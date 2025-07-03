import 'dart:io';

import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/home/data/models/location_model.dart';
import 'package:buldm/features/home/data/models/post_model.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

class AddPostScreen extends StatelessWidget {
  const AddPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IconButton(
          onPressed: () async {
            final userBox = Hive.box<UserModel>('user');
            final user = userBox.get('user');
            if (user == null || user.token == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User not logged in')),
              );
              return;
            }

            // اختر صورة من المعرض
            final ImagePicker picker = ImagePicker();
            final XFile? pickedFile =
                await picker.pickImage(source: ImageSource.gallery);

            if (pickedFile == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No image selected')),
              );
              return;
            }

            final File imageFile = File(pickedFile.path);
            final token = user.token;

            // إرسال الحدث إلى PostBloc
            context.read<PostBloc>().add(
                  AddPostEvent(
                    post: PostModel(
                      title: 'back',
                      description: 'back',
                      category: 'back',
                      location: LocationModel(
                        type: "found",
                        coordinates: [0, 0],
                        placeName: "",
                      ),
                      user_id: "67fa7475705be9c78ea1cfc0",
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      images: [], // سيتم رفع الصورة كـ MultipartFile في backend
                      status: 'found',
                      predictedItems: [],
                      contactInfo: '',
                      when: DateTime.now(),
                    ),
                    token: token,
                    imageFile: imageFile,
                  ),
                );
          },
          icon:
              const Icon(Icons.add_circle, size: 50, color: Colors.blueAccent),
        ),
      ),
    );
  }
}
