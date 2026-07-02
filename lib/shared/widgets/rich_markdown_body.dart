import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/markdown/body_markdown_normalizer.dart';
import 'package:url_launcher/url_launcher.dart';

/// 回覧板・玉置玉稿などの本文用 Markdown レンダラー。
/// 見出し・画像・リンクなど、CMS 由来のリッチテキストに対応する。
/// 「・」で書かれた行は Markdown リストにせず、段落テキストとして表示する。
class RichMarkdownBody extends StatelessWidget {
  const RichMarkdownBody({super.key, required this.data});

  final String data;

  Future<void> _openLink(String? href) async {
    if (href == null) return;
    final uri = Uri.tryParse(href);
    if (uri == null || !await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildImage(MarkdownImageConfig config) {
    final uri = config.uri;
    final src = uri.toString();
    final isNetwork = uri.scheme == 'http' || uri.scheme == 'https';
    final isAsset = !isNetwork &&
        (src.startsWith('assets/') ||
            uri.scheme == 'asset' ||
            uri.scheme.isEmpty);

    final label = config.alt ?? config.title;
    if (!isNetwork && !isAsset) {
      return _imagePlaceholder(label);
    }

    final image = isNetwork
        ? Image.network(
            src,
            width: config.width,
            height: config.height,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                _imagePlaceholder(label),
          )
        : Image.asset(
            isAsset && uri.scheme == 'asset' ? uri.path : src,
            width: config.width,
            height: config.height,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                _imagePlaceholder(label),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: image,
      ),
    );
  }

  Widget _imagePlaceholder(String? label) {
    return Container(
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label ?? '画像を読み込めませんでした',
        style: AppTypography.caption(),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: BodyMarkdownNormalizer.normalize(data),
      softLineBreak: true,
      onTapLink: (text, href, title) => _openLink(href),
      sizedImageBuilder: _buildImage,
      styleSheet: MarkdownStyleSheet(
        p: AppTypography.body(size: 15),
        h1: AppTypography.heading(size: 22),
        h2: AppTypography.heading(size: 18),
        h3: AppTypography.title(size: 16),
        h4: AppTypography.titleSmall(size: 14),
        h5: AppTypography.body(size: 14, weight: FontWeight.w600),
        h6: AppTypography.caption(size: 13),
        strong: AppTypography.body(size: 15, weight: FontWeight.w700),
        em: AppTypography.body(size: 15).copyWith(fontStyle: FontStyle.italic),
        a: AppTypography.body(
          size: 15,
          color: AppColors.primary,
        ),
        blockquote: AppTypography.body(color: AppColors.secondary),
        listBullet: AppTypography.body(size: 15),
        listIndent: 20,
        code: AppTypography.body(size: 14).copyWith(
          fontFamily: 'monospace',
          backgroundColor: AppColors.surface,
        ),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
      ),
    );
  }
}
