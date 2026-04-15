---
description: 멀티 모듈 프로젝트에 새 서브모듈/패키지/서비스 추가
argument-hint: <모듈명> (예: notification, payment)
---

다음 지시사항에 따라 멀티 모듈 프로젝트에 새 서브모듈을 추가합니다.

**모듈명**: $ARGUMENTS (없으면 사용자에게 물어보세요)

---

## 프로젝트 타입 감지

먼저 현재 프로젝트의 멀티 모듈 타입을 감지합니다:

| 감지 조건 | 타입 |
|----------|------|
| `go.work` 파일 존재 | Go Workspace |
| `turbo.json` 파일 존재 | Next.js Turborepo |
| `settings.gradle.kts`에 `include(` 포함 | Kotlin 멀티 모듈 |

감지된 타입을 사용자에게 보여주고 확인을 받습니다:
> "turbo.json을 감지했습니다. Next.js Turborepo 프로젝트로 진행할까요?"

감지가 불분명하면 사용자에게 직접 물어봅니다.

---

## Kotlin 멀티 모듈일 때

새 Gradle 서브모듈을 생성합니다.

### 1. 서브모듈 디렉토리 구조 생성

```
{moduleName}/
  build.gradle.kts
  src/
    main/
      kotlin/com/{company}/{project}/
        (패키지 구조 — 기존 모듈 참고)
      resources/
    test/
      kotlin/com/{company}/{project}/
```

패키지명은 기존 모듈(`domain/`, `api/`, `infra/`)의 패키지 구조를 확인하고 동일하게 적용합니다.

### 2. build.gradle.kts 생성

의존성은 모듈 용도에 따라 사용자에게 확인합니다:
- 순수 비즈니스 로직 모듈 → `:domain`에 의존
- 외부 연동 모듈 → `:domain` + 외부 라이브러리
- API 모듈 → `:domain`, `:infra`에 의존

```kotlin
// 예시: notification 모듈
dependencies {
    implementation(project(":domain"))
    // 필요한 의존성 추가
}
```

### 3. settings.gradle.kts 업데이트

`settings.gradle.kts`의 `include()` 목록에 새 모듈을 추가합니다:

```kotlin
// 변경 전
include(":api", ":domain", ":infra")

// 변경 후
include(":api", ":domain", ":infra", ":{moduleName}")
```

### 4. 완료 안내

생성 완료 후 사용자에게 안내합니다:
- 생성된 파일 목록
- 다른 모듈에서 이 모듈을 사용하려면 해당 모듈의 `build.gradle.kts`에 `implementation(project(":{moduleName}"))` 추가 필요
- `./gradlew :{moduleName}:build`로 빌드 확인

---

## Next.js (Turborepo)일 때

새 패키지를 생성합니다.

### 1. apps/ 또는 packages/ 선택

사용자에게 묻습니다:
> "새 패키지를 어디에 추가할까요?
> 1. `apps/` — 독립적으로 배포되는 Next.js 앱 또는 서비스
> 2. `packages/` — 여러 앱에서 공유하는 라이브러리"

### 2. 디렉토리 구조 생성

**apps/ 선택 시:**
```
apps/{moduleName}/
  package.json
  tsconfig.json
  src/
    app/               ← Next.js App Router
    components/
    hooks/
    lib/
    stores/
    types/
```

**packages/ 선택 시:**
```
packages/{moduleName}/
  package.json
  tsconfig.json
  src/
    index.ts           ← 공개 API export
```

### 3. package.json 생성

```json
{
  "name": "@project/{moduleName}",
  "version": "0.0.1",
  "exports": {
    ".": "./src/index.ts"
  },
  "scripts": {
    "lint": "eslint src/",
    "test": "jest",
    "build": "tsc"
  },
  "devDependencies": {
    "@project/config": "*"
  }
}
```

### 4. 루트 package.json 워크스페이스 등록 확인

루트 `package.json`의 `workspaces` 필드를 확인합니다. `"apps/*"`, `"packages/*"` 패턴으로 이미 등록되어 있다면 별도 수정 불필요합니다.

### 5. 완료 안내

생성 완료 후 사용자에게 안내합니다:
- 생성된 파일 목록
- 다른 앱에서 이 패키지를 사용하려면 해당 앱의 `package.json` dependencies에 `"@project/{moduleName}": "*"` 추가 후 `npm install` 필요
- `turbo run build --filter=@project/{moduleName}`으로 빌드 확인

---

## Go Workspace일 때

새 서비스 모듈을 생성합니다.

### 1. 서비스 디렉토리 구조 생성

```
services/{moduleName}/
  go.mod
  cmd/
    main.go
  internal/
    domain/
    usecase/
    repository/
    handler/
    middleware/
  migrations/
  db/
    query/
    sqlc/
  mocks/
  testutil/
```

### 2. go.mod 생성

기존 서비스의 모듈 경로 패턴을 확인하고 동일하게 적용합니다:

```
module github.com/{org}/{project}/services/{moduleName}

go 1.23

require (
    github.com/{org}/{project}/pkg/shared v0.0.0
)
```

### 3. cmd/main.go 기본 골격 생성

```go
package main

import (
    "log"
    // 필요한 import 추가
)

func main() {
    log.Println("Starting {moduleName} service...")
    // DI 조립 및 서버 시작
}
```

### 4. go.work 업데이트

루트 `go.work`의 `use` 디렉티브에 새 서비스를 추가합니다:

```
// 변경 전
use (
    ./services/api
    ./pkg/shared
)

// 변경 후
use (
    ./services/api
    ./services/{moduleName}
    ./pkg/shared
)
```

### 5. go.work sync 실행

```bash
go work sync
```

### 6. 완료 안내

생성 완료 후 사용자에게 안내합니다:
- 생성된 파일 목록
- 공유 도메인이 필요하다면 `pkg/shared/` 에 배치하고 `go.mod`에 require 추가
- `cd services/{moduleName} && go build ./...`로 빌드 확인
- `cd services/{moduleName} && golangci-lint run ./...`로 lint 확인 (workspace root에서는 미지원)
