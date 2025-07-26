// features/chat/presentation/bloc/chat_event.dart
import 'package:equatable/equatable.dart';
import 'package:buldm/features/chat/data/models/MessageModel.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadConversations extends ChatEvent {
  final String userId;

  const LoadConversations(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadMessages extends ChatEvent {
  final String userId1;
  final String userId2;

  const LoadMessages(this.userId1, this.userId2);

  @override
  List<Object?> get props => [userId1, userId2];
}

class SendMessage extends ChatEvent {
  final String message;
  final String fromUserId;
  final String toUserId;

  const SendMessage({
    required this.message,
    required this.fromUserId,
    required this.toUserId,
  });

  @override
  List<Object?> get props => [message, fromUserId, toUserId];
}

class MessageReceived extends ChatEvent {
  final MessageModel message;

  const MessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class RegisterUser extends ChatEvent {
  final String userId;

  const RegisterUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ConnectToSocket extends ChatEvent {
  const ConnectToSocket();
}

class DisconnectFromSocket extends ChatEvent {
  const DisconnectFromSocket();
}

class UpdateConversations extends ChatEvent {
  final MessageModel message;

  const UpdateConversations(this.message);

  @override
  List<Object?> get props => [message];
}

class SwitchConversation extends ChatEvent {
  final String userId1;
  final String userId2;

  const SwitchConversation(this.userId1, this.userId2);

  @override
  List<Object?> get props => [userId1, userId2];
}
