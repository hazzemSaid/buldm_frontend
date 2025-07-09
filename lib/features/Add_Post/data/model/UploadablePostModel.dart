import 'package:buldm/features/home/data/models/location_model.dart';
import 'package:image_picker/image_picker.dart';

class UploadablePostModel {
  /*predictedItems: [
      {
        label: {
          type: String,
          required: true,
          trim: true,
        },
        confidence: {
          type: Number,
          required: true,
        },
        category: {
          type: String,
          default: "other",
        },
      },
    ], */
  final String title;
  final String description;
  final List<XFile> images; // ملفات الصور
  final LocationModel location;
  final String status;
  final String category;
  final List<dynamic> predictedItems; // يمكن أن تكون قائمة من الكائنات أو القيم
  final String user_id;
  final String contactInfo;
  final DateTime when;
  final DateTime createdAt;
  final DateTime updatedAt;

  UploadablePostModel(
      {required this.title,
      required this.description,
      required this.images,
      required this.location,
      required this.status,
      required this.category,
      required this.predictedItems,
      required this.user_id,
      required this.contactInfo,
      required this.when,
      required this.createdAt,
      required this.updatedAt});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'images': images.map((image) => image.path).toList(),
      'location': location.toJson(),
      'status': status,
      'category': category,
      'predictedItems': predictedItems,
      'user_id': user_id,
      'contactInfo': contactInfo,
      'when': when.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UploadablePostModel.fromJson(Map<String, dynamic> json) {
    return UploadablePostModel(
      title: json['title'],
      description: json['description'],
      images: (json['images'] as List)
          .map((imagePath) => XFile(imagePath))
          .toList(),
      location: LocationModel.fromJson(json['location']),
      status: json['status'],
      category: json['category'],
      predictedItems: json['predictedItems'],
      user_id: json['user_id'],
      contactInfo: json['contactInfo'],
      when: DateTime.parse(json['when']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
