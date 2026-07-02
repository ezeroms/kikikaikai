import 'package:kikikaikai/core/models/figure.dart';
import 'package:kikikaikai/data/dummy/dummy_figures.dart';
import 'package:kikikaikai/data/repositories/figure_repository.dart';

/// テストやオフライン検証用。本番経路は [LocalFigureRepository]。
class MockFigureRepository implements FigureRepository {
  @override
  Future<List<Figure>> getAll() async => dummyFigures;

  @override
  Future<Figure?> getById(String id) async =>
      dummyFigures.where((f) => f.id == id).firstOrNull;
}
