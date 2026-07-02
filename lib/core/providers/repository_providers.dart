import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/core/providers/database_providers.dart';
import 'package:kikikaikai/data/repositories/auth_repository.dart';
import 'package:kikikaikai/data/repositories/content_comments_repository.dart';
import 'package:kikikaikai/data/repositories/content_engagement_repository.dart';
import 'package:kikikaikai/data/repositories/content_repository.dart';
import 'package:kikikaikai/data/repositories/figure_repository.dart';
import 'package:kikikaikai/data/repositories/local_content_repository.dart';
import 'package:kikikaikai/data/repositories/local_figure_repository.dart';
import 'package:kikikaikai/data/repositories/mock_auth_repository.dart';
import 'package:kikikaikai/data/repositories/downloads_repository.dart';
import 'package:kikikaikai/data/repositories/search_history_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => MockAuthRepository(),
);

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => LocalContentRepository(ref.watch(appDatabaseProvider)),
);

final figureRepositoryProvider = Provider<FigureRepository>(
  (ref) => LocalFigureRepository(ref.watch(appDatabaseProvider)),
);

final downloadsRepositoryProvider = Provider<DownloadsRepository>(
  (ref) => MockDownloadsRepository(),
);

final contentEngagementRepositoryProvider =
    Provider<ContentEngagementRepository>(
  (ref) => MockContentEngagementRepository(),
);

final contentCommentsRepositoryProvider =
    Provider<ContentCommentsRepository>(
  (ref) => MockContentCommentsRepository(),
);

final searchHistoryRepositoryProvider = Provider<SearchHistoryRepository>(
  (ref) => MockSearchHistoryRepository(),
);
