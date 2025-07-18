const express = require('express');
const fs = require('fs');
const path = require('path');
const readline = require('readline');

const app = express();
const PORT = 4000;
const LOG_FILE = '/logs/trivance-unified.json';

// Middleware
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// API endpoint for searching logs
app.get('/api/logs/search', async (req, res) => {
  const { traceId, sessionId, service, level, text, from, to, limit = 1000 } = req.query;
  const results = [];
  
  try {
    // Check if log file exists
    if (!fs.existsSync(LOG_FILE)) {
      return res.json({ logs: [], message: 'Log file not found' });
    }
    
    const fileStream = fs.createReadStream(LOG_FILE);
    const rl = readline.createInterface({
      input: fileStream,
      crlfDelay: Infinity
    });
    
    for await (const line of rl) {
      if (line.trim()) {
        try {
          let log = JSON.parse(line);
          
          // Handle nested logs from backend (Winston wrapper)
          if (log.message && typeof log.message === 'object' && log.message['@service']) {
            log = log.message;
          }
          
          // Apply filters
          if (traceId && log['@traceId'] !== traceId) continue;
          if (sessionId && log['@sessionId'] !== sessionId) continue;
          if (service && log['@service'] !== service) continue;
          if (level && log.level !== level) continue;
          if (text && !JSON.stringify(log).toLowerCase().includes(text.toLowerCase())) continue;
          if (from && new Date(log['@timestamp']) < new Date(from)) continue;
          if (to && new Date(log['@timestamp']) > new Date(to)) continue;
          
          results.push(log);
          
          // Limit results
          if (results.length >= parseInt(limit)) break;
        } catch (parseError) {
          console.error('Error parsing log line:', parseError);
        }
      }
    }
    
    // Sort by timestamp
    results.sort((a, b) => new Date(a['@timestamp']) - new Date(b['@timestamp']));
    
    res.json({ logs: results, count: results.length });
  } catch (error) {
    console.error('Error reading logs:', error);
    res.status(500).json({ error: 'Error reading logs', message: error.message });
  }
});

// API endpoint for getting latest logs
app.get('/api/logs/latest', async (req, res) => {
  const { limit = 100 } = req.query;
  const logs = [];
  
  try {
    if (!fs.existsSync(LOG_FILE)) {
      return res.json({ logs: [], message: 'Log file not found' });
    }
    
    // Read file in reverse to get latest logs
    const fileContent = fs.readFileSync(LOG_FILE, 'utf-8');
    const lines = fileContent.trim().split('\n');
    
    for (let i = lines.length - 1; i >= 0 && logs.length < limit; i--) {
      if (lines[i].trim()) {
        try {
          const log = JSON.parse(lines[i]);
          logs.push(log);
        } catch (e) {
          console.error('Error parsing log line:', e);
        }
      }
    }
    
    res.json({ logs: logs.reverse(), count: logs.length });
  } catch (error) {
    console.error('Error reading latest logs:', error);
    res.status(500).json({ error: 'Error reading logs', message: error.message });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', logFile: fs.existsSync(LOG_FILE) });
});

// Start server
app.listen(PORT, () => {
  console.log(`Log viewer server running on port ${PORT}`);
  console.log(`Log file: ${LOG_FILE}`);
  console.log(`File exists: ${fs.existsSync(LOG_FILE)}`);
});