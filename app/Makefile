.PHONY: help test test-coverage test-watch clean install

# 기본 도움말
help:
	@echo "Tomo.place Flutter App - Available Commands:"
	@echo ""
	@echo "Development:"
	@echo "  install     - Install dependencies"
	@echo "  clean       - Clean build artifacts"
	@echo ""
	@echo "Testing:"
	@echo "  test        - Run all tests"
	@echo "  test-coverage - Run tests with coverage report"
	@echo "  test-watch  - Run tests in watch mode"
	@echo "  test-file   - Run tests for specific file (FILE=path/to/test.dart)"
	@echo "  test-pattern - Run tests matching pattern (PATTERN=LoginUseCase)"
	@echo ""
	@echo "Examples:"
	@echo "  make test-file FILE=test/domains/auth/core/usecases/login_usecase_test.dart"
	@echo "  make test-pattern PATTERN=AuthToken"

# 의존성 설치
install:
	fvm flutter pub get

# 빌드 아티팩트 정리
clean:
	fvm flutter clean
	fvm flutter pub get

# 모든 테스트 실행
test:
	fvm flutter test

# 커버리지와 함께 테스트 실행
test-coverage:
	fvm flutter test --coverage
	@echo "Coverage report generated at: coverage/lcov.info"
	@echo "To view HTML report: make coverage-html"

# HTML 커버리지 리포트 생성
coverage-html:
	@if [ ! -f coverage/lcov.info ]; then \
		echo "No coverage data found. Run 'make test-coverage' first."; \
		exit 1; \
	fi
	genhtml coverage/lcov.info -o coverage/html
	@echo "HTML coverage report generated at: coverage/html/index.html"

# 특정 파일 테스트
test-file:
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make test-file FILE=path/to/test.dart"; \
		echo "Example: make test-file FILE=test/domains/auth/core/usecases/login_usecase_test.dart"; \
		exit 1; \
	fi
	@if [ ! -f "$(FILE)" ]; then \
		echo "Test file not found: $(FILE)"; \
		exit 1; \
	fi
	fvm flutter test "$(FILE)"

# 패턴 매칭 테스트
test-pattern:
	@if [ -z "$(PATTERN)" ]; then \
		echo "Usage: make test-pattern PATTERN=pattern"; \
		echo "Example: make test-pattern PATTERN=pattern"; \
		exit 1; \
	fi
	fvm flutter test --name="$(PATTERN)"

# 감시 모드로 테스트 실행
test-watch:
	fvm flutter test --watch

# 특정 도메인 테스트
test-auth:
	fvm flutter test test/domains/auth/

# 특정 레이어 테스트
test-core:
	fvm flutter test test/domains/auth/core/

test-infrastructure:
	fvm flutter test test/shared/infrastructure/

# 테스트 결과를 파일로 저장
test-output:
	fvm flutter test --reporter=json --reporter=expanded > test_results.txt
	@echo "Test results saved to: test_results.txt"

# 커버리지 임계치 확인 (very_good_cli 사용 시)
coverage-check:
	@if command -v very_good >/dev/null 2>&1; then \
		very_good test --coverage --min-coverage 80; \
	else \
		echo "very_good_cli not installed. Install with: dart pub global activate very_good_cli"; \
		echo "Or check coverage manually: make test-coverage"; \
	fi

# 테스트 디버깅 (verbose 출력)
test-debug:
	fvm flutter test --verbose

# 특정 플랫폼 테스트
test-android:
	fvm flutter test --platform=android

test-ios:
	fvm flutter test --platform=ios

# 테스트 성능 측정
test-performance:
	fvm flutter test --coverage --reporter=json | grep -E '"duration"|"test_count"|"failure_count"'
