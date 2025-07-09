import 'dart:io';

import 'package:buldm/features/Add_Post/data/model/UploadablePostModel.dart';
import 'package:buldm/features/Add_Post/presentation/bloc/imagespicker_cubit/imagespicker_cubit.dart';
import 'package:buldm/features/Add_Post/presentation/bloc/location_cubit/location_cubit.dart';
import 'package:buldm/features/Add_Post/presentation/view/widgets/buildCategorySelector.dart';
import 'package:buldm/features/Add_Post/presentation/view/widgets/buildCustomTextField.dart';
import 'package:buldm/features/Add_Post/presentation/view/widgets/buildDateSelector.dart';
import 'package:buldm/features/Add_Post/presentation/view/widgets/buildImagesSection.dart';
import 'package:buldm/features/Add_Post/presentation/view/widgets/buildLocationSelector.dart';
import 'package:buldm/features/Add_Post/presentation/view/widgets/buildSectionCard.dart';
import 'package:buldm/features/Add_Post/presentation/view/widgets/buildStatusSelector.dart';
import 'package:buldm/features/home/data/models/location_model.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class AddPostDetails extends StatefulWidget {
  const AddPostDetails({super.key});

  @override
  State<AddPostDetails> createState() => _AddPostDetailsState();
}

class _AddPostDetailsState extends State<AddPostDetails>
    with TickerProviderStateMixin {
  List<XFile> images = [];
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final ValueNotifier<String> _statusNotifier = ValueNotifier<String>('found');
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Documents',
    'Jewelry',
    'Keys',
    'Bags',
    'Books',
    'Other'
  ];

  final List<IconData> _categoryIcons = [
    Icons.phone_android,
    Icons.checkroom,
    Icons.description,
    Icons.diamond,
    Icons.vpn_key,
    Icons.work,
    Icons.book,
    Icons.category
  ];

  @override
  void initState() {
    super.initState();
    if (context.read<ImagespickerCubit>().state is ImagespickerLoaded) {
      images = (context.read<ImagespickerCubit>().state as ImagespickerLoaded)
          .images;
    } else {
      images = [];
    }
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submit() async {
    //handel this later with bloc
    //here we have a problem with _pickedLocation being null

    if (!_formKey.currentState!.validate()) {
      _scrollToFirstError();
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showErrorSnackBar("Description cannot be empty");
      return;
    }

    final locationpiker = context.read<LocationCubit>();
    final currentState = locationpiker.state;
    LatLng? _pickedLocation = null;
    if (currentState is LocationSelected) {
      _pickedLocation = currentState.location;
    }
    if (_pickedLocation == null) {
      _showErrorSnackBar("Please select a location");
      return;
    }
    context.read<PostBloc>().add(UpdatePostEvent(
            post: UploadablePostModel(
          title: "asdasd",
          description: _descriptionController.text.trim(),
          category: _categoryController.text.trim(),
          contactInfo: _contactInfoController.text.trim(),
          status: _statusNotifier.value,
          when: DateTime.now(),
          images: images,
          location: LocationModel(
              type: "Point",
              coordinates: [
                _pickedLocation?.latitude ?? LatLng(0, 0).latitude,
                _pickedLocation?.longitude ?? LatLng(0, 0).longitude
              ],
              placeName: "Selected Location"),
          predictedItems: [],
          user_id: "6862ee1eb389f2554cecea98",
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )));
    // go back to home page
    _showSuccessSnackBar("Post submitted successfully!");
    context.read<ImagespickerCubit>().clearImages();
    Navigator.pop(context);
  }

  void _scrollToFirstError() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Item Details',
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          BlocConsumer<PostBloc, PostState>(
            listener: (context, state) {
              if (state is PostError) {
                _showErrorSnackBar(state.message);
              } else if (state is postCreatedState) {
                _showSuccessSnackBar('Post created successfully!');
                Navigator.pop(context);
              }
            },
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: state is PostLoading
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      )
                    : TextButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.publish, color: Colors.white),
                        label: const Text(
                          'Publish',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Images Preview Section
                  BuildImagesSection(
                    images: images.map((img) => File(img.path)).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Basic Information Section
                  BuildSectionCard(
                    title: 'Basic Information',
                    icon: Icons.info_outline,
                    children: [
                      BuildCustomTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Describe the item in detail...',
                        icon: FontAwesomeIcons.fileAlt,
                        maxLines: 3,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Category Section
                  BuildSectionCard(
                    title: 'Category',
                    icon: Icons.category,
                    children: [
                      BuildCategorySelector(
                        categories: _categories,
                        categoryIcons: _categoryIcons,
                        categoryController: _categoryController,
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Status Section
                  BuildSectionCard(
                    title: 'Status',
                    icon: Icons.flag,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: _statusNotifier,
                        builder: (context, status, child) {
                          return BuildStatusSelector(
                            status: status,
                            onStatusChanged: () {
                              final newStatus =
                                  status == 'found' ? 'lost' : 'found';
                              _statusNotifier.value = newStatus;
                            },
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Location & Date Section
                  BuildSectionCard(
                    title: 'Location & Date',
                    icon: Icons.place,
                    children: [
                      // Location Selector screen
                      BuildLocationSelector(),
                      const SizedBox(height: 16),
                      BuildDateSelector(),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Contact Information Section
                  BuildSectionCard(
                    title: 'Contact Information',
                    icon: Icons.contact_phone,
                    children: [
                      BuildCustomTextField(
                        controller: _contactInfoController,
                        label: 'Contact Info',
                        hint: 'Phone, email, or other contact details',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),

                  const SizedBox(height: 100), // Bottom spacing
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
