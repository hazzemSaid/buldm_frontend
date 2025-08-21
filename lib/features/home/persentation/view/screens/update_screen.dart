// import 'package:buldm/core/Dependency_njection/service_locator.dart';
// import 'package:buldm/features/Add_Post/data/model/UploadablePostModel.dart';
// import 'package:buldm/features/Add_Post/presentation/bloc/location_cubit/location_cubit.dart';
// import 'package:buldm/features/Add_Post/presentation/view/widgets/buildCategorySelector.dart';
// import 'package:buldm/features/Add_Post/presentation/view/widgets/buildCustomTextField.dart';
// import 'package:buldm/features/Add_Post/presentation/view/widgets/buildDateSelector.dart';
// import 'package:buldm/features/Add_Post/presentation/view/widgets/buildImagesSection.dart';
// import 'package:buldm/features/Add_Post/presentation/view/widgets/buildLocationSelector.dart';
// import 'package:buldm/features/Add_Post/presentation/view/widgets/buildSectionCard.dart';
// import 'package:buldm/features/Add_Post/presentation/view/widgets/buildStatusSelector.dart';
// import 'package:buldm/features/home/data/models/location_model.dart';
// import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
// import 'package:buldm/l10n/app_localizations.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:latlong2/latlong.dart';

// class UpdateScreen extends StatefulWidget {
//   final UploadablePostModel post;
//   final String postId;
//   const UpdateScreen({Key? key, required this.post, required this.postId})
//       : super(key: key);

//   @override
//   State<UpdateScreen> createState() => _UpdateScreenState();
// }

// class _UpdateScreenState extends State<UpdateScreen>
//     with TickerProviderStateMixin {
//   List<String> images = [];
//   final _formKey = GlobalKey<FormState>();
//   final _scrollController = ScrollController();
//   late ValueNotifier<String> _statusNotifier;
//   bool _statusInitialized = false;
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _categoryController = TextEditingController();
//   final TextEditingController _contactInfoController = TextEditingController();

//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   final List<String> _categoriesEng = [
//     'Electronics',
//     'Clothing',
//     'Documents',
//     'Jewelry',
//     'Keys',
//     'Bags',
//     'Books',
//     'Other'
//   ];
//   final List<String> _categoriesAr = [
//     'إلكترونيات',
//     'ملابس',
//     'مستندات',
//     'مجوهرات',
//     'مفاتيح',
//     'حقائب',
//     'كتب',
//     'أخرى'
//   ];
//   final List<String> _categories = [];
//   final List<IconData> _categoryIcons = [
//     Icons.phone_android,
//     Icons.checkroom,
//     Icons.description,
//     Icons.diamond,
//     Icons.vpn_key,
//     Icons.work,
//     Icons.book,
//     Icons.category
//   ];

//   @override
//   void initState() {
//     super.initState();

//     // Initialize form fields with post data
//     _descriptionController.text = widget.post.description;
//     _categoryController.text = widget.post.category;
//     _contactInfoController.text = widget.post.contactInfo;

//     // Initialize images if any
//     // Note: You'll need to convert the post's images to XFile format
//     // For now, we'll leave images empty

//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

//     _fadeController.forward();
//     _slideController.forward();
//   }

//   @override
//   void didChangeDependencies() {
//     final localizations = AppLocalizations.of(context)!;

//     if (!_statusInitialized) {
//       _statusNotifier = ValueNotifier<String>(widget.post.status == 'found'
//           ? localizations.found
//           : localizations.lost);
//       _statusInitialized = true;
//     }

//     if (localizations.localeName.startsWith('ar')) {
//       _categories.addAll(_categoriesAr);
//     } else {
//       _categories.addAll(_categoriesEng);
//     }
//     super.didChangeDependencies();
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _slideController.dispose();
//     _scrollController.dispose();
//     _statusNotifier.dispose();
//     _descriptionController.dispose();
//     _categoryController.dispose();
//     _contactInfoController.dispose();
//     super.dispose();
//   }

//   void _updatePost(BuildContext ctx) {
//     final localizations = AppLocalizations.of(context)!;

//     if (!_formKey.currentState!.validate()) {
//       _scrollToFirstError();
//       return;
//     }

//     if (_descriptionController.text.trim().isEmpty) {
//       _showErrorSnackBar(localizations.descriptionRequired);
//       return;
//     }

//     final locationPicker = BlocProvider.of<LocationCubit>(ctx);
//     final currentState = locationPicker.state;
//     LatLng? pickedLocation;

//     if (currentState is LocationSelected) {
//       pickedLocation = currentState.location;
//     } else if (widget.post.location != null) {
//       pickedLocation = LatLng(
//         widget.post.location!.coordinates[1],
//         widget.post.location!.coordinates[0],
//       );
//     }

//     if (pickedLocation == null) {
//       _showErrorSnackBar(localizations.selectLocation);
//       return;
//     }

//     final updatedPost = UploadablePostModel(
//       title: widget.post.title,
//       description: _descriptionController.text.trim(),
//       category: _categoryController.text.trim(),
//       contactInfo: _contactInfoController.text.trim(),
//       status: _statusNotifier.value == localizations.found ? "found" : "lost",
//       when: DateTime.now(),
//       images: images,
//       location: widget.post.location!.copyWith(
//         coordinates: [pickedLocation.longitude, pickedLocation.latitude],
//       ),
//       predictedItems: widget.post.predictedItems ?? [],
//       user_id: widget.post.user_id,
//       createdAt: widget.post.createdAt,
//       updatedAt: DateTime.now(),
//     );

//     context
//         .read<PostBloc>()
//         .add(UpdatePostEvent(post: updatedPost, postId: widget.postId));
//   }

//   void _scrollToFirstError() {
//     _scrollController.animateTo(
//       0,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.error_outline, color: Colors.white),
//             const SizedBox(width: 8),
//             Text(message),
//           ],
//         ),
//         backgroundColor: Colors.red.shade400,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }

//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.check_circle_outline, color: Colors.white),
//             const SizedBox(width: 8),
//             Text(message),
//           ],
//         ),
//         backgroundColor: Colors.green.shade400,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }

//   void _showLoadingSnackBar() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.error_outline, color: Colors.white),
//             const SizedBox(width: 8),
//             Text('Loading...'),
//           ],
//         ),
//         backgroundColor: Colors.red.shade400,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final localizations = AppLocalizations.of(context)!;

//     return BlocProvider(
//       create: (context) => sl<LocationCubit>(),
//       child: Scaffold(
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         appBar: AppBar(
//           elevation: 0,
//           backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
//           flexibleSpace: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title: Text(
//             "Update Post",
//             style: TextStyle(
//               color: theme.colorScheme.onPrimary,
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           actions: [
//             BlocConsumer<PostBloc, PostState>(
//               listener: (context, state) {
//                 if (state is PostUpdatedLoading) {
//                   _showLoadingSnackBar();
//                 } else if (state is PostUploadError) {
//                   _showErrorSnackBar(state.message);
//                 } else if (state is PostUpdatedSuccess) {
//                   _showSuccessSnackBar('Post updated successfully');
//                   Navigator.pop(context);
//                 }
//               },
//               builder: (context, state) {
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 16),
//                   child: state is PostLoading
//                       ? const Center(
//                           child: SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor:
//                                   AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           ),
//                         )
//                       : TextButton.icon(
//                           onPressed: () => _updatePost(context),
//                           icon: const Icon(Icons.update, color: Colors.white),
//                           label: const Text(
//                             "Update",
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600),
//                           ),
//                         ),
//                 );
//               },
//             ),
//           ],
//         ),
//         body: FadeTransition(
//           opacity: _fadeAnimation,
//           child: SlideTransition(
//             position: _slideAnimation,
//             child: Form(
//               key: _formKey,
//               child: SingleChildScrollView(
//                 controller: _scrollController,
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Images Preview Section
//                     BuildImagesSection(
//                       imageSources: images.isNotEmpty
//                           ? images // local file paths selected in this screen
//                           : (widget.post.images), // existing URLs from the post
//                     ),
//                     const SizedBox(height: 24),

//                     // Basic Information Section
//                     BuildSectionCard(
//                       title: localizations.basicInformation,
//                       icon: Icons.info_outline,
//                       children: [
//                         BuildCustomTextField(
//                           controller: _descriptionController,
//                           label: localizations.description,
//                           hint: localizations.descriptionHint,
//                           icon: FontAwesomeIcons.fileAlt,
//                           maxLines: 3,
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 20),

//                     // Category Section
//                     BuildSectionCard(
//                       title: localizations.category,
//                       icon: Icons.category,
//                       children: [
//                         BuildCategorySelector(
//                           images: [],
//                           categories: _categories,
//                           categoryIcons: _categoryIcons,
//                           categoryController: _categoryController,
//                         )
//                       ],
//                     ),

//                     const SizedBox(height: 20),

//                     // Status Section
//                     BuildSectionCard(
//                       title: localizations.status,
//                       icon: Icons.flag,
//                       children: [
//                         ValueListenableBuilder(
//                           valueListenable: _statusNotifier,
//                           builder: (context, status, child) {
//                             return BuildStatusSelector(
//                               status: status,
//                               onStatusChanged: () {
//                                 final newStatus = status == localizations.found
//                                     ? localizations.lost
//                                     : localizations.found;
//                                 _statusNotifier.value = newStatus;
//                               },
//                             );
//                           },
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 20),

//                     // Location & Date Section
//                     BuildSectionCard(
//                       title: localizations.locationAndDate,
//                       icon: Icons.place,
//                       children: [
//                         // Location Selector screen
//                         BuildLocationSelector(
//                           initialLocation: widget.post.location != null
//                               ? LocationModel(
//                                   coordinates: [
//                                     widget.post.location!.coordinates[1],
//                                     widget.post.location!.coordinates[0],
//                                   ],
//                                   type: '',
//                                   placeName: '',
//                                 )
//                               : null,
//                         ),
//                         const SizedBox(height: 16),
//                         BuildDateSelector(
//                           initialDate: widget.post.when,
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 20),

//                     // Contact Information Section
//                     BuildSectionCard(
//                       title: "Contact Information",
//                       icon: Icons.contact_phone,
//                       children: [
//                         BuildCustomTextField(
//                           controller: _contactInfoController,
//                           label: "Contact Information",
//                           hint: "Phone, Email or Other",
//                           icon: FontAwesomeIcons.phone,
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 24),

//                     // Action Button
//                     Center(
//                       child: Builder(
//                         builder: (innerCtx) => ElevatedButton.icon(
//                           onPressed: () => _updatePost(innerCtx),
//                           icon: const Icon(Icons.save),
//                           label: const Text("Save changes"),
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 24, vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
