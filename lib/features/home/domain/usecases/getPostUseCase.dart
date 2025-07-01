import 'package:buldm/features/home/domain/entities/postentity.dart';
import 'package:buldm/features/home/domain/repository/postrepository.dart';

class GetPostUseCase {
  final Postrepository postrepository;
  GetPostUseCase({required this.postrepository});
  Future<List<PostEntity>> call({
    String? category,
    String? status,
    String? userId,
    String? searchQuery,
    int? limit,
    int? page,
    required String token,
  }) {
    return postrepository.getPosts(
      category: category,
      status: status,
      userId: userId,
      searchQuery: searchQuery,
      limit: limit,
      page: page,
      token: token,
    );
  }
}
