class User {
  final String name;
  final String email;
  final String avatar;
  final String token;
  final String refreshToken;
  final String user_id;
  User({
    required this.user_id,
    required this.name,
    required this.email,
    this.avatar = "/image/2024.png",
    required this.token,
    required this.refreshToken,
  });
}
