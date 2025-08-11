import 'package:flutter/material.dart';
// import 'package:quizsnap/core/widgets/index.dart';
import 'package:quizsnap/core/routes/routes.dart';

/// Onboarding screen redesigned to match the provided dark walkthrough.
/// - Top: large illustration area (placeholder containers, clearly labeled)
/// - Middle: big, high-contrast copy
/// - Bottom: page indicators and two CTA buttons
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _current = 0;

  late final List<_SlideModel> _slides = const [
    _SlideModel(
      imagePath: 'assets/image/onboarding/ob1.png',
      copy: 'Create, share and play quizzes whenever and wherever you want',
    ),
    _SlideModel(
      imagePath: 'assets/image/onboarding/ob2.png',
      copy: 'Find fun and interesting quizzes to boost up your knowledge',
    ),
    _SlideModel(
      imagePath: 'assets/image/onboarding/ob3.png',
      copy: 'Play and take quiz challenges together with your friends.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => Navigator.of(context)
                
                    .pushReplacementNamed(AppRoutes.login),
                child: const Text('Skip'),
              ),
            ),

            // Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _current = i),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 200),
                        // Illustration area
                        SizedBox(
                          height: 260,
                          width: double.infinity,
                          child: Image.asset(
                            slide.imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Copy
                        Text(
                          slide.copy,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        // Dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _slides.length,
                            (i) => AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 250),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              height: 6,
                              width: _current == i ? 22 : 6,
                              decoration: BoxDecoration(
                                color: _current == i
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),

            // CTAs
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(color: theme.dividerColor, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.signup),
                    child: const Text('GET STARTED'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor:
                          theme.colorScheme.onSurface.withValues(alpha: 0.12),
                      foregroundColor: theme.colorScheme.onSurface,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.login),
                    child: const Text('I ALREADY HAVE AN ACCOUNT'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _SlideModel {
  final String imagePath;
  final String copy;
  const _SlideModel({required this.imagePath, required this.copy});
}

