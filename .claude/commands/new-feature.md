---
description: 새 기능을 위한 git worktree 생성 — dev/feature-{number} 브랜치를 .worktrees/ 에 격리된 작업공간으로 준비
argument-hint: <이슈번호 또는 기능명>  예: 42 / user-auth / 42-user-auth  |  pr (PR 생성 모드)
---

새 기능 개발을 위한 격리된 worktree를 생성합니다.

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

## Step 3 — 브랜치 번호 결정

`$ARGUMENTS`를 분석합니다:

- **숫자 포함** (예: `42`, `42-user-auth`) → 해당 번호 사용
- **기능명만** (예: `user-auth`) → 기존 worktree 목록 확인 후 다음 번호 자동 부여

```bash
# 기존 feature 번호 확인
git worktree list | grep 'feature-' | sort -t- -k2 -n | tail -5
```

---

## Step 4 — Worktree 생성

```bash
# 브랜치명: dev/feature-{number}
# 디렉토리: .worktrees/feature-{number}
git worktree add .worktrees/feature-{number} -b dev/feature-{number}
```

---

## Step 5 — 스택별 의존성 설치

worktree 디렉토리에서 프로젝트 파일 확인 후 자동 실행:

```bash
cd .worktrees/feature-{number}

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

브랜치:     dev/feature-{number}
경로:       .worktrees/feature-{number}/
베이스:     dev

병렬 작업:
  다른 터미널에서 cd .worktrees/feature-{number} 으로 이동하여 독립 작업 가능
  Claude Code: claude --dir .worktrees/feature-{number}

작업 완료 후:
  /new-feature pr   → PR 생성 (base: dev)
  정리:
    git worktree remove .worktrees/feature-{number}
    git branch -d dev/feature-{number}
```

---

## PR 생성

현재 worktree의 브랜치에서 `dev` base PR을 생성합니다.

### 사전 확인
```bash
BRANCH=$(git branch --show-current)
# dev/feature-{number} 형식인지 확인
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
git worktree remove .worktrees/feature-{number}
git branch -d dev/feature-{number}
git remote prune origin
```

---

## Worktree 현황 확인

```bash
git worktree list
```

```
/path/to/project          abc1234 [dev]
/path/to/.worktrees/feature-42  def5678 [dev/feature-42]
/path/to/.worktrees/feature-43  ghi9012 [dev/feature-43]
```
