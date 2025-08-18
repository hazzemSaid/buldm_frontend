import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/home/domain/repository/postrepository.dart';
import 'package:either_dart/either.dart';

class SetCommentUseCase {
  final Postrepository postRepository;

  SetCommentUseCase({required this.postRepository});

  Future<Either<Failure, void>> call(String postId, String content) {
    return postRepository.setComment(postId, content);
  }
}
