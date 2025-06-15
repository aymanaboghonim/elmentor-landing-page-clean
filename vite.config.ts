import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    open: true
  },
  build: {
    outDir: 'dist',
    sourcemap: true
  },
  // Using elmentor-landing-page-clean as the repository name
  // Change this to match your actual repository name on GitHub
  base: '/elmentor-landing-page-clean/'
})
