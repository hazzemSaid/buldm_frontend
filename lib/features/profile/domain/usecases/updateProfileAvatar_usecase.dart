import 'package:buldm/features/profile/domain/repo/ProfileRepository.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfileAvatarUseCase {
  final ProfileRepository profileRepository;

  UpdateProfileAvatarUseCase(this.profileRepository);

  Future<Response> call({
    required String userId,
    required String token,
    required XFile imagePath,
  }) async {
    return await profileRepository.updateProfileAvatar(
      userId: userId,
      token: token,
      imagePath: imagePath,
    );
  }
}
