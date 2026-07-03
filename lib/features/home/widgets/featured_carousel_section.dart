import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/features/home/widgets/featured_content_card.dart';

/// おすすめ — Vimeo風の横スクロール縦長カードカルーセル（無限ループ）
class FeaturedCarouselSection extends StatefulWidget {
  const FeaturedCarouselSection({super.key, required this.contents});

  final List<Content> contents;

  @override
  State<FeaturedCarouselSection> createState() => _FeaturedCarouselSectionState();
}

class _FeaturedCarouselSectionState extends State<FeaturedCarouselSection> {
  static const _virtualLoops = 1000;

  late final PageController _pageController;
  late int _currentIndex;

  int get _itemCount => widget.contents.length;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _pageController = PageController(
      viewportFraction: 0.88,
      initialPage: _itemCount > 1 ? _virtualLoops * _itemCount : 0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _contentIndex(int pageIndex) {
    final n = _itemCount;
    return ((pageIndex % n) + n) % n;
  }

  void _onPageChanged(int pageIndex) {
    final nextIndex = _contentIndex(pageIndex);
    if (nextIndex == _currentIndex) return;
    setState(() => _currentIndex = nextIndex);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.contents.isEmpty) return const SizedBox.shrink();

    if (_itemCount == 1) {
      return SizedBox(
        height: FeaturedContentCard.carouselHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: FeaturedContentCard(content: widget.contents.first),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: FeaturedContentCard.carouselHeight,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _virtualLoops * _itemCount * 2,
            itemBuilder: (context, index) {
              final content = widget.contents[_contentIndex(index)];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: FeaturedContentCard(content: content),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        _CarouselPageDots(
          count: _itemCount,
          currentIndex: _currentIndex,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _CarouselPageDots extends StatelessWidget {
  const _CarouselPageDots({
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  static const _inactiveSize = 6.0;
  static const _activeSize = 8.0;
  static const _spacing = 6.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: _spacing),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: i == currentIndex ? _activeSize : _inactiveSize,
            height: i == currentIndex ? _activeSize : _inactiveSize,
            decoration: BoxDecoration(
              color: i == currentIndex ? AppColors.onBase : AppColors.muted,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }
}
