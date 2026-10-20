import 'package:flutter/material.dart';
import 'experience_controller.dart';
import 'onboarding_screen.dart';

PageRouteBuilder<void> experienceRoute(BuildContext context, Widget screen) {
  final reduced = MediaQuery.disableAnimationsOf(context);
  return PageRouteBuilder<void>(
    transitionDuration: reduced
        ? Duration.zero
        : const Duration(milliseconds: 350),
    reverseTransitionDuration: reduced
        ? Duration.zero
        : const Duration(milliseconds: 250),
    pageBuilder: (_, __, ___) => screen,
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, .035), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    ),
  );
}

void replaceExperience(BuildContext context, Widget screen) =>
    Navigator.of(context).pushReplacement(experienceRoute(context, screen));

void continueExperience(BuildContext context) {
  final scope = ExperienceScope.of(context);
  if (!scope.controller.introDone) {
    replaceExperience(
      context,
      Builder(
        builder: (introContext) => OnboardingScreen(
          onDone: () async {
            await scope.controller.completeIntro();
            if (introContext.mounted) {
              replaceExperience(introContext, scope.homeBuilder());
            }
          },
        ),
      ),
    );
  } else {
    replaceExperience(context, scope.homeBuilder());
  }
}
