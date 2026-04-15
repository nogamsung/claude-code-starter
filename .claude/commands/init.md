---
description: 프로젝트 스택을 선언하고 관련 없는 agent/command/skills 파일을 제거, CLAUDE.md + settings.json을 설치하여 하네스를 구성
argument-hint: [kotlin | go | nextjs | flutter] (생략 시 자동 감지)
---

이 프로젝트의 스택을 설정하고 하네스를 구성합니다.

**선택한 스택:** $ARGUMENTS

---

## 진행 순서

### Step 1 — 스택 확인

#### 1-1. `$ARGUMENTS` 확인

- `kotlin` → Kotlin Spring Boot 백엔드 프로젝트
- `kotlin-multi` → Kotlin Spring Boot (Gradle 멀티 모듈)
- `go` → Go Gin 백엔드 프로젝트
- `go-multi` → Go (Go Workspace 멀티 서비스)
- `nextjs` → Next.js 프론트엔드 프로젝트
- `nextjs-multi` → Next.js (Turborepo 멀티 패키지)
- `flutter` → Flutter 모바일 프로젝트

#### 1-2. `$ARGUMENTS`가 없으면 — 자동 감지

프로젝트 루트에서 다음 파일을 확인합니다:

| 파일 | 감지 스택 |
|------|----------|
| `settings.gradle.kts`에 `include(` 포함 | `kotlin-multi` |
| `build.gradle.kts` 또는 `pom.xml` | `kotlin` |
| `go.work` 존재 | `go-multi` |
| `go.mod` | `go` |
| `turbo.json` 존재 | `nextjs-multi` |
| `package.json` (`next` 의존성 포함) | `nextjs` |
| `pubspec.yaml` | `flutter` |

자동 감지된 스택을 사용자에게 보여주고 확인을 받습니다.
> "build.gradle.kts를 감지했습니다. kotlin 스택으로 진행할까요?"

감지 불가 시 사용자에게 직접 물어봅니다.

#### 1-3. 신규 vs 기존 프로젝트 판단

- **신규**: 소스 파일이 거의 없는 빈 디렉토리 (`.claude` 폴더만 존재)
- **기존**: 이미 코드가 있는 프로젝트에 하네스를 추가하는 경우

두 경우 모두 동일하게 진행하되, 기존 프로젝트는 Step 4에서 파일 덮어쓰기 전 병합 여부를 확인합니다.

---

### Step 2 — 제거할 파일 목록 제시

**반드시 목록을 사용자에게 보여주고 확인을 받은 후에 삭제하세요.**

#### `go` 선택 시 — 제거 대상
agents: `kotlin-generator`, `kotlin-modifier`, `kotlin-tester`, `flutter-generator`, `flutter-modifier`, `flutter-tester`, `nextjs-generator`, `nextjs-modifier`, `nextjs-tester`
commands: `new-api.md`, `new-component.md`, `new-screen.md`
templates: `CLAUDE.kotlin.md`, `CLAUDE.nextjs.md`, `CLAUDE.flutter.md`, `settings.kotlin.json`, `settings.nextjs.json`, `settings.flutter.json`
skills: `kotlin-patterns.md`, `flutter-patterns.md`, `nextjs-patterns.md`, `ui-design-impl.md`
기타: `.github/assets/` (스타터 대표 이미지 폴더)

유지: `go-generator`, `go-modifier`, `go-tester`, `code-reviewer`, `github-actions-designer`
유지 commands: `new-go-api.md`, `new-workflow.md`, `new-feature.md`, `plan.md`, `test.md`, `review.md`, `improve.md`, `commit.md`, `memory.md`
유지 skills: `go-patterns.md`, `github-actions-patterns.md`

> `ui-designer`와 `ui-design-impl.md`는 Go 백엔드 전용 프로젝트에서는 불필요합니다.
> Go + Next.js/Flutter 풀스택 구성이라면 유지하세요.

---

#### `kotlin` 선택 시 — 제거 대상
agents: `nextjs-generator`, `nextjs-modifier`, `nextjs-tester`, `flutter-generator`, `flutter-modifier`, `flutter-tester`
commands: `new-component.md`, `new-screen.md`
templates: `CLAUDE.nextjs.md`, `CLAUDE.flutter.md`, `settings.nextjs.json`, `settings.flutter.json`
skills: `go-patterns.md`, `flutter-patterns.md`, `nextjs-patterns.md`, `ui-design-impl.md`
기타: `.github/assets/` (스타터 대표 이미지 폴더)

유지: `kotlin-generator`, `kotlin-modifier`, `kotlin-tester`, `code-reviewer`, `ui-designer`, `github-actions-designer`
유지 commands: `new-api.md`, `new-workflow.md`, `new-feature.md`, `plan.md`, `test.md`, `review.md`, `improve.md`, `commit.md`, `memory.md`
유지 skills: `kotlin-patterns.md`, `github-actions-patterns.md`

> `ui-designer`와 `ui-design-impl.md`는 Kotlin 백엔드 전용으로는 불필요합니다.
> 단, Kotlin + Next.js/Flutter 풀스택 구성이라면 유지하세요.

---

#### `nextjs` 선택 시 — 제거 대상
agents: `kotlin-generator`, `kotlin-modifier`, `kotlin-tester`, `flutter-generator`, `flutter-modifier`, `flutter-tester`
commands: `new-api.md`, `new-screen.md`
templates: `CLAUDE.kotlin.md`, `CLAUDE.flutter.md`, `settings.kotlin.json`, `settings.flutter.json`
skills: `kotlin-patterns.md`, `flutter-patterns.md`, `go-patterns.md`
기타: `.github/assets/` (스타터 대표 이미지 폴더)

유지: `nextjs-generator`, `nextjs-modifier`, `nextjs-tester`, `code-reviewer`, `ui-designer`, `github-actions-designer`
유지 commands: `new-component.md`, `new-workflow.md`, `new-feature.md`, `plan.md`, `test.md`, `review.md`, `improve.md`, `commit.md`, `memory.md`
유지 skills: `nextjs-patterns.md`, `ui-design-impl.md`, `github-actions-patterns.md`

> `ui-designer`는 Next.js에서 **핵심 에이전트**입니다.
> DESIGN.md → Tailwind 토큰 → shadcn/ui 컴포넌트 일관성을 담당합니다.

---

#### `flutter` 선택 시 — 제거 대상
agents: `kotlin-generator`, `kotlin-modifier`, `kotlin-tester`, `nextjs-generator`, `nextjs-modifier`, `nextjs-tester`
commands: `new-api.md`, `new-component.md`
templates: `CLAUDE.kotlin.md`, `CLAUDE.nextjs.md`, `settings.kotlin.json`, `settings.nextjs.json`
skills: `kotlin-patterns.md`, `nextjs-patterns.md`, `go-patterns.md`
기타: `.github/assets/` (스타터 대표 이미지 폴더)

유지: `flutter-generator`, `flutter-modifier`, `flutter-tester`, `code-reviewer`, `ui-designer`, `github-actions-designer`
유지 commands: `new-screen.md`, `new-workflow.md`, `new-feature.md`, `plan.md`, `test.md`, `review.md`, `improve.md`, `commit.md`, `memory.md`
유지 skills: `flutter-patterns.md`, `ui-design-impl.md`, `github-actions-patterns.md`

> `ui-designer`는 Flutter에서 **디자인 토큰 전담** 에이전트로 활용됩니다.
> DESIGN.md → ColorScheme · TextTheme · 스페이싱 상수 → `lib/core/theme/` 파일 생성을 담당합니다.
> CSS/Tailwind 스펙은 Flutter 모드에서 자동으로 무시됩니다.

---

#### `kotlin-multi` 선택 시 — 제거 대상
agents: `nextjs-generator`, `nextjs-modifier`, `nextjs-tester`, `flutter-generator`, `flutter-modifier`, `flutter-tester`
commands: `new-component.md`, `new-screen.md`
templates: `CLAUDE.kotlin.md`, `CLAUDE.nextjs.md`, `CLAUDE.nextjs-multi.md`, `CLAUDE.flutter.md`, `CLAUDE.go.md`, `CLAUDE.go-multi.md`, `settings.kotlin.json`, `settings.nextjs.json`, `settings.nextjs-multi.json`, `settings.flutter.json`, `settings.go.json`, `settings.go-multi.json`
skills: `go-patterns.md`, `flutter-patterns.md`, `nextjs-patterns.md`, `ui-design-impl.md`
기타: `.github/assets/` (스타터 대표 이미지 폴더)

유지: `kotlin-generator`, `kotlin-modifier`, `kotlin-tester`, `code-reviewer`, `ui-designer`, `github-actions-designer`
유지 commands: `new-api.md`, `new-module.md`, `new-workflow.md`, `new-feature.md`, `plan.md`, `test.md`, `review.md`, `improve.md`, `commit.md`, `memory.md`
유지 skills: `kotlin-patterns.md`, `github-actions-patterns.md`

> `ui-designer`와 `ui-design-impl.md`는 Kotlin 백엔드 전용으로는 불필요합니다.
> 단, Kotlin + Next.js/Flutter 풀스택 구성이라면 유지하세요.

---

#### `nextjs-multi` 선택 시 — 제거 대상
agents: `kotlin-generator`, `kotlin-modifier`, `kotlin-tester`, `flutter-generator`, `flutter-modifier`, `flutter-tester`
commands: `new-api.md`, `new-screen.md`
templates: `CLAUDE.kotlin.md`, `CLAUDE.kotlin-multi.md`, `CLAUDE.nextjs.md`, `CLAUDE.flutter.md`, `CLAUDE.go.md`, `CLAUDE.go-multi.md`, `settings.kotlin.json`, `settings.kotlin-multi.json`, `settings.nextjs.json`, `settings.flutter.json`, `settings.go.json`, `settings.go-multi.json`
skills: `kotlin-patterns.md`, `flutter-patterns.md`, `go-patterns.md`
기타: `.github/assets/` (스타터 대표 이미지 폴더)

유지: `nextjs-generator`, `nextjs-modifier`, `nextjs-tester`, `code-reviewer`, `ui-designer`, `github-actions-designer`
유지 commands: `new-component.md`, `new-module.md`, `new-workflow.md`, `new-feature.md`, `plan.md`, `test.md`, `review.md`, `improve.md`, `commit.md`, `memory.md`
유지 skills: `nextjs-patterns.md`, `ui-design-impl.md`, `github-actions-patterns.md`

> `ui-designer`는 Next.js Turborepo에서 **핵심 에이전트**입니다.
> DESIGN.md → Tailwind 토큰 → shadcn/ui 컴포넌트 일관성을 담당합니다.

---

#### `go-multi` 선택 시 — 제거 대상
agents: `kotlin-generator`, `kotlin-modifier`, `kotlin-tester`, `flutter-generator`, `flutter-modifier`, `flutter-tester`, `nextjs-generator`, `nextjs-modifier`, `nextjs-tester`
commands: `new-api.md`, `new-component.md`, `new-screen.md`
templates: `CLAUDE.kotlin.md`, `CLAUDE.kotlin-multi.md`, `CLAUDE.nextjs.md`, `CLAUDE.nextjs-multi.md`, `CLAUDE.flutter.md`, `CLAUDE.go.md`, `settings.kotlin.json`, `settings.kotlin-multi.json`, `settings.nextjs.json`, `settings.nextjs-multi.json`, `settings.flutter.json`, `settings.go.json`
skills: `kotlin-patterns.md`, `flutter-patterns.md`, `nextjs-patterns.md`, `ui-design-impl.md`
기타: `.github/assets/` (스타터 대표 이미지 폴더)

유지: `go-generator`, `go-modifier`, `go-tester`, `code-reviewer`, `github-actions-designer`
유지 commands: `new-go-api.md`, `new-module.md`, `new-workflow.md`, `new-feature.md`, `plan.md`, `test.md`, `review.md`, `improve.md`, `commit.md`, `memory.md`
유지 skills: `go-patterns.md`, `github-actions-patterns.md`

> `ui-designer`와 `ui-design-impl.md`는 Go 백엔드 전용 프로젝트에서는 불필요합니다.
> Go + Next.js/Flutter 풀스택 구성이라면 유지하세요.

---

### Step 3 — 사용자 확인 후 삭제 실행

사용자가 확인하면 해당 파일들을 `rm` 명령어로 삭제하고 결과를 확인합니다.

---

### Step 4 — 하네스 파일 설치 (핵심)

#### 4-1. CLAUDE.md 설치 (기둥 1: 컨텍스트 파일)

**신규 프로젝트** (CLAUDE.md 없음):
```bash
# 단일 모듈
cp .claude/templates/CLAUDE.{stack}.md ./CLAUDE.md

# 멀티 모듈 (kotlin-multi, nextjs-multi, go-multi)
cp .claude/templates/CLAUDE.{stack}.md ./CLAUDE.md
# 예: cp .claude/templates/CLAUDE.kotlin-multi.md ./CLAUDE.md
```

**기존 프로젝트** (CLAUDE.md 이미 있음):
기존 파일에 템플릿의 "아키텍처 규칙", "반드시 지켜야 할 규칙", "절대 하면 안 되는 것" 섹션을 병합합니다.
덮어쓰기 전 사용자에게 확인을 받습니다.

**사용자에게 프로젝트명을 물어보고** `CLAUDE.md` 첫 줄의 `[프로젝트명]`을 실제 이름으로 교체합니다.

#### 4-2. 커버리지 게이트 훅 설치

`.claude/hooks/pre-push.sh`가 있는지 확인합니다.
bootstrap.sh로 설치했다면 이미 존재합니다.
없으면 이 레포의 `.claude/hooks/pre-push.sh`를 복사합니다.

```bash
mkdir -p .claude/hooks
# (bootstrap으로 이미 복사된 경우 생략)
```

훅은 `git push` 시 자동으로 동작합니다:
- 스택 자동 감지 (Kotlin → Jacoco, Next.js → Jest, Flutter → flutter test)
- 테스트 전체 실행
- 라인 커버리지 90% 미만 시 푸시 차단

#### 4-3. settings.json 설치 (기둥 2+3: CI/CD 게이트 + 도구 경계)

**신규 프로젝트** (`.claude/settings.json` 없음):
```bash
# 단일 모듈
cp .claude/templates/settings.{stack}.json ./.claude/settings.json

# 멀티 모듈 (kotlin-multi, nextjs-multi, go-multi)
cp .claude/templates/settings.{stack}.json ./.claude/settings.json
# 예: cp .claude/templates/settings.kotlin-multi.json ./.claude/settings.json
```

**기존 프로젝트** (`.claude/settings.json` 이미 있음):
기존 파일의 `hooks`와 `permissions` 섹션만 템플릿 내용으로 업데이트합니다.
`enabledPlugins` 등 기존 설정은 유지합니다.

#### 4-3. Second Brain 초기화 (기둥 5: 팀 지식 축적)

`/init`은 새 프로젝트 시작을 의미하므로 **기존 memory가 있어도 항상 초기화합니다.**

```bash
mkdir -p memory
cp .claude/templates/memory.md ./memory/MEMORY.md
```

초기화 후 사용자에게 다음 질문을 합니다. **한 번에 모두 물어보세요.**

> 1. 이 프로젝트의 목적 또는 배경을 한 줄로 설명해주세요.
> 2. 주요 도메인이나 핵심 기능은 무엇인가요?
> 3. 특별한 제약사항이 있나요? (마감일, 성능 요구사항, 팀 규모 등)
> 4. 연동할 외부 시스템이나 참고할 레퍼런스가 있나요? (없으면 생략)

답변을 받으면 `memory/MEMORY.md`에 아래 두 항목을 자동으로 기록합니다:

**[1] 프로젝트 개요**
```markdown
## YYYY-MM-DD: 프로젝트 시작

**카테고리:** 결정

- **프로젝트명:** [프로젝트명]
- **스택:** [선택한 스택]
- **목적:** [질문 1 답변]
- **핵심 기능:** [질문 2 답변]
- **제약사항:** [질문 3 답변]
- **외부 연동:** [질문 4 답변 또는 없음]
```

**[2] 하네스 구성 기록**
```markdown
## YYYY-MM-DD: Claude Code 하네스 구성

**카테고리:** 참고

/init [스택]으로 하네스를 구성했습니다.
- CLAUDE.md: 아키텍처 규칙 및 코딩 컨벤션
- .claude/settings.json: 권한 및 훅 설정
- memory/MEMORY.md: Second Brain 초기화

앞으로 중요한 결정·교훈은 /memory add 로 기록하세요.
```

---

### Step 5 — .gitignore 초기 설정

프로젝트 루트에 `.gitignore`가 없거나 `.worktrees/`가 없으면 추가합니다:

```bash
# .worktrees/ 미등록 시 추가
grep -q "\.worktrees/" .gitignore 2>/dev/null || echo ".worktrees/" >> .gitignore
git add .gitignore
git commit -m "chore: .worktrees/ gitignore 추가" 2>/dev/null || true
```

> `.worktrees/`가 gitignore에 없으면 worktree 디렉토리가 git에 추적될 위험이 있습니다.

---

### Step 6 — Git 브랜치 초기 설정

**신규 프로젝트**인 경우에만 실행합니다. 기존 프로젝트는 생략합니다.

#### 5-1. dev 브랜치 생성
```bash
git checkout -b dev
git push -u origin dev
```

#### 5-2. GitHub 브랜치 보호 규칙 안내

사용자에게 아래를 안내합니다:

> GitHub 저장소 Settings → Branches → Add rule 에서 다음 보호 규칙을 설정하세요.
>
> **`main` 브랜치 보호:**
> - ✅ Require a pull request before merging
> - ✅ Require status checks to pass (CI 워크플로 선택)
> - ✅ Restrict who can push to matching branches
>
> **`dev` 브랜치 보호:**
> - ✅ Require a pull request before merging
> - ✅ Require status checks to pass (CI 워크플로 선택)

#### 5-3. 기본 작업 브랜치 안내

> 앞으로 모든 작업은 `/new-feature {타입-이름}` 커맨드로 시작하세요.
> 생성되는 브랜치: `dev/{feature|fix|hotfix|refactor|chore}-{name}` → PR base: `dev`

---

### Step 7 — 완료 메시지

```
✅ 프로젝트 하네스 구성 완료

프로젝트: [프로젝트명]
스택: [선택한 스택]
제거된 파일: N개

[하네스 기둥 상태]
기둥 1 (컨텍스트):    CLAUDE.md ✅ 설치됨
기둥 2 (CI/CD 게이트): .claude/settings.json hooks ✅ 활성화
기둥 3 (도구 경계):    .claude/settings.json permissions ✅ 활성화
기둥 4 (피드백 루프):  /improve 커맨드 ✅ 사용 가능
기둥 5 (팀 지식 축적): memory/MEMORY.md ✅ 생성됨

[Git 브랜치 & Worktree]
main ← dev ← dev/{feature|fix|hotfix|refactor|chore}-{name}
dev 브랜치:  ✅ 생성됨
.worktrees/: ✅ gitignore 등록됨

남은 agents: [목록]
남은 commands: [목록]

이제 할 일:
1. CLAUDE.md를 열고 프로젝트에 맞게 커스터마이징하세요
2. GitHub에서 main·dev 브랜치 보호 규칙을 설정하세요
3. /new-feature feature-{이름} 또는 fix-{이름} 으로 첫 브랜치를 만드세요
4. /plan <기능> 으로 설계를 시작하세요
5. AI가 실수하면 /improve 로 규칙을 추가하세요
6. memory/MEMORY.md 에 중요한 결정과 교훈을 계속 기록하세요

[멀티 모듈 스택 (kotlin-multi / nextjs-multi / go-multi) 추가 할 일]
7. /new-module <모듈명> 으로 새 서브모듈/패키지/서비스를 추가하세요
```
