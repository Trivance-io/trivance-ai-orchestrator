"""
Integration test for developer workflow scenario.

Tests the user journey: "Desarrollador busca workflow completo"
Based on quickstart.md Scenario 3 validation requirements.
This test should FAIL until complete documentation structure and content are implemented.
"""

import time
from pathlib import Path
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import TimeoutException, NoSuchElementException
import pytest

class TestDeveloperWorkflowScenario:
    """Integration test for developer workflow user scenario."""

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
        chrome_options.add_argument("--window-size=1920,1080")

        try:
            self.driver = webdriver.Chrome(options=chrome_options)
        except Exception:
            pytest.skip("Chrome WebDriver not available")

    def teardown_method(self):
        """Clean up test environment."""
        if hasattr(self, 'driver'):
            self.driver.quit()

    def test_landing_page_purpose_explanation(self):
        """
        Test: Landing page explica propósito claramente
        Verify the landing page clearly explains the documentation purpose.
        """
        # FAIL: Landing page content must be implemented
        index_file = self.site_dir / "index.html"
        if not index_file.exists():
            assert False, "Documentation site must be built (index.html missing)"

        self.driver.get(f"file://{index_file.absolute()}")

        # Wait for page to load
        WebDriverWait(self.driver, 5).until(
            EC.presence_of_element_located((By.TAG_NAME, "body"))
        )

        # Check for clear purpose explanation
        page_content = self.driver.find_element(By.TAG_NAME, "body").text.lower()

        # Should contain key purpose indicators
        purpose_indicators = [
            "claude code",
            "documentación",
            "comandos",
            "agentes",
            "workflow",
            "ai-first"
        ]

        found_indicators = [indicator for indicator in purpose_indicators if indicator in page_content]
        assert len(found_indicators) >= 3, \
            f"Landing page must clearly explain purpose. Found: {found_indicators}"

        # Check for descriptive headings
        headings = self.driver.find_elements(By.CSS_SELECTOR, "h1, h2")
        assert len(headings) > 0, "Landing page must have descriptive headings"

        main_heading = headings[0].text.lower()
        assert any(keyword in main_heading for keyword in ["documentación", "claude", "guía"]), \
            "Main heading must clearly indicate documentation purpose"

    def test_intuitive_category_navigation(self):
        """
        Test: Navegación por categorías intuitiva
        Verify navigation by categories is intuitive and functional.
        """
        # FAIL: Category navigation must be implemented
        index_file = self.site_dir / "index.html"
        self.driver.get(f"file://{index_file.absolute()}")

        # Look for category navigation
        category_selectors = [
            "nav a",
            ".nav-categories a",
            "[data-category]",
            ".category-link",
            ".section-nav a"
        ]

        category_links = []
        for selector in category_selectors:
            links = self.driver.find_elements(By.CSS_SELECTOR, selector)
            category_links.extend(links)

        assert len(category_links) > 0, "Category navigation links must exist"

        # Check for expected documentation categories
        expected_categories = ["comandos", "agentes", "workflows", "prácticas"]
        link_texts = [link.text.lower() for link in category_links]

        found_categories = []
        for category in expected_categories:
            if any(category in text for text in link_texts):
                found_categories.append(category)

        assert len(found_categories) >= 2, \
            f"Must have intuitive category navigation. Found: {found_categories}"

    def test_workflows_section_discovery(self):
        """
        Test: Encuentra sección "Workflows"
        Verify developer can find and access the Workflows section.
        """
        # FAIL: Workflows section must be accessible
        index_file = self.site_dir / "index.html"
        self.driver.get(f"file://{index_file.absolute()}")

        # Look for Workflows navigation
        workflow_selectors = [
            "a[href*='workflow']",
            "a[href*='flujo']",
            "[data-category='workflows']",
            "nav a:contains('Workflows')",
            "a[title*='workflow' i]"
        ]

        workflow_link = None
        for selector in workflow_selectors:
            try:
                links = self.driver.find_elements(By.CSS_SELECTOR, selector)
                if links:
                    workflow_link = links[0]
                    break
            except:
                continue

        # Alternative: check if any link text mentions workflows
        if not workflow_link:
            all_links = self.driver.find_elements(By.CSS_SELECTOR, "a")
            for link in all_links:
                if 'workflow' in link.text.lower() or 'flujo' in link.text.lower():
                    workflow_link = link
                    break

        assert workflow_link is not None, "Workflows section must be discoverable"
        assert workflow_link.is_displayed(), "Workflows link must be visible"

        # Test navigation to workflows section
        original_url = self.driver.current_url
        workflow_link.click()

        # Wait for navigation
        try:
            WebDriverWait(self.driver, 3).until(
                lambda driver: driver.current_url != original_url
            )
        except TimeoutException:
            # Maybe it's an anchor link on the same page
            pass

        # Verify workflows content is now visible
        page_content = self.driver.find_element(By.TAG_NAME, "body").text.lower()
        workflow_indicators = ['workflow', 'flujo', 'proceso', 'ai-first']

        assert any(indicator in page_content for indicator in workflow_indicators), \
            "Workflows section must contain workflow-related content"

    def test_content_format_preservation(self):
        """
        Test: Contenido preserva formato original (código, listas)
        Verify content preserves original formatting from markdown.
        """
        # FAIL: Content formatting must be preserved
        index_file = self.site_dir / "index.html"
        self.driver.get(f"file://{index_file.absolute()}")

        # Navigate to a content page (try to find any documentation page)
        content_links = self.driver.find_elements(By.CSS_SELECTOR,
            "a[href*='commands'], a[href*='agents'], a[href*='workflow']")

        if content_links:
            content_links[0].click()
            WebDriverWait(self.driver, 3).until(
                EC.presence_of_element_located((By.TAG_NAME, "body"))
            )

        # Check for code blocks
        code_blocks = self.driver.find_elements(By.CSS_SELECTOR, "code, pre, .highlight")
        if len(code_blocks) > 0:
            # Verify code formatting
            for code_block in code_blocks[:3]:
                styles = self.driver.execute_script(
                    "return window.getComputedStyle(arguments[0])", code_block
                )
                font_family = styles['font-family'].lower()
                assert 'mono' in font_family or 'courier' in font_family or 'consolas' in font_family, \
                    "Code blocks must use monospace fonts"

        # Check for lists
        lists = self.driver.find_elements(By.CSS_SELECTOR, "ul, ol")
        assert len(lists) > 0, "Documentation must contain formatted lists"

        # Check for headings structure
        headings = self.driver.find_elements(By.CSS_SELECTOR, "h1, h2, h3, h4")
        assert len(headings) > 0, "Documentation must have structured headings"

        # Verify proper list formatting
        list_items = self.driver.find_elements(By.CSS_SELECTOR, "li")
        if list_items:
            first_item = list_items[0]
            margin_left = self.driver.execute_script(
                "return window.getComputedStyle(arguments[0]).marginLeft", first_item
            )
            # Should have some indentation
            assert margin_left != "0px", "List items must be properly indented"

    def test_internal_links_functionality(self):
        """
        Test: Enlaces internos funcionan correctamente
        Verify all internal links work correctly without 404s.
        """
        # FAIL: Internal linking must be implemented
        index_file = self.site_dir / "index.html"
        self.driver.get(f"file://{index_file.absolute()}")

        # Find all internal links
        all_links = self.driver.find_elements(By.CSS_SELECTOR, "a[href]")
        internal_links = []

        base_url = self.driver.current_url
        base_domain = base_url.split('/')[2] if '://' in base_url else ''

        for link in all_links:
            href = link.get_attribute('href')
            if href:
                # Check if link is internal (relative or same domain)
                if (href.startswith('/') or
                    href.startswith('./') or
                    href.startswith('../') or
                    (base_domain and base_domain in href) or
                    href.startswith('#')):
                    internal_links.append((link, href))

        assert len(internal_links) > 0, "Documentation must have internal links"

        # Test a sample of internal links
        working_links = 0
        for link, href in internal_links[:5]:  # Test first 5 internal links
            try:
                # Skip anchor links for now
                if href.startswith('#'):
                    continue

                original_url = self.driver.current_url
                link.click()

                # Wait for navigation or page change
                time.sleep(1)

                # Check if we get a valid page (not 404)
                page_source = self.driver.page_source.lower()
                not_found_indicators = ['404', 'not found', 'page not found']

                if not any(indicator in page_source for indicator in not_found_indicators):
                    working_links += 1

                # Go back to original page
                self.driver.back()
                WebDriverWait(self.driver, 2).until(
                    EC.presence_of_element_located((By.TAG_NAME, "body"))
                )

            except Exception as e:
                print(f"Link test failed for {href}: {e}")

        assert working_links > 0, "At least some internal links must work correctly"

    def test_complete_developer_workflow_validation(self):
        """
        Validate the complete developer workflow scenario from quickstart.md:

        Given: Desarrollador nuevo necesita entender AI-first workflow
        When: Explora la documentación
        Then:
        1. ✅ Landing page explica propósito claramente
        2. ✅ Navegación por categorías intuitiva
        3. ✅ Encuentra sección "Workflows"
        4. ✅ Contenido preserva formato original (código, listas)
        5. ✅ Enlaces internos funcionan correctamente
        """
        # FAIL: Complete developer experience must work end-to-end
        index_file = self.site_dir / "index.html"
        self.driver.get(f"file://{index_file.absolute()}")

        # Wait for page load
        WebDriverWait(self.driver, 5).until(
            EC.presence_of_element_located((By.TAG_NAME, "body"))
        )

        # 1. Test landing page purpose clarity
        page_content = self.driver.find_element(By.TAG_NAME, "body").text.lower()
        purpose_indicators = ["claude code", "documentación", "comandos", "agentes"]
        purpose_clear = sum(1 for indicator in purpose_indicators if indicator in page_content) >= 2

        # 2. Test category navigation
        nav_links = self.driver.find_elements(By.CSS_SELECTOR, "nav a, .nav-link, .category-link")
        categories_intuitive = len(nav_links) > 0

        # 3. Test workflow section accessibility
        workflow_accessible = False
        for link in nav_links:
            if 'workflow' in link.text.lower() or 'flujo' in link.text.lower():
                workflow_accessible = True
                # Test navigation
                link.click()
                WebDriverWait(self.driver, 2).until(
                    EC.presence_of_element_located((By.TAG_NAME, "body"))
                )
                break

        # 4. Test content formatting preservation
        code_blocks = self.driver.find_elements(By.CSS_SELECTOR, "code, pre")
        lists = self.driver.find_elements(By.CSS_SELECTOR, "ul, ol")
        headings = self.driver.find_elements(By.CSS_SELECTOR, "h1, h2, h3")
        format_preserved = len(code_blocks) > 0 or len(lists) > 0 or len(headings) > 0

        # 5. Test internal links functionality
        internal_links = self.driver.find_elements(By.CSS_SELECTOR, "a[href^='/'], a[href^='./']")
        links_functional = len(internal_links) > 0

        # Comprehensive assertions
        assert purpose_clear, "✅ Landing page must clearly explain purpose"
        assert categories_intuitive, "✅ Category navigation must be intuitive"
        assert workflow_accessible, "✅ Workflows section must be accessible"
        assert format_preserved, "✅ Content formatting must be preserved"
        assert links_functional, "✅ Internal links must be functional"

        print("🎉 Complete developer workflow scenario PASSED!")

    def test_ai_first_workflow_content_specific(self):
        """Test specific content about AI-first workflow is present and accessible."""
        # FAIL: AI-first workflow content must be implemented
        index_file = self.site_dir / "index.html"
        self.driver.get(f"file://{index_file.absolute()}")

        # Look for AI-first workflow specific content
        page_content = self.driver.find_element(By.TAG_NAME, "body").text.lower()

        # Navigate through different sections to find AI-first content
        all_links = self.driver.find_elements(By.CSS_SELECTOR, "a")
        ai_content_found = False

        for link in all_links[:10]:  # Check first 10 links
            try:
                if any(keyword in link.text.lower() for keyword in ['ai', 'workflow', 'flujo']):
                    link.click()
                    WebDriverWait(self.driver, 2).until(
                        EC.presence_of_element_located((By.TAG_NAME, "body"))
                    )

                    current_content = self.driver.find_element(By.TAG_NAME, "body").text.lower()
                    ai_indicators = ['ai-first', 'inteligencia artificial', 'workflow', 'claude']

                    if sum(1 for indicator in ai_indicators if indicator in current_content) >= 2:
                        ai_content_found = True
                        break

                    self.driver.back()
                    WebDriverWait(self.driver, 2).until(
                        EC.presence_of_element_located((By.TAG_NAME, "body"))
                    )
            except:
                continue

        assert ai_content_found, "Documentation must contain specific AI-first workflow content"

    def test_developer_onboarding_completeness(self):
        """Test that documentation provides complete developer onboarding."""
        # FAIL: Complete onboarding content must be available
        index_file = self.site_dir / "index.html"
        self.driver.get(f"file://{index_file.absolute()}")

        # Check for essential developer information
        essential_sections = [
            "quickstart",
            "commands",
            "agents",
            "examples",
            "getting started"
        ]

        page_content = self.driver.find_element(By.TAG_NAME, "body").text.lower()
        all_links = self.driver.find_elements(By.CSS_SELECTOR, "a")
        link_texts = [link.text.lower() for link in all_links]

        sections_found = []
        for section in essential_sections:
            if (section in page_content or
                any(section in text for text in link_texts)):
                sections_found.append(section)

        assert len(sections_found) >= 3, \
            f"Documentation must provide comprehensive onboarding. Found: {sections_found}"

if __name__ == "__main__":
    pytest.main([__file__, "-v"])