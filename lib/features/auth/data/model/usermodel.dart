import 'package:hive/hive.dart';

part 'usermodel.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String avatar;

  UserModel({
    required this.name,
    required this.email,
    this.avatar = "/image/2024.png",
  });
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'] ?? '/image/2024.png',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'avatar': avatar};
  }
}

// Run the build runner to generate the adapter
// Command: dart run build_runner build --delete-conflicting-outputs
