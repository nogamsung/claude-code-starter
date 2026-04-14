---
description: 현재 변경사항 또는 지정 파일을 code-reviewer agent로 코드 리뷰
argument-hint: [파일경로 또는 "staged" | "diff"] (없으면 현재 대화 컨텍스트 사용)
---

**code-reviewer** agent를 사용하여 코드 리뷰를 진행합니다.

**대상**: $ARGUMENTS

## 리뷰 진행 순서

1. **리뷰 대상 파악**
   - `$ARGUMENTS`가 파일 경로면 해당 파일을 읽으세요
   - `staged`이면 `git diff --staged`로 스테이징된 변경사항을 확인하세요
   - `diff`이면 `git diff HEAD`로 전체 변경사항을 확인하세요
   - 인수가 없으면 현재 대화에서 언급된 코드 또는 사용자에게 물어보세요

2. **프로젝트 컨텍스트 파악**
   - 어떤 스택인지 확인 (Kotlin/Spring Boot, Next.js, Flutter)
   - 관련 파일들(인터페이스, 부모 클래스, 사용처)을 필요시 추가로 읽으세요

3. **code-reviewer agent 호출**
   - 위에서 수집한 코드와 컨텍스트를 전달하여 리뷰를 요청하세요

## 리뷰 결과 형식

```
## 코드 리뷰 결과

**전체 평가**: Approved / Approved with minor changes / Changes requested

### 🚨 Critical (반드시 수정)
### ⚠️ Major (수정 권장)  
### 💡 Minor (개선 제안)
### ✅ 잘 된 점

### 수정 코드 예시 (필요시)
```

리뷰는 건설적이고 구체적이어야 합니다. 각 지적사항에 대해 왜 문제인지와 어떻게 수정할지를 명확히 설명하세요.
