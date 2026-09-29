// ============================================================
// 설정값
// ============================================================
const GITHUB_USERNAME = "davekim-dev";
const SCROLL_TOP_THRESHOLD = 300; // 스크롤 탑 버튼이 나타나는 기준 (px)
const NAV_SCROLLED_THRESHOLD = 60; // 네비게이션 배경색이 바뀌는 기준 (px)
const REVEAL_THRESHOLD = 0.2; // IntersectionObserver threshold
const MESSAGE_MIN_LENGTH = 10; // 메시지 최소 글자 수

// ============================================================
// 상태 (단일 진실 공급원: DOM이 아니라 이 객체를 읽고 바꾼다)
// ============================================================
const state = {
  theme: "light", // 'light' | 'dark'
  isMenuOpen: false,
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
// GitHub API 연동 (상태: loading/success/error/empty → 렌더링: Projects 카드)
// ============================================================
const projectsGrid = document.querySelector("#projects-grid");
const projectsStatus = document.querySelector("#projects-status");

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

const renderProjectsLoading = () => {
  projectsStatus.textContent = "로딩 중...";
  projectsGrid.innerHTML = "";
};

const renderProjectsError = () => {
  projectsStatus.innerHTML = `
    프로젝트를 불러올 수 없습니다.
    <button class="btn btn--secondary retry-btn" id="retry-btn">다시 시도</button>
  `;
  projectsGrid.innerHTML = "";

  document.querySelector("#retry-btn").addEventListener("click", loadProjects);
};

const renderProjectsEmpty = () => {
  projectsStatus.textContent = "표시할 프로젝트가 없습니다.";
  projectsGrid.innerHTML = "";
};

const renderProjectsSuccess = (repos) => {
  projectsStatus.textContent = "";
  projectsGrid.innerHTML = repos.map(renderProjectCard).join("");
};

const loadProjects = async () => {
  renderProjectsLoading();

  try {
    const response = await fetch(
      `https://api.github.com/users/${GITHUB_USERNAME}/repos?sort=updated&per_page=6`
    );

    if (!response.ok) {
      throw new Error(`GitHub API error: ${response.status}`);
    }

    const repos = await response.json();

    if (repos.length === 0) {
      renderProjectsEmpty();
      return;
    }

    renderProjectsSuccess(repos);
  } catch (error) {
    console.error(error);
    renderProjectsError();
  }
};

loadProjects();

// ============================================================
// 폼 유효성 검사 (상태: 에러 → 렌더링: 에러 메시지 표시/숨김)
// ============================================================
const contactForm = document.querySelector("#contact-form");
const nameInput = document.querySelector("#name");
const emailInput = document.querySelector("#email");
const messageInput = document.querySelector("#message");
const formSuccess = document.querySelector("#form-success");

const showError = (fieldId, message) => {
  const errorEl = document.querySelector(`#${fieldId}-error`);
  errorEl.textContent = message;
};

const clearErrors = () => {
  document
    .querySelectorAll(".form__error")
    .forEach((el) => (el.textContent = ""));
  formSuccess.textContent = "";
};

const isValidEmail = (email) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);

const validateForm = ({ name, email, message }) => {
  let isValid = true;

  if (!name.trim()) {
    showError("name", "이름을 입력해주세요.");
    isValid = false;
  }

  if (!email.trim()) {
    showError("email", "이메일을 입력해주세요.");
    isValid = false;
  } else if (!isValidEmail(email)) {
    showError("email", "올바른 이메일 형식이 아닙니다.");
    isValid = false;
  }

  if (!message.trim()) {
    showError("message", "메시지를 입력해주세요.");
    isValid = false;
  } else if (message.trim().length < MESSAGE_MIN_LENGTH) {
    showError("message", `메시지는 ${MESSAGE_MIN_LENGTH}자 이상 입력해주세요.`);
    isValid = false;
  }

  return isValid;
};

contactForm.addEventListener("submit", (event) => {
  event.preventDefault();
  clearErrors();

  const formData = {
    name: nameInput.value,
    email: emailInput.value,
    message: messageInput.value,
  };

  if (!validateForm(formData)) return;

  formSuccess.textContent = "메시지가 성공적으로 전송되었습니다!";
  contactForm.reset();
});

// 입력 중 실시간으로 에러 지우기
[nameInput, emailInput].forEach((input) => {
  input.addEventListener("input", () => {
    showError(input.id, "");
  });
});

// 메시지는 입력 중에도 글자 수 안내 (비어 있을 때는 제출 시에만 에러 표시)
messageInput.addEventListener("input", () => {
  const { length } = messageInput.value.trim();
  const isTooShort = length > 0 && length < MESSAGE_MIN_LENGTH;

  showError(
    "message",
    isTooShort ? `메시지는 ${MESSAGE_MIN_LENGTH}자 이상 입력해주세요.` : ""
  );
});
