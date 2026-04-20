#!/bin/bash
# Claude Code Starter — 부트스트랩 스크립트
#
# 신규 설치 또는 기존 프로젝트 업데이트에 모두 사용합니다.
# 기존 .claude/ 가 있으면 백업 없이 전체 교체합니다.
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

# install | update 모드 감지
if [ -d "$TARGET_DIR/.claude" ]; then
  MODE="update"
  OLD_VERSION="(unknown)"
  [ -f "$TARGET_DIR/.claude/.starter-version" ] && OLD_VERSION=$(cat "$TARGET_DIR/.claude/.starter-version")
else
  MODE="install"
fi

echo "📦 Claude Code Starter"
echo "   대상 디렉토리: $TARGET_DIR"
echo "   모드: $MODE"
[ "$MODE" = "update" ] && echo "   현재 버전: $OLD_VERSION"
echo ""

if [ "$MODE" = "update" ]; then
  echo "⚠️  기존 .claude/ 가 백업 없이 전체 교체됩니다."
  echo "    — 수정한 agent / 추가한 command / hooks / settings.local.json 이 모두 사라집니다."
  echo "    — memory/ 폴더는 건드리지 않습니다."
  echo ""
fi

# sparse checkout으로 .claude 폴더 + VERSION 가져오기
git clone --quiet --depth=1 --filter=blob:none --sparse "$REPO_URL" "$TMP_DIR" 2>/dev/null
cd "$TMP_DIR"
git sparse-checkout set .claude VERSION
cd "$TARGET_DIR"

# 기존 .claude/ 제거 후 새로 복사
rm -rf "$TARGET_DIR/.claude"
cp -r "$TMP_DIR/.claude" "$TARGET_DIR/"

# 설치된 스타터 버전 기록 (.starter-version은 gitignore 대상 아님 — 팀 공유)
NEW_VERSION=$(cat "$TMP_DIR/VERSION" 2>/dev/null || echo "unknown")
echo "$NEW_VERSION" > "$TARGET_DIR/.claude/.starter-version"

rm -rf "$TMP_DIR"

echo "✅ .claude/ 설치 완료 (버전: $NEW_VERSION)"
echo ""

if [ "$MODE" = "install" ]; then
  echo "다음 단계:"
  echo "  1. Claude Code에서 이 프로젝트를 여세요"
  echo "  2. /init              # 스택 자동 감지"
  echo "     /init kotlin       # Kotlin Spring Boot"
  echo "     /init nextjs       # Next.js"
  echo "     /init flutter      # Flutter"
  echo "     /init go           # Go Gin"
  echo "     /init python       # Python FastAPI"
  echo "     /init marketing    # 코드 없는 마케팅 전담"
  echo "     /init sales        # 코드 없는 세일즈 전담"
else
  echo "다음 단계:"
  echo "  1. Claude Code를 재시작하세요 (새 커맨드 인식)"
  echo "  2. /starter check     # 버전 확인"
fi
