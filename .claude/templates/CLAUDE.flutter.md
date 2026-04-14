# [프로젝트명] — Flutter

## Stack
- **Framework**: Flutter (latest stable)
- **Language**: Dart (null safety)
- **State Management**: Riverpod 2.x (`@riverpod` 코드 생성)
- **Navigation**: GoRouter
- **Network**: Dio + Retrofit
- **Models**: Freezed + json_serializable
- **Error Handling**: fpdart (`Either<Failure, T>`)

## Agents
| 작업 | Agent |
|------|-------|
| 새 파일 생성 | `flutter-generator` |
| 기존 코드 수정 | `flutter-modifier` |
| 테스트 작성 | `flutter-tester` |
| 코드 리뷰 | `code-reviewer` |

## Commands
| 커맨드 | 용도 |
|--------|------|
| `/plan <기능>` | 코드 작성 전 설계 및 확인 |
| `/new-screen <Name>` | Screen + 전체 레이어 생성 |
| `/test [파일]` | 테스트 자동 생성 |
| `/review [staged\|diff\|파일]` | 코드 리뷰 |
| `/improve <실수 설명>` | 새 규칙을 이 파일에 추가 |
| `/commit [힌트]` | Conventional Commits 커밋 |
| `/memory [add\|search]` | Second Brain 조회·추가·검색 |

---

## 아키텍처 규칙 (Clean Architecture)

```
lib/
├── core/
│   ├── errors/       # Failure 클래스 정의
│   ├── network/      # Dio 클라이언트, 인터셉터
│   └── utils/        # 공통 유틸리티, 확장
├── features/
│   └── {feature}/
│       ├── data/         # Repository impl, DataSource, Model
│       ├── domain/       # Entity, Repository interface, UseCase
│       └── presentation/ # Screen, Widget, Provider
└── shared/
    ├── widgets/      # 재사용 위젯
    └── providers/    # 공유 Provider
```

### 레이어 의존 방향
`presentation` → `domain` ← `data`

**`domain`은 Flutter/외부 패키지에 의존하지 않습니다.**
**`presentation`이 `data`를 직접 import하면 안 됩니다.**

---

## 반드시 지켜야 할 규칙 (MUST)

### Null Safety
```dart
// ✅ 안전한 null 처리
final name = user?.name ?? '이름 없음';

// ❌ 절대 금지 — 확신 없이 ! 사용
final name = user!.name;
```

### const 생성자
```dart
// ✅ const 최대한 활용
const SizedBox(height: 16)
const Text('안녕하세요')

// ❌ 불필요한 non-const
SizedBox(height: 16)
```

### 리소스 해제
```dart
// ✅ 반드시 dispose() 구현
@override
void dispose() {
  _emailController.dispose();
  _scrollController.dispose();
  super.dispose();
}

// ❌ 절대 금지 — Controller를 dispose 없이 생성
```

### Either 결과 처리
```dart
// ✅ fold로 반드시 양쪽 처리
final result = await repository.getUser(id);
result.fold(
  (failure) => state = AsyncError(failure.message, StackTrace.current),
  (user) => state = AsyncData(user),
);

// ❌ 절대 금지 — Either 결과 무시
await repository.getUser(id);
```

### Riverpod Provider
```dart
// ✅ @riverpod 어노테이션 사용
@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  Future<User> build(int id) => _fetch(id);
}

// ❌ Provider를 직접 생성자로 만들지 않음
final userProvider = FutureProvider((ref) => ...);  // 단순 경우만 허용
```

---

## 절대 하면 안 되는 것 (NEVER)

- `!` 연산자를 non-null 보장 없이 사용
- `dispose()` 없이 `TextEditingController`, `AnimationController` 생성
- UI 스레드에서 blocking 연산 실행 (`Isolate` 또는 `compute` 사용)
- `presentation` 레이어에서 `data` 레이어 직접 import
- `domain` 레이어에서 Flutter 패키지 import
- `Either` 결과를 처리하지 않고 무시
- `.freezed.dart`, `.g.dart` 파일 직접 수정
- `BuildContext`를 async gap 이후 사용 (mounted 체크 없이)

---

## Build Runner 규칙

`@freezed`, `@riverpod`, `@JsonSerializable`, Retrofit 어노테이션 변경 후:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
**위 명령어 실행 필요 여부를 항상 명시적으로 안내합니다.**

---

## 성능 기준

- `ListView`가 20개 이상 항목: `ListView.builder` 필수
- 이미지: `cached_network_image` 패키지 사용
- Riverpod: 필요한 상태만 `select`로 구독

---

## 커버리지 게이트

**git push 전 Flutter 라인 커버리지 90% 이상 필수** (`.claude/hooks/pre-push.sh` 자동 검사)

커버리지 미달 시 동작:
1. pre-push 훅이 푸시를 차단하고 미달 수치를 출력합니다
2. 커버리지가 낮은 파일에 `/test <파일>` 커맨드로 테스트를 추가합니다
3. `flutter test --coverage`로 커버리지를 재확인합니다
4. 90% 이상이 되면 다시 `git push`를 시도합니다

**커버리지 제외 파일 (pubspec.yaml 또는 test 설정에서 관리):**
- `*.g.dart` (코드 생성 파일)
- `*.freezed.dart` (Freezed 생성 파일)
- `main.dart` (앱 진입점)

---

## 학습된 규칙 (AI 실수 후 추가)

<!-- /improve 커맨드로 새 규칙이 여기에 추가됩니다 -->

---

## Memory 관리 지침

> Claude는 아래 상황에서 `memory/MEMORY.md`를 **자동으로** 업데이트합니다.
> 사용자가 요청하지 않아도 기록하고, 기록 후 "memory에 저장했습니다." 한 줄만 언급합니다.

**자동 기록 트리거:**
- `/plan` 승인 → 구현할 기능과 선택한 설계 방식 기록
- `/improve` 실행 → 어떤 실수였는지, 추가된 규칙 요약 기록
- 복잡한 버그 해결 → 원인, 해결 방법, 재발 방지 포인트 기록
- 외부 라이브러리/API 도입 결정 → 선택 이유, 대안 기록
- 아키텍처 또는 폴더 구조 변경 → 변경 전/후, 이유 기록
- 성능 문제 발견 및 해결 → 병목 지점, 해결 방법 기록

**`memory/MEMORY.md` vs `CLAUDE.md` 구분:**
- `memory/MEMORY.md` — 맥락과 히스토리 (왜 이 결정을 했는가)
- `CLAUDE.md` — 규칙 (앞으로 어떻게 해야 하는가)
