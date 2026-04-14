---
description: Next.js React 컴포넌트 생성 (컴포넌트, 훅, 타입, 스토리, 테스트)
argument-hint: <컴포넌트명> [--page | --feature | --ui] (예: UserCard --feature)
---

다음 지시사항에 따라 Next.js 컴포넌트를 생성해주세요.

**인수**: $ARGUMENTS

## 파싱 규칙
- 컴포넌트명이 없으면 사용자에게 물어보세요
- `--page`: app/ 디렉토리에 페이지 컴포넌트 생성
- `--feature`: components/features/ 아래 피처 컴포넌트 생성 (기본값)
- `--ui`: components/ui/ 아래 재사용 UI 컴포넌트 생성

## 생성할 파일

현재 프로젝트 구조를 파악한 후 생성하세요.

### --ui 또는 기본 컴포넌트
```
components/ui/{component-name}/
├── {component-name}.tsx       # 컴포넌트 본체
├── {component-name}.test.tsx  # React Testing Library 테스트
└── index.ts                   # 재export
```

### --feature 컴포넌트
```
components/features/{feature}/
├── {component-name}.tsx
├── use-{component-name}.ts    # 관련 커스텀 훅 (필요시)
└── {component-name}.test.tsx
```

### --page
```
app/{route}/
├── page.tsx                   # Server Component
├── loading.tsx                # 로딩 UI
└── error.tsx                  # 에러 UI
```

## 컴포넌트 생성 규칙

1. **타입 정의**: Props 인터페이스 명시
2. **Named export** 사용 (default export 금지)
3. **Server Component** 기본 - 인터랙티비티 필요시에만 `"use client"` 추가
4. **Tailwind CSS** 스타일링
5. **접근성**: 적절한 aria 속성, 시맨틱 HTML
6. **로딩/에러 상태** 처리 (필요한 경우)

## 컴포넌트에 포함할 내용 판단
- 현재 프로젝트의 기존 컴포넌트 패턴을 먼저 파악하세요
- API 연동이 필요하면 TanStack Query 훅 패턴 사용
- 폼이 필요하면 React Hook Form + Zod 사용
- 전역 상태가 필요하면 Zustand store 패턴 사용

생성 후 파일 목록과 사용법 예시를 보여주세요.
