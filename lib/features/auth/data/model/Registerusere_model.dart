import 'package:buldm/features/auth/domain/entities/registeruserentities.dart';

class RegisterusereModel extends UserRegistration {
  RegisterusereModel({
    required super.state,
    required super.message,
    required super.user,
  });
  factory RegisterusereModel.fromJson(Map<String, dynamic> json) {
    return RegisterusereModel(
      state: json['success'] ? 'success' : 'error',
      message: json['message'],
      user: json['user'],
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
    return 'RegisterusereModel(state: $state, message: $message, user: $user)';
  }
}
