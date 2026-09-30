// ============================================================
// 설정값
// ============================================================
const GITHUB_USERNAME = "davekim-dev";
const SCROLL_TOP_THRESHOLD = 300; // 스크롤 탑 버튼이 나타나는 기준 (px)
const NAV_SCROLLED_THRESHOLD = 60; // 네비게이션 배경색이 바뀌는 기준 (px)
const REVEAL_THRESHOLD = 0.2; // IntersectionObserver threshold
const MESSAGE_MIN_LENGTH = 10; // 메시지 최소 글자 수
const MAX_PROJECTS = 6; // 화면에 보여줄 프로젝트 최대 개수
const ALL_LANGUAGES = "All"; // 언어 필터 '전체' 값

// ============================================================
// 상태 (단일 진실 공급원: DOM이 아니라 이 객체를 읽고 바꾼다)
// ============================================================
const state = {
  theme: "light", // 'light' | 'dark'
  isMenuOpen: false,
  projectsStatus: "idle", // 'idle' | 'loading' | 'success' | 'empty' | 'error'
  repos: [], // fork를 제외한 저장소 배열
  activeLanguage: ALL_LANGUAGES, // 언어 필터
  formErrors: {}, // { name?: string, email?: string, message?: string }
  formSuccess: "", // 전송 성공 메시지
};

// ============================================================
// 다크 모드 (상태: theme → 렌더링: data-theme 속성 + 아이콘)
// ============================================================
const themeToggleBtn = document.querySelector("#theme-toggle");
const THEME_STORAGE_KEY = "theme";

const renderTheme = () => {
  document.documentElement.setAttribute("data-theme", state.theme);
  themeToggleBtn.textContent = state.theme === "dark" ? "☀️" : "🌙";
};

const initTheme = () => {
  const savedTheme = localStorage.getItem(THEME_STORAGE_KEY);
  const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
  state.theme = savedTheme || (prefersDark ? "dark" : "light");
  renderTheme();
};

themeToggleBtn.addEventListener("click", () => {
  state.theme = state.theme === "dark" ? "light" : "dark";
  localStorage.setItem(THEME_STORAGE_KEY, state.theme);
  renderTheme();
});

initTheme();

// ============================================================
// 햄버거 메뉴 토글 (상태: isMenuOpen → 렌더링: active 클래스 + aria-expanded)
// ============================================================
const navToggleBtn = document.querySelector("#nav-toggle");
const navMenu = document.querySelector("#nav-menu");

const renderMenu = () => {
  navMenu.classList.toggle("active", state.isMenuOpen);
  navToggleBtn.classList.toggle("active", state.isMenuOpen);
  navToggleBtn.setAttribute("aria-expanded", String(state.isMenuOpen));
};

navToggleBtn.addEventListener("click", () => {
  state.isMenuOpen = !state.isMenuOpen;
  renderMenu();
});

// 메뉴 링크 클릭 시 모바일 메뉴 닫기
const navLinks = document.querySelectorAll(".nav__link");
navLinks.forEach((link) => {
  link.addEventListener("click", () => {
    state.isMenuOpen = false;
    renderMenu();
  });
});

// ============================================================
// 부드러운 스크롤 (앵커 링크)
// ============================================================
const anchorLinks = document.querySelectorAll('a[href^="#"]');
anchorLinks.forEach((anchor) => {
  anchor.addEventListener("click", (event) => {
    const targetId = anchor.getAttribute("href");
    const targetEl = document.querySelector(targetId);
    if (!targetEl) return;

    event.preventDefault();
    targetEl.scrollIntoView({ behavior: "smooth" });
  });
});

// ============================================================
// 스크롤 이벤트: 네비게이션 스타일 변경 + 스크롤 탑 버튼
// ============================================================
const header = document.querySelector("#header");
const scrollTopBtn = document.querySelector("#scroll-top");

window.addEventListener("scroll", () => {
  const { scrollY } = window;

  header.classList.toggle("scrolled", scrollY >= NAV_SCROLLED_THRESHOLD);
  scrollTopBtn.classList.toggle("visible", scrollY >= SCROLL_TOP_THRESHOLD);
});

scrollTopBtn.addEventListener("click", () => {
  window.scrollTo({ top: 0, behavior: "smooth" });
});

// ============================================================
// 스크롤 애니메이션 (Intersection Observer)
// ============================================================
const revealTargets = document.querySelectorAll(
  ".about, .skills, .projects, .contact"
);
revealTargets.forEach((el) => el.classList.add("reveal"));

const revealObserver = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("visible");
        revealObserver.unobserve(entry.target);
      }
    });
  },
  { threshold: REVEAL_THRESHOLD }
);

revealTargets.forEach((el) => revealObserver.observe(el));

// ============================================================
// GitHub API 연동 (상태: projectsStatus/repos/activeLanguage → 렌더링: 필터 + Projects 카드)
// ============================================================
const projectsGrid = document.querySelector("#projects-grid");
const projectsStatusEl = document.querySelector("#projects-status");
const projectsFilters = document.querySelector("#projects-filters");

// 외부 데이터를 innerHTML에 넣기 전에 HTML 특수문자를 이스케이프 (XSS 방지)
const escapeHtml = (value) =>
  String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");

const renderProjectCard = ({ name, description, html_url, stargazers_count, language }) => `
  <article class="project-card">
    <h3 class="project-card__title">${escapeHtml(name)}</h3>
    <p class="project-card__desc">${escapeHtml(description ?? "설명이 없습니다.")}</p>
    <p class="project-card__meta">⭐ ${escapeHtml(stargazers_count)} ${language ? `· ${escapeHtml(language)}` : ""}</p>
    <a href="${escapeHtml(html_url)}" target="_blank" rel="noopener noreferrer" class="btn btn--secondary">Repo 보기</a>
  </article>
`;

const renderFilterButton = (language) => `
  <button type="button"
    class="btn btn--secondary filter-btn ${language === state.activeLanguage ? "active" : ""}"
    data-language="${escapeHtml(language)}"
    aria-pressed="${language === state.activeLanguage}">
    ${escapeHtml(language)}
  </button>
`;

// 저장소에 등장하는 언어 목록 (중복 제거, 언어 없는 저장소 제외)
const getLanguages = (repos) => [
  ALL_LANGUAGES,
  ...new Set(repos.map(({ language }) => language).filter(Boolean)),
];

const matchesActiveLanguage = ({ language }) =>
  state.activeLanguage === ALL_LANGUAGES || language === state.activeLanguage;

// 상태 하나만 보고 Projects 영역 전체를 그린다
const renderProjects = () => {
  const { projectsStatus, repos } = state;

  projectsFilters.innerHTML = "";
  projectsGrid.innerHTML = "";

  if (projectsStatus === "loading") {
    projectsStatusEl.textContent = "로딩 중...";
    return;
  }

  if (projectsStatus === "error") {
    projectsStatusEl.innerHTML = `
      프로젝트를 불러올 수 없습니다.
      <button type="button" class="btn btn--secondary retry-btn" id="retry-btn">다시 시도</button>
    `;
    return;
  }

  if (projectsStatus === "empty") {
    projectsStatusEl.textContent = "표시할 프로젝트가 없습니다.";
    return;
  }

  projectsStatusEl.textContent = "";
  projectsFilters.innerHTML = getLanguages(repos).map(renderFilterButton).join("");
  projectsGrid.innerHTML = repos
    .filter(matchesActiveLanguage)
    .map(renderProjectCard)
    .join("");
};

const loadProjects = async () => {
  state.projectsStatus = "loading";
  renderProjects();

  try {

    await new Promise((resolve) => setTimeout(resolve, 2000)); // 테스트용 2초 지연 (확인 후 삭제!)
    const response = await fetch(
      `https://api.github.com/users/${GITHUB_USERNAME}/repos?sort=updated&per_page=100`
    );

    if (!response.ok) {
      throw new Error(`GitHub API error: ${response.status}`);
    }

    const data = await response.json();

    // fork 저장소는 제외하고 최근 수정순으로 최대 MAX_PROJECTS개만 사용
    state.repos = data.filter(({ fork }) => !fork).slice(0, MAX_PROJECTS);
    state.activeLanguage = ALL_LANGUAGES;
    state.projectsStatus = state.repos.length === 0 ? "empty" : "success";
  } catch (error) {
    console.error(error);
    state.repos = [];
    state.projectsStatus = "error";
  }

  renderProjects();
};

// 이벤트 위임: innerHTML로 다시 그려져도 리스너가 유지된다
projectsStatusEl.addEventListener("click", (event) => {
  if (!event.target.closest("#retry-btn")) return;
  loadProjects();
});

projectsFilters.addEventListener("click", (event) => {
  const filterBtn = event.target.closest(".filter-btn");
  if (!filterBtn) return;

  state.activeLanguage = filterBtn.dataset.language;
  renderProjects();
});

loadProjects();

// ============================================================
// 폼 유효성 검사 (상태: formErrors/formSuccess → 렌더링: 에러·성공 메시지)
// ============================================================
const contactForm = document.querySelector("#contact-form");
const nameInput = document.querySelector("#name");
const emailInput = document.querySelector("#email");
const messageInput = document.querySelector("#message");
const formSuccess = document.querySelector("#form-success");
const FORM_FIELDS = ["name", "email", "message"];
const MESSAGE_TOO_SHORT = `메시지는 ${MESSAGE_MIN_LENGTH}자 이상 입력해주세요.`;

const renderForm = () => {
  FORM_FIELDS.forEach((field) => {
    const errorEl = document.querySelector(`#${field}-error`);
    errorEl.textContent = state.formErrors[field] ?? "";
  });
  formSuccess.textContent = state.formSuccess;
};

const isValidEmail = (email) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);

// 입력값을 받아 에러 객체를 돌려주는 순수 함수 (DOM을 건드리지 않음)
const validateForm = ({ name, email, message }) => {
  const errors = {};

  if (!name.trim()) errors.name = "이름을 입력해주세요.";

  if (!email.trim()) errors.email = "이메일을 입력해주세요.";
  else if (!isValidEmail(email)) errors.email = "올바른 이메일 형식이 아닙니다.";

  if (!message.trim()) errors.message = "메시지를 입력해주세요.";
  else if (message.trim().length < MESSAGE_MIN_LENGTH) errors.message = MESSAGE_TOO_SHORT;

  return errors;
};

contactForm.addEventListener("submit", (event) => {
  event.preventDefault();

  const errors = validateForm({
    name: nameInput.value,
    email: emailInput.value,
    message: messageInput.value,
  });
  const isValid = Object.keys(errors).length === 0;

  state.formErrors = errors;
  state.formSuccess = isValid ? "메시지가 성공적으로 전송되었습니다!" : "";
  renderForm();

  if (isValid) contactForm.reset();
});

// 입력 중 실시간으로 에러 지우기
[nameInput, emailInput].forEach((input) => {
  input.addEventListener("input", () => {
    state.formErrors = { ...state.formErrors, [input.id]: "" };
    renderForm();
  });
});

// 메시지는 입력 중에도 글자 수 안내 (비어 있을 때는 제출 시에만 에러 표시)
messageInput.addEventListener("input", () => {
  const { length } = messageInput.value.trim();
  const isTooShort = length > 0 && length < MESSAGE_MIN_LENGTH;

  state.formErrors = { ...state.formErrors, message: isTooShort ? MESSAGE_TOO_SHORT : "" };
  renderForm();
});
