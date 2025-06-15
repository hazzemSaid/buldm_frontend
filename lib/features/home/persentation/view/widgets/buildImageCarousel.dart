import 'package:flutter/material.dart';

class buildImageCarousel extends StatelessWidget {
  const buildImageCarousel(
      {super.key,
      required this.pageController,
      required this.currentPageNotifier,
      required this.imagePaths});
  final pageController;
  final imagePaths;
  final currentPageNotifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 4 / 5,
          child: Stack(
            children: [
              PageView.builder(
                controller: pageController,
                itemCount: imagePaths.length,
                onPageChanged: (index) => currentPageNotifier.value = index,
                itemBuilder: (context, index) {
                  return Image.asset(
                    imagePaths[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              ),
              Positioned(
                top: 10,
                right: 12,
                child: ValueListenableBuilder<int>(
                  valueListenable: currentPageNotifier,
                  builder: (context, currentIndex, _) {
                    return Row(
                      children: List.generate(imagePaths.length, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: currentIndex == index ? 8 : 6,
                          height: currentIndex == index ? 8 : 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
