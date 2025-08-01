part of 'profilechanges_cubit.dart';

abstract class ProfilechangesState extends Equatable {
  const ProfilechangesState();

  @override
  List<Object?> get props => [];

  factory ProfilechangesState.initial() => ProfileChangesInitial();
}

class ProfileChangesInitial extends ProfilechangesState {}

class ProfileChangesLoading extends ProfilechangesState {}

class ProfileChangesError extends ProfilechangesState {
  final String message;
  const ProfileChangesError({required this.message});
}

class ProfileChangesSuccess extends ProfilechangesState {
  final String message;
  const ProfileChangesSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProfileChangesAvatarUpdatedLoading extends ProfilechangesState {
  const ProfileChangesAvatarUpdatedLoading();

  @override
  List<Object?> get props => [];
}

class ProfileChangesAvatarUpdatedSuccess extends ProfilechangesState {
  final String imageurl;
  const ProfileChangesAvatarUpdatedSuccess({required this.imageurl});

  @override
  List<Object?> get props => [imageurl];
}

class ProfileChangesAvatarUpdatedError extends ProfilechangesState {
  final String message;
  const ProfileChangesAvatarUpdatedError({required this.message});

  @override
  List<Object?> get props => [message];
}
