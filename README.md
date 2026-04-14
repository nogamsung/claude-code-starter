<div align="center">

# 🤖 Claude Code Starter

**새 프로젝트에 Claude Code 하네스를 10초 만에 구성하는 설정 모음**

![Claude](https://img.shields.io/badge/Claude-Code-orange?logo=anthropic&logoColor=white)
![Kotlin](https://img.shields.io/badge/Kotlin-Spring_Boot-7F52FF?logo=kotlin&logoColor=white)
![Next.js](https://img.shields.io/badge/Next.js-000000?logo=next.js&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)

</div>

---

## 개요

Claude Code를 프로젝트에서 바로 활용할 수 있도록 **커맨드, 에이전트, 템플릿**을 미리 세팅한 스타터입니다.

- `/init <stack>` 한 번으로 프로젝트에 맞는 하네스 구성
- 스택별 전문 subagent로 생성·수정·테스트 역할 분리
- AI가 실수할 때마다 `/improve`로 규칙을 누적해 점점 정교해지는 피드백 루프

**지원 스택:** Kotlin Spring Boot · Next.js · Flutter

---

## 빠른 시작

### 1. `.claude` 폴더를 프로젝트에 복사

```bash
cp -r /path/to/claude-code-starter/.claude /path/to/your-project/.claude
```

### 2. Claude Code에서 스택 초기화

```
/init kotlin    # Kotlin Spring Boot 백엔드
/init nextjs    # Next.js 프론트엔드
/init flutter   # Flutter 모바일
```

<details>
<summary><code>/init</code>이 하는 일</summary>

- 선택한 스택과 무관한 agent/command 파일 제거
- `CLAUDE.md` 설치 — 프로젝트 컨텍스트 파일 (아키텍처 규칙, 금지 패턴 등)
- `.claude/settings.json` 설치 — 권한 및 훅 설정

</details>

### 3. `CLAUDE.md` 커스터마이징

설치된 `CLAUDE.md`를 열어 프로젝트 도메인 규칙, 폴더 구조, 금지 패턴을 추가합니다.

---

## 워크플로

```
/plan <기능 설명>      # 1. 코드 전 설계 합의
                       # 2. Claude가 적절한 agent로 구현
/test <파일>           # 3. 테스트 코드 자동 생성
/review staged         # 4. 코드 리뷰
/commit                # 5. Conventional Commits 형식으로 커밋

# AI가 실수하면:
/improve <실수 설명>   # → CLAUDE.md 규칙으로 등록 (반복 방지)
```

---

## 커맨드

### 공통

| 커맨드 | 설명 |
|--------|------|
| `/init <stack>` | 스택 선택 및 하네스 구성 |
| `/plan <기능>` | 코드 작성 전 설계 검토 및 합의 |
| `/test [파일]` | 테스트 코드 자동 생성 |
| `/review [대상]` | 코드 리뷰 |
| `/commit [힌트]` | Conventional Commits 형식으로 커밋 |
| `/improve <설명>` | AI 실수를 CLAUDE.md 규칙으로 등록 |
| `/memory [add\|search]` | 프로젝트 Second Brain 조회·추가·검색 |

### 스택별

| 커맨드 | 스택 | 설명 |
|--------|------|------|
| `/new-api` | Kotlin | Controller / Service / Repository 스캐폴딩 |
| `/new-component` | Next.js | React 컴포넌트 생성 |
| `/new-screen` | Flutter | 화면 및 Provider 생성 |

---

## Agents

스택별로 역할이 분리된 전문 subagent가 포함되어 있습니다.

| Agent | 역할 |
|-------|------|
| `code-reviewer` | 정확성 · 보안 · 성능 · 유지보수성 관점 코드 리뷰 |
| `kotlin-generator` | 새 Kotlin 파일 생성 |
| `kotlin-modifier` | 기존 Kotlin 파일 수정 / 리팩토링 |
| `kotlin-tester` | Kotlin 테스트 코드 작성 |
| `nextjs-generator` | 새 Next.js 파일 생성 |
| `nextjs-modifier` | 기존 Next.js 파일 수정 / 리팩토링 |
| `nextjs-tester` | Next.js 테스트 코드 작성 |
| `flutter-generator` | 새 Flutter 파일 생성 |
| `flutter-modifier` | 기존 Flutter 파일 수정 / 리팩토링 |
| `flutter-tester` | Flutter 테스트 코드 작성 |

---

## 디렉토리 구조

```
.claude/
├── agents/                   # 스택별 전문 subagent 정의
│   ├── code-reviewer.md
│   ├── kotlin-{generator,modifier,tester}.md
│   ├── nextjs-{generator,modifier,tester}.md
│   └── flutter-{generator,modifier,tester}.md
├── commands/                 # 슬래시 커맨드 정의
│   ├── init.md
│   ├── plan.md
│   ├── test.md
│   ├── review.md
│   ├── commit.md
│   ├── improve.md
│   ├── new-api.md
│   ├── new-component.md
│   └── new-screen.md
└── templates/                # 스택별 CLAUDE.md / settings.json 템플릿
    ├── CLAUDE.kotlin.md
    ├── CLAUDE.nextjs.md
    ├── CLAUDE.flutter.md
    ├── settings.kotlin.json
    ├── settings.nextjs.json
    └── settings.flutter.json
```
