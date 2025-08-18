import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/home/domain/repository/postrepository.dart'
    show Postrepository;
import 'package:either_dart/either.dart';

class Getlikedpostusecase {
  final Postrepository postRepository;

  Getlikedpostusecase({required this.postRepository});

  Future<Either<Failure, Set<String>>> call(String postId) {
    return postRepository.getLikesByPostId(postId);
  }
}
