# [프로젝트명] — Python FastAPI

## Stack
- **Language**: Python 3.11+
- **Framework**: FastAPI (latest)
- **ORM**: **SQLAlchemy 2.0 (async)** — `Mapped[...]` + `mapped_column` 스타일 필수
- **Migration**: **Alembic** (autogenerate + 수동 검토)
- **Validation**: **Pydantic v2** (`@field_validator`, `ConfigDict`)
- **Config**: Pydantic Settings (`pydantic-settings`)
- **Testing**: **pytest + pytest-asyncio + httpx** (`AsyncClient` + `ASGITransport`)
- **Lint / Format**: **ruff** (+ `ruff format`) — `flake8` · `black` · `isort` 를 대체
- **Type Check**: **mypy** (`strict = true`) + `pydantic.mypy` 플러그인
- **API Docs**: **FastAPI 자동 OpenAPI** — `/docs` (Swagger UI), `/redoc`
- **Package Manager**: **uv** (표준 — `uv sync`, `uv add`, `uv run`)
- **Auth**: `python-jose` + `passlib[bcrypt]`
- **DB Driver**: `asyncpg` (PostgreSQL) / `aiomysql` (MySQL) / `aiosqlite` (테스트)

## Agents
| 작업 | Agent |
|------|-------|
| 새 파일 생성 | `python-generator` |
| 기존 코드 수정 | `python-modifier` |
| 테스트 작성 | `python-tester` |
| 코드 리뷰 | `code-reviewer` |

## Commands
| 커맨드 | 용도 |
|--------|------|
| `/planner <기능>` | 기획서(PRD) + 구현 프롬프트 작성 (단일 스택은 단일 프롬프트 산출) |
| `/plan <기능>` | 코드 작성 전 설계 및 확인 |
| `/plan api <Resource>` | REST API 설계 → OpenAPI 3.0 YAML |
| `/plan db <도메인>` | PostgreSQL/MySQL 스키마 → Alembic revision 안내 |
| `/new <Resource>` | REST API 전체 스캐폴딩 (스택 자동 감지, 명시: `/new api`) |
| `/test [파일]` | 테스트 자동 생성 |
| `/review [staged\|diff\|파일]` | 코드 리뷰 |
| `/rule <실수 설명>` | 새 규칙을 이 파일에 추가 |
| `/commit [힌트]` | Conventional Commits 커밋 |
| `/pr` | PR 생성 + /merge 자동 제안 |
| `/merge [auto]` | GitHub 머지 실행 + 태그 + worktree 정리 |
| `/memory [add\|search]` | Second Brain 조회·추가·검색 |

---

## Git 브랜치 전략 & 병렬 작업 (Worktree)

| 브랜치 | 역할 | 보호 |
|--------|------|------|
| `main` | 프로덕션 릴리스 | PR + CI 통과 필수 |
| `dev` | 통합·스테이징 | PR + CI 통과 필수 |
| `feature/{name}` | 새 기능 | - |
| `fix/{name}` | 버그 수정 | - |
| `hotfix/{name}` | 긴급 수정 | - |
| `refactor/{name}` | 리팩토링 | - |
| `chore/{name}` | 설정·의존성 | - |

### Worktree 병렬 작업 흐름

```bash
# 작업 시작 — worktree로 격리된 작업공간 생성
/new feature-login    # feature/login + .worktrees/feature-login/
/new fix-signup       # fix/signup + .worktrees/fix-signup/

# 각 worktree 에서 독립된 .venv 보유
cd .worktrees/feature-login && uv sync

# 여러 작업 동시 진행 가능
git worktree list

# 작업 후 PR 생성 (base: dev)
/pr

# PR merge 후 정리
git worktree remove .worktrees/feature-login
git branch -d feature/login
```

### Worktree 디렉토리 규칙
- 위치: `.worktrees/{type}-{name}/` (프로젝트 내부, gitignore 필수)
- `.gitignore` 에 `.worktrees/` + `.venv/` 반드시 포함
- 각 worktree 는 독립 `.venv` 보유 (`uv sync` 자동 실행)
- `main` 직접 push 금지 — 반드시 `dev` 를 거쳐 PR

---

## 아키텍처 규칙

### 디렉토리 구조
```
app/
├── main.py                 # FastAPI 앱 + 예외 핸들러 + 라우터 등록
├── core/
│   ├── config.py           # Pydantic Settings
│   ├── deps.py             # Dependency injection (FastAPI Depends)
│   └── security.py         # JWT, 패스워드 해싱
├── db/
│   ├── base.py             # DeclarativeBase
│   └── session.py          # async engine + sessionmaker
├── models/                 # SQLAlchemy ORM (Mapped[...] + mapped_column)
│   └── order.py
├── schemas/                # Pydantic v2 Request/Response
│   └── order.py
├── repositories/           # 데이터 접근 계층 (AsyncSession 기반)
│   └── order.py
├── services/               # 비즈니스 로직
│   └── order.py
├── routers/                # FastAPI APIRouter
│   └── orders.py
└── exceptions.py           # 도메인 커스텀 예외
alembic/
├── env.py
└── versions/               # Alembic migration revisions
tests/
├── conftest.py
├── fixtures/
├── services/
├── routers/
├── repositories/
└── integration/
pyproject.toml              # uv 프로젝트 + ruff/mypy 설정
alembic.ini
```

### 레이어 의존 방향
`routers` → `services` → `repositories` → `models`
`schemas` ← `routers`, `services` (양쪽에서 사용, 하위 의존 없음)

**`models/` 에는 비즈니스 로직 추가 금지** — Service 에만.

---

## 반드시 지켜야 할 규칙 (MUST)

### 의존성 주입
```python
# ✅ FastAPI Depends 로만 주입
def get_order_service(
    repo: Annotated[OrderRepository, Depends(get_order_repository)],
) -> OrderService:
    return OrderService(repo)

# ❌ 절대 금지 — 모듈 전역 인스턴스
order_service = OrderService(...)  # 테스트·override 불가
```

### async 일관성
```python
# ✅ 전 레이어 async
async def get_order(self, order_id: int) -> Order:
    return await self._repo.find_by_id(order_id)

# ❌ sync 섞기 금지
def get_order_sync(self, order_id: int) -> Order:  # Service 전체가 async 인데 혼용
    ...
```

### 예외 처리
```python
# ✅ 커스텀 예외 → Router 에서 HTTPException 변환 (또는 app.exception_handler)
raise NotFoundError("order", order_id)

# ❌ 절대 금지 — Service 에서 HTTPException 직접 던지기
raise HTTPException(404, "not found")  # Service 가 FastAPI 를 의존하게 됨
```

### Schema / Model 분리
```python
# ✅ Response 는 Pydantic Schema 로 변환
return OrderResponse.model_validate(order)

# ❌ ORM 모델을 직접 응답
return order  # lazy load 터짐 + 내부 필드 노출
```

### 타입 힌트
```python
# ✅ 모든 public 함수에 타입 힌트
async def create(self, user_id: int, data: OrderCreate) -> Order:
    ...

# ❌ 타입 힌트 누락 — mypy strict 에서 에러
async def create(self, user_id, data):
    ...
```

---

## 절대 하면 안 되는 것 (NEVER)

- `models/` 에 비즈니스 로직 (메서드로 주문 취소 로직 등) 추가
- `services/` 에서 `HTTPException` 또는 `fastapi.*` import
- SQLAlchemy `Column(...)` 단독 사용 — 반드시 `Mapped[...] = mapped_column(...)`
- Pydantic v1 스타일 (`@validator`, `Config` 내부 클래스) 사용
- `@pytest.mark.asyncio` 없이 async 테스트 작성 (또는 `asyncio_mode = "auto"` 미설정)
- `session.commit()` 을 Service / Repository 에서 호출 — 트랜잭션 경계는 `Depends(get_db_session)` 에서
- 기존 Alembic migration 파일 수정 — 항상 새 revision
- `print()` 로 디버깅 — `logging` 모듈 사용
- 패스워드·토큰·PII 를 로그에 출력
- 테스트 없이 새 Service 메서드 추가
- `# type: ignore` 를 이유 주석 없이 사용
- raw SQL 문자열을 코드에 하드코딩 — `text()` + 파라미터 바인딩

---

## FastAPI 라우터 규칙 (MUST)

### Router 선언
```python
router = APIRouter(prefix="/api/v1/orders", tags=["orders"])
```

### 엔드포인트 메타데이터
```python
@router.get(
    "/{order_id}",
    response_model=OrderResponse,
    summary="주문 단건 조회",
    responses={404: {"model": ErrorResponse}},
)
async def get_order(
    service: OrderServiceDep,
    order_id: int = Path(..., ge=1, description="주문 ID"),
) -> OrderResponse:
    ...
```

- `response_model` 필수 — dict 반환 금지
- `summary` + `responses` 로 OpenAPI 스키마 풍부화
- `Path` / `Query` 에 `ge` · `le` · `max_length` 검증

### 예외 핸들러 (main.py)
```python
@app.exception_handler(NotFoundError)
async def not_found_handler(_: Request, exc: NotFoundError) -> JSONResponse:
    return JSONResponse(
        status_code=404,
        content={"detail": str(exc)},
    )
```

커스텀 예외 → JSON 응답 변환은 `main.py` 에서 일괄 관리.

---

## Alembic Migration 규칙

### 초기 설정
```bash
uv run alembic init alembic
```

`alembic/env.py` 에서 `target_metadata = Base.metadata` 로 설정 (autogenerate 활성화).

### 새 revision 생성
```bash
# 모델 변경 후
uv run alembic revision --autogenerate -m "create_orders_table"

# 생성된 파일 반드시 검토 — autogenerate 가 놓치는 것:
#   - 서버 기본값 변경
#   - 체크 제약
#   - 인덱스 순서
#   - ENUM 타입 변경
```

### 적용
```bash
uv run alembic upgrade head        # 최신으로
uv run alembic downgrade -1        # 한 단계 롤백
uv run alembic history             # 히스토리 확인
```

**기존 revision 파일 수정 금지** — 항상 새 revision 추가.

---

## 테스트 규칙

### pytest 설정 (pyproject.toml)
```toml
[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]
markers = ["integration: requires real database"]
```

### 단위 테스트 (AsyncMock)
```python
async def test_주문이_없으면_NotFoundError(self) -> None:
    repo = AsyncMock(spec=OrderRepository)
    repo.find_by_id.return_value = None

    service = OrderService(repo)
    with pytest.raises(NotFoundError):
        await service.get(999)
```

### Router 테스트 (httpx AsyncClient)
```python
async def test_get_order(client: AsyncClient) -> None:
    service = AsyncMock(spec=OrderService)
    service.get.return_value = make_order(id=1)
    app.dependency_overrides[get_order_service] = lambda: service

    response = await client.get("/api/v1/orders/1")
    assert response.status_code == 200
```

### 통합 테스트 (실제 DB)
`@pytest.mark.integration` 으로 분리. `aiosqlite` 또는 testcontainers 사용.

---

## 코드 품질 기준

- 모든 Service public 메서드에 단위 테스트 필수
- 새 Router 엔드포인트마다 Router 테스트 필수
- 모델 스키마 변경은 반드시 Alembic revision 쌍 (upgrade/downgrade)
- Factory 는 `tests/fixtures/` 에 중앙집중

## 커버리지 게이트

**git push 전 라인 커버리지 80% 이상 필수** (`.claude/hooks/pre-push.sh` 자동 검사)

```bash
# 커버리지 확인
uv run pytest --cov=app --cov-report=term-missing
```

## ruff / mypy 체크포인트

```bash
uv run ruff check .            # 린트
uv run ruff format --check .   # 포맷 검증 (CI)
uv run ruff format .           # 포맷 적용 (로컬)
uv run mypy .                  # 타입 체크
```

**git push 전 위 3 명령 모두 통과 필수**.

---

## uv 기본 명령어

```bash
uv sync                        # 락파일 기반 동기화
uv add fastapi                 # 의존성 추가
uv add --dev pytest            # dev 의존성
uv remove <pkg>                # 제거
uv run uvicorn app.main:app --reload   # 개발 서버
uv lock --upgrade-package fastapi      # 특정 패키지만 업그레이드
```

---

## 학습된 규칙 (AI 실수 후 추가)

<!-- /rule 커맨드로 새 규칙이 여기에 추가됩니다 -->

---

## 세션 시작 시 자동 참조

> 🧠 **새 작업을 시작하기 전에 `memory/MEMORY.md` 를 반드시 먼저 읽으세요.** 과거 결정·교훈을 맥락에 포함하여 같은 실수를 반복하지 않도록 합니다.

---

## Memory 관리 지침

> Claude 는 아래 상황에서 `memory/MEMORY.md` 를 **자동으로** 업데이트합니다.

**자동 기록 트리거:**
- `/plan` 승인 → 구현할 기능과 선택한 설계 방식 기록
- `/rule` 실행 → 어떤 실수였는지, 추가된 규칙 요약 기록
- 복잡한 버그 해결 → 원인, 해결 방법, 재발 방지 포인트 기록
- 외부 라이브러리/API 도입 결정 → 선택 이유, 대안 기록
- 아키텍처 또는 폴더 구조 변경 → 변경 전/후, 이유 기록

**`memory/MEMORY.md` vs `CLAUDE.md` 구분:**
- `memory/MEMORY.md` — 맥락과 히스토리 (왜 이 결정을 했는가)
- `CLAUDE.md` — 규칙 (앞으로 어떻게 해야 하는가)
