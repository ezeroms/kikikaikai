abstract final class PlaybackSpeed {
  static const min = 0.5;
  static const max = 3.0;
  static const step = 0.05;

  static const presets = [1.0, 1.25, 1.5, 1.75, 2.0, 3.0];

  static double clamp(double speed) =>
      speed.clamp(min, max).toDouble();

  static double snap(double speed) {
    final steps = ((clamp(speed) - min) / step).round();
    return clamp(min + steps * step);
  }

  static String formatLabel(double speed) {
    final snapped = snap(speed);
    if (snapped == snapped.roundToDouble()) {
      return '${snapped.toInt()}x';
    }
    final text = snapped.toStringAsFixed(2);
    return '${text.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')}x';
  }

  static String formatSheetValue(double speed) {
    return '${snap(speed).toStringAsFixed(1)}x';
  }
}
