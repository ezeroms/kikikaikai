import 'package:intl/intl.dart';

final _contentDateFormat = DateFormat('yyyy年M月d日');

/// コンテンツの投稿日など、アプリ内で統一して使う年月日表示。
String formatContentDate(DateTime date) => _contentDateFormat.format(date);
