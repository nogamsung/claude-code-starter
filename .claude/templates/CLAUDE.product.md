# [프로젝트명] — Product Management

## Mode
**코드 스택 없는 Product Management 전담 프로젝트.** 제품 발견(Discovery), 전략(Strategy), 실행(PRD/OKR/Roadmap), GTM, 리서치, 분석 등 PM 산출물만 관리합니다. 엔지니어링 구현은 별도 저장소에서 진행.

기반 프레임워크: **Teresa Torres** (Continuous Discovery), **Marty Cagan** (Inspired/Empowered), **Alberto Savoia** (The Right It).

## Agents & Commands
| 목적 | Agent / Command |
|------|----------------|
| 기획 → PRD + 구현 프롬프트 | `/planner <기능>` |
| GTM 전략 (마케팅+세일즈) | `/planner <기능> --gtm` · `gtm-planner` |
| 마케팅 작업 라우팅 | `/marketing [카테고리]` |
| 문서 리뷰 | `code-reviewer` · `/review` |
| 커밋/PR/머지 | `/commit` · `/pr` · `/merge` |
| Second Brain | `/memory [add\|search]` |
| 규칙 추가 | `/rule` |

## 필수 플러그인 — pm-skills

**`phuryn/pm-skills` 마켓플레이스 (8개 플러그인)** 가 없으면 핵심 커맨드 (`/discover`, `/strategy`, `/write-prd`, `/plan-launch` 등) 가 동작하지 않습니다.

**설치:**
```bash
# 1. 마켓플레이스 등록
claude plugin marketplace add phuryn/pm-skills

# 2. 8개 플러그인 설치 (순서 무관)
claude plugin install pm-toolkit@pm-skills
claude plugin install pm-product-discovery@pm-skills
claude plugin install pm-product-strategy@pm-skills
claude plugin install pm-execution@pm-skills
claude plugin install pm-go-to-market@pm-skills
claude plugin install pm-market-research@pm-skills
claude plugin install pm-data-analytics@pm-skills
claude plugin install pm-marketing-growth@pm-skills
```

**추가 선택**: `marketing-skills@marketingskills` — pm-marketing-growth 와 보완 (30+ 카피·SEO·광고 스킬).

## Git 전략
`main` / `dev` / `{feature|fix|chore|docs}/{name}`. Worktree `.worktrees/{type}-{name}/`. `main` 직접 push 금지, PR 필수. 모든 PM 산출물은 PR 리뷰 후 병합.

## 디렉토리 구조
```
docs/
├── discovery/            # 사용자 인터뷰·가설·실험 (pm-product-discovery)
│   ├── interviews/
│   ├── opportunities/    # opportunity-solution-tree
│   └── experiments/
├── strategy/             # 비전·포지셔닝·경쟁·BM (pm-product-strategy)
│   ├── vision.md
│   ├── positioning.md
│   ├── value-proposition.md
│   └── business-model.md
├── prd/                  # PRD (pm-execution:write-prd)
│   └── {feature}.md
├── stories/              # User stories (pm-execution:write-stories)
├── okrs/                 # OKR (pm-execution:plan-okrs)
│   └── {quarter}.md
├── roadmap/              # 로드맵 (pm-execution:transform-roadmap)
├── launch/               # GTM + 배틀카드 (pm-go-to-market)
│   ├── {feature}-launch.md
│   └── battlecards/
├── research/             # 유저·경쟁 리서치 (pm-market-research)
│   ├── users/
│   └── competitors/
├── analytics/            # 코호트·A/B·쿼리 (pm-data-analytics)
│   └── north-star-metric.md
├── specs/                # 기능별 살아있는 문서 (gtm-planner 와 공용)
│   └── {feature}/
│       ├── marketing.md
│       └── sales.md
└── gtm/                  # 릴리스 스냅샷 (날짜 기반)

memory/
└── MEMORY.md             # 결정·학습·리서치 인사이트
```

## 작업 흐름

### 1. 발견 (Discovery)
```
/discover                 # pm-product-discovery 의 4단계 체인
                          # brainstorm-ideas → identify-assumptions
                          # → prioritize-assumptions → brainstorm-experiments
/interview <주제>         # 사용자 인터뷰 가이드
/triage-requests          # 들어온 요청 분류
```

### 2. 전략 (Strategy)
```
/strategy                 # 전략 수립
/market-scan              # 시장 분석
/value-proposition        # 가치 제안
/business-model           # 비즈니스 모델 캔버스
/pricing                  # 가격 전략
```

### 3. 실행 (Execution)
```
/write-prd <기능>         # PRD 작성 — docs/prd/ 저장
/write-stories            # User stories
/plan-okrs                # OKR 계획 — docs/okrs/
/transform-roadmap        # 로드맵 변환
/pre-mortem               # 사전 부검
/stakeholder-map          # 이해관계자 지도
/sprint                   # 스프린트 플랜
/meeting-notes            # 회의록
```

### 4. 런치 (GTM)
```
/plan-launch              # 런치 플랜 — docs/launch/
/battlecard               # 경쟁 대응 카드
/growth-strategy          # 성장 전략
```

### 5. 분석 (Analytics)
```
/north-star               # 북극성 지표
/analyze-cohorts          # 코호트 분석
/analyze-test             # A/B 테스트 분석
/write-query              # SQL 쿼리 작성
```

### 6. 리서치 (Research)
```
/research-users           # 유저 리서치
/competitive-analysis     # 경쟁 분석
/analyze-feedback         # 피드백 분석
```

### 7. 통합
```
/planner <기능>           # PRD + 역할별 프롬프트 (pm-skills 와 조합 가능)
/planner <기능> --gtm     # + 마케팅 + 세일즈 전략
/merge                    # 릴리스 → docs/gtm/ 스냅샷 자동 freeze
```

## MUST
- **모든 산출물은 `docs/` 하위** — 루트에 문서 흩뿌리기 금지
- **PM 프레임워크 기반 의사결정** — Teresa Torres 의 Opportunity Solution Tree, Alberto Savoia 의 Pretotyping 등 pm-skills 가 제공하는 프레임워크 우선
- **가설·증거 명시** — discovery 산출물은 "가정 → 증거 → 결론" 구조 필수
- **PRD 는 `/write-prd` 스킬로만** — 임의 포맷 금지, 팀 일관성 유지
- **OKR 은 분기별 파일** — `docs/okrs/2026-Q2.md` 식 명명
- **인터뷰 녹취록 익명화** — 실제 이름·이메일·회사명 금지 (Persona1, UserA 식)
- **중요한 결정·학습은 `/memory add`** 로 기록 — 다음 iteration 에 재활용

## NEVER
- **코드 작성 금지** — 이 프로젝트는 PM 전담 (구현은 별도 저장소)
- **실제 유저 PII (이메일·이름·전화) 커밋 금지** — 인터뷰 로그 익명화 필수
- **경쟁사 내부 정보 무단 기록 금지** — 공개 자료 기반만
- **전략 문서 덮어쓰기 금지** — 변경 시 새 파일 (`vision.md` → `vision-2026.md` 로 snapshot)
- **"그냥 감" 기반 의사결정 금지** — 최소 하나의 프레임워크 인용 (RICE, ICE, JTBD, MoSCoW 등)
- **`docs/gtm/` 스냅샷 직접 수정** — `/merge` 를 통해서만 갱신

## 명령어
```bash
git status / log / diff
gh pr list / view / create
```

## 학습된 규칙
<!-- /rule 로 여기에 추가됩니다 -->

## Memory
세션 시작 시 `memory/MEMORY.md` 자동 로드. 리서치 인사이트·실패한 가설·전략 피벗·경쟁 동향은 `/memory add` 로 기록.
