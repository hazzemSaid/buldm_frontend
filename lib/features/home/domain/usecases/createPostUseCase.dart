import 'package:buldm/features/home/domain/repository/postrepository.dart';
import 'package:dio/dio.dart';

class Createpostusecase {
  final Postrepository postrepository;

  Createpostusecase({required this.postrepository});

  Future<Response> call({required FormData data, required String token}) async {
    return await postrepository.createPost(data, token);
  }
}
