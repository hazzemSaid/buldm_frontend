import 'dart:io';

import 'package:buldm/features/Add_Post/presentation/view/screens/AddPostDetails.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostUploadScreen extends StatefulWidget {
  const PostUploadScreen({super.key});

  @override
  State<PostUploadScreen> createState() => _PostUploadScreenState();
}

class _PostUploadScreenState extends State<PostUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _pickedImages = [];

  Future<void> _selectImages() async {
    final images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() {
        _pickedImages = images;
      });
    }
  }

  void _goNext() {
    // هنا تروح للشاشة اللي فيها تفاصيل النشر
    // وتبعت الصور المختارة
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPostDetails(images: _pickedImages),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Post Upload"),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _pickedImages.clear();
                });
                Navigator.maybePop(context);
              },
            ),
          ],
        ),
        actions: [
          if (_pickedImages.isNotEmpty)
            TextButton(
              onPressed: _goNext,
              child: const Text(
                "التالي",
                style: TextStyle(color: Colors.white),
              ),
            )
        ],
      ),
      body: _pickedImages.isEmpty
          ? Center(
              child: ElevatedButton.icon(
                onPressed: _selectImages,
                icon: const Icon(Icons.add_a_photo),
                label: const Text('اختر صور من المعرض'),
              ),
            )
          : PageView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _pickedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.4,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Image.file(
                    File(_pickedImages[index].path),
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
    );
  }
}
