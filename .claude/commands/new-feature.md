---
description: 작업 유형에 맞는 git worktree 생성 — dev/{type}-{name} 브랜치를 .worktrees/ 에 격리된 작업공간으로 준비
argument-hint: <타입-이름>  예: feature-login / fix-signup / hotfix-payment / refactor-auth  |  pr (PR 생성 모드)
---

작업 유형에 맞는 격리된 worktree를 생성합니다.

**작업 내용**: $ARGUMENTS

---

## PR 생성 모드 (`$ARGUMENTS`가 `pr`인 경우)

현재 브랜치에서 `dev`를 base로 PR을 생성합니다. → [PR 생성 섹션](#pr-생성)으로 이동

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

## Step 2 — dev 브랜치 최신화

```bash
git checkout dev
git pull origin dev
```

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
# 예: $ARGUMENTS = feature-login  →  dev/feature-login, .worktrees/feature-login
# 예: $ARGUMENTS = fix-signup     →  dev/fix-signup,    .worktrees/fix-signup
git worktree add .worktrees/{type}-{name} -b dev/{type}-{name}
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

브랜치:     dev/{type}-{name}
경로:       .worktrees/{type}-{name}/
베이스:     dev

병렬 작업:
  다른 터미널에서 cd .worktrees/{type}-{name} 으로 이동하여 독립 작업 가능
  Claude Code: claude --dir .worktrees/{type}-{name}

작업 완료 후:
  /new-feature pr   → PR 생성 (base: dev)
  정리:
    git worktree remove .worktrees/{type}-{name}
    git branch -d dev/{type}-{name}
```

---

## PR 생성

현재 worktree의 브랜치에서 `dev` base PR을 생성합니다.

### 사전 확인
```bash
BRANCH=$(git branch --show-current)
# dev/{type}-{name} 형식인지 확인
echo "브랜치: $BRANCH → PR base: dev"
```

### push & PR 생성
```bash
git push -u origin $BRANCH

gh pr create \
  --base dev \
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

### PR merge 후 정리
```bash
# PR merge 확인 후 실행
git worktree remove .worktrees/{type}-{name}
git branch -d dev/{type}-{name}
git remote prune origin
```

---

## Worktree 현황 확인

```bash
git worktree list
```

```
/path/to/project                        abc1234 [dev]
/path/to/.worktrees/feature-login       def5678 [dev/feature-login]
/path/to/.worktrees/fix-signup          ghi9012 [dev/fix-signup]
/path/to/.worktrees/refactor-auth       jkl3456 [dev/refactor-auth]
```
