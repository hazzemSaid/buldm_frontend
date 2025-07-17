import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';
import 'package:buldm/features/profile/presentation/blocs/profile/profile_cubit.dart';
import 'package:buldm/features/profile/presentation/view/widgets/ProfileOption.dart';
import 'package:buldm/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  bool status = false;
  void initState() {
    super.initState();
    _fetchUserPosts(
      status: status,
    );
  }

  void _fetchUserPosts({
    status = false,
  }) async {
    // Fetch posts when the screen is initialized
    final UserModel? user =
        await context.read<AuthCubit>().getCurrentuserUsercase();
    if (!mounted) return;

    if (user != null && user.token.isNotEmpty && user.user_id.isNotEmpty) {
      await context.read<ProfileCubit>().fetchPost(
            token: user.token,
            userId: user.user_id,
          );
      context.read<ProfileCubit>().filterpost(status: status);
    } else {
      // Handle case where user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        shadowColor: Theme.of(context).colorScheme.shadow,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        child: ListView(
          children: [
            ProfileOption(icon: Icons.settings, title: 'Settings'),
            ProfileOption(icon: Icons.help, title: 'Help'),
            ProfileOption(
                icon: Icons.logout,
                title: 'Logout',
                onTap: () {
                  context.read<AuthCubit>().signOut();

                  //
                }),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Theme.of(context).colorScheme.background,
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
                Spacer(),
                IconButton(
                  icon: Icon(Icons.refresh,
                      color: Theme.of(context).colorScheme.primary),
                  onPressed: () {
                    setState(() {
                      status = !status;
                      _fetchUserPosts(status: status);
                    });
                  },
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // معلومات المستخدم
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return SliverList(
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
                                    child: Image.network(
                                      state.user.avatar,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
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
                          state.user.name,
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
                                  status = false;
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      'items Find',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    const SizedBox(width: 10),
                                    ImageIcon(
                                      const AssetImage(
                                          "assets/images/find.png"),
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
                                  status = true;
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      'items Lost',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    const SizedBox(width: 10),
                                    ImageIcon(
                                      const AssetImage(
                                          "assets/images/lost.png"),
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
                );
              } else {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
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
                            'No posts available',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.grey),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () => _fetchUserPosts(status: status),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                          child: Image.network(
                            state.posts[index].images[0],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: Colors.grey[300],
                              child: const Center(
                                  child: Icon(Icons.error, color: Colors.red)),
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    childCount: state.posts.length,
                  ),
                );
              }

              return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ],
      ),
    );
  }
}
