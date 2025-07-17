import 'package:buldm/features/auth/domain/entities/userentities.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'usermodel.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject implements User, Equatable {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String avatar;
  @HiveField(3)
  final String token;
  @HiveField(4)
  final String refreshToken;
  @HiveField(5)
  final String user_id;
  UserModel({
    required this.user_id,
    required this.name,
    required this.email,
    this.avatar = "/image/2024.png",
    required this.token,
    required this.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      user_id: json['user_id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'] ?? '/image/2024.png',
      token: json['token'],
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'token': token,
      'refreshToken': refreshToken
    };
  }

  @override
  // TODO: implement props
  List<Object?> get props =>
      [name, email, avatar, token, refreshToken, user_id];

  @override
  // TODO: implement stringify
  bool? get stringify => true;
}

// Run the build runner to generate the adapter
// Command: dart run build_runner build --delete-conflicting-outputs
