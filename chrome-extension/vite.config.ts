import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { resolve } from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@shared': resolve(__dirname, 'src/shared'),
      '@background': resolve(__dirname, 'src/background'),
      '@popup': resolve(__dirname, 'src/popup'),
    },
  },
  build: {
    outDir: 'dist',
    emptyOutDir: true,
    rollupOptions: {
      input: {
        popup: resolve(__dirname, 'popup.html'),
        background: resolve(__dirname, 'src/background/index.ts'),
        'content-bridge': resolve(__dirname, 'src/content/bridge.ts'),
        'content-inpage': resolve(__dirname, 'src/content/inpage.ts'),
      },
      output: {
        entryFileNames: (chunkInfo) => {
          if (chunkInfo.name === 'background') return 'background.js';
          if (chunkInfo.name === 'content-bridge') return 'content-bridge.js';
          if (chunkInfo.name === 'content-inpage') return 'content-inpage.js';
          return 'assets/[name]-[hash].js';
        },
      },
    },
    // Chrome extension requirements
    target: 'esnext',
    minify: 'terser',
  },
});
