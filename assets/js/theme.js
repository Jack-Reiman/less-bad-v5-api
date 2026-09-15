// Theme interactions: Sphinx Semantic UI tabs, copy-to-clipboard, mobile sidebar, search

document.addEventListener('DOMContentLoaded', () => {
  // 1. Sphinx / Semantic UI Tab Switching
  document.querySelectorAll('.sphinx-tabs').forEach(tabGroup => {
    const menuItems = tabGroup.querySelectorAll('.sphinx-menu .item');
    const tabSegments = tabGroup.querySelectorAll('.sphinx-tab.tab.segment');

    menuItems.forEach((item, index) => {
      item.style.cursor = 'pointer';
      item.addEventListener('click', (e) => {
        e.preventDefault();
        // Deactivate all items and segments in this tabGroup
        menuItems.forEach(mi => mi.classList.remove('active'));
        tabSegments.forEach(ts => ts.classList.remove('active'));

        // Activate clicked item and matching segment
        item.classList.add('active');
        if (tabSegments[index]) {
          tabSegments[index].classList.add('active');
        }
      });
    });
  });

  // 2. Code Copy Buttons for Code Tabs and Pre Blocks
  document.querySelectorAll('.sphinx-tab.tab.segment, .rst-content pre:not(.tab pre)').forEach(container => {
    // Avoid double buttons
    if (container.querySelector('.code-copy-btn')) return;

    if (window.getComputedStyle(container).position === 'static') {
      container.style.position = 'relative';
    }

    const btn = document.createElement('button');
    btn.innerHTML = 'Copy';
    btn.className = 'code-copy-btn';
    btn.title = 'Copy code snippet';
    container.appendChild(btn);

    btn.addEventListener('click', (e) => {
      e.stopPropagation();
      const pre = container.querySelector('pre') || container;
      const text = pre.innerText.trim();
      navigator.clipboard.writeText(text).then(() => {
        btn.innerText = '✓ Copied!';
        btn.classList.add('copied');
        setTimeout(() => {
          btn.innerText = 'Copy';
          btn.classList.remove('copied');
        }, 2000);
      }).catch(err => {
        console.error('Clipboard copy failed:', err);
      });
    });
  });

  // 3. Mobile Navigation Toggle (Sphinx wy-nav-top)
  const mobileToggle = document.querySelector('[data-toggle="wy-nav-top"]') || document.querySelector('.wy-nav-top');
  const navSide = document.querySelector('.wy-nav-side');
  const contentWrap = document.querySelector('.wy-nav-content-wrap');

  if (mobileToggle && navSide) {
    mobileToggle.addEventListener('click', (e) => {
      e.stopPropagation();
      navSide.classList.toggle('shift');
      if (contentWrap) contentWrap.classList.toggle('shift');
    });

    document.addEventListener('click', (e) => {
      if (navSide.classList.contains('shift') && !navSide.contains(e.target) && !mobileToggle.contains(e.target)) {
        navSide.classList.remove('shift');
        if (contentWrap) contentWrap.classList.remove('shift');
      }
    });
  }

  // 4. Search Trigger & Shortcut
  const searchInputs = document.querySelectorAll('.search-input, #search-query-input, input[name="q"]');
  searchInputs.forEach(inp => {
    inp.addEventListener('focus', (e) => {
      e.target.blur();
      if (typeof openSearchModal === 'function') {
        openSearchModal();
      }
    });
  });

  document.addEventListener('keydown', (e) => {
    if (e.key === '/' && document.activeElement.tagName !== 'INPUT' && document.activeElement.tagName !== 'TEXTAREA') {
      e.preventDefault();
      if (typeof openSearchModal === 'function') {
        openSearchModal();
      }
    }
    if (e.key === 'Escape') {
      if (typeof closeSearchModal === 'function') {
        closeSearchModal();
      }
    }
  });
});

