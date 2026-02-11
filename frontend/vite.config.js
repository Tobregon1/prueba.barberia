import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { visualizer } from 'rollup-plugin-visualizer'

export default defineConfig(({ command }) => ({
  plugins: [react(), visualizer({ filename: './dist/stats.html', open: false })],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true
      }
    }
  },
  build: {
    // Ajusta el límite de advertencia si quieres, y configura manualChunks
    chunkSizeWarningLimit: 700,
    rollupOptions: {
      output: {
        manualChunks(id) {
          if (id.includes('node_modules')) {
            if (id.includes('recharts') || id.includes('chart')) return 'vendor-charts'
            if (id.includes('react')) return 'vendor-react'
            return 'vendor'
          }
        }
      }
    }
  }
}))
