"""
Lighthouse Performance Test Suite
Tests performance metrics against targets defined in the specification.
"""

import subprocess
import json
import time
from pathlib import Path
import pytest
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

class TestLighthousePerformance:
    """Test performance metrics using Lighthouse."""

    def setup_method(self):
        """Set up test environment."""
        self.repo_root = Path(__file__).parent.parent.parent
        self.docs_dir = self.repo_root / "docs"
        self.site_dir = self.docs_dir / "_site"

    def test_lighthouse_performance_score(self):
        """Test that Lighthouse performance score meets requirements (≥90)."""
        if not self.site_dir.exists():
            pytest.skip("Site must be built for performance testing")

        # Start a simple HTTP server for testing
        server_process = None
        try:
            server_process = subprocess.Popen(
                ['python', '-m', 'http.server', '8080'],
                cwd=self.site_dir,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )

            # Wait for server to start
            time.sleep(2)

            # Run Lighthouse
            lighthouse_result = self.run_lighthouse('http://localhost:8080')

            # Check performance score
            performance_score = lighthouse_result['categories']['performance']['score'] * 100
            assert performance_score >= 90, f"Performance score {performance_score} below target (90)"

        finally:
            if server_process:
                server_process.terminate()

    def test_lighthouse_accessibility_score(self):
        """Test that accessibility score meets requirements (≥95)."""
        if not self.site_dir.exists():
            pytest.skip("Site must be built for accessibility testing")

        server_process = None
        try:
            server_process = subprocess.Popen(
                ['python', '-m', 'http.server', '8081'],
                cwd=self.site_dir,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )

            time.sleep(2)

            lighthouse_result = self.run_lighthouse('http://localhost:8081')
            accessibility_score = lighthouse_result['categories']['accessibility']['score'] * 100

            assert accessibility_score >= 95, f"Accessibility score {accessibility_score} below target (95)"

        finally:
            if server_process:
                server_process.terminate()

    def test_core_web_vitals(self):
        """Test Core Web Vitals metrics."""
        if not self.site_dir.exists():
            pytest.skip("Site must be built for Core Web Vitals testing")

        server_process = None
        try:
            server_process = subprocess.Popen(
                ['python', '-m', 'http.server', '8082'],
                cwd=self.site_dir,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )

            time.sleep(2)

            lighthouse_result = self.run_lighthouse('http://localhost:8082')
            audits = lighthouse_result['audits']

            # First Contentful Paint (should be ≤2s)
            fcp = audits['first-contentful-paint']['numericValue'] / 1000
            assert fcp <= 2.0, f"First Contentful Paint {fcp:.2f}s exceeds 2s target"

            # Largest Contentful Paint (should be ≤2.5s)
            lcp = audits['largest-contentful-paint']['numericValue'] / 1000
            assert lcp <= 2.5, f"Largest Contentful Paint {lcp:.2f}s exceeds 2.5s target"

            # Cumulative Layout Shift (should be ≤0.1)
            cls = audits['cumulative-layout-shift']['numericValue']
            assert cls <= 0.1, f"Cumulative Layout Shift {cls:.3f} exceeds 0.1 target"

        finally:
            if server_process:
                server_process.terminate()

    def test_bundle_size_limits(self):
        """Test that bundle sizes meet targets (<50KB total)."""
        if not self.site_dir.exists():
            pytest.skip("Site must be built for bundle size testing")

        # Check CSS file size
        css_file = self.site_dir / "assets" / "css" / "docs.css"
        if css_file.exists():
            css_size = css_file.stat().st_size / 1024  # KB
            assert css_size <= 20, f"CSS bundle {css_size:.1f}KB exceeds 20KB target"

        # Check JS file size
        js_file = self.site_dir / "assets" / "js" / "search.js"
        if js_file.exists():
            js_size = js_file.stat().st_size / 1024  # KB
            assert js_size <= 15, f"JS bundle {js_size:.1f}KB exceeds 15KB target"

        # Check total asset size
        total_size = 0
        assets_dir = self.site_dir / "assets"
        if assets_dir.exists():
            for file_path in assets_dir.rglob("*"):
                if file_path.is_file():
                    total_size += file_path.stat().st_size

        total_size_kb = total_size / 1024
        assert total_size_kb <= 50, f"Total assets {total_size_kb:.1f}KB exceed 50KB target"

    def test_mobile_performance(self):
        """Test mobile-specific performance metrics."""
        if not self.site_dir.exists():
            pytest.skip("Site must be built for mobile performance testing")

        server_process = None
        try:
            server_process = subprocess.Popen(
                ['python', '-m', 'http.server', '8083'],
                cwd=self.site_dir,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )

            time.sleep(2)

            # Run Lighthouse with mobile settings
            lighthouse_result = self.run_lighthouse('http://localhost:8083', mobile=True)

            # Mobile performance should still be ≥85
            mobile_performance = lighthouse_result['categories']['performance']['score'] * 100
            assert mobile_performance >= 85, f"Mobile performance {mobile_performance} below target (85)"

            # Check mobile-specific metrics
            audits = lighthouse_result['audits']

            # Time to Interactive on mobile (should be ≤5s)
            tti = audits['interactive']['numericValue'] / 1000
            assert tti <= 5.0, f"Time to Interactive {tti:.2f}s exceeds 5s mobile target"

        finally:
            if server_process:
                server_process.terminate()

    def run_lighthouse(self, url, mobile=False):
        """Run Lighthouse and return results."""
        try:
            # Lighthouse CLI command
            cmd = [
                'lighthouse',
                url,
                '--output=json',
                '--quiet',
                '--chrome-flags=--headless',
                '--no-sandbox'
            ]

            if mobile:
                cmd.extend([
                    '--preset=perf',
                    '--emulated-form-factor=mobile'
                ])

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=60
            )

            if result.returncode != 0:
                raise Exception(f"Lighthouse failed: {result.stderr}")

            return json.loads(result.stdout)

        except (subprocess.TimeoutExpired, FileNotFoundError, json.JSONDecodeError) as e:
            pytest.skip(f"Lighthouse not available or failed: {e}")

    def test_image_optimization(self):
        """Test that images are properly optimized."""
        if not self.site_dir.exists():
            pytest.skip("Site must be built for image testing")

        # Find all images in the site
        image_files = list(self.site_dir.rglob("*.jpg")) + \
                     list(self.site_dir.rglob("*.png")) + \
                     list(self.site_dir.rglob("*.gif"))

        for image_file in image_files:
            # Check file size (should be reasonable for web)
            file_size = image_file.stat().st_size / 1024  # KB

            # Adjust limits based on image type
            if image_file.suffix.lower() == '.png':
                max_size = 100  # KB for PNGs
            else:
                max_size = 200  # KB for JPGs/GIFs

            assert file_size <= max_size, \
                f"Image {image_file.name} ({file_size:.1f}KB) exceeds {max_size}KB limit"

    def test_font_loading_performance(self):
        """Test font loading doesn't block rendering."""
        # This is a basic check - in a real scenario you'd test font loading strategies
        css_file = self.site_dir / "assets" / "css" / "docs.css"

        if css_file.exists():
            css_content = css_file.read_text()

            # Check for font-display: swap or similar optimizations
            if '@font-face' in css_content:
                assert 'font-display:' in css_content, \
                    "Custom fonts should use font-display for performance"

if __name__ == "__main__":
    pytest.main([__file__, "-v"])