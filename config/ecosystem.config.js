// Configuración PM2 para arquitectura híbrida
// Solo contiene el frontend - Backends van en Docker
module.exports = {
  apps: [
    {
      name: 'backoffice',
      cwd: process.env.WORKSPACE_DIR ? `${process.env.WORKSPACE_DIR}/level_up_backoffice` : '../../level_up_backoffice',
      script: 'npm',
      args: 'run dev',
      env: {
        NODE_ENV: 'development',
        VITE_API_URL: 'http://localhost:3000',
        VITE_AUTH_API_URL: 'http://localhost:3001'
      },
      // Configuración optimizada para frontend
      instances: 1,
      exec_mode: 'fork',
      watch: false,  // Vite ya tiene hot-reload
      max_memory_restart: '1G',
      error_file: './logs/backoffice-error.log',
      out_file: './logs/backoffice-out.log',
      log_file: './logs/backoffice-combined.log',
      time: true
    }
  ]
};