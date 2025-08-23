import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:buldm/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:buldm/features/notifications/presentation/bloc/notification_state.dart';
import 'package:buldm/features/notifications/presentation/view/screens/notification_screen.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';

class NotificationBadge extends StatelessWidget {
  final String userId;
  final VoidCallback? onTap;

  const NotificationBadge({
    super.key,
    required this.userId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoaded) {
          return StreamBuilder<int>(
            stream: state.unreadCountStream,
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      FontAwesomeIcons.bell,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: onTap ?? () {
                      final postBloc = context.read<PostBloc>();
                      final userBloc = context.read<UserBloc>();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MultiBlocProvider(
                            providers: [
                              BlocProvider<PostBloc>.value(value: postBloc),
                              BlocProvider<UserBloc>.value(value: userBloc),
                            ],
                            child: const NotificationScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        }
        
        // Fallback when bloc is not loaded
        return IconButton(
          icon: Icon(
            FontAwesomeIcons.bell,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: onTap ?? () {
            final postBloc = context.read<PostBloc>();
            final userBloc = context.read<UserBloc>();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider<PostBloc>.value(value: postBloc),
                    BlocProvider<UserBloc>.value(value: userBloc),
                  ],
                  child: const NotificationScreen(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
