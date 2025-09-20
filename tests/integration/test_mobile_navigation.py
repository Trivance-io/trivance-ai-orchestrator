"""
Integration test for mobile navigation scenario.

Tests the user journey: "Usuario navega desde móvil"
Based on quickstart.md Scenario 2 validation requirements.
This test should FAIL until the complete mobile responsive design is implemented.
"""

import time
from pathlib import Path
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.action_chains import ActionChains
from selenium.common.exceptions import TimeoutException
import pytest

class TestMobileNavigationScenario:
    """Integration test for mobile navigation user scenario."""

    def setup_method(self):
        """Set up mobile test environment."""
        self.repo_root = Path(__file__).parent.parent.parent
        self.docs_dir = self.repo_root / "docs"
        self.site_dir = self.docs_dir / "_site"

        # Set up Chrome for mobile testing
        chrome_options = Options()
        chrome_options.add_argument("--headless")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")

        # Mobile device emulation
        mobile_emulation = {
            "deviceMetrics": {"width": 375, "height": 667, "pixelRatio": 2.0},
            "userAgent": "Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605.1.15"
        }
        chrome_options.add_experimental_option("mobileEmulation", mobile_emulation)

        try:
            self.driver = webdriver.Chrome(options=chrome_options)
        except Exception:
            pytest.skip("Chrome WebDriver not available")

    def teardown_method(self):
        """Clean up test environment."""
        if hasattr(self, 'driver'):
            self.driver.quit()

    def test_mobile_responsive_layout_adaptation(self):
        """
        Test: Layout responsive se adapta automáticamente
        Verify the layout automatically adapts to mobile viewport.
        """
        # FAIL: Responsive design must be implemented
        index_file = self.site_dir / "index.html"
        if not index_file.exists():
            assert False, "Documentation site must be built (index.html missing)"

        self.driver.get(f"file://{index_file.absolute()}")

        # Wait for page to load
        WebDriverWait(self.driver, 5).until(
            EC.presence_of_element_located((By.TAG_NAME, "body"))
        )

        # Check viewport meta tag exists for responsive design
        viewport_meta = self.driver.find_elements(By.CSS_SELECTOR, "meta[name='viewport']")
        assert len(viewport_meta) > 0, "Viewport meta tag must exist for responsive design"

        # Check that content doesn't overflow horizontally
        body_width = self.driver.execute_script("return document.body.scrollWidth")
        viewport_width = self.driver.execute_script("return window.innerWidth")

        assert body_width <= viewport_width, \
            f"Content must not overflow: body width {body_width}px > viewport {viewport_width}px"

    def test_mobile_hamburger_menu_functionality(self):
        """
        Test: Menú hamburger funcional en mobile
        Verify hamburger menu exists and functions properly on mobile.
        """
        # FAIL: Hamburger menu must be implemented
        index_file = self.site_dir / "index.html"
        self.driver.get(f"file://{index_file.absolute()}")

        # Look for hamburger menu
        hamburger_selectors = [
            "[data-mobile-menu-toggle]",
            ".hamburger",
            ".menu-toggle",
            ".mobile-menu-button",
            "button[aria-label*='menu' i]"
        ]

        hamburger = None
        for selector in hamburger_selectors:
            elements = self.driver.find_elements(By.CSS_SELECTOR, selector)
            if elements:
                hamburger = elements[0]
                break

        assert hamburger is not None, "Hamburger menu button must exist on mobile"
        assert hamburger.is_displayed(), "Hamburger menu must be visible on mobile"

        # Test hamburger menu toggle functionality
        # Check if menu is initially hidden
        mobile_nav = self.driver.find_elements(By.CSS_SELECTOR,
            ".mobile-nav, [data-mobile-nav], .nav-menu.mobile")

        if mobile_nav:
            initial_state = mobile_nav[0].is_displayed()

            # Click hamburger to toggle
            hamburger.click()
            time.sleep(0.3)  # Animation time

            final_state = mobile_nav[0].is_displayed()
            assert initial_state != final_state, "Hamburger menu must toggle navigation visibility"

    def test_mobile_text_readability_without_zoom(self):
        """
        Test: Texto legible sin zoom
        Verify text is readable without requiring zoom on mobile.
        """
        # FAIL: Mobile typography must be implemented
        index_file = self.site_dir / "index.html"
        self.driver.get(f"file://{index_file.absolute()}")

        # Check main content text elements
        text_selectors = ["p", "h1", "h2", "h3", "li", ".content", "main"]

        for selector in text_selectors:
            elements = self.driver.find_elements(By.CSS_SELECTOR, selector)
            for element in elements[:3]:  # Check first few elements
                if element.text.strip():  # Has text content
                    font_size = self.driver.execute_script(
                        "return window.getComputedStyle(arguments[0]).fontSize", element
                    )
                    font_size_px = int(font_size.replace('px', ''))

                    # Mobile text should be at least 16px for readability
                    assert font_size_px >= 16, \
                        f"Text must be ≥16px for mobile readability, found {font_size_px}px in {selector}"

    def test_mobile_touch_targets_size(self):
        """
        Test: Enlaces y botones tocables (44px mínimo)
        Verify touch targets meet minimum 44px size requirement.
        """
        # FAIL: Touch-friendly sizing must be implemented
        index_file = self.site_dir / "index.html"
        self.driver.get(f"file://{index_file.absolute()}")

        # Check interactive elements
        interactive_selectors = ["a", "button", "input", "[role='button']", "[data-action]"]

        for selector in interactive_selectors:
            elements = self.driver.find_elements(By.CSS_SELECTOR, selector)
            for element in elements[:5]:  # Check first few elements
                if element.is_displayed():
                    size = element.size
                    location = element.location

                    # Touch targets should be at least 44px x 44px
                    min_touch_size = 44

                    assert size['height'] >= min_touch_size or size['width'] >= min_touch_size, \
                        f"Touch target {selector} must be ≥44px: found {size['width']}x{size['height']}px"

    def test_mobile_navigation_between_sections(self):
        """
        Test: Navegación fluida entre secciones
        Verify smooth navigation between different documentation sections.
        """
        # FAIL: Section navigation must be implemented
        index_file = self.site_dir / "index.html"
        self.driver.get(f"file://{index_file.absolute()}")

        # Look for navigation links to different sections
        section_links = self.driver.find_elements(By.CSS_SELECTOR,
            "a[href*='commands'], a[href*='agents'], a[href*='workflows'], nav a, .nav-link")

        assert len(section_links) > 0, "Navigation links to sections must exist"

        # Test navigation to different section
        if section_links:
            first_link = section_links[0]
            original_url = self.driver.current_url

            # Click navigation link
            self.driver.execute_script("arguments[0].click();", first_link)

            # Wait for navigation
            WebDriverWait(self.driver, 3).until(
                lambda driver: driver.current_url != original_url
            )

            new_url = self.driver.current_url
            assert new_url != original_url, "Navigation must change URL when section link is clicked"

            # Verify new page loads properly
            WebDriverWait(self.driver, 3).until(
                EC.presence_of_element_located((By.TAG_NAME, "body"))
            )

    def test_mobile_viewport_breakpoints(self):
        """
        Test different mobile viewport sizes and breakpoints.
        """
        # FAIL: Responsive breakpoints must be implemented
        index_file = self.site_dir / "index.html"

        # Test multiple mobile viewports
        mobile_sizes = [
            (320, 568),  # iPhone 5/SE
            (375, 667),  # iPhone 6/7/8
            (414, 896),  # iPhone XR/11
            (768, 1024)  # iPad Portrait
        ]

        for width, height in mobile_sizes:
            self.driver.set_window_size(width, height)
            self.driver.get(f"file://{index_file.absolute()}")

            # Check no horizontal overflow
            body_scroll_width = self.driver.execute_script("return document.body.scrollWidth")
            viewport_width = self.driver.execute_script("return window.innerWidth")

            assert body_scroll_width <= viewport_width, \
                f"Content overflows at {width}x{height}: {body_scroll_width}px > {viewport_width}px"

            # Check navigation is accessible
            nav_visible = len(self.driver.find_elements(By.CSS_SELECTOR, "nav:not([hidden])")) > 0
            hamburger_visible = len(self.driver.find_elements(By.CSS_SELECTOR,
                "[data-mobile-menu-toggle], .hamburger, .menu-toggle")) > 0

            assert nav_visible or hamburger_visible, \
                f"Navigation must be accessible at {width}x{height}px"

    def test_complete_mobile_scenario_validation(self):
        """
        Validate the complete mobile navigation scenario from quickstart.md:

        Given: Usuario en dispositivo móvil necesita consultar agentes
        When: Accede al sitio web
        Then:
        1. ✅ Layout responsive se adapta automáticamente
        2. ✅ Menú hamburger funcional en mobile
        3. ✅ Texto legible sin zoom
        4. ✅ Enlaces y botones tocables (44px mínimo)
        5. ✅ Navegación fluida entre secciones
        """
        # FAIL: Complete mobile experience must work end-to-end
        index_file = self.site_dir / "index.html"
        self.driver.get(f"file://{index_file.absolute()}")

        # Wait for page load
        WebDriverWait(self.driver, 5).until(
            EC.presence_of_element_located((By.TAG_NAME, "body"))
        )

        # 1. Test responsive layout adaptation
        viewport_width = self.driver.execute_script("return window.innerWidth")
        body_width = self.driver.execute_script("return document.body.scrollWidth")
        responsive_ok = body_width <= viewport_width

        # 2. Test hamburger menu functionality
        hamburger = self.driver.find_elements(By.CSS_SELECTOR,
            "[data-mobile-menu-toggle], .hamburger, .menu-toggle")
        hamburger_ok = len(hamburger) > 0 and hamburger[0].is_displayed()

        # 3. Test text readability
        main_text = self.driver.find_elements(By.CSS_SELECTOR, "h1, h2, p")
        text_readable = True
        if main_text:
            font_size = self.driver.execute_script(
                "return window.getComputedStyle(arguments[0]).fontSize", main_text[0]
            )
            font_size_px = int(font_size.replace('px', ''))
            text_readable = font_size_px >= 16

        # 4. Test touch target sizes
        links = self.driver.find_elements(By.CSS_SELECTOR, "a, button")
        touch_targets_ok = True
        for link in links[:3]:
            if link.is_displayed():
                size = link.size
                if size['height'] < 44 and size['width'] < 44:
                    touch_targets_ok = False
                    break

        # 5. Test navigation fluidity
        nav_links = self.driver.find_elements(By.CSS_SELECTOR, "nav a, .nav-link")
        navigation_ok = len(nav_links) > 0

        # Comprehensive assertions
        assert responsive_ok, "✅ Layout must be responsive"
        assert hamburger_ok, "✅ Hamburger menu must be functional"
        assert text_readable, "✅ Text must be readable without zoom"
        assert touch_targets_ok, "✅ Touch targets must be ≥44px"
        assert navigation_ok, "✅ Navigation between sections must exist"

        print("🎉 Complete mobile navigation scenario PASSED!")

    def test_mobile_performance_requirements(self):
        """Test mobile-specific performance requirements."""
        # FAIL: Mobile performance must meet standards
        index_file = self.site_dir / "index.html"

        start_time = time.time()
        self.driver.get(f"file://{index_file.absolute()}")

        # Wait for complete page load
        WebDriverWait(self.driver, 5).until(
            EC.presence_of_element_located((By.TAG_NAME, "body"))
        )

        load_time = time.time() - start_time

        # Mobile should still load quickly
        assert load_time < 4.0, f"Mobile page load must be <4s, took {load_time:.2f}s"

        # Check that images are optimized/lazy loaded
        images = self.driver.find_elements(By.CSS_SELECTOR, "img")
        for img in images:
            # Should have loading attribute or be reasonably sized
            loading_attr = img.get_attribute("loading")
            width = img.size['width']

            # Either lazy loading or reasonable mobile size
            mobile_optimized = loading_attr == "lazy" or width <= 400

            if not mobile_optimized:
                print(f"Warning: Image may not be mobile optimized: {img.get_attribute('src')}")

if __name__ == "__main__":
    pytest.main([__file__, "-v"])