import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  // 1. static instance
  static final SocketService _instance = SocketService._internal();

  // 2. private constructor
  SocketService._internal();

  // 3. public factory
  factory SocketService() => _instance;

  // 4. socket object
  late IO.Socket _socket;

  // 5. getter for socket
  IO.Socket get socket => _socket;

  bool _isConnected = false;
  bool _isConnecting = false;
  String? _registeredUserId;

  // 6. improved connect method with better error handling
  Future<bool> connect() async {
    if (_isConnected) return true;
    if (_isConnecting) return false;

    _isConnecting = true;

    try {
      _socket = IO.io(
        'http://192.168.1.8:3000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .setTimeout(20000)
            .disableAutoConnect()
            .build(),
      );

      _socket.connect();

      _socket.onConnect((_) {
        print('🔌 Connected to socket server: ${_socket.id}');
        _isConnected = true;
        _isConnecting = false;

        // Re-register user if was previously registered
        if (_registeredUserId != null) {
          registerUser(_registeredUserId!);
        }
      });

      _socket.onDisconnect((reason) {
        print('❌ Disconnected from socket server. Reason: $reason');
        _isConnected = false;
        _isConnecting = false;
      });

      _socket.onConnectError((error) {
        print('🚫 Connection error: $error');
        _isConnected = false;
        _isConnecting = false;
      });

      _socket.onError((error) {
        print('⚠️ Socket error: $error');
      });

      return true;
    } catch (e) {
      print('❌ Failed to connect: $e');
      _isConnected = false;
      _isConnecting = false;
      return false;
    }
  }

  // 7. improved register user with validation
  void registerUser(String userId) {
    if (userId.isEmpty) {
      print('⚠️ Cannot register empty userId');
      return;
    }

    _registeredUserId = userId;

    if (_socket.connected) {
      _socket.emit('register', {'userId': userId});
      print('✅ Registered user $userId');
    } else {
      print('⚠️ Socket not connected! Will register when connected.');
    }
  }

  // 8. improved send message with validation
  bool sendMessage(String toUserId, String message) {
    if (!_isConnected) {
      print('⚠️ Cannot send message - not connected');
      return false;
    }

    if (toUserId.isEmpty || message.isEmpty) {
      print('⚠️ Cannot send empty message or to empty userId');
      return false;
    }

    try {
      _socket.emit('SendMessage', {
        'touserId': toUserId,
        'Message': message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      print('📤 Message sent to $toUserId');
      return true;
    } catch (e) {
      print('❌ Failed to send message: $e');
      return false;
    }
  }

  // 9. improved listen to messages with error handling
  void listenForMessages(Function(Map<String, dynamic>) onMessageReceived) {
    _socket.on('ReceiveMessage', (data) {
      try {
        print('📥 Raw message received: $data');

        if (data is Map<String, dynamic>) {
          onMessageReceived(data);
        } else if (data is Map) {
          // Convert to Map<String, dynamic> if needed
          final convertedData = Map<String, dynamic>.from(data);
          onMessageReceived(convertedData);
        } else {
          print('⚠️ Unexpected data format: $data (${data.runtimeType})');
        }
      } catch (e) {
        print('❌ Error processing received message: $e');
        print('❌ Problematic data: $data');
      }
    });

    // Listen for typing indicators if your server supports it
    _socket.on('userTyping', (data) {
      print('⌨️ User typing: $data');
      // Handle typing indicator
    });

    // Listen for user online/offline status
    _socket.on('userStatus', (data) {
      print('👤 User status changed: $data');
      // Handle user status changes
    });
  }

  // 10. check connection status
  bool get isConnected => _isConnected && _socket.connected;

  // 11. improved disconnect with cleanup
  void disconnect() {
    try {
      if (_socket.connected) {
        _socket.disconnect();
      }
      _socket.dispose();
    } catch (e) {
      print('⚠️ Error during disconnect: $e');
    } finally {
      _isConnected = false;
      _isConnecting = false;
      _registeredUserId = null;
    }
  }

  // 12. reconnect method
  Future<bool> reconnect() async {
    disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    return await connect();
  }

  // 13. get connection status
  Map<String, dynamic> getConnectionStatus() {
    return {
      'isConnected': _isConnected,
      'isConnecting': _isConnecting,
      'socketId': _socket.connected ? _socket.id : null,
      'registeredUserId': _registeredUserId,
    };
  }
}
