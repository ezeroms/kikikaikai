import 'package:kikikaikai/core/models/figure.dart';

abstract class FigureRepository {
  Future<List<Figure>> getAll();
  Future<Figure?> getById(String id);
}
