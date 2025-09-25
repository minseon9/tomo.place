import 'dart:math' as _math;

class HeadingNormalizer {
  static double normalize(double heading) {
    final h = heading % 360;
    return h < 0 ? h + 360 : h;
  }

  static double shortestDelta(double from, double to) {
    double diff = (to - from) % 360;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return diff;
  }

  static bool hasSignificantChange({
    required double previous,
    required double current,
    double thresholdDegrees = 5.0,
  }) {
    final prev = normalize(previous);
    final curr = normalize(current);
    final delta = shortestDelta(prev, curr).abs();
    return delta >= thresholdDegrees;
  }
}
