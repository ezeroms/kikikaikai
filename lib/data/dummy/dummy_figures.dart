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
    id: 'figure_nagahata',
    name: '長畑宏明',
    sortKey: 'ながはたひろあき',
    bio: '街頭テレビに出演。',
    avatarAsset: 'assets/branding/eye_catch/gaitotv.png',
  ),
  const Figure(
    id: 'figure_kanri',
    name: '団地管理室',
    sortKey: 'だんちかんりしつ',
    bio: '団地便・旧作倉庫の管理。',
    avatarAsset: 'assets/branding/eye_catch/kairanban.png',
  ),
  const Figure(
    id: 'figure_osan',
    name: 'ダ・ヴィンチ・恐山',
    sortKey: 'おそれやま',
    bio: '奇奇怪怪・団地ラジオに出演。',
    avatarAsset: 'assets/branding/ogp_common.png',
  ),
  const Figure(
    id: 'figure_yamamoto',
    name: '山本浩貴',
    sortKey: 'やまもとひろき',
    bio: '奇奇怪怪・団地ラジオに出演。',
    avatarAsset: 'assets/branding/ogp_common.png',
  ),
  const Figure(
    id: 'figure_miyake',
    name: '三宅香帆',
    sortKey: 'みやけかほ',
    bio: '団地ラジオに出演。',
    avatarAsset: 'assets/branding/ogp_common.png',
  ),
  const Figure(
    id: 'figure_tsuyacchan',
    name: 'つやちゃん',
    sortKey: 'つやちゃん',
    bio: '団地ラジオに出演。',
    avatarAsset: 'assets/branding/ogp_common.png',
  ),
  const Figure(
    id: 'figure_sakuma',
    name: '佐久間信行',
    sortKey: 'さくまのぶゆき',
    bio: '団地ラジオに出演。',
    avatarAsset: 'assets/branding/ogp_common.png',
  ),
  const Figure(
    id: 'figure_goto',
    name: '後藤愼平',
    sortKey: 'ごとうしんぺい',
    bio: '団地ラジオに出演。',
    avatarAsset: 'assets/branding/ogp_common.png',
  ),
  const Figure(
    id: 'figure_wakabayashi',
    name: '若林恵',
    sortKey: 'わかばやしめぐみ',
    bio: '団地ラジオに出演。',
    avatarAsset: 'assets/branding/ogp_common.png',
  ),
  const Figure(
    id: 'figure_iwasaki',
    name: '岩崎裕介',
    sortKey: 'いわさきゆうすけ',
    bio: '映画監督。団地ラジオに出演。',
    avatarAsset: 'assets/branding/ogp_common.png',
  ),
  const Figure(
    id: 'figure_hayashi',
    name: '林健太郎',
    sortKey: 'はやしけんたろう',
    bio: '団地ラジオに出演。',
    avatarAsset: 'assets/branding/ogp_common.png',
  ),
  const Figure(
    id: 'figure_franz',
    name: 'Franz K Endo',
    sortKey: 'ふらんつけえんど',
    bio: 'クリエイター。団地ラジオに出演。',
    avatarAsset: 'assets/branding/ogp_common.png',
  ),
  const Figure(
    id: 'figure_omori',
    name: '大森時生',
    sortKey: 'おおもりときお',
    bio: '団地ラジオに出演。',
    avatarAsset: 'assets/branding/ogp_common.png',
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
