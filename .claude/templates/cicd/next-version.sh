#!/usr/bin/env bash
# next-version.sh — 마지막 v* 태그 + conventional commits 로 다음 SemVer 계산
#
# stdout 으로 "X.Y.Z" 만 출력 → release-promote.yml 가 $(...) 로 캡처.
#
# 규칙:
#   <type>!: …  또는  본문 "BREAKING CHANGE"  → major
#   feat: …                                   → minor
#   그 외 (fix/chore/refactor/…)              → patch
#   태그 없음 (첫 릴리스)                      → 0.1.0
#
# override: 환경변수 BUMP=major|minor|patch 가 있으면 자동 판정 대신 사용.
#   (release-promote.yml 가 머지 메시지의 "release:<level>" 를 읽어 전달)
set -euo pipefail

LAST_TAG=$(git describe --tags --abbrev=0 --match 'v[0-9]*' 2>/dev/null || echo "")

# 첫 릴리스 — 태그 없음
if [ -z "$LAST_TAG" ]; then
  echo "0.1.0"
  exit 0
fi

CUR=${LAST_TAG#v}
IFS='.' read -r MAJ MIN PAT <<< "$CUR"
MAJ=${MAJ:-0}; MIN=${MIN:-0}; PAT=${PAT:-0}

LEVEL="${BUMP:-}"

if [ -z "$LEVEL" ]; then
  RANGE="${LAST_TAG}..HEAD"
  SUBJECTS=$(git log --format='%s' "$RANGE" 2>/dev/null || echo "")
  BODIES=$(git log --format='%b' "$RANGE" 2>/dev/null || echo "")

  if echo "$SUBJECTS" | grep -qE '^[a-z]+(\([^)]+\))?!:' \
     || echo "$BODIES" | grep -qE 'BREAKING[ -]CHANGE'; then
    LEVEL=major
  elif echo "$SUBJECTS" | grep -qE '^feat(\([^)]+\))?:'; then
    LEVEL=minor
  else
    LEVEL=patch
  fi
fi

case "$LEVEL" in
  major) MAJ=$((MAJ + 1)); MIN=0; PAT=0 ;;
  minor) MIN=$((MIN + 1)); PAT=0 ;;
  patch) PAT=$((PAT + 1)) ;;
  *) echo "❌ invalid BUMP='$LEVEL' (major|minor|patch)" >&2; exit 1 ;;
esac

echo "${MAJ}.${MIN}.${PAT}"
