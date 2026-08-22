import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Shared, lightweight Lottie hero for authentication and onboarding steps.
/// It keeps the first-use experience expressive without adding motion to
/// content-heavy marketplace screens.
class WsAuthAnimation extends StatelessWidget {
  final double size;

  const WsAuthAnimation({
    super.key,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'WorkSphere secure collaboration illustration',
      child: SizedBox(
        width: size,
        height: size,
        child: Lottie.asset(
          'assets/animations/authentication.json',
          repeat: true,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
