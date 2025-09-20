/**
 * Claude Code Documentation Search
 * Client-side search functionality with real-time results
 * Supports fuzzy matching and category filtering
 */

class DocumentationSearch {
  constructor() {
    this.searchIndex = [];
    this.searchInput = null;
    this.searchResults = null;
    this.resultsContainer = null;
    this.categoryFilter = null;
    this.searchCache = new Map();
    this.currentFocus = -1;
    this.isLoading = false;

    // Configuration
    this.config = {
      debounceDelay: 300,
      minQueryLength: 1,
      maxResults: 10,
      highlightClass: "search-highlight",
      fuzzyThreshold: 0.3,
    };

    this.init();
  }

  async init() {
    // Wait for DOM to be ready
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", () => this.setup());
    } else {
      this.setup();
    }
  }

  async setup() {
    // Find search components
    this.searchInput = document.querySelector("[data-search-input]");
    this.searchResults = document.querySelector("[data-search-results]");
    this.resultsContainer = document.querySelector(
      "[data-search-results-container]",
    );
    this.categoryFilter = document.querySelector("[data-category-filter]");

    if (!this.searchInput || !this.searchResults) {
      console.warn("Search components not found");
      return;
    }

    // Load search index
    await this.loadSearchIndex();

    // Setup event listeners
    this.setupEventListeners();

    // Setup keyboard shortcuts
    this.setupKeyboardShortcuts();

    console.log("Documentation search initialized");
  }

  async loadSearchIndex() {
    this.isLoading = true;
    this.showLoading();

    try {
      // Try to load the search index
      const response = await fetch("/_data/search.json");

      if (!response.ok) {
        throw new Error(`Failed to load search index: ${response.status}`);
      }

      const data = await response.json();
      this.searchIndex = data.index || [];

      console.log(`Loaded ${this.searchIndex.length} search entries`);
    } catch (error) {
      console.error("Error loading search index:", error);

      // Fallback: create a basic index from current page
      this.createFallbackIndex();
    } finally {
      this.isLoading = false;
      this.hideLoading();
    }
  }

  createFallbackIndex() {
    // Create a basic search index from the current page content
    const headings = document.querySelectorAll("h1, h2, h3, h4");
    const fallbackIndex = [];

    headings.forEach((heading, index) => {
      const text = heading.textContent.trim();
      if (text) {
        fallbackIndex.push({
          id: `heading-${index}`,
          title: text,
          content: this.getContentAfterHeading(heading),
          category: "general",
          url: `#${heading.id || "heading-" + index}`,
          keywords: this.extractKeywords(text),
        });

        // Ensure heading has an ID for navigation
        if (!heading.id) {
          heading.id = `heading-${index}`;
        }
      }
    });

    this.searchIndex = fallbackIndex;
    console.log(`Created fallback index with ${fallbackIndex.length} entries`);
  }

  getContentAfterHeading(heading) {
    let content = "";
    let next = heading.nextElementSibling;
    let wordCount = 0;
    const maxWords = 30;

    while (next && wordCount < maxWords) {
      if (next.tagName && next.tagName.match(/^H[1-6]$/)) {
        break; // Stop at next heading
      }

      const text = next.textContent || "";
      const words = text.split(/\s+/).filter((w) => w.length > 0);

      if (wordCount + words.length > maxWords) {
        content += " " + words.slice(0, maxWords - wordCount).join(" ");
        break;
      }

      content += " " + text;
      wordCount += words.length;
      next = next.nextElementSibling;
    }

    return content.trim();
  }

  extractKeywords(text) {
    const commonWords = new Set([
      "el",
      "la",
      "de",
      "que",
      "y",
      "a",
      "en",
      "un",
      "es",
      "se",
      "no",
      "te",
      "lo",
      "le",
      "da",
      "su",
      "por",
      "son",
      "con",
      "para",
      "al",
      "del",
      "los",
      "las",
      "una",
      "como",
      "pero",
      "sus",
      "más",
      "fue",
      "ser",
      "está",
      "todo",
      "esta",
      "muy",
      "has",
      "me",
      "si",
      "sin",
      "sobre",
      "también",
      "then",
      "the",
      "is",
      "at",
      "it",
      "on",
      "be",
      "to",
      "of",
      "and",
      "or",
      "an",
      "as",
      "are",
      "for",
      "with",
      "this",
      "that",
      "from",
      "have",
      "had",
      "by",
      "not",
      "but",
      "can",
      "all",
      "how",
      "what",
      "when",
      "where",
      "who",
      "why",
      "will",
      "would",
      "could",
      "should",
    ]);

    return text
      .toLowerCase()
      .split(/\s+/)
      .filter((word) => word.length > 2 && !commonWords.has(word))
      .slice(0, 5);
  }

  setupEventListeners() {
    // Search input
    this.searchInput.addEventListener(
      "input",
      this.debounce(() => {
        this.handleSearch();
      }, this.config.debounceDelay),
    );

    // Category filter
    if (this.categoryFilter) {
      this.categoryFilter.addEventListener("change", () => {
        this.handleSearch();
      });
    }

    // Clear button
    const clearButton = document.querySelector("[data-search-clear]");
    if (clearButton) {
      clearButton.addEventListener("click", () => {
        this.clearSearch();
      });
    }

    // Keyboard navigation in results
    this.searchInput.addEventListener("keydown", (e) => {
      this.handleKeyboardNavigation(e);
    });

    // Click outside to close results
    document.addEventListener("click", (e) => {
      if (
        !this.searchInput.contains(e.target) &&
        !this.resultsContainer.contains(e.target)
      ) {
        this.hideResults();
      }
    });

    // Show/hide clear button
    this.searchInput.addEventListener("input", () => {
      const clearButton = document.querySelector("[data-search-clear]");
      if (clearButton) {
        clearButton.style.display = this.searchInput.value ? "block" : "none";
      }
    });
  }

  setupKeyboardShortcuts() {
    // Global search shortcut (/)
    document.addEventListener("keydown", (e) => {
      if (e.key === "/" && !this.isInputFocused()) {
        e.preventDefault();
        this.searchInput.focus();
      }

      if (e.key === "Escape") {
        this.hideResults();
        this.searchInput.blur();
      }
    });
  }

  isInputFocused() {
    const active = document.activeElement;
    return (
      active &&
      (active.tagName === "INPUT" ||
        active.tagName === "TEXTAREA" ||
        active.isContentEditable)
    );
  }

  handleSearch() {
    const query = this.searchInput.value.trim();
    const category = this.categoryFilter ? this.categoryFilter.value : "";

    if (query.length < this.config.minQueryLength) {
      this.hideResults();
      return;
    }

    // Check cache first
    const cacheKey = `${query}:${category}`;
    if (this.searchCache.has(cacheKey)) {
      this.displayResults(this.searchCache.get(cacheKey), query);
      return;
    }

    // Perform search
    const results = this.search(query, category);

    // Cache results
    this.searchCache.set(cacheKey, results);

    // Display results
    this.displayResults(results, query);
  }

  search(query, category = "") {
    if (this.isLoading || !this.searchIndex.length) {
      return [];
    }

    const lowerQuery = query.toLowerCase();
    const queryTerms = lowerQuery
      .split(/\s+/)
      .filter((term) => term.length > 0);

    let results = this.searchIndex
      .map((item) => {
        // Skip if category filter doesn't match
        if (category && item.category !== category) {
          return null;
        }

        const score = this.calculateRelevanceScore(
          item,
          queryTerms,
          lowerQuery,
        );
        return score > 0 ? { ...item, score } : null;
      })
      .filter((item) => item !== null)
      .sort((a, b) => b.score - a.score)
      .slice(0, this.config.maxResults);

    return results;
  }

  calculateRelevanceScore(item, queryTerms, fullQuery) {
    let score = 0;
    const title = item.title.toLowerCase();
    const content = item.content.toLowerCase();
    const keywords = (item.keywords || []).map((k) => k.toLowerCase());

    // Exact title match (highest score)
    if (title.includes(fullQuery)) {
      score += title === fullQuery ? 100 : 50;
    }

    // Title word matches
    queryTerms.forEach((term) => {
      if (title.includes(term)) {
        score += title.startsWith(term) ? 25 : 15;
      }
    });

    // Content matches
    queryTerms.forEach((term) => {
      const contentMatches = (content.match(new RegExp(term, "g")) || [])
        .length;
      score += contentMatches * 5;
    });

    // Keyword matches
    queryTerms.forEach((term) => {
      keywords.forEach((keyword) => {
        if (keyword.includes(term)) {
          score += keyword === term ? 20 : 10;
        }
      });
    });

    // Fuzzy matching for typos
    if (score === 0) {
      queryTerms.forEach((term) => {
        if (this.fuzzyMatch(term, title) || this.fuzzyMatch(term, content)) {
          score += 5;
        }
      });
    }

    return score;
  }

  fuzzyMatch(query, text) {
    if (query.length < 3) return false;

    const words = text.split(/\s+/);
    return words.some((word) => {
      if (word.length < 3) return false;

      const distance = this.levenshteinDistance(query, word.toLowerCase());
      return distance <= Math.floor(query.length * this.config.fuzzyThreshold);
    });
  }

  levenshteinDistance(str1, str2) {
    const matrix = [];

    for (let i = 0; i <= str2.length; i++) {
      matrix[i] = [i];
    }

    for (let j = 0; j <= str1.length; j++) {
      matrix[0][j] = j;
    }

    for (let i = 1; i <= str2.length; i++) {
      for (let j = 1; j <= str1.length; j++) {
        if (str2.charAt(i - 1) === str1.charAt(j - 1)) {
          matrix[i][j] = matrix[i - 1][j - 1];
        } else {
          matrix[i][j] = Math.min(
            matrix[i - 1][j - 1] + 1,
            matrix[i][j - 1] + 1,
            matrix[i - 1][j] + 1,
          );
        }
      }
    }

    return matrix[str2.length][str1.length];
  }

  displayResults(results, query) {
    this.updateResultsInfo(results.length, query);

    if (results.length === 0) {
      this.showNoResults(query);
      return;
    }

    // Clear previous results
    this.searchResults.innerHTML = "";

    // Add results
    results.forEach((result, index) => {
      const resultElement = this.createResultElement(result, query, index);
      this.searchResults.appendChild(resultElement);
    });

    this.showResults();
    this.currentFocus = -1;
  }

  createResultElement(result, query, index) {
    const li = document.createElement("li");
    li.className = "result-item";
    li.setAttribute("role", "option");
    li.setAttribute("data-result-index", index);

    const link = document.createElement("a");
    link.href = result.url;
    link.className = "result-link";
    link.setAttribute("data-result-category", result.category);

    // Highlight query terms in title and content
    const highlightedTitle = this.highlightMatches(result.title, query);
    const highlightedContent = this.highlightMatches(result.content, query);

    link.innerHTML = `
      <div class="result-title">${highlightedTitle}</div>
      <div class="result-excerpt">${highlightedContent}</div>
      <div class="result-category category-${result.category}">${result.category}</div>
    `;

    // Add click tracking
    link.addEventListener("click", () => {
      this.trackSearchClick(result, query);
      this.hideResults();
    });

    li.appendChild(link);
    return li;
  }

  highlightMatches(text, query) {
    if (!text || !query) return text;

    const queryTerms = query.toLowerCase().split(/\s+/);
    let highlightedText = text;

    queryTerms.forEach((term) => {
      if (term.length > 1) {
        const regex = new RegExp(`(${this.escapeRegExp(term)})`, "gi");
        highlightedText = highlightedText.replace(
          regex,
          `<mark class="${this.config.highlightClass}">$1</mark>`,
        );
      }
    });

    return highlightedText;
  }

  escapeRegExp(string) {
    return string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  }

  handleKeyboardNavigation(e) {
    const resultItems = this.searchResults.querySelectorAll(".result-item");

    if (resultItems.length === 0) return;

    switch (e.key) {
      case "ArrowDown":
        e.preventDefault();
        this.currentFocus = Math.min(
          this.currentFocus + 1,
          resultItems.length - 1,
        );
        this.updateFocus(resultItems);
        break;

      case "ArrowUp":
        e.preventDefault();
        this.currentFocus = Math.max(this.currentFocus - 1, -1);
        this.updateFocus(resultItems);
        break;

      case "Enter":
        e.preventDefault();
        if (this.currentFocus >= 0) {
          const focusedResult = resultItems[this.currentFocus];
          const link = focusedResult.querySelector(".result-link");
          if (link) {
            link.click();
          }
        }
        break;

      case "Escape":
        this.hideResults();
        break;
    }
  }

  updateFocus(resultItems) {
    // Remove previous focus
    resultItems.forEach((item) => {
      item.querySelector(".result-link").classList.remove("keyboard-focused");
    });

    // Add focus to current item
    if (this.currentFocus >= 0) {
      const focusedItem = resultItems[this.currentFocus];
      focusedItem
        .querySelector(".result-link")
        .classList.add("keyboard-focused");

      // Update ARIA attributes
      this.searchInput.setAttribute(
        "aria-activedescendant",
        focusedItem.getAttribute("data-result-index"),
      );
    } else {
      this.searchInput.removeAttribute("aria-activedescendant");
    }
  }

  showResults() {
    if (this.resultsContainer) {
      this.resultsContainer.style.display = "block";
      this.searchInput.setAttribute("aria-expanded", "true");
    }
  }

  hideResults() {
    if (this.resultsContainer) {
      this.resultsContainer.style.display = "none";
      this.searchInput.setAttribute("aria-expanded", "false");
    }
    this.currentFocus = -1;
  }

  showNoResults(query) {
    const noResultsElement = document.querySelector("[data-no-results]");
    if (noResultsElement) {
      const queryElements = noResultsElement.querySelectorAll(
        "[data-search-query]",
      );
      queryElements.forEach((el) => (el.textContent = query));
      noResultsElement.style.display = "block";
    }

    this.searchResults.innerHTML = "";
    this.showResults();
  }

  showLoading() {
    const loadingElement = document.querySelector("[data-search-loading]");
    if (loadingElement) {
      loadingElement.style.display = "block";
    }
  }

  hideLoading() {
    const loadingElement = document.querySelector("[data-search-loading]");
    if (loadingElement) {
      loadingElement.style.display = "none";
    }
  }

  updateResultsInfo(count, query) {
    const countElement = document.querySelector("[data-results-count]");
    const queryElements = document.querySelectorAll("[data-search-query]");

    if (countElement) {
      countElement.textContent = count;
    }

    queryElements.forEach((el) => {
      el.textContent = query;
    });

    // Hide/show no results
    const noResultsElement = document.querySelector("[data-no-results]");
    if (noResultsElement) {
      noResultsElement.style.display = count === 0 ? "block" : "none";
    }
  }

  clearSearch() {
    this.searchInput.value = "";
    this.hideResults();
    this.searchInput.focus();

    // Hide clear button
    const clearButton = document.querySelector("[data-search-clear]");
    if (clearButton) {
      clearButton.style.display = "none";
    }

    // Reset category filter
    if (this.categoryFilter) {
      this.categoryFilter.value = "";
    }
  }

  trackSearchClick(result, query) {
    // Track search analytics if available
    if (typeof gtag !== "undefined") {
      gtag("event", "search_click", {
        search_term: query,
        result_title: result.title,
        result_category: result.category,
        result_url: result.url,
      });
    }

    console.log("Search click:", { query, result: result.title });
  }

  debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  }
}

// Initialize search when DOM is ready
const documentationSearch = new DocumentationSearch();
