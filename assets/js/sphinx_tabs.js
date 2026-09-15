// Sphinx Tabs vanilla JS handler for Semantic UI tabs

document.addEventListener('DOMContentLoaded', function() {
  // Find all tab containers
  document.querySelectorAll('.sphinx-tabs').forEach(function(tabGroup) {
    var menuItems = tabGroup.querySelectorAll('.sphinx-menu .item');
    var tabSegments = tabGroup.querySelectorAll('.sphinx-tab.tab.segment');

    menuItems.forEach(function(item, index) {
      item.style.cursor = 'pointer';
      item.addEventListener('click', function(e) {
        e.preventDefault();
        
        // Remove active class from sibling items and segments
        menuItems.forEach(function(mi) { mi.classList.remove('active'); });
        tabSegments.forEach(function(ts) { ts.classList.remove('active'); });

        // Add active class to clicked item and corresponding segment
        item.classList.add('active');
        if (tabSegments[index]) {
          tabSegments[index].classList.add('active');
        }
      });
    });
  });
});