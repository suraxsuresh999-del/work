import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../app/router/route_names.dart';
import '../../../core/constants/app_constants.dart';
import '../../common/widgets/ws_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Find Top Talent',
      'description': 'Connect with verified freelancers across Tamil Nadu for your projects',
      'icon': 'search',
    },
    {
      'title': 'Secure & Verified',
      'description': 'Government ID verification ensures trust and safety for every user',
      'icon': 'verified_user',
    },
    {
      'title': 'Grow Your Career',
      'description': 'Build your portfolio, earn reviews, and grow your freelance business',
      'icon': 'trending_up',
    },
  ];

  Future<void> _completeOnboarding() async {
    final box = await Hive.openBox(AppConstants.settingsBox);
    await box.put(AppConstants.onboardingKey, true);
    if (mounted) {
      context.go(RouteNames.login);
    }
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'search': return Icons.search;
      case 'verified_user': return Icons.verified_user;
      case 'trending_up': return Icons.trending_up;
      default: return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getIconData(page['icon']!),
                          size: 120,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 48),
                        Text(
                          page['title']!,
                          style: Theme.of(context).textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['description']!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: Theme.of(context).colorScheme.primary,
                      dotColor: Theme.of(context).colorScheme.primary.withAlpha(51),
                    ),
                  ),
                  const SizedBox(height: 32),
                  WsButton(
                    text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
