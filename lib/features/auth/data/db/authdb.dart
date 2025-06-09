import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/utils/constrains.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

class Authdb {
  Future<Response> sendTokenToBackend(String idToken) async {
    final dio = Dio();
    const baseurl = Appconstrains.Baseurl;
    final response = dio.post(
      '$baseurl/api/v1/user/google_auth',
      data: {'token': idToken},
    );
    return response;
  }
}
