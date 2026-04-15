<div align="center">

# Claude Code Starter

**새 프로젝트에 Claude Code 하네스를 10초 만에 구성하는 설정 모음**

<br/>

[![Claude](https://img.shields.io/badge/Claude-Code-FF6B35?logo=anthropic&logoColor=white)](https://claude.ai/code)
[![Version](https://img.shields.io/badge/version-1.4.0-blue)](CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

<br/>

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
- **Git Worktree 기반 병렬 작업** — 여러 기능을 독립된 작업공간에서 동시 개발
- **멀티 모듈 지원** — Gradle 멀티 모듈 / Turborepo / Go Workspace 구조로 시작 가능
- **DB 설계 자동화** — `/design-db`로 MySQL 스키마 설계 → Flyway/golang-migrate SQL 자동 생성
- **API 설계 자동화** — `/design-api`로 REST API 설계 → OpenAPI 3.0 YAML → 코드 생성 연결

**지원 스택:** Kotlin Spring Boot · Next.js · Flutter · Go Gin

---

## 빠른 시작

### 1. 새 프로젝트에 `.claude` 폴더 설치

**방법 A — 부트스트랩 스크립트 (권장)**

```bash
curl -fsSL https://raw.githubusercontent.com/nogamsung/claude-code-starter/main/bootstrap.sh | bash
```

**방법 B — 수동 복사**

```bash
git clone --depth=1 https://github.com/nogamsung/claude-code-starter.git
cp -r claude-code-starter/.claude /path/to/your-project/
rm -rf claude-code-starter
```

### 2. Claude Code에서 스택 초기화

```
/init                # 자동 감지 (package.json / build.gradle.kts / pubspec.yaml / go.mod / go.work / turbo.json)
/init kotlin         # Kotlin Spring Boot 백엔드 (단일 모듈)
/init kotlin-multi   # Kotlin Spring Boot (Gradle 멀티 모듈: api/domain/infra)
/init nextjs         # Next.js 프론트엔드 (단일 앱)
/init nextjs-multi   # Next.js (Turborepo: apps/web + packages/ui,lib,config)
/init flutter        # Flutter 모바일
/init go             # Go Gin 백엔드 (단일 서비스)
/init go-multi       # Go (Workspace: services/api,worker + pkg/shared)
```

<details>
<summary><code>/init</code>이 하는 일</summary>

1. 스택 자동 감지 (인수 생략 시)
2. 선택한 스택과 무관한 agent/command/template 파일 제거
3. `CLAUDE.md` 설치 — 아키텍처 규칙, 코딩 컨벤션
4. `.claude/settings.json` 설치 — 스택별 허용 명령어 + 자동 lint/test 훅
5. `memory/MEMORY.md` 초기화 — 프로젝트 정보 인터뷰 후 자동 기록
6. `dev` 브랜치 생성 + `.worktrees/` gitignore 등록

</details>

### 3. 기능 개발 시작

```bash
/new-feature feature-login    # .worktrees/feature-login/ 에 격리된 작업공간 생성
/new-feature fix-signup       # .worktrees/fix-signup/ 에 격리된 작업공간 생성
/new-feature refactor-auth    # .worktrees/refactor-auth/ 에 격리된 작업공간 생성
                              # 의존성 자동 설치 후 바로 작업 가능

/new-feature pr        # 작업 완료 후 dev 브랜치로 PR 생성
```

---

## 워크플로

```
/new-feature feature-login  # 1. worktree 생성 (dev/feature-login 브랜치)
/plan <기능 설명>       # 2. 코드 전 설계 합의
                        # 3. Claude가 적절한 agent로 구현
/test <파일>            # 4. 테스트 코드 자동 생성
/review staged          # 5. 코드 리뷰
/commit                 # 6. Conventional Commits 형식으로 커밋
/new-feature pr         # 7. dev 브랜치로 PR 생성

# AI가 실수하면:
/improve <실수 설명>    # → CLAUDE.md 규칙으로 등록 (반복 방지)
                        #   + memory/MEMORY.md에 자동 기록

# 팀 지식 관리:
/memory                 # → Second Brain 전체 조회
/memory add <내용>      # → 결정·교훈 수동 기록
```

---

## 브랜치 전략

```
main  ←──── dev  ←──── feature/{name}
(배포)      (통합)      fix/{name}
                        hotfix/{name}
                        refactor/{name}
                        chore/{name}
```

각 브랜치는 `.worktrees/{type}-{name}/` 에 격리된 작업공간으로 생성됩니다.
타입: `feature` · `fix` · `hotfix` · `refactor` · `chore` · `docs` · `test` · `perf`
여러 터미널 / Claude Code 인스턴스에서 **병렬 작업**이 가능합니다.

> ⚠️ **Git 브랜치 네이밍 제약:** `dev` 브랜치와 `dev/feature-*` 브랜치는 Git refs 구조상 동시에 존재할 수 없습니다.
> 따라서 피처 브랜치는 `dev/` 접두사 대신 `feature/`, `fix/` 등 독립 prefix를 사용합니다.

---

## 커맨드

### 공통

| 커맨드 | 설명 |
|--------|------|
| `/init [stack]` | 스택 감지 및 하네스 구성 (단일·멀티 모듈 모두 지원) |
| `/new-feature [{type}-{name}\|pr]` | Worktree 기반 작업 브랜치 생성 / PR 생성 (feature·fix·hotfix·refactor·chore 등) |
| `/new-module <name>` | 멀티 모듈 프로젝트에 서브모듈/패키지/서비스 추가 |
| `/plan <기능>` | 코드 작성 전 설계 검토 및 합의 |
| `/test [파일]` | 테스트 코드 자동 생성 |
| `/review [대상]` | 코드 리뷰 |
| `/commit [힌트]` | Conventional Commits 형식으로 커밋 |
| `/improve <설명>` | AI 실수를 CLAUDE.md 규칙으로 등록 |
| `/memory [add\|search]` | Second Brain 조회·추가·검색 |
| `/new-workflow [목적] [스택]` | GitHub Actions 워크플로 생성 |

### 스택별

| 커맨드 | 스택 | 설명 |
|--------|------|------|
| `/design-db <도메인>` | Kotlin · Go | MySQL 스키마 설계 → Flyway/golang-migrate Migration SQL 자동 생성 |
| `/design-api <Resource>` | Kotlin · Go | REST API 설계 → OpenAPI 3.0 YAML → `/new-api` · `/new-go-api` 연결 |
| `/review-api [대상]` | Kotlin · Go | REST 컨벤션·보안·OpenAPI 문서 완성도 리뷰 |
| `/new-api <Resource>` | Kotlin | Controller / Service / QueryDSL Repository 스캐폴딩 |
| `/new-go-api <Resource>` | Go | Handler / UseCase / sqlc Repository 스캐폴딩 |
| `/new-component <Name>` | Next.js | React 컴포넌트 생성 |
| `/new-screen <Name>` | Flutter | 화면 및 Provider 생성 |

---

## Agents

| Agent | 역할 |
|-------|------|
| `code-reviewer` | 정확성 · 보안 · 성능 · 유지보수성 관점 코드 리뷰 (전 스택) |
| `ui-designer` | DESIGN.md 기반 디자인 시스템 (Next.js: Tailwind 토큰, Flutter: ThemeData) |
| `github-actions-designer` | CI/CD · 릴리스 · Docker 배포 워크플로 설계 |
| `kotlin-{generator\|modifier\|tester}` | Kotlin Spring Boot 코드 생성·수정·테스트 |
| `nextjs-{generator\|modifier\|tester}` | Next.js 코드 생성·수정·테스트 |
| `flutter-{generator\|modifier\|tester}` | Flutter 코드 생성·수정·테스트 |
| `go-{generator\|modifier\|tester}` | Go Gin 코드 생성·수정·테스트 |
| `api-designer` | REST API 설계 전문 (OpenAPI 3.0 YAML, 컨벤션, 인증·페이지네이션 패턴) — Kotlin · Go 전용 |

---

## 스택별 기술 표준

| 항목 | Kotlin Spring Boot | Go Gin | Next.js | Flutter |
|------|-------------------|--------|---------|---------|
| ORM / 쿼리 | JPA + **QueryDSL** | GORM + **sqlc** | — | — |
| API 문서 | **SpringDoc OpenAPI** | **swaggo/swag** | — | — |
| Lint | ktlint | **golangci-lint** | ESLint | dart analyze |
| Docker 배포 | ✅ GHCR | ✅ GHCR | ✅ GHCR | ❌ |

---

## 플러그인 (스택별 자동 설치)

### 공통 (전 스택)

| 플러그인 | 설명 |
|---------|------|
| `github` | GitHub 레포 · PR · 이슈 관리 |
| `context7` | 최신 공식 문서를 컨텍스트로 자동 주입 |
| `feature-dev` | 탐색→설계→구현→리뷰 7단계 체계적 개발 |
| `code-review` | 병렬 4-agent PR 자동 리뷰 |
| `security-guidance` | 위험 명령어 실행 전 보안 경고 |
| `hookify` | 반복 실수를 자동 방지 훅으로 등록 |
| `commit-commands` | 커밋·푸시·PR 생성 원스텝 |

### 스택별 추가

| 플러그인 | 스택 | 설명 |
|---------|------|------|
| `kotlin-lsp` | Kotlin | 타입 오류 · 심볼 참조 실시간 지원 |
| `typescript-lsp` | Next.js | TypeScript 코드 인텔리전스 |
| `frontend-design` | Next.js | UI 패턴 · 접근성 가이드 |
| `playwright` | Next.js | E2E 브라우저 테스트 자동화 |

---

## 자동 훅

`/init` 후 설치되는 `settings.json`에는 스택별 자동 검사 훅이 포함됩니다.

| 이벤트 | Kotlin | Next.js | Flutter | Go |
|--------|--------|---------|---------|-----|
| 파일 저장 후 | `ktlint` | `eslint` | `dart analyze` | `go vet` |
| 작업 완료 전 | `gradlew test` | `tsc` + `jest` | `flutter test` | `go test ./...` |
| **git push 전** | **Jacoco ≥ 90%** | **Jest ≥ 90%** | **Flutter ≥ 90%** | **Go ≥ 90%** |

---

## 디렉토리 구조

```
claude-code-starter/
├── .github/
│   └── assets/               # README 이미지 (init 시 삭제)
├── .claude/
│   ├── agents/               # 전문 subagent 정의
│   │   ├── code-reviewer.md
│   │   ├── ui-designer.md
│   │   ├── github-actions-designer.md
│   │   ├── kotlin-{generator,modifier,tester}.md
│   │   ├── nextjs-{generator,modifier,tester}.md
│   │   ├── flutter-{generator,modifier,tester}.md
│   │   └── go-{generator,modifier,tester}.md
│   ├── commands/             # 슬래시 커맨드
│   │   ├── init.md           # 스택 초기화
│   │   ├── new-feature.md    # Worktree 기반 기능 브랜치
│   │   ├── new-workflow.md   # GitHub Actions 워크플로 생성
│   │   ├── plan.md / test.md / review.md
│   │   ├── commit.md / improve.md / memory.md
│   │   ├── new-api.md        # Kotlin REST API 스캐폴딩 (단일·멀티 모듈 감지)
│   │   ├── new-go-api.md     # Go REST API 스캐폴딩 (단일·워크스페이스 감지)
│   │   ├── new-module.md     # 멀티 모듈 서브모듈/패키지/서비스 추가
│   │   ├── new-component.md  # Next.js 컴포넌트
│   │   ├── new-screen.md     # Flutter 화면
│   │   ├── design-api.md     # REST API 설계 → OpenAPI YAML → 코드 생성 연결 (Kotlin·Go)
│   │   └── review-api.md     # REST API 리뷰 — 컨벤션·보안·OpenAPI 문서 (Kotlin·Go)
│   ├── skills/               # 코드 패턴 참조 (agents가 읽음)
│   │   ├── kotlin-patterns.md
│   │   ├── go-patterns.md
│   │   ├── nextjs-patterns.md
│   │   ├── flutter-patterns.md
│   │   ├── api-design-patterns.md  # REST API 설계 패턴 레퍼런스 (Kotlin·Go)
│   │   ├── github-actions-patterns.md
│   │   └── ui-design-impl.md
│   └── templates/            # 스택별 설치 템플릿
│       ├── CLAUDE.{kotlin,go,nextjs,flutter}.md
│       ├── CLAUDE.{kotlin,go,nextjs}-multi.md  # 멀티 모듈 variant
│       ├── settings.{kotlin,go,nextjs,flutter}.json
│       ├── settings.{kotlin,go,nextjs}-multi.json
│       └── memory.md
├── memory/
│   └── MEMORY.md             # 이 레포의 Second Brain
├── bootstrap.sh
├── CHANGELOG.md
└── VERSION                   # 1.4.0
```
