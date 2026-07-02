import 'package:flutter/material.dart';
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

  int get _itemCount => widget.contents.length;

  @override
  void initState() {
    super.initState();
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

    return SizedBox(
      height: FeaturedContentCard.carouselHeight,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _virtualLoops * _itemCount * 2,
        itemBuilder: (context, index) {
          final content = widget.contents[_contentIndex(index)];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: FeaturedContentCard(content: content),
          );
        },
      ),
    );
  }
}
