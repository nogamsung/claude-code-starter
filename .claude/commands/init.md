---
description: 프로젝트 스택을 선언하고 관련 없는 agent/command 파일을 제거, CLAUDE.md + settings.json을 설치하여 하네스를 구성
argument-hint: <stack> — kotlin | nextjs | flutter
---

이 프로젝트의 스택을 설정하고 하네스를 구성합니다.

**선택한 스택:** $ARGUMENTS

## 진행 순서

### Step 1 — 스택 확인

`$ARGUMENTS`를 확인합니다.
- `kotlin` → Kotlin Spring Boot 백엔드 프로젝트
- `nextjs` → Next.js 프론트엔드 프로젝트
- `flutter` → Flutter 모바일 프로젝트
- 값이 없거나 위 세 가지가 아니면: 사용자에게 다시 물어봅니다

---

### Step 2 — 제거할 파일 목록 제시

**반드시 목록을 사용자에게 보여주고 확인을 받은 후에 삭제하세요.**

#### `kotlin` 선택 시 — 제거 대상
agents: `nextjs-generator`, `nextjs-modifier`, `nextjs-tester`, `flutter-generator`, `flutter-modifier`, `flutter-tester`
commands: `new-component.md`, `new-screen.md`
templates: `CLAUDE.nextjs.md`, `CLAUDE.flutter.md`, `settings.nextjs.json`, `settings.flutter.json`

유지: `kotlin-generator`, `kotlin-modifier`, `kotlin-tester`, `code-reviewer`
유지 commands: `new-api.md`, `plan.md`, `test.md`, `review.md`, `improve.md`, `commit.md`

---

#### `nextjs` 선택 시 — 제거 대상
agents: `kotlin-generator`, `kotlin-modifier`, `kotlin-tester`, `flutter-generator`, `flutter-modifier`, `flutter-tester`
commands: `new-api.md`, `new-screen.md`
templates: `CLAUDE.kotlin.md`, `CLAUDE.flutter.md`, `settings.kotlin.json`, `settings.flutter.json`

유지: `nextjs-generator`, `nextjs-modifier`, `nextjs-tester`, `code-reviewer`
유지 commands: `new-component.md`, `plan.md`, `test.md`, `review.md`, `improve.md`, `commit.md`

---

#### `flutter` 선택 시 — 제거 대상
agents: `kotlin-generator`, `kotlin-modifier`, `kotlin-tester`, `nextjs-generator`, `nextjs-modifier`, `nextjs-tester`
commands: `new-api.md`, `new-component.md`
templates: `CLAUDE.kotlin.md`, `CLAUDE.nextjs.md`, `settings.kotlin.json`, `settings.nextjs.json`

유지: `flutter-generator`, `flutter-modifier`, `flutter-tester`, `code-reviewer`
유지 commands: `new-screen.md`, `plan.md`, `test.md`, `review.md`, `improve.md`, `commit.md`

---

### Step 3 — 사용자 확인 후 삭제 실행

사용자가 확인하면 해당 파일들을 `rm` 명령어로 삭제하고 결과를 확인합니다.

---

### Step 4 — 하네스 파일 설치 (핵심)

#### 4-1. CLAUDE.md 설치 (기둥 1: 컨텍스트 파일)

프로젝트 루트에 `CLAUDE.md`가 없으면:
```bash
cp .claude/templates/CLAUDE.{stack}.md ./CLAUDE.md
```

이미 있으면: 기존 파일에 템플릿의 "아키텍처 규칙", "반드시 지켜야 할 규칙", "절대 하면 안 되는 것" 섹션을 병합합니다.

**사용자에게 프로젝트명을 물어보고** `CLAUDE.md` 첫 줄의 `[프로젝트명]`을 실제 이름으로 교체합니다.

#### 4-2. settings.json 설치 (기둥 2+3: CI/CD 게이트 + 도구 경계)

`.claude/settings.json`이 없으면:
```bash
cp .claude/templates/settings.{stack}.json ./.claude/settings.json
```

이미 있으면: 기존 파일의 `hooks`와 `permissions` 섹션을 템플릿 내용으로 업데이트합니다.

#### 4-3. Second Brain 초기화 (기둥 5: 팀 지식 축적)

`/init`은 새 프로젝트 시작을 의미하므로 **기존 memory가 있어도 항상 초기화합니다.**

```bash
mkdir -p memory
cp .claude/templates/memory.md ./memory/MEMORY.md
```

초기화 후 사용자에게 다음 질문을 합니다. **한 번에 모두 물어보세요.**

> 1. 이 프로젝트의 목적 또는 배경을 한 줄로 설명해주세요.
> 2. 주요 도메인이나 핵심 기능은 무엇인가요?
> 3. 특별한 제약사항이 있나요? (마감일, 성능 요구사항, 팀 규모 등)
> 4. 연동할 외부 시스템이나 참고할 레퍼런스가 있나요? (없으면 생략)

답변을 받으면 `memory/MEMORY.md`에 아래 두 항목을 자동으로 기록합니다:

**[1] 프로젝트 개요**
```markdown
## YYYY-MM-DD: 프로젝트 시작

**카테고리:** 결정

- **프로젝트명:** [프로젝트명]
- **스택:** [선택한 스택]
- **목적:** [질문 1 답변]
- **핵심 기능:** [질문 2 답변]
- **제약사항:** [질문 3 답변]
- **외부 연동:** [질문 4 답변 또는 없음]
```

**[2] 하네스 구성 기록**
```markdown
## YYYY-MM-DD: Claude Code 하네스 구성

**카테고리:** 참고

/init [스택]으로 하네스를 구성했습니다.
- CLAUDE.md: 아키텍처 규칙 및 코딩 컨벤션
- .claude/settings.json: 권한 및 훅 설정
- memory/MEMORY.md: Second Brain 초기화

앞으로 중요한 결정·교훈은 /memory add 로 기록하세요.
```

---

### Step 5 — 완료 메시지

```
✅ 프로젝트 하네스 구성 완료

스택: [선택한 스택]
제거된 파일: N개

[하네스 기둥 상태]
기둥 1 (컨텍스트): CLAUDE.md ✅ 설치됨
기둥 2 (CI/CD 게이트): .claude/settings.json hooks ✅ 활성화
기둥 3 (도구 경계): .claude/settings.json permissions ✅ 활성화
기둥 4 (피드백 루프): /improve 커맨드 ✅ 사용 가능
기둥 5 (팀 지식 축적): memory/MEMORY.md ✅ 생성됨

남은 agents: [목록]
남은 commands: [목록]

이제 할 일:
1. CLAUDE.md를 열고 프로젝트에 맞게 커스터마이징하세요
2. /plan <기능> 으로 코드 작성을 시작하세요
3. AI가 실수하면 /improve 로 규칙을 추가하세요
4. memory/MEMORY.md 에 중요한 결정과 교훈을 계속 기록하세요
```
