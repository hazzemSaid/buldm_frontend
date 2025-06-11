import 'package:buldm/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Buldm", style: AppTextStyles.headlineLarge(context)),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(FontAwesomeIcons.heart,
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(FontAwesomeIcons.telegram,
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    prefixIcon: Icon(FontAwesomeIcons.search),
                    hintText: "Search",
                    hintStyle: AppTextStyles.titleMedium(context),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const PostWidget(),
                childCount: 10,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PostWidget extends StatelessWidget {
  const PostWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// User Info
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage("assets/images/profile.jpg"),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hazem",
                          style: AppTextStyles.displaySmall(context,
                              color: Colors.red),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.grade_outlined,
                                  color: Colors.green, size: 16),
                              SizedBox(width: 4),
                              Text("Level 1",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.green)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(FontAwesomeIcons.ellipsisVertical,
                        color: colorScheme.onPrimary),
                  )
                ],
              ),
              const SizedBox(height: 12),

              /// Description
              const Text(
                "This is a sample description for the post. It can contain text, hashtags, or mentions.",
                softWrap: true,
              ),
              const SizedBox(height: 12),

              /// Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/darkbuldm.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),

              /// Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    tooltip: "Send",
                    onPressed: () {},
                    icon: const Icon(FontAwesomeIcons.locationArrow),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: "Upvote",
                          onPressed: () {},
                          icon: const Icon(FontAwesomeIcons.arrowUp),
                        ),
                        const Text("23",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          tooltip: "Downvote",
                          onPressed: () {},
                          icon: const Icon(FontAwesomeIcons.arrowDown),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: "Comment",
                    onPressed: () {},
                    icon: const Icon(FontAwesomeIcons.comment),
                  ),
                  IconButton(
                    tooltip: "Share",
                    onPressed: () {},
                    icon: const Icon(FontAwesomeIcons.share),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
