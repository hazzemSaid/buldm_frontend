import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/home/domain/repository/postrepository.dart';
import 'package:either_dart/either.dart';

class ChangeLikePostUseCase {
  final Postrepository postRepository;

  ChangeLikePostUseCase({required this.postRepository});

  Future<Either<Failure, void>> call(String postId, String userId) {
    return postRepository.setLike(postId, userId);
  }
}
