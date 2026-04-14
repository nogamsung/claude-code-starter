# Claude Code 기본 세팅

새 프로젝트에 Claude Code 하네스를 빠르게 구성하기 위한 설정 모음입니다.
Kotlin Spring Boot, Next.js, Flutter 세 가지 스택을 지원합니다.

---

## 사용 방법

### 1단계: 이 디렉토리를 새 프로젝트에 복사

`.claude` 폴더를 프로젝트 루트에 복사합니다.

```bash
cp -r /path/to/this-repo/.claude /path/to/your-project/.claude
```

### 2단계: 스택 초기화

프로젝트를 열고 `/init` 커맨드를 실행합니다.

```
/init kotlin    # Kotlin Spring Boot 백엔드
/init nextjs    # Next.js 프론트엔드
/init flutter   # Flutter 모바일
```

`/init`이 하는 일:
- 선택한 스택과 관계없는 agent/command 파일 제거
- `CLAUDE.md` 설치 (프로젝트 컨텍스트 파일)
- `.claude/settings.json` 설치 (권한 및 훅 설정)

### 3단계: CLAUDE.md 커스터마이징

설치된 `CLAUDE.md`를 열어 프로젝트에 맞게 수정합니다.
도메인 규칙, 폴더 구조, 금지 패턴 등을 추가하세요.

---

## 포함된 커맨드

| 커맨드 | 설명 |
|--------|------|
| `/init <stack>` | 스택 선택 및 하네스 구성 |
| `/plan <기능>` | 코드 작성 전 설계 검토 및 합의 |
| `/test [파일]` | 테스트 코드 자동 생성 |
| `/review [대상]` | 코드 리뷰 (code-reviewer agent 사용) |
| `/commit [힌트]` | Conventional Commits 형식으로 커밋 |
| `/improve <설명>` | AI 실수를 CLAUDE.md 규칙으로 등록 |

### 스택별 추가 커맨드

| 커맨드 | 스택 | 설명 |
|--------|------|------|
| `/new-api` | Kotlin | Controller/Service/Repository 스캐폴딩 |
| `/new-component` | Next.js | React 컴포넌트 생성 |
| `/new-screen` | Flutter | 화면 및 Provider 생성 |

---

## 포함된 Agents

| Agent | 역할 |
|-------|------|
| `code-reviewer` | 정확성·보안·성능·유지보수성 관점 코드 리뷰 |
| `kotlin-generator` | 새 Kotlin 파일 생성 전문 |
| `kotlin-modifier` | 기존 Kotlin 파일 수정/리팩토링 전문 |
| `kotlin-tester` | Kotlin 테스트 코드 작성 전문 |
| `nextjs-generator` | 새 Next.js 파일 생성 전문 |
| `nextjs-modifier` | 기존 Next.js 파일 수정/리팩토링 전문 |
| `nextjs-tester` | Next.js 테스트 코드 작성 전문 |
| `flutter-generator` | 새 Flutter 파일 생성 전문 |
| `flutter-modifier` | 기존 Flutter 파일 수정/리팩토링 전문 |
| `flutter-tester` | Flutter 테스트 코드 작성 전문 |

---

## 권장 워크플로

```
/plan <기능 설명>        # 1. 설계 합의
                         # 2. Claude가 적절한 agent로 구현
/test <구현한 파일>      # 3. 테스트 생성
/review staged           # 4. 코드 리뷰
/commit                  # 5. 커밋

# AI가 실수하면:
/improve <실수 설명>     # → CLAUDE.md에 규칙 추가 (다음부터 반복 방지)
```

---

## 디렉토리 구조

```
.claude/
├── agents/          # 스택별 전문 subagent 정의
├── commands/        # 슬래시 커맨드 정의
└── templates/       # 스택별 CLAUDE.md / settings.json 템플릿
    ├── CLAUDE.kotlin.md
    ├── CLAUDE.nextjs.md
    ├── CLAUDE.flutter.md
    ├── settings.kotlin.json
    ├── settings.nextjs.json
    └── settings.flutter.json
```
