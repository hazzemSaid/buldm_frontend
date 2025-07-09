part of 'imagespicker_cubit.dart';

abstract class ImagespickerState extends Equatable {
  const ImagespickerState();

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => true;
}

class ImagespickerInitial extends ImagespickerState {
  const ImagespickerInitial();
}

class ImagespickerLoaded extends ImagespickerState {
  final List<XFile> images;
  const ImagespickerLoaded({required this.images});
  @override
  List<Object?> get props => [images];
  @override
  bool? get stringify => true;
}

class ImagespickerError extends ImagespickerState {
  final String message;
  const ImagespickerError({required this.message});

  @override
  List<Object?> get props => [message];
}
