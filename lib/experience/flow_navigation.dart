import 'package:flutter/material.dart';
import 'experience_controller.dart';

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

// The first-run screens are added in the next two parts.
void continueExperience(BuildContext context) =>
    replaceExperience(context, ExperienceScope.of(context).homeBuilder());
