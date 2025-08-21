import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/home/persentation/view/screens/PostWidget.dart';
import 'package:buldm/features/profile/presentation/blocs/profile/profile_cubit.dart';
import 'package:buldm/l10n/app_localizations.dart';
import 'package:buldm/routes/routes.dart';
import 'package:buldm/utils/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final ViewerUser user;
  const OtherUserProfileScreen({super.key, required this.user});

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  @override
  bool status = false;
  bool listview = false;

  @override
  void initState() {
    super.initState();
    _fetchUserPosts(
      status: status,
      userid: widget.user.id,
    );
  }

  void _fetchUserPosts({
    status = false,
    required String userid,
  }) async {
    if (!mounted) return;

    if (userid.isNotEmpty) {
      await context.read<ProfileCubit>().fetchPost(
            userId: userid,
          );
      context.read<ProfileCubit>().filterpost(status: status);
    } else if (mounted) {
      final localization = AppLocalizations.of(context);
      if (localization != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localization.userNotLoggedIn)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Scaffold(
        body: MultiBlocProvider(
            providers: [
          BlocProvider<UserBloc>(create: (_) => sl<UserBloc>()),
          BlocProvider<PostBloc>(create: (_) => sl<PostBloc>()),
        ],
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  elevation: 0,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Buldm",
                        style: AppTextStyles.headlineLarge(context).copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          listview
                              ? Icons.grid_view_rounded
                              : Icons.list_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () {
                          setState(() {
                            listview = !listview;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () {
                          setState(() {
                            status = !status;
                          });
                          _fetchUserPosts(
                              status: status, userid: widget.user.id);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          FontAwesomeIcons.facebookMessenger,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () {
                          // Navigate to chat details using GoRouter
                          final currentUse =
                              (context.read<AuthCubit>().state as Authenticated)
                                  .user;
                          context.push(
                            paths[AppRoute.chat.name]!,
                            extra: {
                              'user': widget.user,
                              'currentUserId': currentUse.user_id,
                              'otherUserId': widget.user.id,
                              'currentViewerUser': ViewerUser(
                                id: currentUse.user_id,
                                name: currentUse.name,
                                email: currentUse.email,
                                avatar: currentUse.avatar,
                              ),
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // معلومات المستخدم
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // صورة الـ cover + avatar
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/pngwing.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        height: 160,
                        width: double.infinity,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.3),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -25,
                              left: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 45,
                                  backgroundColor: Colors.transparent,
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: widget.user.avatar,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                      errorWidget:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          widget.user.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // زرار الفلترة
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  context
                                      .read<ProfileCubit>()
                                      .filterpost(status: false);
                                  setState(() {
                                    status = false;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      localization.itemsFound,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: status == false
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : (Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.color ??
                                                        Colors.grey)
                                                    .withOpacity(0.7),
                                          ),
                                    ),
                                    const SizedBox(width: 10),
                                    ImageIcon(
                                      const AssetImage(
                                          "assets/images/find.png"),
                                      color: status == false
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.5),
                                      size: 35,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 30,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.3),
                              ),
                              GestureDetector(
                                onTap: () {
                                  context
                                      .read<ProfileCubit>()
                                      .filterpost(status: true);
                                  setState(() {
                                    status = true;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      localization.itemsLost,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: status == true
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : (Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.color ??
                                                        Colors.grey)
                                                    .withOpacity(0.7),
                                          ),
                                    ),
                                    const SizedBox(width: 10),
                                    ImageIcon(
                                      const AssetImage(
                                          "assets/images/lost.png"),
                                      color: status == true
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.5),
                                      size: 45,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                // بوستات المستخدم
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    if (state is ProfileInitial) {
                      return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (state is ProfileError) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            state.message,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.red),
                          ),
                        ),
                      );
                    }

                    if (state is fetchpost) {
                      if (state.posts.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  localization.noPostsAvailable,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(color: Colors.grey),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () => _fetchUserPosts(
                                      status: status, userid: widget.user.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      if (listview) {
                        // List view: render full PostWidget items
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 6.0),
                                child: PostWidget(
                                  post: state.posts[index],
                                  index: state.posts[index].id,
                                ),
                              );
                            },
                            childCount: state.posts.length,
                          ),
                        );
                      } else {
                        // Grid view: show thumbnails
                        return SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: state.posts[index].images[0],
                                    fit: BoxFit.cover,
                                    errorWidget: (context, error, stackTrace) =>
                                        Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                          child: Icon(Icons.error,
                                              color: Colors.red)),
                                    ),
                                    placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator()),
                                  ),
                                ),
                              );
                            },
                            childCount: state.posts.length,
                          ),
                        );
                      }
                    }

                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ],
            )));
  }
}

class ViewerUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final String avatar;
  const ViewerUser({
    required this.avatar,
    required this.id,
    required this.name,
    required this.email,
  });
  ViewerUser copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
  }) {
    return ViewerUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
    };
  }

  factory ViewerUser.fromJson(Map<String, dynamic> json) {
    return ViewerUser(
      id: json['user_id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
    );
  }

  @override
  List<Object?> get props => [id, name, email, avatar];
  @override
  String toString() {
    return 'ViewerUser(id: $id, name: $name, email: $email, avatar: $avatar)';
  }
}
