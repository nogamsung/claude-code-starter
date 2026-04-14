---
description: 새 기능 브랜치 생성 및 작업 완료 후 PR 생성 가이드 (dev/feature-{number})
argument-hint: <이슈번호 또는 기능명>  예: 42 / user-auth / 42-user-auth
---

새 기능 개발을 위한 브랜치를 생성하고 PR을 준비합니다.

**작업 내용**: $ARGUMENTS

---

## Step 1 — dev 브랜치 최신화

```bash
git checkout dev
git pull origin dev
```

현재 브랜치가 `dev`인지, 로컬이 원격과 동기화되었는지 확인합니다.

---

## Step 2 — 브랜치 번호 결정

`$ARGUMENTS`를 분석합니다:

- **숫자 포함** (예: `42`, `42-user-auth`) → 해당 번호 사용
- **기능명만** (예: `user-auth`) → 기존 `dev/feature-*` 브랜치 목록 확인 후 다음 번호 자동 부여

```bash
# 기존 feature 브랜치 번호 확인
git branch -a | grep 'dev/feature-' | sort -t- -k3 -n | tail -5
```

---

## Step 3 — 브랜치 생성

```bash
git checkout -b dev/feature-{number}
```

브랜치명 형식: `dev/feature-{number}` 또는 `dev/feature-{number}-{slug}`

예시:
- `dev/feature-42`
- `dev/feature-42-user-auth`

---

## Step 4 — 작업 안내

브랜치 생성 후 아래를 출력합니다:

```
브랜치 생성 완료: dev/feature-{number}
베이스 브랜치:    dev

작업 완료 후:
  /commit         → 커밋 메시지 작성
  /new-feature pr → PR 생성 (base: dev)
```

---

## PR 생성 모드 (`$ARGUMENTS`가 `pr`인 경우)

현재 브랜치에서 `dev`를 base로 PR을 생성합니다.

### PR 생성 전 체크리스트
1. 커밋이 모두 push되었는지 확인
2. CI가 통과 가능한 상태인지 확인 (lint, test)

### PR 생성

```bash
# 현재 브랜치 확인
BRANCH=$(git branch --show-current)

# 브랜치 push
git push -u origin $BRANCH

# PR 생성 (base: dev)
gh pr create \
  --base dev \
  --title "feat: {기능 요약}" \
  --body "$(cat <<'EOF'
## Summary
- 

## Changes
- 

## Test plan
- [ ] 

EOF
)"
```

### PR 제목 규칙
- Conventional Commits 형식: `feat:`, `fix:`, `refactor:` 등
- 50자 이내

### PR 생성 후 출력
```
PR 생성 완료
URL: {PR URL}

다음 단계:
1. GitHub에서 PR 리뷰어 지정
2. CI 통과 확인
3. dev에 merge 후 브랜치 삭제:
   git push origin --delete dev/feature-{number}
   git branch -d dev/feature-{number}
```
