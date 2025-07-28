import 'package:buldm/features/profile/domain/repo/ProfileRepository.dart';
import 'package:dio/dio.dart';

class SearchByName {
  final ProfileRepository profileRepository;

  SearchByName({required this.profileRepository});

  Future<Response> call({required String name}) {
    return profileRepository.searchByName(name: name);
  }
}
