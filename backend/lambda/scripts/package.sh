#!/bin/bash
set -e

LAMBDA_NAME=$1
ZIP_NAME=$2
shift 2
DEPS=("$@")

SCRIPT_DIR=$(dirname "$0")
LAMBDA_DIR="$SCRIPT_DIR/../$LAMBDA_NAME"
DIST_DIR="$SCRIPT_DIR/../dist"
ROOT_NODE_MODULES="$SCRIPT_DIR/../../../node_modules"

cd "$LAMBDA_DIR"

npm run build

mkdir -p "$DIST_DIR" dist/node_modules
rm -rf "$DIST_DIR/$ZIP_NAME"

for dep in "${DEPS[@]}"; do
  if [ -d "$ROOT_NODE_MODULES/$dep" ]; then
    cp -rL "$ROOT_NODE_MODULES/$dep" dist/node_modules/
  fi
done

find dist/node_modules -type d \( -name 'test*' -o -name 'dist-es' -o -name 'dist-types' \) -exec rm -rf {} + 2>/dev/null || true
find dist/node_modules -type f \( -name '*.md' -o -name '*.ts' -o -name '*.map' -o -name 'LICENSE*' -o -name '*.d.ts' \) -delete 2>/dev/null || true

cd dist && zip -rq "../$DIST_DIR/$ZIP_NAME" .

echo "Created $ZIP_NAME"
