import 'package:buldm/features/home/domain/entities/postentity.dart';
import 'package:equatable/equatable.dart';

class PostModel extends PostEntity implements Equatable {
  const PostModel(
      {required super.title,
      required super.description,
      required super.images,
      required super.location,
      required super.status,
      required super.category,
      required super.predictedItems,
      required super.userId,
      required super.contactInfo,
      required super.when,
      required super.createdAt,
      required super.updatedAt,
      required super.id});
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      title: json['title'],
      description: json['description'],
      images: json['images'],
      location: json['location'],
      status: json['status'],
      category: json['category'],
      predictedItems: json['predictedItems'],
      userId: json['userId'],
      contactInfo: json['contactInfo'],
      when: json['when'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      id: json['id'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'images': images,
      'location': location,
      'status': status,
      'category': category,
      'predictedItems': predictedItems,
      'userId': userId,
      'contactInfo': contactInfo,
      'when': when,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'id': id,
    };
  }

  @override
  List<Object?> get props => [
        title,
        description,
        images,
        location,
        status,
        category,
        predictedItems,
        userId,
        contactInfo,
        when,
        createdAt,
        updatedAt,
        id,
      ];

  @override
  bool? get stringify => true;
}
