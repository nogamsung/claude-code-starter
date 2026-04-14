---
description: GitHub Actions 워크플로 생성 (CI/CD, 릴리스, Docker 이미지 배포)
argument-hint: "[ci|release|publish|scheduled] [스택명]  예: ci nextjs / release / publish kotlin / publish go / publish nextjs"
---

다음 지시사항에 따라 GitHub Actions 워크플로를 생성해주세요.

**목적**: $ARGUMENTS (없으면 사용자에게 확인)

## 진행 순서

### Step 1 — 컨텍스트 파악
- `CLAUDE.md` 또는 `package.json` / `build.gradle.kts` / `go.mod` / `pubspec.yaml` 확인 → 스택 특정
- `.github/workflows/` 기존 파일 확인 → 중복·충돌 방지

### Step 2 — 패턴 참고
- `.claude/skills/github-actions-patterns.md` 읽기
- 해당 스택 + 목적에 맞는 템플릿 선택

### Step 3 — 워크플로 생성
목적별 파일명 규칙:
- CI (빌드·테스트·린트) → `.github/workflows/ci.yml`
- 릴리스·버전 태깅 → `.github/workflows/release.yml`
- Docker 이미지 배포 (GHCR) → `.github/workflows/publish.yml`
- 정기 실행 → `.github/workflows/scheduled.yml`

**publish 워크플로 요청 시 추가 동작:**
1. 프로젝트 루트에 `Dockerfile`이 없으면 스택에 맞는 멀티스테이지 Dockerfile 먼저 생성
   - Kotlin Spring Boot: JDK builder → JRE runtime
   - Go Gin: golang builder → alpine (정적 바이너리)
   - Next.js: deps → builder → runner (`next.config.js`에 `output: 'standalone'` 추가 안내)
2. Flutter는 Docker 배포 미지원 — 요청 시 안내 후 종료

### Step 4 — 완료 출력
생성된 파일 경로와 아래 항목을 반드시 출력:
1. 설정이 필요한 **GitHub Secrets** 목록
2. 설정이 필요한 **GitHub Environments** 목록 (있으면)
3. 추가로 필요한 외부 설정 안내 (예: npm token 발급, OIDC role 생성)

## 주의사항
- `secrets.*`는 절대 하드코딩 금지
- 모든 `uses:` action은 버전 태그 고정 (`@v4` 이상)
- 스택별 캐시 설정 필수 (skills 파일 Cache Patterns 참고)
- 릴리스 워크플로는 반드시 `push: tags: ['v*.*.*']` 트리거 사용
