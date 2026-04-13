---
description: 프로젝트 스택을 선언하고 관련 없는 agent/command 파일을 제거하여 프로젝트에 최적화된 Claude Code 환경을 구성
argument-hint: <stack> — kotlin | nextjs | flutter
---

이 프로젝트의 스택을 설정하고 불필요한 파일을 제거합니다.

**선택한 스택:** $ARGUMENTS

## 진행 순서

### Step 1 — 스택 확인

`$ARGUMENTS`를 확인합니다.
- `kotlin` → Kotlin Spring Boot 백엔드 프로젝트
- `nextjs` → Next.js 프론트엔드 프로젝트
- `flutter` → Flutter 모바일 프로젝트
- 값이 없거나 위 세 가지가 아니면: 사용자에게 다시 물어봅니다

### Step 2 — 제거할 파일 목록 제시

선택한 스택에 따라 아래 파일들을 제거합니다.
**반드시 목록을 사용자에게 보여주고 확인을 받은 후에 삭제하세요.**

#### `kotlin` 선택 시 — 제거 대상
agents:
- `.claude/agents/nextjs-generator.md`
- `.claude/agents/nextjs-modifier.md`
- `.claude/agents/nextjs-tester.md`
- `.claude/agents/flutter-generator.md`
- `.claude/agents/flutter-modifier.md`
- `.claude/agents/flutter-tester.md`

commands:
- `.claude/commands/new-component.md`
- `.claude/commands/new-screen.md`

유지:
- `kotlin-generator.md`, `kotlin-modifier.md`, `kotlin-tester.md`
- `code-reviewer.md`
- `new-api.md`, `test.md`, `review.md`, `commit.md`, `tdd.md`

---

#### `nextjs` 선택 시 — 제거 대상
agents:
- `.claude/agents/kotlin-generator.md`
- `.claude/agents/kotlin-modifier.md`
- `.claude/agents/kotlin-tester.md`
- `.claude/agents/flutter-generator.md`
- `.claude/agents/flutter-modifier.md`
- `.claude/agents/flutter-tester.md`

commands:
- `.claude/commands/new-api.md`
- `.claude/commands/new-screen.md`

유지:
- `nextjs-generator.md`, `nextjs-modifier.md`, `nextjs-tester.md`
- `code-reviewer.md`
- `new-component.md`, `test.md`, `review.md`, `commit.md`, `tdd.md`

---

#### `flutter` 선택 시 — 제거 대상
agents:
- `.claude/agents/kotlin-generator.md`
- `.claude/agents/kotlin-modifier.md`
- `.claude/agents/kotlin-tester.md`
- `.claude/agents/nextjs-generator.md`
- `.claude/agents/nextjs-modifier.md`
- `.claude/agents/nextjs-tester.md`

commands:
- `.claude/commands/new-api.md`
- `.claude/commands/new-component.md`

유지:
- `flutter-generator.md`, `flutter-modifier.md`, `flutter-tester.md`
- `code-reviewer.md`
- `new-screen.md`, `test.md`, `review.md`, `commit.md`, `tdd.md`

---

### Step 3 — 사용자 확인 후 삭제 실행

사용자가 확인하면:
1. 위 목록의 파일들을 삭제합니다 (`rm` 명령어 사용)
2. 삭제 성공 여부를 확인합니다

### Step 4 — CLAUDE.md 생성

프로젝트 루트(현재 디렉토리)에 `CLAUDE.md`가 없으면 생성합니다.
이미 있으면 스택 정보 섹션만 추가/업데이트합니다.

#### kotlin용 CLAUDE.md 내용
```markdown
# Project

## Stack
- **Language**: Kotlin
- **Framework**: Spring Boot 3.x
- **Build**: Gradle (Kotlin DSL)
- **ORM**: Spring Data JPA
- **Migration**: Flyway

## Agents
| 작업 | Agent |
|------|-------|
| 새 코드 생성 (Entity/Service/Controller) | `kotlin-generator` |
| 기존 코드 수정/리팩토링 | `kotlin-modifier` |
| 테스트 코드 작성 | `kotlin-tester` |
| 코드 리뷰 | `code-reviewer` |

## Commands
| 커맨드 | 용도 |
|--------|------|
| `/new-api <Resource>` | REST API 전체 스캐폴딩 |
| `/test [file]` | 테스트 자동 생성 |
| `/tdd <기능>` | TDD 사이클로 개발 |
| `/review [staged\|diff\|file]` | 코드 리뷰 |
| `/commit [hint]` | Conventional Commits 커밋 |
```

#### nextjs용 CLAUDE.md 내용
```markdown
# Project

## Stack
- **Framework**: Next.js 14+ (App Router)
- **Language**: TypeScript (strict)
- **Styling**: Tailwind CSS + shadcn/ui
- **State**: TanStack Query + Zustand
- **Forms**: React Hook Form + Zod

## Agents
| 작업 | Agent |
|------|-------|
| 새 코드 생성 (Page/Component/Hook) | `nextjs-generator` |
| 기존 코드 수정/리팩토링 | `nextjs-modifier` |
| 테스트 코드 작성 | `nextjs-tester` |
| 코드 리뷰 | `code-reviewer` |

## Commands
| 커맨드 | 용도 |
|--------|------|
| `/new-component <Name> [--page\|--feature\|--ui]` | 컴포넌트 생성 |
| `/test [file]` | 테스트 자동 생성 |
| `/tdd <기능>` | TDD 사이클로 개발 |
| `/review [staged\|diff\|file]` | 코드 리뷰 |
| `/commit [hint]` | Conventional Commits 커밋 |
```

#### flutter용 CLAUDE.md 내용
```markdown
# Project

## Stack
- **Framework**: Flutter (latest stable)
- **Language**: Dart (null safety)
- **State**: Riverpod 2.x
- **Navigation**: GoRouter
- **Network**: Dio + Retrofit
- **Models**: Freezed + json_serializable

## Agents
| 작업 | Agent |
|------|-------|
| 새 코드 생성 (Screen/Provider/Model) | `flutter-generator` |
| 기존 코드 수정/리팩토링 | `flutter-modifier` |
| 테스트 코드 작성 | `flutter-tester` |
| 코드 리뷰 | `code-reviewer` |

## Commands
| 커맨드 | 용도 |
|--------|------|
| `/new-screen <Name>` | Screen + 전체 레이어 생성 |
| `/test [file]` | 테스트 자동 생성 |
| `/tdd <기능>` | TDD 사이클로 개발 |
| `/review [staged\|diff\|file]` | 코드 리뷰 |
| `/commit [hint]` | Conventional Commits 커밋 |
```

### Step 5 — 완료 메시지

다음 내용을 출력합니다:
```
✅ 프로젝트 초기화 완료

스택: [선택한 스택]
제거된 파일: N개
남은 agents: [목록]
남은 commands: [목록]

CLAUDE.md가 생성/업데이트되었습니다.
이제 Claude Code가 이 프로젝트에 최적화된 상태입니다.
```
