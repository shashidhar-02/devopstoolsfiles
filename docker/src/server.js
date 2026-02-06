// Simple Node.js application demonstrating production patterns
// - Health checks  - Security headers
// - Graceful shutdown
// - Request logging
// - Error handling

import { createServer } from 'http';
import { hostname as _hostname } from 'os';

// Configuration from environment
const PORT = process.env.PORT || 3000;
const HOST = '0.0.0.0';
const NODE_ENV = process.env.NODE_ENV || 'development';
const LOG_LEVEL = process.env.LOG_LEVEL || 'info';

// Logger
const logger = {
    info: (msg) => console.log(`[INFO] ${new Date().toISOString()} ${msg}`),
    warn: (msg) => console.warn(`[WARN] ${new Date().toISOString()} ${msg}`),
    error: (msg) => console.error(`[ERROR] ${new Date().toISOString()} ${msg}`),
    debug: (msg) => LOG_LEVEL === 'debug' && console.log(`[DEBUG] ${new Date().toISOString()} ${msg}`)
};

// Request metrics
const metrics = {
    requests: 0,
    errors: 0,
    uptime: Date.now(),
    lastError: null
};

// Request logging middleware
function logRequest(req, res, next) {
    const start = Date.now();
    const id = Math.random().toString(36).substr(2, 9);
    
    logger.info(`[${id}] ${req.method} ${req.url}`);
    
    // Track response completion
    res.on('finish', () => {
        const duration = Date.now() - start;
        logger.info(`[${id}] ${res.statusCode} (${duration}ms)`);
        metrics.requests++;
    });
    
    next();
}

// Routes
const routes = {
    '/health': handleHealth,
    '/ready': handleReady,
    '/metrics': handleMetrics,
    '/': handleHome,
};

// Health endpoint (liveness)
function handleHealth(req, res) {
    const health = {
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: (Date.now() - metrics.uptime) / 1000
    };
    
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(health));
}

// Readiness endpoint
function handleReady(req, res) {
    const ready = {
        status: 'ready',
        database: process.env.DATABASE_HOST ? 'configured' : 'unconfigured',
        redis: process.env.REDIS_HOST ? 'configured' : 'unconfigured',
        timestamp: new Date().toISOString()
    };
    
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(ready));
}

// Metrics endpoint
function handleMetrics(req, res) {
    const metrics_data = {
        requests: metrics.requests,
        errors: metrics.errors,
        uptime: (Date.now() - metrics.uptime) / 1000,
        memory: process.memoryUsage(),
        hostname: _hostname(),
        environment: NODE_ENV
    };
    
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(metrics_data));
}

// Home endpoint
function handleHome(req, res) {
    const html = `
    <!DOCTYPE html>
    <html>
    <head>
        <title>DevOps Application</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; }
            pre { background: #f4f4f4; padding: 10px; border-radius: 5px; }
        </style>
    </head>
    <body>
        <h1>🚀 DevOps Application Running</h1>
        <p>Environment: ${NODE_ENV}</p>
        <p>Hostname: ${_hostname()}</p>
        
        <h2>Available Endpoints</h2>
        <ul>
            <li><a href="/health">/health</a> - Liveness check</li>
            <li><a href="/ready">/ready</a> - Readiness check</li>
            <li><a href="/metrics">/metrics</a> - Metrics</li>
        </ul>
    </body>
    </html>
    `;
    
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end(html);
}

// 404 handler
function handle404(req, res) {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ 
        error: 'Not Found',
        message: `Route ${req.url} not found`,
        availableRoutes: Object.keys(routes)
    }));
}

// Create server
const server = createServer((req, res) => {
    // Security headers
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('X-XSS-Protection', '1; mode=block');
    res.setHeader('Strict-Transport-Security', 'max-age=3600');
    
    // CORS (if needed)
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, HEAD');
    
    // Parse URL
    const url = new URL(req.url, `http://${req.headers.host}`).pathname;
    
    // Route request
    const handler = routes[url] || handle404;
    
    try {
        handler(req, res);
    } catch (error) {
        logger.error(`Unhandled error: ${error.message}`);
        metrics.errors++;
        metrics.lastError = error.message;
        
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ 
            error: 'Internal Server Error',
            message: NODE_ENV === 'development' ? error.message : 'An error occurred'
        }));
    }
});

// Graceful shutdown
function gracefulShutdown(signal) {
    logger.info(`Received ${signal}, shutting down gracefully...`);
    
    server.close(() => {
        logger.info('Server closed, exiting process');
        process.exit(0);
    });
    
    // Force shutdown after 10 seconds
    setTimeout(() => {
        logger.error('Forcing shutdown after timeout');
        process.exit(1);
    }, 10000);
}

// Signal handlers
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Error handling
process.on('uncaughtException', (error) => {
    logger.error(`Uncaught Exception: ${error.message}`);
    metrics.errors++;
    process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
    logger.error(`Unhandled Rejection: ${reason}`);
    metrics.errors++;
});

// Start server
server.listen(PORT, HOST, () => {
    logger.info(`Server started on ${HOST}:${PORT}`);
    logger.info(`Environment: ${NODE_ENV}`);
    logger.info(`Process PID: ${process.pid}`);
    logger.info(`Node version: ${process.version}`);
});

export default server;
