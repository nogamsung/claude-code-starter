# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> **릴리즈 규칙:** VERSION 파일을 올린 뒤 반드시 git 태그를 생성하고 푸시한다.
> ```bash
> git tag v$(cat VERSION) && git push origin v$(cat VERSION)
> ```

---

## [1.7.0] - 2026-04-17

### Added

**모노레포 모드** — 한 저장소에서 backend + frontend + mobile 공존 지원.

- `/init` 이 루트의 `backend/`·`frontend/`·`mobile/` (별칭 `api`/`server`/`web`/`client`/`app`) 디렉토리를 스캔해 모노레포 자동 감지
- `.claude/stacks.json` — 활성 스택 매니페스트 (단일 진실의 원천)
- 루트 `CLAUDE.md` 는 인덱스, 각 스택 디렉토리에 역할별 `CLAUDE.md` 자동 배치
- `.claude/settings.json` 은 union permissions + 경로 가드 hooks (PostToolUse 가 편집 파일 경로로 스택 lookup)
- `.claude/hooks/pre-push.sh` 가 활성 스택 전체 순차 커버리지 검증 (한 스택 실패 시 전체 차단)
- Go 스택 커버리지 검증 추가 (`go test -coverprofile`)
- 역할 prefix 지원 — `/new backend api User`, `/new frontend component Button`, `/new mobile screen Login`
- `/plan` 도 동일한 역할 prefix 파싱 (`/plan backend api User`)
- 중첩 멀티모듈 지원 — `backend/` 내부가 `kotlin-multi`/`go-multi` 가능, `frontend/` 가 `nextjs-multi` (Turborepo) 가능

**`/planner` 커맨드 + `planner` agent** — 기획자 에이전트 추가.

- `/planner <기능>` — 사용자 요청을 받아 PRD + 역할별 구현 프롬프트 생성
- `planner` agent — Read/Write/Grep/Glob/Bash 로 코드베이스 맥락 스캔 후 PRD 작성 (코드는 작성하지 않음)
- `.claude/templates/prd.md` — 엔지니어용 한국어 PRD 템플릿 (12 섹션)
- `.claude/templates/role-prompt.md` — 역할별 구현 프롬프트 템플릿 (체크리스트 + 계약 + 실행 지시)
- **Agent Teams 옵션** — 생성된 프롬프트를 병렬 agent 호출로 즉시 실행 가능
  - `--teams` 플래그 → 바로 병렬 실행
  - `--output-only` 플래그 → 파일만 생성, 수동 실행
  - 플래그 없음 → 매번 사용자에게 선택 질문
  - 안전장치: teams 실행 전 한 번 더 확인

### Changed

- `pre-push.sh` 를 함수화하고 `.claude/stacks.json` 분기 추가 — 단일 스택 모드는 기존 동작 그대로
- 각 스택 `CLAUDE.md` 템플릿에 `/planner` 커맨드 행 추가
- `/init` 단일 스택 모드의 유지 대상에 `planner` agent + `prd`/`role-prompt` 템플릿 포함

### 마이그레이션 안내

- **단일 스택 사용자**: `.claude/stacks.json` 이 없으면 모든 훅·커맨드가 기존 동작으로 폴백 — 파괴적 영향 없음
- **모노레포 신규 설치**: `/starter update` → `/init` 재실행 시 자동 감지
- 기존 `/plan`, `/new` 사용법 그대로 유지

---

## [1.6.0] - 2026-04-17

### ⚠️ Breaking Changes

**커맨드 16개 → 11개로 재편 + 워크플로 단순화.** 기존 커맨드 이름은 더 이상 작동하지 않습니다.
`/starter update` 또는 `bootstrap.sh` 재실행으로 최신 커맨드를 받으세요.

| 이전 커맨드 | 새 커맨드 |
|------------|----------|
| `/new-api <Resource>` | `/new api <Resource>` |
| `/new-component <Name>` | `/new component <Name>` |
| `/new-screen <Name>` | `/new screen <Name>` |
| `/new-module <Name>` | `/new module <Name>` |
| `/new-workflow <Purpose>` | `/new workflow <Purpose>` |
| `/new-feature <type-name>` | `/new worktree <type-name>` |
| `/new-feature pr` | `/pr` + `/merge` (PR 생성과 머지 정리 분리) |
| `/design-api <Resource>` | `/plan api <Resource>` |
| `/design-db <도메인>` | `/plan db <도메인>` |
| `/review-api [대상]` | `/review api [대상]` |
| `/improve <설명>` | `/rule <설명>` |
| `/memory show` / `/memory` (조회) | 세션 시작 시 자동 로드 (호출 불필요) |

### Added

- **`/starter [check\|update]` 커맨드** — 스타터 버전 확인 / 재설치 (신규 install + update 통합 진입점)
- **`/pr` 커맨드** — 현재 브랜치 PR 생성. 완료 후 `/merge` 자동 제안. 기존 `/new-feature pr` 에서 분리
- **`/merge [auto]` 커맨드** — `gh pr merge` 로 GitHub 머지 실행 + main 최신화 + 버전 태그 + worktree 정리. `auto` 모드는 체크 통과 시 자동 머지 큐잉
- **`/commit` → `/pr` → `/merge` 자동 체인** — 각 단계가 다음을 제안하여 피처 브랜치에서 커밋부터 머지·정리까지 한 흐름으로 진행 (각 단계 확인 필요)
- **`/new` 디스패처 + 자동 감지** — api / component / screen / module / workflow / worktree 6개 서브명령 통합 + 스택·이름 패턴 기반 **서브명령 생략 가능** (`/new User` → Go/Kotlin은 api, Next.js는 component, Flutter는 screen 자동 분기 / `/new feature-login` → worktree / `/new publish kotlin` → workflow). 명시 서브명령은 override용으로 유지.
- **`/plan` 디스패처 확장** — 기존 범용 계획 + `api` / `db` 서브명령 흡수 (구 `/design-api`, `/design-db`)
- **`/review` api 모드** — 기존 `/review-api` 를 `/review` 내부 서브모드로 흡수
- **`/commit` 후 자동 PR 제안** — 피처 브랜치 감지 시 `/pr` 실행 여부 자동 제안
- **`memory/MEMORY.md` 자동 로드** — CLAUDE.md 템플릿에 세션 시작 시 자동 참조 지시 추가
- **`.claude/.starter-version`** — 설치된 스타터 버전 추적 파일 (팀 공유 대상)

### Changed

- `/rule` (구 `/improve`) — 네이밍을 "규칙 등록" 결과물 중심으로 개명
- `/memory` — `show` 모드 제거, 인수 없이 호출 시 도움말만 출력 (자동 로드로 대체됨)
- `bootstrap.sh` — 기존 `.claude/` 자동 감지, install/update 모드 분기, 확인 프롬프트 제거 (무조건 백업 없이 전체 교체), `.starter-version` 자동 기록
- `/init` — 스택별 제거 대상 목록 단일 표로 축소 (기존 7개 반복 섹션 → 표 1개). 커맨드는 전부 유지 (디스패처가 내부 분기)
- 전체 커맨드 내부 구조를 `상단 1줄 요약 → Step N → 출력 예시 → 주의사항` 포맷으로 통일, 중복·과한 설명 축소

### Removed

- 옛 커맨드 파일 11개: `new-api.md`, `new-component.md`, `new-screen.md`, `new-module.md`, `new-workflow.md`, `new-feature.md`, `design-api.md`, `design-db.md`, `design.md`, `review-api.md`, `improve.md`

---

## [1.5.3] - 2026-04-15

### Changed

- `/commit` — main 직접 커밋 금지, 항상 feature 브랜치에서 PR을 통해 머지
- `/new-feature pr` — PR 머지 후 정리 단계에 `git pull main` + 태그 생성 + 태그 푸시 추가

---

## [1.5.2] - 2026-04-15

### Changed

- `/commit` — 브랜치별 git 자동화 분기: `main`은 push+태그+태그푸시, feature는 push만

---

## [1.5.1] - 2026-04-15

### Changed

- `/commit` — 모든 커밋 타입에서 CHANGELOG 업데이트 필수화, Unreleased 방식 제거 (항상 버전 태그 발행)
- `/new-feature` — 베이스 브랜치 자동 감지 (`dev` 브랜치 있으면 `dev`, 없으면 `main`)
- `/init` — 브랜치 전략 선택 옵션 추가 (A. main+dev 기본값 / B. main only)

---

## [1.5.0] - 2026-04-15

### Added

- **`/design-api` 커맨드** — 코드 작성 전 REST API를 설계하는 인터랙티브 워크플로우
  - 스택 자동 감지 (`build.gradle.kts` → Kotlin, `go.mod` → Go)
  - 도메인 파악 → 엔드포인트 목록 → Request/Response 스키마 → OpenAPI 3.0 YAML 초안 5단계
  - 설계 완료 후 `/new-api`로 자동 연결
  - 백엔드 전용 (`/init nextjs`, `flutter` 시 제거 대상)
- **`/review-api` 커맨드** — 기존 REST API 코드 리뷰
  - RESTful 컨벤션 (URL 구조, HTTP 메서드, 상태코드) 체크
  - 보안 취약점 (인증 누락, 민감 데이터 노출, 입력값 검증 누락) 체크
  - OpenAPI 문서 완성도 체크 (SpringDoc `@Operation`/`@ApiResponse`, swag godoc 주석)
  - 높음/중간/낮음 심각도로 구분한 리뷰 결과 출력
  - 백엔드 전용 (`/init nextjs`, `flutter` 시 제거 대상)
- **`api-designer` agent** — REST API 설계 전문 에이전트
  - RESTful 컨벤션, 인증/인가 패턴, 페이지네이션, 에러 응답 표준화 전담
  - OpenAPI 3.0 YAML 템플릿 내장 (BearerAuth, PagedResponse, ErrorResponse 포함)
  - 백엔드 전용 (`/init nextjs`, `flutter` 시 제거 대상)
- **`api-design-patterns.md` 스킬** — REST API 설계 패턴 레퍼런스
  - URL 구조 원칙 (복수형 명사, 중첩 리소스, 액션 엔드포인트)
  - 표준 응답 형식 (단건·목록·커서 페이지네이션 envelope)
  - RFC 7807 Problem Details 에러 응답 패턴
  - 인증 스킴별 OpenAPI securityScheme 정의
  - 스택별 어노테이션 패턴 (SpringDoc vs swag godoc)
  - `/design-api` → `/new-api` 연결 플로우 다이어그램

### Changed

- `/commit` — 작업 완료 시 CHANGELOG·VERSION·memory 자동 업데이트 단계 추가 (문서 자동화)
- `/init` — kotlin/go 스택은 api 관련 파일 유지, nextjs/flutter 스택은 제거 목록에 추가

## [1.4.1] - 2026-04-15

### Changed

- **`/new-api` 통합** — `/new-go-api` 커맨드를 `/new-api`로 통합
  - `go.mod` 존재 시 Go Gin 스캐폴딩 자동 실행
  - `settings.gradle.kts` / `build.gradle.kts` 존재 시 Spring Boot 스캐폴딩 자동 실행
  - 스택 감지 실패 시 사용자에게 선택 요청

### Removed

- **`/new-go-api` 커맨드** — `/new-api`로 통합되어 제거

---

## [1.4.0] - 2026-04-15

### Added

- **`/design-db` 커맨드** — MySQL 스키마 설계 → Migration SQL 자동 생성
  - 스택 자동 감지 (`build.gradle.kts` → Flyway, `go.mod` → golang-migrate)
  - 도메인 설명 → ERD 텍스트 출력 → 검토 확인 → Migration SQL 파일 생성 5단계 자동화
  - 공통 컬럼(`id`, `created_at`, `updated_at`), FK 인덱스, `ENGINE=InnoDB utf8mb4` 자동 포함
  - 기존 migration 파일 번호 감지 후 다음 번호로 자동 생성
  - 생성 완료 후 `/new-api` / `/new-go-api` 연계 안내
- **`db-patterns.md` 스킬** — MySQL 설계 패턴 레퍼런스
  - 데이터 타입 선택 기준 (`DECIMAL` for 금액, `DATETIME(6)` for timestamps, `BIGINT UNSIGNED` for PK)
  - 공통 컬럼 패턴, 인덱스 전략, Soft Delete 패턴, FK 제약 옵션 가이드
  - Flyway 네이밍 컨벤션 (`V{N}__{description}.sql`)
  - golang-migrate 네이밍 컨벤션 (`{000000}_{description}.up/down.sql`)

### Changed

- `/new-api`, `/new-go-api` — DB 설계 선행 권장 안내(`/design-db`) 추가
- `CLAUDE.kotlin.md`, `CLAUDE.kotlin-multi.md`, `CLAUDE.go.md`, `CLAUDE.go-multi.md` — Commands 표에 `/design-db` 추가
- `/init` — kotlin/go 스택은 `design-db.md` 유지, nextjs/flutter 스택은 제거 목록에 추가

### Fixed

- **브랜치 네이밍 Git refs 충돌 수정** — `dev` 브랜치와 `dev/feature-*` 브랜치 동시 존재 불가 문제
  - 피처 브랜치 prefix를 `dev/` → `feature/`, `fix/`, `hotfix/` 등 독립 prefix로 변경
  - `new-feature.md`, `CLAUDE.*.md` 7개, `README.md` 일괄 수정

---

## [1.3.0] - 2026-04-15

### Added

- **멀티 모듈 프로젝트 지원** — Kotlin, Next.js, Go 3개 스택에 멀티 모듈 variant 추가
  - `/init kotlin-multi` — Gradle 멀티 모듈 (`api` / `domain` / `infra` 서브모듈, 모듈간 의존 규칙 포함)
  - `/init nextjs-multi` — Turborepo 멀티 패키지 (`apps/web`, `packages/ui`, `packages/lib`, `packages/config`)
  - `/init go-multi` — Go Workspace (`services/api`, `services/worker`, `pkg/shared`, `go.work`)
- **`/new-module` 커맨드** — 멀티 모듈 프로젝트에 새 서브모듈/패키지/서비스 추가
  - 프로젝트 타입 자동 감지 (`go.work` / `turbo.json` / `settings.gradle.kts` include 여부)
  - Kotlin: Gradle 서브모듈 생성 + `settings.gradle.kts` 자동 등록
  - Next.js: Turborepo 패키지 생성 (`apps/` 또는 `packages/` 선택)
  - Go: 서비스 모듈 생성 + `go.work` use 자동 등록
- **멀티 모듈 인식 커맨드 업데이트**
  - `/new-api`: `settings.gradle.kts` include 감지 시 파일을 각 모듈 경로로 분기 (Entity/Service → `:domain`, Repository Impl → `:infra`, Controller/DTO → `:api`)
  - `/new-go-api`: `go.work` 감지 시 대상 서비스 선택 후 해당 경로에 스캐폴딩
- **멀티 모듈 패턴 추가** — 스택별 skills 파일 확장
  - `kotlin-patterns.md`: `settings.gradle.kts`, 모듈별 `build.gradle.kts`, 모듈간 의존 표, 테스트 실행 커맨드
  - `nextjs-patterns.md`: `turbo.json`, workspace `package.json`, 패키지 의존 규칙, filter 실행 패턴
  - `go-patterns.md`: `go.work`, `go.mod` 멀티 서비스 패턴, 공유 도메인 패턴, workspace 빌드/테스트

### Changed

- `/init` — `kotlin-multi` / `nextjs-multi` / `go-multi` 옵션 추가, 자동 감지 로직 확장 (`go.work`, `turbo.json`, `settings.gradle.kts` include 감지)

---

## [1.2.0] - 2026-04-14

### Added

- **Git Worktree 병렬 작업 지원** — 모든 파생 프로젝트에 적용
  - `/new-feature` 커맨드 전면 개편: branch 생성 → worktree 생성 (`git worktree add .worktrees/feature-{n}`)
  - 스택별 의존성 자동 설치 (Go: `go mod download`, Node.js: `npm ci`, Gradle: `dependencies`, Flutter: `flutter pub get`)
  - `/init` 에 `.worktrees/` gitignore 자동 등록 단계 추가
  - 4개 CLAUDE 템플릿에 `Git 브랜치 전략 & 병렬 작업 (Worktree)` 섹션 추가
- **GitHub Actions — Docker 이미지 배포 (GitHub Container Registry)**
  - 스택별 멀티스테이지 Dockerfile (Kotlin: JDK builder→JRE, Go: golang→alpine, Next.js: deps→builder→runner)
  - 스택별 완성형 `publish.yml` — semver 태그 자동 생성 + `linux/amd64,linux/arm64` 멀티플랫폼
  - dev 브랜치 push → `:dev` 태그 스테이징 자동 배포 패턴
  - Flutter 제외 명시
- **백엔드 Swagger 문서화 필수 적용**
  - Kotlin: SpringDoc OpenAPI (`@Tag`, `@Operation`, `@ApiResponse`, `@Schema`) 패턴 + SwaggerConfig Bean
  - Go: swaggo/swag (`@Summary`, `@Tags`, `@Router`, `@Success`, `@Failure`, `example` 태그) 패턴
- **main / dev 브랜치 전략 확립**
  - `main ← dev ← dev/feature-{number}` 구조
  - `/init` 에서 `dev` 브랜치 자동 생성 + GitHub 브랜치 보호 규칙 안내
  - `/new-feature pr` 모드: `base: dev` PR 자동 생성
- **GitHub Actions 설계 에이전트** (`github-actions-designer`)
  - 스택별 CI 템플릿 (Next.js, Spring Boot, Go, Flutter)
  - 릴리스 자동화 (VERSION 파일 기반, semantic-release)
  - `/new-workflow` 슬래시 커맨드
- **Kotlin QueryDSL 필수 스택 지정**
  - `JpaRepository + RepositoryCustom + RepositoryImpl` 3세트 패턴
  - jOOQ 선택 사용 안내
- **Go sqlc + golangci-lint 필수 스택 지정**
  - 동적 쿼리 → sqlc, 단순 CRUD → GORM 기준 정립
  - `.golangci.yml` 기본 설정 패턴
- **커맨드/에이전트 전체 동기화**
  - `new-api.md`: QueryDSL 3세트 + SpringDoc 반영
  - `new-go-api.md`: sqlc + swaggo 반영
  - `kotlin-modifier.md` / `go-modifier.md`: 수정 체크리스트 업데이트
  - `code-reviewer.md`: Go 스택 추가 + 스택별 체크리스트 (SpringDoc/swaggo/QueryDSL/sqlc)

---

## [1.1.0] - 2026-04-14

### Added

- **Go Gin 스택 지원** — 4번째 지원 스택 추가
  - `go-generator` / `go-modifier` / `go-tester` 에이전트
  - `/new-go-api` 커맨드 — Handler / UseCase / Repository / Domain 스캐폴딩
  - `CLAUDE.go.md` 템플릿 — Clean Architecture 규칙, GORM, golang-migrate
  - `settings.go.json` 템플릿 — 공통 플러그인 + go vet / go test 훅
  - `/init go` 지원 (`go.mod` 자동 감지 포함)
  - 커버리지 게이트 Go 지원 — `go test -coverprofile` 기반 90% 차단
- **Skills 시스템** (`.claude/skills/`) — 스택별 코드 패턴을 agents에서 분리
  - `kotlin-patterns.md`, `nextjs-patterns.md`, `flutter-patterns.md`, `go-patterns.md`, `ui-design-impl.md`
  - agents 파일 경량화 (역할·워크플로 선언만 유지, 패턴은 skills 참조)

---

## [1.0.0] - 2026-04-14

### Added

- **bootstrap.sh** — curl 한 줄로 `.claude/` 폴더 설치 (sparse checkout)
- **`/init` 커맨드** — 스택 자동 감지 (Kotlin / Next.js / Flutter), 기존 프로젝트 분기, memory 초기화 + 프로젝트 인터뷰
- **`/memory` 커맨드** — Second Brain 조회·추가·검색, 6가지 자동 기록 트리거
- **`/improve` 커맨드** — AI 실수를 CLAUDE.md 규칙으로 누적
- **커버리지 게이트** — git push 시 90% 미만이면 차단
  - Kotlin: Jacoco (`jacocoTestReport`)
  - Next.js: Jest (`--coverage --coverageReporters=json-summary`)
  - Flutter: `flutter test --coverage`
- **스택별 CLAUDE.md 템플릿** — Kotlin / Next.js / Flutter
- **스택별 settings.json 템플릿** — `enabledPlugins`, `permissions.allow`, PreToolUse 훅
- **`ui-designer` 에이전트** — DESIGN.md 기반 디자인 시스템
  - Next.js: tailwind.config.ts + globals.css + shadcn/ui 테마 연동
  - Flutter: 디자인 토큰만 추출 (`lib/core/theme/`)
- **스택별 전문 subagent** — generator / modifier / tester 분리
- **플러그인 세팅** — 스택별 최적 Claude Code 플러그인 선정
  - 공통: github, context7, feature-dev, code-review, pr-review-toolkit, security-guidance, hookify, commit-commands, claude-md-management
  - Kotlin 추가: kotlin-lsp
  - Next.js 추가: typescript-lsp, frontend-design, playwright
- **`memory/MEMORY.md`** — 팀 Second Brain (git 커밋됨)

### Project Structure

```
claude-code-starter/
├── .claude/
│   ├── agents/          # ui-designer, 스택별 subagent
│   ├── commands/        # /init, /memory, /improve, /plan, /commit
│   ├── hooks/           # pre-push.sh (커버리지 게이트)
│   └── templates/       # CLAUDE.*.md, settings.*.json
├── memory/
│   └── MEMORY.md        # 팀 Second Brain
├── bootstrap.sh
├── CHANGELOG.md
├── README.md
└── VERSION
```

---

## Version History

| Version | Date       | Summary               |
|---------|------------|-----------------------|
| 1.5.3   | 2026-04-15 | PR 통한 main 머지 강제, PR 머지 후 태그 자동화 |
| 1.5.2   | 2026-04-15 | /commit 브랜치별 git 자동화 (main: push+태그, feature: push만) |
| 1.5.1   | 2026-04-15 | 문서 필수화, 브랜치 전략 자동 감지, /init 브랜치 옵션 추가 |
| 1.5.0   | 2026-04-15 | /design-api, /review-api 커맨드, api-designer 에이전트 추가 |
| 1.4.0   | 2026-04-15 | /design-db 커맨드 추가, 브랜치 전략 수정 |
| 1.3.0   | 2026-04-15 | 멀티 모듈 지원 (Kotlin Gradle / Next.js Turborepo / Go Workspace) |
| 1.2.0   | 2026-04-14 | Worktree 병렬 작업, Docker GHCR 배포, Swagger, 브랜치 전략, GitHub Actions |
| 1.1.0   | 2026-04-14 | Go Gin 스택 추가, Skills 시스템 도입 |
| 1.0.0   | 2026-04-14 | 초기 릴리즈            |
