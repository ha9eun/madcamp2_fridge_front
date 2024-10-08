# 냉장고를 부탁해

## Outline


![냉장고를 부탁해 배너](https://github.com/ha9eun/madcamp2_fridge_front/assets/146503043/560f44f6-e6e4-4440-8f32-7a5c211603da)


개발에 몰입하느라 내 냉장고에 뭐가 있는지 기억이 나지 않는 사람..?

분명 재료는 있는데 뭘 먹어야 할 지 생각이 나지 않는 사람?

아앗..! 유통 기한이 기억나지 않는 사람???

이제는 <냉장고를 부탁해> 로 내 냉장고를 체계적이고 효율적으로 관리해보세요! 

**개발 환경**

- **Front-end** : Flutter
- **Back-end** : django
- **Server** : Kcloud
- **Database** : MySQL
- **IDE** : Visual Studio Code, Android Studio

## Team

조승완(KAIST)

하은수(숙명여대)

## Kakao Login

https://github.com/user-attachments/assets/959fa520-8e15-43f1-8d1d-81f927160fea

`카카오 로그인 API`를 사용해 카카오 계정으로 로그인할 시 자동으로 DB에 유저 정보가 저장됩니다.

`카카오 ID`와 `닉네임`을 불러오도록 구현했습니다.

카카오톡 앱이 설치되어 있지 않은 경우는 카카오 계정 로그인 웹으로 `리다이렉트` 됩니다.


### 자동로그인

한 번 로그인한 적이 있는 계정에서는 다시 카카오 로그인을 할 필요 없이 바로 탭으로 이동합니다.

`SharedPreference`를 사용해 로그인 정보를 로컬에 저장하도록 구현했습니다.




## Tab 1: 나의 냉장고
https://github.com/user-attachments/assets/b19a7188-cb1d-4b08-89ca-d75f2d3ab228
### 재료 등록, 수정 및 삭제

`재료 추가` 버튼을 누르면 알맞은 카테고리, 이름, 양, 유통기한을 설정해 `재료를 등록`할 수 있습니다.

`재료 수정, 삭제` 버튼을 통해 재료를 관리할 수 있습니다.

냉장고 속 재료는 우측 `신선도` 색깔을 통해 한 눈에 `유통기한을 확인`할 수 있습니다.

https://github.com/user-attachments/assets/92014bbf-3ebe-423f-9c70-75938636d508

### 식사하기

식사하기 버튼을 통해 `레시피를 선택`하거나, 레시피 없이 `재료들을 조합`할 수 있습니다.

식사 완료를 하게 되면 자동으로 재료에 반영되며, 다 먹은 재료는 재료 리스트에서 사라집니다.

### 히스토리

히스토리 버튼을 통해 나의 식사 `히스토리`를 확인할 수 있습니다.

레시피를 선택하지 않았던 식사의 경우 `커스텀 레시피`라는 이름으로 등록됩니다.

## Tab 2: 레시피
https://github.com/user-attachments/assets/e4219209-03b1-4f48-825a-11d27a0f0309

### 레시피 뷰, 검색

`ListView`로 등록된 레시피를 확인할 수 있고, `검색 바`를 이용해 레시피를 검색할 수 있습니다.

레시피를 누르면 `상세 페이지`로 이동됩니다.

https://github.com/user-attachments/assets/66838db1-eeab-487d-a8b8-d3154f6cc161

### AI 추천 받기

`AI 추천 받기` 버튼을 누른 후, 키워드를 입력하면 내 재료를 반영해 `키워드`에 맞는 레시피를 골라줍니다.

`Gemini API`를 사용해 구현했습니다.

https://github.com/user-attachments/assets/f521a68d-f9d1-41f1-ba66-23dce612f869

### 상세 페이지

`상세 페이지`에서는 관련 유튜브 영상 하나, 재료, 조리 방법을 한눈에 확인할 수 있습니다.

유튜브 영상은 `Youtube Data API`를 사용해 `video ID`를 가져오는 방식으로 구현했습니다.

Gemini의 한마디 버튼을 누르면 `gemini API`와 연결되어 입맛을 돋구는 한마디를 해줍니다.

상세 페이지에서 식사하기 버튼을 누르면 자동으로 `식사하기` 페이지와 연결되고, 내 재료 중 필요한 재료들을 `자동으로 등록`해 줍니다.

## Tab 3: 커뮤니티

https://github.com/user-attachments/assets/e9d00722-e4da-4314-af0b-4711cb97b13e


### 게시글 검색, 카테고리 설정

상단의 검색 바를 사용해 게시글을 `검색`할 수 있습니다.

[’전체’, ‘자유’, ‘질문’, ‘공유’] 중 `카테고리`를 선택하여 원하는 게시글만 확인할 수 있습니다.

https://github.com/user-attachments/assets/49d4edf8-c01a-4c1e-bfbf-9f0195b90922

### 글 등록

우측 하단의 `FloatingActionButton`을 통해 글을 등록할 수 있도록 구현했습니다.

글을 누르면 글 `상세 페이지`를 확인할 수 있습니다.

https://github.com/user-attachments/assets/9ea7b994-3d59-4758-9de0-74e4b038a77b

### 글 상세 페이지

`제목, 작성 시간, 날짜, 내용`을 확인할 수 있는 탭입니다.

내가 작성한 글일 경우에는 상단의 설정 버튼을 눌러 `수정 / 삭제`를 할 수 있습니다.

하단에 댓글 창을 통해 댓글을 확인할 수 있고, 내가 쓴 댓글일 경우 `등록 / 삭제`를 할 수 있습니다.

## ERD

![MyFridgeDB](https://github.com/ha9eun/madcamp2_fridge_front/assets/146503043/42db3b67-2f27-41be-8a29-5b1ae2e5ae96)


## APK File

https://drive.google.com/file/d/11B_tc5nMHCsMf3OskABfY9taILpB65F_/view?usp=sharing
