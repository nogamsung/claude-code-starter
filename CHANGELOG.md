# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
| 1.1.0   | 2026-04-14 | Go Gin 스택 추가, Skills 시스템 도입 |
| 1.0.0   | 2026-04-14 | 초기 릴리즈            |
