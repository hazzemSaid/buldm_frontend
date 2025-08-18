import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/home/domain/repository/postrepository.dart';
import 'package:either_dart/either.dart';

class UpdatePostUseCase {
  final Postrepository postRepository;

  UpdatePostUseCase({required this.postRepository});

  Future<Either<Failure, void>> call(String postId, Map<String, dynamic> data) {
    return postRepository.updatePost(postId, data);
  }
}
