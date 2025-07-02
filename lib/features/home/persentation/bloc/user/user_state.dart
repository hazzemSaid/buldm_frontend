import 'package:buldm/features/auth/domain/entities/userentities.dart';
import 'package:equatable/equatable.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {
  final String userId;

  const UserLoading(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UserLoaded extends UserState {
  final Map<String, User> users;

  const UserLoaded({required this.users});

  @override
  List<Object?> get props => [users];
}

class UserError extends UserState {
  final String userId;
  final String message;

  const UserError({required this.userId, required this.message});

  @override
  List<Object?> get props => [userId, message];
}
