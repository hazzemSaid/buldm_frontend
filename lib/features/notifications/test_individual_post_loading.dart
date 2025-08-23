// features/notifications/test_individual_post_loading.dart
import 'package:buldm/features/notifications/integration/notification_integration.dart';
import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';

class IndividualPostLoadingTest {
  // Test individual post loading with notifications
  static Future<void> testIndividualPostLoading() async {
    print('🧪 Testing Individual Post Loading...');

    try {
      // Get current user
      final authCubit = sl<AuthCubit>();
      final authState = authCubit.state;

      if (authState is Authenticated) {
        final currentUser = authState.user;
        print('👤 Current user: ${currentUser.name} (${currentUser.user_id})');

        // Create test notifications with specific post IDs
        final testPostId =
            'test_post_individual_${DateTime.now().millisecondsSinceEpoch}';

        await NotificationIntegration.createLikeNotification(
          postId: testPostId,
          postOwnerId: currentUser.user_id,
          userName: currentUser.name,
        );

        await NotificationIntegration.createCommentNotification(
          postId: testPostId,
          postOwnerId: currentUser.user_id,
          userName: currentUser.name,
          commentText: 'This is a test comment for individual post loading!',
        );

        print('✅ Individual post loading test completed!');
        print('📱 Check your notification screen to see:');
        print('   - Post ID: $testPostId');
        print(
            '   - Individual post loading via API: {{BASE_URL}}/api/v1/post/$testPostId');
        print('   - User names and avatars from UserBloc');
        print('   - Post previews with images and content');
      } else {
        print('❌ User not authenticated');
      }
    } catch (e) {
      print('❌ Individual post loading test failed: $e');
    }
  }

  // Test with multiple different post IDs
  static Future<void> testMultiplePostIds() async {
    print('🧪 Testing Multiple Post IDs...');

    try {
      final authCubit = sl<AuthCubit>();
      final authState = authCubit.state;

      if (authState is Authenticated) {
        final currentUser = authState.user;

        // Create notifications for different post IDs
        final postIds = [
          'post_1_${DateTime.now().millisecondsSinceEpoch}',
          'post_2_${DateTime.now().millisecondsSinceEpoch}',
          'post_3_${DateTime.now().millisecondsSinceEpoch}',
        ];

        for (final postId in postIds) {
          await NotificationIntegration.createLikeNotification(
            postId: postId,
            postOwnerId: currentUser.user_id,
            userName: currentUser.name,
          );
        }

        print('✅ Multiple post IDs test completed!');
        print('📱 Created notifications for ${postIds.length} different posts');
        print('🔗 Each post will be loaded individually via:');
        for (final postId in postIds) {
          print('   - {{BASE_URL}}/api/v1/post/$postId');
        }
      } else {
        print('❌ User not authenticated');
      }
    } catch (e) {
      print('❌ Multiple post IDs test failed: $e');
    }
  }

  // Debug the individual post loading process
  static void debugIndividualPostLoading() {
    print('🔍 Individual Post Loading Process:');
    print('   1. Notification screen loads notifications from Firebase');
    print('   2. Extracts unique post IDs from notifications');
    print(
        '   3. For each post ID, calls PostBloc.add(LoadIndividualPostEvent(postId))');
    print('   4. PostBloc calls GetIndividualPostUseCase(postId)');
    print('   5. Use case calls postrepository.getPostById(postId)');
    print('   6. Repository calls remotePostDataSource.getPostById(postId)');
    print(
        '   7. Data source makes API call to {{BASE_URL}}/api/v1/post/:postid');
    print('   8. Post data is returned and merged into PostBloc state');
    print('   9. NotificationTile displays post preview with loaded data');
  }
}
