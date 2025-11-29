#!/bin/bash
set -e

LAMBDA_NAME=$1
ZIP_NAME=$2
shift 2

SCRIPT_DIR=$(dirname "$0")
LAMBDA_DIR="$SCRIPT_DIR/../$LAMBDA_NAME"
DIST_DIR="$SCRIPT_DIR/../dist"

cd "$LAMBDA_DIR"

# TypeScript をコンパイル
npm run build

mkdir -p "$DIST_DIR"
rm -rf "$DIST_DIR/$ZIP_NAME"

# dist ディレクトリ内に本番用依存関係をインストール
cd dist
rm -rf node_modules

# package.json と package-lock.json をコピー（あればの場合）
if [ -f "../package.json" ]; then
  cp ../package.json .
  if [ -f "../package-lock.json" ]; then
    cp ../package-lock.json .
  fi
fi

# 本番用モジュールのみをインストール
npm install --omit=dev --legacy-peer-deps 2>/dev/null || npm install --omit=dev 2>/dev/null || true

# 不要なファイルを削除
find node_modules -type d \( -name 'test*' -o -name 'dist-es' -o -name 'dist-types' -o -name '.bin' -o -name '__tests__' -o -name 'example*' \) -exec rm -rf {} + 2>/dev/null || true
find node_modules -type f \( -name '*.md' -o -name '*.ts' -o -name '*.map' -o -name 'LICENSE*' -o -name '*.d.ts' \) ! -path '*/node_modules/*/package.json' -delete 2>/dev/null || true

# zip を作成
zip -rq "../$DIST_DIR/$ZIP_NAME" .

echo "Created $ZIP_NAME"
