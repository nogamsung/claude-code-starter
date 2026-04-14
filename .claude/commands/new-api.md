---
description: Spring Boot REST API 엔드포인트 스캐폴딩 생성 (Controller, Service, Repository, DTO, 테스트)
argument-hint: <리소스명> (예: User, Product, Order)
---

다음 지시사항에 따라 Spring Boot REST API를 생성해주세요.

**리소스명**: $ARGUMENTS (없으면 사용자에게 물어보세요)

## 생성할 파일

현재 프로젝트의 패키지 구조를 먼저 파악한 후, 아래 파일들을 생성하세요:

### 1. Domain Entity
- `domain/{Resource}.kt`
- JPA `@Entity` 클래스
- 필요한 필드는 context를 보고 판단하거나 사용자에게 확인
- `@CreationTimestamp`, `@UpdateTimestamp` 포함

### 2. Repository
- `infrastructure/{Resource}Repository.kt`
- `JpaRepository<{Resource}, Long>` 상속
- 비즈니스에 필요한 커스텀 쿼리 메서드 포함

### 3. DTOs
- `presentation/dto/{Resource}Response.kt` - 응답 DTO (companion object with `from()`)
- `presentation/dto/Create{Resource}Request.kt` - 생성 요청 DTO (Bean Validation)
- `presentation/dto/Update{Resource}Request.kt` - 수정 요청 DTO

### 4. Service
- `application/{Resource}Service.kt`
- `@Service`, `@Transactional(readOnly = true)`
- CRUD 메서드: `get{Resource}`, `get{Resource}s`, `create{Resource}`, `update{Resource}`, `delete{Resource}`
- `EntityNotFoundException` 등 적절한 예외 처리

### 5. Controller
- `presentation/{Resource}Controller.kt`
- `@RestController`, `@RequestMapping("/api/v1/{resources}")`
- RESTful 엔드포인트: GET (목록/단건), POST, PUT/PATCH, DELETE
- `ResponseEntity` 반환 타입 사용
- `@Valid` 검증 적용

### 6. 테스트
- `test/.../application/{Resource}ServiceTest.kt` - MockK 기반 단위 테스트
- `test/.../presentation/{Resource}ControllerTest.kt` - `@WebMvcTest` 기반 테스트

## 주의사항
- 현재 프로젝트의 기존 패턴 (패키지명, 예외 처리 방식, 응답 형태)을 먼저 파악하고 따르세요
- 기존 프로젝트에 `GlobalExceptionHandler`가 있다면 그에 맞게 예외를 던지세요
- 모든 코드는 Kotlin 관용 표현을 사용하세요
- 생성 후 어떤 파일을 만들었는지 요약해주세요
