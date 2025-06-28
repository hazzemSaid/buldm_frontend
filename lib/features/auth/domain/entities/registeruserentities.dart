class UserRegistration {
  /*{
    "success": true,
    "massage": "verification code sent to your email",
    "user": {
        "name": "hazem",
        "email": "haazemsaidd@gmail.com"
    }
} */

  final String state;
  final String message;
  final Map<String, dynamic> user;
  const UserRegistration({
    required this.state,
    required this.message,
    required this.user,
  });
}
