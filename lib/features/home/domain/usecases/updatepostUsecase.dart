import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/home/data/models/post_model.dart';
import 'package:buldm/features/home/domain/repository/postrepository.dart';
import 'package:either_dart/either.dart';

class Updatepostusecase {
  final Postrepository postRepository;

  Updatepostusecase({required this.postRepository});

  Future<Either<Failure, PostModel>> call(
    String token,
    String postId,
    Map<String, dynamic> data,
  ) {
    return postRepository.updatePost(token, postId, data);
  }
}
