import 'package:buldm/features/auth/domain/entities/userentities.dart';
import 'package:hive/hive.dart';

part 'usermodel.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject implements User {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String avatar;
  @HiveField(3)
  final String? token;

  UserModel({
    required this.name,
    required this.email,
    this.avatar = "/image/2024.png",
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'] ?? '/image/2024.png',
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'avatar': avatar, 'token': token};
  }
}

// Run the build runner to generate the adapter
// Command: dart run build_runner build --delete-conflicting-outputs
