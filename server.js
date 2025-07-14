const express = require('express');
const chromeLauncher = require('chrome-launcher');

const app = express();
let chrome;

app.use(express.json());

async function startChrome() {
  if (chrome) {
    console.log('Chrome already running');
    return chrome;
  }

  try {
    chrome = await chromeLauncher.launch({
      port: 9222,
      chromeFlags: [
        '--headless',
        '--disable-gpu',
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--remote-debugging-port=9222',
        '--remote-debugging-address=0.0.0.0',
        '--disable-dev-shm-usage',
        '--disable-extensions',
        '--disable-plugins',
        '--disable-images',
        '--disable-background-timer-throttling',
        '--disable-backgrounding-occluded-windows',
        '--disable-renderer-backgrounding'
      ]
    });
    
    console.log('✅ Chrome launched successfully');
    console.log(`📍 Chrome DevTools: http://localhost:${chrome.port}`);
    console.log(`🔌 WebSocket endpoint: ws://localhost:${chrome.port}`);
    
    return chrome;
  } catch (error) {
    console.error('❌ Failed to launch Chrome:', error);
    throw error;
  }
}

// Routes
app.get('/', (req, res) => {
  res.json({
    service: 'Chrome Endpoint Server',
    status: chrome ? 'running' : 'stopped',
    endpoints: {
      info: '/info',
      start: '/start',
      stop: '/stop',
      restart: '/restart'
    }
  });
});

app.get('/info', (req, res) => {
  if (!chrome) {
    return res.status(404).json({
      error: 'Chrome not running',
      message: 'Use /start to launch Chrome'
    });
  }
  
  res.json({
    status: 'running',
    pid: chrome.pid,
    port: chrome.port,
    devtools: `http://localhost:${chrome.port}`,
    websocket: `ws://localhost:${chrome.port}`,
    version_url: `http://localhost:${chrome.port}/json/version`
  });
});

app.post('/start', async (req, res) => {
  try {
    const chromeInstance = await startChrome();
    res.json({
      success: true,
      message: 'Chrome started successfully',
      pid: chromeInstance.pid,
      port: chromeInstance.port,
      websocket: `ws://localhost:${chromeInstance.port}`
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

app.post('/stop', async (req, res) => {
  if (!chrome) {
    return res.status(404).json({
      error: 'Chrome not running'
    });
  }
  
  try {
    await chrome.kill();
    chrome = null;
    res.json({
      success: true,
      message: 'Chrome stopped successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

app.post('/restart', async (req, res) => {
  try {
    if (chrome) {
      await chrome.kill();
      chrome = null;
    }
    
    const chromeInstance = await startChrome();
    res.json({
      success: true,
      message: 'Chrome restarted successfully',
      pid: chromeInstance.pid,
      port: chromeInstance.port,
      websocket: `ws://localhost:${chromeInstance.port}`
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    chrome: chrome ? 'running' : 'stopped',
    uptime: process.uptime(),
    memory: process.memoryUsage()
  });
});

// Cleanup function
async function cleanup() {
  console.log('\n🧹 Cleaning up...');
  if (chrome) {
    try {
      await chrome.kill();
      console.log('✅ Chrome process terminated');
    } catch (error) {
      console.error('❌ Error killing Chrome:', error);
    }
  }
  process.exit(0);
}

// Handle process termination
process.on('SIGINT', cleanup);
process.on('SIGTERM', cleanup);
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  cleanup();
});

// Start server
const PORT = process.env.PORT || 3000;

async function startServer() {
  try {
    // Auto-start Chrome when server starts
    await startChrome();
    
    app.listen(PORT, () => {
      console.log(`\n🚀 Server running on port ${PORT}`);
      console.log(`📊 API endpoints:`);
      console.log(`   GET  http://localhost:${PORT}/`);
      console.log(`   GET  http://localhost:${PORT}/info`);
      console.log(`   POST http://localhost:${PORT}/start`);
      console.log(`   POST http://localhost:${PORT}/stop`);
      console.log(`   POST http://localhost:${PORT}/restart`);
      console.log(`   GET  http://localhost:${PORT}/health`);
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
}

startServer();