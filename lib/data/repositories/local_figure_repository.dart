import 'package:kikikaikai/core/models/figure.dart';
import 'package:kikikaikai/data/local/app_database.dart';
import 'package:kikikaikai/data/local/catalog_mappers.dart';
import 'package:kikikaikai/data/repositories/figure_repository.dart';

class LocalFigureRepository implements FigureRepository {
  LocalFigureRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<Figure>> getAll() async {
    final rows = await _database.raw.query(
      'figures',
      orderBy: 'sort_key ASC',
    );
    return rows.map(CatalogMappers.figureFromRow).toList();
  }

  @override
  Future<Figure?> getById(String id) async {
    final rows = await _database.raw.query(
      'figures',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return CatalogMappers.figureFromRow(rows.first);
  }
}
