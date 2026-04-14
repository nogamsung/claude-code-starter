<div align="center">

# 🤖 Claude Code Starter

**새 프로젝트에 Claude Code 하네스를 10초 만에 구성하는 설정 모음**

![Claude](https://img.shields.io/badge/Claude-Code-orange?logo=anthropic&logoColor=white)
![Kotlin](https://img.shields.io/badge/Kotlin-Spring_Boot-7F52FF?logo=kotlin&logoColor=white)
![Next.js](https://img.shields.io/badge/Next.js-000000?logo=next.js&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Go](https://img.shields.io/badge/Go-Gin-00ADD8?logo=go&logoColor=white)

</div>

---

## 개요

Claude Code를 프로젝트에서 바로 활용할 수 있도록 **커맨드, 에이전트, 템플릿**을 미리 세팅한 스타터입니다.

- `/init` 한 번으로 스택에 맞는 하네스 구성 (스택 자동 감지 지원)
- 스택별 전문 subagent로 생성·수정·테스트 역할 분리
- AI가 실수할 때마다 `/improve`로 규칙을 누적해 점점 정교해지는 피드백 루프
- `memory/MEMORY.md`에 팀 지식 자동 축적 — Second Brain

**지원 스택:** Kotlin Spring Boot · Next.js · Flutter · Go Gin

---

## 빠른 시작

### 1. 새 프로젝트에 `.claude` 폴더 설치

**방법 A — 부트스트랩 스크립트 (권장)**

새 프로젝트 루트에서 실행합니다.

```bash
curl -fsSL https://raw.githubusercontent.com/nogamsung/claude-code-starter/main/bootstrap.sh | bash
```

**방법 B — 수동 복사**

```bash
git clone --depth=1 https://github.com/nogamsung/claude.git
cp -r claude/.claude /path/to/your-project/
rm -rf claude
```

### 2. Claude Code에서 스택 초기화

```
/init           # 자동 감지 (package.json / build.gradle.kts / pubspec.yaml / go.mod)
/init kotlin    # Kotlin Spring Boot 백엔드
/init nextjs    # Next.js 프론트엔드
/init flutter   # Flutter 모바일
/init go        # Go Gin 백엔드
```

<details>
<summary><code>/init</code>이 하는 일</summary>

1. 스택 자동 감지 (인수 생략 시)
2. 선택한 스택과 무관한 agent/command/template 파일 제거
3. `CLAUDE.md` 설치 — 아키텍처 규칙, 코딩 컨벤션
4. `.claude/settings.json` 설치 — 스택별 허용 명령어 + 자동 lint/test 훅
5. `memory/MEMORY.md` 초기화 — 프로젝트 정보 인터뷰 후 자동 기록

</details>

### 3. `CLAUDE.md` 커스터마이징

설치된 `CLAUDE.md`를 열어 프로젝트 도메인 규칙, 폴더 구조, 금지 패턴을 추가합니다.

---

## 워크플로

```
/plan <기능 설명>      # 1. 코드 전 설계 합의
                       # 2. Claude가 적절한 agent로 구현
/test <파일>           # 3. 테스트 코드 자동 생성
/review staged         # 4. 코드 리뷰
/commit                # 5. Conventional Commits 형식으로 커밋

# AI가 실수하면:
/improve <실수 설명>   # → CLAUDE.md 규칙으로 등록 (반복 방지)
                       #   + memory/MEMORY.md에 자동 기록

# 팀 지식 관리:
/memory                # → Second Brain 전체 조회
/memory add <내용>     # → 결정·교훈 수동 기록
```

---

## 커맨드

### 공통

| 커맨드 | 설명 |
|--------|------|
| `/init [stack]` | 스택 감지 및 하네스 구성 |
| `/plan <기능>` | 코드 작성 전 설계 검토 및 합의 |
| `/test [파일]` | 테스트 코드 자동 생성 |
| `/review [대상]` | 코드 리뷰 |
| `/commit [힌트]` | Conventional Commits 형식으로 커밋 |
| `/improve <설명>` | AI 실수를 CLAUDE.md 규칙으로 등록 |
| `/memory [add\|search]` | Second Brain 조회·추가·검색 |

### 스택별

| 커맨드 | 스택 | 설명 |
|--------|------|------|
| `/new-api` | Kotlin | Controller / Service / Repository 스캐폴딩 |
| `/new-go-api` | Go | Handler / UseCase / Repository / Domain 스캐폴딩 |
| `/new-component` | Next.js | React 컴포넌트 생성 |
| `/new-screen` | Flutter | 화면 및 Provider 생성 |

---

## Agents

| Agent | 역할 |
|-------|------|
| `code-reviewer` | 정확성 · 보안 · 성능 · 유지보수성 관점 코드 리뷰 |
| `ui-designer` | DESIGN.md 기반 디자인 시스템 구축 (Next.js: Tailwind 토큰, Flutter: ThemeData) |
| `kotlin-generator` | 새 Kotlin 파일 생성 |
| `kotlin-modifier` | 기존 Kotlin 파일 수정 / 리팩토링 |
| `kotlin-tester` | Kotlin 테스트 코드 작성 |
| `nextjs-generator` | 새 Next.js 파일 생성 |
| `nextjs-modifier` | 기존 Next.js 파일 수정 / 리팩토링 |
| `nextjs-tester` | Next.js 테스트 코드 작성 |
| `flutter-generator` | 새 Flutter 파일 생성 |
| `flutter-modifier` | 기존 Flutter 파일 수정 / 리팩토링 |
| `flutter-tester` | Flutter 테스트 코드 작성 |
| `go-generator` | 새 Go 파일 생성 (Domain · Repository · UseCase · Handler) |
| `go-modifier` | 기존 Go 파일 수정 / 리팩토링 |
| `go-tester` | Go 테스트 코드 작성 (testify + mockery) |

---

## 플러그인 (스택별 자동 설치)

`/init` 실행 시 스택에 맞는 플러그인이 `settings.json`에 자동으로 활성화됩니다.

### 공통 (전 스택)

| 플러그인 | 설명 |
|---------|------|
| `github` | GitHub 레포 · PR · 이슈 관리 |
| `context7` | Spring Boot · Next.js · Flutter 최신 공식 문서를 컨텍스트로 자동 주입 |
| `feature-dev` | `/feature-dev` — 탐색→설계→구현→리뷰 7단계 체계적 개발 |
| `code-review` | `/code-review` — 병렬 4-agent PR 자동 리뷰 + CLAUDE.md 준수 검사 |
| `pr-review-toolkit` | 6종 전문 리뷰 에이전트 (테스트 분석 · 버그 탐지 · 타입 설계 · 간소화) |
| `security-guidance` | 위험 명령어 실행 전 보안 경고 |
| `hookify` | `/hookify` — 반복 실수를 자동 방지 훅으로 등록 |
| `commit-commands` | `/commit-push-pr` — 커밋·푸시·PR 생성 원스텝 |
| `claude-md-management` | CLAUDE.md 규칙 자동 관리 |

### 스택별 추가 플러그인

| 플러그인 | 스택 | 설명 |
|---------|------|------|
| `kotlin-lsp` | Kotlin | 타입 오류 · 심볼 참조 · 리팩토링 실시간 지원 |
| `typescript-lsp` | Next.js | TypeScript 코드 인텔리전스 실시간 지원 |
| `frontend-design` | Next.js | UI 컴포넌트 디자인 패턴 · 접근성 가이드 |
| `playwright` | Next.js | E2E 브라우저 테스트 자동화 |

> Go · Flutter는 별도 LSP 플러그인 없이 공통 플러그인만 사용합니다.

---

## 자동 훅 (settings.json)

`/init` 후 설치되는 `settings.json`에는 스택별 자동 검사 훅이 포함됩니다.

| 이벤트 | Kotlin | Next.js | Flutter | Go |
|--------|--------|---------|---------|-----|
| 파일 저장 후 | `ktlint` 검사 | `eslint` 검사 | `dart analyze` 검사 | `go vet` 검사 |
| 작업 완료 전 | `./gradlew test` | `tsc --noEmit` + `jest` | `flutter test` | `go test ./...` |
| **git push 전** | **Jacoco 커버리지 ≥ 90%** | **Jest 커버리지 ≥ 90%** | **Flutter 커버리지 ≥ 90%** | **Go 커버리지 ≥ 90%** |

### 커버리지 게이트 동작

`git push` 시 `.claude/hooks/pre-push.sh`가 자동 실행됩니다.

```
[Pre-push] 커버리지 게이트 (기준: 90%)
[Pre-push] 스택: Kotlin Spring Boot
[Pre-push] ./gradlew test jacocoTestReport 실행 중...

[Pre-push] 라인 커버리지: 87.3%  (기준: 90%)
[Pre-push] ❌ 커버리지 87.3%가 기준 90% 미만입니다.

  커버리지가 낮은 파일을 찾아 테스트를 추가하세요:
    /test <파일경로>   # 테스트 자동 생성
```

커버리지 미달 시 Claude가 자동으로 `/test`를 실행해 테스트를 보강하고 재시도합니다.

---

## 디렉토리 구조

```
.
├── bootstrap.sh              # 새 프로젝트에 .claude 설치 스크립트
├── memory/
│   └── MEMORY.md             # 이 레포의 Second Brain
└── .claude/
    ├── agents/               # 스택별 전문 subagent 정의
    │   ├── code-reviewer.md
    │   ├── ui-designer.md
    │   ├── kotlin-{generator,modifier,tester}.md
    │   ├── nextjs-{generator,modifier,tester}.md
    │   ├── flutter-{generator,modifier,tester}.md
    │   └── go-{generator,modifier,tester}.md
    ├── commands/             # 슬래시 커맨드 정의
    │   ├── init.md           # 스택 초기화 (자동 감지 포함)
    │   ├── plan.md
    │   ├── test.md
    │   ├── review.md
    │   ├── commit.md
    │   ├── improve.md
    │   ├── memory.md
    │   ├── new-api.md
    │   ├── new-go-api.md
    │   ├── new-component.md
    │   └── new-screen.md
    ├── skills/               # 스택별 코드 패턴 참조 (agents가 읽음)
    │   ├── kotlin-patterns.md
    │   ├── nextjs-patterns.md
    │   ├── flutter-patterns.md
    │   ├── go-patterns.md
    │   └── ui-design-impl.md
    └── templates/            # 스택별 설치 템플릿
        ├── CLAUDE.kotlin.md
        ├── CLAUDE.nextjs.md
        ├── CLAUDE.flutter.md
        ├── CLAUDE.go.md
        ├── settings.kotlin.json
        ├── settings.nextjs.json
        ├── settings.flutter.json
        ├── settings.go.json
        └── memory.md
```
