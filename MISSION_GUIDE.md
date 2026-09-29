# 반응형 포트폴리오 웹사이트 미션 — 개념 정리 가이드

> 이 문서는 "무엇을 만드는가"가 아니라 **"왜 이걸 만드는가, 그리고 여기 쓰이는 개념들이 각각 무엇인가"** 를 설명하는 학습 문서입니다.
> 구현 스펙은 미션 요구사항 원문을 따르고, 이 문서는 그 요구사항들이 왜 그렇게 정해졌는지를 풀어 씁니다.

---

## 목차

1. [이 미션은 무엇을 위한 것인가](#1-이-미션은-무엇을-위한-것인가)
2. [큰 그림: 웹이 동작하는 한 문장](#2-큰-그림-웹이-동작하는-한-문장)
3. [HTML — 문서의 구조](#3-html--문서의-구조)
4. [CSS — 표현과 레이아웃](#4-css--표현과-레이아웃)
5. [JavaScript — 동작](#5-javascript--동작)
6. [비동기와 API 연동](#6-비동기와-api-연동)
7. [상태 관리 패턴 — 이 미션의 진짜 핵심](#7-상태-관리-패턴--이-미션의-진짜-핵심)
8. [브라우저 저장소와 상태 유지](#8-브라우저-저장소와-상태-유지)
9. [배포 — GitHub Pages](#9-배포--github-pages)
10. [React로 가는 다리](#10-react로-가는-다리)
11. [자주 하는 실수와 점검 포인트](#11-자주-하는-실수와-점검-포인트)
12. [용어 사전](#12-용어-사전)
13. [개발 환경과 허용 리소스](#13-개발-환경과-허용-리소스)
14. [제약 사항 — 왜 이렇게 제한하는가](#14-제약-사항--왜-이렇게-제한하는가)
15. [제출물 체크리스트](#15-제출물-체크리스트)
16. [결과 예시 읽는 법 (와이어프레임)](#16-결과-예시-읽는-법-와이어프레임)

---

## 1. 이 미션은 무엇을 위한 것인가

### 1.1 표면적 목표와 실제 목표

| 구분 | 내용 |
|---|---|
| **표면적 목표** | 반응형 포트폴리오 웹사이트 1개를 만들어 GitHub Pages에 배포한다 |
| **실제 목표** | 프레임워크가 "대신 해주던 일"을 손으로 직접 해보면서, 프레임워크가 무엇을 추상화했는지 이해한다 |

포트폴리오 사이트는 **핑계**에 가깝습니다. 이 미션이 포트폴리오를 고른 이유는:

- 섹션이 여러 개라서 **문서 구조(시맨틱 마크업)** 를 설계할 필요가 생긴다
- 카드 목록이 있어서 **Grid 레이아웃**과 **배열 → HTML 변환**이 자연스럽게 필요해진다
- 폼이 있어서 **이벤트 처리와 유효성 검사**가 필요해진다
- 외부 데이터(GitHub API)가 있어서 **비동기 처리와 로딩/에러/빈 상태**를 반드시 다루게 된다
- 다크 모드가 있어서 **상태를 저장하고 복원하는 흐름**을 경험하게 된다

즉, 웹 개발에서 반복적으로 등장하는 문제들을 **한 프로젝트 안에 압축해 넣은 연습 문제**입니다.

### 1.2 왜 라이브러리 없이 만드는가

React, Vue, Angular, Tailwind, jQuery 모두 결국 브라우저가 이해하는 것은 **HTML / CSS / JavaScript** 세 가지뿐입니다. 프레임워크는 이 세 가지를 더 편하게 쓰기 위한 도구이지, 대체하는 것이 아닙니다.

라이브러리 없이 만들면 다음을 직접 체험하게 됩니다.

- **React의 `useState`가 없을 때** 상태 변경을 화면에 반영하려면 무슨 일이 필요한가 → 직접 DOM을 찾아 바꿔야 한다
- **React의 JSX가 없을 때** 배열을 카드 목록으로 그리려면 무슨 일이 필요한가 → 템플릿 리터럴 + `map()` + `innerHTML`
- **React의 리렌더링이 없을 때** 로딩/성공/에러 화면을 어떻게 전환하는가 → 상태 변수 + 조건 분기 + 렌더 함수

이 고생을 한 번 해봐야 React가 "왜 좋은지"가 체감됩니다. 반대로 이걸 건너뛰고 React를 배우면, React를 **문법 암기**로 배우게 됩니다.

### 1.3 미션이 요구하는 "설명할 수 있어야 한다"의 의미

과제 목표가 전부 "~를 설명할 수 있다"로 적혀 있는 것에 주목하세요. 이건 **코드가 동작하는 것만으로는 부족하다**는 뜻입니다.

- 코드가 동작한다 → 검색해서 붙여넣어도 가능
- 왜 그렇게 썼는지 설명할 수 있다 → 이해한 것

작업 중에 아래 질문에 답을 만들어두면 좋습니다.

- 이 부분에 `<section>`을 쓴 이유는? `<div>`를 쓰면 뭐가 달라지나?
- 여기는 왜 Flexbox고 저기는 왜 Grid인가?
- 왜 `defer`를 붙였는가? 안 붙이면 어떤 에러가 나는가?
- 왜 `async/await`인가? 콜백이나 `.then()`과 뭐가 다른가?
- 이 기능에서 "상태"는 정확히 어떤 변수인가?

---

## 2. 큰 그림: 웹이 동작하는 한 문장

이 미션 전체를 관통하는 흐름은 다음 한 줄입니다.

```
사용자 이벤트  →  상태 변경  →  DOM 업데이트  →  화면 변화
```

구체적인 예로 풀면:

```
[햄버거 버튼 클릭]
   → (이벤트) click 이벤트 발생
   → (상태)   isMenuOpen: false → true
   → (DOM)    navMenu.classList.add('active')
   → (화면)   CSS의 .nav-menu.active 규칙이 적용되어 메뉴가 나타남
```

```
[GitHub API 호출]
   → (이벤트) 페이지 로드
   → (상태)   status: 'loading'  → 화면: 스피너
   → (상태)   status: 'success', repos: [...] → 화면: 카드 목록
   → (상태)   status: 'error'    → 화면: 에러 메시지 + 재시도 버튼
```

이 문서의 나머지는 이 한 줄의 각 단계를 담당하는 기술을 설명합니다.

- **HTML**: 화면의 뼈대를 만든다 (무엇이 있는가)
- **CSS**: 그 뼈대를 어떻게 보이게 할지 정의한다 (어떻게 보이는가)
- **JavaScript**: 이벤트를 받고 상태를 바꾸고 DOM을 갱신한다 (어떻게 반응하는가)

---

## 3. HTML — 문서의 구조

### 3.1 시맨틱 마크업이란

**시맨틱(semantic) = 의미론적**. 태그 이름 자체가 "이 영역이 무엇인지"를 설명하도록 마크업하는 것입니다.

```html
<!-- 비시맨틱: 브라우저/스크린리더/검색엔진 입장에서 전부 똑같은 상자 -->
<div class="header">
  <div class="nav">...</div>
</div>
<div class="main">
  <div class="section">...</div>
</div>

<!-- 시맨틱: 태그 이름이 역할을 설명함 -->
<header>
  <nav>...</nav>
</header>
<main>
  <section id="about">...</section>
</main>
```

두 코드는 **화면상 결과가 완전히 동일**합니다. 그럼에도 시맨틱을 쓰는 이유는 화면 밖의 소비자들 때문입니다.

| 소비자 | 시맨틱 태그로 얻는 것 |
|---|---|
| **스크린 리더** (시각장애인 보조기기) | "메인 콘텐츠로 건너뛰기", "탐색 영역" 같은 랜드마크 이동이 가능해짐 |
| **검색 엔진** | 어디가 본문이고 어디가 부가 정보인지 판별 → 검색 노출에 영향 |
| **다른 개발자 (미래의 나)** | `</div>` 20개가 늘어선 코드에서 어디가 어디 닫는 건지 추적 불필요 |
| **브라우저 기본 동작** | `<button>`은 키보드 포커스/Enter 동작이 기본 제공, `<div>`는 직접 구현해야 함 |

### 3.2 주요 시맨틱 태그와 이 미션에서의 배치

| 태그 | 의미 | 이 미션에서의 위치 |
|---|---|---|
| `<header>` | 문서/섹션의 머리말 영역 | 상단 고정 네비게이션 바 |
| `<nav>` | 주요 탐색 링크 묶음 | 로고 + 메뉴 링크 |
| `<main>` | 문서의 주된 콘텐츠. **페이지당 1개** | Hero~Contact 전체를 감쌈 |
| `<section>` | 주제를 가진 콘텐츠 묶음. 보통 제목(`h2`)을 동반 | Hero, About, Skills, Projects, Contact |
| `<article>` | **그 자체로 독립적으로 배포 가능한** 콘텐츠 | GitHub 저장소 카드 하나하나 |
| `<footer>` | 문서/섹션의 꼬리말 | 저작권, 소셜 링크 |
| `<figure>` / `<figcaption>` | 이미지 + 설명 캡션 | About의 프로필 이미지(선택) |

**`<section>` vs `<article>` 구분 기준**
"이 덩어리를 잘라내서 RSS 피드나 다른 사이트에 그대로 붙여도 말이 되는가?"
- 된다 → `<article>` (블로그 글, 상품 카드, 저장소 카드)
- 안 된다, 이 페이지 안에서만 의미 있다 → `<section>` (About 섹션은 이 포트폴리오 밖에선 무의미)

즉, section은 내가 만든 웹(포트폴리오) 안에서만 의미가 있다! 
반대로 article은 다른 곳에 옮겨놓아도 잘 작동함! 독립적인 내용을 내 포트폴리오에 넣어놓은 격!

section = 하나의 주제 덩어리

arcticle은 그 자체로 완결된 컨텐츠 (위젯, 포스트, 뉴스 기사 등)



**`<div>`는 언제 쓰는가**
시맨틱 태그가 아깝지 않은 순수 "스타일링용 껍데기"일 때 씁니다. 예: `.container`(가운데 정렬 + 최대 너비 제한), 그리드 래퍼. `<div>`를 쓰는 게 잘못이 아니라, **의미가 있는 곳에 `<div>`를 쓰는 게** 잘못입니다.

### 3.3 접근성(Accessibility) 요구사항

미션에 명시된 두 가지는 접근성의 기본입니다.

**① 이미지의 `alt` 속성**

```html
<!-- 나쁨: 파일명 반복, 정보 없음 -->
<img src="profile.jpg" alt="profile.jpg">
<img src="profile.jpg" alt="이미지">

<!-- 좋음: 이미지를 볼 수 없는 사람에게 내용을 전달 -->
<img src="images/profile.jpg" alt="노트북 앞에서 웃고 있는 개발자 홍길동의 프로필 사진">

<!-- 순수 장식용 이미지는 빈 alt: 스크린리더가 건너뜀 -->
<img src="images/decoration-dot.svg" alt="">
```

`alt`는 이미지가 로드 실패했을 때 표시되는 대체 텍스트이자, 스크린 리더가 읽어주는 유일한 정보입니다.

**② `<label>`과 `for-id` 연결**

```html
<label for="user-email">이메일</label>
<input type="email" id="user-email" name="email">
```

`label`의 `for` 값과 `input`의 `id` 값이 일치해야 연결됩니다. 연결되면:

- 스크린 리더가 입력 칸에 포커스했을 때 "이메일, 편집 가능"이라고 읽어줌
- **라벨 텍스트를 클릭해도 입력 칸에 포커스가 감** (모바일에서 터치 영역이 넓어짐 = UX 개선)

`placeholder`는 라벨의 대체품이 아닙니다. 입력을 시작하면 사라지기 때문에, 다 입력한 뒤에는 이 칸이 무슨 칸이었는지 알 수 없게 됩니다.

### 3.4 앵커 링크와 프래그먼트

```html
<a href="#about">About</a>   <!-- 링크 -->
...
<section id="about">...</section>   <!-- 목적지 -->
```

`#`으로 시작하는 링크를 **프래그먼트 링크(fragment link)** 라고 하며, 같은 페이지 내 `id`가 일치하는 요소로 이동합니다. 이 미션의 "부드러운 스크롤"은 이 기본 동작을 부드럽게 만드는 것입니다(4.7절 참고).

---

## 4. CSS — 표현과 레이아웃

### 4.1 CSS 변수 (Custom Properties)

```css
:root {
  --color-primary: #2563eb;
  --color-bg: #ffffff;
  --color-text: #1f2937;
  --font-base: 'Pretendard', -apple-system, sans-serif;
  --space-sm: 0.5rem;
  --space-md: 1rem;
  --space-lg: 2rem;
  --radius: 12px;
  --transition: 0.25s ease;
}

[data-theme="dark"] {
  --color-bg: #111827;
  --color-text: #f9fafb;
}

body {
  background: var(--color-bg);
  color: var(--color-text);
  transition: background var(--transition), color var(--transition);
}
```

**개념 정리**

- `:root`는 문서의 최상위 요소(`<html>`)를 가리키는 선택자입니다. 여기 정의한 변수는 문서 전체에서 사용 가능합니다.
- `--이름: 값` 으로 선언하고, `var(--이름)` 으로 사용합니다.
- **상속됩니다.** 부모에서 정의한 변수를 자식이 그대로 씁니다.
- **런타임에 바뀝니다.** 이게 Sass 변수와의 결정적 차이입니다. Sass 변수는 컴파일 시점에 고정되지만, CSS 변수는 브라우저에서 JS로 바꿀 수 있습니다.

**다크 모드가 이 한 줄로 끝나는 이유**

```js
document.documentElement.setAttribute('data-theme', 'dark');
```

`<html data-theme="dark">`가 되는 순간, `[data-theme="dark"]` 블록의 변수 값이 `:root`의 값을 덮어씁니다(더 구체적인 선택자이므로). `var(--color-bg)`를 쓰던 **모든 규칙이 자동으로 새 값을 참조**하게 됩니다. 다크 모드용 CSS를 별도로 100줄 쓸 필요가 없습니다.

이것 자체가 **"상태 변경 → 전체 화면 렌더링 변화"** 의 가장 순수한 예시입니다.

### 4.2 박스 모델과 `box-sizing`

box = 요소(시맨텍 테그 애들)들에 의해 레이아웃을 걸쳐 만들어진 결과.. 즉, css가 만든 모든 결과물

"article" 이라는 요소 안에 box들이 여러개 들어가 있을 수 있음!

로고로 예를 들면, 
```<img src="logo.svg">``` 하나면 박스 1개, 

```<div><img><span>Codyssey</span></div>```면 박스 3개


모든 요소는 안쪽부터 `content(실제 내용) → padding(안쪽 여백) → border(테두리) → margin(다른 박스와 구별선 - 밀어내는 여백)` 의 상자입니다.

사실상 디자인 요소임. 어디까지가 내용이고 여백을 어떻게 할 것이고 다른 박스와 구별되는 바운더리를 어떻게 만들 것인가.

```css
* {
  box-sizing: border-box;
}
```

- 기본값 `content-box`: `width: 300px` + `padding: 20px` → 실제 차지 너비 **340px** (계산이 어긋남)
- `border-box`: `width: 300px`이면 padding과 border를 **포함해서** 300px

레이아웃 계산이 직관적이 되므로 거의 모든 프로젝트에서 첫 줄에 선언합니다.

### 4.3 Flexbox — 1차원 레이아웃

**한 방향(가로 또는 세로) 한 줄**에 아이템을 배치하고, 남는 공간을 분배하는 도구입니다.

```css
.nav {
  display: flex;
  justify-content: space-between; /* 주축(가로) 정렬: 양 끝으로 */
  align-items: center;            /* 교차축(세로) 정렬: 가운데 */
  gap: var(--space-md);
}
```

**핵심 개념: 주축(main axis)과 교차축(cross axis)**

- `flex-direction: row`(기본) → 주축 = 가로, 교차축 = 세로
- `flex-direction: column` → 주축 = 세로, 교차축 = 가로
- `justify-content`는 **항상 주축**, `align-items`는 **항상 교차축**을 다룹니다.
  → `direction`을 바꾸면 두 속성의 의미가 90도 회전합니다. 이걸 모르면 "왜 안 되지"가 반복됩니다.

**자주 쓰는 속성**

| 속성 | 대상 | 의미 |
|---|---|---|
| `justify-content` | 컨테이너 | 주축 정렬 (`flex-start` / `center` / `space-between` / `space-around`) |
| `align-items` | 컨테이너 | 교차축 정렬 (`stretch`(기본) / `center` / `flex-start`) |
| `gap` | 컨테이너 | 아이템 사이 간격 (margin 해킹 불필요) |
| `flex-wrap` | 컨테이너 | 넘칠 때 줄바꿈 허용 |
| `flex: 1` | 아이템 | 남는 공간을 이 아이템이 차지 |

미션에서 네비게이션에 Flexbox를 지정한 이유: **로고(왼쪽)와 메뉴(오른쪽)라는 한 줄 배치**이기 때문입니다.

### 4.4 Grid — 2차원 레이아웃

**행과 열을 동시에** 정의하는 도구입니다.

```css
.projects-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: var(--space-lg);
}
```

이 한 줄이 미션 요구사항의 핵심이므로 분해해서 봅니다.

| 조각 | 의미 |
|---|---|
| `repeat(...)` | 같은 패턴 반복 |
| `auto-fit` | 개수를 고정하지 않고 **컨테이너 너비에 맞춰 알아서** 열 개수를 정함 |
| `minmax(280px, 1fr)` | 각 열은 **최소 280px**, 최대는 **남는 공간의 균등 분배(1fr)** |
| `1fr` | fraction(비율) 단위. 남는 공간을 1:1:1로 나눔 |

**결과**: 화면이 1200px면 4열, 800px면 2열, 360px면 1열로 **미디어 쿼리 없이 자동 대응**합니다. 이것이 "auto-fit + minmax로 반응형"의 의미입니다.

> `auto-fit` vs `auto-fill`: 아이템이 적어 빈 트랙이 생길 때, `auto-fit`은 빈 트랙을 접어서 남은 아이템을 늘리고, `auto-fill`은 빈 트랙을 유지합니다. 카드 목록에서는 보통 `auto-fit`이 자연스럽습니다.

### 4.5 Flexbox vs Grid — 선택 기준

이 미션의 과제 목표에 명시적으로 포함된 질문입니다.

| 기준 | Flexbox | Grid |
|---|---|---|
| **차원** | 1차원 (한 줄) | 2차원 (행 + 열) |
| **주도권** | **콘텐츠 주도** — 아이템 크기가 배치를 결정 | **레이아웃 주도** — 정해둔 격자에 아이템이 들어감 |
| **적합한 경우** | 네비게이션 바, 버튼 그룹, 카드 내부의 아이콘+텍스트, 정렬 | 카드 갤러리, 대시보드, 페이지 전체 골격 |
| **줄바꿈 시** | 각 줄의 아이템 크기가 제각각이 될 수 있음 | 열 너비가 모든 행에서 일정하게 정렬됨 |

**한 문장 판단법**
- "이것들을 한 줄에 늘어놓고 정렬하고 싶다" → **Flexbox**
- "칸을 미리 만들어두고 그 안에 채우고 싶다" → **Grid**

**중첩해서 쓰는 게 정상입니다.** 이 미션에서도:
```
Projects 섹션 (Grid) → 카드 배치
  └ 카드 하나 (Flex, column) → 제목 / 설명 / 하단 메타정보 세로 배치
      └ 메타정보 줄 (Flex, row) → 언어 · 별 개수 가로 배치
```

실무에서는 "gird로 레이아웃 셀을 지정하고 셀 안을 flexbox로 채운다."  
- 요소들을 페이지 어디에 얼마나 놓을 것인가 -> **Grid**
- 그 요소들의 자식 box- item을 어떻게 늘어놓을 것인가 -> **Flexbox**

사실 gird로 안쪽도 만들어도 되긴 하는데,,, gird(바깥) - gird(안) 겹치면 중첩문제 발생,,, subgrid 사용해야  +  유지보수 문제가 들어간다고..

### 4.6 반응형 디자인과 모바일 퍼스트

**미디어 쿼리(Media Query)**: 화면 조건에 따라 CSS 규칙을 다르게 적용하는 문법.

```css
/* 1) 기본 = 모바일 스타일 (미디어 쿼리 밖) */
.nav-menu {
  display: none;              /* 모바일에선 숨김 */
}
.hamburger { display: block; }

/* 2) 태블릿 이상 */
@media (min-width: 768px) {
  .container { padding: 0 2rem; }
}

/* 3) 데스크톱 이상 */
@media (min-width: 1024px) {
  .nav-menu { display: flex; }  /* 메뉴 노출 */
  .hamburger { display: none; } /* 햄버거 숨김 */
}
```

**모바일 퍼스트(Mobile First)란**
기본 스타일을 **가장 작은 화면 기준**으로 작성하고, `min-width` 미디어 쿼리로 **위로 확장**해 나가는 방식입니다.

반대는 데스크톱 퍼스트(`max-width`로 아래로 축소). 모바일 퍼스트를 권장하는 이유:

1. **트래픽 현실** — 대부분의 방문이 모바일. 기본 스타일이 곧 다수 사용자의 경험
2. **제약이 설계를 단순하게 만든다** — 좁은 화면에서 살아남는 요소만 남기면 콘텐츠 우선순위가 정리됨
3. **CSS가 덜 지저분해진다** — 확장은 속성 추가, 축소는 앞서 준 스타일의 취소(`override`)라서 코드가 누적됨

**뷰포트 메타 태그를 빼먹으면 반응형은 동작하지 않습니다.**

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```
이게 없으면 모바일 브라우저가 980px짜리 데스크톱 화면을 축소해서 보여줍니다. 미디어 쿼리는 트리거되지 않습니다.

### 4.7 전환(transition)과 부드러운 스크롤

```css
.card {
  box-shadow: 0 1px 3px rgba(0,0,0,.1);
  transition: transform .25s ease, box-shadow .25s ease;
}
.card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 24px rgba(0,0,0,.15);
}
```

`transition`은 **속성 값이 바뀔 때 그 변화를 시간에 걸쳐 보간**합니다. `transition`이 없으면 hover 시 즉시 점프하고, 있으면 0.25초 동안 자연스럽게 움직입니다.

- 문법: `transition: <속성> <시간> <가속곡선> <지연>`
- 성능상 `transform`과 `opacity`를 애니메이션하는 것이 가장 좋습니다. 이 둘은 레이아웃 재계산 없이 합성(compositing) 단계에서 처리되기 때문입니다. `width`, `top`, `margin` 애니메이션은 매 프레임 레이아웃을 다시 계산해 버벅일 수 있습니다.

**부드러운 스크롤** — 두 가지 방법이 있습니다.

```css
/* 방법 A: CSS 한 줄 */
html { scroll-behavior: smooth; }
```

```js
/* 방법 B: JS로 제어 (오프셋 조정 등 세밀한 제어 가능) */
target.scrollIntoView({ behavior: 'smooth', block: 'start' });
```

고정 헤더가 있으면 섹션 제목이 헤더에 가려집니다. 해결책:
```css
section { scroll-margin-top: 70px; } /* 헤더 높이만큼 여유 */
```

### 4.8 선택자 우선순위(Specificity)

"CSS를 썼는데 안 먹는다"의 대부분은 우선순위 문제입니다.

높은 순서대로: `!important` > 인라인 스타일(`style="..."`) > `#id` > `.class` / `[속성]` / `:hover` > `태그` > `*`

같은 우선순위면 **나중에 쓴 것**이 이깁니다. `!important`는 디버깅을 어렵게 만들므로 최후의 수단으로만 씁니다. 이 미션에서 `[data-theme="dark"]`가 `:root`를 이기는 것도 이 규칙(속성 선택자 > 요소 선택자) 덕분입니다.

---

## 5. JavaScript — 동작

### 5.1 `defer`와 스크립트 로딩

```html
<script src="js/main.js" defer></script>
```

| 방식 | 동작 | 문제/장점 |
|---|---|---|
| `<script>` (head, 속성 없음) | HTML 파싱을 **멈추고** 즉시 다운로드+실행 | DOM이 아직 없어서 `querySelector`가 `null` 반환 |
| `<script defer>` | 다운로드는 병렬, 실행은 **HTML 파싱 완료 후** | DOM 접근 보장 + 파싱 차단 없음 ✅ |
| `<script async>` | 다운로드 병렬, 도착 즉시 실행 (순서 보장 X) | 독립적인 분석 스크립트 등에 적합 |
| `</body>` 직전 배치 | 파싱 후 실행 | `defer`와 유사하나 다운로드가 늦게 시작 |

`defer`를 쓰면 `DOMContentLoaded` 이벤트로 감쌀 필요 없이 바로 DOM을 조작할 수 있습니다. 여러 `defer` 스크립트는 **작성 순서대로** 실행됩니다.

### 5.2 `var` 대신 `const` / `let`

| 키워드 | 스코프 | 재할당 | 호이스팅 시 |
|---|---|---|---|
| `var` | **함수** 스코프 | 가능 | `undefined`로 초기화됨 (버그 유발) |
| `let` | **블록** 스코프 `{}` | 가능 | TDZ — 선언 전 접근 시 에러 |
| `const` | **블록** 스코프 | 불가 | TDZ |

```js
// var의 문제: 블록을 무시함
for (var i = 0; i < 3; i++) { /* ... */ }
console.log(i); // 3  ← 반복문 밖에서도 살아있음

for (let j = 0; j < 3; j++) { /* ... */ }
console.log(j); // ReferenceError ← 올바른 동작
```

**규칙**: 기본은 `const`, 재할당이 필요할 때만 `let`, `var`는 쓰지 않습니다.

> `const`는 "값이 불변"이 아니라 **"바인딩(변수 이름 ↔ 값의 연결)이 불변"** 입니다.
> `const arr = []; arr.push(1);` → 정상 동작. `arr = []` → 에러.

- 바인딩 : 값을 넣는 것! ```let age = 25 ```
  1. 메모리에 값을 담을 상자가 생긴다
  2. 상자에 age라는 이름표가 붙는다.
  3. 상자 안에 25가 들어간다

- const & let : 최신 버전의 바인딩 키워드(선언) / var : js 초창기의 바인딩 키워드
- const : 바인딩 된 값 수정 불가능 ```const age= 25``` 하면 age = 25는 불변
- let , var : 바인딩 된 값 수정 가능 ```let age = 30``` 으로 재선언 하면 age = 30 으로 바뀜
- const & let : 해당 블록에서만 유효함!! but

- var는 python에서 global로 정의하는 것처럼 전체에서 유효함!!!! 코드가 길어지면 충돌이 날 수 있음으로 var를 안 쓰는 것! 
Q 그럼 왜 쓰냐? -- 옛날에 만든 코드들이 유효해야 하기 때문에 유지하는 것! 최근에는 사용하지 않음!! 


### 5.3 DOM (Document Object Model)

**DOM이란**: 브라우저가 HTML 문서를 파싱해서 만든 **객체 트리**입니다. HTML 텍스트 자체가 아니라, JavaScript가 조작할 수 있도록 메모리에 올려둔 구조체입니다.

```
document
 └ html
    ├ head
    └ body
       ├ header > nav > ul > li > a
       └ main > section#about > h2
```

**요소 선택**

```js
const nav = document.querySelector('.nav');            // 조건에 맞는 첫 번째 요소 (없으면 null)
const links = document.querySelectorAll('.nav-link');  // 전부 (NodeList, 없으면 빈 리스트)
```

- 인자는 **CSS 선택자 문자열** 그대로 씁니다 → CSS 지식이 그대로 재사용됨
- `querySelectorAll`이 반환하는 `NodeList`는 배열이 아니라 **유사 배열**입니다. `forEach`는 되지만 `map`, `filter`는 안 됩니다.
  → 배열 메서드가 필요하면 `[...document.querySelectorAll('.x')]` 또는 `Array.from(...)`으로 변환합니다.

**내용 변경**

```js
el.textContent = '안녕하세요';   // 텍스트로 취급. 태그도 글자로 표시됨. 안전 ✅
el.innerHTML = '<strong>안녕</strong>'; // HTML로 파싱해서 삽입
```

**`textContent` vs `innerHTML` — 보안 관점**
사용자 입력이나 외부 API 응답을 `innerHTML`로 넣으면 **XSS(Cross-Site Scripting)** 취약점이 생깁니다. 저장소 설명(`description`)에 `<img src=x onerror="...">` 같은 문자열이 들어있으면 그대로 실행됩니다.

- 단순 텍스트 → **`textContent`**
- HTML 구조 생성 필요 → `innerHTML`을 쓰되, 삽입 전 이스케이프 처리:

```js
const escapeHtml = (str = '') =>
  str.replace(/[&<>"']/g, (c) => (
    { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]
  ));
```
**정리
dom은 노드형태임!

textContent & innerHTML 모두 변경점을 가지고 있는 노드를 없애고 새로 만드는 방법임!!

ex) a노드 이하를 모두 지워라
- 둘의 차이는 이전 노드를 지우고 없앤 후 파싱을 하냐, 마냐의 차이 
- textContent = 문자열 취급! 그냥 노드만 바꾸고 끝
- innerHTML = 마크업 문법 취급! 파싱해서 읽어줘야 함!!

-----

**클래스 조작**

```js
el.classList.add('active');
el.classList.remove('active');
el.classList.toggle('active');            // 있으면 제거, 없으면 추가
el.classList.toggle('active', isOpen);    // 두 번째 인자로 강제 지정
el.classList.contains('active');          // boolean
```
- add : 말 그대로 그냥 추가. 이미 값이 있으면 조용히 넘어감
- remove : 마찬기자로 그냥 삭제. 없는 걸 지우라해도 조용히 넘어감
- toggle : 있으면 빼고 없으면 넣음. 값을 boolean으로 반환 => 없어서 추가했으면 true , 있어서 제거했으면 false  + 두 번재 인자 주면 강제 => isOpen = true면 add / isOpen = false면 remove

**중요한 사고방식**: JS는 클래스만 붙였다 뗍니다. **"어떻게 보일지"는 전적으로 CSS의 책임**입니다.

```css
.nav-menu { transform: translateX(100%); transition: transform .3s; }
.nav-menu.active { transform: translateX(0); }
```
```js
navMenu.classList.toggle('active');  // JS는 이 한 줄뿐
```

이렇게 **관심사를 분리**하면 애니메이션을 바꾸고 싶을 때 CSS만 고치면 됩니다. `el.style.transform = '...'` 처럼 JS에서 스타일을 직접 쓰기 시작하면 스타일 로직이 두 파일에 흩어집니다.

### 5.4 이벤트 (Event)

**이벤트란**: 브라우저에서 일어나는 사건(클릭, 입력, 스크롤, 폼 제출, 로드…). JS는 이 사건에 **콜백 함수를 등록**해두고 기다립니다.

```js
button.addEventListener('click', (event) => {
  console.log('클릭됨', event.target);
});
```

**왜 `onclick` 속성 대신 `addEventListener`인가** (미션 요구사항)

```html
<!-- 금지 -->
<button onclick="toggleTheme()">테마</button>
```

| 이유 | 설명 |
|---|---|
| **관심사 분리** | 동작 로직이 HTML에 섞이면 구조와 동작이 뒤엉킴 |
| **핸들러 여러 개** | `onclick`은 하나만 가능(덮어씀). `addEventListener`는 무제한 |
| **전역 오염** | `onclick="fn()"`의 `fn`은 전역 함수여야 함 |
| **제거 가능** | `removeEventListener`로 해제 가능 |
| **옵션 지원** | `{ once: true }`, `{ passive: true }` 등 세밀한 제어 |

- onclick , addeventlistner (함수를 추가) VS add (문자열)
- onclick (한 개의 슬롯, 덮어쓰기) : x=1 , x=2 하면 x=2 되는 것처럼
- addevenlistner (배열형식, 새로 추가) : x=1, x=2 하면 x=1,2 이런 느낌


**이 미션에서 다루는 이벤트**

| 이벤트 | 발생 시점 | 이 미션에서의 용도 |
|---|---|---|
| `click` | 클릭 | 햄버거, 테마 토글, 스크롤탑, 재시도, 필터 |
| `submit` | 폼 제출 | Contact 폼 유효성 검사 |
| `scroll` | 스크롤 | 네비 배경 변경, 스크롤탑 버튼 표시 |
| `input` | 입력값이 바뀔 때마다 | 실시간 유효성 검사 |
| `change` | 값 확정 시(포커스 아웃 등) | 셀렉트 박스 등 |

**이벤트 객체와 `preventDefault()`**

핸들러의 첫 번째 인자로 **이벤트 객체**가 들어옵니다.

```js
form.addEventListener('submit', (event) => {
  event.preventDefault();  // 브라우저 기본 동작(페이지 새로고침/전송) 차단
  // 이제 JS로 직접 처리
});
```

`preventDefault()`가 없으면 폼 제출 시 페이지가 새로고침되어 JS로 만든 화면 상태가 전부 초기화됩니다. 앵커 링크(`<a href="#about">`)에서도 JS로 스크롤을 직접 제어하려면 기본 점프를 막아야 합니다.

1. 제출 클릭 → submit 이벤트 발생
2. 내 리스너가 값을 검사하고, 마음에 안 들면 빨간 글씨를 DOM에 넣음
   (브라우저는 이 판단을 전혀 모름)
3. preventDefault()로 "기본 제출 하지 마"라고 표시
4. 브라우저가 그 표시를 보고 요청을 안 보냄
5. Document가 그대로 유지되므로 빨간 글씨도 화면에 남음

``` 내비게이션에서 발생하는 오류를 막아줄 때 사용! 
원래 내비게이션: 새로운 페이지로 이동 -> 새로운 페이지 정상 작동 확인 -> 이전 페이지 삭제

비정상 내비게이션(잘못된 값 입력했을 때): 새로운 페이지로 이동 -> 새로운 페이지 비정상 작동 확인 -> 이전 페이지로 강제 이동
[ 사용자는 잘못된 값을 잃어버리게 됨!! ex 내가 뭘 잘 못 입력했는데 돌아왔지? 뭘 입력했었지??]

때문에! 잘못된 값을 보여주기 위해서 preventDefault()가 있는 것! 
"야야 새로윤 페이지 비정상이다! 내비게이션으로 가지 말고 현재 잘못된 값이 있는 페이지를 유지해!" 
```

**이벤트 버블링과 위임(Delegation)**

이벤트는 발생한 요소에서 시작해 조상 방향으로 **거슬러 올라갑니다(버블링)**. 이를 이용하면 자식이 몇 개든 부모에 핸들러 하나만 달면 됩니다.

```js
// 카드가 API로 나중에 생성되어도 동작함
projectsGrid.addEventListener('click', (event) => {
  const card = event.target.closest('.project-card');
  if (!card) return;
  console.log(card.dataset.repoName);
});
```

동적으로 생성되는 요소(GitHub 카드, 필터 버튼)에 이벤트를 붙일 때 **렌더링 후 매번 다시 붙이는 것보다 위임이 안전**합니다. 렌더 함수가 `innerHTML`로 내용을 갈아엎으면 기존 요소에 붙였던 리스너는 함께 사라지기 때문입니다.

**`event.target` vs `event.currentTarget`**
- `target`: 실제로 이벤트가 시작된 요소 (클릭한 그 지점)
- `currentTarget`: 지금 핸들러가 붙어 있는 요소

### 5.5 ES6+ 문법
javascrpit의 문법 6번째 개정판!
**① 화살표 함수 (Arrow Function)**

```js
// 기존
function add(a, b) { return a + b; }
// 화살표 — 표현식 하나면 return 생략
const add = (a, b) => a + b;
// 객체를 반환할 땐 괄호로 감싸야 함 (블록으로 오인 방지)
const makeUser = (name) => ({ name, active: true });
```

단순히 짧아서 쓰는 게 아닙니다. 결정적 차이는 **`this` 바인딩**입니다.

- 일반 함수: 호출 방식에 따라 `this`가 동적으로 결정됨
- 화살표 함수: `this`를 **자신을 감싼 바깥 스코프에서 그대로 가져옴(렉시컬 바인딩)**

콜백 안에서 `this`가 예상과 달라지는 고전적 버그가 사라집니다. 그래서 콜백/이벤트 핸들러에 잘 맞습니다.
(단, `this`가 이벤트 대상 요소를 가리켜야 하는 경우엔 일반 함수를 써야 합니다. 화살표 함수 안에서 `this`는 요소가 아닙니다.)

``` 화살표 함수를 쓰는 이유는 this(객체)를 강제하기 위해서!! 
this를 쓰면 부른 방식만 따라감! ex) 메뉴 = {버튼.열림} 이렇게 해놓고 this를 하면 "메뉴 {버튼.열림}" 가 아니라 그냥 "버튼.열림"만 가져온다는 것..?

결과적으로 브라우저가 js엔진에 함수를 넣을 때 this 가 currentTarget으로 정의되어 있어서,, 내가 의미한 this가 콜백되지 않을 수 있다는 것!!
python에서 a=5 라고 정의한 후 관련 class를 호출했는데 내가 다른 class에서 입력한 a=4가 튀어나오는 것과 비슷하다고 볼 수 있지! 
때문에 => 화살표 함수로 '내가 가져올 a=5야' 라고 강제하는 것
```

**② 템플릿 리터럴 (Template Literal)**

백틱(`` ` ``)으로 감싸고 `${}`로 값을 끼워 넣습니다.

```js
// 기존 — 따옴표와 + 의 지옥
var html = '<article class="card">' + '<h3>' + repo.name + '</h3>' + '</article>';

// 템플릿 리터럴 — 줄바꿈 그대로 유지, 구조가 눈에 보임
const html = `
  <article class="project-card">
    <h3 class="project-title">${escapeHtml(repo.name)}</h3>
    <p class="project-desc">${escapeHtml(repo.description ?? '설명이 없습니다.')}</p>
    <div class="project-meta">
      <span>${repo.language ?? 'Unknown'}</span>
      <span>⭐ ${repo.stargazers_count}</span>
    </div>
  </article>
`;
```

이게 사실상 **JSX의 원형**입니다. "데이터를 넣어 마크업 문자열을 만든다"는 발상이 동일합니다.

- 즉, 우리가 쓰는 html문자열임!! 
사실 html을 작성하는 방법은 여러가지임, 그 중에서 가장 범용적이고 간편한 탬플릿 리터럴을 사용하는 것


**③ 구조 분해 할당 (Destructuring)**

```js
// 객체 구조 분해 — 이름을 바꾸고 기본값도 줄 수 있음
const { name, description = '설명 없음', html_url: url, stargazers_count: stars } = repo;

// 배열 구조 분해
const [first, second] = repos;

// 함수 매개변수에서 바로 분해 — 실무에서 가장 많이 쓰는 형태
const renderCard = ({ name, description, html_url, language }) => `...`;
```

`repo.name`, `repo.description`... 을 반복하지 않아 코드가 짧아지고, **이 함수가 객체의 어떤 필드에 의존하는지 시그니처만 봐도 드러납니다.**

**④ 스프레드 / 나머지**

```js
const copy = [...repos];                    // 얕은 복사
const merged = { ...defaults, ...userOpts }; // 객체 병합 (뒤가 우선)
const nodes = [...document.querySelectorAll('.card')]; // NodeList → 배열
```

**⑤ 배열 메서드 — `map` / `filter` / `forEach`**

이 셋의 구분이 미션 목표에 포함되어 있습니다.

| 메서드 | 반환값 | 용도 | 원본 |
|---|---|---|---|
| `map` | **새 배열** (길이 동일) | **변환** — 데이터 → HTML 문자열 | 변경 안 함 |
| `filter` | **새 배열** (길이 ≤ 원본) | **선별** — 조건 통과한 것만 | 변경 안 함 |
| `forEach` | `undefined` | **순회하며 부수효과** — 이벤트 등록 등 | 변경 안 함 |

- map = 원소 개수는 그대로 대신 형태를 다르게 할 때
- filter = 원소 개수는 다르게 대신 형태는 똑같이 할 때
- forEach = 반환할 필요가 없을 때.. for처럼 반복 시 사용

- ex) 검색 후 결과 보여주기 = filter로 검색 결과에 맞는 원소들만 반환 , map으로 페이지에 보여줘야 할 원소들을 html 문자열로 변경 // 디버깅용으로 배열 내용 확인 = forEach로 반복

```js
// filter: 포크한 저장소 제외
const myRepos = repos.filter((repo) => !repo.fork);

// map + join: 배열 → HTML 문자열
const cardsHtml = myRepos.map(renderCard).join('');
grid.innerHTML = cardsHtml;

// forEach: 각 링크에 이벤트 연결 (반환값이 필요 없는 작업)
navLinks.forEach((link) => link.addEventListener('click', handleNavClick));

// 체이닝
const html = repos
  .filter((r) => !r.fork)
  .sort((a, b) => b.stargazers_count - a.stargazers_count)
  .slice(0, 6)
  .map(renderCard)
  .join('');
```

> `map()`은 배열을 반환하므로 `.join('')`으로 이어붙여야 합니다. 빼먹으면 요소 사이에 쉼표(`,`)가 찍혀 나옵니다. — 아주 흔한 실수입니다.

**왜 `for` 루프 대신 이걸 쓰는가**
`for` 루프는 "어떻게 반복하는지"(인덱스 증가, 종료 조건)를 매번 서술합니다(명령형). `map`/`filter`는 "무엇을 하려는지"를 이름으로 선언합니다(선언형). 코드를 읽는 사람이 의도를 즉시 파악할 수 있고, 원본을 변경하지 않아 부작용이 적습니다.

**⑥ 옵셔널 체이닝 / null 병합**

```js
repo.owner?.login          // owner가 없으면 에러 대신 undefined
repo.description ?? '설명 없음'  // null 또는 undefined일 때만 대체
repo.description || '설명 없음'  // '' , 0, false 도 대체 (주의)
```

API 응답에는 `null` 필드가 자주 있습니다(`description`, `language`). `??`를 쓰면 방어 코드가 짧아집니다.

---

## 6. 비동기와 API 연동

### 6.1 왜 비동기인가

JavaScript는 **싱글 스레드**입니다. 한 번에 한 가지 일만 합니다. 네트워크 요청(수백 ms ~ 수 초)을 기다리는 동안 멈춰버리면 그 시간 내내 화면이 얼어붙습니다(스크롤도, 클릭도 안 됨).

그래서 브라우저는 **"요청만 걸어두고 다음 코드로 넘어간 뒤, 응답이 오면 그때 콜백을 실행"** 하는 방식을 씁니다. 이것이 비동기입니다.

``` 비동기 vs lazy deletion
- lazy deletion: 그냥 작업을 미룸!! 요청이 오기 전까지 안 하고 뻐팅기는 것 
ex) 개인 과제 하다가 팀플 카톡 보고 팀플 과제 시작

- 비동기 : 빠른 연산에 비해 I/O 느릴 때 사용하는 것! 
js는 단일 스레드라서 I/O에 한계가 있음!! 오래 걸리는 연산을 바로 I/O까지 가면 js는 다른 활동을 못함

1) 어려운 연산은 js 스레드 밖에서 처리
2) 연산 끝나면 js 큐에 콜백을 넣어둠
3) js 스레드가 이전 일 끝나고 큐에 있는 콜백을 실행시키면 결과를 가져오는 것
< 밖에서 미리 끝내놓고 나를 봐줄때까지 기다리는 것>
ex) 집에서 숙제하고 선생님이 내 숙제 채점할 때까지 기다리는 것
```

### 6.2 Promise

**Promise**: "지금은 없지만 나중에 값이 생길 것"을 나타내는 객체. 세 가지 상태를 가집니다.

- `pending` (대기) → `fulfilled` (성공, 값 있음) 또는 `rejected` (실패, 에러 있음)
- 한 번 결정되면 바뀌지 않습니다.

```js
fetch(url)
  .then((res) => res.json())
  .then((data) => render(data))
  .catch((err) => showError(err));
```

``` promise는 fetch()를 통해 비동기로 계산될 함수값들이 들어올 상자임!!

- promise를 1번 사용
1. fetch() 통해서 비동기

2. promise객체 생성 - Pending 상태

3. 외부에서 함수 계산 끝

4. promise에 함수값 - Fulfilled 상태

5. 콜백을 큐에 넣음

6. 큐 순서가 되면 콜백값을 promise에서 꺼냄

- promise를 2번 사용 (체이닝 .then())
<외부에서 데이터를 받아와서 비동기로 함수값을 구해야할 때 -- 값 정제해서 구하는 느낌>
1. fetch() 호출: Promise #1 생성 (Pending).
  첫 번째 .then() 호출:
  새로운 Promise #2 생성 (Pending).
  첫 번째 콜백이 Promise #1에 등록됩니다.

2. 두 번째 .then() 호출:
  새로운 Promise #3 생성 (Pending).
  두 번째 콜백이 Promise #2에 등록됩니다.

3. 동기 코드 완료 후 네트워크 응답 도착:
  Promise #1 상태가 Fulfilled로 바뀜 (Response 저장).
  첫 번째 콜백이 Microtask Queue로 들어갑니다.

4.첫 번째 콜백 실행:
  이벤트 루프에 의해 첫 번째 콜백이 실행되어 response.json()을 리턴합니다.
  response.json() 역시 비동기 작업이므로, 이 작업이 완료되면 Promise #2가 Fulfilled로 바뀌고 파싱된 JSON 데이터가 담깁니다.

5. 두 번째 콜백으로 연쇄 전달:
  Promise #2가 완료되었으므로, 두 번째 콜백이 Microtask Queue로 들어갑니다.
  두 번째 콜백이 실행되면서 Promise #2의 데이터(JSON)를 인자로 받아서 화면 업데이트(DOM 조작) 등을 수행하고 Promise #3이 Fulfilled가 됩니다.
```

### 6.3 async / await

`async/await`는 Promise를 **동기 코드처럼 위에서 아래로 읽히게** 만드는 문법 설탕입니다.

```js
const fetchRepos = async (username) => {
  const res = await fetch(`https://api.github.com/users/${username}/repos`);
  if (!res.ok) throw new Error(`GitHub API 오류: ${res.status}`);
  const data = await res.json();
  return data;
};
```

- `async` 함수는 **항상 Promise를 반환**합니다.
- `await`는 Promise가 결정될 때까지 **그 함수 안에서만** 기다립니다. 나머지 페이지는 멈추지 않습니다.
- `await`는 `async` 함수 안에서만 쓸 수 있습니다(모듈 최상위 예외).

사실상 promise를 편하게 쓰기 위해 존재하는 syntatic sugar(문법 설탕)!! 
정작 promise는 async/await 없어도 정상 작동은 한다고

### 6.4 `fetch`의 함정 — `res.ok` 확인

**가장 흔한 실수**: `fetch`는 404, 500 같은 HTTP 에러 응답에서 **reject 하지 않습니다.** 네트워크 자체가 실패해야(오프라인, CORS 차단, DNS 실패) reject 합니다.

- 404: 요청은 잘 했는데 받고 보니 리소스가 없다
- 500: 서버 내부에서 처리 과정에 boom... 클라이언트가 할 수 있는 게 없다.

```js
// 잘못됨 — 404가 와도 catch로 안 감. res.json()이 에러 객체를 파싱해서 이상한 화면이 나옴
const res = await fetch(url);
const data = await res.json();


// 올바름
const res = await fetch(url);
if (!res.ok) {
  throw new Error(`요청 실패 (${res.status})`);
}
const data = await res.json();
```

`res.ok`는 상태 코드가 200~299일 때 `true`입니다.

- fetch()는 비동기를 시작하는 함수! 브라우저가 꼽아놓은 webAPI
- 404, 500 같은 오류 수신도 '수신받았다' 라고 판단!! promise에게 '응답 성공'을 반환!

### 6.5 try / catch / finally

```js
const loadProjects = async () => {
  setState('loading');                     // ① 로딩 상태
  try {
    const repos = await fetchRepos(USERNAME);
    const visible = repos.filter((r) => !r.fork);
    if (visible.length === 0) {
      setState('empty');                   // ② 빈 상태
      return;
    }
    setState('success', visible);          // ③ 성공 상태
  } catch (error) {
    console.error(error);
    setState('error', error.message);      // ④ 에러 상태
  }
};
```

- `try`: 에러가 날 수 있는 코드
- `catch(error)`: `try` 안에서 던져진 에러를 잡음. **여기서 사용자에게 보여줄 화면을 결정**
- `finally`: 성공/실패와 무관하게 실행 (로딩 스피너 정리 등)

``` python에서의 try - except 와 비슷하다고 생각하면 됨

try로 에러가 날 수 있는 코드로 진입
js엔진이 연산 시 에러를 발견 throw로 가장 가까운 catch에 에러 객체 전달 (catch를 못 만나면 UncaughtError로 콘솔에)
catch가 자신의 코드에 맞춰서 사용자에게 에러를 어떻게 보여줄 것인지 계산
finally는 끝날 때 지나는 검문소
정상적으로 finally를 지나면 try 다음 줄 실행
```



### 6.6 네 가지 UI 상태 — 왜 이게 요구사항인가

초보 코드는 보통 **성공 케이스만** 그립니다. 하지만 실제 서비스에서 사용자가 마주치는 상황은 넷입니다.

| 상태 | 언제 | 보여줘야 할 것 | 없으면 사용자가 겪는 일 |
|---|---|---|---|
| **loading** | 요청 중 | 스피너 / "불러오는 중..." | 빈 화면. "고장났나?" |
| **success** | 데이터 있음 | 카드 목록 | — |
| **empty** | 요청 성공, 데이터 0개 | "표시할 프로젝트가 없습니다" | 빈 화면. 로딩 실패와 구분 불가 |
| **error** | 요청 실패 | 메시지 + **재시도 버튼** | 빈 화면. 복구 방법 없음 |

**`empty`와 `error`를 구분하는 게 핵심입니다.** 둘 다 "아무것도 안 보인다"지만 원인과 사용자의 다음 행동이 완전히 다릅니다. error에는 **재시도 버튼**이 필요하고, empty에는 필요 없습니다.

이 네 상태를 하나의 변수로 관리하는 것이 7장의 상태 관리로 이어집니다.

### 6.7 GitHub API 실무 노트

```
GET https://api.github.com/users/{username}/repos
```

- **인증 없이 호출 가능**하며, IP당 **시간당 60회**로 제한됩니다. 개발 중 새로고침을 반복하면 걸릴 수 있습니다(403 응답 + `X-RateLimit-Remaining: 0`).
  - 이 미션은 레이트 리밋을 **버그가 아니라 반드시 겪게 되는 정상 케이스**로 취급합니다. `res.ok`가 `false`인 모든 경우(404, 403, 500 등)를 6.6절의 **error 상태**로 통일해서 처리하면, 레이트 리밋에 걸려도 자동으로 "프로젝트를 불러올 수 없습니다 + 다시 시도" 화면이 뜹니다. 상태 코드별로 분기 처리를 따로 만들 필요가 없다는 뜻입니다.
  - 개발 중에는 새로고침을 남발하지 말고, `fetchRepos()` 호출부에 임시로 `console.log`를 찍어 요청 횟수를 눈으로 확인하거나, 응답 헤더 `X-RateLimit-Remaining`을 콘솔에서 확인하며 작업하는 것이 안전합니다.
- 유용한 쿼리 파라미터: `?sort=updated&per_page=6` (최근 수정순 6개)
- **토큰을 프론트엔드 코드에 넣지 마세요.** 클라이언트 JS는 누구나 볼 수 있습니다. GitHub이 감지하면 토큰을 자동 폐기합니다. 공개 저장소 조회는 인증이 필요 없습니다.
- 응답에서 쓸 만한 필드: `name`, `description`, `html_url`, `language`, `stargazers_count`, `forks_count`, `topics`, `updated_at`, `fork`(포크 여부)

---

## 7. 상태 관리 패턴 — 이 미션의 진짜 핵심

### 7.1 "상태"란 무엇인가

**상태(state) = 시간에 따라 변하고, 변하면 화면이 달라져야 하는 데이터.**

이 미션에서의 상태 목록:

```js
const state = {
  theme: 'light',        // 'light' | 'dark'
  isMenuOpen: false,     // boolean
  projectsStatus: 'idle',// 'idle' | 'loading' | 'success' | 'error' | 'empty'
  repos: [],             // 저장소 배열
  activeLanguage: 'All', // 필터 상태 (보너스)
  formErrors: {},        // { name?: string, email?: string, message?: string }
};
```

**상태가 아닌 것**: 로고 이미지 경로, 섹션 제목 문구 — 변하지 않으므로 HTML에 그냥 두면 됩니다.

### 7.2 안티패턴: DOM을 상태 저장소로 쓰기

```js
// ❌ 나쁜 방식 — 현재 상태를 DOM에서 "읽어옴"
if (navMenu.classList.contains('active')) {
  navMenu.classList.remove('active');
} else {
  navMenu.classList.add('active');
}
```

동작은 합니다. 하지만 상태가 화면에 흩어져 있습니다. 조건이 늘어나면(메뉴 열림 + 다크모드 + 스크롤됨) 각 정보를 DOM 여기저기서 긁어모아야 하고, 어긋나기 시작합니다.

```js
// ✅ 좋은 방식 — 상태는 JS 변수 하나, DOM은 그 결과물
let isMenuOpen = false;

const renderMenu = () => {
  navMenu.classList.toggle('active', isMenuOpen);
  hamburger.classList.toggle('active', isMenuOpen);
  hamburger.setAttribute('aria-expanded', String(isMenuOpen));
  document.body.style.overflow = isMenuOpen ? 'hidden' : '';
};

hamburger.addEventListener('click', () => {
  isMenuOpen = !isMenuOpen;  // 상태만 바꾸고
  renderMenu();              // 렌더는 렌더 함수에 위임
});
```

**핵심 원칙**
> **상태는 JS 변수가 단일 진실 공급원(Single Source of Truth)이고, DOM은 그 상태를 비추는 거울일 뿐이다.**

이 원칙 하나가 React 전체의 철학입니다. React에서는 이 `renderMenu()` 호출조차 프레임워크가 자동으로 해줍니다.

### 7.3 세 가지 상태 흐름 (미션 필수 요구사항)

**흐름 ①: 다크 모드**

```
[토글 버튼 click]
  → state.theme = (state.theme === 'light' ? 'dark' : 'light')
  → localStorage.setItem('theme', state.theme)      // 영속화
  → document.documentElement.setAttribute('data-theme', state.theme)  // DOM
  → CSS 변수 재해석 → 전체 화면 색상 변경
```

**흐름 ②: 프로젝트 로딩**

```
[페이지 로드 / 재시도 click]
  → state.status = 'loading'  → render() → 스피너
  → await fetch(...)
  → 성공: state.status='success', state.repos=[...] → render() → 카드 목록
  → 0개:  state.status='empty'                      → render() → 빈 상태 메시지
  → 실패: state.status='error'                      → render() → 에러 + 재시도 버튼
```

렌더 함수는 하나로 통일하는 것이 좋습니다.

```js
const renderProjects = () => {
  const { status, repos, errorMessage } = state;

  if (status === 'loading') {
    grid.innerHTML = `<p class="status status--loading">프로젝트를 불러오는 중...</p>`;
    return;
  }
  if (status === 'error') {
    grid.innerHTML = `
      <div class="status status--error">
        <p>프로젝트를 불러올 수 없습니다.</p>
        <p class="status__detail">${escapeHtml(errorMessage)}</p>
        <button type="button" class="btn" id="retry-btn">다시 시도</button>
      </div>`;
    return;
  }
  if (status === 'empty' || repos.length === 0) {
    grid.innerHTML = `<p class="status status--empty">표시할 프로젝트가 없습니다.</p>`;
    return;
  }
  grid.innerHTML = repos.map(renderCard).join('');
};
```

이 구조가 왜 좋은가: **"지금 화면이 어떤 모습이어야 하는가"가 `state` 값만으로 완전히 결정됩니다.** 화면을 보고 추측할 필요가 없습니다.

**흐름 ③: 폼 유효성 검사**

```
[input 이벤트 / submit 이벤트]
  → 검증 함수 실행 → state.formErrors = { email: '올바른 이메일 형식이 아닙니다' }
  → renderFormErrors() → 해당 필드 아래 <span class="error">에 메시지 표시 + 필드에 error 클래스
  → 에러가 없으면 → 성공 메시지 표시 + 폼 초기화
```

```js
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const validate = ({ name, email, message }) => {
  const errors = {};
  if (!name.trim()) errors.name = '이름을 입력해주세요.';
  if (!email.trim()) errors.email = '이메일을 입력해주세요.';
  else if (!EMAIL_RE.test(email)) errors.email = '올바른 이메일 형식이 아닙니다.';
  if (message.trim().length < 10) errors.message = '메시지는 10자 이상 입력해주세요.';
  return errors;
};

form.addEventListener('submit', (event) => {
  event.preventDefault();
  const formData = new FormData(form);
  const values = Object.fromEntries(formData);   // FormData → 일반 객체
  const errors = validate(values);

  state.formErrors = errors;
  renderFormErrors();

  if (Object.keys(errors).length > 0) return;

  showSuccess('메시지가 전송되었습니다. 감사합니다!');
  form.reset();
});
```

**유효성 검사 UX 팁**
- `submit` 시점에만 검사하면 사용자가 다 채우고 나서야 에러를 봅니다.
- 반대로 `input` 마다 검사하면 첫 글자 입력 즉시 "이메일 형식이 아닙니다"가 떠서 공격적으로 느껴집니다.
- 절충안: **첫 검증은 `blur` 또는 `submit`에서, 한 번 에러가 난 필드는 그 뒤로 `input`마다 재검증**해서 고치는 즉시 에러가 사라지게 합니다.

**HTML 기본 검증과의 관계**
`required`, `type="email"` 속성만으로도 브라우저가 검증해줍니다. 다만 메시지 문구와 위치를 제어할 수 없고 브라우저마다 다릅니다. 그래서 이 미션은 JS 검증을 요구합니다. `<form novalidate>`를 주면 브라우저 기본 툴팁을 끄고 JS 메시지만 보여줄 수 있습니다. 단, HTML 속성은 남겨두는 편이 접근성에 유리합니다.

### 7.4 Intersection Observer — 스크롤 애니메이션

**개념**: 특정 요소가 **뷰포트(또는 지정한 영역)에 들어오거나 나가는 순간**을 브라우저가 알려주는 API입니다.

기존에는 `scroll` 이벤트마다 `getBoundingClientRect()`로 위치를 계산했습니다. 스크롤 이벤트는 초당 수십~수백 번 발생하고, 그때마다 위치를 재계산하면 **강제 리플로우(forced reflow)** 가 일어나 성능이 나빠집니다. Intersection Observer는 이 판정을 브라우저 내부에서 비동기로 처리하므로 훨씬 효율적입니다.

```js
const observer = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add('is-visible');
        observer.unobserve(entry.target);  // 한 번만 실행 (재진입 시 반복 방지)
      }
    });
  },
  {
    threshold: 0.2,          // 요소의 20%가 보이면 콜백 실행
    rootMargin: '0px 0px -50px 0px',  // 뷰포트 경계를 조정 (조금 일찍/늦게 발동)
  }
);

document.querySelectorAll('.reveal').forEach((el) => observer.observe(el));
```

**옵션 설명**

| 옵션 | 의미 |
|---|---|
| `root` | 기준 영역. `null`(기본)이면 뷰포트 |
| `threshold` | 0~1. 대상이 이 비율만큼 보이면 콜백 실행. `0.2` = 20% |
| `rootMargin` | 기준 영역을 확장/축소. 음수면 화면 안쪽으로 당김 |

미션이 `threshold: 0.2` 이상을 권장하는 이유: `0`이면 요소의 1픽셀만 걸쳐도 발동해서, 아직 화면에 거의 안 보이는 상태에서 애니메이션이 끝나버립니다.

**짝이 되는 CSS**

```css
.reveal {
  opacity: 0;
  transform: translateY(24px);
  transition: opacity .6s ease, transform .6s ease;
}
.reveal.is-visible {
  opacity: 1;
  transform: translateY(0);
}

/* 접근성: 모션 민감 사용자 배려 */
@media (prefers-reduced-motion: reduce) {
  .reveal { opacity: 1; transform: none; transition: none; }
}
```

여기서도 **JS는 클래스만 붙이고, 애니메이션은 CSS가 담당**하는 원칙이 유지됩니다.

### 7.5 스크롤 이벤트와 스로틀링

네비 배경 변경과 스크롤탑 버튼은 `scroll` 이벤트를 씁니다.

```js
const SCROLL_NAV_THRESHOLD = 60;   // README에 명시할 기준값
const SCROLL_TOP_THRESHOLD = 300;

let ticking = false;
window.addEventListener('scroll', () => {
  if (ticking) return;
  ticking = true;
  requestAnimationFrame(() => {
    const y = window.scrollY;
    nav.classList.toggle('scrolled', y > SCROLL_NAV_THRESHOLD);
    topBtn.classList.toggle('visible', y > SCROLL_TOP_THRESHOLD);
    ticking = false;
  });
}, { passive: true });
```

- **`requestAnimationFrame`으로 묶는 이유**: 스크롤 이벤트는 프레임당 여러 번 발생할 수 있는데, 화면은 프레임당 한 번만 그려집니다. rAF로 묶으면 프레임당 한 번만 DOM을 건드립니다(rAF 스로틀링).
- **`{ passive: true }`**: "이 핸들러는 `preventDefault()`를 호출하지 않겠다"는 약속. 브라우저가 스크롤을 즉시 처리할 수 있어 모바일 스크롤이 부드러워집니다.
- **기준값은 상수로 이름을 붙여 관리**합니다. 미션이 README에 명시하라고 한 값들입니다.

---

## 8. 브라우저 저장소와 상태 유지

### 8.1 localStorage

브라우저에 **문자열 형태의 key-value**를 저장하는 API. 도메인(origin)별로 격리되며, 명시적으로 지우기 전까지 유지됩니다.

```js
localStorage.setItem('theme', 'dark');
const saved = localStorage.getItem('theme'); // 'dark', 없으면 null
localStorage.removeItem('theme');
```

| 저장소 | 유효 기간 | 용량 | 서버 전송 |
|---|---|---|---|
| `localStorage` | 영구 (수동 삭제 전까지) | ~5–10MB | X |
| `sessionStorage` | 탭을 닫으면 소멸 | ~5MB | X |
| `cookie` | 만료일 지정 | ~4KB | **매 요청마다 전송** |

**주의**
- 값은 항상 **문자열**입니다. 객체를 저장하려면 `JSON.stringify` / `JSON.parse`.
- 동기 API이므로 큰 데이터를 매 프레임 읽고 쓰면 느려집니다.
- 시크릿 모드나 저장소 차단 설정에서 **접근 자체가 예외를 던질 수 있습니다.** `try/catch`로 감싸는 것이 안전합니다.
- **민감 정보(토큰, 비밀번호)를 넣지 마세요.** JS로 누구나 읽을 수 있어 XSS에 그대로 노출됩니다.

### 8.2 테마 초기화 — FOUC 방지

```js
const getInitialTheme = () => {
  try {
    const saved = localStorage.getItem('theme');
    if (saved === 'light' || saved === 'dark') return saved;   // ① 사용자 선택 우선
  } catch { /* 저장소 접근 불가 시 무시 */ }
  // ② 저장값이 없으면 시스템 설정 따름 (보너스 과제)
  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
};
```

우선순위: **사용자가 직접 고른 값 > 시스템 설정 > 라이트(기본)**. 사용자가 명시적으로 선택한 것이 시스템 설정보다 우선해야 합니다.

**FOUC(Flash of Unstyled Content) 문제**
`defer` 스크립트는 HTML 파싱이 끝난 뒤 실행됩니다. 그래서 다크 모드 사용자가 새로고침하면 **흰 화면이 잠깐 번쩍인 뒤** 어두워집니다.

해결책: 테마 적용 코드**만** `<head>`에 인라인 스크립트로 넣어 파싱 전에 실행합니다.

```html
<head>
  <script>
    (() => {
      try {
        const t = localStorage.getItem('theme')
          ?? (matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
        document.documentElement.setAttribute('data-theme', t);
      } catch {}
    })();
  </script>
  <link rel="stylesheet" href="css/style.css">
</head>
```

"HTML에 JS 쓰지 말라"는 원칙의 예외입니다. **이벤트 핸들러를 HTML에 인라인하지 말라**는 뜻이지, 렌더 차단이 반드시 필요한 초기화까지 금지하는 것은 아닙니다. 이 트레이드오프를 README에 적어두면 좋은 설명 재료가 됩니다.

---

## 9. 배포 — GitHub Pages

### 9.1 개념

**GitHub Pages**: GitHub 저장소의 파일을 그대로 **정적 웹사이트로 호스팅**해주는 무료 서비스입니다.

- **정적 사이트(static site)**: 서버에서 코드를 실행하지 않고, 미리 만들어진 HTML/CSS/JS 파일을 그대로 내려주는 사이트. 이 미션의 결과물이 정확히 여기 해당합니다.
- 서버 코드(PHP, Node 등)는 실행할 수 없습니다. 그래서 GitHub API 호출을 **브라우저에서 직접** 하는 것입니다.

### 9.2 배포 절차

1. GitHub에 저장소 생성 후 코드 push
2. 저장소 → **Settings → Pages**
3. Source를 `Deploy from a branch`, 브랜치는 `main`, 폴더는 `/ (root)` 선택
4. 1~2분 뒤 `https://{username}.github.io/{repo-name}/` 로 접속

### 9.3 배포 후 흔히 깨지는 것들

| 증상 | 원인 | 해결 |
|---|---|---|
| CSS/이미지 404 | 절대 경로 `/css/style.css` 사용 | **상대 경로** `css/style.css` 또는 `./css/style.css` |
| 이미지만 404 | 로컬 파일명 `Profile.JPG`, 코드엔 `profile.jpg` | GitHub Pages(리눅스)는 **대소문자 구분**. 정확히 일치시킬 것 |
| 변경이 반영 안 됨 | 브라우저/CDN 캐시 | 강력 새로고침(⌘⇧R), 몇 분 대기 |
| API 호출 실패 | rate limit 초과, 또는 사용자명 오타 | 콘솔에서 상태 코드 확인 |
| 빈 화면 | JS 에러로 스크립트 중단 | 배포된 사이트에서 **개발자 도구 콘솔** 확인 |

로컬(Live Server)에서 되던 게 배포 후 깨지는 원인은 대부분 **경로**와 **대소문자**입니다.

### 9.4 README에 들어가야 할 것 (미션 요구사항)

- 프로젝트 소개 (무엇을 만들었는지)
- 사용 기술 (HTML5 / CSS3 / Vanilla JavaScript / GitHub REST API)
- **배포 URL**
- 스크린샷 (데스크톱 + 모바일 두 장이면 반응형 증명이 됨)
- 폴더 구조
- **구현한 기능 목록**
- **기준값 명시** — 스크롤탑 표시 임계값, 네비 스타일 변경 임계값, Intersection Observer threshold
- (권장) 트러블슈팅 기록 — 무엇이 안 됐고 왜 그랬으며 어떻게 고쳤는지. 학습 미션에서 가장 평가받기 좋은 항목입니다.

---

## 10. React로 가는 다리

이 미션에서 손으로 한 일이 React에서 무엇으로 대체되는지 대조표입니다. 미션을 끝낸 뒤 다시 읽으면 React 학습이 훨씬 빨라집니다.

| 이번 미션에서 직접 한 일 | React에서는 |
|---|---|
| `let isMenuOpen = false` + 렌더 함수 수동 호출 | `const [isMenuOpen, setIsMenuOpen] = useState(false)` — 상태가 바뀌면 **자동 리렌더** |
| 템플릿 리터럴 + `innerHTML` | **JSX** — 마크업이 문법 차원에서 지원됨 |
| `repos.map(renderCard).join('')` | `{repos.map(repo => <Card key={repo.id} {...repo} />)}` — `join` 불필요 |
| `addEventListener('click', fn)` | `onClick={fn}` — 겉보기엔 인라인이지만 실제로는 합성 이벤트 위임 |
| 카드 HTML을 만드는 함수 `renderCard(repo)` | **컴포넌트** `<ProjectCard repo={repo} />` |
| 함수 인자로 데이터 전달 | **props** |
| `status` 변수로 loading/error 분기 | 동일하지만 `useState` + 조건부 렌더링 |
| 페이지 로드 시 `loadProjects()` 호출 | `useEffect(() => { loadProjects() }, [])` |
| `localStorage` 직접 읽고 쓰기 | 동일. 다만 `useEffect`나 커스텀 훅으로 감쌈 |
| 상태 바꾼 뒤 `render()` 호출을 **잊으면 화면이 안 바뀜** | React가 자동으로 처리 — **이 고통이 React의 존재 이유** |

**가장 중요한 깨달음**
직접 만들다 보면 반드시 이런 버그를 만납니다. *"상태는 바꿨는데 화면이 그대로다."* 렌더 함수 호출을 빠뜨린 것입니다.

React는 이 문제를 **"상태가 바뀌면 렌더는 자동"** 이라는 규칙으로 원천 차단합니다. `useState`의 setter를 호출하면 리렌더가 예약됩니다. 이 미션에서 그 버그를 한 번 겪어봐야 React의 설계 의도가 이해됩니다.

---

## 11. 자주 하는 실수와 점검 포인트

### HTML
- [ ] `<meta name="viewport">` 누락 → 반응형이 전혀 동작하지 않음
- [ ] `<main>`이 2개 이상 → 페이지당 1개
- [ ] `label`의 `for`와 `input`의 `id` 불일치
- [ ] `alt="이미지"` 같은 무의미한 대체 텍스트
- [ ] 앵커 링크 `href="#about"`와 `id="about"` 철자 불일치

### CSS
- [ ] `box-sizing: border-box` 미설정 → 너비 계산이 계속 어긋남
- [ ] `justify-content`와 `align-items`를 `flex-direction: column`에서 반대로 씀
- [ ] `min-width`와 `max-width` 미디어 쿼리를 섞어 써서 겹치는 구간 발생
- [ ] 고정 헤더에 가려진 섹션 제목 → `scroll-margin-top` 필요
- [ ] 다크 모드에서 하드코딩된 색상(`color: #333`)이 남아 있어 글자가 안 보임 → **모든 색은 `var()`로**
- [ ] `transition`을 `all`로 지정 → 의도치 않은 속성까지 애니메이션되어 버벅임

### JavaScript
- [ ] `defer` 없이 `<head>`에 스크립트 → `querySelector`가 `null` → `Cannot read properties of null`
- [ ] `map()` 뒤 `.join('')` 누락 → 카드 사이에 쉼표 출력
- [ ] `res.ok` 확인 없이 `res.json()` → 404가 catch로 안 잡힘
- [ ] `event.preventDefault()` 누락 → 폼 제출 시 페이지 새로고침
- [ ] `innerHTML` 재렌더 후 기존 이벤트 리스너 소실 → **이벤트 위임** 사용
- [ ] `scroll` 이벤트에서 무거운 DOM 조작 → rAF 스로틀링
- [ ] API 응답의 `null` 필드(`description`, `language`)를 그대로 출력 → `??` 기본값
- [ ] 외부 데이터를 이스케이프 없이 `innerHTML`에 삽입 → XSS

### 상태 관리
- [ ] 상태를 DOM 클래스에서 읽어옴 → JS 변수를 단일 진실 공급원으로
- [ ] 상태 변경 후 렌더 함수 호출 누락
- [ ] `empty`와 `error`를 구분하지 않음
- [ ] 재시도 버튼이 없는 에러 상태

### 배포
- [ ] 절대 경로(`/css/...`) 사용
- [ ] 파일명 대소문자 불일치
- [ ] 로컬에서만 테스트하고 배포본 미확인 → **배포 URL을 모바일 기기에서 직접 열어볼 것**

---

## 12. 용어 사전

| 용어 | 뜻 |
|---|---|
| **시맨틱 마크업** | 태그 이름이 콘텐츠의 의미를 나타내도록 HTML을 작성하는 것 |
| **DOM** | 브라우저가 HTML을 파싱해 만든 객체 트리. JS가 조작하는 대상 |
| **뷰포트** | 브라우저에서 실제 콘텐츠가 보이는 영역 |
| **미디어 쿼리** | 화면 조건(너비, 방향, 사용자 설정)에 따라 CSS를 분기하는 문법 |
| **브레이크포인트** | 레이아웃을 전환하는 기준 너비 (이 미션: 768px, 1024px) |
| **모바일 퍼스트** | 모바일 스타일을 기본으로 두고 `min-width`로 확장하는 방식 |
| **주축 / 교차축** | Flexbox에서 아이템이 흐르는 방향 / 그에 수직인 방향 |
| **`fr`** | Grid의 비율 단위. 남은 공간을 분배 |
| **CSS 변수** | `--name: value`로 선언하고 `var(--name)`으로 쓰는 런타임 변경 가능한 값 |
| **우선순위(Specificity)** | 여러 CSS 규칙이 충돌할 때 이기는 순서를 결정하는 점수 체계 |
| **이벤트 리스너** | 특정 이벤트가 발생하면 실행되도록 등록해둔 함수 |
| **버블링** | 이벤트가 발생 지점에서 조상 요소로 전파되는 현상 |
| **이벤트 위임** | 부모에 리스너 하나를 달아 자식들의 이벤트를 처리하는 기법 |
| **콜백** | 나중에 호출되도록 다른 함수에 넘기는 함수 |
| **Promise** | 미래에 완료될 비동기 작업의 결과를 나타내는 객체 |
| **`async` / `await`** | Promise를 동기 코드처럼 읽히게 만드는 문법 |
| **`fetch`** | 브라우저 내장 HTTP 요청 API |
| **REST API** | HTTP 메서드와 URL로 자원을 다루는 API 설계 방식 |
| **JSON** | 텍스트 기반 데이터 교환 형식. API 응답의 표준 |
| **CORS** | 다른 출처의 리소스 요청을 브라우저가 통제하는 보안 정책 |
| **Rate Limit** | API 서버가 정한 시간당 요청 횟수 제한 |
| **상태(state)** | 변하면 화면이 달라져야 하는 데이터 |
| **단일 진실 공급원** | 같은 정보를 여러 곳에 두지 않고 한 곳에서만 관리하는 원칙 |
| **XSS** | 악의적 스크립트가 페이지에 삽입되어 실행되는 취약점 |
| **FOUC** | 스타일이 적용되기 전 화면이 잠깐 번쩍이는 현상 |
| **정적 사이트** | 서버 실행 없이 파일을 그대로 제공하는 웹사이트 |
| **`prefers-color-scheme`** | 사용자의 OS 다크/라이트 설정을 감지하는 미디어 쿼리 |
| **`prefers-reduced-motion`** | 애니메이션 최소화를 원하는지 감지하는 미디어 쿼리 |

---

## 13. 개발 환경과 허용 리소스

### 13.1 금지되는 것과 허용되는 것

| 구분 | 금지 | 허용 |
|---|---|---|
| **JS 프레임워크/라이브러리** | React, Vue, jQuery | 순수(Vanilla) JavaScript만 |
| **CSS 프레임워크** | Bootstrap, Tailwind CSS | 직접 작성한 CSS만 |
| **아이콘** | — | Font Awesome 등 아이콘 라이브러리 |
| **폰트** | — | Google Fonts 등 웹 폰트 |

**왜 이렇게 나뉘는가**: 금지 목록(React/Vue/jQuery/Bootstrap/Tailwind)의 공통점은 **"이 미션이 직접 체득시키려는 기술 자체를 대신 해준다"** 는 것입니다.

- jQuery는 `querySelector`/`addEventListener`를 대신 해줌 → DOM/이벤트를 직접 다루는 연습이 안 됨
- Bootstrap/Tailwind는 Flexbox/Grid/미디어 쿼리를 클래스 이름 뒤에 숨김 → CSS 레이아웃을 직접 설계하는 연습이 안 됨
- React/Vue는 상태→렌더링을 자동화함 → 이 미션이 가장 체득시키고 싶어하는 부분 자체가 사라짐

반면 아이콘/웹 폰트는 **레이아웃이나 상태 관리와 무관한 순수 리소스**(이미지·폰트 파일)이기 때문에 허용됩니다. `<link>` 태그로 불러와 쓰는 것은 `<img>` 태그로 이미지를 불러오는 것과 본질적으로 같습니다.

### 13.2 아이콘 사용 예시

```html
<!-- Font Awesome CDN -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
```
```html
<a href="https://github.com/본인아이디" aria-label="GitHub 프로필로 이동">
  <i class="fa-brands fa-github"></i>
</a>
```

`<i>` 태그 자체는 시각 효과만 있고 의미가 없으므로, 스크린 리더 사용자를 위해 링크(`<a>`)나 버튼에 `aria-label`로 목적을 설명해주는 것이 좋습니다.

### 13.3 웹 폰트 사용 예시

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Pretendard:wght@400;700&display=swap" rel="stylesheet">
```

```css
:root {
  --font-base: 'Pretendard', -apple-system, BlinkMacSystemFont, sans-serif;
}
body { font-family: var(--font-base); }
```

- `display=swap`: 폰트가 로드되기 전까지는 시스템 폰트로 먼저 보여주고, 로드되면 교체합니다. 이게 없으면 폰트가 로드될 때까지 텍스트가 아예 안 보이는 경우(FOIT)가 생길 수 있습니다.
- 폴백 폰트(`-apple-system` 등)를 항상 함께 지정합니다. 네트워크가 느리거나 CDN이 막힌 환경에서도 텍스트는 읽혀야 합니다.

### 13.4 VS Code + Live Server

**Live Server**는 VS Code 확장 프로그램으로, `index.html`을 저장할 때마다 브라우저를 자동 새로고침해주는 로컬 개발 서버입니다.

- 파일을 그냥 더블클릭해서 여는 것(`file://...`)과 서버로 여는 것(`http://127.0.0.1:5500/...`)은 다릅니다. `fetch`로 외부 API를 호출할 때 `file://` 프로토콜에서는 CORS 정책상 막히는 경우가 있어, 반드시 로컬 서버(Live Server)로 실행해야 합니다.
- 설치: VS Code 확장 마켓에서 "Live Server" 검색 → 설치 → `index.html` 우클릭 → "Open with Live Server"

### 13.5 최신 Chrome 기준 동작

미션은 **최신 Chrome**에서의 정상 동작만 요구합니다. 즉 구형 브라우저(Internet Explorer 등)를 위한 폴리필이나 벤더 프리픽스(`-webkit-`, `-moz-`)를 신경 쓸 필요가 없습니다. `fetch`, `async/await`, CSS 변수, Grid `auto-fit`, Intersection Observer 모두 최신 Chrome에서 별도 처리 없이 그대로 동작합니다.

---

## 14. 제약 사항 — 왜 이렇게 제한하는가

### 14.1 핵심 목표를 다시 읽기

> UI 고퀄리티보다 "이벤트 → 상태 → 렌더링" 흐름 이해 우선

이 한 줄이 채점 기준의 우선순위를 말해줍니다. 디자인이 세련되지 않아도, **상태가 어떻게 바뀌고 그게 화면에 어떻게 반영되는지가 코드에서 명확히 보이면** 이 미션의 목적은 달성된 것입니다. 반대로 디자인은 화려한데 상태를 DOM에서 즉흥적으로 읽고 쓰는 코드(7.2절의 안티패턴)라면, 미션의 핵심을 비껴간 것입니다.

작업 우선순위를 정해야 한다면:

1. 세 가지 이상의 "상태 → 렌더링" 흐름이 코드에서 명확히 분리되어 있는가
2. GitHub API의 4가지 상태(로딩/성공/에러/빈 상태, 레이트 리밋 포함)가 실제로 눈에 보이는가
3. 폼 유효성 검사가 이벤트 기반으로 동작하는가
4. 반응형 레이아웃이 세 구간(모바일/태블릿/데스크톱)에서 자연스러운가
5. 디자인 완성도 (우선순위상 가장 마지막)

### 14.2 코드 스타일 규칙의 근거

| 규칙 | 5장에서의 상세 설명 위치 | 한 줄 이유 |
|---|---|---|
| `var` 대신 `const`/`let` | [5.2](#52-var-대신-const--let) | 블록 스코프로 스코프 관련 버그 원천 차단 |
| `onclick` 대신 `addEventListener` | [5.4](#54-이벤트-event) | 구조(HTML)와 동작(JS)의 관심사 분리, 핸들러 다중 등록 가능 |
| **인라인 스타일(`style="..."`) 금지** | (신규) 아래 14.3 참고 | 스타일(CSS)과 상태 적용(JS)의 관심사 분리 |

### 14.3 인라인 스타일을 금지하는 이유

```html
<!-- 금지 -->
<div style="display: none; color: red;">에러 메시지</div>
```
```js
// 금지 — JS에서 개별 CSS 속성을 직접 조작
errorBox.style.display = 'block';
errorBox.style.color = 'red';
```

인라인 스타일이 왜 문제인지는 4.8절(선택자 우선순위)과 이어집니다. 인라인 스타일은 `!important`를 제외하면 **가장 높은 우선순위**를 가져서, `class`로 준 스타일을 아무리 정교하게 짜도 인라인 스타일 한 줄에 덮여버립니다. 이 때문에 나중에 스타일이 안 먹히는 원인을 추적하기 어려워집니다.

**해결책은 이미 7.2절에서 다룬 원칙과 같습니다.** "JS는 클래스만 붙였다 뗀다. 어떻게 보일지는 CSS가 정한다."

```css
/* css/style.css */
.error-box { display: none; color: var(--color-error); }
.error-box.visible { display: block; }
```
```js
errorBox.classList.toggle('visible', hasError);
```

예외적으로 **JS로 계산해야만 하는 동적인 수치**(예: 스크롤 진행률에 따른 `width: 37%`, 드래그 중인 요소의 좌표)는 인라인 스타일이 실용적인 경우가 있습니다. 하지만 이 미션의 요구 기능(햄버거 메뉴, 다크 모드, 카드 렌더링, 폼 에러 표시) 중에는 그런 동적 수치 계산이 필요한 항목이 없으므로, 전부 `classList` + CSS 규칙만으로 구현 가능합니다.

### 14.4 GitHub API 사용 시 태도

7장·13장에서 다룬 내용을 제약사항 관점에서 다시 정리하면:

- 레이트 리밋(시간당 60회)은 **정상적으로 발생 가능한 상황**이지, 예외적인 장애가 아닙니다. 따라서 "에러가 왜 났지?"라며 당황할 게 아니라, **애초에 에러 상태 UI가 이걸 위해 존재**한다고 생각하면 됩니다.
- 개발 중 반복 새로고침으로 직접 리밋에 걸려보고, 그때 에러 상태 UI(재시도 버튼 포함)가 잘 뜨는지 확인하는 것이 오히려 좋은 테스트 방법입니다. 재현이 어려우면 `fetch` URL을 일부러 오타 내서(`/user/`) 404를 만들어 테스트해도 같은 에러 경로를 검증할 수 있습니다.

---

## 15. 제출물 체크리스트

미션 완료 시 제출해야 하는 네 가지와, 각각 점검할 포인트입니다.

| 제출물 | 확인할 것 |
|---|---|
| **GitHub 저장소 URL** | `public` 저장소인지 (비공개면 채점자가 코드를 못 봄) · README가 저장소 루트에 있는지 |
| **배포된 사이트 URL (GitHub Pages)** | 9장의 절차대로 배포되었는지 · 시크릿 창(캐시 없는 상태)에서 새로 열어 전체 기능이 동작하는지 |
| **데스크톱 스크린샷** | 1024px 이상 너비에서 촬영 · 네비게이션 메뉴가 펼쳐진 상태 |
| **모바일 스크린샷** | 브라우저 개발자 도구의 기기 툴바(⌘⇧M / Ctrl+Shift+M)로 375px 전후 폭에서 촬영 · 햄버거 메뉴가 보이는(또는 펼쳐진) 상태 |
| **다크모드 스크린샷** | 토글을 눌러 다크 모드로 전환한 뒤 촬영 · 라이트 모드 스크린샷과 대비되도록 같은 섹션을 찍으면 좋음 |

**스크린샷을 README에 넣는 방법**

```markdown
## 스크린샷

| 데스크톱 | 모바일 | 다크 모드 |
|---|---|---|
| ![desktop](images/screenshot-desktop.png) | ![mobile](images/screenshot-mobile.png) | ![dark](images/screenshot-dark.png) |
```

이미지 파일은 `images/` 폴더에 넣고 README에서 **상대 경로**로 참조합니다(9.3절에서 다룬 절대 경로 문제와 동일한 이유).

**제출 전 마지막 점검**: 배포 URL을 실제 스마트폰(또는 개발자 도구 기기 모드가 아닌 진짜 모바일 브라우저)에서 열어, 레이아웃뿐 아니라 **터치로 햄버거 메뉴가 실제로 열리는지, 폼 입력이 되는지**까지 확인하는 것을 권장합니다. 개발자 도구의 반응형 미리보기는 실제 터치 이벤트와 미묘하게 다를 수 있습니다.

---

## 16. 결과 예시 읽는 법 (와이어프레임)

미션에 제시된 와이어프레임(ASCII 박스 그림)은 **디자인 정답이 아니라 "정보 구조"의 예시**입니다. 색상, 폰트, 여백, 정렬은 자유이되, 각 섹션이 담아야 하는 정보와 그 정보들 사이의 위계는 참고할 만합니다. 박스 하나하나가 실제로 어떤 HTML/CSS 개념과 대응하는지 짚어보면 이렇습니다.

```
+------------------------------------------------------------------+
| Logo                           Menu                         [D]  |  <- Header (Flex)
+------------------------------------------------------------------+
```

- `<header><nav>` 안에 로고(왼쪽)와 메뉴(오른쪽)가 양 끝에 붙는 배치 → 4.3절의 `justify-content: space-between`
- `[D]`는 다크 모드 토글 버튼. 메뉴와 같은 줄, 가장 오른쪽에 배치되는 경우가 많음
- 모바일 폭에서는 이 줄의 `Menu` 부분이 햄버거 아이콘 하나로 축약됨 (4.6절)

```
|                          Hello!                                  |
|                       I am [NAME].                               |  <- Hero
|                 [ View Projects ]   [ Contact ]                  |
```

- Hero 섹션: 화면에 처음 보이는 인사말 + 이름 + CTA(Call To Action) 버튼 2개
- CTA 버튼들은 `#projects`, `#contact` 앵커로 연결되는 프래그먼트 링크(3.4절) → 클릭 시 부드러운 스크롤(4.7절)로 이동

```
| About Me                                                         |
|  +----------+  Intro text...                                     |
|  |  PHOTO   |  (skills / interests / short bio)                  |  <- About
|  +----------+                                                    |
```

- 사진(왼쪽) + 텍스트(오른쪽)의 좌우 배치 → 전형적인 Flexbox `row` 레이아웃 (또는 좁은 화면에선 `column`으로 전환하는 반응형 패턴)
- 사진에는 의미 있는 `alt` 필요 (3.3절)
- "Skills"가 여기 텍스트에 녹아 있지만, 미션 요구사항상 Skills는 **별도 섹션**으로 분리하는 것이 시맨틱 구조상 더 명확합니다 (기술 스택 목록은 About의 자기소개와 성격이 다른 콘텐츠이므로)

```
| Projects (GitHub API)                                            |
|  +--------------+  +--------------+  +--------------+            |
|  | Repo 1        |  | Repo 2     |  | Repo 3        |            |
|  | Stars: 5      |  | Stars: 3   |  | Stars: 2      |            |
|  +--------------+  +--------------+  +--------------+            |
```

- 카드가 가로로 나열되지만 개수가 화면 폭에 따라 자동으로 줄어드는 구조 → 4.4절의 `grid-template-columns: repeat(auto-fit, minmax(280px, 1fr))`
- 카드 하나하나는 `<article class="project-card">` (3.2절 — 독립적으로 떼어내도 의미가 통하는 콘텐츠)
- 이 박스 하나가 실제로는 네 가지 모습 중 하나로 바뀔 수 있다는 걸 그림만 봐서는 알 수 없습니다. 아래 "상태별 UI 예시"가 그 부분을 보완합니다.

```
| Contact                                                          |
|  | Name:    [____________________]                            |  |
|  | Email:   [____________________]                            |  |
|  | Message: [______________________________]                  |  |
|  |                          [ Send ]                          |  |
```

- 각 입력 칸 왼쪽의 "Name:", "Email:", "Message:" 텍스트가 `<label>` → `for`/`id`로 바로 옆 `<input>`/`<textarea>`와 연결 (3.3절)
- `[ Send ]` 버튼은 `<button type="submit">` → `submit` 이벤트로 처리, `event.preventDefault()` 필수 (5.4절, 7.3절)

```
| (C) 2026 [NAME]   |  GitHub  |  LinkedIn                         |
+------------------------------------------------------------------+
```

- `<footer>`: 저작권 문구 + 소셜 링크. 13.2절의 아이콘(Font Awesome)을 여기서 활용하기 좋음

### 16.1 "상태별 UI 예시"가 그림과 별도로 제시된 이유

와이어프레임은 **정적인 한 순간**만 보여줍니다. 하지만 Projects 섹션의 저 박스 3개짜리 그림은 실제로는 아래 네 가지 모습 중 하나로, 사용자 세션마다 다르게 나타납니다.

```
[로딩]  Projects (GitHub API)
        ⏳ 프로젝트를 불러오는 중...

[성공]  Projects (GitHub API)
        [Repo1] [Repo2] [Repo3]        ← 와이어프레임에 그려진 모습

[에러]  Projects (GitHub API)
        ⚠ 프로젝트를 불러올 수 없습니다.
        [ 다시 시도 ]

[빈 데이터] Projects (GitHub API)
        표시할 프로젝트가 없습니다.
```

이것이 6.6절과 7.3절에서 다룬 `state.status` 값 하나가 이 네 그림 중 무엇을 그릴지를 결정하는 것과 정확히 같은 이야기입니다. 미션의 예시 그림 8장에서 와이어프레임과 "상태별 UI 예시"를 **따로** 제시한 것 자체가, 이 미션이 정적인 화면 하나가 아니라 **상태에 따라 달라지는 화면 여러 개**를 만들라고 요구하고 있다는 신호입니다.

---

## 마무리

이 미션의 요구사항을 하나의 문장으로 요약하면 이렇습니다.

> **"이벤트를 받아 상태를 바꾸고, 그 상태로 화면을 다시 그리는 일"을 라이브러리 없이 직접 해보는 것.**

햄버거 메뉴, 다크 모드, API 로딩, 폼 검증 — 겉보기엔 네 개의 다른 기능이지만 전부 같은 구조입니다. 이 구조가 보이기 시작하면 미션은 끝난 것이고, React의 `useState`를 처음 봤을 때 "아, 그거 자동으로 해주는 거구나"라고 이해하게 됩니다.
