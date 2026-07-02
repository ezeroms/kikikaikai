#!/bin/zsh
# 品品団地 — iPhone 17 Pro Max シミュレーターで Flutter を起動（対話型ターミナル用）
set -euo pipefail

cd "$(dirname "$0")/.."

DEVICE_ID="A596A395-A5BA-4AAF-BEFB-C539B5F99B27"

echo "▶ 品品団地 — flutter run (iPhone 17 Pro Max)"
echo "  ホットリロード: r または Cmd+R"
echo "  ホットリスタート: R"
echo "  新しい音声ファイル追加後は q で終了してから再起動してください（Hot Restart では不可）"
echo "  終了: q"
echo ""

exec flutter run -d "$DEVICE_ID"
