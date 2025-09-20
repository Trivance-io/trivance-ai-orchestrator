"""
HTML Validation and Link Checking Test Suite
Validates HTML structure and checks that all links work correctly.
"""

import re
import requests
from pathlib import Path
from urllib.parse import urljoin, urlparse
import pytest
from bs4 import BeautifulSoup
import subprocess
import time

class TestHTMLValidation:
    """Test HTML validation and link checking."""

    def setup_method(self):
        """Set up test environment."""
        self.repo_root = Path(__file__).parent.parent.parent
        self.docs_dir = self.repo_root / "docs"
        self.site_dir = self.docs_dir / "_site"
        self.base_url = "http://localhost:8084"

    def test_html_structure_validity(self):
        """Test that all HTML pages have valid structure."""
        if not self.site_dir.exists():
            pytest.skip("Site must be built for HTML validation")

        html_files = list(self.site_dir.rglob("*.html"))
        assert len(html_files) > 0, "No HTML files found in built site"

        for html_file in html_files:
            self.validate_html_file(html_file)

    def validate_html_file(self, html_file):
        """Validate individual HTML file structure."""
        content = html_file.read_text(encoding='utf-8')
        soup = BeautifulSoup(content, 'html.parser')

        # Check basic HTML structure
        assert soup.find('html'), f"Missing <html> tag in {html_file.name}"
        assert soup.find('head'), f"Missing <head> tag in {html_file.name}"
        assert soup.find('body'), f"Missing <body> tag in {html_file.name}"

        # Check for DOCTYPE
        assert content.strip().startswith('<!DOCTYPE'), f"Missing DOCTYPE in {html_file.name}"

        # Check for title tag
        title = soup.find('title')
        assert title and title.get_text().strip(), f"Missing or empty title in {html_file.name}"

        # Check for meta viewport (responsive design)
        viewport = soup.find('meta', attrs={'name': 'viewport'})
        assert viewport, f"Missing viewport meta tag in {html_file.name}"

        # Check for meta description (SEO)
        description = soup.find('meta', attrs={'name': 'description'})
        if not description:
            # Allow og:description as alternative
            og_description = soup.find('meta', attrs={'property': 'og:description'})
            assert og_description, f"Missing description meta tag in {html_file.name}"

        # Check for lang attribute
        html_tag = soup.find('html')
        assert html_tag.get('lang'), f"Missing lang attribute in {html_file.name}"

        # Validate heading hierarchy
        self.validate_heading_hierarchy(soup, html_file.name)

        # Check for alt attributes on images
        self.validate_image_alt_text(soup, html_file.name)

        # Validate form accessibility
        self.validate_form_accessibility(soup, html_file.name)

    def validate_heading_hierarchy(self, soup, filename):
        """Validate proper heading hierarchy (h1->h2->h3...)."""
        headings = soup.find_all(['h1', 'h2', 'h3', 'h4', 'h5', 'h6'])

        if not headings:
            return  # No headings is okay

        # Should start with h1
        first_heading = headings[0]
        assert first_heading.name == 'h1', f"First heading should be h1 in {filename}"

        # Check hierarchy doesn't skip levels
        prev_level = 1
        for heading in headings[1:]:
            current_level = int(heading.name[1])

            # Can stay same, go down one, or go to any lower level
            if current_level > prev_level:
                assert current_level <= prev_level + 1, \
                    f"Heading hierarchy skip in {filename}: {heading.name} after h{prev_level}"

            prev_level = current_level

    def validate_image_alt_text(self, soup, filename):
        """Validate that all images have alt text."""
        images = soup.find_all('img')

        for img in images:
            # Alt attribute should exist
            assert img.has_attr('alt'), f"Missing alt attribute on image in {filename}"

            # Alt text should be meaningful (not just filename)
            alt_text = img.get('alt', '').strip()
            src = img.get('src', '')

            if alt_text and src:
                # Alt text shouldn't just be the filename
                filename_part = Path(src).stem.lower()
                assert alt_text.lower() != filename_part, \
                    f"Alt text should be descriptive, not filename in {filename}"

    def validate_form_accessibility(self, soup, filename):
        """Validate form accessibility."""
        inputs = soup.find_all(['input', 'textarea', 'select'])

        for input_element in inputs:
            input_type = input_element.get('type', 'text')

            # Skip hidden inputs
            if input_type == 'hidden':
                continue

            # Should have associated label or aria-label
            input_id = input_element.get('id')
            aria_label = input_element.get('aria-label')

            if not aria_label:
                if input_id:
                    # Look for associated label
                    label = soup.find('label', attrs={'for': input_id})
                    assert label, f"Input missing label or aria-label in {filename}"
                else:
                    # Look for wrapping label
                    parent_label = input_element.find_parent('label')
                    assert parent_label, f"Input missing label or aria-label in {filename}"

    def test_internal_links_validity(self):
        """Test that all internal links are valid."""
        if not self.site_dir.exists():
            pytest.skip("Site must be built for link testing")

        # Start local server
        server_process = None
        try:
            server_process = subprocess.Popen(
                ['python', '-m', 'http.server', '8084'],
                cwd=self.site_dir,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )

            time.sleep(2)

            # Test links on main pages
            test_urls = [
                f"{self.base_url}/",
                f"{self.base_url}/commands/",
                f"{self.base_url}/agents/",
                f"{self.base_url}/workflows/",
                f"{self.base_url}/best-practices/"
            ]

            for url in test_urls:
                try:
                    self.check_page_links(url)
                except requests.RequestException:
                    # Skip if page doesn't exist yet
                    continue

        finally:
            if server_process:
                server_process.terminate()

    def check_page_links(self, page_url):
        """Check all links on a specific page."""
        try:
            response = requests.get(page_url, timeout=10)
            response.raise_for_status()
        except requests.RequestException as e:
            pytest.fail(f"Failed to load page {page_url}: {e}")

        soup = BeautifulSoup(response.content, 'html.parser')
        links = soup.find_all('a', href=True)

        for link in links:
            href = link['href']

            # Skip external links, mailto, and tel links
            if (href.startswith('http') and not href.startswith(self.base_url) or
                href.startswith('mailto:') or href.startswith('tel:')):
                continue

            # Convert relative URLs to absolute
            absolute_url = urljoin(page_url, href)

            # Check if link is accessible
            try:
                link_response = requests.head(absolute_url, timeout=5)
                assert link_response.status_code < 400, \
                    f"Broken internal link: {href} on page {page_url} (status: {link_response.status_code})"
            except requests.RequestException:
                # Try GET if HEAD fails
                try:
                    link_response = requests.get(absolute_url, timeout=5)
                    assert link_response.status_code < 400, \
                        f"Broken internal link: {href} on page {page_url} (status: {link_response.status_code})"
                except requests.RequestException as e:
                    pytest.fail(f"Failed to check link {href} on page {page_url}: {e}")

    def test_search_functionality_present(self):
        """Test that search functionality is properly implemented."""
        if not self.site_dir.exists():
            pytest.skip("Site must be built for search testing")

        # Check that search assets exist
        search_js = self.site_dir / "assets" / "js" / "search.js"
        assert search_js.exists(), "Search JavaScript file missing"

        # Check search JS is not empty
        js_content = search_js.read_text()
        assert len(js_content) > 1000, "Search JavaScript appears incomplete"
        assert 'DocumentationSearch' in js_content, "Search class missing from JavaScript"

        # Check HTML pages have search elements
        html_files = list(self.site_dir.rglob("*.html"))
        found_search = False

        for html_file in html_files:
            content = html_file.read_text()
            if 'data-search-input' in content:
                found_search = True
                break

        assert found_search, "No search input found in HTML pages"

    def test_responsive_design_elements(self):
        """Test that responsive design elements are present."""
        if not self.site_dir.exists():
            pytest.skip("Site must be built for responsive testing")

        css_file = self.site_dir / "assets" / "css" / "docs.css"
        assert css_file.exists(), "Main CSS file missing"

        css_content = css_file.read_text()

        # Check for media queries
        media_queries = re.findall(r'@media[^{]+\{', css_content)
        assert len(media_queries) >= 2, "Insufficient media queries for responsive design"

        # Check for mobile-first approach (min-width queries)
        min_width_queries = [mq for mq in media_queries if 'min-width' in mq]
        assert len(min_width_queries) >= 1, "Missing min-width media queries"

        # Check for mobile breakpoint
        mobile_breakpoint = any('768px' in mq or '767px' in mq for mq in media_queries)
        assert mobile_breakpoint, "Missing standard mobile breakpoint"

    def test_accessibility_landmarks(self):
        """Test that proper accessibility landmarks are present."""
        if not self.site_dir.exists():
            pytest.skip("Site must be built for accessibility testing")

        html_files = list(self.site_dir.rglob("*.html"))

        for html_file in html_files:
            content = html_file.read_text()
            soup = BeautifulSoup(content, 'html.parser')

            # Check for main landmark
            main_element = soup.find('main') or soup.find(attrs={'role': 'main'})
            assert main_element, f"Missing main landmark in {html_file.name}"

            # Check for navigation landmark
            nav_element = soup.find('nav') or soup.find(attrs={'role': 'navigation'})
            assert nav_element, f"Missing navigation landmark in {html_file.name}"

            # Check for skip link
            skip_link = soup.find('a', string=re.compile(r'skip|saltar', re.I))
            if not skip_link:
                # Check for skip link in href
                skip_link = soup.find('a', href=re.compile(r'#main|#content'))
            # Skip links are recommended but not required for all pages

    def test_seo_meta_tags(self):
        """Test that SEO meta tags are properly implemented."""
        if not self.site_dir.exists():
            pytest.skip("Site must be built for SEO testing")

        # Test main pages
        important_pages = ['index.html']

        for page_name in important_pages:
            page_file = self.site_dir / page_name
            if not page_file.exists():
                continue

            content = page_file.read_text()
            soup = BeautifulSoup(content, 'html.parser')

            # Check for title tag (should be specific, not just site name)
            title = soup.find('title')
            assert title and len(title.get_text().strip()) > 10, \
                f"Title too short or missing in {page_name}"

            # Check for meta description
            description = soup.find('meta', attrs={'name': 'description'})
            assert description and len(description.get('content', '')) > 50, \
                f"Meta description too short or missing in {page_name}"

            # Check for Open Graph tags
            og_title = soup.find('meta', attrs={'property': 'og:title'})
            og_description = soup.find('meta', attrs={'property': 'og:description'})

            # OG tags are recommended but not required
            if og_title:
                assert og_title.get('content'), f"Empty og:title in {page_name}"

if __name__ == "__main__":
    pytest.main([__file__, "-v"])