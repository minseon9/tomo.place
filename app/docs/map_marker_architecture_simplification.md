# Map Marker Architecture Simplification Plan

## 목표
- 기능: "내 위치 + 바라보는 방향"을 구글 맵에 안정적으로 표시한다.
- 아키텍처: 지도 SDK 의존(google_maps_flutter)을 표시 단계에 국한한다.
- 복잡도: 오버엔지니어링을 피하고, 테스트/교체 용이성을 유지한다.

## 현재 구조 요약
- 스트림: `LocationStreamService` → 위치/정확도/heading 생산 (OK, 유지)
- 상태: `mapMarkersProvider: Set<MapMarker>` (SDK 비의존 상태, OK)
- 렌더: `MapWidget` → `MapRenderer`/`GoogleMapRenderer`
- 아이콘: atoms/molecules에서 `BitmapDescriptor` 생성(현 구조), Renderer도 아이콘 해석 로직 일부 보유

### 문제점
- 아이콘 생성이 atoms/molecules와 Renderer에 분산되어 경계가 모호함
- 비동기 아이콘 로딩/캐싱/해결이 여러 레이어에 걸쳐 복잡도가 상승
- 요구사항 대비 설계 요소가 과다(IconSpec/Resolver 다층 구조)

## 단순화 원칙
1. SDK 의존은 Renderer 단일 지점에서만: `BitmapDescriptor`는 Renderer에서만 생성/사용
2. UI/도메인은 오직 "무엇을 보여줄지"만 표현: `MapMarker`(좌표, 회전, 아이콘키)
3. 아이콘은 키 기반으로만 지정: `iconKey` → Renderer에서 에셋 경로 매핑/캐싱
4. 테스트는 `Set<MapMarker>` 단위로 수행: 플러그인 타입 배제

## 목표 구조 (간결 버전)
- 스트림: 유지 (위치/heading 생산)
- 상태: `mapMarkersProvider: Set<MapMarker>` 유지
- 렌더러: `GoogleMapRenderer` 내부에 아래 로직 집중
  - iconKey → 에셋 경로 매핑(단순 switch)
  - SVG → BitmapDescriptor 변환 + 메모리 캐시 (key=size+iconKey)
  - `MapMarker → Marker` 변환 일괄 수행
- atoms/molecules: UI 아이콘 미리보기나 일반 위젯에서만 사용(선택). 지도 마커 아이콘 생성 책임 제거

## 변경안 (최소 단계)
1) atoms/molecules 정리
   - `DirectionArrowAtom`, `CurrentLocationMarkerAtom`: 지도 마커용 `BitmapDescriptor` 생성 책임 제거(향후 필요 시 일반 위젯에서만 활용)
   - 지도 마커 아이콘은 "iconKey"로만 지정하도록 컨벤션 확립 (예: 'current_with_direction')

2) MapMarker 확정 스펙
   - `MapMarker { id, lat, lng, rotation, anchorX, anchorY, iconKey, title?, snippet? }`
   - Provider는 여전히 `Set<MapMarker>`만 유지

3) GoogleMapRenderer 단순화
   - 입력: `Set<MapMarker>`
   - 내부: `iconKey -> assetPath` 매핑, 캐시, 변환, `Marker` 생성
   - 출력: `GoogleMap.markers`에 전달

4) MapWidget
   - 단순히 `markerSpecs`와 렌더러 연결
   - 아이콘 리졸버 주입이 필요 없다면 생략(렌더러 내부 기본 구현 사용)

5) 성능/UX 보완(필요 시)
   - 최초 렌더 전에 iconKey 집합 사전 로드(옵션)
   - 캐시 적중 시 동기 반환, 미적중 시 기본 마커 → 다음 프레임에 갱신

## 장단점
- 장점: 경계 명확, 파일 수/추상화 수 감소, 테스트 쉬움, 의존 단순
- 단점: 아이콘 커스터마이징 다양성이 필요해질 때 Renderer에 로직이 집중됨(그러나 요구사항 범위 내에서는 충분)

## 향후 확장 포인트(필요해질 때만)
- 다중 테마/다중 사이즈 아이콘: iconKey 네이밍 컨벤션(`key@size@theme`)으로 간단 해결 가능
- 다른 SDK(Naver 등) 도입: 해당 Renderer에서만 변환/캐시 로직 구현

## 적용 순서(코드에 최소 영향)
1. atoms/molecules에서 마커 아이콘 생성 호출 제거(참조만 제거)
2. `GoogleMapRenderer`에 iconKey→에셋 매핑/캐시 로직 유지/정리
3. `MapWidget`은 `markerSpecs`만 전달
4. 스트림/상태/권한 로직은 변경 없음

## 결론
- "무엇을 그릴지(도메인)"와 "어떻게 그릴지(렌더러)"를 명확히 분리하되, 아이콘 변환/캐시를 Renderer로 단일화해 복잡도를 낮춘다.
- 요구사항(내 위치/방향 표시) 범위에서는 위 구조가 가장 단순·안정적이며, SDK 의존 축소와 테스트 용이성도 함께 달성한다.


