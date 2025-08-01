import 'dart:async';

import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';
import 'package:buldm/features/profile/presentation/blocs/profile/profile_cubit.dart';
import 'package:buldm/features/profile/presentation/view/screens/OtherUserProfileScreen.dart';
import 'package:buldm/features/profile/presentation/view/screens/profile_screen.dart';
import 'package:buldm/features/search/presentation/bloc/ssearch/Search_Cubit.dart';
import 'package:buldm/l10n/app_localizations.dart';
import 'package:buldm/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  static Timer? _debounce;
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
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
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                onChanged: (value) {
                  if (value.isEmpty) {
                    context.read<SearchCubit>().clearSearch();
                    return;
                  }
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    context.read<SearchCubit>().searchUsers(value);
                  });
                },
                decoration: InputDecoration(
                  hintText: localization.searchUsers,
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) {
              if (state is SearchLoading) {
                return SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is SearchLoaded) {
                final items = state.users;
                if (items.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(child: Text(localization.noUsersFound)),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= items.length) return null;
                      return GestureDetector(
                        onTap: () {
                          if (context.read<AuthCubit>().state
                                  is Authenticated &&
                              (context.read<AuthCubit>().state as Authenticated)
                                      .user
                                      .user_id ==
                                  items[index].id) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                      value: sl<ProfileCubit>(),
                                      child: ProfileScreen()),
                                ));
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BlocProvider.value(
                                          value: sl<ProfileCubit>(),
                                          child: OtherUserProfileScreen(
                                            user: ViewerUser(
                                                avatar: items[index].avatar,
                                                id: items[index].id,
                                                name: items[index].name,
                                                email: items[index].email),
                                          ),
                                        )));
                          }
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(items[index].avatar),
                          ),
                          title: Text(items[index].name),
                        ),
                      );
                    },
                    childCount: items.length,
                  ),
                );
              } else if (state is SearchError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text('Error: ${state.message}')),
                );
              }
              return SliverFillRemaining(
                child: Center(child: Text('type to search...')),
              );
            },
          ),
        ],
      ),
    );
  }
}
