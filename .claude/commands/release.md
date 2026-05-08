---
description: SemVer 룰로 VERSION bump + CHANGELOG 동기화 + commit + (옵션) /pr 자동 체인. v1.17.0/1.17.1 같은 누락 사고 방지.
argument-hint: [patch | minor | major] [--dry-run] [--no-pr]
---

VERSION + CHANGELOG + commit + (옵션) PR 까지를 한 번에. **현재 브랜치에 변경사항을 함께 묶어** 릴리스합니다 (별도 release PR 패턴이 아님).

**명령:** $ARGUMENTS

---

## 사전 조건

1. **현재 브랜치가 main 이 아님** — 릴리스는 항상 feature/fix/chore 브랜치에서 묶음. main 직접 push 거부.
2. **working tree 가 깨끗** (uncommitted 변경 없음) — VERSION/CHANGELOG 갱신만 깔끔하게 추가하기 위함.
3. **CHANGELOG.md 에 변경 내역이 준비됨** — 없으면 사용자에게 작성 요청 (다음 Step 2 참조).

위반 시 명확한 오류 메시지 + 수정 가이드.

---

## Step 0 — 옵션 파싱

| 인자 | 동작 |
|------|------|
| `patch` | X.Y.**Z+1** (디폴트) |
| `minor` | X.**Y+1**.0 |
| `major` | **X+1**.0.0 |
| `--dry-run` | 변경 미리보기만, 실제 파일 수정 X |
| `--no-pr` | commit 까지만, `/pr` 자동 호출 안 함 |

```bash
BUMP=patch  # 디폴트
DRY=false
NO_PR=false
for a in $ARGUMENTS; do
  case "$a" in
    patch|minor|major) BUMP="$a" ;;
    --dry-run) DRY=true ;;
    --no-pr) NO_PR=true ;;
  esac
done
```

---

## Step 1 — 새 버전 계산

```bash
CURRENT=$(cat VERSION | tr -d '[:space:]')
IFS='.' read -r MA MI PA <<< "$CURRENT"
case "$BUMP" in
  patch) NEW="$MA.$MI.$((PA+1))" ;;
  minor) NEW="$MA.$((MI+1)).0" ;;
  major) NEW="$((MA+1)).0.0" ;;
esac
echo "VERSION: $CURRENT → $NEW"
```

---

## Step 2 — CHANGELOG 검증·동기화

CHANGELOG.md 의 가장 위 `## [X.Y.Z] - YYYY-MM-DD` 섹션이 **새 버전 $NEW 와 일치** 하는지 확인.

### Case A — 이미 작성됨 (`## [$NEW] - 오늘 날짜`)
정상. 그대로 진행.

### Case B — 작성 안 됨 (가장 위 항목이 $CURRENT 또는 옛날 버전)
사용자에게 **CHANGELOG 항목 작성 요청**. 자동 추가는 위험 (의도와 다른 카테고리·맥락이 들어갈 수 있음). 다음 형식의 템플릿을 보여주고 사용자가 직접 채우게:

```markdown
## [$NEW] - $(date +%Y-%m-%d)

### Added (또는 Changed/Fixed/Removed)

- (변경 내역 1줄 요약)

### (선택) Migration

- (마이그레이션 가이드)

이유: (왜 이 변경이 필요했는지 한 문장)
```

> **자동 추가 금지** — v1.17.0/1.17.1 사고 (CHANGELOG 누락) 의 교훈은 "검증" 이지 "자동 생성" 이 아님. 사용자가 의도를 적게.

작성 후 다시 `/release $BUMP` 호출.

### Case C — 가장 위 항목이 $NEW 가 아니지만 사용자가 커밋한 변경에 CHANGELOG.md 가 포함됨
가장 위 섹션 헤더의 버전을 `$NEW` 와 날짜 `$(date +%Y-%m-%d)` 로 **자동 갱신** (헤더 한 줄만 정정).

```bash
# 가장 위 ## [버전] 헤더만 새 버전·오늘 날짜로 덮어쓰기
sed -i.bak -E "0,/^## \[[0-9]+\.[0-9]+\.[0-9]+\] - [0-9-]+/s//## [$NEW] - $(date +%Y-%m-%d)/" CHANGELOG.md
rm CHANGELOG.md.bak
```

---

## Step 3 — VERSION 갱신

```bash
if [ "$DRY" = true ]; then
  echo "[dry-run] VERSION → $NEW (실제 변경 X)"
else
  echo "$NEW" > VERSION
fi
```

---

## Step 4 — README 배지 갱신 (선택)

README.md 에 `version-X.Y.Z-blue` 배지가 있으면 자동 갱신.

```bash
if [ "$DRY" = false ] && grep -q "version-${CURRENT}-blue" README.md 2>/dev/null; then
  sed -i.bak "s/version-${CURRENT}-blue/version-${NEW}-blue/g" README.md
  rm README.md.bak
fi
```

---

## Step 5 — Dry run 출력

`--dry-run` 이면 여기서 종료:

```
[dry-run]
  VERSION:        $CURRENT → $NEW
  CHANGELOG:      가장 위 섹션 [$NEW] - $(date +%Y-%m-%d)
  README 배지:    version-${NEW}-blue
  Commit message: chore(release): v$NEW
```

---

## Step 6 — commit

```bash
git add VERSION CHANGELOG.md README.md 2>/dev/null
git commit -m "chore(release): v$NEW"
```

> **이미 다른 변경사항이 staged 됐다면 그것도 함께 commit** — 릴리스는 기능 PR 안에 들어가는 흐름이므로 자연스러움. 사용자가 거부하려면 `--no-pr` + 수동 unstage.

---

## Step 7 — `/pr` 자동 체인 (`--no-pr` 아니면)

`/pr` 커맨드 호출 (이미 존재). PR 본문에 다음 안내 자동 포함:

```
> **Release**: v$CURRENT → v$NEW. merge 후 .github/workflows/auto-tag.yml 이 자동으로 v$NEW 태그·릴리스를 생성합니다.
```

---

## Step 8 — 머지 후 사용자 안내

PR 생성 직후 출력:

```
✅ Release PR 생성 — v$NEW
   merge 후 자동:
     1. auto-tag.yml → v$NEW 태그 push + GitHub Release
     2. release notes = CHANGELOG 의 [$NEW] 섹션
   주의: CI 의 install-matrix 통과 확인 후 머지하세요.
```

---

## 사용 예시

```bash
# 가장 흔한 패턴 — 기능 PR 의 마지막에 호출
/release patch

# minor (새 기능 묶음)
/release minor

# 미리보기
/release patch --dry-run

# CHANGELOG 만 작성하고 PR 은 따로
/release patch --no-pr
```

---

## 주의사항

- **CHANGELOG 자동 작성 금지** — 의도 누락 사고 방지. 항상 사용자가 직접 작성한 항목을 검증할 뿐.
- **main 브랜치에서 호출 금지** — 즉시 거부, "feature/fix/chore 브랜치를 먼저 만드세요" 안내.
- **대화 중 여러 번 호출 금지** — VERSION 이 두 번 bump 되면 sync 깨짐. 한 PR 당 한 번만.
- `auto-tag.yml` 가 main 의 VERSION 변경을 감지해 태그를 만드므로, `/release` 가 직접 태그를 push 하지 않음 (중복 방지).
