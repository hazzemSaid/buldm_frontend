import 'package:buldm/features/profile/domain/repo/ProfileRepository.dart';
import 'package:dio/dio.dart';

class Fetchpost {
  final ProfileRepository profileRepository;
  Fetchpost({required this.profileRepository});
  Future<Response> call({
    required String token,
    required String userId,
  }) async {
    return await profileRepository.fetchPost(token: token, userId: userId);
  }
}
