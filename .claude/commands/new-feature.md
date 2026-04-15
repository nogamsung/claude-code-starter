---
description: 작업 유형에 맞는 git worktree 생성 — feature/{type}-{name} 브랜치를 .worktrees/ 에 격리된 작업공간으로 준비
argument-hint: <타입-이름>  예: feature-login / fix-signup / hotfix-payment / refactor-auth  |  pr (PR 생성 모드)
---

작업 유형에 맞는 격리된 worktree를 생성합니다.

**작업 내용**: $ARGUMENTS

> ⚠️ **브랜치 네이밍 제약**
> Git은 `dev` 브랜치와 `dev/feature-*` 브랜치를 **동시에 유지할 수 없습니다.**
> (Git refs가 파일시스템 경로처럼 동작해 `dev`라는 파일과 `dev/` 디렉토리가 충돌)
>
> 따라서 이 프로젝트의 피처 브랜치는 `dev/` 접두사 대신 **`feature/`, `fix/` 등 독립 prefix**를 사용합니다:
> - 통합 브랜치: `dev`
> - 피처 브랜치: `feature/{name}`, `fix/{name}`, `hotfix/{name}` 등

---

## PR 생성 모드 (`$ARGUMENTS`가 `pr`인 경우)

베이스 브랜치를 자동 감지하여 PR을 생성합니다:
- `dev` 브랜치 있음 → base: `dev`
- `dev` 브랜치 없음 → base: `main`

→ [PR 생성 섹션](#pr-생성)으로 이동

---

## Step 1 — .worktrees/ 안전 확인

```bash
# 1. .worktrees/가 .gitignore에 등록되어 있는지 확인
git check-ignore -q .worktrees 2>/dev/null
```

**등록되어 있지 않으면 즉시 추가 후 커밋:**
```bash
echo ".worktrees/" >> .gitignore
git add .gitignore
git commit -m "chore: .worktrees/ gitignore 추가"
```

---

## Step 2 — 베이스 브랜치 결정 & 최신화

`dev` 브랜치 존재 여부로 브랜치 전략을 자동 감지합니다:

```bash
# 베이스 브랜치 결정
if git branch --list dev | grep -q dev; then
  BASE_BRANCH="dev"
else
  BASE_BRANCH="main"
fi

git checkout $BASE_BRANCH
git pull origin $BASE_BRANCH
```

- `dev` 브랜치 있음 → **main + dev 전략**: base = `dev`
- `dev` 브랜치 없음 → **main only 전략**: base = `main`

---

## Step 3 — 브랜치명 결정

`$ARGUMENTS`를 분석합니다. 형식: `{타입}-{이름}` (kebab-case, 이름은 1~2단어)

| 타입 | 의미 | 예시 |
|------|------|------|
| `feature` | 새 기능 | `feature-login`, `feature-cart` |
| `fix` | 버그 수정 | `fix-signup`, `fix-null-crash` |
| `hotfix` | 긴급 프로덕션 수정 | `hotfix-payment`, `hotfix-auth` |
| `refactor` | 리팩토링 | `refactor-auth`, `refactor-db` |
| `chore` | 설정·의존성·잡무 | `chore-deps`, `chore-ci` |
| `docs` | 문서 | `docs-api`, `docs-readme` |
| `test` | 테스트 추가/수정 | `test-user`, `test-order` |
| `perf` | 성능 개선 | `perf-query`, `perf-render` |

- **타입 없이 이름만** (예: `login`) → `feature-login`으로 자동 처리

---

## Step 4 — Worktree 생성

```bash
# 예: $ARGUMENTS = feature-login  →  feature/login,     .worktrees/feature-login
# 예: $ARGUMENTS = fix-signup     →  fix/signup,        .worktrees/fix-signup
git worktree add .worktrees/{type}-{name} -b {type}/{name}
```

---

## Step 5 — 스택별 의존성 설치

worktree 디렉토리에서 프로젝트 파일 확인 후 자동 실행:

```bash
cd .worktrees/{type}-{name}

# Go
if [ -f go.mod ]; then go mod download; fi

# Next.js / Node.js
if [ -f package.json ]; then npm ci; fi

# Kotlin / Spring Boot
if [ -f gradlew ]; then ./gradlew dependencies --no-daemon -q; fi

# Flutter
if [ -f pubspec.yaml ]; then flutter pub get; fi
```

---

## Step 6 — 작업 안내 출력

```
Worktree 준비 완료

브랜치:     {type}/{name}
경로:       .worktrees/{type}-{name}/
베이스:     {BASE_BRANCH}   ← dev 브랜치 있으면 "dev", 없으면 "main"

병렬 작업:
  다른 터미널에서 cd .worktrees/{type}-{name} 으로 이동하여 독립 작업 가능
  Claude Code: claude --dir .worktrees/{type}-{name}

작업 완료 후:
  /new-feature pr   → PR 생성 (base: {BASE_BRANCH})
  정리:
    git worktree remove .worktrees/{type}-{name}
    git branch -d {type}/{name}
```

---

## PR 생성

현재 worktree의 브랜치에서 base PR을 생성합니다. 베이스는 `dev` 브랜치 존재 여부로 자동 결정됩니다.

### 사전 확인
```bash
BRANCH=$(git branch --show-current)
BASE_BRANCH=$(git branch --list dev | grep -q dev && echo "dev" || echo "main")
echo "브랜치: $BRANCH → PR base: $BASE_BRANCH"
```

### push & PR 생성
```bash
git push -u origin $BRANCH

gh pr create \
  --base $BASE_BRANCH \
  --title "feat: {기능 요약}" \
  --body "$(cat <<'EOF'
## Summary
- 

## Changes
- 

## Test plan
- [ ] 단위 테스트 추가/통과
- [ ] 로컬 동작 확인

EOF
)"
```

### PR merge 후 정리 (사용자가 GitHub에서 머지한 뒤 실행)

```bash
# 1. main 최신화
git checkout main
git pull origin main

# 2. 버전 태그 생성 & 푸시 (VERSION 파일 기준)
git tag v$(cat VERSION)
git push origin v$(cat VERSION)

# 3. worktree & 브랜치 정리
git worktree remove .worktrees/{type}-{name}
git branch -d {type}/{name}
git remote prune origin
```

> 태그는 항상 PR 머지 후 `main`에서 생성합니다. feature 브랜치에서는 태그를 만들지 않습니다.

---

## Worktree 현황 확인

```bash
git worktree list
```

```
/path/to/project                        abc1234 [dev]
/path/to/.worktrees/feature-login       def5678 [feature/login]
/path/to/.worktrees/fix-signup          ghi9012 [fix/signup]
/path/to/.worktrees/refactor-auth       jkl3456 [refactor/auth]
```
