### 목표
- 생성되는 버튼이 화면 디바이스의 width를 넘기지 않으면 1줄만으로 필터 버튼 영역을 구성,
- 만약 디바이스 width를 넘긴다면 2줄로 만들어줘야 하는 필터 버튼 영역을 만들어야 했다.


<img width="400" alt="스크린샷 2024-12-29 오후 8 30 00" src="https://github.com/user-attachments/assets/886484fd-a328-460c-b41e-c9638c4d5cad" />
<img width="400" alt="스크린샷 2024-12-29 오후 8 30 47" src="https://github.com/user-attachments/assets/921163aa-2f2e-41ac-b7cc-136b0b7990a9" />


---

### 설명

내가 설정한 로직은 아래와 같다.
<br><br>

<img width="400" alt="스크린샷 2024-12-29 오후 9 36 44" src="https://github.com/user-attachments/assets/06444b00-2ced-490c-9cc1-a551bae3e6e5" />

<br><br>

- `UIStackView`로 구성을 한다.
- `currentRow`
    - 가로 한줄을 추가해줄 때 사용하기 위한 `UIStackView`
- `mainStackView`
    - 전체 필터 버튼의 영역을 관리하는 `UIStackView`

<br>

코드 구성은 아래와 같다.

- 특이사항
    - refreshControl은 테스트 편하게 해보려고 넣었다.
    - UIApplication Extension도 기존 레퍼런스를 참고했다.
    - Button 설정은 configuration을 사용해봤다.
