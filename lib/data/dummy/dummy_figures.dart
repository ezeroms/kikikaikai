import 'package:kikikaikai/core/models/figure.dart';

final dummyFigures = <Figure>[
  const Figure(
    id: 'figure_taitan',
    name: 'TaiTan',
    sortKey: 'たいたん',
    bio: '回覧板の更新担当。奇奇怪怪にも出演。',
    avatarAsset: 'assets/avatar/taitan.png',
  ),
  const Figure(
    id: 'figure_tamaki',
    name: '玉置',
    sortKey: 'たまき',
    bio: '玉置玉稿に関わる。奇奇怪怪にも出演。',
    avatarAsset: 'assets/avatar/tamaoki.png',
  ),
  const Figure(
    id: 'figure_paon',
    name: 'ぱおん',
    sortKey: 'ぱおん',
    bio: '団地ラジオ・街頭テレビの進行。',
    avatarAsset: 'assets/avatar/paon.png',
  ),
  const Figure(
    id: 'figure_kanri',
    name: '団地管理室',
    sortKey: 'だんちかんりしつ',
    bio: '団地便・旧作倉庫の管理。',
    avatarAsset: 'assets/branding/eye_catch/kairanban.png',
  ),
];

final figureById = {
  for (final f in dummyFigures) f.id: f,
};

List<Figure> resolveFigures(Iterable<String> ids) {
  return sortFiguresByGojuon(
    ids.map((id) => figureById[id]).whereType<Figure>(),
  );
}
