import 'package:equatable/equatable.dart';

class UserProfileModel extends Equatable {
  final String id;
  final String name;
  final String avatar;
  UserProfileModel({
    required this.id,
    required this.name,
    required this.avatar,
  });
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['_id'],
      name: json['name'],
      avatar: json['avatar'],
    );
  }

  @override
  List<Object?> get props => [id];
  @override
  String toString() =>
      'UserProfileModel(id: $id, name: $name, avatar: $avatar)';
}/*   "_id": "689a677320a1503a42519a23",
                "name": "hazem",
                "avatar": "https://lh3.googleusercontent.com/a/ACg8ocLM2GW7-Zm8mwk57_MMTv76ClWVq-iXGtdaFkwZ9_mHZv0svJHb=s96-c"*/