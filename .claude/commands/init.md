---
description: 프로젝트 스택 선언 → 불필요한 agent/template/skill 제거 → CLAUDE.md + settings.json 설치 + Second Brain 초기화
argument-hint: [kotlin | kotlin-multi | go | go-multi | nextjs | nextjs-multi | flutter] (생략 시 자동 감지)
---

프로젝트의 스택을 설정하고 하네스를 구성합니다.

**선택한 스택:** $ARGUMENTS

---

## Step 1 — 스택 확인

### 1-1. `$ARGUMENTS` 해석

| 값 | 의미 |
|----|------|
| `kotlin` / `kotlin-multi` | Spring Boot 백엔드 (단일 / Gradle 멀티 모듈) |
| `go` / `go-multi` | Go Gin 백엔드 (단일 / Workspace 멀티 서비스) |
| `nextjs` / `nextjs-multi` | Next.js 프론트엔드 (단일 / Turborepo) |
| `flutter` | Flutter 모바일 |

### 1-2. 자동 감지 (인수 없을 때)

| 감지 파일 | 스택 |
|-----------|------|
| `settings.gradle.kts` + `include(` 포함 | `kotlin-multi` |
| `build.gradle.kts` / `pom.xml` | `kotlin` |
| `go.work` | `go-multi` |
| `go.mod` | `go` |
| `turbo.json` | `nextjs-multi` |
| `package.json` (`next` 의존성) | `nextjs` |
| `pubspec.yaml` | `flutter` |

감지 결과를 사용자에게 확인:
> "build.gradle.kts를 감지했습니다. `kotlin` 스택으로 진행할까요?"

감지 불가 시 직접 물어봅니다.

---

## Step 2 — 파일 정리 (스택별)

**각 스택에서 유지/제거 대상 목록을 사용자에게 보여주고 확인 후 삭제합니다.**

### 유지 대상 (스택별)

| 스택 | 유지 agents | 유지 skills | 유지 templates |
|------|-------------|-------------|----------------|
| `kotlin` / `kotlin-multi` | kotlin-{gen,mod,test}, code-reviewer, api-designer, ui-designer¹, github-actions-designer | kotlin-patterns, db-patterns, api-design-patterns, github-actions-patterns | CLAUDE.kotlin[-multi], settings.kotlin[-multi] |
| `go` / `go-multi` | go-{gen,mod,test}, code-reviewer, api-designer, github-actions-designer | go-patterns, db-patterns, api-design-patterns, github-actions-patterns | CLAUDE.go[-multi], settings.go[-multi] |
| `nextjs` / `nextjs-multi` | nextjs-{gen,mod,test}, code-reviewer, ui-designer, github-actions-designer | nextjs-patterns, ui-design-impl, github-actions-patterns | CLAUDE.nextjs[-multi], settings.nextjs[-multi] |
| `flutter` | flutter-{gen,mod,test}, code-reviewer, ui-designer, github-actions-designer | flutter-patterns, ui-design-impl, github-actions-patterns | CLAUDE.flutter, settings.flutter |

¹ `ui-designer`는 백엔드 단독 프로젝트에선 제거, 풀스택(Kotlin·Go + Next.js/Flutter) 구성이면 유지.

### 제거 대상

선택한 스택의 "유지 대상"이 아닌 `.claude/agents/`, `.claude/skills/`, `.claude/templates/` 하위 파일을 제거합니다. `.github/assets/` (스타터 대표 이미지 폴더)도 함께 제거.

> **커맨드는 전부 유지**합니다. `/new`, `/design`, `/review` 는 서브명령으로 스택 분기를 내부 처리합니다.

---

## Step 3 — 하네스 파일 설치

### 3-1. CLAUDE.md

**신규 프로젝트** (CLAUDE.md 없음):
```bash
cp .claude/templates/CLAUDE.{stack}.md ./CLAUDE.md
```

**기존 프로젝트**: 기존 파일에 템플릿의 "아키텍처 규칙", "반드시 지켜야 할 규칙", "절대 하면 안 되는 것" 섹션을 병합. 덮어쓰기 전 사용자 확인.

사용자에게 프로젝트명을 물어 `CLAUDE.md` 첫 줄의 `[프로젝트명]`을 교체.

### 3-2. 커버리지 게이트 훅

`.claude/hooks/pre-push.sh` 확인. `bootstrap.sh`로 설치했으면 이미 존재. 없으면 복사.

```bash
mkdir -p .claude/hooks
# 훅은 git push 시 자동 동작: 스택 감지 → 테스트 실행 → 라인 커버리지 90% 미만 시 푸시 차단
```

### 3-3. settings.json

**신규**:
```bash
cp .claude/templates/settings.{stack}.json ./.claude/settings.json
```

**기존**: 기존 파일의 `hooks`와 `permissions` 섹션만 템플릿으로 업데이트. `enabledPlugins` 등 기존 설정은 유지.

### 3-4. Second Brain 초기화

`/init`은 새 프로젝트 시작이므로 **기존 memory가 있어도 항상 초기화**:

```bash
mkdir -p memory
cp .claude/templates/memory.md ./memory/MEMORY.md
```

초기화 후 사용자에게 **한 번에** 질문:

> 1. 이 프로젝트의 목적 또는 배경을 한 줄로 설명해주세요.
> 2. 주요 도메인이나 핵심 기능은 무엇인가요?
> 3. 특별한 제약사항이 있나요? (마감일, 성능 요구사항, 팀 규모)
> 4. 연동할 외부 시스템이나 참고 레퍼런스가 있나요? (없으면 생략)

답변을 받으면 `memory/MEMORY.md`에 다음 두 항목 기록:

```markdown
## YYYY-MM-DD: 프로젝트 시작

**카테고리:** 결정

- **프로젝트명:** [프로젝트명]
- **스택:** [선택 스택]
- **목적:** [질문 1 답변]
- **핵심 기능:** [질문 2 답변]
- **제약사항:** [질문 3 답변]
- **외부 연동:** [질문 4 답변 또는 없음]

---

## YYYY-MM-DD: Claude Code 하네스 구성

**카테고리:** 참고

/init [스택]으로 하네스를 구성했습니다.
- CLAUDE.md: 아키텍처 규칙 및 코딩 컨벤션
- .claude/settings.json: 권한 및 훅 설정
- memory/MEMORY.md: Second Brain 초기화

앞으로 중요한 결정·교훈은 /memory add 로 기록하세요.
```

---

## Step 4 — .gitignore 초기 설정

```bash
grep -q "\.worktrees/" .gitignore 2>/dev/null || echo ".worktrees/" >> .gitignore
git add .gitignore
git commit -m "chore: .worktrees/ gitignore 추가" 2>/dev/null || true
```

> `.worktrees/`가 gitignore에 없으면 worktree 디렉토리가 git에 추적될 위험이 있습니다.

---

## Step 5 — Git 브랜치 전략 (신규 프로젝트만)

사용자에게 선택 요청 (기본값 A):

> **A. main + dev** (권장)
> ```
> main ← dev ← feature/* / fix/* / hotfix/* / ...
> ```
> - `dev`: 개발 통합 (스테이징), `main`: 프로덕션
> - PR: `feature/*` → `dev`, 릴리즈: `dev` → `main`
>
> **B. main only**
> ```
> main ← feature/* / fix/* / hotfix/* / ...
> ```
> - `main` 하나만, PR: `feature/*` → `main` 바로 머지

### A 선택

```bash
git checkout -b dev
git push -u origin dev
```

GitHub 브랜치 보호 안내:
- **main**: PR 필수 + status checks + restrict push
- **dev**: PR 필수 + status checks

### B 선택

`dev` 생성하지 않음. `main` 하나만 사용.

GitHub 브랜치 보호 안내:
- **main**: PR 필수 + status checks + restrict push

> ℹ️ `/new worktree` 는 `dev` 존재 여부로 전략을 자동 감지합니다. `dev` 없으면 자동으로 `main`을 베이스로 사용.

---

## Step 6 — 완료 메시지

```
✅ 프로젝트 하네스 구성 완료

프로젝트: [이름]
스택: [선택 스택]
제거된 파일: N개

[하네스 기둥 상태]
  기둥 1 (컨텍스트):     CLAUDE.md ✅
  기둥 2 (CI/CD 게이트): .claude/settings.json hooks ✅
  기둥 3 (도구 경계):    .claude/settings.json permissions ✅
  기둥 4 (피드백 루프):  /rule 커맨드 ✅
  기둥 5 (팀 지식):      memory/MEMORY.md ✅

[Git 브랜치 & Worktree]
  main + dev 또는 main only
  dev 브랜치: 생성됨 / 사용 안 함
  .worktrees/: gitignore 등록됨

남은 agents: [목록]
남은 commands: [목록]

이제 할 일:
  1. CLAUDE.md 를 열고 프로젝트에 맞게 커스터마이징
  2. GitHub 브랜치 보호 규칙 설정 (main·dev 또는 main만)
  3. /new worktree {type-name}  → 첫 작업 브랜치
  4. /plan <기능>                → 설계 시작
  5. AI 실수 시 /rule            → 규칙 추가
  6. 중요한 결정·교훈은 /memory add

[멀티 모듈 스택 추가]
  7. /new module <모듈명>        → 새 서브모듈/패키지/서비스
```
