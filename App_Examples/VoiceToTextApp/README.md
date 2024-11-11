## 주요 기능

음성녹음 파일 저장 & 녹음 시 음성을 텍스트로 변환합니다.

## 사용한 프레임워크

- UIKit
- Speech
- AVFoundation

## 세부 기능

- AVFoundation 프레임워크를 이용한 음성 녹음 / 일시중지 / 초기화
- Speech 프레임워크를 이용한 음성 -> 텍스트 즉시 변환

## 결과 확인

- 텍스트 변환은 "Move To the Next Level" 버튼 클릭시 print문으로 출력이 됩니다.
- 음성녹음 파일은 실제 디바이스에서 테스트 한다면 다음과 같은 방법으로 확인할 수 있습니다.
  - Xcode 상단 Window 클릭
  - Devices and Simulators 클릭
  - 여러 앱들이 나오는데, VoiceToTextApp을 클릭후 아래에 위치한 ꞏꞏꞏ 클릭
  - Download Container 클릭
  - 다운받은 파일을 우클릭
  - 패키지 내용보기 -> AppData -> Documents에 m4a 파일 확인

* 프레임워크 적용을 위해 공부한 내용, 기능 구현만을 위한 코드입니다.
* 학습 정리는 정리를 완료한 이후 바로 링크로 첨부할 예정입니다.
