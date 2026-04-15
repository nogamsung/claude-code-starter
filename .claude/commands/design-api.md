---
description: 코드 작성 전 REST API를 설계하는 인터랙티브 워크플로우. 엔드포인트·스키마·인증을 설계하고 OpenAPI YAML 초안을 생성한 뒤 /new-api (Kotlin) 또는 /new-go-api (Go)로 연결. 백엔드 전용.
argument-hint: <리소스명> (예: Order, Product, User)
---

코드 작성 전에 API 설계를 먼저 진행합니다.

**리소스명**: $ARGUMENTS (없으면 사용자에게 물어보세요)

---

## Step 1 — 스택 감지

프로젝트 루트 파일을 확인합니다:

| 파일 | 스택 | 구현 커맨드 |
|------|------|------------|
| `build.gradle.kts` / `pom.xml` | Kotlin Spring Boot | `/new-api` |
| `go.mod` | Go Gin | `/new-go-api` |

감지된 스택을 사용자에게 확인합니다.

---

## Step 2 — 도메인 파악

아래 질문 중 필요한 것만 골라서 **한 번에 최대 3개까지** 묻습니다.

- 이 리소스의 핵심 속성(필드)은 무엇인가요?
- 어떤 사용자/역할이 이 API를 호출하나요? (인증 필요 여부)
- 특별한 비즈니스 액션이 있나요? (예: 주문 취소, 상태 변경)
- 다른 리소스와 관계가 있나요? (예: Order → OrderItem)
- 목록 조회 시 필터·정렬 조건이 있나요?

---

## Step 3 — 엔드포인트 목록 초안

`api-designer` 에이전트를 사용해 다음 형식으로 엔드포인트 목록을 제시합니다:

```
[엔드포인트 목록]
  GET    /api/v1/{resources}          — 목록 조회 (페이지네이션)
  POST   /api/v1/{resources}          — 생성
  GET    /api/v1/{resources}/{id}     — 단건 조회
  PUT    /api/v1/{resources}/{id}     — 전체 수정
  PATCH  /api/v1/{resources}/{id}     — 부분 수정  ← 필요 시 추가
  DELETE /api/v1/{resources}/{id}     — 삭제
  POST   /api/v1/{resources}/{id}/cancel  — 액션 ← 필요 시 추가

[인증]
  Bearer JWT  /  API Key  /  없음

[페이지네이션]
  오프셋 (?page=0&size=20)  /  커서 기반
```

사용자에게 엔드포인트 목록 확인을 요청합니다.

---

## Step 4 — Request / Response 스키마 설계

확인된 엔드포인트를 기반으로 스키마를 설계합니다:

```
[Request 스키마]
  Create{Resource}Request
    - field1: 타입, 필수/선택, 제약조건
    - field2: 타입, 필수/선택, 제약조건

  Update{Resource}Request
    - field1: 타입, 제약조건

[Response 스키마]
  {Resource}Response
    - id: Long/int
    - field1: 타입
    - createdAt: datetime

[에러 응답]
  400: 입력값 유효성 실패
  401: 인증 없음
  404: 리소스 없음
```

---

## Step 5 — OpenAPI YAML 출력

`api-designer` 에이전트가 Step 3~4 결과를 바탕으로 OpenAPI 3.0 YAML 초안을 생성합니다.

파일명: `docs/api/{resource}.yaml` (없으면 콘솔에만 출력)

---

## Step 6 — 사용자 확인 및 구현 연결

설계 초안을 제시하고 확인을 요청합니다:

> **이 설계대로 구현을 시작할까요? 수정이 필요한 부분이 있으면 알려주세요.**

사용자가 승인하면 감지된 스택에 따라 구현 커맨드를 안내합니다:

### Kotlin Spring Boot
```
설계가 완료됐습니다. 이제 구현을 시작합니다.

/new-api {리소스명}
```

`/new-api` 커맨드가 이어서 실행되며, 설계한 엔드포인트·스키마를 기반으로
Controller, Service, Repository, DTO, 테스트를 자동 생성합니다.

### Go Gin
```
설계가 완료됐습니다. 이제 구현을 시작합니다.

/new-go-api {리소스명}
```

`/new-go-api` 커맨드가 이어서 실행되며, 설계한 엔드포인트·스키마를 기반으로
Domain, Repository, UseCase, Handler, Migration을 자동 생성합니다.

---

## 핵심 원칙

> API 계약(Contract)을 먼저 합의하면
> 프론트엔드·백엔드가 병렬로 작업할 수 있고,
> 구현 후 스키마 변경 비용을 크게 줄일 수 있습니다.
