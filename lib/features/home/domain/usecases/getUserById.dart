import 'package:buldm/features/auth/domain/entities/userentities.dart';
import 'package:buldm/features/home/data/repository/postrepositoryimp.dart';

class Getuserbyid {
  final Postrepositoryimp postRepository;

  Getuserbyid({
    required this.postRepository,
  });

  Future<User> call(String userId) async {
    return await postRepository.getUserById(userId);
  }
}
