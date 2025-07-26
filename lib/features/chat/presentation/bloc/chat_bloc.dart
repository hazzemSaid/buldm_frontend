// features/chat/presentation/bloc/chat_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/core/http/socket.io/socketserver.dart';
import 'package:buldm/features/chat/data/models/MessageModel.dart';
import 'package:buldm/features/chat/data/models/contacntListmodel.dart';
import 'package:buldm/features/chat/domain/usecases/getAllMessagesById.dart';
import 'package:buldm/features/chat/domain/usecases/getMessagesByTId.dart';
import 'package:buldm/features/chat/presentation/bloc/chat_event.dart';
import 'package:buldm/features/chat/presentation/bloc/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetAllMessagesById getAllMessagesById;
  final GetMessagesByTId getMessagesByTId;
  final SocketService socketService;

  StreamSubscription? _messageSubscription;
  String? _currentUserId;

  // Cache for loaded conversations to avoid re-fetching
  final Map<String, List<MessageModel>> _conversationCache = {};

  ChatBloc({
    required this.getAllMessagesById,
    required this.getMessagesByTId,
    required this.socketService,
  }) : super(ChatInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<LoadMessages>(_onLoadMessages);
    on<SwitchConversation>(_onSwitchConversation);
    on<SendMessage>(_onSendMessage);
    on<MessageReceived>(_onMessageReceived);
    on<UpdateConversations>(_onUpdateConversations);
    on<RegisterUser>(_onRegisterUser);
    on<ConnectToSocket>(_onConnectToSocket);
    on<DisconnectFromSocket>(_onDisconnectFromSocket);
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final conversations = await getAllMessagesById(event.userId);
      emit(ConversationsLoaded(conversations));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      print(
          '📥 Loading past messages for conversation: ${event.userId1} <-> ${event.userId2}');
      final messages = await getMessagesByTId(event.userId1, event.userId2);
      print('📥 Loaded ${messages.length} past messages');

      // Backend returns messages in descending order (newest first),
      // but we need ascending order (oldest first) for chat UI
      // So we reverse the list to get proper chronological order
      messages.sort((a, b) {
        if (a.timestamp == null && b.timestamp == null) return 0;
        if (a.timestamp == null) return -1;
        if (b.timestamp == null) return 1;
        return b.timestamp!
            .compareTo(a.timestamp!); // Keep descending order from backend
      });
      // Then reverse to get ascending order for chat display
      final sortedMessages = messages.reversed.toList();

      // Cache the conversation
      final conversationId = _getConversationId(event.userId1, event.userId2);
      _conversationCache[conversationId] = sortedMessages;

      emit(MessagesLoaded(sortedMessages, isInitialLoad: true));
      print('✅ Past messages loaded successfully and cached');
    } catch (e) {
      print('❌ Error loading past messages: $e');
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    // Generate a temporary ID for optimistic message
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    final newMessage = MessageModel(
      message: event.message,
      from: event.fromUserId,
      to: event.toUserId,
      timestamp:
          null, // Don't set timestamp for optimistic message, let backend set it
      id: tempId, // Temporary ID for tracking
    );

    // Update messages if we're in MessagesLoaded state
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;

      // Add message to current state immediately for optimistic UI
      final updatedMessages = List<MessageModel>.from(currentState.messages)
        ..add(newMessage);
      emit(MessagesLoaded(updatedMessages, isInitialLoad: false));
    }

    // Send via socket
    final success = socketService.sendMessage(
      event.toUserId,
      event.message,
    );
    if (!success) {
      emit(ChatError('Failed to send message'));
    }

    // Update conversations list locally without triggering API calls
    if (state is ConversationsLoaded || state is ConversationsUpdated) {
      final currentState = state is ConversationsLoaded
          ? (state as ConversationsLoaded).conversations
          : (state as ConversationsUpdated).conversations;

      final updatedConversations = _updateConversationLocally(
          currentState, newMessage, event.fromUserId);

      emit(ConversationsUpdated(updatedConversations));
    }
  }

  void _onMessageReceived(
    MessageReceived event,
    Emitter<ChatState> emit,
  ) {
    final newMessage = event.message;
    print(
        '📨 Message received: ${newMessage.message} from ${newMessage.from} to ${newMessage.to}');

    // Update conversations list locally when a message is received
    print('🔄 Updating conversations locally');
    if (state is ConversationsLoaded || state is ConversationsUpdated) {
      final currentState = state is ConversationsLoaded
          ? (state as ConversationsLoaded).conversations
          : (state as ConversationsUpdated).conversations;

      final updatedConversations = _updateConversationLocally(
          currentState, newMessage, _currentUserId ?? '');

      emit(ConversationsUpdated(updatedConversations));
    }

    // Update messages if we're in MessagesLoaded state
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;

      // Check if this message belongs to the current conversation
      final isCurrentConversation =
          (newMessage.from == currentState.messages.firstOrNull?.from &&
                  newMessage.to == currentState.messages.firstOrNull?.to) ||
              (newMessage.from == currentState.messages.firstOrNull?.to &&
                  newMessage.to == currentState.messages.firstOrNull?.from);

      if (isCurrentConversation) {
        print('📨 Processing message for current conversation');

        // Check if this is a response to our optimistic message
        final optimisticMessageIndex = currentState.messages.indexWhere((msg) =>
            msg.id?.startsWith('temp_') == true &&
            msg.message == newMessage.message &&
            msg.from == newMessage.from &&
            msg.to == newMessage.to);

        if (optimisticMessageIndex != -1) {
          print(
              '🔄 Replacing optimistic message with real message from backend');
          // Replace optimistic message with real message from backend
          final updatedMessages =
              List<MessageModel>.from(currentState.messages);
          updatedMessages[optimisticMessageIndex] = newMessage;

          // Sort messages by timestamp in ascending order (oldest first)
          updatedMessages.sort((a, b) {
            if (a.timestamp == null && b.timestamp == null) return 0;
            if (a.timestamp == null) return -1;
            if (b.timestamp == null) return 1;
            return a.timestamp!.compareTo(b.timestamp!);
          });
          emit(MessagesLoaded(updatedMessages, isInitialLoad: false));
        } else {
          // Check if this is a completely new message (not a duplicate)
          final existingMessage = currentState.messages.any((msg) =>
              msg.id == newMessage.id ||
              (msg.message == newMessage.message &&
                  msg.timestamp == newMessage.timestamp &&
                  msg.from == newMessage.from));

          if (!existingMessage) {
            print('📨 Adding new message from socket to conversation');
            final updatedMessages =
                List<MessageModel>.from(currentState.messages)..add(newMessage);
            // Sort messages by timestamp in ascending order (oldest first)
            updatedMessages.sort((a, b) {
              if (a.timestamp == null && b.timestamp == null) return 0;
              if (a.timestamp == null) return -1;
              if (b.timestamp == null) return 1;
              return a.timestamp!.compareTo(b.timestamp!);
            });
            emit(MessagesLoaded(updatedMessages, isInitialLoad: false));
          } else {
            print('⚠️ Message already exists, skipping duplicate');
          }
        }
      } else {
        print(
            '⚠️ Message not for current conversation, only updating chat list');
      }
    }
  }

  Future<void> _onSwitchConversation(
    SwitchConversation event,
    Emitter<ChatState> emit,
  ) async {
    final conversationId = _getConversationId(event.userId1, event.userId2);

    // Check if conversation is already cached
    if (_conversationCache.containsKey(conversationId)) {
      print('🔄 Switching to cached conversation: $conversationId');
      final cachedMessages = _conversationCache[conversationId]!;
      emit(ConversationSwitched(cachedMessages, conversationId));
    } else {
      print('📥 Conversation not cached, loading from API: $conversationId');
      // If not cached, load from API
      add(LoadMessages(event.userId1, event.userId2));
    }
  }

  String _getConversationId(String userId1, String userId2) {
    // Create a consistent conversation ID regardless of sender/receiver order
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  Future<void> _onUpdateConversations(
    UpdateConversations event,
    Emitter<ChatState> emit,
  ) async {
    print('🔄 Updating conversations for message: ${event.message.message}');
    if (_currentUserId != null) {
      try {
        // Only call API if we don't have conversations loaded yet
        if (state is! ConversationsLoaded && state is! ConversationsUpdated) {
          final conversations = await getAllMessagesById(_currentUserId!);
          print('📋 Fetched ${conversations.length} conversations from API');
          emit(ConversationsLoaded(conversations));
        } else {
          // Update conversations locally without API call
          final currentState = state is ConversationsLoaded
              ? (state as ConversationsLoaded).conversations
              : (state as ConversationsUpdated).conversations;

          final updatedConversations = _updateConversationLocally(
              currentState, event.message, _currentUserId!);

          print(
              '📋 Updated ${updatedConversations.length} conversations locally');
          emit(ConversationsUpdated(updatedConversations));
        }
      } catch (e) {
        // Don't emit error state, just log it
        print('❌ Error updating conversations: $e');
      }
    } else {
      print('⚠️ No current user ID available for conversation update');
    }
  }

  List<ChatContactDirectory> _updateConversationLocally(
    List<ChatContactDirectory> conversations,
    MessageModel newMessage,
    String currentUserId,
  ) {
    final otherUserId =
        newMessage.from == currentUserId ? newMessage.to : newMessage.from;

    // Find existing conversation
    final existingIndex =
        conversations.indexWhere((conv) => conv.user == otherUserId);

    if (existingIndex != -1) {
      // Update existing conversation
      final existingConversation = conversations[existingIndex];
      final updatedMessages =
          List<MessageModel>.from(existingConversation.messages)
            ..add(newMessage);

      final updatedConversation = ChatContactDirectory(
        user: existingConversation.user,
        messages: updatedMessages,
        lastActivity: newMessage.timestamp ?? DateTime.now(),
      );

      final updatedConversations =
          List<ChatContactDirectory>.from(conversations);
      updatedConversations[existingIndex] = updatedConversation;

      // Sort by last activity (most recent first)
      updatedConversations.sort((a, b) {
        if (a.lastActivity == null && b.lastActivity == null) return 0;
        if (a.lastActivity == null) return 1;
        if (b.lastActivity == null) return -1;
        return b.lastActivity!.compareTo(a.lastActivity!);
      });

      return updatedConversations;
    } else {
      // Create new conversation
      final newConversation = ChatContactDirectory(
        user: otherUserId,
        messages: [newMessage],
        lastActivity: newMessage.timestamp ?? DateTime.now(),
      );

      final updatedConversations =
          List<ChatContactDirectory>.from(conversations)..add(newConversation);

      // Sort by last activity (most recent first)
      updatedConversations.sort((a, b) {
        if (a.lastActivity == null && b.lastActivity == null) return 0;
        if (a.lastActivity == null) return 1;
        if (b.lastActivity == null) return -1;
        return b.lastActivity!.compareTo(a.lastActivity!);
      });

      return updatedConversations;
    }
  }

  Future<void> _onRegisterUser(
    RegisterUser event,
    Emitter<ChatState> emit,
  ) async {
    _currentUserId = event.userId;
    print('👤 Registering user: $event.userId');

    // Ensure socket is connected before registering
    if (!socketService.isConnected) {
      print('⚠️ Socket not connected, attempting to connect...');
      final connected = await socketService.connect();
      if (!connected) {
        print('❌ Failed to connect socket for user registration');
        return;
      }
    }

    socketService.registerUser(event.userId);
    emit(UserRegistered(event.userId));
  }

  Future<void> _onConnectToSocket(
    ConnectToSocket event,
    Emitter<ChatState> emit,
  ) async {
    emit(SocketConnecting());
    try {
      print('🔌 Attempting to connect to socket server...');
      final connected = await socketService.connect();
      if (connected) {
        print('✅ Socket connected successfully');
        emit(SocketConnected());
        _setupMessageListener();
      } else {
        print('❌ Failed to connect to socket server');
        emit(SocketError('Failed to connect to socket server'));
      }
    } catch (e) {
      print('❌ Socket connection error: $e');
      emit(SocketError(e.toString()));
    }
  }

  Future<void> _onDisconnectFromSocket(
    DisconnectFromSocket event,
    Emitter<ChatState> emit,
  ) async {
    _messageSubscription?.cancel();
    socketService.disconnect();
    emit(SocketDisconnected());
  }

  void _setupMessageListener() {
    _messageSubscription?.cancel();
    _messageSubscription = null;

    print('🔌 Setting up message listener for ChatBloc');
    socketService.listenForMessages((data) {
      try {
        print('📥 Raw message received in ChatBloc: $data');
        final message = MessageModel.fromJson(data);
        print(
            '📥 Parsed message: ${message.message} from ${message.from} to ${message.to}');
        add(MessageReceived(message));
      } catch (e) {
        print('❌ Error parsing received message: $e');
        print('❌ Problematic data: $data');
      }
    });
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
