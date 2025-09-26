# Map 도메인 구조 제안

## 현재 구조의 문제점
- Map 관련 코드가 `shared`와 `home` 도메인에 분산
- Map 도메인의 경계가 불분명
- Map 기능이 확장될 때 구조적 한계

## 제안하는 Map 도메인 구조

```
lib/domains/map/
├── core/
│   ├── entities/
│   │   ├── map_position.dart
│   │   ├── map_marker.dart
│   │   └── map_state.dart
│   ├── repositories/
│   │   ├── map_repository.dart
│   │   └── location_repository.dart
│   └── usecases/
│       ├── get_current_location_usecase.dart
│       ├── move_to_location_usecase.dart
│       └── add_marker_usecase.dart
├── data/
│   ├── repositories/
│   │   ├── map_repository_impl.dart
│   │   └── location_repository_impl.dart
│   └── services/
│       ├── location_service.dart
│       └── map_service.dart
├── presentation/
│   ├── controllers/
│   │   └── map_notifier.dart
│   ├── providers/
│   │   └── map_providers.dart
│   ├── widgets/
│   │   ├── atoms/
│   │   │   ├── map_marker.dart
│   │   │   └── location_button.dart
│   │   ├── molecules/
│   │   │   └── map_controls.dart
│   │   └── organisms/
│   │       └── map_widget.dart
│   └── pages/
│       └── map_page.dart
└── routes/
    └── map_routes.dart
```

## 장점
1. **명확한 도메인 경계**: Map 관련 모든 코드가 한 곳에 집중
2. **확장성**: 새로운 Map 기능 추가 시 구조적 일관성 유지
3. **재사용성**: 다른 도메인에서도 Map 기능을 쉽게 사용 가능
4. **테스트 용이성**: Map 도메인만 독립적으로 테스트 가능

## 마이그레이션 계획
1. `shared/ui/maps/` → `domains/map/presentation/widgets/`
2. `shared/providers/map_providers.dart` → `domains/map/presentation/providers/`
3. `domains/home/presentation/controller/map_notifier.dart` → `domains/map/presentation/controllers/`
4. `domains/home/presentation/widgets/organisms/map_widget.dart` → `domains/map/presentation/widgets/organisms/`

## Home 도메인과의 관계
- Home 도메인은 Map 도메인을 **사용**하는 관계
- Home 도메인에서 Map 도메인의 Provider들을 import하여 사용
- Map 도메인은 Home 도메인에 의존하지 않음 (단방향 의존)
