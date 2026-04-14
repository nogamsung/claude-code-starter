# [프로젝트명] — Kotlin Spring Boot

## Stack
- **Language**: Kotlin (latest stable)
- **Framework**: Spring Boot 3.x
- **Build**: Gradle (Kotlin DSL — `build.gradle.kts`)
- **ORM**: Spring Data JPA + Hibernate
- **Migration**: Flyway (절대 기존 migration 파일 수정 금지)
- **Security**: Spring Security + JWT
- **Docs**: SpringDoc OpenAPI

## Agents
| 작업 | Agent |
|------|-------|
| 새 파일 생성 | `kotlin-generator` |
| 기존 코드 수정 | `kotlin-modifier` |
| 테스트 작성 | `kotlin-tester` |
| 코드 리뷰 | `code-reviewer` |

## Commands
| 커맨드 | 용도 |
|--------|------|
| `/plan <기능>` | 코드 작성 전 설계 및 확인 |
| `/new-api <Resource>` | REST API 전체 스캐폴딩 |
| `/test [파일]` | 테스트 자동 생성 |
| `/review [staged\|diff\|파일]` | 코드 리뷰 |
| `/improve <실수 설명>` | 새 규칙을 이 파일에 추가 |
| `/commit [힌트]` | Conventional Commits 커밋 |

---

## 아키텍처 규칙

### 디렉토리 구조
```
src/main/kotlin/com/{company}/{project}/
├── domain/           # Entity, Value Object — 순수 도메인
├── application/      # Service — 비즈니스 로직
├── infrastructure/   # Repository, 외부 연동
├── presentation/     # Controller, DTO, Request/Response
└── config/           # Spring 설정 클래스
```

### 레이어 의존 방향
`presentation` → `application` → `domain` ← `infrastructure`

**절대 역방향 의존 금지.** `domain`이 `infrastructure`를 import하면 안 됩니다.

---

## 반드시 지켜야 할 규칙 (MUST)

### 의존성 주입
```kotlin
// ✅ 생성자 주입만 허용
@Service
class UserService(private val userRepository: UserRepository)

// ❌ 절대 금지 — 필드 주입
@Autowired
lateinit var userRepository: UserRepository
```

### 트랜잭션
```kotlin
// ✅ 서비스 클래스에 readOnly = true
@Service
@Transactional(readOnly = true)
class UserService(...) {

    // ✅ 쓰기 메서드에만 @Transactional 추가
    @Transactional
    fun createUser(request: CreateUserRequest): UserResponse { ... }
}
```

### DTO 사용
```kotlin
// ✅ 반드시 DTO로 감싸서 반환
fun getUser(id: Long): UserResponse = UserResponse.from(findUser(id))

// ❌ 절대 금지 — Entity를 API 응답으로 직접 노출
fun getUser(id: Long): User = findUser(id)
```

### Kotlin Null Safety
```kotlin
// ✅ 안전한 처리
val name = user?.name ?: throw IllegalStateException("name is null")

// ❌ 절대 금지 — 확신 없이 !! 사용
val name = user!!.name
```

### 예외 처리
```kotlin
// ✅ 도메인 예외를 던지고 GlobalExceptionHandler에서 처리
throw EntityNotFoundException("User not found: $id")

// ❌ 절대 금지 — Controller에서 try-catch로 예외 삼키기
```

---

## 절대 하면 안 되는 것 (NEVER)

- `DROP TABLE`, `TRUNCATE` 등 raw DDL SQL 실행
- 기존 Flyway migration 파일 수정 (새 파일 추가만 가능)
- Entity 클래스에 비즈니스 로직 추가 (getter/setter 외)
- 패스워드, 토큰, PII를 로그에 출력
- `@SpringBootApplication` 클래스에 비즈니스 코드 추가
- 테스트 없이 새로운 public 메서드 추가
- N+1 쿼리를 유발하는 즉시 로딩(`FetchType.EAGER`) 추가

---

## 코드 품질 기준

- 모든 public 서비스 메서드에 단위 테스트 필수
- 새 엔드포인트마다 Controller 테스트 필수
- 새 DB 컬럼/테이블은 반드시 Flyway migration과 함께
- PR당 하나의 기능 단위로 atomic하게 커밋

---

## 학습된 규칙 (AI 실수 후 추가)

<!-- /improve 커맨드로 새 규칙이 여기에 추가됩니다 -->

---

## Memory 관리 지침

> Claude는 아래 상황에서 `memory/MEMORY.md`를 **자동으로** 업데이트합니다.
> 사용자가 요청하지 않아도 기록하고, 기록 후 "memory에 저장했습니다." 한 줄만 언급합니다.

**자동 기록 트리거:**
- `/plan` 승인 → 구현할 기능과 선택한 설계 방식 기록
- `/improve` 실행 → 어떤 실수였는지, 추가된 규칙 요약 기록
- 복잡한 버그 해결 → 원인, 해결 방법, 재발 방지 포인트 기록
- 외부 라이브러리/API 도입 결정 → 선택 이유, 대안 기록
- 아키텍처 또는 폴더 구조 변경 → 변경 전/후, 이유 기록
- 성능 문제 발견 및 해결 → 병목 지점, 해결 방법 기록

**`memory/MEMORY.md` vs `CLAUDE.md` 구분:**
- `memory/MEMORY.md` — 맥락과 히스토리 (왜 이 결정을 했는가)
- `CLAUDE.md` — 규칙 (앞으로 어떻게 해야 하는가)
