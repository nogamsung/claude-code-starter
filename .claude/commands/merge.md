---
description: 현재 브랜치의 PR을 머지한 뒤 main 최신화·버전 태그·worktree 정리까지 한 번에
argument-hint: [auto] (auto = GitHub Actions의 체크 통과 후 자동 머지로 queue)
---

현재 worktree의 PR을 머지하고 후속 정리를 자동 실행합니다.

**모드:** $ARGUMENTS (없으면 즉시 머지 시도, `auto` = 체크 통과 시 자동 머지)

---

## Step 1 — PR 상태 확인

```bash
BRANCH=$(git branch --show-current)
PR_JSON=$(gh pr view --json number,state,mergeable,mergeStateStatus 2>/dev/null)

if [ -z "$PR_JSON" ]; then
  echo "❌ 현재 브랜치($BRANCH)에 연결된 PR이 없습니다. 먼저 /pr 로 PR을 생성하세요."
  exit 1
fi

PR_NUM=$(echo "$PR_JSON" | jq -r '.number')
STATE=$(echo "$PR_JSON" | jq -r '.state')
MERGEABLE=$(echo "$PR_JSON" | jq -r '.mergeable')
MERGE_STATUS=$(echo "$PR_JSON" | jq -r '.mergeStateStatus')

echo "PR #$PR_NUM 상태: $STATE / mergeable: $MERGEABLE / $MERGE_STATUS"
```

### 상태별 분기

- `STATE == MERGED` → Step 3(정리)로 직행
- `STATE == CLOSED` → "PR이 머지되지 않은 채 닫혔습니다. 정리만 진행할까요? (y/N)"
- `STATE == OPEN` + `MERGEABLE == MERGEABLE` → Step 2로 진행
- `STATE == OPEN` + `MERGEABLE != MERGEABLE` → 충돌·체크 실패 등. 원인 안내 후 종료

---

## Step 2 — 머지 실행

### 기본 모드 (즉시 머지)

사용자에게 머지 방식을 물어봅니다 (기본값: squash):

> "머지 방식을 선택하세요:
>  **s**. squash (기본값, 커밋 1개로 합침)
>  **r**. rebase
>  **m**. merge commit"

선택에 따라:

```bash
# squash
gh pr merge $PR_NUM --squash --delete-branch

# rebase
gh pr merge $PR_NUM --rebase --delete-branch

# merge commit
gh pr merge $PR_NUM --merge --delete-branch
```

`--delete-branch` 로 GitHub 원격 브랜치는 자동 삭제.

### `auto` 모드 (체크 통과 시 자동 머지)

```bash
gh pr merge $PR_NUM --squash --auto --delete-branch
```

GitHub가 필요한 체크를 모두 통과하면 자동으로 머지합니다. 이 경우 Step 3는 **지금 실행하지 않고**, 체크 통과 후 사용자가 다시 `/merge` 를 호출해 정리 단계를 진행하도록 안내:

```
✅ auto-merge 큐잉 완료. 체크 통과 후 GitHub가 자동 머지합니다.
머지 확인 후 다시 /merge 를 호출해 로컬 정리를 진행하세요.
```

---

## Step 3 — 머지 후 정리

### 3-1. main 최신화

```bash
git checkout main
git pull origin main
```

> `dev` 전략을 쓰는 프로젝트라면 PR base에 따라 `git checkout dev && git pull origin dev` 를 먼저 실행한 뒤 main도 최신화.

### 3-2. 버전 태그

VERSION 파일 기준으로 태그 생성·푸시:

```bash
TAG="v$(cat VERSION)"
if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "ℹ️  태그 $TAG 이미 존재. 스킵."
else
  git tag $TAG
  git push origin $TAG
  echo "✅ 태그 $TAG 푸시 완료"
fi
```

> 태그는 항상 `main`에서 생성합니다. 피처 브랜치에서는 금지.

### 3-3. worktree & 로컬 브랜치 정리

```bash
# 현재 worktree가 .worktrees/ 하위면 안전하게 제거
WT_PATH=$(git worktree list --porcelain | awk -v b="refs/heads/$BRANCH" '$1=="worktree"{p=$2} $1=="branch"&&$2==b{print p}')

if [ -n "$WT_PATH" ] && [[ "$WT_PATH" == *"/.worktrees/"* ]]; then
  git worktree remove "$WT_PATH"
  echo "✅ worktree 제거: $WT_PATH"
fi

git branch -d "$BRANCH" 2>/dev/null || git branch -D "$BRANCH"
git remote prune origin
```

### 3-4. 완료 메시지

```
✅ 머지 및 정리 완료

PR:       #$PR_NUM ($BRANCH → merged)
태그:     $TAG
worktree: 제거됨
원격:     가지치기 완료
```

---

## 주의사항

- `gh` CLI 로그인 필요 (`gh auth status`)
- 브랜치 보호 규칙상 직접 머지가 금지된 레포에서는 `auto` 모드 권장
- `--delete-branch` 가 GitHub 설정상 차단된 경우 수동 삭제 안내
- 팀 프로젝트에서는 PR 머지 권한이 없을 수 있음 — 이 경우 체크 통과 알림만 보내고 사람이 머지하도록 유도
