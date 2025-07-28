import 'package:buldm/features/auth/domain/entities/registeruserentities.dart';

class RegisterUserModel extends UserRegistration {
  RegisterUserModel({
    required super.state,
    required super.message,
    required super.user,
  });
  /*{
    "success": true,
    "message": "verification code sent to your email",
    "user": {
        "name": "example_name",
        "email": "example@email.com"
    }
}*/

  factory RegisterUserModel.fromJson(Map<String, dynamic> json) {
    return RegisterUserModel(
      state: json['success'] ? 'success' : 'error',
      message: json['message'],
      user: userregister.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'success': state == 'success',
      'message': message,
      'user': user,
    };
  }

  @override
  String toString() {
    return 'RegisterUserModel(state: $state, message: $message, user: $user)';
  }
}

class userregister {
  final email;
  final name;
  userregister({
    required this.email,
    required this.name,
  });
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
    };
  }

  factory userregister.fromJson(Map<String, dynamic> json) {
    return userregister(
      email: json['email'],
      name: json['name'],
    );
  }
}
