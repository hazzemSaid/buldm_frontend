import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

part 'imagespicker_state.dart';

class ImagespickerCubit extends Cubit<ImagespickerState> {
  ImagespickerCubit() : super(ImagespickerInitial());
  void selectImages(List<XFile> images) {
    emit(ImagespickerLoaded(images: images));
  }

  void clearImages() {
    emit(ImagespickerInitial());
  }
}
