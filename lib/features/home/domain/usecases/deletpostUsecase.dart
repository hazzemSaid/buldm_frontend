import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/home/domain/repository/postrepository.dart';
import 'package:either_dart/either.dart';

class DeletePostUseCase {
  final Postrepository postRepository;

  DeletePostUseCase({required this.postRepository});

  Future<Either<Failure, void>> call(String postId) {
    return postRepository.deletePost(postId);
  }
}
