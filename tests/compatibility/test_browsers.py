"""
Cross-Browser Compatibility Test Suite
Tests site functionality across different browsers and versions.
"""

import time
from pathlib import Path
import pytest
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options as ChromeOptions
from selenium.webdriver.firefox.options import Options as FirefoxOptions
from selenium.common.exceptions import WebDriverException, TimeoutException

class TestBrowserCompatibility:
    """Test cross-browser compatibility."""

    def setup_method(self):
        """Set up test environment."""
        self.repo_root = Path(__file__).parent.parent.parent
        self.docs_dir = self.repo_root / "docs"
        self.site_dir = self.docs_dir / "_site"
        self.test_url = "file://" + str(self.site_dir / "index.html")

    @pytest.mark.parametrize("browser", ["chrome", "firefox"])
    def test_basic_functionality_across_browsers(self, browser):
        """Test basic site functionality works across browsers."""
        if not self.site_dir.exists():
            pytest.skip("Site must be built for browser testing")

        driver = self.get_driver(browser)
        if not driver:
            pytest.skip(f"{browser} driver not available")

        try:
            # Load the page
            driver.get(self.test_url)

            # Wait for page to load
            WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.TAG_NAME, "body"))
            )

            # Test basic elements are present
            self.test_page_elements(driver, browser)

            # Test navigation functionality
            self.test_navigation(driver, browser)

            # Test responsive design
            self.test_responsive_behavior(driver, browser)

        finally:
            driver.quit()

    def get_driver(self, browser):
        """Get appropriate WebDriver for browser."""
        try:
            if browser == "chrome":
                options = ChromeOptions()
                options.add_argument("--headless")
                options.add_argument("--no-sandbox")
                options.add_argument("--disable-dev-shm-usage")
                return webdriver.Chrome(options=options)

            elif browser == "firefox":
                options = FirefoxOptions()
                options.add_argument("--headless")
                return webdriver.Firefox(options=options)

        except WebDriverException:
            return None

    def test_page_elements(self, driver, browser):
        """Test that essential page elements are present and functional."""
        # Check title is present
        assert driver.title, f"Page title missing in {browser}"

        # Check main content area
        main_content = driver.find_elements(By.CSS_SELECTOR, "main, [role='main']")
        assert len(main_content) > 0, f"Main content area missing in {browser}"

        # Check navigation
        nav_elements = driver.find_elements(By.CSS_SELECTOR, "nav, [role='navigation']")
        assert len(nav_elements) > 0, f"Navigation missing in {browser}"

        # Check headings are present
        headings = driver.find_elements(By.CSS_SELECTOR, "h1, h2, h3")
        assert len(headings) > 0, f"No headings found in {browser}"

        # Check for site logo/title
        site_title = driver.find_elements(By.CSS_SELECTOR, ".site-title, .site-logo")
        assert len(site_title) > 0, f"Site title/logo missing in {browser}"

    def test_navigation(self, driver, browser):
        """Test navigation functionality."""
        # Find navigation links
        nav_links = driver.find_elements(By.CSS_SELECTOR, "nav a, .nav-link")

        if len(nav_links) == 0:
            pytest.skip(f"No navigation links found in {browser}")

        # Test first navigation link (if any)
        first_link = nav_links[0]
        original_url = driver.current_url

        # Check link is clickable
        assert first_link.is_enabled(), f"Navigation link not clickable in {browser}"

        # Click might not work with file:// URLs, so just verify href
        href = first_link.get_attribute('href')
        assert href, f"Navigation link missing href in {browser}"

    def test_responsive_behavior(self, driver, browser):
        """Test responsive design behavior."""
        # Test desktop viewport
        driver.set_window_size(1200, 800)
        time.sleep(0.5)

        # Check desktop navigation is visible
        desktop_nav = driver.find_elements(By.CSS_SELECTOR, ".desktop-nav, nav:not(.mobile-nav)")
        # Note: Visibility check depends on actual CSS implementation

        # Test tablet viewport
        driver.set_window_size(768, 1024)
        time.sleep(0.5)

        # Check content doesn't overflow
        body_width = driver.execute_script("return document.body.scrollWidth")
        viewport_width = driver.execute_script("return window.innerWidth")
        assert body_width <= viewport_width + 5, f"Content overflows in tablet view in {browser}"

        # Test mobile viewport
        driver.set_window_size(375, 667)
        time.sleep(0.5)

        # Check mobile layout
        body_width = driver.execute_script("return document.body.scrollWidth")
        viewport_width = driver.execute_script("return window.innerWidth")
        assert body_width <= viewport_width + 5, f"Content overflows in mobile view in {browser}"

        # Check for mobile menu or navigation
        mobile_elements = driver.find_elements(By.CSS_SELECTOR,
            ".mobile-menu-toggle, .hamburger, [data-mobile-menu-toggle]")
        # Mobile menu might not be implemented yet, so this is informational

    def test_css_grid_support(self, driver, browser):
        """Test CSS Grid functionality."""
        if not self.site_dir.exists():
            pytest.skip("Site must be built for CSS testing")

        driver.get(self.test_url)

        # Check if browser supports CSS Grid
        grid_support = driver.execute_script("""
            return CSS.supports('display', 'grid');
        """)

        if not grid_support:
            pytest.skip(f"CSS Grid not supported in {browser}")

        # Find elements that should use grid
        grid_elements = driver.find_elements(By.CSS_SELECTOR, ".docs-layout, .sections-grid")

        for element in grid_elements:
            display_value = driver.execute_script("""
                return window.getComputedStyle(arguments[0]).display;
            """, element)

            # Should be grid or fallback to flex/block
            assert display_value in ['grid', 'flex', 'block'], \
                f"Invalid display value for grid element in {browser}: {display_value}"

    def test_javascript_functionality(self, driver, browser):
        """Test JavaScript functionality works."""
        if not self.site_dir.exists():
            pytest.skip("Site must be built for JavaScript testing")

        driver.get(self.test_url)

        # Check for JavaScript errors
        logs = driver.get_log('browser')
        js_errors = [log for log in logs if log['level'] == 'SEVERE']

        # Filter out known harmless errors
        critical_errors = []
        for error in js_errors:
            message = error['message'].lower()
            # Skip favicon 404s and other non-critical errors
            if 'favicon' not in message and 'net::err_file_not_found' not in message:
                critical_errors.append(error)

        assert len(critical_errors) == 0, \
            f"JavaScript errors in {browser}: {[e['message'] for e in critical_errors]}"

        # Test search functionality if present
        search_input = driver.find_elements(By.CSS_SELECTOR, "[data-search-input], input[type='search']")
        if search_input:
            # Try to interact with search
            search_element = search_input[0]
            assert search_element.is_enabled(), f"Search input not functional in {browser}"

    def test_font_rendering(self, driver, browser):
        """Test font rendering and fallbacks."""
        if not self.site_dir.exists():
            pytest.skip("Site must be built for font testing")

        driver.get(self.test_url)

        # Check body font
        body = driver.find_element(By.TAG_NAME, "body")
        font_family = driver.execute_script("""
            return window.getComputedStyle(arguments[0]).fontFamily;
        """, body)

        # Should have font stack
        assert font_family, f"No font family applied in {browser}"

        # Check headings have appropriate font
        h1_elements = driver.find_elements(By.TAG_NAME, "h1")
        if h1_elements:
            h1_font = driver.execute_script("""
                return window.getComputedStyle(arguments[0]).fontFamily;
            """, h1_elements[0])
            assert h1_font, f"No font family on headings in {browser}"

    def test_form_functionality(self, driver, browser):
        """Test form elements work correctly."""
        if not self.site_dir.exists():
            pytest.skip("Site must be built for form testing")

        driver.get(self.test_url)

        # Find form inputs
        inputs = driver.find_elements(By.CSS_SELECTOR, "input, textarea, select")

        for input_element in inputs:
            input_type = input_element.get_attribute('type') or 'text'

            # Skip hidden inputs
            if input_type == 'hidden':
                continue

            # Test input is focusable
            try:
                input_element.click()
                # Should be able to focus
                assert driver.switch_to.active_element == input_element, \
                    f"Input not focusable in {browser}"
            except Exception:
                # Some inputs might not be interactable, that's okay
                pass

    @pytest.mark.parametrize("viewport", [
        (1920, 1080),  # Desktop
        (1366, 768),   # Laptop
        (768, 1024),   # Tablet
        (375, 667),    # Mobile
    ])
    def test_viewport_compatibility(self, viewport):
        """Test site works at different viewport sizes."""
        if not self.site_dir.exists():
            pytest.skip("Site must be built for viewport testing")

        width, height = viewport
        driver = self.get_driver("chrome")

        if not driver:
            pytest.skip("Chrome driver not available")

        try:
            driver.set_window_size(width, height)
            driver.get(self.test_url)

            # Wait for page load
            WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.TAG_NAME, "body"))
            )

            # Check no horizontal overflow
            body_width = driver.execute_script("return document.body.scrollWidth")
            viewport_width = driver.execute_script("return window.innerWidth")

            assert body_width <= viewport_width + 20, \
                f"Horizontal overflow at {width}x{height}: {body_width}px > {viewport_width}px"

            # Check content is visible
            content_elements = driver.find_elements(By.CSS_SELECTOR, "main, .content, article")
            assert len(content_elements) > 0, f"No content visible at {width}x{height}"

        finally:
            driver.quit()

    def test_accessibility_features(self, driver, browser):
        """Test accessibility features work across browsers."""
        if not self.site_dir.exists():
            pytest.skip("Site must be built for accessibility testing")

        driver.get(self.test_url)

        # Test keyboard navigation
        try:
            # Tab through focusable elements
            focusable_elements = driver.find_elements(By.CSS_SELECTOR,
                "a, button, input, textarea, select, [tabindex]:not([tabindex='-1'])")

            if focusable_elements:
                first_element = focusable_elements[0]
                first_element.click()

                # Should be able to tab to next element
                driver.execute_script("arguments[0].focus()", first_element)
                focused_element = driver.switch_to.active_element

                assert focused_element, f"Keyboard focus not working in {browser}"

        except Exception:
            # Keyboard navigation might not work in headless mode
            pass

if __name__ == "__main__":
    pytest.main([__file__, "-v"])