// features/home/domain/usecases/getIndividualPostUseCase.dart
import 'package:buldm/features/home/data/models/post_model.dart';
import 'package:buldm/features/home/domain/repository/postrepository.dart';

class GetIndividualPostUseCase {
  final Postrepository postrepository;

  GetIndividualPostUseCase({required this.postrepository});

  Future<PostModel> call({
    required String postId,
    required String token,
  }) {
    return postrepository.getPostById(postId, token);
  }
}
