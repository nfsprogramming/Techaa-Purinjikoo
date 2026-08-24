import 'package:flutter/material.dart';

class MotionDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration navigation = Duration(milliseconds: 340);
  static const Duration floatingXp = Duration(milliseconds: 850);
  static const Duration celebration = Duration(milliseconds: 1200);
  static const Duration modal = Duration(milliseconds: 280);
}

class MotionCurves {
  static const Curve fast = Curves.easeOutQuad;
  static const Curve normal = Curves.easeOutCubic;
  static const Curve liquid = Curves.easeOutCubic;
  static const Curve bounce = Curves.easeOutBack;
  static const Curve gentle = Curves.easeInOutCubic;
}

class AppMotion {
  static bool isReducedMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  static Duration duration(BuildContext context, Duration standardDuration) {
    return isReducedMotion(context) ? Duration.zero : standardDuration;
  }
}
