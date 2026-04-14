---
description: Conventional Commits 형식으로 git 커밋 메시지 작성 및 커밋
argument-hint: [커밋 메시지 힌트] (없으면 변경사항을 분석하여 자동 생성)
---

Conventional Commits 규칙에 따라 커밋을 생성합니다.

**힌트**: $ARGUMENTS

## 커밋 메시지 형식

```
<type>(<scope>): <subject>

[body]

[footer]
```

### Type 목록
- `feat`: 새로운 기능 추가
- `fix`: 버그 수정
- `refactor`: 리팩토링 (기능 변경 없음)
- `test`: 테스트 추가/수정
- `docs`: 문서 수정
- `style`: 코드 포맷팅, 세미콜론 누락 등 (로직 변경 없음)
- `chore`: 빌드 설정, 패키지 업데이트 등
- `perf`: 성능 개선
- `ci`: CI/CD 설정 변경
- `build`: 빌드 시스템 변경

### Scope 예시 (프로젝트별)
- **Backend**: `auth`, `user`, `product`, `order`, `payment`
- **Frontend**: `layout`, `auth`, `dashboard`, `ui`
- **Mobile**: `auth`, `home`, `profile`, `nav`

## 진행 순서

1. `git status`로 변경된 파일 확인
2. `git diff --staged` 또는 `git diff`로 변경 내용 확인
3. 변경사항을 분석하여 적절한 커밋 메시지 초안 작성
4. `$ARGUMENTS`에 힌트가 있으면 참고하여 메시지 보완
5. 커밋 메시지를 사용자에게 보여주고 확인 요청
6. 확인 후 `git commit` 실행
7. **VERSION 파일이 변경된 경우** — 버전 태그를 생성하고 푸시
   ```bash
   git tag v$(cat VERSION)
   git push origin v$(cat VERSION)
   ```

## 커밋 메시지 작성 규칙
- `subject`는 50자 이내, 현재형 동사로 시작 (한국어 가능)
- `body`는 변경 이유와 영향을 설명 (선택사항)
- `BREAKING CHANGE:` footer로 하위 호환성 깨지는 변경 표시
- 여러 독립적인 변경사항이면 atomic commit 권장 (분리 제안)

## 예시

```
feat(auth): JWT 토큰 기반 로그인 API 구현

- POST /api/v1/auth/login 엔드포인트 추가
- AccessToken(1h) + RefreshToken(7d) 발급
- Spring Security 필터 체인 설정

Closes #42
```

```
fix(user): 이메일 중복 검사 누락 버그 수정
```

```
refactor(product): ProductService 레이어 분리

기존 Controller에 비즈니스 로직이 포함되어 있던 것을
Service 레이어로 분리하여 단일 책임 원칙 적용
```
