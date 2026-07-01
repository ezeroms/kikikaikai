# 品品団地（pinpin-danchi）

[品品団地 pinpin.tokyo](https://pinpin.tokyo/) のビジュアル・情報設計をトレースした iOS/Android カルチャープラットフォーム Flutter アプリ（v1 プロトタイプ）。

## 機能

- 回覧板 / 玉置玉稿 / 街頭テレビ / 団地ラジオ / 奇奇怪怪 / 団地便 / 旧作倉庫 の閲覧
- 品品団地アカウント（ダミー）の作成・ログイン
- 団地住民（有料）限定コンテンツのアクセス制御
- 団地住民アップグレード（ブラウザ遷移 + ダミー完了）
- 動画・音声の30秒プレビュー

## 起動方法

```bash
flutter pub get
flutter run -d "iPhone 17 Pro Max"
```

## 技術スタック

- Flutter 3.x
- Riverpod / go_router
- google_fonts / video_player / just_audio / flutter_markdown

## 注意

- 認証・課金・コンテンツはすべてダミー実装です
- 画像アセットは pinpin.tokyo 公式素材を使用しています
