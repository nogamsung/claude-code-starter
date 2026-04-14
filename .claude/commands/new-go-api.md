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

### 3. Repository Implementation (GORM + sqlc)
- `internal/repository/{resource}_repository.go`
  - 단순 CRUD (Create, FindByID, Update, Delete) → GORM
  - 조건 검색·페이징 → sqlc `*sqlcdb.Queries` 사용
- `db/query/{resource}.sql` — sqlc 쿼리 파일 (List, Search 등)

### 4. UseCase
- `internal/usecase/{resource}_usecase.go` — 비즈니스 로직 + Request/SearchParams DTO

### 5. Handler + Response DTO (swag 주석 필수)
- `internal/handler/{resource}_handler.go`
  - 모든 Handler 메서드에 godoc swag 주석 (`@Summary`, `@Tags`, `@Router`, `@Success`, `@Failure`)
  - `RegisterRoutes` 메서드 포함
- `internal/handler/{resource}_response.go`
  - Response DTO (필드에 `example:"..."` json 태그 필수)
  - `ErrorResponse` 없으면 생성

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
- 조건 검색·페이징 쿼리는 sqlc로 작성 — raw SQL 문자열 금지
- 모든 Handler 메서드에 swag godoc 주석 필수
- 생성 완료 후 반드시 안내:
  1. mock 재생성: `mockery --name={Resource}Repository --dir=internal/domain --output=mocks`
  2. sqlc 코드 생성: `sqlc generate`
  3. swagger 문서 재생성: `swag init -g cmd/main.go -o docs`
- 생성 후 어떤 파일을 만들었는지 요약해주세요
