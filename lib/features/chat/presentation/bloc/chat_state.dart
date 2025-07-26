// features/chat/presentation/bloc/chat_state.dart
import 'package:equatable/equatable.dart';
import 'package:buldm/features/chat/data/models/MessageModel.dart';
import 'package:buldm/features/chat/data/models/contacntListmodel.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ConversationsLoaded extends ChatState {
  final List<ChatContactDirectory> conversations;

  const ConversationsLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class MessagesLoaded extends ChatState {
  final List<MessageModel> messages;
  final bool isInitialLoad;

  const MessagesLoaded(this.messages, {this.isInitialLoad = false});

  @override
  List<Object?> get props => [messages, isInitialLoad];
}

class UserRegistered extends ChatState {
  final String userId;

  const UserRegistered(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SocketConnecting extends ChatState {}

class SocketConnected extends ChatState {}

class SocketDisconnected extends ChatState {}

class SocketError extends ChatState {
  final String message;

  const SocketError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class ConversationsUpdated extends ChatState {
  final List<ChatContactDirectory> conversations;

  const ConversationsUpdated(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class ConversationSwitched extends ChatState {
  final List<MessageModel> messages;
  final String conversationId;

  const ConversationSwitched(this.messages, this.conversationId);

  @override
  List<Object?> get props => [messages, conversationId];
}
