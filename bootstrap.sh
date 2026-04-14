#!/bin/bash
# Claude Code Starter — 부트스트랩 스크립트
#
# 새 프로젝트 루트에서 실행하면 .claude 폴더를 설치합니다.
#
# 사용법:
#   curl -fsSL https://raw.githubusercontent.com/nogamsung/claude-code-starter/main/bootstrap.sh | bash
#
# 또는 클론 후:
#   bash /path/to/claude-code-starter/bootstrap.sh

set -e

REPO_URL="https://github.com/nogamsung/claude-code-starter.git"
TMP_DIR=$(mktemp -d)
TARGET_DIR="$(pwd)"

echo "📦 Claude Code Starter 설치 중..."
echo "   대상 디렉토리: $TARGET_DIR"
echo ""

# .claude 폴더가 이미 있는 경우
if [ -d "$TARGET_DIR/.claude" ]; then
  echo "⚠️  .claude 폴더가 이미 존재합니다."
  read -p "   덮어쓰시겠습니까? (y/N): " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "   취소되었습니다."
    exit 0
  fi
fi

# sparse checkout으로 .claude 폴더만 가져오기
git clone --quiet --depth=1 --filter=blob:none --sparse "$REPO_URL" "$TMP_DIR" 2>/dev/null
cd "$TMP_DIR"
git sparse-checkout set .claude
cd "$TARGET_DIR"

cp -r "$TMP_DIR/.claude" "$TARGET_DIR/"
rm -rf "$TMP_DIR"

echo "✅ .claude 폴더 설치 완료"
echo ""
echo "다음 단계:"
echo "  1. Claude Code에서 이 프로젝트를 여세요"
echo "  2. /init kotlin   # Kotlin Spring Boot"
echo "     /init nextjs   # Next.js"
echo "     /init flutter  # Flutter"
echo ""
echo "스택을 명시하지 않으면 자동으로 감지합니다."
