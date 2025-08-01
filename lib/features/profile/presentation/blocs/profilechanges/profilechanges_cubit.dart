import 'package:bloc/bloc.dart';
import 'package:buldm/features/profile/domain/usecases/updateProfileAvatar_usecase.dart';
import 'package:equatable/equatable.dart' show Equatable;
import 'package:image_picker/image_picker.dart';

part 'profilechanges_state.dart';

class ProfilechangesCubit extends Cubit<ProfilechangesState> {
  final UpdateProfileAvatarUseCase updateProfileAvatarUsecase;
  ProfilechangesCubit({required this.updateProfileAvatarUsecase})
      : super(ProfilechangesState.initial());

  Future<void> updateProfileAvatar({
    required String userId,
    required String token,
    required XFile imagePath,
  }) async {
    emit(ProfileChangesAvatarUpdatedLoading());
    try {
      final response = await updateProfileAvatarUsecase.call(
        userId: userId,
        token: token,
        imagePath: imagePath,
      );
      if (response.statusCode == 200) {
        emit(ProfileChangesAvatarUpdatedSuccess(
          imageurl: response.data['user']['avatar'],
        ));
      } else {
        emit(ProfileChangesAvatarUpdatedError(
            message: 'Failed to update avatar'));
      }
    } catch (e) {
      emit(ProfileChangesAvatarUpdatedError(message: e.toString()));
    }
  }
}
