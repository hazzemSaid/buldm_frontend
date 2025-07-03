import 'package:bloc/bloc.dart';
import 'package:buldm/features/auth/domain/entities/userentities.dart';
import 'package:buldm/features/home/domain/usecases/getUserById.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_event.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final Getuserbyid getuserbyid;
  final Map<String, User> _userCache = {};

  UserBloc({required this.getuserbyid}) : super(UserLoaded(users: {})) {
    on<LoadUserEvent>(_onUserLoaded);
  }

  Future<void> _onUserLoaded(
    LoadUserEvent event,
    Emitter<UserState> emit,
  ) async {
    // ✅ Skip if already cached and not forced
    if (!event.forceRefresh && _userCache.containsKey(event.userId)) {
      return;
    }

    try {
      final user = await getuserbyid(event.userId);
      _userCache[event.userId] = user;

      emit(UserLoaded(users: {..._userCache}));
    } catch (e) {
      emit(UserError(message: e.toString(), userId: event.userId));
    }
  }
}
