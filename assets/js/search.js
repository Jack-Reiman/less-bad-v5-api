// Client-side search engine for VEXcode V5 C++ documentation

let searchIndex = [];
let searchModalBackdrop = null;
let searchInput = null;
let searchResults = null;
let selectedIndex = -1;

function initSearch(indexData) {
  searchIndex = indexData;
  setupSearchUI();
}

function setupSearchUI() {
  // Create search modal elements
  const backdrop = document.createElement('div');
  backdrop.className = 'search-modal-backdrop';
  backdrop.innerHTML = `
    <div class="search-modal" role="dialog" aria-modal="true">
      <div class="search-modal-header">
        <span style="color:#888;">🔍</span>
        <input type="text" class="search-modal-input" placeholder="Search VEXcode C++ API (e.g. spin, heading, brain, degrees)..." autocomplete="off" />
        <span style="color:#aaa; font-size:0.8rem; background:#eee; padding:0.2rem 0.4rem; border-radius:3px;">ESC</span>
      </div>
      <div class="search-modal-results"></div>
    </div>
  `;
  document.body.appendChild(backdrop);

  searchModalBackdrop = backdrop;
  searchInput = backdrop.querySelector('.search-modal-input');
  searchResults = backdrop.querySelector('.search-modal-results');

  // Trigger from sidebar input
  const sidebarInputs = document.querySelectorAll('.search-input');
  sidebarInputs.forEach(input => {
    input.addEventListener('focus', (e) => {
      e.target.blur();
      openSearchModal();
    });
  });

  backdrop.addEventListener('click', (e) => {
    if (e.target === backdrop) closeSearchModal();
  });

  searchInput.addEventListener('input', (e) => {
    renderSearchResults(e.target.value.trim());
  });

  searchInput.addEventListener('keydown', (e) => {
    const items = searchResults.querySelectorAll('.search-result-item');
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      if (items.length > 0) {
        selectedIndex = (selectedIndex + 1) % items.length;
        updateSelected(items);
      }
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      if (items.length > 0) {
        selectedIndex = (selectedIndex - 1 + items.length) % items.length;
        updateSelected(items);
      }
    } else if (e.key === 'Enter') {
      e.preventDefault();
      if (selectedIndex >= 0 && selectedIndex < items.length) {
        items[selectedIndex].click();
      }
    }
  });
}

function updateSelected(items) {
  items.forEach((item, idx) => {
    if (idx === selectedIndex) {
      item.classList.add('selected');
      item.scrollIntoView({ block: 'nearest' });
    } else {
      item.classList.remove('selected');
    }
  });
}

function openSearchModal() {
  if (!searchModalBackdrop) return;
  searchModalBackdrop.classList.add('open');
  searchInput.value = '';
  selectedIndex = -1;
  renderSearchResults('');
  setTimeout(() => searchInput.focus(), 50);
}

function closeSearchModal() {
  if (!searchModalBackdrop) return;
  searchModalBackdrop.classList.remove('open');
}

function renderSearchResults(query) {
  if (!searchResults) return;
  selectedIndex = -1;

  if (!query) {
    searchResults.innerHTML = `
      <div style="padding: 1.5rem; color: #888; text-align: center; font-size: 0.9rem;">
        Type a command name, class, or keyword to search the VEXcode V5 C++ reference.
      </div>
    `;
    return;
  }

  const q = query.toLowerCase();
  const matched = searchIndex.filter(item => {
    return item.title.toLowerCase().includes(q) ||
           item.category.toLowerCase().includes(q) ||
           (item.desc && item.desc.toLowerCase().includes(q));
  }).slice(0, 15);

  if (matched.length === 0) {
    searchResults.innerHTML = `<div class="search-empty">No documentation entries found matching "<strong>${escapeHtml(query)}</strong>"</div>`;
    return;
  }

  const isInsideApiCpp = window.location.pathname.replace(/\\/g, '/').includes('/api/cpp/');

  searchResults.innerHTML = matched.map((item, idx) => {
    let resolvedUrl = item.url;
    if (!isInsideApiCpp) {
      if (!resolvedUrl.startsWith('http') && !resolvedUrl.startsWith('api/cpp/')) {
        resolvedUrl = 'api/cpp/' + resolvedUrl;
      }
    }
    return `
      <a href="${resolvedUrl}" class="search-result-item ${idx === 0 ? 'selected' : ''}">
        <div class="search-result-title">${highlightMatch(item.title, query)}</div>
        <div class="search-result-breadcrumb">${escapeHtml(item.category)}</div>
        <div class="search-result-snippet">${highlightMatch(item.desc || '', query)}</div>
      </a>
    `;
  }).join('');

  selectedIndex = 0;
}

function escapeHtml(str) {
  return (str || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function highlightMatch(text, query) {
  if (!query || !text) return escapeHtml(text);
  const regex = new RegExp(`(${query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'gi');
  return escapeHtml(text).replace(regex, '<span style="background:#fff3cd; font-weight:700; color:#333;">$1</span>');
}
