import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig(({ command }) => {
  const config = {
    plugins: [react()],
    server: {
      port: 3000,
      open: true
    },
    build: {
      outDir: 'dist',
      sourcemap: true
    }
  }
  
  // Set the base path depending on the mode
  if (command === 'build' || command === 'serve') {
    // For production build and preview
    config.base = '/elmentor-landing-page-clean/'
  } else {
    // For development
    config.base = '/'
  }
  
  return config
})
