---
description: REST API 스캐폴딩 생성 — 기술 스택 자동 감지 (Spring Boot / Go Gin)
argument-hint: <리소스명> (예: User, Product, Order)
---

> 💡 **DB 스키마부터 설계하려면** `/design-db <도메인 설명>` 을 먼저 실행하세요.
> Migration SQL을 생성한 후 이 커맨드로 Entity/Repository 코드를 생성하면 일관성이 보장됩니다.

다음 지시사항에 따라 REST API를 생성해주세요.

**리소스명**: $ARGUMENTS (없으면 사용자에게 물어보세요)

## 스택 자동 감지

먼저 프로젝트 루트에서 아래 파일을 순서대로 확인하여 기술 스택을 결정합니다:

| 감지 파일 | 스택 |
|-----------|------|
| `go.mod` 존재 | → [Go Gin 스캐폴딩](#go-gin) |
| `settings.gradle.kts` 또는 `build.gradle.kts` 존재 | → [Spring Boot 스캐폴딩](#spring-boot) |
| `build.gradle` 존재 | → [Spring Boot 스캐폴딩](#spring-boot) |
| 위 파일 없음 | → 사용자에게 스택 선택 요청 ("Go Gin / Spring Boot 중 어떤 스택인가요?") |

---

## Go Gin

### 프로젝트 구조 감지

`go.work` 존재 여부를 확인합니다:
- `go.work` 없음 → 단일 서비스 (기존 동작)
- `go.work` 있음 → 멀티 서비스 workspace

#### 멀티 서비스일 때

어느 서비스에 추가할지 사용자에게 묻습니다:
> "어느 서비스에 추가할까요? (예: services/api, services/worker)"

선택한 서비스 디렉토리를 루트로 삼아 기존 단일 서비스 구조를 그대로 적용합니다.
공유 도메인이 필요하다면 `pkg/shared/` 에 배치하도록 안내합니다.

### 생성할 파일

현재 프로젝트의 `go.mod` 모듈명과 디렉터리 구조를 먼저 파악한 후, 아래 파일들을 생성하세요.

#### 1. Domain Entity + Errors
- `internal/domain/{resource}.go` — 도메인 Entity struct
- `internal/domain/errors.go` — 없으면 생성, 있으면 확인

#### 2. Repository Interface
- `internal/domain/{resource}_repository.go` — CRUD 인터페이스

#### 3. Repository Implementation (GORM + sqlc)
- `internal/repository/{resource}_repository.go`
  - 단순 CRUD (Create, FindByID, Update, Delete) → GORM
  - 조건 검색·페이징 → sqlc `*sqlcdb.Queries` 사용
- `db/query/{resource}.sql` — sqlc 쿼리 파일 (List, Search 등)

#### 4. UseCase
- `internal/usecase/{resource}_usecase.go` — 비즈니스 로직 + Request/SearchParams DTO

#### 5. Handler + Response DTO (swag 주석 필수)
- `internal/handler/{resource}_handler.go`
  - 모든 Handler 메서드에 godoc swag 주석 (`@Summary`, `@Tags`, `@Router`, `@Success`, `@Failure`)
  - `RegisterRoutes` 메서드 포함
- `internal/handler/{resource}_response.go`
  - Response DTO (필드에 `example:"..."` json 태그 필수)
  - `ErrorResponse` 없으면 생성

#### 6. Migration
- `migrations/{nextNum:06d}_create_{resources}_table.up.sql`
- `migrations/{nextNum:06d}_create_{resources}_table.down.sql`

#### 7. 테스트
- `internal/usecase/{resource}_usecase_test.go` — mockery 기반 단위 테스트
- `internal/handler/{resource}_handler_test.go` — httptest 기반 Handler 테스트
- `testutil/{resource}_fixture.go` — 없으면 생성

### 주의사항 (Go Gin)
- `domain/` 패키지는 외부 import 금지 — 순수 Go 인터페이스만
- 기존 프로젝트 패턴(에러 응답 형식, middleware 방식)을 먼저 파악하고 따르세요
- `cmd/main.go`의 DI 조립 부분에 신규 의존성 연결 방법을 안내하세요
- 조건 검색·페이징 쿼리는 sqlc로 작성 — raw SQL 문자열 금지
- 모든 Handler 메서드에 swag godoc 주석 필수
- 생성 완료 후 반드시 안내:
  1. mock 재생성: `mockery --name={Resource}Repository --dir=internal/domain --output=mocks`
  2. sqlc 코드 생성: `sqlc generate`
  3. swagger 문서 재생성: `swag init -g cmd/main.go -o docs`

---

## Spring Boot

### 프로젝트 구조 감지

먼저 프로젝트가 단일 모듈인지 멀티 모듈인지 확인합니다:
- `settings.gradle.kts`에 `include(`가 있으면 → 멀티 모듈
- 없으면 → 단일 모듈 (기존 동작)

#### 멀티 모듈일 때 파일 위치

| 파일 | 모듈 |
|------|------|
| Entity, Value Object | `:domain` 모듈 → `domain/src/main/kotlin/.../domain/` |
| Service | `:domain` 모듈 → `domain/src/main/kotlin/.../application/` |
| Repository (interface) | `:domain` 모듈 → `domain/src/main/kotlin/.../domain/` |
| Repository (impl, QueryDSL) | `:infra` 모듈 → `infra/src/main/kotlin/.../infrastructure/` |
| Controller, DTO | `:api` 모듈 → `api/src/main/kotlin/.../presentation/` |
| 테스트 | 각 모듈의 `src/test/kotlin/` |

### 생성할 파일

현재 프로젝트의 패키지 구조를 먼저 파악한 후, 아래 파일들을 생성하세요:

#### 1. Domain Entity
- `domain/{Resource}.kt`
- JPA `@Entity` 클래스
- 필요한 필드는 context를 보고 판단하거나 사용자에게 확인
- `@CreationTimestamp`, `@UpdateTimestamp` 포함

#### 2. Repository (QueryDSL 3세트 필수)
- `infrastructure/{Resource}Repository.kt` — `JpaRepository` + `{Resource}RepositoryCustom` 상속
- `infrastructure/{Resource}RepositoryCustom.kt` — 동적 쿼리 인터페이스
- `infrastructure/{Resource}RepositoryImpl.kt` — `JPAQueryFactory` 기반 QueryDSL 구현체
- `infrastructure/{Resource}SearchCondition.kt` — 검색 조건 DTO

#### 3. DTOs (Schema 어노테이션 필수)
- `presentation/dto/{Resource}Response.kt` - `@Schema` + companion object with `from()`
- `presentation/dto/Create{Resource}Request.kt` - `@Schema` + Bean Validation
- `presentation/dto/Update{Resource}Request.kt` - `@Schema` + Bean Validation

#### 4. Service
- `application/{Resource}Service.kt`
- `@Service`, `@Transactional(readOnly = true)`
- CRUD 메서드: `get{Resource}`, `get{Resource}s`, `create{Resource}`, `update{Resource}`, `delete{Resource}`
- `EntityNotFoundException` 등 적절한 예외 처리

#### 5. Controller (SpringDoc 어노테이션 필수)
- `presentation/{Resource}Controller.kt`
- `@Tag(name, description)` 클래스 레벨
- `@RestController`, `@RequestMapping("/api/v1/{resources}")`
- RESTful 엔드포인트: GET (목록/단건), POST, PUT/PATCH, DELETE
- 각 메서드: `@Operation(summary)` + `@ApiResponse` 명시
- Path/Query 파라미터: `@Parameter(description, required)`
- `ResponseEntity` 반환 타입 사용, `@Valid` 검증 적용

#### 6. 테스트
- `test/.../application/{Resource}ServiceTest.kt` - MockK 기반 단위 테스트
- `test/.../presentation/{Resource}ControllerTest.kt` - `@WebMvcTest` 기반 테스트

### 주의사항 (Spring Boot)
- 현재 프로젝트의 기존 패턴 (패키지명, 예외 처리 방식, 응답 형태)을 먼저 파악하고 따르세요
- 기존 프로젝트에 `GlobalExceptionHandler`가 있다면 그에 맞게 예외를 던지세요
- 모든 코드는 Kotlin 관용 표현을 사용하세요
- QueryDSL Repository 3세트(`Custom` 인터페이스 + `Impl` 구현체 + `SearchCondition` DTO) 반드시 생성
- 모든 Controller 메서드에 SpringDoc `@Operation`, `@ApiResponse` 어노테이션 추가
- 모든 DTO 클래스·필드에 `@Schema` 어노테이션 추가

---

생성 후 어떤 파일을 만들었는지 요약해주세요.
