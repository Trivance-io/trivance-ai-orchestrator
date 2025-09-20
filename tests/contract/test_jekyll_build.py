"""
Contract tests for Jekyll build pipeline.

These tests verify that the Jekyll build process meets the contract specifications
defined in contracts/jekyll-build.yml. They should FAIL until implementation is complete.
"""

import subprocess
import os
import json
import time
from pathlib import Path
import yaml

class TestJekyllBuildContract:
    """Test Jekyll build pipeline contract compliance."""

    def setup_method(self):
        """Set up test environment."""
        self.repo_root = Path(__file__).parent.parent.parent
        self.docs_dir = self.repo_root / "docs"
        self.site_dir = self.docs_dir / "_site"
        self.source_dir = self.repo_root / ".claude" / "human-handbook" / "docs"

    def test_jekyll_config_exists(self):
        """Test that Jekyll configuration file exists with required settings."""
        config_file = self.docs_dir / "_config.yml"
        assert config_file.exists(), "Jekyll _config.yml must exist"

        with open(config_file, 'r') as f:
            config = yaml.safe_load(f)

        # Contract requirements from jekyll-build.yml
        assert config.get('title'), "Config must have title"
        assert config.get('description'), "Config must have description"
        assert 'jekyll-feed' in config.get('plugins', []), "Must include jekyll-feed plugin"
        assert 'jekyll-sitemap' in config.get('plugins', []), "Must include jekyll-sitemap plugin"

    def test_source_directory_structure(self):
        """Test that source documentation files exist."""
        # Contract requirement: source files must exist
        required_files = [
            "commands-guide.md",
            "agents-guide.md",
            "ai-first-workflow.md",
            "ai-first-best-practices.md",
            "quickstart.md"
        ]

        for filename in required_files:
            source_file = self.source_dir / filename
            assert source_file.exists(), f"Source file {filename} must exist"

    def test_jekyll_directory_structure(self):
        """Test that Jekyll directory structure is properly set up."""
        required_dirs = [
            "_layouts",
            "_includes",
            "_data",
            "assets/css",
            "assets/js"
        ]

        for dirname in required_dirs:
            dir_path = self.docs_dir / dirname
            assert dir_path.exists(), f"Jekyll directory {dirname} must exist"

    def test_build_performance_requirements(self):
        """Test that build meets performance targets."""
        # This test will FAIL until Jekyll site is fully implemented
        start_time = time.time()

        # Attempt to run Jekyll build
        try:
            result = subprocess.run(
                ['bundle', 'exec', 'jekyll', 'build'],
                cwd=self.docs_dir,
                capture_output=True,
                text=True,
                timeout=30  # Contract requirement: build in <30 seconds
            )
        except (subprocess.TimeoutExpired, FileNotFoundError):
            # Expected to fail - no implementation yet
            assert False, "Jekyll build should complete in <30 seconds (will fail until implemented)"

        build_time = time.time() - start_time
        assert build_time < 30, f"Build time {build_time}s exceeds 30s limit"

    def test_output_artifacts_generated(self):
        """Test that build generates required artifacts."""
        # This test will FAIL until site is built
        assert self.site_dir.exists(), "Site directory _site/ must be generated"

        # Contract requirements from jekyll-build.yml
        index_file = self.site_dir / "index.html"
        assert index_file.exists(), "index.html must be generated"

        # Search index requirement
        search_index = self.site_dir / "_data" / "search.json"
        assert search_index.exists(), "Search index must be generated"

    def test_html_validation(self):
        """Test that generated HTML is valid."""
        # This will FAIL until pages are implemented
        if not self.site_dir.exists():
            assert False, "Site must be built for HTML validation"

        index_file = self.site_dir / "index.html"
        if index_file.exists():
            with open(index_file, 'r') as f:
                content = f.read()

            # Basic HTML structure validation
            assert "<!DOCTYPE html>" in content, "Must have valid DOCTYPE"
            assert "<html" in content, "Must have html tag"
            assert "<head>" in content, "Must have head section"
            assert "<body>" in content, "Must have body section"

    def test_responsive_assets_exist(self):
        """Test that responsive CSS and JS assets exist."""
        # These will FAIL until assets are implemented
        css_file = self.site_dir / "assets" / "css" / "docs.css"
        js_file = self.site_dir / "assets" / "js" / "search.js"

        assert css_file.exists(), "docs.css must be generated"
        assert js_file.exists(), "search.js must be generated"

    def test_build_error_handling(self):
        """Test that build process handles errors gracefully."""
        # Test with intentionally broken config
        config_backup = self.docs_dir / "_config.yml.backup"
        config_file = self.docs_dir / "_config.yml"

        # Backup original config
        if config_file.exists():
            config_file.rename(config_backup)

        # Create broken config
        with open(config_file, 'w') as f:
            f.write("invalid_yaml: [")

        try:
            result = subprocess.run(
                ['bundle', 'exec', 'jekyll', 'build'],
                cwd=self.docs_dir,
                capture_output=True,
                text=True
            )

            # Build should fail gracefully
            assert result.returncode != 0, "Build should fail with invalid config"
            assert "error" in result.stderr.lower() or "error" in result.stdout.lower(), "Should report error"

        finally:
            # Restore original config
            if config_backup.exists():
                config_backup.rename(config_file)
            elif config_file.exists():
                config_file.unlink()