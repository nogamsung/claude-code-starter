# Second Brain — Claude Code Starter

> 이 파일은 프로젝트의 기관 기억(institutional memory)입니다.
> 기술 결정, 교훈, 반복되는 패턴을 여기에 누적하세요.
> 규칙은 `CLAUDE.md`, 맥락과 히스토리는 이 파일에 기록합니다.

---

## 2026-05-08: v1.27.0 — P3 두 번째 (opt-in 사용량 텔레메트리)

**카테고리:** 결정

### 배경
"어떤 command/agent 를 가장 많이 쓰는가" 데이터 없이 토큰 절감·UX 의사결정 진행 중. 어떤 자산을 더 다듬을지, 어떤 hook 을 더 무겁게 할지 모름. 익명·opt-in·로컬 누적으로 본인 작업 패턴 가시화.

### 결정

**3가지 핵심 정책**:

1. **opt-in (디폴트 disabled)** — `.claude/settings.local.json` 의 `"telemetry": true` 명시해야 동작. 사용자 신뢰의 가장 큰 가치는 "묻지 않고 동작 안 함".
2. **외부 전송 0** — 로컬 `.claude/.usage.json` 파일에만 누적. anonymous opt-in upload 옵션도 미제공 (남용 우려).
3. **tool_name 만 수집** — `Bash`/`Edit`/`Read` 같은 카운트만. 명령 내용·파일 경로·입출력 모두 기록 안 함. PII 위험 0.

**구현**:
- `hooks/usage-counter.sh` (PostToolUse) — opt-in 게이팅 + jq 로 atomic 갱신
- `hooks/session-start.sh` 에 top 5 tool 한 줄 출력
- 14개 settings 템플릿 `hooks.PostToolUse` 에 일괄 등록
- `.gitignore` 에 `.usage.json` + `settings.local.json` 추가 (기존 README 약속이었으나 누락)

### 의식적 배제

- **익명 업로드 옵션** — 한번 켜면 데이터 통제 어려워짐. 신뢰성 최우선.
- **command 별 집계** — slash command 는 사용자 직접 입력이라 PostToolUse 에서 못 잡음. tool 카운트로 우회.
- **input/output 기록** — PII 누출 위험. tool_name 만 충분.
- **시간대별 집계** — 형식 단순화, 누적 카운트만.
- **자동 활성화 안내** — settings.local.json 자동 생성·수정 안 함. 사용자가 의식적으로 활성화.

### 사용자 흐름
```bash
echo '{"telemetry": true}' >> .claude/settings.local.json  # 활성화
# ... 작업 ...
cat .claude/.usage.json     # 직접 확인
# 비활성화: telemetry 키 false 또는 제거
rm .claude/.usage.json      # 누적 데이터 초기화
```

### 변경 파일
```
.claude/hooks/usage-counter.sh        # 신규 (32줄)
.claude/hooks/session-start.sh        # +9줄 (Usage 표시)
.claude/templates/settings.*.json     # 14개 (PostToolUse 에 hook 추가)
.gitignore                            # .usage.json + settings.local.json 추가
README.md, README.en.md (배지)
CHANGELOG.md, VERSION (1.26.0 → 1.27.0)
```

### Dogfooding
이 저장소도 opt-in 활성화하면 maintainer 자신의 작업 패턴 가시화 가능. README/CHANGELOG/skills 중 어느 카테고리가 토큰을 가장 많이 쓰는지 다음 결정의 데이터.

### 다음 P3 후보
- plugin marketplace 등록 (Anthropic 승인 필요 — 큰 작업)

---

## 2026-05-08: v1.26.0 — P3 첫 번째 (i18n: English README)

**카테고리:** 결정

### 배경
P0/P1/P2 의 핵심 격차는 정리됨. P3 후보 3건 (i18n / 텔레메트리 / plugin marketplace) 중 가장 영향 큰 i18n 부터.

한국어 only 상태 → 글로벌 채택의 가장 큰 마찰. 영문 README 가 없으면 한국 외 사용자는 첫 페이지에서 이탈.

### 결정

**README 만 i18n, templates 는 그대로**:
- `README.en.md` 신규 (402줄) — 한국어 README 와 동일 구조의 영문 번역
- 양쪽 최상단에 언어 토글 (`[🇰🇷 한국어](README.md) · [🇬🇧 English](README.en.md)`)
- `templates/CLAUDE.{stack}.md` 9개는 **한국어 그대로** — 사용자 프로젝트로 복사되는 자산이라 i18n 시 매 세션 토큰 ×2

### 의식적 배제 (의도된 lazy translation)

**1. templates/ i18n 거부**
- 토큰 비용 ×2: `CLAUDE.kotlin.ko.md` + `CLAUDE.kotlin.en.md` 둘 다 유지하면 매 세션 어느 한쪽이 항상 dead weight
- 사용자가 자기 프로젝트 언어에 맞게 번역하는 게 더 자연스러움 (`/init` 후 직접 편집)
- 결정: README 만 i18n, templates 는 user-side i18n 위임

**2. 자동 동기화 거부**
- `README.en.md` 가 한국어 변경에 자동 따라가게 만드는 GHA 안 검토 → 거부
- 이유: LLM 자동 번역은 뉘앙스 손실. "stale 해도 한국어가 source of truth" 명시 + 사용자가 PR 로 동기화
- README.en.md 마지막 섹션에 명시: "Translations track the Korean source. If they ever drift, the Korean README is authoritative."

**3. CLAUDE.md / CHANGELOG / 기타 i18n 거부**
- README 가 entry point. 그 안에 들어온 사람은 영문 자료 없어도 코드 읽을 수 있음 (개발자).
- README 만 i18n 하는 게 80/20.

### 변경 파일
```
README.en.md             # 신규 (402줄)
README.md                # 최상단 언어 토글 추가, 배지 갱신
CHANGELOG.md, VERSION (1.25.0 → 1.26.0)
```

### 다음 P3 후보
1. opt-in 텔레메트리 (사용량 집계 → 토큰 절감 의사결정 근거)
2. 자체 plugin marketplace 등록 (Anthropic 승인 필요 — 큰 작업)

---

## 2026-05-08: v1.25.0 — P2 세 번째 (AI prompt regression — ai-eval-patterns skill)

**카테고리:** 결정

### 배경
ai-tester agent 가 단위/통합/RAG 테스트 패턴은 다루지만 **회귀 검증 (regression / eval)** 영역이 비어 있었음. LLM 출력은 비결정적이라 `assert ==` 가 안 통하는데, 그에 대응하는 표준 프로세스 부재.

기존 ai-patterns.md 가 530줄로 비대해 거기에 추가하면 가드레일 부담. 별도 skill 분리.

### 결정

**`ai-eval-patterns.md` 신설** (별도 skill, 202줄) — 4가지 검증 layer:

1. **Golden snapshot** — 가장 흔한 패턴
   - `tests/fixtures/prompts/{case}.json` (입력) + `{case}.golden` (기대 출력)
   - `UPDATE_GOLDEN=1 pytest` 로 갱신
   - golden 변경은 **항상 PR 에 포함 + 리뷰** — 자동 갱신 후 검토 없이 머지 금지

2. **LLM-as-judge** — 자유 형식 답변
   - rubric → score (1-5) → threshold 통과 여부
   - **target ≠ judge 모델** — 같은 모델로 자기 평가 = 가짜 합격

3. **메트릭 기반** (BLEU/ROUGE/embedding cosine) — 보조만
   - 의미 무시 등 한계 명시
   - 단독 사용 금지

4. **RAG 분리 평가** — retrieval recall + answer grounding
   - 검색 정확도와 생성 충실도를 나눠 측정

### 핵심 정책 결정

**1. Golden 자동 갱신 거부**
- v1.17.0 사고 (CHANGELOG 누락) 와 같은 교훈 — "검증 없는 자동 갱신" 은 의도 누락 위험.
- `UPDATE_GOLDEN=1` 은 명시적 갱신 모드, 결과는 PR diff 로 리뷰어 검증.

**2. judge 모델 분리 강제**
- target 이 sonnet 이면 judge 는 haiku. 같은 모델로 자기 평가 시 false positive 빈발 (논문 Anthropic eval 가이드).

**3. CI 비용 게이트**
- PR CI = mocked + golden (무료, 빠름)
- nightly = real LLM (낮은 비용)
- weekly = full eval set 100+ cases (높은 비용)
- 매 PR 실 호출 안티패턴 명시

**4. eval set 사람 큐레이션**
- LLM 자동 생성 거부 — 노이즈 + 정답 편향. 최소 5~10 케이스를 사람이 만들어야.

### 의식적 배제

- **`assert response == expected` 비결정 출력에** — golden + UPDATE_GOLDEN 패턴
- **temperature=0 결정성 강제** — 일부 모델만 지원, 미세 변동 여전
- **단일 케이스 합격** — 최소 5~10 fixture, 다양성 확보
- **eval set LLM 자동 생성** — 정답 편향
- **mock 없이 매 PR 실 호출** — 비용 폭증 + flaky CI

### 변경 파일
```
.claude/skills/ai-eval-patterns.md    # 신규 (202줄)
.claude/agents/ai-tester.md           # 워크플로 step 3 추가
.claude/commands/init.md              # python/python-multi/모노레포-python/infra 4 군데
README.md, CHANGELOG.md, VERSION (1.24.0 → 1.25.0)
```

### 다음 P2 후보
1. 추가 코드 스택 (Rust / NestJS / Django) — 사용자 요청 누적 시
   (P2 마지막 항목)

---

## 2026-05-08: v1.24.0 — P2 두 번째 (DevOps/Infra 카테고리 신설)

**카테고리:** 결정

### 배경
P2 후보 4건 중 가장 큰 공백 — 5개 코드 스택 (kotlin/go/python/nextjs/flutter) + 3개 코드 없는 모드 (marketing/sales/product) 외 인프라 영역이 통째로 비어 있었음. 사용자가 자기 앱의 helm chart, terraform module, k8s manifest 를 다룰 때 참조할 패턴 없음.

### 결정

**한 PR 로 인프라 클래스 통째 신설** — skill 3개 + agent 1개 + template 2개 + /init infra 모드:

1. **skill 3개**: terraform/kubernetes/helm 각각 ~130줄. 패턴 + 의식적 배제 + 운영 체크리스트.
2. **infra-generator agent (단일)**: modifier/tester 분리 안 함 — 인프라는 변경 빈도 낮고 작업 단위가 거의 generator 와 동일.
3. **/init infra 모드**: 코드 없이 IaC 만 다루는 프로젝트용. 자동 감지 안 함 (백엔드 프로젝트의 부속 인프라일 수 있음).

### 핵심 정책 결정

**1. Helm vs kustomize 우선순위**
- 자기 앱 manifest = kustomize (template 엔진 X, 단순)
- 외부 OSS (Prometheus, Cert-Manager 등) = Helm
- `helm-patterns.md` 의 첫 섹션이 이 결정 명시

**2. terraform workspace 배제**
- 환경 분리에 부적합 (같은 backend 의 다른 key 만 다를 뿐 blast radius 동일)
- 디렉토리 분리 (`envs/{prod,staging,dev}/`) 가 안전
- 예외: 동일 환경 multi-region 만 workspace 가능

**3. K8s 필수 항목**
- resources requests/limits — 미설정 = 안티패턴 (노드 OOM 시 random kill)
- liveness ≠ readiness — 둘 다 정의 (재시작 vs 트래픽 차단)
- image tag = SemVer 명시, latest 금지
- Secret 평문 금지 — ExternalSecret/SOPS/Sealed Secrets

**4. apply 자동화 거부**
- `settings.infra.json` 의 deny 리스트에 `terraform apply -auto-approve`, `kubectl delete namespace`, `helm uninstall` 명시
- 운영 환경 실수 차단

**5. modifier/tester agent 분리 안 함**
- 코드 스택은 generator/modifier/tester 3종이지만, 인프라는 generator 한 개로 충분
- 이유: 인프라 변경 빈도 낮음, 단위 테스트 개념 약함 (terraform plan/k8s dry-run 자체가 검증), modifier 와 generator 경계 모호 (대부분 새 모듈 추가 또는 변수 추가)

### 변경 파일
```
.claude/skills/terraform-patterns.md      # 신규 (129줄)
.claude/skills/kubernetes-patterns.md     # 신규 (147줄)
.claude/skills/helm-patterns.md           # 신규 (138줄)
.claude/agents/infra-generator.md         # 신규 (70줄)
.claude/templates/CLAUDE.infra.md         # 신규 (100줄)
.claude/templates/settings.infra.json     # 신규
.claude/commands/init.md                  # infra 모드 행 + 자동 감지 안내 갱신
README.md, CHANGELOG.md, VERSION (1.23.0 → 1.24.0)
```

### 의식적 배제

- **infra 자동 감지** — `*.tf`, `Chart.yaml` 마커는 백엔드 프로젝트 부속일 수 있어 가정 안 함. 명시 선택만.
- **infra-modifier / infra-tester** — 코드 스택 패턴 답습 안 함. 인프라 컨텍스트엔 generator 만으로 충분.
- **모노레포 공통 유지에 infra-generator 추가** — 모노레포가 너무 비대해짐. 인프라 작업은 별도 infra 모드로 분리.

### 다음 P2 후보
1. AI prompt regression suite (ai-tester 보강)
2. 추가 코드 스택 (Rust / NestJS / Django) — 사용자 요청 누적 시

---

## 2026-05-08: v1.23.0 — P2 첫 번째 (observability-patterns skill)

**카테고리:** 결정

### 배경
P1 5건 완료 → P2 카테고리 진입. P2 후보 4건 (observability / DevOps-Infra / 추가 스택 / AI prompt regression) 중 가장 영향 범위 넓은 observability 부터.

### 결정

**Observability 영역을 단일 skill 로 통합** — 스택별로 분산하지 않음:
- 후보: 스택별 `observability-{kotlin,go,python,nextjs,flutter}.md` 5개로 쪼개기
- 결정: **횡단 단일 skill** (`observability-patterns.md`) — 패턴 (logging, tracing, error tracking, SLO) 자체는 스택 무관. 스택별 라이브러리만 표 형태로 매핑.
- 이유: 토큰 효율 (5번 로드보다 1번), 일관성 (필드 컨벤션 한 곳에 정의), 유지보수 비용 (5분의 1)

### 핵심 정책 결정

**1. structured logging 필드 컨벤션**
- `ts`, `level`, `msg`, `trace_id`, `span_id`, `service`, `env` — 모든 스택 공통 필수
- 이벤트 이름 = 스네이크케이스 명사 (`user.signup`)
- PII 직접 로깅 금지 (ID 만)

**2. OTel 환경변수 표준화**
- `OTEL_EXPORTER_OTLP_ENDPOINT` / `OTEL_SERVICE_NAME` / `OTEL_RESOURCE_ATTRIBUTES`
- 5개 스택 모두 동일 환경변수 — 인프라 한 곳에서 설정

**3. Flutter OTel 한계 명시**
- Dart SDK 미성숙 → Sentry 또는 Firebase Performance 권장. 거짓 약속 안 함.

**4. SLO 3개 이내 권고**
- Availability / Latency p99 / Error rate 만. "관리 가능 범위" 강조.

### 의식적 배제

- **모든 함수에 span** — 비용 폭증, 안티패턴
- **개발 환경 OTLP 강제** — 로컬 노이즈 → `OTEL_SDK_DISABLED=true`
- **4xx Sentry 전송** — 사용자 입력 오류는 알람 가치 없음

### 변경 파일
```
.claude/skills/observability-patterns.md  # 신규 (122줄)
.claude/commands/init.md                  # 5개 스택 + 모노레포 공통에 추가
README.md, CHANGELOG.md, VERSION (1.22.0 → 1.23.0)
```

### 다음 P2 후보 우선순위
1. DevOps/Infra (terraform/k8s/helm) — 완전 비어있는 영역
2. 추가 코드 스택 (Rust/NestJS/Django) — 사용자 요청 누적되면
3. AI prompt regression (snapshot/golden 테스트) — ai-tester 보강

---

## 2026-05-08: v1.22.0 — P1 묶음 (MCP 프리셋 skill + session-start plugin 표시)

**카테고리:** 결정

### 배경
P1 카테고리 5건 중 3건 (`/upgrade`, `/release`, P0 4건) 완료. 남은 2건 (MCP 프리셋, plugin health check) 둘 다 작은 작업이라 한 PR 에 묶음.

### 결정

**MCP 프리셋 — skill 로만 제공, 자동 활성화 X**:
- `settings.{stack}.json` 에 `mcpServers` 디폴트 채우는 안을 검토 → 배제.
- 이유: 잘못된 환경변수 (`${DATABASE_URL}` 미설정) 로 매 세션이 npx 다운로드 또는 connection error 로 깨질 수 있음. 사용자가 의식적으로 활성화하는 것이 안전.
- 결정: `.claude/skills/mcp-presets.md` 에 스택별 snippet 만. 사용자가 `settings.local.json` (개인) 또는 `settings.json` (팀 공유) 에 직접 붙여넣음.
- 5개 MCP 커버: postgres, filesystem, github, puppeteer (Next.js), fetch (marketing).

**Plugin health check — 표시만, 검증 X**:
- session-start.sh 가 enabledPlugins 의 plugin 키를 `claude plugin list` 로 검증 가능한지 검토 → 그런 CLI 명령 없음.
- Claude Code 내부 plugin 설치 상태는 외부 bash hook 에서 알 수 없음.
- 결정: enabledPlugins 키 한 줄 표시 + `/plugin install` 안내. 사용자가 `/plugin` 으로 직접 확인.
- settings.json + settings.local.json 합집합 — 개인 plugin 도 표시 (jq -s `.[]` 가 아닌 `to_entries[]` 로 두 파일 union 처리).

### 의식적 배제

- **mcpServers 디폴트 활성화** — 파괴 위험 vs 편의성. 안전 우선.
- **plugin 자동 설치** — `/plugin install` 은 사용자 동의 필요. hook 에서 자동 호출 부적절.
- **enabledPlugins 미설치 plugin 강제 제거** — 사용자가 임시로 비활성화한 것일 수 있음.

### 변경 파일
```
.claude/skills/mcp-presets.md         # 신규 (~140줄)
.claude/hooks/session-start.sh        # +10줄 (Plugins 표시)
README.md, CHANGELOG.md, VERSION (1.21.0 → 1.22.0)
```

### P1 카테고리 마무리
| P1 항목 | 버전 | 상태 |
|---------|------|------|
| /upgrade selective diff | v1.20.0 | ✅ |
| /release 자동화 | v1.21.0 | ✅ |
| MCP 프리셋 | v1.22.0 | ✅ |
| Plugin health check | v1.22.0 | ✅ (표시만) |

P1 5건 (#5–#8 + P0) 모두 완료. 다음은 P2 (DevOps/Infra, Observability, 추가 스택, AI prompt regression) 또는 P3 (i18n, 텔레메트리, plugin marketplace).

---

## 2026-05-08: v1.21.0 — P1 `/release` 커맨드 (SemVer + CHANGELOG 동기화 + PR 체인)

**카테고리:** 결정

### 배경
v1.17.0 → v1.17.1 사고 (CHANGELOG 누락 + README 배지 미갱신) 가 **사람이 매 릴리스마다 동일 작업을 수동으로 하다 빠뜨린** 결과. v1.18.0 ~ v1.20.0 까지도 매번 VERSION + CHANGELOG + README + memory 4개 파일을 손으로 갱신. 한 단계 자동화 안 하면 같은 사고가 반복됨.

### 결정

**`/release [patch|minor|major]` 커맨드 신설** — 릴리스 단계를 한 번에:
1. 사전 조건 검증 (브랜치 ≠ main, working tree 깨끗)
2. SemVer bump 계산
3. CHANGELOG 검증 (사용자가 미리 작성했어야 — 없으면 템플릿 안내 후 종료)
4. CHANGELOG 헤더의 버전·날짜 자동 sync
5. VERSION 갱신
6. README 배지 갱신 (`version-X.Y.Z-blue`)
7. `chore(release): vX.Y.Z` 커밋
8. `/pr` 체인 (--no-pr 가 아니면)

### 핵심 정책 결정

**1. CHANGELOG 자동 작성 금지 — 검증만**
- 자동 생성 시 의도 누락 가능성 (어떤 카테고리, 왜 변경했는지). v1.17.0 사고가 "사람의 누락" 이지 "자동화 부재" 가 아님.
- 사용자가 작성 안 했으면 템플릿 보여주고 정중히 종료.

**2. main 브랜치 호출 거부**
- 우리 패턴은 별도 release PR 이 아니라 **기능 PR 에 VERSION/CHANGELOG 동시 bump** (v1.18.0~1.20.0 모두). `/release` 가 이 패턴을 강제.

**3. 태그 push 안 함**
- `auto-tag.yml` 이 main 의 VERSION 변경을 감지해 태그 자동 생성. `/release` 가 직접 태그하면 중복.

### 의식적 배제

- `/release --auto-changelog` 같은 자동 생성 옵션 — v1.17 사고 재발 방지를 위해 일부러 미제공
- `/release` 가 main 으로 직접 push — 기능 PR 패턴 강제 (위 정책 2)
- pre-release (`-rc.1` 등) 지원 — GitHub Actions 에서도 명시적으로 stable 만 latest 태그. `/release` 도 stable 만.

### 변경 파일
```
.claude/commands/release.md      # 신규 (198줄)
README.md                         # 빠른 시작에 /release 안내
CHANGELOG.md, VERSION (1.20.0 → 1.21.0)
```

### Dogfooding 한계
이번 v1.21.0 자체는 `/release` 가 도입되는 PR 이라 본인을 사용해 자기를 릴리스할 수 없음 (chicken-and-egg). v1.21.1 부터 본격 dogfood.

---

## 2026-05-08: v1.20.0 — P1 `/upgrade` selective diff 커맨드

**카테고리:** 결정

### 배경
v1.19.0 에서 `bootstrap.sh` 가 custom 자산을 보존하도록 개선됐지만 갱신 단위는 여전히 all-or-nothing. 사용자가 "skills 만 새로 받아보고 싶다", "agents 변경 없이 hooks 만 갱신" 같은 부분 갱신을 원할 때 경로 없음. 큰 변경(예: 26개 agents 일괄 변경) 을 한 번에 적용하기엔 심리적 부담이 큼.

### 결정

**`/upgrade` 커맨드 신설** — 카테고리 단위 selective diff:
- `agents`, `commands`, `skills`, `templates`, `hooks`, `settings` 6개 카테고리
- 디폴트는 dry-run (통계만), `apply <cat>` 로 명시적 적용
- `--version <ref>` 로 임의 시점 비교 가능 (롤백 결정용)
- 보존 정책은 bootstrap.sh 와 동일 (`custom/` + `settings.local.json`)

### 인터페이스 결정 사유

세 가지 후보 중 **카테고리 단위** 선택:
1. **카테고리 단위** ✅ — 변경 단위가 자연스럽고 인터랙션 1~2회로 끝남
2. 파일별 fine-grained — 정밀하지만 인터랙션 폭증 (8개 변경이면 16번 Y/N)
3. 프리셋 (minimal/standard/full) — 단순하지만 사용자 의도와 매핑 안 맞음

### 사용 시나리오

```
/upgrade                      → 통계 (예: skills +0 ~2 -0)
/upgrade apply skills         → skills 만 갱신
/upgrade --version v1.18.0    → 1.18.0 과 비교 (롤백 결정용)
/upgrade apply all            → bootstrap update 호출
```

### `/starter` 와의 관계

| 커맨드 | 입자 | 인터랙션 |
|--------|------|----------|
| `/starter update` | 전체 | 1회 확인 |
| `/upgrade apply <cat>` | 카테고리 | 카테고리당 1회 |
| `/upgrade apply all` | 전체 | `/starter update` 와 동일 (내부 호출) |

`/upgrade apply all` 이 bootstrap.sh 를 그대로 호출하므로 `/starter` 와 기능 중복 같지만, **diff 보기 → 부분 적용 흐름** 이 `/upgrade` 의 핵심 가치. 둘 다 유지.

### 변경 파일
```
.claude/commands/upgrade.md     # 신규 (205줄)
README.md                        # 빠른 시작에 /upgrade 안내
CHANGELOG.md, VERSION (1.19.0 → 1.20.0)
```

### 한계
- 카테고리 단위 부분 갱신 시 의존성 불일치 가능 (예: `commands/` 만 갱신했는데 새 command 가 미설치 agent 호출). 사용자에게 경고 명시.
- `templates/` 갱신은 사용자 루트 `CLAUDE.md` 에 영향 없음 — `/init` 재실행 시에만 반영.

---

## 2026-05-07: v1.19.0 — P0 안정성 패치 (bootstrap 비파괴 + 버전 핀 + CI 매트릭스 + 300줄 가드)

**카테고리:** 결정

### 배경
v1.18.0 까지 `/start` 등 사용자 경험은 다듬어졌으나, **하네스 자체의 안정성 격차** 4건이 누적돼 있었음:
1. `bootstrap.sh` update 가 사용자 custom agent/hook/`settings.local.json` 을 통째로 덮어씀 → 매 update 마다 사용자 자산 손실 위험.
2. 버전 핀·롤백 불가 — 깨진 릴리스 발생 시 복구 수단 없음.
3. README 가 "PR 전 `bootstrap.sh` 직접 실행" 을 약속하지만 CI 검증 없음.
4. CLAUDE.md ≤ 300줄 캡 (v1.17.0) 이 정책으로만 존재, hook 가드 없음.

### 결정

**P0 4건 일괄 패치**:

1. **`bootstrap.sh` 디폴트 보존 모드** — `agents/custom/`, `commands/custom/`, `hooks/custom/`, `skills/custom/`, `settings.local.json` 자동 보존. `--no-preserve` 가 escape hatch.
2. **`--version <ref>` 핀 옵션** — `git fetch --depth=1 origin <ref>` 로 임의 태그/브랜치/SHA 체크아웃 후 sparse-checkout. `curl | bash -s -- --version v1.x.x` 형태.
3. **`.starter-version-prev` 자동 기록** — update 시 직전 버전을 보존 디렉토리 경유로 기록 → `/starter rollback` 으로 toggle 복원 가능.
4. **`/starter` 커맨드 확장** — `check` 가 3개 버전(현재/최신/이전) 표시, `update --version` 핀, `rollback` 신설.
5. **CI install matrix** — fresh-install / update-preserve / update-no-preserve / version-pin / rollback-meta / hooks-on-empty-project / claude-md-line-cap 7개 job.
6. **CLAUDE.md 300줄 가드 hook** — `post-edit-lint.sh` 의 case 에 `*CLAUDE.md|*CLAUDE.*.md` 추가, 초과 시 경고 + 이관 가이드.

### 사용자 자산 디렉토리 규약 (신설)

스타터 update 후에도 보존되는 영역:
```
.claude/agents/custom/     .claude/commands/custom/
.claude/hooks/custom/      .claude/skills/custom/
.claude/settings.local.json
```

루트 직속(`agents/`, `commands/` 등) 에 둔 사용자 파일은 update 시 사라짐. 이 정책을 README + `/starter` 커맨드에서 명시.

### 영향
- 사용자 update 시 자산 손실 위험 0
- 깨진 릴리스 발생 시 30초 안에 rollback 가능
- 매 PR 마다 install/update/preserve/pin/rollback 시나리오 자동 검증
- CLAUDE.md 비대화 hook 으로 즉시 차단

### 변경 파일
```
bootstrap.sh                                  # --version, --no-preserve, --preserve, 보존 로직, prev 기록
.claude/commands/starter.md                   # check/update/rollback 재작성
.claude/hooks/post-edit-lint.sh               # CLAUDE.md case 추가
.github/workflows/install-matrix.yml          # 신규 (7 jobs)
README.md                                     # 옵션 + 보존 규약 + rollback 안내
CHANGELOG.md, VERSION (1.18.0 → 1.19.0)
```

### 검증
로컬에서 fresh-install / update-preserve / update-no-preserve / `--version v1.17.0` 핀 / 빈 프로젝트 hook silent / 300줄 가드 트리거 — 6개 시나리오 모두 통과.

### 마이그레이션
- 기존 `bootstrap.sh` 사용자: 변경 불필요. 새 디폴트가 더 안전.
- custom agent/command 가 있는 사용자는 `custom/` 하위로 이동 권장.

---

## 2026-04-27: v1.18.0 — 신규 기능 시작 흐름 단순화 (`/start` 신설 + `/planner` → `/plan` 흡수)

**카테고리:** 결정

### 배경
신규 기능 시작이 `/new worktree → /planner → /plan` 3단계로 분리돼 있어 사용자 인지 부담이 컸음. `/planner` 와 `/plan` 의 범용 모드가 거의 동일 (둘 다 소크라테스식 인터뷰 + 자연어 요청 처리) 해서 어떤 걸 쓸지 매번 망설이게 했음. 모노레포에선 인터랙션 2회 (실행 모드 선택 + 안전장치 yes/no) 가 매번 발생.

### 결정

**`/start <기능>` 신설** — 신규 기능 시작의 단일 진입점:
1. worktree 자동 생성 (`feature/{name}`, base = origin/dev 또는 origin/main)
2. planner agent 호출 → PRD + 역할별 프롬프트
3. 단일 스택은 자동 generator 실행 / 모노레포는 1회만 확인
4. 인터뷰는 요청이 명확하면 0개 — 모호할 때만 최대 3개

**`/plan` 이 `/planner` 흡수**:
- 디폴트 = PRD + 역할 프롬프트 (이전 `/planner` 동작, 실행 없음)
- `--teams` = PRD 후 즉시 generator (이전 `/planner --teams`)
- `--light` = 가벼운 단일 변경 계획 (이전 `/plan` 범용 모드)
- `api`/`db` 서브 그대로
- `--marketing|--sales|--gtm` 그대로

`commands/planner.md` 제거 — frontmatter description 1개 절감 (매 세션 로드되는 토큰).

### 영향
- 사용자 흐름 5 inputs → 1~2 inputs (신규 기능 시작 마찰 80% 감소)
- 모노레포 인터랙션 2회 → 1회
- frontmatter description 14 → 13 (스킬 리스트 토큰 절감)
- 본문은 on-invoke 이지만 통합으로 ~150줄 절감

### 변경 파일 (총 19개)
```
.claude/commands/start.md            # 신규
.claude/commands/plan.md             # planner 흡수 (271→390줄, 통합 효과)
.claude/commands/planner.md          # 삭제
.claude/commands/init.md             # 완료 메시지에 /start 우선 안내
.claude/agents/{planner,gtm-planner,security-reviewer}.md  # 호출자 표기 갱신
.claude/templates/CLAUDE.{kotlin,go,python,nextjs,flutter}.md  # 5개 — 표에 /start 행 추가
.claude/templates/CLAUDE.{monorepo,marketing,sales,product}.md # 4개 — /planner → /plan 또는 /start
.claude/templates/{role-prompt,gtm-history}.md             # 호출자 표기 갱신
README.md, CHANGELOG.md, VERSION (1.17.1 → 1.18.0)
```

### 마이그레이션
- `/planner X` → `/plan X`
- `/planner X --teams` → `/start X` (worktree 포함) 또는 `/plan X --teams` (worktree 없이)
- `/new worktree feature-X` + `/planner X` → `/start X` 한 번에

---

## 2026-04-25: v1.17.0 — GHCR semver-only 정책 + CLAUDE.md ≤ 300줄 캡

**카테고리:** 결정

### 배경
GitHub Packages (GHCR) 가 publish 워크플로 호출마다 `v1`, `v1.0`, `1.0.0`, `latest`, `sha-*` 등 5–7개 태그를 동시에 만들어내며 패키지 목록이 비대화. 동시에 사용자 프로젝트의 CLAUDE.md 도 정해진 상한 없이 비대해져 매 세션 토큰 낭비가 누적되는 패턴 관찰. 두 문제 모두 "단일 진실의 형식"이 없어서 발생한 것으로 보고 한 릴리스에서 묶어 정책화.

### 핵심 결정

1. **GHCR 태그는 `MAJOR.MINOR.PATCH` + `latest` 만** — `v1`, `v1.0`, `sha-*`, `dev`, `pr-*` 모두 발행 금지. 이전 docker/metadata-action 의 multi-tag 출력 (`{{major}}`, `{{major}}.{{minor}}`) 도 전부 삭제. semver 단일 vs 부분 태그 혼용은 캐시·롤백 모호성을 만들어 운영 사고 위험이 더 큼.
2. **`latest` 는 안정 릴리스에만** — pre-release (`-rc.1`, `-beta`) 는 enable 조건 `!contains(github.ref_name, '-')` 로 제외. `is_default_branch` 가 아닌 ref 기반 — 릴리스는 무조건 태그에서 트리거되므로.
3. **non-semver cleanup 은 같은 워크플로 안에서** — publish job 의 needs 후속으로 `cleanup-non-semver` job 강제. `actions/github-script` + `packages.deletePackageVersion*` API 로 자동 삭제. cleanup 을 별도 scheduled workflow 로 빼면 사용자가 끄거나 잊을 수 있음 — publish 와 한 묶음으로 강제.
4. **동일 semver overwrite 허용 + `workflow_dispatch` 트리거** — 정정 빌드(예: 같은 1.2.3 재빌드)는 의도된 동작. GHCR 은 기본 덮어쓰기.
5. **스테이징 이미지는 별도 패키지명** — production GHCR 에 비-semver 태그가 단 하나도 없어야 cleanup job 이 안전하게 동작. 스테이징 필요 시 `{repo}-staging` 별도 패키지 또는 별도 레지스트리 사용 권장.
6. **CLAUDE.md ≤ 300줄 — 4곳 분산 가드** — 한 곳에만 두면 우회 가능. 스타터 핵심 원칙 1-1 (이 저장소) / `/init` Step 3 (설치 시) / `/rule` Step 5 (규칙 추가 시) / 13개 templates footer (사용자 즉석 편집 시). 280–300 경고, > 300 차단.
7. **이관 형식: `상세: .claude/skills/{topic}.md` 한 줄** — 인덱스 패턴 통일. claude code 가 필요시에만 skill 파일을 on-demand 로드.

### 철학
- **단일 진실의 형식이 없으면 비대화는 시간 문제** — 패키지 태그도, 컨텍스트 파일도. 형식을 좁히면 자동 정리/검증이 가능해짐.
- **정책은 가능한 가장 가까운 곳에서 강제** — GHCR cleanup 을 별도 cron 으로 빼지 않고 publish 워크플로 끝에 묶은 것, CLAUDE.md cap 을 install/rule/template 모든 진입점에 박은 것 동일한 원리.
- **사용자 매 세션 비용을 0이 아닌 수로 곱한 값이 토큰 비용** — CLAUDE.md 1줄은 100명 × 매 세션. 10줄 줄이면 1000줄/일 절감.

### 영향 범위
- 신규 사용자 프로젝트: `/init` 시점부터 두 정책 자동 적용
- 기존 사용자 프로젝트: `/starter update` 또는 직접 적용 필요
- 스타터 자체 publish 워크플로는 .github/workflows 에 별도 publish.yml 이 없어서 이번 릴리스에는 영향 없음 (정책만 라이브러리에 추가)

### 후속
- v1.17.1 — README.md version badge 1.16.0 → 1.17.1 업데이트, 본 메모리 항목 추가 (v1.17.0 릴리스 시 누락된 부수 문서 갱신)

---

## 2026-04-20: v1.16.0 — Tier 1 보안 리뷰 자동화 + Docker/Redis 패턴

**카테고리:** 결정

### 배경
기능 구현 완료 시점에 보안 검토가 수동이었고, Dockerfile·Redis 패턴도 프로젝트마다 재발명하고 있었음. 기능이 머지되기 직전에 **반드시 통과해야 하는 게이트**로 보안을 못박고, 컨테이너·캐시 베스트 프랙티스를 스킬로 내재화.

### 핵심 결정

1. **security-reviewer 는 agent, 개입 시점은 `/pr` Step 1.5** — 사용자가 기능을 만들 때마다 마지막 단계에서 자동 호출. 코드 수정은 안 하고 리포트만 반환 (수정은 해당 스택의 modifier agent).
2. **3단계 판정 체계** — PASS/REVIEW/BLOCK. Critical 1개면 exit (강제 차단), High 1개면 확인 후 진행, 나머지는 경고만.
3. **`--skip-security` 는 hotfix 전용 예외** — 이유 입력 필수 + PR 본문에 경고 주입. 일반 개발 플로우엔 쓰지 말 것.
4. **Docker 는 `/new dockerfile` 서브명령으로 분리** — `/new` 의 기존 api/component/screen 라인에 얹어서 호출. `docker-patterns.md` 스킬이 실제 템플릿 공급.
5. **Redis/Cache 는 스킬 only** — 별도 커맨드 없음. ai-generator/python-generator/kotlin-generator 가 필요 시 `cache-patterns.md` 읽고 적용. 과도한 커맨드 증식 방지.

### 철학
기능 게이트는 command/skill 레이어가 아니라 **agent 호출 자체**로 강제해야 안 우회됨 — `/pr` 하면 반드시 security-reviewer 가 돈다. 우회 옵션(`--skip-security`)은 있지만 비용이 높게(이유 요구 + PR 본문 경고) 설계.

### 구조

```
.claude/
  agents/security-reviewer.md        # 신규 agent (opus, Read/Grep/Bash/Skill)
  skills/security-patterns.md        # OWASP + 스택별 체크리스트
  skills/docker-patterns.md          # 멀티스테이지 + compose + .dockerignore
  skills/cache-patterns.md           # Redis cache/rate-limit/lock/session
  commands/pr.md                     # Step 1.5 보안 리뷰 자동 실행 추가
  commands/new.md                    # dockerfile 서브명령 추가
```

---

## 2026-04-17: v1.9.0 — /planner GTM 옵션 + gtm-planner agent

**카테고리:** 결정

### 배경
v1.8.0 의 `/marketing` 은 카피·SEO 같은 **task 단위** 라우터였고, 기능 단위 GTM 문서(포지셔닝·런치 체크리스트·세일즈 덱)를 체계적으로 생산·보관할 수단이 없었음. 기획(/planner PRD) ↔ 마케팅/세일즈 전략 ↔ 실제 릴리스 버전을 **한 축으로** 연결하는 구조가 필요했음.

### 핵심 결정

1. **플래그 확장, 서브명령 없음** — `/planner <기능> --marketing|--sales|--gtm`. 기존 `--teams`/`--output-only` 패턴과 일관.
2. **전담 agent 분리** — `planner` (PRD 전담) / `gtm-planner` (GTM 전담). 코드 작성은 둘 다 금지. 도구 차이 — gtm-planner 만 `Skill` 보유해 `marketing-skills:*` 체이닝 가능.
3. **2단 산출물 구조** — `docs/specs/{feature}/{marketing,sales}.md` 은 **살아있는 문서**, `docs/gtm/{YYYY-MM-DD}-{feature}/` 은 **스냅샷**. 중복처럼 보이지만 의도적 — 편집 vs 기록을 분리.
4. **날짜 + 버전 두 축 히스토리** — 디렉토리는 날짜 기반 (초안 시점), `meta.yaml` 의 `released_version` 은 버전 기반 (`/merge` 에서 자동 기록). `history.md` 는 두 관점 모두로 조회 가능.
5. **재기획 시 새 디렉토리** — 동일 feature 재GTM 하면 기존 스냅샷 보존하고 새 날짜 디렉토리 추가. 히스토리성.
6. **`/marketing` 과 역할 분리** — `/marketing` = task 단위 스킬 라우터, `/planner --gtm` = 기능 단위 종합 문서. 상호 보완, 대체 아님.

### 구조

```
.claude/
  agents/gtm-planner.md                 # 신규 agent (opus, Skill 포함)
  commands/planner.md                   # --marketing/--sales/--gtm 플래그 추가
  commands/merge.md                     # 3-2b 단계 추가 — GTM 스냅샷 릴리스
  templates/marketing-plan.md           # 살아있는/스냅샷 템플릿
  templates/sales-plan.md
  templates/gtm-history.md

docs/
  specs/{feature}/marketing.md          # 살아있는
  specs/{feature}/sales.md
  gtm/history.md                        # 인덱스
  gtm/{date}-{feature}/                 # 스냅샷
```

### 열린 이슈
- `/merge` 의 브랜치명 → feature 이름 추출이 `feature/*` / `fix/*` 등 표준 prefix 를 가정. 비표준 브랜치명이면 매칭 실패
- history.md 편집 로직이 python3 의존 — 다른 환경에선 meta.yaml 만 갱신됨

---

## 2026-04-17: v1.8.0 — /marketing 커맨드 + marketing-skills 플러그인

**카테고리:** 결정

### 배경
코드 생성 중심의 기존 커맨드 셋(/new, /plan, /planner 등) 외에, 마케팅·카피·SEO·CRO 같은 **비개발 워크플로**를 Claude Code 안에서 일관되게 처리할 수 있는 진입점이 없었음. `marketing-skills` 플러그인이 35개의 전문 스킬을 제공하지만, 어떤 스킬을 언제 호출해야 하는지 매번 기억해야 하는 부담이 있었음.

### 핵심 결정

1. **라우터 커맨드로 구현** — `/marketing` 은 코드를 작성하지 않는 순수 라우터. 35개 스킬을 6개 카테고리(strategy/seo/cro/channel/retention/context)로 압축해 인지 부하 축소.
2. **3-layer 진입 방식** — (a) 메뉴 (인수 없음) → (b) 서브명령 (`/marketing seo audit`) → (c) 자연어 (`/marketing 회원가입 전환율이 낮아`). 자연어 모드는 한·영 키워드 점수 매칭으로 **최고점 1개 자동 실행** (동점 시 표 등장 순서상 위쪽 우선).
3. **카테고리 6개로 고정** — 35개를 flat 하게 나열하면 선택 비용이 높아, 사용 빈도·의미 단위로 6개로 묶음.
4. **`product-marketing-context` 는 자연 호출** — 전용 서브명령을 두지 않고, 최초 실행 시 한 번만 설정을 권유. 강제하지 않음.
5. **스택 무관** — monorepo 역할 prefix(backend/frontend/mobile) 체크 없이 그대로 실행.

### 구조

```
.claude/commands/marketing.md    # 라우터 커맨드 (3-layer 진입)
.claude/settings.json            # marketing-skills@marketingskills 플러그인 활성화
```

### 열린 이슈
- 자연어 라우팅 점수 정확도는 사용 로그로 보정 필요 (현재는 표 등장 순서 우선)
- `.agents/product-marketing-context.md` 가 없는 최초 사용자의 UX — 현재는 안내만 하고 강제하지 않음

---

## 2026-04-17: v1.7.0 — 모노레포 모드 + 기획자 agent

**카테고리:** 결정

### 배경
기존에는 `/init` 이 **한 스택만** 선택하고 나머지 agent/template 를 삭제하는 구조였음. 그러나 실제로는 `backend/` + `frontend/` + `mobile/` 을 한 저장소에서 운영하는 조직이 많고, 매 저장소마다 다른 하네스를 유지하면 일관성이 깨졌음. 또한 기능 기획 → 구현 사이에 "각 스택에 어떤 지시를 내릴지" 를 매번 수동으로 작성하는 부담이 있었음.

### 핵심 결정

1. **모노레포 자동 감지 + 단일 스택 호환** — 루트에서 `backend|api|server/`, `frontend|web|client/`, `mobile|app/` 디렉토리를 스캔해 2개 이상이면 `monorepo` 모드, 1개/0개면 기존 단일 스택 로직으로 폴백. 파괴적 변경 없음.
2. **`.claude/stacks.json` 을 단일 진실의 원천으로** — `/new`, `/plan`, `/planner`, `pre-push.sh`, PostToolUse/Stop hooks 가 모두 이 파일을 읽어 분기. 없으면 기존 동작.
3. **CLAUDE.md 중첩 배치** — 루트는 얇은 인덱스, 각 역할 디렉토리에 `{path}/CLAUDE.md` 배치. Claude Code 의 상위 CLAUDE.md 누적 로드 특성을 활용해 컨텍스트 오염 최소화.
4. **역할 prefix** — `/new backend api User`, `/plan frontend component Button` 식으로 대상 스택을 명시. 경로는 `stacks.json` 에서 lookup 하므로 별칭 디렉토리명 (`api`, `web`, `app`) 지원.
5. **기획자 agent 분리** — PRD 작성과 역할별 프롬프트 분배를 **코드 작성과 분리된 agent** 에 맡김. `planner` agent 는 Read/Write/Grep/Glob 만 가지고 `docs/specs/` 산출.
6. **Agent Teams 는 옵션** — 한 번의 호출로 backend·frontend·mobile generator 를 **병렬** 실행 가능하지만, 반드시 옵션으로. 기본은 `ask` 모드.

### 구조

```
.claude/
  stacks.json               # 매니페스트 (모노레포일 때만)
  agents/planner.md         # 기획자 agent (opus)
  commands/planner.md       # /planner 슬래시 커맨드
  templates/
    CLAUDE.monorepo.md      # 루트 인덱스 템플릿
    settings.monorepo.json  # 병합 settings (경로 가드 hooks)
    prd.md                  # PRD 템플릿
    role-prompt.md          # 역할별 구현 프롬프트 템플릿

docs/specs/{feature}.md     # PRD (팀 공유)
docs/specs/{feature}/
  backend.md                # backend 구현 프롬프트
  frontend.md               # frontend 구현 프롬프트
  mobile.md                 # mobile 구현 프롬프트
```

### 교훈

- **hook 은 루트 1개**라는 Claude Code 제약을 받아들이고 hook 내부에서 경로로 분기하는 방식이 깔끔 — 하위 디렉토리 `.claude/` 중첩은 복잡성만 키움
- **병렬 agent 호출**은 파일 경로가 역할별로 분리될 때만 안전 — 단일 스택에선 Teams 의미 없음 (자동 폴백)
- **별칭 디렉토리명 허용**은 유연성 ↑ 이지만 **역할 prefix 는 표준 이름 고정** (`backend`/`frontend`/`mobile`) — UX 일관성 우선

### 다음 호기 고려 항목
- `.claude/settings.json` 에 `planner.defaultExecution` 추가 (ask / teams / output-only 기본값)
- `docs/specs/` GitHub Actions 로 lint (PRD 섹션 누락 체크)
- PR 템플릿 연동 — `/pr` 이 관련 PRD 를 자동 링크

---

## 2026-04-17: v1.6.0 — 커맨드 전면 재편 + 워크플로 단순화

**카테고리:** 결정

### 배경
커맨드 16개가 평평(flat)하게 흩어져 있어 근육 기억 부담이 크고, `new-*`, `design-*`, `review-*` 접두사가 혼재해 의미가 겹쳤음. 또한 커밋→PR→머지→정리 과정이 수작업이라 피처 완료 후 정리 단계가 누락되는 경우가 있었음.

### 변경 사항

**커맨드 통합 (16 → 11)**
- `new-*` 6개 → `/new` 디스패처 (+ 자동 감지: 이름 패턴·스택으로 서브 생략 가능)
- `design-*` 2개 → `/plan` 으로 흡수 (`/plan api`, `/plan db`)
- `/review-api` → `/review` api 모드로 흡수
- `/improve` → `/rule` 로 개명 (결과물 중심 네이밍)
- `/pr` 신설 (기존 `/new-feature pr` 분리)
- `/merge` 신설 (`gh pr merge` + main 최신화 + 태그 + worktree 정리)
- `/starter` 신설 (install/update 통합 진입점)

**자동 체인 (각 단계 확인)**
- `/commit` → 피처 브랜치면 `/pr` 제안 → 수락 시 `/pr` → `/merge` 제안 → 수락 시 `/merge`
- 완전 자동이 아닌 "연속 확인" 체인 (각 단계에서 y/N 또는 옵션 선택)

**컨텍스트 자동 로드**
- `memory/MEMORY.md` 를 세션 시작 시 자동 참조하도록 CLAUDE.md 템플릿 전체에 지시 추가
- `/memory show` 모드 제거 (자동 로드로 대체)

**bootstrap.sh install/update 통합**
- 기존 `.claude/` 감지 시 백업 없이 전체 교체
- `.claude/.starter-version` 에 버전 기록 (팀 공유용)

### 핵심 원칙
- 디스패처 커맨드는 스택·이름 패턴으로 자동 감지 → 사용자가 타이핑 최소화
- 명시 서브명령은 override 용도로만 사용 (자동 감지가 틀릴 때)
- 체인 제안은 "다음 단계를 물어봄" — 강제하지 않음

**관련 파일:** `.claude/commands/*.md` (11개), `.claude/templates/CLAUDE.*.md`, `bootstrap.sh`, `README.md`, `CHANGELOG.md`

---

## 2026-04-15: v1.4.0 — /design-db DB 설계 자동화 추가

**카테고리:** 결정

### 배경
새 기능 개발 시 DB 스키마를 먼저 설계하고 Migration SQL을 만드는 과정이 수동이어서 패턴 불일치 발생 위험이 있었음.

### 추가된 기능
- `/design-db <도메인 설명>` — MySQL 스키마 설계 → ERD 검토 → Migration SQL 자동 생성
- `db-patterns.md` — MySQL 타입 선택, 공통 컬럼, 인덱스, Flyway/golang-migrate 규칙 레퍼런스

### 설계 원칙
- **설계 → 코드 순서 강제**: `/design-db` 완료 후 `/new-api` 실행 유도
- **스택별 분기**: Kotlin은 Flyway(`V{N}__*.sql`), Go는 golang-migrate(`{000000}_*.up/down.sql`)
- **nextjs/flutter 제외**: DB migration 커맨드는 백엔드 스택에서만 유지

### 워크플로
```
/design-db → Migration SQL 생성 → /new-api → Entity/Repository 코드 생성
```

**관련 파일:** `.claude/commands/design-db.md`, `.claude/skills/db-patterns.md`

---

## 2026-04-15: v1.5.0 — REST API 설계 자동화 추가

**카테고리:** 결정

### 추가된 파일
- `api-designer` agent: REST API 설계 전문 에이전트 (OpenAPI 3.0 YAML 초안, BearerAuth/Pagination/Error 패턴)
- `api-design-patterns.md` skill: URL 구조·응답 형식·RFC 7807 에러·인증·스택별 어노테이션 패턴 레퍼런스
- `/design-api` command: 5단계 인터랙티브 설계 → `/new-api`(Kotlin) / `/new-go-api`(Go) 연결
- `/review-api` command: REST 컨벤션·보안·OpenAPI 문서 완성도 리뷰 (심각도 3단계)

### 설계 원칙
- **백엔드 전용**: `/init nextjs`, `/init flutter` 시 자동 제거 대상
- **플로우 연결**: `/design-api` → 설계 확인 → `/new-api` or `/new-go-api` 구현으로 이어짐
- **`/commit` 문서 자동화**: feat/fix 커밋 시 CHANGELOG·README·memory 자동 업데이트 단계 추가

### 충돌 해결 기록
`feature/api-design-settings` 브랜치가 `feature/db-design`(PR#2) merge 후 `dev`와 충돌.
`init.md`의 스택별 유지/제거 목록이 양쪽에서 수정됨 → rebase 후 두 변경사항 병합으로 해결.

**관련 파일:** `.claude/agents/api-designer.md`, `.claude/commands/design-api.md`, `.claude/commands/review-api.md`, `.claude/skills/api-design-patterns.md`, `.claude/commands/commit.md`

---

## 2026-04-15: Git 브랜치 네이밍 — dev/* 충돌 교훈

**카테고리:** 교훈

### 문제
`dev` 브랜치(통합)와 `dev/feature-*` 브랜치(피처)를 동시에 운용하려 했으나 Git이 거부.

### 원인
Git refs는 파일시스템 경로처럼 동작함. `refs/heads/dev`(파일)와 `refs/heads/dev/feature-login`(디렉토리)은 같은 경로에 공존 불가.
`fatal: cannot lock ref 'refs/heads/dev/feature-db-design': 'refs/heads/dev' exists`

### 해결
피처 브랜치 prefix를 `dev/` 에서 타입별 독립 prefix로 변경:
- `feature/{name}` · `fix/{name}` · `hotfix/{name}` · `refactor/{name}` · `chore/{name}`

통합 브랜치(`dev`)는 그대로 유지.

### 수정된 파일
- `new-feature.md` — 브랜치 생성 명령 및 예시 수정
- `CLAUDE.*.md` 7개 — 브랜치 전략 테이블 수정
- `README.md` — 브랜치 전략 다이어그램 수정

**관련 파일:** `.claude/commands/new-feature.md`, `.claude/templates/CLAUDE.*.md`

---

## 2026-04-15: v1.3.0 — 멀티 모듈 지원 추가

**카테고리:** 결정

### 배경
단일 모듈 구조(패키지 기반 레이어)만 지원하던 것에서 물리적 경계가 있는 멀티 모듈 구조 추가.
Kotlin Gradle 멀티 모듈 / Next.js Turborepo / Go Workspace 3가지 variant 도입.

### 설계 원칙
- **에이전트 신규 생성 없음** — CLAUDE.md 템플릿이 구조를 설명하면 기존 generator/modifier/tester가 자동으로 해당 구조를 따름
- **하위 호환** — 기존 단일 모듈 `/init kotlin|nextjs|go|flutter` 동작 변경 없음
- **자동 감지** — `go.work` / `turbo.json` / `settings.gradle.kts` include 여부로 단일/멀티 모듈 자동 분기

### 추가된 파일
- 템플릿 6개: `CLAUDE.{kotlin,nextjs,go}-multi.md`, `settings.{kotlin,nextjs,go}-multi.json`
- 커맨드 1개: `/new-module` (서브모듈/패키지/서비스 추가)
- 커맨드 수정 2개: `/init`, `/new-api` (멀티 모듈 분기 추가)
- Skills 수정 3개: 각 스택 patterns 파일에 멀티 모듈 패턴 섹션 추가

### 각 스택 멀티 모듈 구조
- **Kotlin**: `:api`(presentation) → `:domain`(entity+service) ← `:infra`(repository)
- **Next.js**: `apps/web` + `packages/{ui,lib,config}` (Turborepo)
- **Go**: `services/{api,worker}` + `pkg/shared` (go.work)

**관련 파일:** `.claude/templates/CLAUDE.*-multi.md`, `.claude/commands/new-module.md`

---

## 2026-04-14: 프로젝트 초기 구성

**카테고리:** 결정

이 레포는 Claude Code를 새 프로젝트에 빠르게 세팅하기 위한 스타터입니다.
Kotlin Spring Boot, Next.js, Flutter 세 스택을 지원하며 `/init <stack>` 한 번으로 불필요한 파일을 제거하고 CLAUDE.md + settings.json을 설치합니다.

**핵심 설계 원칙:**
- 스택별 전문 subagent 분리 (generator / modifier / tester)
- `/improve`로 AI 실수를 CLAUDE.md 규칙에 누적 → 피드백 루프
- `memory/MEMORY.md`로 팀 지식 축적 → Second Brain

**관련 파일:** `.claude/commands/init.md`, `.claude/templates/`

---

## 2026-04-14: Second Brain 시스템 도입

**카테고리:** 결정

`memory/MEMORY.md`를 Second Brain으로 사용하기로 결정.

**개인 메모리 vs 팀 메모리 구분:**
- 개인 메모리: `~/.claude/projects/<project>/memory/` — 세션 간 AI 자동 학습 내용
- 팀 메모리: `memory/MEMORY.md` (이 파일) — git으로 공유되는 팀 지식

**`/memory` 커맨드**로 조회·추가·검색 가능.
파생 프로젝트는 `/init` 실행 시 `memory/MEMORY.md` 템플릿이 자동 생성됨.

---

## 2026-04-14: /init 스택 자동 감지 및 신규/기존 분기 추가

**카테고리:** 결정

`/init` 인수 생략 시 프로젝트 파일로 스택 자동 감지:
- `build.gradle.kts` / `pom.xml` → kotlin
- `package.json` (next 의존성) → nextjs
- `pubspec.yaml` → flutter

신규 프로젝트(빈 디렉토리)와 기존 프로젝트(코드 있음) 분기 처리:
- 기존 프로젝트는 CLAUDE.md 덮어쓰기 전 병합 여부 확인

**관련 파일:** `.claude/commands/init.md`

---

## 2026-04-14: /init 시 memory 인터뷰 자동 기록

**카테고리:** 결정

`/init`은 새 프로젝트 시작이므로 기존 memory 유무와 관계없이 항상 초기화.
초기화 후 4가지 질문 (목적, 핵심 기능, 제약사항, 외부 연동) → 자동 기록.

**이유:** 프로젝트 초기 컨텍스트가 이후 세션에서도 유지되도록.

---

## 2026-04-14: settings.json 템플릿 permissions.allow 추가

**카테고리:** 결정

기존 템플릿은 `permissions.allow`가 비어 있어 모든 Bash 명령마다 승인 요청 발생.
스택별 허용 명령어를 명시적으로 등록.

- Kotlin: `./gradlew`, `./mvnw`, `docker`, `docker-compose`, `git` + 파일 조작
- Next.js: `npm`, `npx`, `node`, `git` + 파일 조작
- Flutter: `flutter`, `dart`, `git` + 파일 조작

**관련 파일:** `.claude/templates/settings.{kotlin,nextjs,flutter}.json`

---

## 2026-04-14: Pre-push 커버리지 게이트 도입

**카테고리:** 결정

`git push` 전 라인 커버리지 90% 이상 강제.
`.claude/hooks/pre-push.sh`가 settings.json PreToolUse/Bash 훅으로 실행됨.

- Kotlin → `./gradlew test jacocoTestReport` → `build/reports/jacoco/test/jacocoTestReport.xml`
- Next.js → `npx jest --coverage --coverageReporters=json-summary` → `coverage/coverage-summary.json`
- Flutter → `flutter test --coverage` → `coverage/lcov.info`

**⚠️ 교훈:** Kotlin에서 Jacoco가 `build.gradle.kts`에 설정되지 않으면 게이트 자체가 실패함.
필수 설정:
```kotlin
plugins { jacoco }
tasks.jacocoTestReport { dependsOn(tasks.test); reports { xml.required = true } }
tasks.test { finalizedBy(tasks.jacocoTestReport) }
```

**관련 파일:** `.claude/hooks/pre-push.sh`, `.claude/templates/settings.*.json`, `CLAUDE.*.md`

---

## 2026-04-14: 스택별 플러그인 선정

**카테고리:** 결정

`anthropics/claude-plugins-official` 전체 목록 직접 조회 후 선정.

**공통 (전 스택):** `github`, `context7`, `feature-dev`, `code-review`, `pr-review-toolkit`, `security-guidance`, `hookify`, `commit-commands`, `claude-md-management`

**Kotlin 추가:** `kotlin-lsp`
**Next.js 추가:** `typescript-lsp`, `frontend-design`, `playwright`
**Flutter:** 공통만 (공식 Dart/Flutter LSP 없음)

**제외 판단:**
- `jdtls-lsp`: Java 전용, Kotlin 미지원 확인
- `superpowers`, `atomic-agents`: 공식 레포에 없는 구 플러그인 (이전 템플릿 잔재)
- `greptile`: 외부 유료 서비스 의존

**관련 파일:** `.claude/templates/settings.{kotlin,nextjs,flutter}.json`

---

## 2026-04-14: ui-designer agent 추가

**카테고리:** 결정

DESIGN.md 기반 디자인 시스템 에이전트. awesome-design-md(VoltAgent) 66개 브랜드 참조 가능.

**Flutter 포함 결정 근거:**
- 컬러·타이포·스페이싱·엘리베이션 토큰 → Flutter ThemeData 변환 가능 ✅
- CSS/Tailwind 컴포넌트 스펙 → Flutter 직접 적용 불가 ❌
- 결론: 포함하되 디자인 토큰 추출 전담으로 제한. CSS 스펙 자동 무시.

**Kotlin:** 백엔드 전용이면 불필요. 풀스택이면 유지.

**생성 파일 (Flutter 모드):** `lib/core/theme/app_theme.dart`, `app_colors.dart`, `app_text_styles.dart`, `app_spacing.dart`, `app_radius.dart`

**관련 파일:** `.claude/agents/ui-designer.md`

---

## 2026-04-14: GitHub 레포 이름 변경

**카테고리:** 참고

- **구 URL:** https://github.com/nogamsung/claude
- **현재 URL:** https://github.com/nogamsung/claude-code-starter
- **bootstrap.sh 및 README URL 수정 완료**

git push 시 "This repository moved" 경고가 발생했으나 리다이렉트로 push는 성공.
이후 `git remote set-url origin https://github.com/nogamsung/claude-code-starter.git` 실행.

---

## 2026-04-14: v1.2.0 — 대규모 기능 추가

**카테고리:** 결정

### Git Worktree 병렬 작업 전략
- 모든 파생 프로젝트에 `.worktrees/feature-{n}` 구조 강제
- `superpowers:using-git-worktrees` 스킬 원칙 적용:
  - `.worktrees/` gitignore 미등록 시 즉시 추가·커밋 (안전 검증 필수)
  - worktree 생성 후 스택별 의존성 자동 설치
- `/new-feature` 커맨드를 worktree 기반으로 전면 개편

### 브랜치 전략
- `main ← dev ← dev/feature-{number}` 3단계 구조
- `main` / `dev` 모두 PR + CI 통과 보호
- `/init` 실행 시 `dev` 브랜치 자동 생성

### Docker → GitHub Container Registry 배포
- Kotlin/Go/Next.js 스택별 멀티스테이지 Dockerfile 패턴 확립
- Flutter는 Docker 배포 미지원으로 명시 제외
- `publish.yml`: semver 태그 자동 생성 + 멀티플랫폼(`linux/amd64,linux/arm64`)

### Swagger 필수화
- Kotlin: SpringDoc OpenAPI — Controller에 `@Tag/@Operation/@ApiResponse`, DTO에 `@Schema` 필수
- Go: swaggo/swag — Handler에 godoc 주석 필수, DTO에 `example` 태그 필수

### 쿼리 레이어 표준화
- Kotlin: JPA + QueryDSL (동적 쿼리) + jOOQ (복잡 집계, 선택)
- Go: GORM (단순 CRUD) + sqlc (동적/페이징) + golangci-lint 필수

**관련 파일:** 대부분의 `.claude/**/*.md`, `CHANGELOG.md`, `VERSION`

---

## 2026-04-14: bootstrap.sh 도입

**카테고리:** 결정

새 프로젝트에서 `.claude` 폴더를 curl 한 줄로 설치:
```bash
curl -fsSL https://raw.githubusercontent.com/nogamsung/claude-code-starter/main/bootstrap.sh | bash
```

sparse checkout으로 `.claude` 폴더만 가져오는 방식 채택 (전체 클론 대비 빠름).

**관련 파일:** `bootstrap.sh`
