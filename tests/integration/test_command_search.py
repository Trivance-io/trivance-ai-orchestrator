"""
Integration test for command search scenario.

Tests the user journey: "Usuario busca comandos específicos"
Based on quickstart.md Scenario 1 validation requirements.
This test should FAIL until the complete search functionality is implemented.
"""

import time
from pathlib import Path
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import TimeoutException
import pytest

class TestCommandSearchScenario:
    """Integration test for command search user scenario."""

    def setup_method(self):
        """Set up test environment."""
        self.repo_root = Path(__file__).parent.parent.parent
        self.docs_dir = self.repo_root / "docs"
        self.site_dir = self.docs_dir / "_site"

        # Set up Chrome for testing
        chrome_options = Options()
        chrome_options.add_argument("--headless")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--window-size=1920,1080")  # Desktop viewport

        try:
            self.driver = webdriver.Chrome(options=chrome_options)
        except Exception:
            pytest.skip("Chrome WebDriver not available")

    def teardown_method(self):
        """Clean up test environment."""
        if hasattr(self, 'driver'):
            self.driver.quit()

    def test_command_search_scenario_complete(self):
        """
        Test complete command search scenario per quickstart.md:

        Given: Usuario necesita información sobre comando '/implement'
        When: Visita el sitio de documentación
        Then:
        1. ✅ Página carga en <3 segundos
        2. ✅ Navegación visible en mobile y desktop
        3. ✅ Busca "/implement" en search box
        4. ✅ Encuentra resultado relevante instantáneamente
        5. ✅ Click lleva a página de comandos con información detallada
        """
        # FAIL EARLY: Site must exist
        index_file = self.site_dir / "index.html"
        if not index_file.exists():
            assert False, "Documentation site must be built (index.html missing)"

        # Step 1: Test page load performance (<3 seconds)
        start_time = time.time()
        self.driver.get(f"file://{index_file.absolute()}")

        # Wait for page to be fully loaded
        WebDriverWait(self.driver, 5).until(
            EC.presence_of_element_located((By.TAG_NAME, "body"))
        )

        load_time = time.time() - start_time
        assert load_time < 3.0, f"Page must load in <3 seconds, took {load_time:.2f}s"

    def test_navigation_visibility_desktop(self):
        """Test that navigation is visible on desktop viewport."""
        # FAIL: Navigation must be implemented
        index_file = self.site_dir / "index.html"
        self.driver.get(f"file://{index_file.absolute()}")

        # Desktop viewport (already set in setup)
        try:
            nav_element = WebDriverWait(self.driver, 2).until(
                EC.visibility_of_element_located((By.CSS_SELECTOR, "nav, [role='navigation']"))
            )
            assert nav_element.is_displayed(), "Navigation must be visible on desktop"
        except TimeoutException:
            assert False, "Navigation element must exist and be visible on desktop"

    def test_navigation_visibility_mobile(self):
        """Test that navigation is visible/accessible on mobile viewport."""
        # FAIL: Mobile navigation must be implemented
        index_file = self.site_dir / "index.html"
        self.driver.set_window_size(375, 667)  # iPhone viewport
        self.driver.get(f"file://{index_file.absolute()}")

        # Either visible nav or hamburger menu
        try:
            # Look for visible navigation
            nav_visible = self.driver.find_elements(By.CSS_SELECTOR, "nav:not([hidden])")

            # Or look for hamburger menu
            hamburger = self.driver.find_elements(By.CSS_SELECTOR,
                "[data-mobile-menu-toggle], .hamburger, .menu-toggle")

            assert len(nav_visible) > 0 or len(hamburger) > 0, \
                "Either navigation or hamburger menu must be visible on mobile"

        except Exception:
            assert False, "Mobile navigation solution must exist"

    def test_search_functionality_implement_command(self):
        """Test searching for '/implement' command returns relevant results."""
        # FAIL: Search functionality must be implemented
        index_file = self.site_dir / "index.html"
        self.driver.get(f"file://{index_file.absolute()}")

        # Find search input
        try:
            search_input = WebDriverWait(self.driver, 2).until(
                EC.presence_of_element_located((By.CSS_SELECTOR,
                    "input[type='search'], [data-search-input], input[placeholder*='buscar' i]"))
            )
        except TimeoutException:
            assert False, "Search input must exist on the page"

        # Type '/implement' in search
        search_input.clear()
        search_input.send_keys("/implement")

        # Wait for search results to appear (instant per spec)
        try:
            search_results = WebDriverWait(self.driver, 1).until(
                EC.presence_of_element_located((By.CSS_SELECTOR,
                    "[data-search-results], .search-results"))
            )
        except TimeoutException:
            assert False, "Search results must appear instantly after typing"

        # Verify results contain relevant information
        result_items = self.driver.find_elements(By.CSS_SELECTOR,
            "[data-search-results] .result-item, .search-results .result")

        assert len(result_items) > 0, "Search for '/implement' must return results"

        # Check that results contain 'implement' or 'command' related content
        relevant_found = False
        for item in result_items:
            text = item.text.lower()
            if 'implement' in text or 'comando' in text:
                relevant_found = True
                break

        assert relevant_found, "Search results must contain relevant content for '/implement'"

    def test_search_result_navigation_to_commands(self):
        """Test that clicking search result navigates to commands page with details."""
        # FAIL: Commands page and navigation must be implemented
        index_file = self.site_dir / "index.html"
        self.driver.get(f"file://{index_file.absolute()}")

        # Perform search
        search_input = self.driver.find_element(By.CSS_SELECTOR,
            "input[type='search'], [data-search-input], input[placeholder*='buscar' i]")
        search_input.send_keys("/implement")

        # Wait for and click first result
        try:
            first_result = WebDriverWait(self.driver, 1).until(
                EC.element_to_be_clickable((By.CSS_SELECTOR,
                    "[data-search-results] .result-item:first-child a, .search-results .result:first-child a"))
            )
            first_result.click()
        except TimeoutException:
            assert False, "Search results must be clickable links"

        # Verify navigation to commands page
        WebDriverWait(self.driver, 3).until(
            lambda driver: 'commands' in driver.current_url or 'comando' in driver.current_url
        )

        # Verify page contains detailed information about implement command
        page_content = self.driver.find_element(By.TAG_NAME, "body").text.lower()
        assert 'implement' in page_content, "Commands page must contain information about implement command"
        assert any(keyword in page_content for keyword in ['descripción', 'descripcion', 'qué hace', 'que hace']), \
            "Commands page must contain detailed information/descriptions"

    def test_search_performance_instant_results(self):
        """Test that search results appear instantly (<1 second)."""
        # FAIL: Search performance must meet requirements
        index_file = self.site_dir / "index.html"
        self.driver.get(f"file://{index_file.absolute()}")

        search_input = self.driver.find_element(By.CSS_SELECTOR,
            "input[type='search'], [data-search-input], input[placeholder*='buscar' i]")

        # Measure search response time
        start_time = time.time()
        search_input.send_keys("/implement")

        # Results should appear instantly
        try:
            WebDriverWait(self.driver, 1).until(
                EC.presence_of_element_located((By.CSS_SELECTOR,
                    "[data-search-results], .search-results"))
            )
            response_time = time.time() - start_time
            assert response_time < 1.0, f"Search must be instant (<1s), took {response_time:.3f}s"
        except TimeoutException:
            assert False, "Search results must appear within 1 second"

    def test_complete_user_journey_validation(self):
        """
        Validate the complete user journey from quickstart.md validation steps.
        This is the master integration test that combines all steps.
        """
        # FAIL: Complete journey must work end-to-end
        index_file = self.site_dir / "index.html"

        # Step 1: Load and measure performance
        start_time = time.time()
        self.driver.get(f"file://{index_file.absolute()}")
        WebDriverWait(self.driver, 5).until(EC.presence_of_element_located((By.TAG_NAME, "body")))
        load_time = time.time() - start_time

        # Step 2: Verify navigation exists
        nav_exists = len(self.driver.find_elements(By.CSS_SELECTOR, "nav, [role='navigation']")) > 0

        # Step 3: Perform search
        search_input = self.driver.find_element(By.CSS_SELECTOR,
            "input[type='search'], [data-search-input], input[placeholder*='buscar' i]")
        search_input.send_keys("/implement")

        # Step 4: Verify instant results
        search_start = time.time()
        WebDriverWait(self.driver, 1).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, "[data-search-results], .search-results"))
        )
        search_time = time.time() - search_start

        # Step 5: Navigate to detailed page
        first_result = self.driver.find_element(By.CSS_SELECTOR,
            "[data-search-results] .result-item:first-child a, .search-results .result:first-child a")
        first_result.click()

        WebDriverWait(self.driver, 3).until(
            lambda driver: 'commands' in driver.current_url.lower() or 'comando' in driver.current_url.lower()
        )

        # Assertions for complete journey
        assert load_time < 3.0, f"✅ Page load: {load_time:.2f}s < 3s"
        assert nav_exists, "✅ Navigation visible"
        assert search_time < 1.0, f"✅ Search instant: {search_time:.3f}s < 1s"

        page_content = self.driver.find_element(By.TAG_NAME, "body").text.lower()
        assert 'implement' in page_content, "✅ Detailed command information found"

        print("🎉 Complete command search scenario PASSED!")

if __name__ == "__main__":
    # Run this specific test
    pytest.main([__file__, "-v"])