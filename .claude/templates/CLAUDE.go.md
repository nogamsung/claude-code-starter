# [프로젝트명] — Go Gin

## Stack
- **Language**: Go (latest stable)
- **Framework**: Gin
- **ORM**: GORM (단순 CRUD)
- **쿼리 생성**: **sqlc** (필수 — 동적·복잡 쿼리는 sqlc로 타입 안전하게 생성)
- **Migration**: golang-migrate
- **Lint**: **golangci-lint** (필수 — 모든 PR/push 전 통과 의무)
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

## Git 브랜치 전략

| 브랜치 | 역할 | 보호 |
|--------|------|------|
| `main` | 프로덕션 릴리스 | PR + CI 통과 필수 |
| `dev` | 통합·스테이징 | PR + CI 통과 필수 |
| `dev/feature-{number}` | 기능 개발 | - |
| `dev/hotfix-{number}` | 긴급 수정 | - |

```bash
# 새 기능 시작
git checkout dev && git pull origin dev
git checkout -b dev/feature-42

# 작업 후 PR 생성 (base: dev)
gh pr create --base dev --title "feat: ..."

# dev → main 릴리스 PR
gh pr create --base main --title "release: v1.2.0"
```

**규칙**
- feature 브랜치는 반드시 `dev`에서 분기 → `dev`로 PR
- `main` 직접 push 금지
- PR merge 후 feature 브랜치 즉시 삭제

---

## 아키텍처 규칙

### 디렉토리 구조
```
cmd/
└── main.go              # Entry point — DI 조립만 담당
internal/
├── domain/              # Entity, Repository interface, domain errors — 외부 의존성 없음
├── usecase/             # 비즈니스 로직 + UseCase DTO
├── repository/          # GORM + sqlc Repository 구현체
├── handler/             # Gin Handler + Response DTO
└── middleware/          # Auth, Logger, Recovery 등
migrations/              # golang-migrate SQL 파일 (up/down 쌍)
db/
├── query/               # sqlc SQL 쿼리 파일 (*.sql)
└── sqlc/                # sqlc 자동 생성 코드 (수동 수정 금지)
mocks/                   # mockery 자동 생성 mock
testutil/                # 테스트 Fixture
sqlc.yaml                # sqlc 설정
.golangci.yml            # golangci-lint 설정
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
- `db/sqlc/` 아래 자동 생성 파일 수동 수정 (항상 `sqlc generate`로 재생성)
- sqlc 없이 raw SQL 문자열을 코드에 직접 작성
- golangci-lint 경고를 `//nolint` 주석으로 무분별하게 억제

---

## sqlc 사용 규칙

### 쿼리 선택 기준
| 케이스 | 사용 기술 |
|--------|----------|
| 단순 CRUD (Insert, FindByID, Delete) | GORM |
| 조건 검색, 페이징, 조인 쿼리 | sqlc |
| 집계·통계·보고서 | sqlc |

### sqlc.yaml 기본 설정
```yaml
version: "2"
sql:
  - engine: "postgresql"   # 또는 mysql
    queries: "db/query/"
    schema: "migrations/"
    gen:
      go:
        package: "sqlcdb"
        out: "db/sqlc"
        emit_json_tags: true
        emit_interface: true
        emit_exact_table_names: false
```

### sqlc 쿼리 작성 예시
```sql
-- db/query/order.sql

-- name: ListOrdersByUserID :many
SELECT * FROM orders
WHERE user_id = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: GetOrderByID :one
SELECT * FROM orders WHERE id = $1;

-- name: SearchOrders :many
SELECT * FROM orders
WHERE (user_id = sqlc.narg('user_id') OR sqlc.narg('user_id') IS NULL)
  AND (status  = sqlc.narg('status')  OR sqlc.narg('status')  IS NULL)
ORDER BY created_at DESC;
```

### Repository에서 sqlc 사용
```go
// internal/repository/order_repository.go
type orderRepository struct {
    db      *gorm.DB
    queries *sqlcdb.Queries  // sqlc 자동 생성
}

// 단순 CRUD — GORM
func (r *orderRepository) Create(ctx context.Context, order *domain.Order) error {
    return r.db.WithContext(ctx).Create(order).Error
}

// 조건 검색 — sqlc
func (r *orderRepository) Search(ctx context.Context, params domain.OrderSearchParams) ([]*domain.Order, error) {
    rows, err := r.queries.SearchOrders(ctx, sqlcdb.SearchOrdersParams{
        UserID: pgtype.Int8{Int64: params.UserID, Valid: params.UserID != 0},
        Status: pgtype.Text{String: params.Status, Valid: params.Status != ""},
    })
    // ...
}
```

---

## golangci-lint 규칙

### .golangci.yml 기본 설정
```yaml
linters:
  enable:
    - errcheck       # 에러 무시 방지
    - govet          # go vet 검사
    - staticcheck    # 정적 분석
    - gosimple       # 코드 단순화 제안
    - unused         # 미사용 코드 탐지
    - gofmt          # 포맷 검사
    - goimports      # import 정렬
    - revive         # 스타일 검사
    - bodyclose      # HTTP response body 닫기 검사
    - noctx          # context 없는 HTTP 요청 탐지

linters-settings:
  revive:
    rules:
      - name: exported
      - name: var-naming

issues:
  exclude-use-default: false
  max-issues-per-linter: 0
  max-same-issues: 0
```

### lint 실행
```bash
# 로컬 실행
golangci-lint run ./...

# 특정 파일
golangci-lint run internal/usecase/...
```

**git push 전 `golangci-lint run ./...` 통과 필수** (`.claude/hooks/pre-push.sh` 자동 검사)

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

### 2026-04-14 — sqlc·golangci-lint 미사용으로 쿼리 안전성·코드 품질 저하
- **문제**: Go Gin 프로젝트에서 GORM만 사용하고 복잡한 쿼리를 raw SQL 문자열로 작성, lint 검사 없이 코드 생성
- **규칙**: 조건 검색·페이징·조인 쿼리는 **반드시 sqlc**로 타입 안전하게 생성. 모든 코드는 **golangci-lint** 통과 필수
- **이유**: raw SQL 문자열은 컴파일 타임 오류 검출 불가, lint 없이 작성된 코드는 errcheck 누락·미사용 변수 등 버그 유입 위험

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
