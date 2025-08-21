// features/home/persentation/bloc/user/user_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:buldm/features/auth/domain/entities/userentities.dart';
import 'package:buldm/features/home/domain/usecases/getUserById.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_event.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final Getuserbyid getuserbyid;
  // In-memory cache with freshness tracking
  final Map<String, _CacheEntry> _cache = {};
  // Track in-flight requests to avoid duplicate fetches
  final Set<String> _inFlight = {};
  // Time-to-live for cache entries
  final Duration ttl;

  UserBloc({required this.getuserbyid, this.ttl = const Duration(minutes: 5)})
      : super(UserLoaded(users: {})) {
    on<LoadUserEvent>(_onUserLoaded);
    on<LoadMultipleUsersEvent>(_onMultipleUsersLoaded);
    on<ClearUserCacheEvent>(_onClearCache);
  }

  Future<void> _onUserLoaded(
    LoadUserEvent event,
    Emitter<UserState> emit,
  ) async {
    // If cached and fresh, return cached map
    final cached = _cache[event.userId];
    if (!event.forceRefresh && cached != null && cached.isFresh(ttl)) {
      emit(UserLoaded(users: _currentUsersMap()));
      return;
    }
    emit(UserLoading());
    try {
      // Avoid duplicate concurrent fetches
      if (_inFlight.contains(event.userId)) {
        // Another request is already fetching this user; do nothing now.
        return;
      }

      _inFlight.add(event.userId);
      emit(UserLoading());

      final user = await getuserbyid(event.userId);
      _cache[event.userId] = _CacheEntry(user: user, fetchedAt: DateTime.now());

      emit(UserLoaded(users: _currentUsersMap()));
    } catch (e) {
      emit(UserError(message: e.toString(), userId: event.userId));
    } finally {
      _inFlight.remove(event.userId);
    }
  }

  Future<void> _onMultipleUsersLoaded(
    LoadMultipleUsersEvent event,
    Emitter<UserState> emit,
  ) async {
    // Determine which users need fetching (missing or stale or forced)
    final toFetch = <String>[];
    for (final id in event.userIds) {
      final cached = _cache[id];
      final needsFetch =
          event.forceRefresh || cached == null || !cached.isFresh(ttl);
      if (needsFetch && !_inFlight.contains(id)) {
        toFetch.add(id);
      }
    }

    if (toFetch.isEmpty) {
      // Everything is fresh in cache
      emit(UserLoaded(users: _currentUsersMap()));
      return;
    }

    // Mark as in-flight
    _inFlight.addAll(toFetch);

    try {
      // Fetch all missing/stale users in parallel
      final results = await Future.wait<User>(
          toFetch.map((id) async => await getuserbyid(id)));
      for (var i = 0; i < toFetch.length; i++) {
        final id = toFetch[i];
        final user = results[i];
        _cache[id] = _CacheEntry(user: user, fetchedAt: DateTime.now());
      }

      emit(UserLoaded(users: _currentUsersMap()));
    } catch (e) {
      // Emit an error for the batch; you may adjust to per-id if needed
      // Here we emit the first id that failed contextually is unknown; fallback to general error
      emit(UserError(
          userId: toFetch.isNotEmpty ? toFetch.first : '-',
          message: e.toString()));
    } finally {
      for (final id in toFetch) {
        _inFlight.remove(id);
      }
    }
  }

  // Clear all cached users and reset state
  void _onClearCache(
    ClearUserCacheEvent event,
    Emitter<UserState> emit,
  ) {
    _cache.clear();
    // Note: keep _inFlight as-is; usually none during pull-to-refresh
    emit(const UserLoaded(users: {}));
  }

  Map<String, User> _currentUsersMap() {
    return {
      for (final entry in _cache.entries) entry.key: entry.value.user,
    };
  }
}

class _CacheEntry {
  final User user;
  final DateTime fetchedAt;

  _CacheEntry({required this.user, required this.fetchedAt});

  bool isFresh(Duration ttl) => DateTime.now().difference(fetchedAt) < ttl;
}
