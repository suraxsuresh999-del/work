import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../core/enums/enums.dart';

Future<void> navigateToNextAuthStep(BuildContext context, UserEntity? user) async {
  if (user == null) {
    context.go(RouteNames.login);
    return;
  }

  if (user.email.isNotEmpty && !user.isEmailVerified) {
    context.go(RouteNames.emailVerification, extra: user.email);
    return;
  }

  if (user.type == UserType.rolePending || user.onboardingStatus == OnboardingStatus.rolePending) {
    context.go(RouteNames.userTypeSelection);
    return;
  }

  switch (user.onboardingStatus) {
    case OnboardingStatus.rolePending:
      context.go(RouteNames.userTypeSelection);
      return;
    case OnboardingStatus.profilePending:
      context.go(
        user.type == UserType.client
            ? RouteNames.clientProfileSetup
            : RouteNames.freelancerProfileSetup,
      );
      return;
    case OnboardingStatus.active:
      context.go(
        user.type == UserType.admin
            ? RouteNames.adminDashboard
            : RouteNames.home,
      );
      return;
  }
}
