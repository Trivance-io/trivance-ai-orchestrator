"""
Contract tests for client-side search API functionality.

These tests verify that the search functionality meets the contract specifications
defined in contracts/search-api.yml. They should FAIL until implementation is complete.
"""

import json
import os
from pathlib import Path
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
import time
import pytest

class TestSearchAPIContract:
    """Test search API contract compliance."""

    def setup_method(self):
        """Set up test environment."""
        self.repo_root = Path(__file__).parent.parent.parent
        self.docs_dir = self.repo_root / "docs"
        self.site_dir = self.docs_dir / "_site"

        # Set up headless Chrome for testing
        chrome_options = Options()
        chrome_options.add_argument("--headless")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")

        try:
            self.driver = webdriver.Chrome(options=chrome_options)
        except Exception:
            # Skip tests if Chrome driver not available
            pytest.skip("Chrome WebDriver not available")

    def teardown_method(self):
        """Clean up test environment."""
        if hasattr(self, 'driver'):
            self.driver.quit()

    def test_search_index_json_exists(self):
        """Test that search index JSON file exists and has correct structure."""
        # This will FAIL until search index is implemented
        search_index_file = self.site_dir / "_data" / "search.json"
        assert search_index_file.exists(), "Search index JSON must exist at /_data/search.json"

    def test_search_index_schema_compliance(self):
        """Test that search index follows the contract schema."""
        search_index_file = self.site_dir / "_data" / "search.json"

        if not search_index_file.exists():
            assert False, "Search index must exist for schema validation"

        with open(search_index_file, 'r') as f:
            data = json.load(f)

        # Contract schema requirements from search-api.yml
        assert "index" in data, "Search data must have 'index' property"
        assert isinstance(data["index"], list), "Index must be an array"

        if data["index"]:  # If index has entries
            entry = data["index"][0]
            required_fields = ["id", "title", "content", "category", "url"]

            for field in required_fields:
                assert field in entry, f"Index entries must have '{field}' field"

            # Validate field constraints
            assert len(entry["title"]) <= 100, "Title must be ≤100 characters"
            assert len(entry["content"]) <= 500, "Content must be ≤500 characters"
            assert entry["category"] in ["commands", "agents", "workflows", "best-practices"], \
                "Category must be valid enum value"
            assert entry["url"].startswith("/"), "URL must be relative path"

    def test_search_javascript_api_exists(self):
        """Test that search JavaScript file exists."""
        # This will FAIL until search.js is implemented
        search_js_file = self.site_dir / "assets" / "js" / "search.js"
        assert search_js_file.exists(), "search.js must exist at /assets/js/search.js"

    def test_search_function_performance(self):
        """Test that search function meets performance requirements."""
        # This will FAIL until search functionality is implemented
        if not self.site_dir.exists():
            assert False, "Site must be built for search testing"

        # Load the site in browser
        index_file = self.site_dir / "index.html"
        if not index_file.exists():
            assert False, "index.html must exist for search testing"

        self.driver.get(f"file://{index_file.absolute()}")

        # Test search input exists
        try:
            search_input = WebDriverWait(self.driver, 5).until(
                EC.presence_of_element_located((By.CSS_SELECTOR, "[data-search-input]"))
            )
        except:
            assert False, "Search input element must exist with data-search-input attribute"

        # Test search function response time
        start_time = time.time()
        search_input.send_keys("implement")

        # Wait for search results (should appear within 50ms per contract)
        try:
            WebDriverWait(self.driver, 0.1).until(  # 100ms max
                EC.presence_of_element_located((By.CSS_SELECTOR, "[data-search-results]"))
            )
        except:
            assert False, "Search results should appear within 100ms"

        response_time = (time.time() - start_time) * 1000
        assert response_time < 100, f"Search response time {response_time}ms exceeds 100ms limit"

    def test_search_functionality_basic(self):
        """Test basic search functionality works."""
        # This will FAIL until search is implemented
        if not self.site_dir.exists():
            assert False, "Site must be built for search testing"

        index_file = self.site_dir / "index.html"
        self.driver.get(f"file://{index_file.absolute()}")

        # Test search for known term
        search_input = self.driver.find_element(By.CSS_SELECTOR, "[data-search-input]")
        search_input.send_keys("commands")

        # Check results appear
        WebDriverWait(self.driver, 1).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, "[data-search-results] .result-item"))
        )

        results = self.driver.find_elements(By.CSS_SELECTOR, "[data-search-results] .result-item")
        assert len(results) > 0, "Search should return results for 'commands'"

    def test_search_category_filtering(self):
        """Test that category filtering works per contract."""
        # This will FAIL until filtering is implemented
        if not self.site_dir.exists():
            assert False, "Site must be built for filtering testing"

        index_file = self.site_dir / "index.html"
        self.driver.get(f"file://{index_file.absolute()}")

        # Test category filter exists
        try:
            category_filter = self.driver.find_element(By.CSS_SELECTOR, "[data-category-filter]")
        except:
            assert False, "Category filter element must exist"

        # Test filtering by category
        search_input = self.driver.find_element(By.CSS_SELECTOR, "[data-search-input]")
        search_input.send_keys("test")

        # Select commands category
        category_filter.click()
        commands_option = self.driver.find_element(By.CSS_SELECTOR, "[data-category='commands']")
        commands_option.click()

        # Verify filtered results
        WebDriverWait(self.driver, 1).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, "[data-search-results]"))
        )

        results = self.driver.find_elements(By.CSS_SELECTOR, "[data-search-results] .result-item")
        for result in results:
            category_element = result.find_element(By.CSS_SELECTOR, "[data-result-category]")
            assert category_element.text == "commands", "Filtered results should only show selected category"

    def test_search_accessibility_compliance(self):
        """Test that search meets accessibility requirements."""
        # This will FAIL until accessibility is implemented
        if not self.site_dir.exists():
            assert False, "Site must be built for accessibility testing"

        index_file = self.site_dir / "index.html"
        self.driver.get(f"file://{index_file.absolute()}")

        # Test ARIA labels exist
        search_input = self.driver.find_element(By.CSS_SELECTOR, "[data-search-input]")
        assert search_input.get_attribute("aria-label"), "Search input must have aria-label"

        # Test search results have live region
        search_results = self.driver.find_element(By.CSS_SELECTOR, "[data-search-results]")
        assert search_results.get_attribute("aria-live"), "Search results must have aria-live attribute"

        # Test keyboard navigation
        search_input.send_keys("test")
        search_input.send_keys(Keys.ARROW_DOWN)  # Should navigate to first result

        active_element = self.driver.switch_to.active_element
        assert "result-item" in active_element.get_attribute("class"), \
            "Arrow keys should navigate to search results"

    def test_search_browser_compatibility(self):
        """Test that search works in specified browsers."""
        # This will FAIL until cross-browser compatibility is ensured
        if not self.site_dir.exists():
            assert False, "Site must be built for browser testing"

        index_file = self.site_dir / "index.html"
        self.driver.get(f"file://{index_file.absolute()}")

        # Test that search JavaScript loads without errors
        js_errors = self.driver.get_log('browser')
        js_errors = [error for error in js_errors if error['level'] == 'SEVERE']
        assert len(js_errors) == 0, f"No JavaScript errors should occur: {js_errors}"

        # Test basic search functionality
        search_input = self.driver.find_element(By.CSS_SELECTOR, "[data-search-input]")
        assert search_input.is_enabled(), "Search input should be functional"

    def test_search_index_size_limit(self):
        """Test that search index meets size constraints."""
        search_index_file = self.site_dir / "_data" / "search.json"

        if not search_index_file.exists():
            assert False, "Search index must exist for size testing"

        file_size = search_index_file.stat().st_size
        max_size = 50 * 1024  # 50KB limit from contract

        assert file_size <= max_size, \
            f"Search index size {file_size} bytes exceeds {max_size} bytes limit"