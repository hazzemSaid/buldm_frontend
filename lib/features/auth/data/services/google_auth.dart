import 'package:either_dart/either.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuth {
  static String webClientId = dotenv.get('webClientId');

  static String androidID = dotenv.get('androidID');

  Future<Either<Exception, String>> googleauth_service() async {
    // this class using the solid pri to make the google auth service to gave the db a token id
    final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile', 'openid'],
      serverClientId:
          webClientId, // This ensures the ID token has the correct audience
      // Remove clientId or set it to null for Android
    );
    await _googleSignIn.signOut(); // optional

    final account = await _googleSignIn.signIn();

    if (account == null) {
      return Left(Exception('Google sign in was cancelled'));
    }

    final authentication = await account.authentication;
    final idToken = authentication.idToken;

    if (idToken == null) {
      return Left(Exception('Failed to retrieve ID token'));
    }
    return Right(idToken);
  }
}

  // void debugPrintTokenPayload(String idToken) {
  //   try {
  //     final parts = idToken.split('.');
  //     if (parts.length == 3) {
  //       final payload = parts[1];
  //       // Add padding if needed
  //       final normalizedPayload = payload + '=' * (4 - payload.length % 4);
  //       final decoded = utf8.decode(base64Url.decode(normalizedPayload));
  //       final payloadMap = json.decode(decoded);

  //       final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  //       final exp = payloadMap['exp'] as int;
  //       final timeToExpiry = exp - now;

  //       print('Token Payload:');
  //       print('  iss: ${payloadMap['iss']}');
  //       print('  aud: ${payloadMap['aud']}');
  //       print('  azp: ${payloadMap['azp']}');
  //       print(
  //         '  exp: ${payloadMap['exp']} (${DateTime.fromMillisecondsSinceEpoch(exp * 1000)})',
  //       );
  //       print('  current time: $now (${DateTime.now()})');
  //       print('  time to expiry: ${timeToExpiry} seconds');
  //       print('  email: ${payloadMap['email']}');

  //       if (timeToExpiry < 60) {
  //         print('  WARNING: Token expires in less than 1 minute!');
  //       }
  //     }
  //   } catch (e) {
  //     print('Failed to decode token: $e');
  //   }
  // }
