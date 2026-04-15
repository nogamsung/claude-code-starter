---
description: MySQL 스키마 설계 → Migration SQL 자동 생성 (Flyway / golang-migrate 패턴 준수)
argument-hint: <도메인 설명> (예: "사용자, 주문, 상품 3개 테이블 설계해줘")
---

다음 지시사항에 따라 MySQL 스키마를 설계하고 Migration SQL 파일을 생성해주세요.

**도메인 설명**: $ARGUMENTS (없으면 사용자에게 물어보세요)

---

## Step 1 — 스택 감지

프로젝트 루트에서 다음 파일을 확인합니다:

| 파일 | 스택 | Migration 도구 |
|------|------|---------------|
| `build.gradle.kts` 또는 `pom.xml` | Kotlin Spring Boot | Flyway |
| `go.mod` | Go Gin | golang-migrate |

- `build.gradle.kts` 존재 → **Kotlin (Flyway)** 로 진행
- `go.mod` 존재 → **Go (golang-migrate)** 로 진행
- 둘 다 없으면 사용자에게 물어봅니다:
  > "스택을 감지하지 못했습니다. Kotlin (Flyway) 와 Go (golang-migrate) 중 어느 쪽으로 진행할까요?"

---

## Step 2 — 도메인 분석

`$ARGUMENTS`에서 다음을 파악합니다:
- 필요한 **엔티티 / 테이블** 목록
- 엔티티 간 **관계** (1:1, 1:N, N:M)
- **제약사항** (UNIQUE, NOT NULL, Soft Delete 필요 여부 등)

아래 항목이 불명확하면 **한 번에 최대 3개**를 물어봅니다:

> 1. 어떤 엔티티/테이블이 필요한가요? (예: users, orders, products)
> 2. 엔티티 간 관계는 어떻게 되나요? (예: users 1:N orders, orders N:M products)
> 3. Soft Delete가 필요한 테이블은 어느 것인가요?

---

## Step 3 — ERD 텍스트 출력

아래 형식으로 ERD를 텍스트로 출력합니다:

```
[users] 1 ──── N [orders]
[orders] 1 ──── N [order_items]
[products] 1 ──── N [order_items]
```

각 테이블의 **핵심 컬럼 목록**을 함께 제시합니다:

```
users
  - id (PK)
  - email (UNIQUE)
  - name
  - status
  - deleted_at (Soft Delete)

orders
  - id (PK)
  - user_id (FK → users)
  - total_price (DECIMAL)
  - status

order_items
  - id (PK)
  - order_id (FK → orders, CASCADE)
  - product_id (FK → products, RESTRICT)
  - quantity
  - price (DECIMAL)
```

출력 후 사용자에게 검토 및 진행 여부를 확인합니다:
> "위 ERD로 Migration SQL을 생성할까요? 수정이 필요하면 말씀해주세요."

---

## Step 4 — Migration SQL 생성

`db-patterns.md` 스킬을 참고하여 아래 규칙에 따라 SQL을 생성합니다.

### 공통 규칙

- **공통 컬럼 자동 포함**: `id`, `created_at`, `updated_at` (모든 테이블)
- **ENGINE 구문 항상 포함**: `ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`
- **FK 컬럼에 INDEX 자동 생성**
- **금액/가격** → `DECIMAL(10, 2)` 사용 (`FLOAT` 절대 금지)
- **상태값** → `VARCHAR(20~50)` 사용 (ENUM 지양)
- **Soft Delete 필요 테이블** → `deleted_at DATETIME(6) NULL DEFAULT NULL` + `INDEX idx_{table}_deleted_at (deleted_at)` 추가

### Kotlin (Flyway) 생성 위치

```
src/main/resources/db/migration/
  V{N}__create_{table}_table.sql   (테이블당 1파일)
```

기존 Flyway 파일 번호 확인 후 다음 번호를 사용합니다:
```bash
ls src/main/resources/db/migration/ | sort
```

파일명 규칙:
- `V{N}__create_{table}_table.sql` — 테이블 생성
- `V{N}__add_{col}_to_{table}.sql` — 컬럼 추가
- `V{N}__create_idx_{table}_{col}.sql` — 인덱스 추가
- **기존 파일 절대 수정 금지**

### Go (golang-migrate) 생성 위치

```
migrations/
  {N:06d}_create_{table}_table.up.sql
  {N:06d}_create_{table}_table.down.sql
```

기존 migration 파일 번호 확인 후 다음 번호를 사용합니다:
```bash
ls migrations/*.up.sql | sort | tail -1
```

파일명 규칙:
- `up` / `down` 쌍 반드시 생성
- `down` 파일: FK 제약이 있는 자식 테이블부터 역순으로 `DROP TABLE IF EXISTS`

---

## Step 5 — Entity/Domain 연계 안내

파일 생성 완료 후 다음을 안내합니다.

### Kotlin (Flyway)
```
Migration SQL 파일이 생성되었습니다.
이제 아래 커맨드로 Entity 클래스와 Repository를 생성하세요:

  /new-api {Entity}

예: /new-api User
    /new-api Order
    /new-api Product
```

### Go (golang-migrate)
```
Migration SQL 파일이 생성되었습니다.
이제 아래 커맨드로 Domain struct와 Repository를 생성하세요:

  /new-api {Resource}

예: /new-api User
    /new-api Order
    /new-api Product
```

---

## 주의사항

- `db-patterns.md` 스킬을 **항상** 참고하여 타입·인덱스·FK 패턴을 따르세요
- 생성한 파일 목록과 적용된 스키마 결정 이유를 요약해주세요
- 테이블 간 참조 순서가 맞도록 파일을 분리하세요 (부모 테이블 먼저 생성)
- down 파일은 up의 역순으로 작성하세요 (자식 테이블 먼저 DROP)
