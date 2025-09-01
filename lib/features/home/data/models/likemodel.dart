//like
import 'package:equatable/equatable.dart';

class LikeModel extends Equatable {
  final List<String> usersIDS;
  final bool isliked;
  const LikeModel({
    required this.usersIDS,
    required this.isliked,
  });
  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      usersIDS: json['usersIDS'] ?? [],
      isliked: json['isliked'] ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'usersIDS': usersIDS,
      'isliked': isliked,
    };
  }

  @override
  List<Object?> get props => [usersIDS, isliked];
  @override
  String toString() {
    return 'LikeModel(usersIDS: $usersIDS, isliked: $isliked)';
  }

  LikeModel copyWith({
    String? userId,
    String? postId,
    DateTime? createdAt,
    String? id,
  }) {
    return LikeModel(
      usersIDS: usersIDS ?? this.usersIDS,
      isliked: isliked ?? this.isliked,
    );
  }
}
