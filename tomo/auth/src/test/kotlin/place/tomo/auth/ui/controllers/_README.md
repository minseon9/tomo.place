# Auth 모듈 테스트 구조

- controllers: 컨트롤러 단위 테스트 (WebMvcTest/슬라이스 고려)
- application/services: 애플리케이션 서비스 단위 테스트 (Mock 의존성)
- domain/services: 도메인 서비스 단위 테스트 (Mock Repository)
- domain/entities: 엔티티 동작 테스트

주의: 본 README는 구조 안내용이며, 실제 테스트 로직은 각 테스트 파일에 구현합니다.
