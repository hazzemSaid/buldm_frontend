import 'dart:io';

import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/features/Add_Post/presentation/bloc/imagespicker_cubit/imagespicker_cubit.dart';
import 'package:buldm/features/Add_Post/presentation/bloc/location_cubit/location_cubit.dart';
import 'package:buldm/features/Add_Post/presentation/view/screens/AddPostDetails.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class PostUploadScreen extends StatelessWidget {
  const PostUploadScreen({super.key});

  Future<void> _selectImages(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? selectedImages = await picker.pickMultiImage();

    if (selectedImages != null && selectedImages.isNotEmpty) {
      context.read<ImagespickerCubit>().selectImages(selectedImages);
    }
  }

  void _goNext(BuildContext context, List<XFile> images) {
    // Get the PostBloc from the current context before navigation
    final postBloc = context.read<PostBloc>();
    final imagespicker = context.read<ImagespickerCubit>();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(
                      value: postBloc,
                    ),
                    BlocProvider<LocationCubit>(
                      create: (context) => sl<LocationCubit>(),
                    ),
                    BlocProvider<ImagespickerCubit>.value(
                      value: imagespicker,
                    ),
                  ],
                  child: AddPostDetails(),
                )));
  }

  void _clearImages(BuildContext context) {
    context.read<ImagespickerCubit>().clearImages();
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImagespickerCubit, ImagespickerState>(
      builder: (context, state) {
        if (state is ImagespickerLoaded) {
          final pickedImages = state.images;
          return Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Post Upload"),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _clearImages(context),
                  ),
                ],
              ),
              actions: [
                if (pickedImages.isNotEmpty)
                  TextButton(
                    onPressed: () => _goNext(context, pickedImages),
                    child: const Text(
                      "التالي",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
              ],
            ),
            body: PageView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: pickedImages.length,
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
                    File(pickedImages[index].path),
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Post Upload"),
            ),
            body: Center(
              child: ElevatedButton(
                onPressed: () => _selectImages(context),
                child: const Text("Select Images"),
              ),
            ),
          );
        }
      },
    );
  }
}
