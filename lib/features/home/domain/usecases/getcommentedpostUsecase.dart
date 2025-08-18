import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/home/data/models/comments.dart';
import 'package:buldm/features/home/domain/repository/postrepository.dart';
import 'package:either_dart/either.dart';

class GetCommentedPostUseCase {
  final Postrepository postRepository;

  GetCommentedPostUseCase({required this.postRepository});

  Future<Either<Failure, List<CommentModel>>> call(String postId) {
    return postRepository.getCommentsByPostId(postId);
  }
}
