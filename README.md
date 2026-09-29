# 반응형 포트폴리오 웹사이트

외부 라이브러리 없이 순수 HTML, CSS, JavaScript만으로 만든 반응형 포트폴리오 웹사이트입니다.
"사용자 이벤트 → 상태 변경 → DOM 업데이트"로 이어지는 웹의 기본 동작 원리를 직접 구현하고, GitHub API 연동을 통해 로딩/성공/에러/빈 상태를 처리하는 경험을 담았습니다.

## 배포 URL

🔗 https://davekim-dev.github.io/basic-4-1/

## 사용 기술

- **HTML5** — 시맨틱 마크업 (`header`, `nav`, `main`, `section`, `article`, `footer`)
- **CSS3** — CSS 변수(Custom Properties), Flexbox, Grid, 미디어 쿼리 기반 반응형 디자인
- **JavaScript (ES6+)** — `const`/`let`, 화살표 함수, 템플릿 리터럴, 구조분해 할당, 배열 메서드(`map`/`forEach`)
- **GitHub REST API** — `fetch` + `async/await`로 저장소 목록 연동
- **Web Storage API** — `localStorage`를 이용한 다크 모드 상태 유지
- **Intersection Observer API** — 스크롤 등장 애니메이션

별도의 프레임워크, 빌드 도구, UI 라이브러리를 사용하지 않았습니다.

## 주요 기능

- 반응형 레이아웃 (모바일 / 태블릿 768px / 데스크톱 1024px)
- 다크 모드 토글 + `localStorage` 상태 저장 (새로고침 후에도 유지)
- 햄버거 메뉴 토글 (모바일 네비게이션)
- 부드러운 스크롤 이동 및 스크롤 탑(Top) 버튼
- 스크롤에 따른 네비게이션 바 스타일 변경
- Intersection Observer 기반 스크롤 등장 애니메이션
- GitHub API로 저장소 목록을 불러와 카드로 렌더링 (로딩 / 성공 / 에러 / 빈 상태 UI 처리)
- Contact 폼 유효성 검사 (필수값, 이메일 형식, 필드별 에러 메시지 표시)

## 프로젝트 구조

```
├── index.html          # 메인 페이지
├── css/
│   └── style.css       # 스타일시트
├── js/
│   └── script.js       # 인터랙션 / API 연동 / 폼 검증 로직
└── images/
    └── profile.png      # 프로필 이미지
```

## 로컬 실행 방법

1. 저장소를 클론합니다.
   ```bash
   git clone https://github.com/davekim-dev/basic-4-1.git
   ```
2. VS Code에서 폴더를 열고 `index.html`을 우클릭 → **Open with Live Server** 로 실행합니다.

## 참고 사항

- GitHub API는 인증 없이 호출 시 시간당 60회 제한이 있어, 짧은 시간 내 반복 새로고침 시 요청이 제한(403)될 수 있습니다. 이 경우 에러 상태 UI와 재시도 버튼이 표시됩니다.
