import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/home/data/models/post_model.dart';
import 'package:buldm/features/home/domain/repository/postrepository.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

class Createpostusecase {
  final Postrepository postrepository;

  Createpostusecase({required this.postrepository});

  Future<Either<Failure, void>> call(
      {required FormData data, required String token}) async {
    return await postrepository.createPost(data, token);
  }
}
