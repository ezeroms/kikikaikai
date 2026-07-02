import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/shared/widgets/content_card.dart';

class HomeHorizontalSection extends StatefulWidget {
  const HomeHorizontalSection({
    super.key,
    this.title,
    required this.contents,
    this.horizontalInset = 16,
  });

  final String? title;
  final List<Content> contents;

  /// 親の左右パディング（PageView 幅の計算に使用）
  final double horizontalInset;

  static const cardWidth = 248.0;
  static const listHeight = 300.0;
  static const _pageGap = 16.0;

  @override
  State<HomeHorizontalSection> createState() => _HomeHorizontalSectionState();
}

class _HomeHorizontalSectionState extends State<HomeHorizontalSection> {
  PageController? _pageController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureController();
  }

  @override
  void didUpdateWidget(covariant HomeHorizontalSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.horizontalInset != widget.horizontalInset) {
      _recreateController();
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  double get _viewportFraction {
    final width =
        MediaQuery.sizeOf(context).width - widget.horizontalInset * 2;
    return ((HomeHorizontalSection.cardWidth + HomeHorizontalSection._pageGap) /
            width)
        .clamp(0.55, 0.95);
  }

  void _ensureController() {
    if (_pageController != null) return;
    _pageController = PageController(viewportFraction: _viewportFraction);
  }

  void _recreateController() {
    _pageController?.dispose();
    _pageController = PageController(viewportFraction: _viewportFraction);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.contents.isEmpty) return const SizedBox.shrink();

    _ensureController();
    final controller = _pageController!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(widget.title!, style: AppTypography.title(size: 17)),
          const SizedBox(height: 12),
        ],
        SizedBox(
          height: HomeHorizontalSection.listHeight,
          child: widget.contents.length == 1
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: ContentCard(
                    content: widget.contents.first,
                    width: HomeHorizontalSection.cardWidth,
                    height: HomeHorizontalSection.listHeight,
                    showPlayButton: false,
                  ),
                )
              : PageView.builder(
                  controller: controller,
                  padEnds: false,
                  itemCount: widget.contents.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < widget.contents.length - 1
                            ? HomeHorizontalSection._pageGap
                            : 0,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ContentCard(
                          content: widget.contents[index],
                          width: HomeHorizontalSection.cardWidth,
                          height: HomeHorizontalSection.listHeight,
                          showPlayButton: false,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
