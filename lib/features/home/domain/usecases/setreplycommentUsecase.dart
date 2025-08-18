import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/home/domain/repository/postrepository.dart';
import 'package:either_dart/either.dart';

class SetReplyCommentUseCase {
  final Postrepository postRepository;

  SetReplyCommentUseCase({required this.postRepository});

  Future<Either<Failure, void>> call(
      String postId, String parentCommentId, String content) {
    return postRepository.setCommentReply(postId, parentCommentId, content);
  }
}
