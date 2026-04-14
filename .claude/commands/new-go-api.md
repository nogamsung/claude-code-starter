---
description: Go Gin REST API 스캐폴딩 생성 (Domain, Repository, UseCase, Handler, Migration)
argument-hint: <리소스명> (예: User, Product, Order)
---

다음 지시사항에 따라 Go Gin REST API를 생성해주세요.

**리소스명**: $ARGUMENTS (없으면 사용자에게 물어보세요)

## 생성할 파일

현재 프로젝트의 `go.mod` 모듈명과 디렉터리 구조를 먼저 파악한 후, 아래 파일들을 생성하세요.

### 1. Domain Entity + Errors
- `internal/domain/{resource}.go` — 도메인 Entity struct
- `internal/domain/errors.go` — 없으면 생성, 있으면 확인

### 2. Repository Interface
- `internal/domain/{resource}_repository.go` — CRUD 인터페이스

### 3. GORM Repository Implementation
- `internal/repository/{resource}_repository.go` — FindByID, FindAll, Create, Update, Delete

### 4. UseCase
- `internal/usecase/{resource}_usecase.go` — 비즈니스 로직 + Request DTO

### 5. Handler + Response DTO
- `internal/handler/{resource}_handler.go` — Gin Handler + `RegisterRoutes`
- `internal/handler/{resource}_response.go` — Response DTO + `to{Resource}Response()` factory

### 6. Migration
- `migrations/{nextNum:06d}_create_{resources}_table.up.sql`
- `migrations/{nextNum:06d}_create_{resources}_table.down.sql`

### 7. 테스트
- `internal/usecase/{resource}_usecase_test.go` — mockery 기반 단위 테스트
- `internal/handler/{resource}_handler_test.go` — httptest 기반 Handler 테스트
- `testutil/{resource}_fixture.go` — 없으면 생성

## 주의사항
- `domain/` 패키지는 외부 import 금지 — 순수 Go 인터페이스만
- 기존 프로젝트 패턴(에러 응답 형식, middleware 방식)을 먼저 파악하고 따르세요
- `cmd/main.go`의 DI 조립 부분에 신규 의존성 연결 방법을 안내하세요
- mock 생성 커맨드를 안내하세요: `mockery --name={Resource}Repository --dir=internal/domain --output=mocks`
- 생성 후 어떤 파일을 만들었는지 요약해주세요
