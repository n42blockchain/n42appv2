import { defineConfig, type Plugin } from 'vite';
import react from '@vitejs/plugin-react';
import { dirname, resolve } from 'path';
import { cpSync, existsSync } from 'fs';
import { fileURLToPath } from 'url';

const configDir = dirname(fileURLToPath(import.meta.url));

/**
 * Chrome 只认 dist/ 目录里现成的 manifest.json + icons/ ——Vite 自身的资源
 * 管线不会把它们从项目根目录带过去。用最小的自定义插件在构建结束时拷贝，
 * 不为此单独引入 vite-plugin-web-extension（那会连带要求把整份多入口
 * rollupOptions 配置改写为它的 manifest 驱动格式，改动面更大、风险更高）。
 */
function copyExtensionAssets(): Plugin {
  return {
    name: 'copy-extension-assets',
    closeBundle() {
      const root = configDir;
      const outDir = resolve(root, 'dist');
      cpSync(resolve(root, 'manifest.json'), resolve(outDir, 'manifest.json'));
      const iconsDir = resolve(root, 'icons');
      if (existsSync(iconsDir)) {
        cpSync(iconsDir, resolve(outDir, 'icons'), { recursive: true });
      }
    },
  };
}

export default defineConfig({
  plugins: [react(), copyExtensionAssets()],
  resolve: {
    alias: {
      '@shared': resolve(configDir, 'src/shared'),
      '@background': resolve(configDir, 'src/background'),
      '@popup': resolve(configDir, 'src/popup'),
    },
  },
  build: {
    outDir: 'dist',
    emptyOutDir: true,
    rollupOptions: {
      input: {
        popup: resolve(configDir, 'popup.html'),
        background: resolve(configDir, 'src/background/index.ts'),
        'content-bridge': resolve(configDir, 'src/content/bridge.ts'),
        'content-inpage': resolve(configDir, 'src/content/inpage.ts'),
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
