---
description: Flutter 화면(Screen) 및 관련 파일 생성 (Screen, Provider/Bloc, Widget, 라우트 등록)
argument-hint: <화면명> (예: Login, UserProfile, ProductDetail)
---

다음 지시사항에 따라 Flutter 화면을 생성해주세요.

**화면명**: $ARGUMENTS (없으면 사용자에게 물어보세요)

## 생성할 파일

현재 프로젝트 구조(Riverpod vs Bloc 사용 여부 등)를 먼저 파악한 후 생성하세요.

### Feature 구조 (Clean Architecture)
```
lib/features/{feature_name}/
├── data/
│   ├── datasources/{feature_name}_remote_data_source.dart
│   └── repositories/{feature_name}_repository_impl.dart
├── domain/
│   ├── entities/{entity_name}.dart           # freezed 모델
│   ├── repositories/{feature_name}_repository.dart
│   └── usecases/get_{feature_name}.dart
└── presentation/
    ├── screens/{screen_name}_screen.dart      # 메인 화면
    ├── widgets/                               # 화면 전용 위젯
    └── providers/{screen_name}_provider.dart  # Riverpod (또는 bloc/)
```

## 각 파일 생성 규칙

### Screen
- `ConsumerStatefulWidget` 또는 `ConsumerWidget` 사용 (Riverpod)
- `Scaffold` 구조 유지
- 로딩 상태: `CircularProgressIndicator`
- 에러 상태: 에러 메시지 + 재시도 버튼
- 빈 상태: 적절한 empty state UI

### Provider (Riverpod)
- `@riverpod` 어노테이션 사용
- `AsyncNotifier` 또는 `Notifier` 패턴
- `Either<Failure, T>` 결과 처리

### Entity
- `@freezed` 어노테이션 사용
- `fromJson` / `toJson` 포함 (`json_serializable`)

### GoRouter 등록
- 현재 `app_router.dart`를 찾아서 새 라우트를 등록해주세요
- path constant를 별도로 정의하세요

## 포함할 기능 판단
- API 연동이 필요하면 Dio 기반 RemoteDataSource 생성
- 로컬 저장이 필요하면 Hive/SharedPreferences LocalDataSource 생성
- 폼이 필요하면 `TextEditingController` 및 validation 포함
- 목록 화면이면 pagination 고려 (`ListView.builder`)

## 주의사항
- `const` 생성자 최대한 활용
- `dispose()` 메서드에서 모든 Controller 정리
- 코드 생성 파일(`.g.dart`, `.freezed.dart`)은 직접 생성하지 말고 `build_runner`로 생성됨을 주석으로 안내
- 생성 후 `flutter pub run build_runner build` 실행 필요 여부 안내

생성 후 파일 목록과 GoRouter 등록 방법을 요약해주세요.
