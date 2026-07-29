# TALKSEO (톡서)

## 소개

독서 과정을 기록하고 시각화하며, 커뮤니티를 통해 독서 경험을 나누는 iOS 앱입니다. 독서 타이머로 실시간 독서 시간을 기록하고, 도서별 감상평을 남기고, 완독 기록을 시각화·통계로 확인할 수 있습니다. 3인 팀 프로젝트로, 저는 로그인/회원가입, 독서 타이머, 도서 상세, 커뮤니티 하단 네비게이션, 마이페이지, 스플래시 화면을 담당했습니다.

## 🛠 기술 스택

- **Frontend**: Swift, SwiftUI (Xcode)
- **Backend**: PHP
- **Database**: MySQL

## ✨ 주요 기능

- **로그인 / 회원가입**: 아이디 중복 확인 포함 (`LoginView`, `SignUpView`)
- **독서 타이머**: 실시간 독서 시간 기록 및 세션 저장 (`BookTimerView`)
- **도서 검색 및 상세**: 도서 검색, 상세 정보, 완독 도서 상세 (`SearchBookView`, `SearchDetailView`, `DetailBookView`, `CompletedBookDetailView`)
- **독서 기록 작성**: 감상평 작성 및 결과 화면 (`BookWriteView`, `SaveBookView`, `ResultBookView`)
- **커뮤니티**: 글 작성/상세/댓글, 좋아요 (`CommunityView`, `ComuWriteView`, `ComuDetailView`, `WriteMainView`, `WriteReviewMainView`)
- **마이페이지 및 하단 네비게이션**: 사용자 정보, 완독 기록, 탭 전환 (`MyPageView`, `BotNav`)

## 📁 구조

```
talkseo/
├── Php/                          # 백엔드 API (로그인, 도서, 독서 세션, 커뮤니티, 좋아요/신고)
├── talkseo/
│   ├── talkseo.xcodeproj/
│   └── talkseo/                  # SwiftUI 화면
│       ├── LoginView.swift / SignUpView.swift
│       ├── BookTimerView.swift / BookWriteView.swift / SaveBookView.swift
│       ├── SearchBookView.swift / SearchDetailView.swift / DetailBookView.swift
│       ├── CommunityView.swift / ComuWriteView.swift / ComuDetailView.swift
│       ├── MyPageView.swift / BotNav.swift / RootView.swift / MainView.swift
└── README.md
```

### DB 주요 테이블

- `USERS` — 사용자 정보
- `BOOK` / `BOOK_AUTHOR` / `BOOK_PUBLISHER` — 도서 정보
- `USER_BOOK` — 사용자별 독서 상태 (읽기 전 / 읽는 중 / 중단 / 완료)
- `READING_SESSION` — 독서 세션 기록 (시작/종료 페이지, 독서 시간)
- `REVIEW` / `REVIEW_LIKE` — 감상평 및 좋아요
- `COMMUNITY_POST` / `POST_COMMENT` / `POST_IMAGE` / `POST_LIKE` — 커뮤니티 글/댓글/이미지/좋아요
- `SEARCH_LOG` / `REPORT` — 검색 로그 및 신고

## ▶️ 실행 방법

### 백엔드 (PHP + MySQL)

```bash
# XAMPP/MAMP 등으로 PHP + MySQL 실행 후
# Php/ 폴더를 웹 서버 루트에 배치
# Php/db.php에 DB 접속 정보(호스트/계정/DB명) 설정
```

### iOS 앱

```bash
open talkseo/talkseo.xcodeproj
```

Xcode에서 시뮬레이터를 선택해 실행합니다. 백엔드 API 주소는 앱 내 네트워크 요청 부분에서 로컬 서버 주소로 맞춰야 합니다.

## 📸 결과

로그인부터 독서 타이머, 도서 기록, 커뮤니티 글쓰기까지 이어지는 전체 플로우가 iOS 앱에서 PHP 백엔드와 통신하며 동작합니다.

## 화면 미리보기

### 스플래시


### 로그인 / 회원가입


### 독서 타이머


### 도서 상세


### 커뮤니티


### 마이페이지


## 팀원 및 역할

| 이름 | 담당 |
|---|---|
| 고정은 | 로그인/회원가입/프로필, 커뮤니티, 설정 |
| 곽가린 | 로그인/회원가입, 독서 타이머, 도서 상세, 커뮤니티 하단바, 마이페이지, 스플래시 |
| 김한나 | 도서 검색/상세, 기록 작성, 커뮤니티 글 작성 |
