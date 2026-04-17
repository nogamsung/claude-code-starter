# Second Brain — Claude Code Starter

> 이 파일은 프로젝트의 기관 기억(institutional memory)입니다.
> 기술 결정, 교훈, 반복되는 패턴을 여기에 누적하세요.
> 규칙은 `CLAUDE.md`, 맥락과 히스토리는 이 파일에 기록합니다.

---

## 2026-04-17: v1.6.0 — 커맨드 전면 재편 + 워크플로 단순화

**카테고리:** 결정

### 배경
커맨드 16개가 평평(flat)하게 흩어져 있어 근육 기억 부담이 크고, `new-*`, `design-*`, `review-*` 접두사가 혼재해 의미가 겹쳤음. 또한 커밋→PR→머지→정리 과정이 수작업이라 피처 완료 후 정리 단계가 누락되는 경우가 있었음.

### 변경 사항

**커맨드 통합 (16 → 11)**
- `new-*` 6개 → `/new` 디스패처 (+ 자동 감지: 이름 패턴·스택으로 서브 생략 가능)
- `design-*` 2개 → `/plan` 으로 흡수 (`/plan api`, `/plan db`)
- `/review-api` → `/review` api 모드로 흡수
- `/improve` → `/rule` 로 개명 (결과물 중심 네이밍)
- `/pr` 신설 (기존 `/new-feature pr` 분리)
- `/merge` 신설 (`gh pr merge` + main 최신화 + 태그 + worktree 정리)
- `/starter` 신설 (install/update 통합 진입점)

**자동 체인 (각 단계 확인)**
- `/commit` → 피처 브랜치면 `/pr` 제안 → 수락 시 `/pr` → `/merge` 제안 → 수락 시 `/merge`
- 완전 자동이 아닌 "연속 확인" 체인 (각 단계에서 y/N 또는 옵션 선택)

**컨텍스트 자동 로드**
- `memory/MEMORY.md` 를 세션 시작 시 자동 참조하도록 CLAUDE.md 템플릿 전체에 지시 추가
- `/memory show` 모드 제거 (자동 로드로 대체)

**bootstrap.sh install/update 통합**
- 기존 `.claude/` 감지 시 백업 없이 전체 교체
- `.claude/.starter-version` 에 버전 기록 (팀 공유용)

### 핵심 원칙
- 디스패처 커맨드는 스택·이름 패턴으로 자동 감지 → 사용자가 타이핑 최소화
- 명시 서브명령은 override 용도로만 사용 (자동 감지가 틀릴 때)
- 체인 제안은 "다음 단계를 물어봄" — 강제하지 않음

**관련 파일:** `.claude/commands/*.md` (11개), `.claude/templates/CLAUDE.*.md`, `bootstrap.sh`, `README.md`, `CHANGELOG.md`

---

## 2026-04-15: v1.4.0 — /design-db DB 설계 자동화 추가

**카테고리:** 결정

### 배경
새 기능 개발 시 DB 스키마를 먼저 설계하고 Migration SQL을 만드는 과정이 수동이어서 패턴 불일치 발생 위험이 있었음.

### 추가된 기능
- `/design-db <도메인 설명>` — MySQL 스키마 설계 → ERD 검토 → Migration SQL 자동 생성
- `db-patterns.md` — MySQL 타입 선택, 공통 컬럼, 인덱스, Flyway/golang-migrate 규칙 레퍼런스

### 설계 원칙
- **설계 → 코드 순서 강제**: `/design-db` 완료 후 `/new-api` 실행 유도
- **스택별 분기**: Kotlin은 Flyway(`V{N}__*.sql`), Go는 golang-migrate(`{000000}_*.up/down.sql`)
- **nextjs/flutter 제외**: DB migration 커맨드는 백엔드 스택에서만 유지

### 워크플로
```
/design-db → Migration SQL 생성 → /new-api → Entity/Repository 코드 생성
```

**관련 파일:** `.claude/commands/design-db.md`, `.claude/skills/db-patterns.md`

---

## 2026-04-15: v1.5.0 — REST API 설계 자동화 추가

**카테고리:** 결정

### 추가된 파일
- `api-designer` agent: REST API 설계 전문 에이전트 (OpenAPI 3.0 YAML 초안, BearerAuth/Pagination/Error 패턴)
- `api-design-patterns.md` skill: URL 구조·응답 형식·RFC 7807 에러·인증·스택별 어노테이션 패턴 레퍼런스
- `/design-api` command: 5단계 인터랙티브 설계 → `/new-api`(Kotlin) / `/new-go-api`(Go) 연결
- `/review-api` command: REST 컨벤션·보안·OpenAPI 문서 완성도 리뷰 (심각도 3단계)

### 설계 원칙
- **백엔드 전용**: `/init nextjs`, `/init flutter` 시 자동 제거 대상
- **플로우 연결**: `/design-api` → 설계 확인 → `/new-api` or `/new-go-api` 구현으로 이어짐
- **`/commit` 문서 자동화**: feat/fix 커밋 시 CHANGELOG·README·memory 자동 업데이트 단계 추가

### 충돌 해결 기록
`feature/api-design-settings` 브랜치가 `feature/db-design`(PR#2) merge 후 `dev`와 충돌.
`init.md`의 스택별 유지/제거 목록이 양쪽에서 수정됨 → rebase 후 두 변경사항 병합으로 해결.

**관련 파일:** `.claude/agents/api-designer.md`, `.claude/commands/design-api.md`, `.claude/commands/review-api.md`, `.claude/skills/api-design-patterns.md`, `.claude/commands/commit.md`

---

## 2026-04-15: Git 브랜치 네이밍 — dev/* 충돌 교훈

**카테고리:** 교훈

### 문제
`dev` 브랜치(통합)와 `dev/feature-*` 브랜치(피처)를 동시에 운용하려 했으나 Git이 거부.

### 원인
Git refs는 파일시스템 경로처럼 동작함. `refs/heads/dev`(파일)와 `refs/heads/dev/feature-login`(디렉토리)은 같은 경로에 공존 불가.
`fatal: cannot lock ref 'refs/heads/dev/feature-db-design': 'refs/heads/dev' exists`

### 해결
피처 브랜치 prefix를 `dev/` 에서 타입별 독립 prefix로 변경:
- `feature/{name}` · `fix/{name}` · `hotfix/{name}` · `refactor/{name}` · `chore/{name}`

통합 브랜치(`dev`)는 그대로 유지.

### 수정된 파일
- `new-feature.md` — 브랜치 생성 명령 및 예시 수정
- `CLAUDE.*.md` 7개 — 브랜치 전략 테이블 수정
- `README.md` — 브랜치 전략 다이어그램 수정

**관련 파일:** `.claude/commands/new-feature.md`, `.claude/templates/CLAUDE.*.md`

---

## 2026-04-15: v1.3.0 — 멀티 모듈 지원 추가

**카테고리:** 결정

### 배경
단일 모듈 구조(패키지 기반 레이어)만 지원하던 것에서 물리적 경계가 있는 멀티 모듈 구조 추가.
Kotlin Gradle 멀티 모듈 / Next.js Turborepo / Go Workspace 3가지 variant 도입.

### 설계 원칙
- **에이전트 신규 생성 없음** — CLAUDE.md 템플릿이 구조를 설명하면 기존 generator/modifier/tester가 자동으로 해당 구조를 따름
- **하위 호환** — 기존 단일 모듈 `/init kotlin|nextjs|go|flutter` 동작 변경 없음
- **자동 감지** — `go.work` / `turbo.json` / `settings.gradle.kts` include 여부로 단일/멀티 모듈 자동 분기

### 추가된 파일
- 템플릿 6개: `CLAUDE.{kotlin,nextjs,go}-multi.md`, `settings.{kotlin,nextjs,go}-multi.json`
- 커맨드 1개: `/new-module` (서브모듈/패키지/서비스 추가)
- 커맨드 수정 2개: `/init`, `/new-api` (멀티 모듈 분기 추가)
- Skills 수정 3개: 각 스택 patterns 파일에 멀티 모듈 패턴 섹션 추가

### 각 스택 멀티 모듈 구조
- **Kotlin**: `:api`(presentation) → `:domain`(entity+service) ← `:infra`(repository)
- **Next.js**: `apps/web` + `packages/{ui,lib,config}` (Turborepo)
- **Go**: `services/{api,worker}` + `pkg/shared` (go.work)

**관련 파일:** `.claude/templates/CLAUDE.*-multi.md`, `.claude/commands/new-module.md`

---

## 2026-04-14: 프로젝트 초기 구성

**카테고리:** 결정

이 레포는 Claude Code를 새 프로젝트에 빠르게 세팅하기 위한 스타터입니다.
Kotlin Spring Boot, Next.js, Flutter 세 스택을 지원하며 `/init <stack>` 한 번으로 불필요한 파일을 제거하고 CLAUDE.md + settings.json을 설치합니다.

**핵심 설계 원칙:**
- 스택별 전문 subagent 분리 (generator / modifier / tester)
- `/improve`로 AI 실수를 CLAUDE.md 규칙에 누적 → 피드백 루프
- `memory/MEMORY.md`로 팀 지식 축적 → Second Brain

**관련 파일:** `.claude/commands/init.md`, `.claude/templates/`

---

## 2026-04-14: Second Brain 시스템 도입

**카테고리:** 결정

`memory/MEMORY.md`를 Second Brain으로 사용하기로 결정.

**개인 메모리 vs 팀 메모리 구분:**
- 개인 메모리: `~/.claude/projects/<project>/memory/` — 세션 간 AI 자동 학습 내용
- 팀 메모리: `memory/MEMORY.md` (이 파일) — git으로 공유되는 팀 지식

**`/memory` 커맨드**로 조회·추가·검색 가능.
파생 프로젝트는 `/init` 실행 시 `memory/MEMORY.md` 템플릿이 자동 생성됨.

---

## 2026-04-14: /init 스택 자동 감지 및 신규/기존 분기 추가

**카테고리:** 결정

`/init` 인수 생략 시 프로젝트 파일로 스택 자동 감지:
- `build.gradle.kts` / `pom.xml` → kotlin
- `package.json` (next 의존성) → nextjs
- `pubspec.yaml` → flutter

신규 프로젝트(빈 디렉토리)와 기존 프로젝트(코드 있음) 분기 처리:
- 기존 프로젝트는 CLAUDE.md 덮어쓰기 전 병합 여부 확인

**관련 파일:** `.claude/commands/init.md`

---

## 2026-04-14: /init 시 memory 인터뷰 자동 기록

**카테고리:** 결정

`/init`은 새 프로젝트 시작이므로 기존 memory 유무와 관계없이 항상 초기화.
초기화 후 4가지 질문 (목적, 핵심 기능, 제약사항, 외부 연동) → 자동 기록.

**이유:** 프로젝트 초기 컨텍스트가 이후 세션에서도 유지되도록.

---

## 2026-04-14: settings.json 템플릿 permissions.allow 추가

**카테고리:** 결정

기존 템플릿은 `permissions.allow`가 비어 있어 모든 Bash 명령마다 승인 요청 발생.
스택별 허용 명령어를 명시적으로 등록.

- Kotlin: `./gradlew`, `./mvnw`, `docker`, `docker-compose`, `git` + 파일 조작
- Next.js: `npm`, `npx`, `node`, `git` + 파일 조작
- Flutter: `flutter`, `dart`, `git` + 파일 조작

**관련 파일:** `.claude/templates/settings.{kotlin,nextjs,flutter}.json`

---

## 2026-04-14: Pre-push 커버리지 게이트 도입

**카테고리:** 결정

`git push` 전 라인 커버리지 90% 이상 강제.
`.claude/hooks/pre-push.sh`가 settings.json PreToolUse/Bash 훅으로 실행됨.

- Kotlin → `./gradlew test jacocoTestReport` → `build/reports/jacoco/test/jacocoTestReport.xml`
- Next.js → `npx jest --coverage --coverageReporters=json-summary` → `coverage/coverage-summary.json`
- Flutter → `flutter test --coverage` → `coverage/lcov.info`

**⚠️ 교훈:** Kotlin에서 Jacoco가 `build.gradle.kts`에 설정되지 않으면 게이트 자체가 실패함.
필수 설정:
```kotlin
plugins { jacoco }
tasks.jacocoTestReport { dependsOn(tasks.test); reports { xml.required = true } }
tasks.test { finalizedBy(tasks.jacocoTestReport) }
```

**관련 파일:** `.claude/hooks/pre-push.sh`, `.claude/templates/settings.*.json`, `CLAUDE.*.md`

---

## 2026-04-14: 스택별 플러그인 선정

**카테고리:** 결정

`anthropics/claude-plugins-official` 전체 목록 직접 조회 후 선정.

**공통 (전 스택):** `github`, `context7`, `feature-dev`, `code-review`, `pr-review-toolkit`, `security-guidance`, `hookify`, `commit-commands`, `claude-md-management`

**Kotlin 추가:** `kotlin-lsp`
**Next.js 추가:** `typescript-lsp`, `frontend-design`, `playwright`
**Flutter:** 공통만 (공식 Dart/Flutter LSP 없음)

**제외 판단:**
- `jdtls-lsp`: Java 전용, Kotlin 미지원 확인
- `superpowers`, `atomic-agents`: 공식 레포에 없는 구 플러그인 (이전 템플릿 잔재)
- `greptile`: 외부 유료 서비스 의존

**관련 파일:** `.claude/templates/settings.{kotlin,nextjs,flutter}.json`

---

## 2026-04-14: ui-designer agent 추가

**카테고리:** 결정

DESIGN.md 기반 디자인 시스템 에이전트. awesome-design-md(VoltAgent) 66개 브랜드 참조 가능.

**Flutter 포함 결정 근거:**
- 컬러·타이포·스페이싱·엘리베이션 토큰 → Flutter ThemeData 변환 가능 ✅
- CSS/Tailwind 컴포넌트 스펙 → Flutter 직접 적용 불가 ❌
- 결론: 포함하되 디자인 토큰 추출 전담으로 제한. CSS 스펙 자동 무시.

**Kotlin:** 백엔드 전용이면 불필요. 풀스택이면 유지.

**생성 파일 (Flutter 모드):** `lib/core/theme/app_theme.dart`, `app_colors.dart`, `app_text_styles.dart`, `app_spacing.dart`, `app_radius.dart`

**관련 파일:** `.claude/agents/ui-designer.md`

---

## 2026-04-14: GitHub 레포 이름 변경

**카테고리:** 참고

- **구 URL:** https://github.com/nogamsung/claude
- **현재 URL:** https://github.com/nogamsung/claude-code-starter
- **bootstrap.sh 및 README URL 수정 완료**

git push 시 "This repository moved" 경고가 발생했으나 리다이렉트로 push는 성공.
이후 `git remote set-url origin https://github.com/nogamsung/claude-code-starter.git` 실행.

---

## 2026-04-14: v1.2.0 — 대규모 기능 추가

**카테고리:** 결정

### Git Worktree 병렬 작업 전략
- 모든 파생 프로젝트에 `.worktrees/feature-{n}` 구조 강제
- `superpowers:using-git-worktrees` 스킬 원칙 적용:
  - `.worktrees/` gitignore 미등록 시 즉시 추가·커밋 (안전 검증 필수)
  - worktree 생성 후 스택별 의존성 자동 설치
- `/new-feature` 커맨드를 worktree 기반으로 전면 개편

### 브랜치 전략
- `main ← dev ← dev/feature-{number}` 3단계 구조
- `main` / `dev` 모두 PR + CI 통과 보호
- `/init` 실행 시 `dev` 브랜치 자동 생성

### Docker → GitHub Container Registry 배포
- Kotlin/Go/Next.js 스택별 멀티스테이지 Dockerfile 패턴 확립
- Flutter는 Docker 배포 미지원으로 명시 제외
- `publish.yml`: semver 태그 자동 생성 + 멀티플랫폼(`linux/amd64,linux/arm64`)

### Swagger 필수화
- Kotlin: SpringDoc OpenAPI — Controller에 `@Tag/@Operation/@ApiResponse`, DTO에 `@Schema` 필수
- Go: swaggo/swag — Handler에 godoc 주석 필수, DTO에 `example` 태그 필수

### 쿼리 레이어 표준화
- Kotlin: JPA + QueryDSL (동적 쿼리) + jOOQ (복잡 집계, 선택)
- Go: GORM (단순 CRUD) + sqlc (동적/페이징) + golangci-lint 필수

**관련 파일:** 대부분의 `.claude/**/*.md`, `CHANGELOG.md`, `VERSION`

---

## 2026-04-14: bootstrap.sh 도입

**카테고리:** 결정

새 프로젝트에서 `.claude` 폴더를 curl 한 줄로 설치:
```bash
curl -fsSL https://raw.githubusercontent.com/nogamsung/claude-code-starter/main/bootstrap.sh | bash
```

sparse checkout으로 `.claude` 폴더만 가져오는 방식 채택 (전체 클론 대비 빠름).

**관련 파일:** `bootstrap.sh`
