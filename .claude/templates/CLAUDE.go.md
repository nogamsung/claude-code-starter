# [프로젝트명] — Go Gin

## Stack
- **Language**: Go (latest stable)
- **Framework**: Gin
- **ORM**: GORM
- **Migration**: golang-migrate
- **Validation**: Gin binding tags (`binding:"required"`)
- **Testing**: testify + mockery
- **Config**: godotenv / viper

## Agents
| 작업 | Agent |
|------|-------|
| 새 파일 생성 | `go-generator` |
| 기존 코드 수정 | `go-modifier` |
| 테스트 작성 | `go-tester` |
| 코드 리뷰 | `code-reviewer` |

## Commands
| 커맨드 | 용도 |
|--------|------|
| `/plan <기능>` | 코드 작성 전 설계 및 확인 |
| `/new-go-api <Resource>` | REST API 전체 스캐폴딩 |
| `/test [파일]` | 테스트 자동 생성 |
| `/review [staged\|diff\|파일]` | 코드 리뷰 |
| `/improve <실수 설명>` | 새 규칙을 이 파일에 추가 |
| `/commit [힌트]` | Conventional Commits 커밋 |
| `/memory [add\|search]` | Second Brain 조회·추가·검색 |

---

## 아키텍처 규칙

### 디렉토리 구조
```
cmd/
└── main.go              # Entry point — DI 조립만 담당
internal/
├── domain/              # Entity, Repository interface, domain errors — 외부 의존성 없음
├── usecase/             # 비즈니스 로직 + UseCase DTO
├── repository/          # GORM Repository 구현체
├── handler/             # Gin Handler + Response DTO
└── middleware/          # Auth, Logger, Recovery 등
migrations/              # golang-migrate SQL 파일 (up/down 쌍)
mocks/                   # mockery 자동 생성 mock
testutil/                # 테스트 Fixture
```

### 레이어 의존 방향
`handler` → `usecase` → `domain` ← `repository`

**`domain/` 패키지는 어떤 외부 패키지도 import할 수 없습니다.**

---

## 반드시 지켜야 할 규칙 (MUST)

### 의존성 주입
```go
// ✅ 생성자 파라미터로만 주입
func NewOrderUseCase(repo domain.OrderRepository) *OrderUseCase {
    return &OrderUseCase{orderRepo: repo}
}

// ❌ 절대 금지 — 전역 변수
var db *gorm.DB
```

### 에러 처리
```go
// ✅ 에러 감싸서 전파
if err := r.db.First(&order, id).Error; err != nil {
    return nil, fmt.Errorf("FindByID: %w", err)
}

// ✅ 도메인 에러로 변환
if errors.Is(err, gorm.ErrRecordNotFound) {
    return nil, domain.ErrNotFound
}

// ❌ 절대 금지 — 에러 무시
result, _ := repo.FindByID(ctx, id)
```

### context 전파
```go
// ✅ 모든 레이어에서 context 전달
func (uc *OrderUseCase) GetOrder(ctx context.Context, id uint) (*domain.Order, error) {
    return uc.orderRepo.FindByID(ctx, id)
}

// ❌ context 누락
func (r *orderRepository) FindByID(id uint) (*domain.Order, error) {
```

### Handler 에러 응답
```go
// ✅ domain error → HTTP status 매핑
if errors.Is(err, domain.ErrNotFound) {
    c.JSON(http.StatusNotFound, gin.H{"error": "not found"})
    return
}

// ❌ 절대 금지 — 내부 에러 메시지 그대로 노출
c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
```

---

## 절대 하면 안 되는 것 (NEVER)

- `domain/` 패키지에서 GORM, gin 등 외부 패키지 import
- Handler에서 Repository 직접 호출 (UseCase 우회)
- 전역 DB 연결 변수 사용
- `panic()`으로 에러 처리 (복구 가능한 에러에)
- 기존 Migration 파일 수정 (새 파일 추가만 가능)
- 패스워드, 토큰, PII를 로그에 출력
- 테스트 없이 새로운 UseCase 메서드 추가
- `context.Background()` 을 요청 핸들러에서 직접 사용 (`c.Request.Context()` 사용)

---

## 코드 품질 기준

- 모든 UseCase public 메서드에 단위 테스트 필수
- 새 Handler 엔드포인트마다 Handler 테스트 필수
- 새 DB 컬럼/테이블은 반드시 golang-migrate 파일과 함께 (up/down 쌍)
- mock은 직접 작성 금지 — mockery로 자동 생성

## 커버리지 게이트

**git push 전 라인 커버리지 80% 이상 필수** (`.claude/hooks/pre-push.sh` 자동 검사)

```bash
# 커버리지 확인
go test ./... -coverprofile=coverage.out
go tool cover -func=coverage.out | grep total
```

---

## 학습된 규칙 (AI 실수 후 추가)

<!-- /improve 커맨드로 새 규칙이 여기에 추가됩니다 -->

---

## Memory 관리 지침

> Claude는 아래 상황에서 `memory/MEMORY.md`를 **자동으로** 업데이트합니다.

**자동 기록 트리거:**
- `/plan` 승인 → 구현할 기능과 선택한 설계 방식 기록
- `/improve` 실행 → 어떤 실수였는지, 추가된 규칙 요약 기록
- 복잡한 버그 해결 → 원인, 해결 방법, 재발 방지 포인트 기록
- 외부 라이브러리/API 도입 결정 → 선택 이유, 대안 기록
- 아키텍처 또는 폴더 구조 변경 → 변경 전/후, 이유 기록

**`memory/MEMORY.md` vs `CLAUDE.md` 구분:**
- `memory/MEMORY.md` — 맥락과 히스토리 (왜 이 결정을 했는가)
- `CLAUDE.md` — 규칙 (앞으로 어떻게 해야 하는가)
