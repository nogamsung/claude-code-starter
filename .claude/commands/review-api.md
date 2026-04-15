---
description: 기존 REST API 코드를 리뷰합니다. RESTful 컨벤션, 보안(인증 누락·과도한 데이터 노출), OpenAPI 문서 완성도를 체크. Kotlin Spring Boot 및 Go Gin 백엔드 전용.
argument-hint: [파일경로 또는 리소스명] (생략 시 전체 API 스캔)
---

기존 API 코드를 리뷰합니다.

**대상**: $ARGUMENTS (없으면 프로젝트 전체 Controller/Handler 스캔)

---

## Step 1 — 스택 감지 및 대상 파일 수집

**Kotlin Spring Boot**
```
대상 파일: **/presentation/**Controller.kt
```

**Go Gin**
```
대상 파일: **/handler/**_handler.go
```

$ARGUMENTS가 있으면 해당 파일/리소스만 대상으로 합니다.

---

## Step 2 — REST 컨벤션 체크

각 엔드포인트에 대해 다음을 확인합니다:

### URL 구조
- [ ] 리소스명이 복수형 명사인가? (`/orders` not `/order`, `/getOrders`)
- [ ] 계층 관계가 3단계를 초과하지 않는가?
- [ ] 액션이 필요한 경우 `POST /resource/{id}/action` 패턴을 사용하는가?

### HTTP 메서드
- [ ] GET — 조회만, 사이드 이펙트 없음
- [ ] POST — 생성 / 201 Created 반환
- [ ] PUT — 전체 수정 / PATCH — 부분 수정 구분
- [ ] DELETE — 삭제 / 204 No Content 반환

### 상태코드
- [ ] 생성: 201 (not 200)
- [ ] 삭제: 204 (not 200)
- [ ] 인증 없음: 401 (not 403)
- [ ] 권한 없음: 403 (not 401)
- [ ] 비즈니스 규칙 위반: 422 (not 400)

---

## Step 3 — 보안 체크

### 인증/인가
- [ ] 인증이 필요한 엔드포인트에 `@PreAuthorize` / JWT 미들웨어가 적용됐는가?
- [ ] 공개 엔드포인트가 의도적으로 노출됐는가? (명시적 허용 목록)
- [ ] 타인 리소스 접근 방지 (userId 검증)가 있는가?

### 과도한 데이터 노출
- [ ] 비밀번호·해시 등 민감 필드가 Response에 포함되지 않는가?
- [ ] 내부 ID(DB PK)를 그대로 노출하는가? (필요 시 UUID/난수 ID 권장)
- [ ] 관계 엔티티를 무한 중첩 직렬화하지 않는가?

### 입력값 검증
- [ ] Bean Validation (`@Valid`) / binding 체크가 적용됐는가?
- [ ] Path variable `{id}` 타입 검증이 있는가?

---

## Step 4 — OpenAPI 문서 완성도 체크

### Kotlin Spring Boot (SpringDoc)
- [ ] `@Tag` 클래스 레벨 어노테이션
- [ ] 모든 메서드에 `@Operation(summary)`
- [ ] 성공/실패 `@ApiResponse` 명시
- [ ] Path/Query 파라미터에 `@Parameter(description)`
- [ ] DTO 필드에 `@Schema` 어노테이션

### Go Gin (swag)
- [ ] 모든 Handler에 godoc swag 주석
- [ ] `@Summary`, `@Tags`, `@Router`
- [ ] `@Success`, `@Failure` 응답 타입
- [ ] `@Security BearerAuth` (인증 필요 엔드포인트)
- [ ] Response DTO 필드에 `example:"..."` json 태그

---

## Step 5 — 리뷰 결과 출력

다음 형식으로 결과를 정리합니다:

```
## API 리뷰 결과

### [파일명 또는 리소스명]

#### 잘된 점
- ...

#### 개선 필요
| 심각도 | 항목 | 위치 | 권장 수정 |
|--------|------|------|----------|
| 높음   | 인증 미적용 | GET /api/v1/orders/{id} | JWT 미들웨어 추가 |
| 중간   | 상태코드 오류 | POST /api/v1/orders → 200 | 201 Created로 변경 |
| 낮음   | @Operation 누락 | OrderController:45 | SpringDoc 어노테이션 추가 |

#### 수정 제안 코드
(심각도 높음 항목에 대해 수정 예시 제공)
```

---

## 심각도 기준

| 심각도 | 기준 |
|--------|------|
| 높음 | 보안 취약점 (인증 누락, 민감 데이터 노출) |
| 중간 | 잘못된 HTTP 상태코드, 비즈니스 규칙 오류 가능성 |
| 낮음 | 컨벤션 불일치, 문서 누락 |
