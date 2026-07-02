import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/media/kikikaikai_media_handler.dart';
import 'package:kikikaikai/core/media/playback_speed.dart';
import 'package:kikikaikai/features/content/widgets/player_bottom_sheet.dart';

const _speedAccent = Color(0xFF00E676);

Future<void> showPlaybackSpeedSheet(
  BuildContext context,
  KikikaikaiMediaHandler handler,
) {
  return showPlayerBottomSheet<void>(
    context,
    title: 'スピード',
    child: _PlaybackSpeedSheetBody(handler: handler),
  );
}

class _PlaybackSpeedSheetBody extends StatefulWidget {
  const _PlaybackSpeedSheetBody({required this.handler});

  final KikikaikaiMediaHandler handler;

  @override
  State<_PlaybackSpeedSheetBody> createState() =>
      _PlaybackSpeedSheetBodyState();
}

class _PlaybackSpeedSheetBodyState extends State<_PlaybackSpeedSheetBody> {
  static const _tickSpacing = 10.0;

  late final ScrollController _scrollController;
  late double _speed;
  bool _syncingScroll = false;

  @override
  void initState() {
    super.initState();
    _speed = PlaybackSpeed.snap(widget.handler.playbackSpeedNotifier.value);
    _scrollController = ScrollController(
      initialScrollOffset: _offsetForSpeed(_speed),
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  int get _tickCount =>
      ((PlaybackSpeed.max - PlaybackSpeed.min) / PlaybackSpeed.step).round();

  double _offsetForSpeed(double speed) {
    final index =
        ((PlaybackSpeed.snap(speed) - PlaybackSpeed.min) / PlaybackSpeed.step)
            .round();
    return index * _tickSpacing;
  }

  double _speedForOffset(double offset) {
    final index = (offset / _tickSpacing).round().clamp(0, _tickCount);
    return PlaybackSpeed.snap(PlaybackSpeed.min + index * PlaybackSpeed.step);
  }

  void _onScroll() {
    if (_syncingScroll) return;
    final next = _speedForOffset(_scrollController.offset);
    if (next != _speed) {
      setState(() => _speed = next);
    }
  }

  Future<void> _commitSpeed(double speed) async {
    final snapped = PlaybackSpeed.snap(speed);
    setState(() => _speed = snapped);
    await widget.handler.setPlaybackSpeed(snapped);
    _syncingScroll = true;
    await _scrollController.animateTo(
      _offsetForSpeed(snapped),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
    _syncingScroll = false;
  }

  Future<void> _snapScroll() async {
    final snapped = _speedForOffset(_scrollController.offset);
    await _commitSpeed(snapped);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final sidePadding = screenWidth / 2;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            PlaybackSpeed.formatSheetValue(_speed),
            style: AppTypography.heading(
              size: 42,
              color: _speedAccent,
            ),
          ),
          CustomPaint(
            size: const Size(14, 8),
            painter: _TrianglePointerPainter(color: _speedAccent),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: screenWidth / 2 - 1,
                  top: 0,
                  bottom: 28,
                  child: Container(
                    width: 2,
                    color: _speedAccent,
                  ),
                ),
                NotificationListener<ScrollEndNotification>(
                  onNotification: (_) {
                    _snapScroll();
                    return false;
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: sidePadding),
                    child: SizedBox(
                      width: _tickCount * _tickSpacing,
                      height: 72,
                      child: CustomPaint(
                        painter: _SpeedRulerPainter(
                          tickCount: _tickCount,
                          tickSpacing: _tickSpacing,
                          selectedIndex:
                              ((_speed - PlaybackSpeed.min) / PlaybackSpeed.step)
                                  .round(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _RulerLabel('0.5'),
                _RulerLabel('1.0'),
                _RulerLabel('1.5'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final preset in PlaybackSpeed.presets)
                  _SpeedPresetChip(
                    label: _presetLabel(preset),
                    selected: (_speed - preset).abs() < 0.001,
                    onTap: () => _commitSpeed(preset),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _presetLabel(double preset) {
    if (preset == preset.roundToDouble()) {
      return preset.toInt().toString();
    }
    return preset.toString();
  }
}

class _RulerLabel extends StatelessWidget {
  const _RulerLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.body(
        size: 14,
        color: AppColors.muted,
        weight: FontWeight.w400,
      ),
    );
  }
}

class _SpeedPresetChip extends StatelessWidget {
  const _SpeedPresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.onBase : AppColors.surfaceElevated,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Center(
            child: Text(
              label,
              style: AppTypography.body(
                size: 15,
                color: selected ? AppColors.base : AppColors.onBase,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeedRulerPainter extends CustomPainter {
  _SpeedRulerPainter({
    required this.tickCount,
    required this.tickSpacing,
    required this.selectedIndex,
  });

  final int tickCount;
  final double tickSpacing;
  final int selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final majorPaint = Paint()
      ..color = AppColors.onBase.withValues(alpha: 0.85)
      ..strokeWidth = 1.5;
    final minorPaint = Paint()
      ..color = AppColors.onBase.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    final selectedPaint = Paint()
      ..color = _speedAccent
      ..strokeWidth = 2;

    for (var i = 0; i <= tickCount; i++) {
      final x = i * tickSpacing;
      final isMajor = i % 10 == 0;
      final isMid = i % 5 == 0;
      final isSelected = i == selectedIndex;
      final height = isSelected
          ? 34.0
          : isMajor
              ? 28.0
              : isMid
                  ? 20.0
                  : 12.0;
      final paint = isSelected
          ? selectedPaint
          : isMajor
              ? majorPaint
              : minorPaint;
      canvas.drawLine(
        Offset(x, size.height - height),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpeedRulerPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.tickCount != tickCount;
  }
}

class _TrianglePointerPainter extends CustomPainter {
  _TrianglePointerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TrianglePointerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
