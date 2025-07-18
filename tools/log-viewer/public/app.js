// Trivance Log Viewer - AI-First Debugging Interface
class LogViewer {
  constructor() {
    this.logs = [];
    this.filteredLogs = [];
    this.autoRefresh = false;
    this.refreshInterval = null;
    
    this.initializeElements();
    this.attachEventListeners();
    this.loadLatest();
  }
  
  initializeElements() {
    this.elements = {
      container: document.getElementById('logsContainer'),
      traceIdInput: document.getElementById('traceId'),
      sessionIdInput: document.getElementById('sessionId'),
      serviceSelect: document.getElementById('service'),
      levelSelect: document.getElementById('level'),
      textInput: document.getElementById('text'),
      statusDiv: document.getElementById('status'),
      autoRefreshBtn: document.getElementById('autoRefresh'),
      expandAllBtn: document.getElementById('expandAll'),
      collapseAllBtn: document.getElementById('collapseAll')
    };
  }
  
  attachEventListeners() {
    // Search on Enter
    document.querySelectorAll('input').forEach(input => {
      input.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') this.search();
      });
    });
    
    // Auto-refresh toggle
    this.elements.autoRefreshBtn?.addEventListener('click', () => {
      this.toggleAutoRefresh();
    });
  }
  
  async loadLatest() {
    this.showLoading();
    
    try {
      const response = await fetch('/api/logs/latest?limit=500');
      const data = await response.json();
      
      if (data.error) {
        this.showError(data.message);
        return;
      }
      
      this.logs = data.logs || [];
      this.applyFilters();
      this.updateStatus(`Loaded ${this.logs.length} latest logs`);
    } catch (error) {
      this.showError(`Failed to load logs: ${error.message}`);
    }
  }
  
  async search() {
    this.showLoading();
    
    const params = new URLSearchParams();
    
    // Only add non-empty parameters
    const filters = {
      traceId: this.elements.traceIdInput.value.trim(),
      sessionId: this.elements.sessionIdInput.value.trim(),
      service: this.elements.serviceSelect.value,
      level: this.elements.levelSelect.value,
      text: this.elements.textInput.value.trim()
    };
    
    Object.entries(filters).forEach(([key, value]) => {
      if (value) params.set(key, value);
    });
    
    params.set('limit', '1000');
    
    try {
      const response = await fetch(`/api/logs/search?${params}`);
      const data = await response.json();
      
      if (data.error) {
        this.showError(data.message);
        return;
      }
      
      this.logs = data.logs || [];
      this.applyFilters();
      this.updateStatus(`Found ${this.logs.length} matching logs`);
    } catch (error) {
      this.showError(`Search failed: ${error.message}`);
    }
  }
  
  clearFilters() {
    this.elements.traceIdInput.value = '';
    this.elements.sessionIdInput.value = '';
    this.elements.serviceSelect.value = '';
    this.elements.levelSelect.value = '';
    this.elements.textInput.value = '';
    this.loadLatest();
  }
  
  applyFilters() {
    this.filteredLogs = [...this.logs];
    this.sortLogs();
    this.render();
  }
  
  sortLogs() {
    // Sort by timestamp descending (newest first)
    this.filteredLogs.sort((a, b) => {
      const timeA = new Date(a['@timestamp'] || a.timestamp || 0).getTime();
      const timeB = new Date(b['@timestamp'] || b.timestamp || 0).getTime();
      return timeB - timeA;
    });
  }
  
  render() {
    if (this.filteredLogs.length === 0) {
      this.elements.container.innerHTML = '<div class="no-logs">No logs found</div>';
      return;
    }
    
    // Group by trace ID
    const grouped = this.groupByTrace();
    
    // Build HTML
    let html = '';
    Object.entries(grouped).forEach(([traceId, logs]) => {
      html += this.renderTraceGroup(traceId, logs);
    });
    
    this.elements.container.innerHTML = html;
  }
  
  groupByTrace() {
    const grouped = {};
    
    this.filteredLogs.forEach(log => {
      const traceId = log['@traceId'] || log.traceId || 'no-trace';
      if (!grouped[traceId]) {
        grouped[traceId] = [];
      }
      grouped[traceId].push(log);
    });
    
    // Sort groups by most recent log
    const sortedGroups = {};
    Object.entries(grouped)
      .sort(([, logsA], [, logsB]) => {
        const maxTimeA = Math.max(...logsA.map(l => new Date(l['@timestamp'] || l.timestamp || 0).getTime()));
        const maxTimeB = Math.max(...logsB.map(l => new Date(l['@timestamp'] || l.timestamp || 0).getTime()));
        return maxTimeB - maxTimeA;
      })
      .forEach(([traceId, logs]) => {
        sortedGroups[traceId] = logs;
      });
    
    return sortedGroups;
  }
  
  renderTraceGroup(traceId, logs) {
    const hasError = logs.some(log => log.level === 'error');
    const hasWarning = logs.some(log => log.level === 'warn' || log.level === 'warning');
    const firstLog = logs[0];
    const services = [...new Set(logs.map(l => l['@service'] || l.service || 'unknown'))];
    
    // Safe trace ID for HTML
    const safeTraceId = this.escapeHtml(traceId);
    const traceIdAttr = CSS.escape(traceId);
    
    return `
      <div class="log-trace ${hasError ? 'has-error' : hasWarning ? 'has-warning' : ''}">
        <div class="trace-header" onclick="logViewer.toggleTrace('${traceId.replace(/'/g, "\\'")}')">
          <span class="icon">${hasError ? '🔴' : hasWarning ? '🟡' : '🟢'}</span>
          <span class="services">${services.join(' → ')}</span>
          <span class="trace-id">${safeTraceId}</span>
          <span class="summary">${logs.length} events</span>
          <span class="time">${this.formatTime(firstLog['@timestamp'] || firstLog.timestamp)}</span>
        </div>
        <div class="trace-content" id="trace-${traceIdAttr}" style="display: none;">
          ${logs.map(log => this.renderLogEntry(log)).join('')}
        </div>
      </div>
    `;
  }
  
  renderLogEntry(log) {
    const level = log.level || 'info';
    const service = log['@service'] || log.service || 'unknown';
    const type = log.type || 'log';
    const timestamp = log['@timestamp'] || log.timestamp;
    
    // Fix level mapping - convert warn to warning for proper styling
    const displayLevel = level === 'warn' ? 'warning' : level;
    
    let html = `
      <div class="log-entry ${displayLevel}">
        <div class="log-header">
          <span class="timestamp">${this.formatTime(timestamp)}</span>
          <span class="service ${service}">${service}</span>
          <span class="type">${type}</span>
          <span class="level ${displayLevel}">${level.toUpperCase()}</span>
        </div>
    `;
    
    // Message
    if (log.message) {
      html += `<div class="message">${this.escapeHtml(log.message)}</div>`;
    }
    
    // HTTP Request
    if (log.method && log.path) {
      html += this.renderHttpRequest(log);
    }
    
    // Frontend request/response
    if (log.request) {
      html += this.renderRequest(log.request);
    }
    
    if (log.response) {
      html += this.renderResponse(log.response);
    }
    
    // Error details
    if (log.error) {
      html += this.renderError(log.error);
    }
    
    // Additional data
    const additionalData = this.extractAdditionalData(log);
    if (Object.keys(additionalData).length > 0) {
      html += this.renderAdditionalData(additionalData);
    }
    
    html += '</div>';
    return html;
  }
  
  renderHttpRequest(log) {
    let html = `
      <div class="payload http-request">
        <div class="payload-header">HTTP REQUEST</div>
        <div class="http-line">${log.method} ${log.path}</div>
    `;
    
    if (log.query && Object.keys(log.query).length > 0) {
      html += `<div class="query">Query: ${this.formatJson(log.query)}</div>`;
    }
    
    if (log.body) {
      html += `<div class="body">Body: ${this.formatJson(log.body)}</div>`;
    }
    
    html += '</div>';
    return html;
  }
  
  renderRequest(request) {
    return `
      <div class="payload request">
        <div class="payload-header">REQUEST</div>
        <div class="http-line">${request.method || 'GET'} ${request.url || ''}</div>
        ${request.headers ? `<div class="headers">Headers: ${this.formatJson(request.headers)}</div>` : ''}
        ${request.body ? `<div class="body">Body: ${this.formatJson(request.body)}</div>` : ''}
      </div>
    `;
  }
  
  renderResponse(response) {
    const duration = response.duration ? ` (${response.duration}ms)` : '';
    
    return `
      <div class="payload response ${response.status >= 400 ? 'error' : ''}">
        <div class="payload-header">RESPONSE${duration}</div>
        <div class="status">Status: ${response.status} ${response.statusText || ''}</div>
        ${response.headers ? `<div class="headers">Headers: ${this.formatJson(response.headers)}</div>` : ''}
        ${response.body !== undefined ? `<div class="body">Body: ${this.formatJson(response.body)}</div>` : ''}
      </div>
    `;
  }
  
  renderError(error) {
    return `
      <div class="payload error-details">
        <div class="payload-header">ERROR DETAILS</div>
        ${error.message ? `<div class="error-message">${this.escapeHtml(error.message)}</div>` : ''}
        ${error.stack ? `<pre class="stack-trace">${this.escapeHtml(error.stack)}</pre>` : ''}
        ${error.code ? `<div class="error-code">Code: ${error.code}</div>` : ''}
      </div>
    `;
  }
  
  renderAdditionalData(data) {
    return `
      <div class="payload additional-data">
        <div class="payload-header">ADDITIONAL DATA</div>
        <pre>${this.formatJson(data)}</pre>
      </div>
    `;
  }
  
  extractAdditionalData(log) {
    const knownFields = [
      '@timestamp', '@service', '@traceId', '@sessionId', '@environment', '@backend_received',
      'timestamp', 'service', 'traceId', 'sessionId', 'environment',
      'level', 'type', 'message', 'error', 'request', 'response',
      'method', 'path', 'query', 'body', 'headers', 'statusCode',
      'url', 'userAgent', 'ip', 'duration'
    ];
    
    const additional = {};
    Object.entries(log).forEach(([key, value]) => {
      if (!knownFields.includes(key) && value !== undefined && value !== null) {
        additional[key] = value;
      }
    });
    
    return additional;
  }
  
  formatJson(obj) {
    if (obj === null) return 'null';
    if (obj === undefined) return 'undefined';
    
    try {
      if (typeof obj === 'string') {
        // Try to parse if it looks like JSON
        if (obj.startsWith('{') || obj.startsWith('[')) {
          try {
            obj = JSON.parse(obj);
          } catch {
            return this.escapeHtml(obj);
          }
        } else {
          return this.escapeHtml(obj);
        }
      }
      
      if (typeof obj === 'object') {
        return this.escapeHtml(JSON.stringify(obj, null, 2));
      }
      
      return this.escapeHtml(String(obj));
    } catch (error) {
      return this.escapeHtml(String(obj));
    }
  }
  
  formatTime(timestamp) {
    if (!timestamp) return 'N/A';
    
    try {
      const date = new Date(timestamp);
      const now = new Date();
      const diff = now - date;
      
      // If less than 1 minute ago, show seconds
      if (diff < 60000) {
        return `${Math.floor(diff / 1000)}s ago`;
      }
      
      // If less than 1 hour ago, show minutes
      if (diff < 3600000) {
        return `${Math.floor(diff / 60000)}m ago`;
      }
      
      // Otherwise show time
      return date.toLocaleTimeString();
    } catch {
      return timestamp;
    }
  }
  
  escapeHtml(unsafe) {
    if (unsafe === null || unsafe === undefined) return '';
    
    return String(unsafe)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;");
  }
  
  toggleTrace(traceId) {
    const element = document.getElementById(`trace-${CSS.escape(traceId)}`);
    if (element) {
      const isVisible = element.style.display !== 'none';
      element.style.display = isVisible ? 'none' : 'block';
    }
  }
  
  expandAll() {
    document.querySelectorAll('.trace-content').forEach(el => {
      el.style.display = 'block';
    });
  }
  
  collapseAll() {
    document.querySelectorAll('.trace-content').forEach(el => {
      el.style.display = 'none';
    });
  }
  
  toggleAutoRefresh() {
    this.autoRefresh = !this.autoRefresh;
    
    if (this.autoRefresh) {
      this.elements.autoRefreshBtn.textContent = '⏹️ Stop Auto-Refresh';
      this.elements.autoRefreshBtn.classList.add('active');
      this.refreshInterval = setInterval(() => this.loadLatest(), 2000);
    } else {
      this.elements.autoRefreshBtn.textContent = '⏱️ Auto-Refresh';
      this.elements.autoRefreshBtn.classList.remove('active');
      clearInterval(this.refreshInterval);
    }
  }
  
  showLoading() {
    this.elements.container.innerHTML = '<div class="loading">Loading logs...</div>';
  }
  
  showError(message) {
    this.elements.container.innerHTML = `<div class="error-message">Error: ${this.escapeHtml(message)}</div>`;
    this.updateStatus('Error loading logs');
  }
  
  updateStatus(message) {
    this.elements.statusDiv.textContent = message;
  }
}

// Initialize on page load
let logViewer;
document.addEventListener('DOMContentLoaded', () => {
  logViewer = new LogViewer();
});

// Export for global access
window.LogViewer = LogViewer;