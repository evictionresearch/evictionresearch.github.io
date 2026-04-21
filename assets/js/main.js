/**
* Template Name: UpConstruction
* Template URL: https://bootstrapmade.com/upconstruction-bootstrap-construction-website-template/
* Updated: Jun 29 2024 with Bootstrap v5.3.3
* Author: BootstrapMade.com
* License: https://bootstrapmade.com/license/
*/

(function() {
  "use strict";

  /**
   * Apply .scrolled class to the body as the page is scrolled down
   */
  function toggleScrolled() {
    const selectBody = document.querySelector('body');
    const selectHeader = document.querySelector('#header');
    if (!selectHeader.classList.contains('scroll-up-sticky') && !selectHeader.classList.contains('sticky-top') && !selectHeader.classList.contains('fixed-top')) return;
    window.scrollY > 100 ? selectBody.classList.add('scrolled') : selectBody.classList.remove('scrolled');
  }

  document.addEventListener('scroll', toggleScrolled);
  window.addEventListener('load', toggleScrolled);

  /**
   * Mobile nav toggle
   * Updated 2026-04-21: toggles aria-expanded for a11y; supports Escape to close.
   */
  const mobileNavToggleBtn = document.querySelector('.mobile-nav-toggle');

  function mobileNavToogle() {
    const body = document.querySelector('body');
    body.classList.toggle('mobile-nav-active');
    if (mobileNavToggleBtn) {
      mobileNavToggleBtn.classList.toggle('bi-list');
      mobileNavToggleBtn.classList.toggle('bi-x');
      const isOpen = body.classList.contains('mobile-nav-active');
      mobileNavToggleBtn.setAttribute('aria-expanded', String(isOpen));
    }
  }
  if (mobileNavToggleBtn) {
    mobileNavToggleBtn.addEventListener('click', mobileNavToogle);
    // Close mobile nav on Escape
    document.addEventListener('keydown', function(e) {
      if (e.key === 'Escape' && document.querySelector('.mobile-nav-active')) {
        mobileNavToogle();
        mobileNavToggleBtn.focus();
      }
    });
  }

  /**
   * Hide mobile nav on same-page/hash links
   */
  document.querySelectorAll('#navmenu a').forEach(navmenu => {
    navmenu.addEventListener('click', () => {
      if (document.querySelector('.mobile-nav-active')) {
        mobileNavToogle();
      }
    });

  });

  /**
   * Toggle mobile nav dropdowns
   * Updated 2026-04-21: syncs aria-expanded on the parent <a>.
   */
  document.querySelectorAll('.navmenu .toggle-dropdown').forEach(navmenu => {
    navmenu.addEventListener('click', function(e) {
      e.preventDefault();
      const parentA = this.parentNode;          // <a>
      parentA.classList.toggle('active');
      if (parentA.nextElementSibling) {
        parentA.nextElementSibling.classList.toggle('dropdown-active');
      }
      if (parentA && parentA.hasAttribute('aria-expanded')) {
        const expanded = parentA.getAttribute('aria-expanded') === 'true';
        parentA.setAttribute('aria-expanded', String(!expanded));
      }
      e.stopImmediatePropagation();
    });
  });

  /**
   * Preloader
   */
  const preloader = document.querySelector('#preloader');
  if (preloader) {
    window.addEventListener('load', () => {
      preloader.remove();
    });
  }

  /**
   * Scroll top button
   */
  let scrollTop = document.querySelector('.scroll-top');

  function toggleScrollTop() {
    if (scrollTop) {
      window.scrollY > 100 ? scrollTop.classList.add('active') : scrollTop.classList.remove('active');
    }
  }
  scrollTop.addEventListener('click', (e) => {
    e.preventDefault();
    window.scrollTo({
      top: 0,
      behavior: 'smooth'
    });
  });

  window.addEventListener('load', toggleScrollTop);
  document.addEventListener('scroll', toggleScrollTop);

  /**
   * Animation on scroll function and init (only when AOS is loaded)
   * 2026-04-20: Added typeof guard so pages that don't load AOS don't throw.
   */
  function aosInit() {
    if (typeof AOS === 'undefined') return;
    AOS.init({
      duration: 600,
      easing: 'ease-in-out',
      once: true,
      mirror: false
    });
  }
  window.addEventListener('load', aosInit);

  /**
   * Initiate glightbox (only when script loaded and .glightbox elements exist)
   * 2026-04-20: Added presence guards (ported from CiDR main.js).
   */
  if (typeof GLightbox !== 'undefined' && document.querySelectorAll('.glightbox').length > 0) {
    GLightbox({ selector: '.glightbox' });
  }

  /**
   * Init isotope layout and filters (only when scripts loaded and .isotope-layout exists)
   * 2026-04-20: Added typeof guards so pages that don't load Isotope/imagesLoaded don't throw.
   */
  if (typeof Isotope !== 'undefined' && typeof imagesLoaded !== 'undefined') {
    document.querySelectorAll('.isotope-layout').forEach(function(isotopeItem) {
      let layout = isotopeItem.getAttribute('data-layout') ?? 'masonry';
      let filter = isotopeItem.getAttribute('data-default-filter') ?? '*';
      let sort = isotopeItem.getAttribute('data-sort') ?? 'original-order';

      let initIsotope;
      imagesLoaded(isotopeItem.querySelector('.isotope-container'), function() {
        initIsotope = new Isotope(isotopeItem.querySelector('.isotope-container'), {
          itemSelector: '.isotope-item',
          layoutMode: layout,
          filter: filter,
          sortBy: sort
        });
      });

      isotopeItem.querySelectorAll('.isotope-filters li').forEach(function(filters) {
        function activate() {
          const active = isotopeItem.querySelector('.isotope-filters .filter-active');
          if (active) {
            active.classList.remove('filter-active');
            if (active.hasAttribute('aria-pressed')) active.setAttribute('aria-pressed', 'false');
          }
          filters.classList.add('filter-active');
          if (filters.hasAttribute('aria-pressed')) filters.setAttribute('aria-pressed', 'true');
          if (initIsotope) {
            initIsotope.arrange({ filter: filters.getAttribute('data-filter') });
          }
          if (typeof aosInit === 'function') aosInit();
        }
        filters.addEventListener('click', activate, false);
        // Keyboard support — Enter or Space activates the filter (since these are <li role="button">)
        filters.addEventListener('keydown', function(e) {
          if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            activate();
          }
        }, false);
      });

    });
  }

  /**
   * Init swiper sliders (only when Swiper loaded and .init-swiper exists)
   */
  function initSwiper() {
    if (typeof Swiper === 'undefined') return;
    document.querySelectorAll(".init-swiper").forEach(function(swiperElement) {
      let configEl = swiperElement.querySelector(".swiper-config");
      if (!configEl) return;
      let config = JSON.parse(configEl.innerHTML.trim());

      if (swiperElement.classList.contains("swiper-tab")) {
        initSwiperWithCustomPagination(swiperElement, config);
      } else {
        new Swiper(swiperElement, config);
      }
    });
  }

  window.addEventListener("load", initSwiper);

  /**
   * Initiate Pure Counter (only when loaded)
   * 2026-04-20: Added typeof guard so pages without PureCounter don't throw.
   */
  if (typeof PureCounter !== 'undefined') {
    new PureCounter();
  }

})();