import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/shared/widgets/content_card.dart';

class HomeHorizontalSection extends StatelessWidget {
  const HomeHorizontalSection({
    super.key,
    this.title,
    required this.contents,
  });

  final String? title;
  final List<Content> contents;

  static const _cardWidth = 280.0;
  static const _listHeight = 328.0;

  @override
  Widget build(BuildContext context) {
    if (contents.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title!, style: AppTypography.title(size: 17)),
          const SizedBox(height: 12),
        ],
        SizedBox(
          height: _listHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: contents.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return ContentCard(
                content: contents[index],
                width: _cardWidth,
              );
            },
          ),
        ),
      ],
    );
  }
}
