# [프로젝트명] — Python (uv Workspace)

## Stack
- **Language**: Python 3.11+
- **Framework**: FastAPI (latest)
- **ORM**: SQLAlchemy 2.0 (async)
- **Migration**: Alembic (서비스별)
- **Validation**: Pydantic v2
- **Testing**: pytest + pytest-asyncio + httpx
- **Lint / Format**: ruff
- **Type Check**: mypy (strict)
- **Package Manager**: **uv (workspace mode)** — 루트 `pyproject.toml` 의 `[tool.uv.workspace]` 로 멤버 선언
- **Structure**: `services/api/`, `services/worker/`, `packages/shared/`

## Agents
| 작업 | Agent |
|------|-------|
| 새 파일 생성 | `python-generator` |
| 기존 코드 수정 | `python-modifier` |
| 테스트 작성 | `python-tester` |
| 코드 리뷰 | `code-reviewer` |

## 워크스페이스 레이아웃

```
.
├── pyproject.toml            # 워크스페이스 루트 (members 선언, 공통 dev deps)
├── uv.lock
├── alembic.ini               # services/api 용 (또는 서비스별 분리)
├── services/
│   ├── api/
│   │   ├── pyproject.toml    # FastAPI 서비스
│   │   ├── app/              # CLAUDE.python.md 구조와 동일
│   │   │   ├── main.py
│   │   │   ├── core/
│   │   │   ├── db/
│   │   │   ├── models/
│   │   │   ├── schemas/
│   │   │   ├── repositories/
│   │   │   ├── services/
│   │   │   ├── routers/
│   │   │   └── exceptions.py
│   │   ├── alembic/
│   │   └── tests/
│   └── worker/
│       ├── pyproject.toml
│       ├── app/
│       │   └── main.py       # 백그라운드 작업 진입점 (celery/arq/RQ)
│       └── tests/
└── packages/
    └── shared/
        ├── pyproject.toml    # 공유 타입·이벤트·유틸 (순수 라이브러리)
        └── src/shared/
            ├── __init__.py
            ├── types.py
            └── events.py
```

## 루트 `pyproject.toml`

```toml
[project]
name = "my-app"
version = "0.1.0"
requires-python = ">=3.11"

[tool.uv.workspace]
members = ["services/api", "services/worker", "packages/shared"]

[tool.uv.sources]
shared = { workspace = true }

[dependency-groups]
dev = [
    "pytest>=8.3",
    "pytest-asyncio>=0.24",
    "httpx>=0.28",
    "ruff>=0.7",
    "mypy>=1.13",
]

[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "UP", "B", "A", "C4", "SIM", "TCH", "ERA", "PL"]
ignore = ["PLR0913"]

[tool.mypy]
python_version = "3.11"
strict = true
plugins = ["pydantic.mypy"]
```

## 서비스 `pyproject.toml` (services/api)

```toml
[project]
name = "api"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "shared",
    "fastapi>=0.115",
    "uvicorn[standard]>=0.32",
    "sqlalchemy[asyncio]>=2.0",
    "alembic>=1.13",
    "asyncpg>=0.29",
    "pydantic>=2.9",
    "pydantic-settings>=2.6",
]
```

## 공유 패키지 (packages/shared)

`shared` 는 **순수 로직·타입 전용** — FastAPI, SQLAlchemy 를 import 하지 않습니다.

```toml
# packages/shared/pyproject.toml
[project]
name = "shared"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = ["pydantic>=2.9"]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["src/shared"]
```

```python
# packages/shared/src/shared/types.py
from typing import NewType

UserId = NewType("UserId", int)
OrderId = NewType("OrderId", int)
```

```python
# packages/shared/src/shared/events.py
from pydantic import BaseModel


class DomainEvent(BaseModel):
    event_type: str
    occurred_at: str
```

## 서비스에서 공유 패키지 사용

```python
# services/api/app/models/order.py
from shared.types import OrderId, UserId  # workspace import


class Order(Base):
    id: Mapped[OrderId] = mapped_column(primary_key=True)
    user_id: Mapped[UserId] = mapped_column(index=True)
```

## 의존 규칙

| 모듈 | 의존 가능 | 의존 불가 |
|------|----------|----------|
| `packages/shared` | (없음 — 순수) | `services/*` |
| `services/api` | `shared` | `services/worker` |
| `services/worker` | `shared` | `services/api` |

서비스 간 직접 import 금지 — 통신은 HTTP / 메시지 큐 / 이벤트 버스로만.

## 워크스페이스 명령

```bash
# 루트에서
uv sync                                 # 전체 워크스페이스 동기화

# 서비스 단위 실행
uv run --directory services/api uvicorn app.main:app --reload
uv run --directory services/worker python -m app.main

# 서비스 단위 테스트
uv run --directory services/api pytest
uv run --directory services/worker pytest

# 루트에서 일괄 실행
uv run ruff check .                     # 전체 린트
uv run ruff format --check .            # 전체 포맷 검증
uv run mypy services packages           # 전체 타입 체크
uv run pytest services packages         # 전체 테스트

# 의존성 추가 (특정 서비스)
uv add --project services/api fastapi
uv add --project packages/shared pydantic
```

## Alembic (서비스별 분리)

각 서비스가 자체 `alembic/` 을 보유. 루트에 단일 `alembic.ini` 를 두고 `script_location` 만 분기하거나, 서비스 디렉토리 안에 각자 `alembic.ini` + `alembic/` 를 둡니다.

**권장 — 서비스별 분리**:
```
services/api/
├── alembic.ini
├── alembic/
│   ├── env.py
│   └── versions/
└── app/
```

```bash
cd services/api
uv run alembic revision --autogenerate -m "..."
uv run alembic upgrade head
```

---

## 공통 규칙

단일 서비스의 아키텍처 규칙·FastAPI 라우터 규칙·테스트 규칙은 **services/api/CLAUDE.md (단일 모듈 버전)** 와 동일하게 적용됩니다. 루트 `CLAUDE.md` (이 파일) 는 워크스페이스 구조와 의존 경계만 다루고, 레이어별 세부 규칙은 각 서비스의 `CLAUDE.md` 를 참고하세요.

## 커버리지 게이트

**git push 전 각 서비스 라인 커버리지 80% 이상 필수** (`.claude/hooks/pre-push.sh` 자동 감지).

```bash
uv run --directory services/api pytest --cov=app
uv run --directory services/worker pytest --cov=app
```

---

## 학습된 규칙

<!-- /rule 커맨드로 새 규칙이 여기에 추가됩니다 -->

---

> 🧠 **새 작업을 시작하기 전에 `memory/MEMORY.md` 를 반드시 먼저 읽으세요.**
