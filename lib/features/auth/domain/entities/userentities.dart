class User {
  final String name;
  final String email;
  final String avatar;
  final String? token;
  User({
    required this.name,
    required this.email,
    this.avatar = "/image/2024.png",
    this.token,
  });
}
