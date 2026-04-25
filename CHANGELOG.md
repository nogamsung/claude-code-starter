# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> **릴리즈 규칙:** VERSION 파일을 올린 뒤 반드시 git 태그를 생성하고 푸시한다.
> ```bash
> git tag v$(cat VERSION) && git push origin v$(cat VERSION)
> ```

---

## [1.17.0] - 2026-04-25

### Added

**GHCR semver-only 정책 + CLAUDE.md ≤ 300줄 캡** — 패키지 레지스트리를 단일 진실 형식으로 통일하고, CLAUDE.md 비대화로 인한 매 세션 토큰 낭비를 차단.

**GitHub Actions 정책 강화 (`.claude/skills/github-actions-patterns.md` · `.claude/agents/github-actions-designer.md`)**:
- GHCR Docker 태그를 `MAJOR.MINOR.PATCH` + `latest` 단일 형식으로 제한 — `v1`, `v1.0`, `sha-*`, `dev` 등 비-semver 태그 발행 금지
- 안정 릴리스에만 `latest` 태그 자동 부여 (pre-release `-rc.1` 제외)
- publish 워크플로 끝에 `cleanup-non-semver` job 필수 — `actions/github-script` 로 비-semver GHCR 버전 자동 삭제
- 동일 semver 태그 overwrite 허용 — `workflow_dispatch` 트리거로 수동 재발행 가능
- 스테이징 이미지는 별도 레지스트리 또는 별도 패키지명(`{repo}-staging`) 으로 분리 권장

**CLAUDE.md ≤ 300줄 캡 (전 모드 강제)**:
- `CLAUDE.md` (이 저장소) — "1-1. CLAUDE.md ≤ 300줄" 핵심 원칙으로 추가
- `.claude/commands/init.md` — Step 3 모든 모드 공통으로 줄 수 검사 + 초과분 `.claude/skills/*.md` 이관 안내
- `.claude/commands/rule.md` — 새 Step 5 줄 수 가드 추가 (≤ 280 정상 / 281–300 경고 / > 300 차단)
- 전체 13개 `templates/CLAUDE.*.md` footer 에 한 줄 가드 인라인 — 사용자 프로젝트 즉석 편집에서도 보호
- 이유: CLAUDE.md 는 매 세션 로드. 1줄 줄이면 모든 협업자 × 모든 세션 토큰 절감

---

## [1.16.0] - 2026-04-20

### Added

**Tier 1 — 보안 리뷰 자동화 + Docker/Redis 패턴** — 기능 완성 시점에 보안 게이트를 강제하고, 컨테이너화·캐시 베스트 프랙티스를 스킬로 내재화.

**신규 agent:**
- `security-reviewer` — OWASP Top 10 + 스택별 보안 pitfall + 시크릿 유출 + 의존성 CVE 검토 전담. `/pr` Step 1.5 에서 **자동 호출**. Critical/High/Medium/Low 등급 + PASS/REVIEW/BLOCK 판정. 코드 수정은 안 하고 리포트만 반환.

**신규 skills (3):**
- `security-patterns.md` — OWASP Top 10 + 스택별(Python/Kotlin/Go/Next.js/Flutter) 보안 패턴. 비밀번호 해싱(bcrypt/argon2), CORS, CSP, rate limiting, 의존성 audit 명령어.
- `docker-patterns.md` — 스택별 멀티스테이지 Dockerfile + docker-compose.yml + .dockerignore 템플릿. distroless/alpine 베이스, non-root user, HEALTHCHECK 기본 포함.
- `cache-patterns.md` — Redis 패턴 (cache-aside, write-through, rate limiting, distributed lock, session, pub/sub) + 스택별 클라이언트 초기화. TTL 가이드·키 네이밍 컨벤션·캐시 무효화 전략 포함.

**신규 서브명령:**
- `/new dockerfile` — 현재 스택 감지 → 멀티스테이지 Dockerfile + .dockerignore + docker-compose.yml 생성. `--no-compose` 옵션 지원.

**수정:**
- `.claude/commands/pr.md` — **Step 1.5 "🔒 보안 리뷰 (자동, 필수)"** 추가. `security-reviewer` agent 가 staged diff 를 자동 검토하고 판정값에 따라 분기 (PASS → 진행, REVIEW → 사용자 확인, BLOCK → 차단 exit). `--skip-security` 옵션은 긴급 hotfix 용 예외 — 이유 입력 필수 + PR 본문에 경고 주입.

**개념 요약:**

| 시점 | 자동 개입 |
|------|-----------|
| 기능 구현 완료 → `/pr` | security-reviewer (Step 1.5) |
| Dockerfile 없을 때 `/new dockerfile` | docker-patterns 스킬 |
| 캐시/세션/rate-limit 구현 | cache-patterns 스킬 |

**보안 리뷰 판정 체계:**

| 판정 | 동작 |
|------|------|
| PASS | Critical/High 없음 → 바로 PR 생성 |
| REVIEW | High 1개 이상 → "계속 진행? (y/N)" 확인 |
| BLOCK | Critical 1개 이상 → exit, 수정 후 재실행 |

---

## [1.15.0] - 2026-04-23

### Added

**AI/ML agent 4종 + ai-patterns skill** — FastAPI 서비스 내부에 embedded 방식으로 AI 기능 통합. python-generator/modifier 와 영역 분리 기반 협업.

**신규 agents (4):**
- `ai-researcher` — AI/ML 리서치 전담 (모델·프레임워크 비교, 벤치마크 조사, 실험 설계). `docs/research/` 에 리포트 산출. 코드 미작성.
- `ai-generator` — LLM 호출, RAG chain, 프롬프트, 임베딩, PyTorch 훈련, HuggingFace 추론, MLflow 실험 코드 신규 생성. `app/ml/`, `app/chains/`, `app/prompts/`, `app/embeddings/` 담당.
- `ai-modifier` — 기존 AI 코드 수정·튜닝·리팩토링 (프롬프트 개선, LLM 모델 교체, RAG chain 수정, 성능 최적화, fine-tuning 재훈련).
- `ai-tester` — AI 테스트 (LLM 모킹 단위 테스트, 프롬프트 evaluation integration 테스트, RAG 품질, 모델 정확도). pytest + pytest-asyncio + marker 기반 (`integration`, `gpu`).

**신규 skill**: `.claude/skills/ai-patterns.md` — 7개 프레임워크 사용 패턴 + 디렉토리 구조 + 협업 프로토콜

**지원 프레임워크 (기본 내장):**

| 영역 | 프레임워크 |
|------|-----------|
| LLM SDK | Anthropic SDK + OpenAI SDK |
| LLM Orchestration | LangChain (LCEL) |
| ML 훈련 | PyTorch + scikit-learn |
| Model Hub | HuggingFace Transformers |
| Vector DB | pgvector (기존 Postgres 재사용) |
| Serving | FastAPI embedded (python-generator 협업) |
| 실험 추적 | MLflow |

**협업 모델** (A — Embedded):
- AI 코드가 **FastAPI 서비스 내부**에 위치 — 별도 service 분리 X (필요 시 v1.14.0 다중 service 로 분리 가능)
- **영역 분리**:
  - `app/ml/`, `app/chains/`, `app/prompts/`, `app/embeddings/` → **ai-\*** 담당
  - `app/routers/`, `app/schemas/`, `app/services/`, `app/models/`, `alembic/` → **python-\*** 담당
- **협업 프로토콜**: ai-generator 가 순수 함수 export → python-generator 가 Service 에서 import 해서 Router 로 HTTP 응답 변환

**수정:**
- `.claude/agents/python-generator.md` — "AI/ML 코드 협업" 섹션 추가 (영역 분리 표, 협업 예시)
- `.claude/agents/python-modifier.md` — 동일한 협업 섹션 + 공유 경계 상황 (시그니처 변경, pgvector Model 분담)
- `.claude/commands/init.md` — python/python-multi 유지 대상 표에 `ai-{researcher,generator,modifier,tester}` + `ai-patterns` skill 추가

**디렉토리 구조 (AI embedded 프로젝트):**
```
app/
├── ml/                # nn.Module, 훈련, 추론, 평가
├── chains/            # LangChain LCEL
├── prompts/           # 프롬프트 템플릿 (코드 분리)
├── embeddings/        # pgvector 저장·검색
│── (위는 ai-* 영역)
├── routers/           # python-*
├── schemas/
├── services/
├── models/            # SQLAlchemy ORM (pgvector Vector 컬럼 포함)
└── exceptions.py
```

**LLM 안전 규칙 (ai-patterns 기준):**
- 모든 호출 `async`, 싱글톤 클라이언트 재사용
- 실제 LLM API unit test 금지 — `AsyncMock` 으로 모킹, integration 은 `@pytest.mark.integration` 분리
- 비밀키는 `settings.ANTHROPIC_API_KEY` 경유 (Pydantic Settings), `os.environ` 직접 금지
- 모델 파일 (`*.pt`, `*.safetensors`, `mlruns/`) git 커밋 금지

**Backward compatibility:**
- 기존 python 프로젝트에 `app/ml/` 없으면 ai-* agent 는 로드되지만 호출되지 않음 — 회귀 없음
- pyproject.toml 의 `[project.optional-dependencies.ai]` 로 AI deps 분리 권장 — `uv sync --extra ai` 로만 설치

---

## [1.14.0] - 2026-04-23

### Added

**모노레포 — 동일 role 다중 service 지원** — 한 프로젝트에 **Kotlin backend + Python backend + Next.js frontend** 같은 조합 가능.

**`.claude/stacks.json` 스키마 확장 (backward compatible)**:
- `name` 필드 신규 — optional. role 이 유일하면 생략 가능, 동일 role 이 2개 이상이면 필수
- 동일 `role` 중복 허용 — `role:name` 조합이 service 식별자 역할
- 기존 stacks.json (name 없음, role 고유) 는 그대로 동작 — 회귀 없음

**디렉토리 명명 컨벤션 확장**:
- 기본: `backend/`, `web/`, `app/` (name 생략)
- suffix 패턴: `backend-auth/`, `backend-ml/`, `web-admin/`, `app-consumer/` (suffix 가 name)
- 허용 prefix: `backend-*`, `api-*`, `server-*`, `frontend-*`, `web-*`, `client-*`, `mobile-*`, `app-*`

**Service 식별자 문법 (`/new`, `/plan`, `/planner` 공통)**:
- `role` 단독 — service 가 1개면 자동 선택, 2개 이상이면 Interactive 프롬프트
- `role:name` — 명시 선택 (예: `/new backend:auth api User`)
- `name` 단독 — name 이 프로젝트 전체에서 유일할 때만 허용 (단축 문법)

**수정:**
- `.claude/commands/init.md`:
  - Step 1-2 감지 규칙 확장 — role 당 **전부** 스캔 (기존: 첫 번째만). suffix 자동 추출로 name 결정
  - Step 3-B-1 `.claude/stacks.json` 스키마 문서 업데이트 — 다중 backend 예시, name 규칙, service 식별자 정의
  - 이름 중복 충돌 검사 규칙 추가
- `.claude/commands/new.md`:
  - Step 0 재작성 — `role` / `role:name` / `name` 3가지 파싱 지원
  - jq 기반 service 해석 로직 — 1개 매칭 시 즉시, 2개 이상이면 interactive 프롬프트
- `.claude/commands/plan.md`:
  - Step 0 동일 문법 반영 — service 식별자 매칭 후 `STACK_PATH`/`STACK_TYPE` 추출
- `.claude/commands/planner.md`:
  - Step 6-a Teams 모드 — service 단위 병렬 실행 (역할 단위 X)
  - 프롬프트 파일명 규칙 확장: `docs/specs/{feature}/{role}.md` 또는 `{role}-{name}.md`

**예시 stacks.json (다중 backend):**
```json
{
  "mode": "monorepo",
  "stacks": [
    { "role": "backend",  "name": "auth", "type": "kotlin-multi", "path": "backend-auth" },
    { "role": "backend",  "name": "ml",   "type": "python",       "path": "backend-ml" },
    { "role": "frontend", "type": "nextjs", "path": "web" }
  ]
}
```

**사용 예시:**
```bash
/new backend:auth api User      # Kotlin backend 에 User 리소스
/new backend:ml api Prediction  # Python backend 에 Prediction 리소스
/new frontend component Card    # Next.js 에 Card 컴포넌트
/new backend api Foo            # backend 2개 → "auth / ml 중?" interactive
```

**Backward compatibility:**
- 기존 단일-role 모노레포 (backend + frontend + mobile) 는 그대로 동작
- `name` 없는 stacks.json 자동 호환 — role 이 고유하면 `/new backend` 는 즉시 실행
- 기존 프로젝트 마이그레이션 불필요

---

## [1.13.0] - 2026-04-23

### Added

**`/init product` 모드 — Product Management 전담 프로젝트 하네스** — `phuryn/pm-skills` 마켓플레이스(⭐10k+, MIT, 65+ 스킬/36 워크플로우/8 플러그인) 기반.

- `/init product` — Discovery / Strategy / PRD / OKR / GTM / Research / Analytics 전 과정을 pm-skills 의 커맨드 체인 (`/discover`, `/strategy`, `/write-prd`, `/plan-launch`, `/north-star` 등) 으로 처리
- 기반 프레임워크: Teresa Torres (Continuous Discovery), Marty Cagan (Inspired/Empowered), Alberto Savoia (Pretotyping)

**신규 파일:**
- `.claude/templates/CLAUDE.product.md` — PM 전담 프로젝트 컨텍스트 + 7단계 PM 워크플로 가이드 (Discovery → Strategy → Execution → Launch → Analytics → Research → 통합) + MUST/NEVER 규칙 + 디렉토리 구조 (`docs/{discovery,strategy,prd,stories,okrs,roadmap,launch,research,analytics}/`)
- `.claude/templates/settings.product.json` — pm-skills 마켓플레이스 8개 플러그인 + `marketing-skills` (보완) + github/commit/claude-md-management/hookify 플러그인 활성. 권한은 git · gh · 파일 작업만. 코드 빌드/테스트 훅 없음 (`safety-guard` + `session-start` 만)

**수정:**
- `.claude/commands/init.md`:
  - Step 1-1 인수 표에 `product` 행 추가
  - Step 1-2 자동 감지 경고 박스에 product 선택지 추가 (marketing/sales/product 모두 자동 감지 안 함)
  - Step 2 유지 대상 표에 `product` 행 추가 (유지: code-reviewer, planner, gtm-planner / 제거: 모든 코드 관련 agent·skill·template)
  - Step 3-C 섹션명을 "Marketing / Sales / Product 모드" 로 확장, 3-C-1/3-C-2/3-C-3 각각 product 분기 추가. 플러그인 가용성 확인 메시지에 pm-skills 마켓플레이스 + 8개 플러그인 설치 명령 포함
  - Step 6 완료 메시지에 "Product 모드" 블록 신규 추가 — 핵심 커맨드 목록 (`/discover`, `/strategy`, `/write-prd`, `/plan-launch`, `/north-star`) + 설치 안내 + 9단계 "이제 할 일"
- `bootstrap.sh` — 설치 후 echo 안내에 `/init product` 한 줄 추가
- `README.md` — `/init` 예시에 `/init product` + pm-skills 설치 안내 문단 추가

**pm-skills 플러그인 구성 (참고):**

| 플러그인 | 주요 커맨드 |
|---------|-----------|
| pm-product-discovery | `/discover`, `/brainstorm`, `/interview`, `/setup-metrics`, `/triage-requests` |
| pm-product-strategy | `/strategy`, `/market-scan`, `/business-model`, `/pricing`, `/value-proposition` |
| pm-execution | `/write-prd`, `/write-stories`, `/sprint`, `/plan-okrs`, `/pre-mortem`, `/stakeholder-map`, `/test-scenarios`, `/transform-roadmap`, `/generate-data`, `/meeting-notes` |
| pm-go-to-market | `/plan-launch`, `/battlecard`, `/growth-strategy` |
| pm-market-research | `/research-users`, `/competitive-analysis`, `/analyze-feedback` |
| pm-data-analytics | `/analyze-cohorts`, `/analyze-test`, `/write-query` |
| pm-marketing-growth | `/market-product`, `/north-star` |
| pm-toolkit | `/draft-nda`, `/proofread`, `/privacy-policy`, `/review-resume`, `/tailor-resume` |

**플러그인 자동화:** `enabledPlugins: true` 로 토글만. 마켓플레이스 등록(`/plugin marketplace add phuryn/pm-skills`)과 각 플러그인 설치는 사용자 몫 — init 완료 메시지가 설치 명령을 순서대로 안내.

---

## [1.12.2] - 2026-04-21

### Changed

**`/new worktree` — base 브랜치를 항상 origin 최신 기준으로 분기**

- 최상단에 "베이스 브랜치 규칙 (필수)" 박스 추가 — `/pr` 규칙과 완벽히 일관 (시작·끝 동일 기준)
- base 결정 로직 전면 교체:
  - `git fetch origin` 으로 remote 최신화 먼저 (오프라인 실패 시 폴백)
  - `git ls-remote --heads origin dev` 로 원격 `dev` 존재 체크 → `BASE_REF=origin/dev`
  - 없으면 `BASE_REF=origin/main`
  - fetch 실패 시 캐시된 `refs/remotes/origin/dev` 로 2차 폴백
- worktree 생성 시 `git worktree add .worktrees/... -b <branch> "$BASE_REF"` — **remote ref 에서 직접 분기**. `git checkout $BASE_BRANCH && git pull` 단계 제거
- 로컬 `dev`/`main` 브랜치의 stale 여부가 새 worktree 에 영향을 주지 않음
- Step 6 완료 메시지의 베이스 표시를 `$BASE_REF` 로 교체

**영향:** `/new feature-login`, `/new fix-signup` 등 worktree 를 만드는 모든 경로가 일관된 기준을 사용. 로컬 브랜치 관리 부담↓, 팀원 동기화 문제 감소.

---

## [1.12.1] - 2026-04-20

### Changed

**`/pr` 커맨드 — PR base branch 자동 감지 규칙 강화**

- 최상단에 "PR base branch 규칙 (필수)" 박스 추가 — 4가지 분기를 한눈에 볼 수 있게 명문화하고, 사용자·Claude 누구도 `gh pr create --base <다른브랜치>` 로 override 할 수 없다고 선언
- base 결정 로직 3가지 강화:
  - `git show-ref --verify --quiet refs/heads/dev` — 로컬 `dev` 체크 (기존)
  - `git ls-remote --heads origin dev 2>/dev/null` — **remote `origin/dev` 도 체크** (신규). 로컬에 `dev` 가 없어도 팀원이 origin 에 만든 `dev` 를 감지. 오프라인 실패 시 로컬 결과로 폴백
  - 현재 브랜치가 `dev` 면 `main` 으로 폴백 (신규) — `base == head` 방지 (GitHub 가 거부함)
- 주의사항에 "base branch override 금지" 항목 추가 — 특정 base 요구 시 "규칙 위반이지만 진행할까요?" 명시적 확인 후에만 수동 지정

**영향:** `/commit → /pr` 자동 체인에도 자동 반영. `/merge` 는 변경 불필요 (GitHub PR 생성 시점에 base 확정).

---

## [1.12.0] - 2026-04-20

### Added

**`marketing` / `sales` 단독 init 모드** — 코드 스택 없이 마케팅·세일즈 산출물만 관리하는 프로젝트용 하네스.

- `/init marketing` — 랜딩 카피·SEO·콘텐츠·광고·이메일 전담 프로젝트
- `/init sales` — 덱·콜드메일·객관 처리·가격·플레이북 전담 프로젝트
- 코드 관련 agent (`kotlin-*`, `go-*`, `python-*`, `nextjs-*`, `flutter-*`, `ui-designer`, `api-designer`) · skill (`*-patterns`, `ui-design-impl`) · 템플릿 (`CLAUDE.{코드스택}.md`) 모두 제거
- 유지: `planner` + `gtm-planner` + `code-reviewer` + 전체 커맨드
- `.claude/stacks.json` 미생성 — 코드 빌드/테스트 훅 비활성 (`pre-push` · `post-edit-lint` · `Stop` 제외, `safety-guard` + `session-start` 만)

**신규 파일:**
- `.claude/templates/CLAUDE.marketing.md` — 마케팅 전담 프로젝트 컨텍스트·규칙·디렉토리 구조
- `.claude/templates/CLAUDE.sales.md` — 세일즈 전담 프로젝트 컨텍스트·규칙·디렉토리 구조
- `.claude/templates/settings.marketing.json` — `marketing-skills@marketingskills` 플러그인 활성, 권한은 git·gh·파일 작업만
- `.claude/templates/settings.sales.json` — 동일 구성 (세일즈 용도 동일 스킬셋)

**수정:**
- `.claude/commands/init.md` — Step 1 인수 표·Step 2 유지 대상 표·Step 3-C (Marketing/Sales 전용 설치 경로)·Step 6 완료 메시지에 marketing/sales 모드 블록 추가. 빈 디렉토리에서 자동 선택은 **하지 않고** 명시 선택 요청
- `.claude/agents/gtm-planner.md` — marketing/sales 단독 모드에선 PRD 없이도 `raw_request` + `product-marketing-context` 만으로 진행 가능하도록 예외 조항
- `bootstrap.sh` — 설치 후 안내 echo 에 `/init python`, `/init marketing`, `/init sales` 세 줄 추가
- `README.md` — `/init` 예시 블록에 python/marketing/sales 모드 + 플러그인 설치 안내 각주

**플러그인 자동화 수준:** `enabledPlugins: true` 로 토글만 (플러그인 자체는 사용자 환경에 설치 필요). 미설치 시 `/init` 완료 메시지에 `/plugin install marketing-skills@marketingskills` 안내.

---

## [1.11.0] - 2026-04-19

### Added

**하네스 엔지니어링 인프라** — 토큰 효율·보안 가드·일관성 확보.

- 신규 커맨드: `/harness [check|doctor|dry-run <hook>|size|lint-settings]`
  - `check` — settings.json 유효성, 중복 Bash 권한, 훅 실행 권한, description 길이 검증
  - `doctor` — 발견된 문제 자동 수정 제안 (확인 후 적용)
  - `dry-run <hook>` — 훅 스크립트 테스트 입력으로 실행 (세션 영향 없음)
  - `size` — 세션마다 로드되는 항목별 토큰 영향 요약
  - `lint-settings` — settings.json 정책 (와일드카드, 중복 allow/deny) 엄격 검증
- 신규 공용 훅 스크립트 3개:
  - `hooks/session-start.sh` — SessionStart 훅, git/stack 간결 요약 주입 (~30줄 이내)
  - `hooks/safety-guard.sh` — PreToolUse(Bash) 훅, `main`/`master`/`production`/`release/*` 보호 브랜치에서 `git push --force*`, `git reset --hard`, `git commit --amend`, `git branch -D` 차단. `rm -rf /`, `rm -rf ~`, `DROP TABLE`, `TRUNCATE`, `DROP DATABASE` 는 브랜치 무관 차단
  - `hooks/post-edit-lint.sh` — PostToolUse 훅, 파일 확장자 기반 lint (py→ruff, go→gofmt, kt→ktlint, ts/tsx→eslint, dart→dart analyze). 모노레포면 stacks.json 경로 자동 lookup. 생성 파일(`*.g.dart`, `*.freezed.dart`, `*.pb.go`) skip
- 스타터 루트 `CLAUDE.md` 신규 — 스타터 자체 개발용 아키텍처 가이드 (토큰 회계, 변경 체크포인트, 기여 가이드)

### Changed

**토큰 최적화** — 사용자 세션마다 로드되는 파일 총 토큰 대폭 절감.

- CLAUDE.md 템플릿 10개 슬림화: **3,215줄 → 728줄 (-77%)**. 상세 코드 패턴은 `skills/{stack}-patterns.md` 로 이미 이관되어 있어 CLAUDE.md 는 규칙·표만 유지
- settings.*.json 10개 일괄 재작성:
  - `allow` 리스트에서 내장 도구 중복 제거 (`ls *`, `find *`, `grep *`, `cat *`) — Claude 가 Glob/Grep/Read 내장 도구로 유도됨
  - `enabledPlugins` 스택당 9~12개 → 5~8개. `context7`, `code-review`, `pr-review-toolkit`, `security-guidance` 기본값에서 제거 (필요시 사용자가 추가)
  - 인라인 Bash 훅을 공용 훅 스크립트 참조로 교체 — settings 파일 간결화 + 유지보수 단일 지점
- Agent description 8개 타이트닝 — `gtm-planner`, `code-reviewer`, `api-designer`, `kotlin-tester`, `python-generator`, `nextjs-tester`, `flutter-tester`, `python-tester` 평균 -40%

### Migration

기존 설치 프로젝트는 `/starter update` 또는 `bootstrap.sh` 재실행으로 최신 스타터 반영. 새 훅 3종이 자동 설치됩니다.
- 이전 인라인 Bash 훅을 커스터마이징한 프로젝트는 `.claude/hooks/post-edit-lint.sh` 를 직접 수정하면 됨 (settings.json 편집 불필요)
- `context7` 등 자동 제거된 플러그인 중 사용 중인 것은 `.claude/settings.json` 의 `enabledPlugins` 에 수동 추가

---

## [1.10.0] - 2026-04-19

### Added

**Python FastAPI 스택 지원** — 기존 4스택(Kotlin/Go/Next.js/Flutter) 에 Python FastAPI 백엔드 추가. 단일 모듈 `python` + uv workspace 기반 멀티 모듈 `python-multi` 모두 지원.

- 신규 agents (3): `python-generator`, `python-modifier`, `python-tester`
  - FastAPI + SQLAlchemy 2.0 (async) + Alembic + Pydantic v2 + pytest-asyncio
  - 레이어: `models/` (ORM) · `schemas/` (Pydantic) · `repositories/` · `services/` · `routers/` — Python 관용 네이밍
- 신규 skill: `.claude/skills/python-patterns.md` — 모델/스키마/리포지토리/서비스/라우터/Alembic/테스트 패턴 전체
- 신규 templates (4):
  - `CLAUDE.python.md` — 단일 스택용 아키텍처 규칙 + Pydantic v2 / SQLAlchemy 2.0 / FastAPI / Alembic / ruff / mypy 규칙
  - `CLAUDE.python-multi.md` — uv workspace (`services/api`, `services/worker`, `packages/shared`)
  - `settings.python.json`, `settings.python-multi.json` — uv/ruff/mypy/pytest/alembic 권한 + 파일 저장 시 ruff check + Stop 시 ruff+mypy 자동 실행 hook
- 패키지 매니저: **uv** (표준화) — poetry 대신
- API 문서: FastAPI 내장 OpenAPI (`/docs`, `/redoc`) — swagger 별도 생성 불필요
- `api-designer` agent 가 Python FastAPI 도 지원

### Changed

- `/init` — `python` / `python-multi` 스택 선언·자동 감지 (`pyproject.toml` + `fastapi` 의존성 또는 `[tool.uv.workspace]`)
- `/new` — Python 스택 감지 시 `api` 서브로 라우팅 (`python-generator` 호출), `module` 서브에 uv workspace 지원 (services/* vs packages/*), worktree 생성 시 `uv sync` 자동 실행
- `/plan api` — Python FastAPI 스택 추가
- `/plan db` — Alembic migration 가이드 (autogenerate + 수동 검토 + up/down 쌍)
- `/planner` — 스택 → agent 매핑에 `python` / `python-multi` → `python-generator` 추가
- `.claude/hooks/pre-push.sh` — Python 커버리지 게이트 추가 (`uv run pytest --cov --cov-report=xml` → `coverage.xml` line-rate 파싱, 임계값 90%)
- `settings.monorepo.json` — uv/ruff/mypy/pytest/alembic 권한 + 파일 저장 hook 에 Python 경로 감지 + Stop hook 에 python 스택 pytest 실행
- 모노레포 역할 경로 별칭은 기존 유지 (`backend`/`api`/`server` → backend) — Python 도 동일하게 `backend` 역할로 분류
- `CLAUDE.monorepo.md` — Python 커버리지 게이트 및 중첩 멀티모듈 감지 업데이트

### Migration

기존 설치 프로젝트는 `/starter update` 또는 `bootstrap.sh` 재실행으로 최신 스타터 반영. Python 프로젝트는 `/init python` 또는 `/init python-multi` 호출.

---

## [1.9.1] - 2026-04-17

### Changed

**GitHub Actions 자동 태깅 워크플로 추가** — `/merge` 없이 GitHub 웹에서 머지해도 태그가 자동 생성되도록.

- `.github/workflows/auto-tag.yml` 신규
  - 트리거: `main` 브랜치의 `VERSION` 파일 변경
  - 동작: VERSION 읽기 → `v${VERSION}` 태그 존재 확인 → 없으면 태그 생성·푸시 + GitHub Release 작성
  - Release 본문은 `CHANGELOG.md` 의 해당 버전 섹션에서 자동 추출 (awk 로 `## [X.Y.Z]` ~ 다음 `## [` 또는 `---` 사이)
- 기존 `/merge` 의 태그 로직은 유지 — 로컬 머지 시 즉시 태그 원하는 경우 fallback
- **누락 태그 회고 생성**: v1.6.0 (커밋 72dca2c), v1.8.0 (커밋 5c6ae22), v1.9.0 (커밋 aa521a3) — 이 PR 머지 후 수동 푸시

---

## [1.9.0] - 2026-04-17

### Added

**`/planner --marketing|--sales|--gtm` GTM 옵션** — 기능 기획 시 마케팅·세일즈 전략도 함께 생성.

- 새 `gtm-planner` agent (opus, Read/Write/Grep/Glob/Bash/Skill)
  - PRD 를 읽어 `marketing-skills:*` 스킬 체이닝으로 전략 초안 작성
  - 마케팅: `launch-strategy` → `content-strategy` → `copywriting` → `page-cro`
  - 세일즈: `sales-enablement` → `competitor-alternatives` → `pricing-strategy`
  - `marketing-skills` 미설치 시 템플릿 뼈대만 채우는 fallback 모드
- `/planner` 플래그 확장: `--marketing`, `--sales`, `--gtm` (= 둘 다)
  - 실행 모드 플래그(`--teams`/`--output-only`)와 조합 가능
- 산출물 2단 구조:
  - `docs/specs/{feature}/{marketing,sales}.md` — **살아있는 문서** (편집 가능)
  - `docs/gtm/{YYYY-MM-DD}-{feature}/` — **스냅샷** (릴리스 시 freeze)
    - `marketing.md`, `sales.md`, `meta.yaml` (feature/status/released_version)
- `docs/gtm/history.md` — 인덱스 (전체 시간순 + 버전별 조회)
- `/merge` 확장: 머지 후 해당 기능 스냅샷이 있으면 `released_version` 자동 기록 + 살아있는 문서로 스냅샷 재복사 + `history.md` 의 draft → released 전환
- 신규 템플릿: `marketing-plan.md`, `sales-plan.md`, `gtm-history.md`

---

## [1.8.0] - 2026-04-17

### Added

**`/marketing` 커맨드** — marketing-skills 플러그인 라우터.

- `/marketing` — 6개 카테고리(strategy/seo/cro/channel/retention/context) 메뉴 출력
- `/marketing <category> <task>` — 명시적 서브명령 (예: `/marketing seo audit`, `/marketing channel email`)
- `/marketing <자연어>` — 한·영 키워드 점수 매칭으로 최고점 스킬 1개 자동 실행
- `.agents/product-marketing-context.md` 존재 시 후속 스킬 호출에 컨텍스트 자동 주입
- 스택 무관 — monorepo 역할 prefix 체크 없음
- 35개 `marketing-skills:*` 스킬 커버 (copywriting, seo-audit, page-cro, email-sequence, paid-ads, churn-prevention, ab-test-setup 등)
- `.claude/settings.json` 에 `marketing-skills@marketingskills` 플러그인 활성화

---

## [1.7.0] - 2026-04-17

### Added

**모노레포 모드** — 한 저장소에서 backend + frontend + mobile 공존 지원.

- `/init` 이 루트의 `backend/`·`frontend/`·`mobile/` (별칭 `api`/`server`/`web`/`client`/`app`) 디렉토리를 스캔해 모노레포 자동 감지
- `.claude/stacks.json` — 활성 스택 매니페스트 (단일 진실의 원천)
- 루트 `CLAUDE.md` 는 인덱스, 각 스택 디렉토리에 역할별 `CLAUDE.md` 자동 배치
- `.claude/settings.json` 은 union permissions + 경로 가드 hooks (PostToolUse 가 편집 파일 경로로 스택 lookup)
- `.claude/hooks/pre-push.sh` 가 활성 스택 전체 순차 커버리지 검증 (한 스택 실패 시 전체 차단)
- Go 스택 커버리지 검증 추가 (`go test -coverprofile`)
- 역할 prefix 지원 — `/new backend api User`, `/new frontend component Button`, `/new mobile screen Login`
- `/plan` 도 동일한 역할 prefix 파싱 (`/plan backend api User`)
- 중첩 멀티모듈 지원 — `backend/` 내부가 `kotlin-multi`/`go-multi` 가능, `frontend/` 가 `nextjs-multi` (Turborepo) 가능

**`/planner` 커맨드 + `planner` agent** — 기획자 에이전트 추가.

- `/planner <기능>` — 사용자 요청을 받아 PRD + 역할별 구현 프롬프트 생성
- `planner` agent — Read/Write/Grep/Glob/Bash 로 코드베이스 맥락 스캔 후 PRD 작성 (코드는 작성하지 않음)
- `.claude/templates/prd.md` — 엔지니어용 한국어 PRD 템플릿 (12 섹션)
- `.claude/templates/role-prompt.md` — 역할별 구현 프롬프트 템플릿 (체크리스트 + 계약 + 실행 지시)
- **Agent Teams 옵션** — 생성된 프롬프트를 병렬 agent 호출로 즉시 실행 가능
  - `--teams` 플래그 → 바로 병렬 실행
  - `--output-only` 플래그 → 파일만 생성, 수동 실행
  - 플래그 없음 → 매번 사용자에게 선택 질문
  - 안전장치: teams 실행 전 한 번 더 확인

### Changed

- `pre-push.sh` 를 함수화하고 `.claude/stacks.json` 분기 추가 — 단일 스택 모드는 기존 동작 그대로
- 각 스택 `CLAUDE.md` 템플릿에 `/planner` 커맨드 행 추가
- `/init` 단일 스택 모드의 유지 대상에 `planner` agent + `prd`/`role-prompt` 템플릿 포함

### 마이그레이션 안내

- **단일 스택 사용자**: `.claude/stacks.json` 이 없으면 모든 훅·커맨드가 기존 동작으로 폴백 — 파괴적 영향 없음
- **모노레포 신규 설치**: `/starter update` → `/init` 재실행 시 자동 감지
- 기존 `/plan`, `/new` 사용법 그대로 유지

---

## [1.6.0] - 2026-04-17

### ⚠️ Breaking Changes

**커맨드 16개 → 11개로 재편 + 워크플로 단순화.** 기존 커맨드 이름은 더 이상 작동하지 않습니다.
`/starter update` 또는 `bootstrap.sh` 재실행으로 최신 커맨드를 받으세요.

| 이전 커맨드 | 새 커맨드 |
|------------|----------|
| `/new-api <Resource>` | `/new api <Resource>` |
| `/new-component <Name>` | `/new component <Name>` |
| `/new-screen <Name>` | `/new screen <Name>` |
| `/new-module <Name>` | `/new module <Name>` |
| `/new-workflow <Purpose>` | `/new workflow <Purpose>` |
| `/new-feature <type-name>` | `/new worktree <type-name>` |
| `/new-feature pr` | `/pr` + `/merge` (PR 생성과 머지 정리 분리) |
| `/design-api <Resource>` | `/plan api <Resource>` |
| `/design-db <도메인>` | `/plan db <도메인>` |
| `/review-api [대상]` | `/review api [대상]` |
| `/improve <설명>` | `/rule <설명>` |
| `/memory show` / `/memory` (조회) | 세션 시작 시 자동 로드 (호출 불필요) |

### Added

- **`/starter [check\|update]` 커맨드** — 스타터 버전 확인 / 재설치 (신규 install + update 통합 진입점)
- **`/pr` 커맨드** — 현재 브랜치 PR 생성. 완료 후 `/merge` 자동 제안. 기존 `/new-feature pr` 에서 분리
- **`/merge [auto]` 커맨드** — `gh pr merge` 로 GitHub 머지 실행 + main 최신화 + 버전 태그 + worktree 정리. `auto` 모드는 체크 통과 시 자동 머지 큐잉
- **`/commit` → `/pr` → `/merge` 자동 체인** — 각 단계가 다음을 제안하여 피처 브랜치에서 커밋부터 머지·정리까지 한 흐름으로 진행 (각 단계 확인 필요)
- **`/new` 디스패처 + 자동 감지** — api / component / screen / module / workflow / worktree 6개 서브명령 통합 + 스택·이름 패턴 기반 **서브명령 생략 가능** (`/new User` → Go/Kotlin은 api, Next.js는 component, Flutter는 screen 자동 분기 / `/new feature-login` → worktree / `/new publish kotlin` → workflow). 명시 서브명령은 override용으로 유지.
- **`/plan` 디스패처 확장** — 기존 범용 계획 + `api` / `db` 서브명령 흡수 (구 `/design-api`, `/design-db`)
- **`/review` api 모드** — 기존 `/review-api` 를 `/review` 내부 서브모드로 흡수
- **`/commit` 후 자동 PR 제안** — 피처 브랜치 감지 시 `/pr` 실행 여부 자동 제안
- **`memory/MEMORY.md` 자동 로드** — CLAUDE.md 템플릿에 세션 시작 시 자동 참조 지시 추가
- **`.claude/.starter-version`** — 설치된 스타터 버전 추적 파일 (팀 공유 대상)

### Changed

- `/rule` (구 `/improve`) — 네이밍을 "규칙 등록" 결과물 중심으로 개명
- `/memory` — `show` 모드 제거, 인수 없이 호출 시 도움말만 출력 (자동 로드로 대체됨)
- `bootstrap.sh` — 기존 `.claude/` 자동 감지, install/update 모드 분기, 확인 프롬프트 제거 (무조건 백업 없이 전체 교체), `.starter-version` 자동 기록
- `/init` — 스택별 제거 대상 목록 단일 표로 축소 (기존 7개 반복 섹션 → 표 1개). 커맨드는 전부 유지 (디스패처가 내부 분기)
- 전체 커맨드 내부 구조를 `상단 1줄 요약 → Step N → 출력 예시 → 주의사항` 포맷으로 통일, 중복·과한 설명 축소

### Removed

- 옛 커맨드 파일 11개: `new-api.md`, `new-component.md`, `new-screen.md`, `new-module.md`, `new-workflow.md`, `new-feature.md`, `design-api.md`, `design-db.md`, `design.md`, `review-api.md`, `improve.md`

---

## [1.5.3] - 2026-04-15

### Changed

- `/commit` — main 직접 커밋 금지, 항상 feature 브랜치에서 PR을 통해 머지
- `/new-feature pr` — PR 머지 후 정리 단계에 `git pull main` + 태그 생성 + 태그 푸시 추가

---

## [1.5.2] - 2026-04-15

### Changed

- `/commit` — 브랜치별 git 자동화 분기: `main`은 push+태그+태그푸시, feature는 push만

---

## [1.5.1] - 2026-04-15

### Changed

- `/commit` — 모든 커밋 타입에서 CHANGELOG 업데이트 필수화, Unreleased 방식 제거 (항상 버전 태그 발행)
- `/new-feature` — 베이스 브랜치 자동 감지 (`dev` 브랜치 있으면 `dev`, 없으면 `main`)
- `/init` — 브랜치 전략 선택 옵션 추가 (A. main+dev 기본값 / B. main only)

---

## [1.5.0] - 2026-04-15

### Added

- **`/design-api` 커맨드** — 코드 작성 전 REST API를 설계하는 인터랙티브 워크플로우
  - 스택 자동 감지 (`build.gradle.kts` → Kotlin, `go.mod` → Go)
  - 도메인 파악 → 엔드포인트 목록 → Request/Response 스키마 → OpenAPI 3.0 YAML 초안 5단계
  - 설계 완료 후 `/new-api`로 자동 연결
  - 백엔드 전용 (`/init nextjs`, `flutter` 시 제거 대상)
- **`/review-api` 커맨드** — 기존 REST API 코드 리뷰
  - RESTful 컨벤션 (URL 구조, HTTP 메서드, 상태코드) 체크
  - 보안 취약점 (인증 누락, 민감 데이터 노출, 입력값 검증 누락) 체크
  - OpenAPI 문서 완성도 체크 (SpringDoc `@Operation`/`@ApiResponse`, swag godoc 주석)
  - 높음/중간/낮음 심각도로 구분한 리뷰 결과 출력
  - 백엔드 전용 (`/init nextjs`, `flutter` 시 제거 대상)
- **`api-designer` agent** — REST API 설계 전문 에이전트
  - RESTful 컨벤션, 인증/인가 패턴, 페이지네이션, 에러 응답 표준화 전담
  - OpenAPI 3.0 YAML 템플릿 내장 (BearerAuth, PagedResponse, ErrorResponse 포함)
  - 백엔드 전용 (`/init nextjs`, `flutter` 시 제거 대상)
- **`api-design-patterns.md` 스킬** — REST API 설계 패턴 레퍼런스
  - URL 구조 원칙 (복수형 명사, 중첩 리소스, 액션 엔드포인트)
  - 표준 응답 형식 (단건·목록·커서 페이지네이션 envelope)
  - RFC 7807 Problem Details 에러 응답 패턴
  - 인증 스킴별 OpenAPI securityScheme 정의
  - 스택별 어노테이션 패턴 (SpringDoc vs swag godoc)
  - `/design-api` → `/new-api` 연결 플로우 다이어그램

### Changed

- `/commit` — 작업 완료 시 CHANGELOG·VERSION·memory 자동 업데이트 단계 추가 (문서 자동화)
- `/init` — kotlin/go 스택은 api 관련 파일 유지, nextjs/flutter 스택은 제거 목록에 추가

## [1.4.1] - 2026-04-15

### Changed

- **`/new-api` 통합** — `/new-go-api` 커맨드를 `/new-api`로 통합
  - `go.mod` 존재 시 Go Gin 스캐폴딩 자동 실행
  - `settings.gradle.kts` / `build.gradle.kts` 존재 시 Spring Boot 스캐폴딩 자동 실행
  - 스택 감지 실패 시 사용자에게 선택 요청

### Removed

- **`/new-go-api` 커맨드** — `/new-api`로 통합되어 제거

---

## [1.4.0] - 2026-04-15

### Added

- **`/design-db` 커맨드** — MySQL 스키마 설계 → Migration SQL 자동 생성
  - 스택 자동 감지 (`build.gradle.kts` → Flyway, `go.mod` → golang-migrate)
  - 도메인 설명 → ERD 텍스트 출력 → 검토 확인 → Migration SQL 파일 생성 5단계 자동화
  - 공통 컬럼(`id`, `created_at`, `updated_at`), FK 인덱스, `ENGINE=InnoDB utf8mb4` 자동 포함
  - 기존 migration 파일 번호 감지 후 다음 번호로 자동 생성
  - 생성 완료 후 `/new-api` / `/new-go-api` 연계 안내
- **`db-patterns.md` 스킬** — MySQL 설계 패턴 레퍼런스
  - 데이터 타입 선택 기준 (`DECIMAL` for 금액, `DATETIME(6)` for timestamps, `BIGINT UNSIGNED` for PK)
  - 공통 컬럼 패턴, 인덱스 전략, Soft Delete 패턴, FK 제약 옵션 가이드
  - Flyway 네이밍 컨벤션 (`V{N}__{description}.sql`)
  - golang-migrate 네이밍 컨벤션 (`{000000}_{description}.up/down.sql`)

### Changed

- `/new-api`, `/new-go-api` — DB 설계 선행 권장 안내(`/design-db`) 추가
- `CLAUDE.kotlin.md`, `CLAUDE.kotlin-multi.md`, `CLAUDE.go.md`, `CLAUDE.go-multi.md` — Commands 표에 `/design-db` 추가
- `/init` — kotlin/go 스택은 `design-db.md` 유지, nextjs/flutter 스택은 제거 목록에 추가

### Fixed

- **브랜치 네이밍 Git refs 충돌 수정** — `dev` 브랜치와 `dev/feature-*` 브랜치 동시 존재 불가 문제
  - 피처 브랜치 prefix를 `dev/` → `feature/`, `fix/`, `hotfix/` 등 독립 prefix로 변경
  - `new-feature.md`, `CLAUDE.*.md` 7개, `README.md` 일괄 수정

---

## [1.3.0] - 2026-04-15

### Added

- **멀티 모듈 프로젝트 지원** — Kotlin, Next.js, Go 3개 스택에 멀티 모듈 variant 추가
  - `/init kotlin-multi` — Gradle 멀티 모듈 (`api` / `domain` / `infra` 서브모듈, 모듈간 의존 규칙 포함)
  - `/init nextjs-multi` — Turborepo 멀티 패키지 (`apps/web`, `packages/ui`, `packages/lib`, `packages/config`)
  - `/init go-multi` — Go Workspace (`services/api`, `services/worker`, `pkg/shared`, `go.work`)
- **`/new-module` 커맨드** — 멀티 모듈 프로젝트에 새 서브모듈/패키지/서비스 추가
  - 프로젝트 타입 자동 감지 (`go.work` / `turbo.json` / `settings.gradle.kts` include 여부)
  - Kotlin: Gradle 서브모듈 생성 + `settings.gradle.kts` 자동 등록
  - Next.js: Turborepo 패키지 생성 (`apps/` 또는 `packages/` 선택)
  - Go: 서비스 모듈 생성 + `go.work` use 자동 등록
- **멀티 모듈 인식 커맨드 업데이트**
  - `/new-api`: `settings.gradle.kts` include 감지 시 파일을 각 모듈 경로로 분기 (Entity/Service → `:domain`, Repository Impl → `:infra`, Controller/DTO → `:api`)
  - `/new-go-api`: `go.work` 감지 시 대상 서비스 선택 후 해당 경로에 스캐폴딩
- **멀티 모듈 패턴 추가** — 스택별 skills 파일 확장
  - `kotlin-patterns.md`: `settings.gradle.kts`, 모듈별 `build.gradle.kts`, 모듈간 의존 표, 테스트 실행 커맨드
  - `nextjs-patterns.md`: `turbo.json`, workspace `package.json`, 패키지 의존 규칙, filter 실행 패턴
  - `go-patterns.md`: `go.work`, `go.mod` 멀티 서비스 패턴, 공유 도메인 패턴, workspace 빌드/테스트

### Changed

- `/init` — `kotlin-multi` / `nextjs-multi` / `go-multi` 옵션 추가, 자동 감지 로직 확장 (`go.work`, `turbo.json`, `settings.gradle.kts` include 감지)

---

## [1.2.0] - 2026-04-14

### Added

- **Git Worktree 병렬 작업 지원** — 모든 파생 프로젝트에 적용
  - `/new-feature` 커맨드 전면 개편: branch 생성 → worktree 생성 (`git worktree add .worktrees/feature-{n}`)
  - 스택별 의존성 자동 설치 (Go: `go mod download`, Node.js: `npm ci`, Gradle: `dependencies`, Flutter: `flutter pub get`)
  - `/init` 에 `.worktrees/` gitignore 자동 등록 단계 추가
  - 4개 CLAUDE 템플릿에 `Git 브랜치 전략 & 병렬 작업 (Worktree)` 섹션 추가
- **GitHub Actions — Docker 이미지 배포 (GitHub Container Registry)**
  - 스택별 멀티스테이지 Dockerfile (Kotlin: JDK builder→JRE, Go: golang→alpine, Next.js: deps→builder→runner)
  - 스택별 완성형 `publish.yml` — semver 태그 자동 생성 + `linux/amd64,linux/arm64` 멀티플랫폼
  - dev 브랜치 push → `:dev` 태그 스테이징 자동 배포 패턴
  - Flutter 제외 명시
- **백엔드 Swagger 문서화 필수 적용**
  - Kotlin: SpringDoc OpenAPI (`@Tag`, `@Operation`, `@ApiResponse`, `@Schema`) 패턴 + SwaggerConfig Bean
  - Go: swaggo/swag (`@Summary`, `@Tags`, `@Router`, `@Success`, `@Failure`, `example` 태그) 패턴
- **main / dev 브랜치 전략 확립**
  - `main ← dev ← dev/feature-{number}` 구조
  - `/init` 에서 `dev` 브랜치 자동 생성 + GitHub 브랜치 보호 규칙 안내
  - `/new-feature pr` 모드: `base: dev` PR 자동 생성
- **GitHub Actions 설계 에이전트** (`github-actions-designer`)
  - 스택별 CI 템플릿 (Next.js, Spring Boot, Go, Flutter)
  - 릴리스 자동화 (VERSION 파일 기반, semantic-release)
  - `/new-workflow` 슬래시 커맨드
- **Kotlin QueryDSL 필수 스택 지정**
  - `JpaRepository + RepositoryCustom + RepositoryImpl` 3세트 패턴
  - jOOQ 선택 사용 안내
- **Go sqlc + golangci-lint 필수 스택 지정**
  - 동적 쿼리 → sqlc, 단순 CRUD → GORM 기준 정립
  - `.golangci.yml` 기본 설정 패턴
- **커맨드/에이전트 전체 동기화**
  - `new-api.md`: QueryDSL 3세트 + SpringDoc 반영
  - `new-go-api.md`: sqlc + swaggo 반영
  - `kotlin-modifier.md` / `go-modifier.md`: 수정 체크리스트 업데이트
  - `code-reviewer.md`: Go 스택 추가 + 스택별 체크리스트 (SpringDoc/swaggo/QueryDSL/sqlc)

---

## [1.1.0] - 2026-04-14

### Added

- **Go Gin 스택 지원** — 4번째 지원 스택 추가
  - `go-generator` / `go-modifier` / `go-tester` 에이전트
  - `/new-go-api` 커맨드 — Handler / UseCase / Repository / Domain 스캐폴딩
  - `CLAUDE.go.md` 템플릿 — Clean Architecture 규칙, GORM, golang-migrate
  - `settings.go.json` 템플릿 — 공통 플러그인 + go vet / go test 훅
  - `/init go` 지원 (`go.mod` 자동 감지 포함)
  - 커버리지 게이트 Go 지원 — `go test -coverprofile` 기반 90% 차단
- **Skills 시스템** (`.claude/skills/`) — 스택별 코드 패턴을 agents에서 분리
  - `kotlin-patterns.md`, `nextjs-patterns.md`, `flutter-patterns.md`, `go-patterns.md`, `ui-design-impl.md`
  - agents 파일 경량화 (역할·워크플로 선언만 유지, 패턴은 skills 참조)

---

## [1.0.0] - 2026-04-14

### Added

- **bootstrap.sh** — curl 한 줄로 `.claude/` 폴더 설치 (sparse checkout)
- **`/init` 커맨드** — 스택 자동 감지 (Kotlin / Next.js / Flutter), 기존 프로젝트 분기, memory 초기화 + 프로젝트 인터뷰
- **`/memory` 커맨드** — Second Brain 조회·추가·검색, 6가지 자동 기록 트리거
- **`/improve` 커맨드** — AI 실수를 CLAUDE.md 규칙으로 누적
- **커버리지 게이트** — git push 시 90% 미만이면 차단
  - Kotlin: Jacoco (`jacocoTestReport`)
  - Next.js: Jest (`--coverage --coverageReporters=json-summary`)
  - Flutter: `flutter test --coverage`
- **스택별 CLAUDE.md 템플릿** — Kotlin / Next.js / Flutter
- **스택별 settings.json 템플릿** — `enabledPlugins`, `permissions.allow`, PreToolUse 훅
- **`ui-designer` 에이전트** — DESIGN.md 기반 디자인 시스템
  - Next.js: tailwind.config.ts + globals.css + shadcn/ui 테마 연동
  - Flutter: 디자인 토큰만 추출 (`lib/core/theme/`)
- **스택별 전문 subagent** — generator / modifier / tester 분리
- **플러그인 세팅** — 스택별 최적 Claude Code 플러그인 선정
  - 공통: github, context7, feature-dev, code-review, pr-review-toolkit, security-guidance, hookify, commit-commands, claude-md-management
  - Kotlin 추가: kotlin-lsp
  - Next.js 추가: typescript-lsp, frontend-design, playwright
- **`memory/MEMORY.md`** — 팀 Second Brain (git 커밋됨)

### Project Structure

```
claude-code-starter/
├── .claude/
│   ├── agents/          # ui-designer, 스택별 subagent
│   ├── commands/        # /init, /memory, /improve, /plan, /commit
│   ├── hooks/           # pre-push.sh (커버리지 게이트)
│   └── templates/       # CLAUDE.*.md, settings.*.json
├── memory/
│   └── MEMORY.md        # 팀 Second Brain
├── bootstrap.sh
├── CHANGELOG.md
├── README.md
└── VERSION
```

---

## Version History

| Version | Date       | Summary               |
|---------|------------|-----------------------|
| 1.5.3   | 2026-04-15 | PR 통한 main 머지 강제, PR 머지 후 태그 자동화 |
| 1.5.2   | 2026-04-15 | /commit 브랜치별 git 자동화 (main: push+태그, feature: push만) |
| 1.5.1   | 2026-04-15 | 문서 필수화, 브랜치 전략 자동 감지, /init 브랜치 옵션 추가 |
| 1.5.0   | 2026-04-15 | /design-api, /review-api 커맨드, api-designer 에이전트 추가 |
| 1.4.0   | 2026-04-15 | /design-db 커맨드 추가, 브랜치 전략 수정 |
| 1.3.0   | 2026-04-15 | 멀티 모듈 지원 (Kotlin Gradle / Next.js Turborepo / Go Workspace) |
| 1.2.0   | 2026-04-14 | Worktree 병렬 작업, Docker GHCR 배포, Swagger, 브랜치 전략, GitHub Actions |
| 1.1.0   | 2026-04-14 | Go Gin 스택 추가, Skills 시스템 도입 |
| 1.0.0   | 2026-04-14 | 초기 릴리즈            |
