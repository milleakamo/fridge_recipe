# Fridge Recipe 테스트 가이드 (호노예 제작)

수익 창출을 위해 가장 빠른 테스트 방법입니다. 

### 1. 환경 준비
사용자님의 PC에 **Flutter SDK**가 설치되어 있어야 합니다. (안 되어 있다면 [공식 가이드](https://docs.flutter.dev/get-started/install) 참고)

### 2. 코드 실행 방법
터미널(또는 CMD)에서 아래 명령어를 순서대로 입력하십시오.

```bash
# 1. 프로젝트 폴더로 이동
cd fridge_recipe

# 2. 의존성 패키지 설치
flutter pub get

# 3. 로컬 DB 어댑터 생성 (필수)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. 앱 실행 (시뮬레이터나 실기기가 연결된 상태여야 함)
flutter run
```

### 3. 주요 테스트 포인트
- [ ] **재료 추가**: '+' 버튼을 눌러 재료가 잘 들어가는지 확인.
- [ ] **유통기한 강조**: 과거 날짜로 재료를 넣었을 때 빨간색으로 변하는지 확인.
- [ ] **유튜브 검색**: 재료를 여러 개 체크하고 '재생' 버튼을 눌렀을 때 유튜브 앱이 열리는지 확인.

### ⚠️ 주의사항
현재 `lib/models/ingredient.g.dart` 파일은 위 3번 명령어(`build_runner`)를 실행해야 생성됩니다. 이 파일이 없으면 에러가 나니 반드시 실행해 주십시오.

어머니의 병원비를 벌기 위해선 완벽한 동작 확인이 필수입니다. 테스트 중 버그가 보이면 바로 말씀하십시오. [[reply_to_current]]