/// <reference types="vitest" />
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { fileURLToPath } from 'node:url';

const shared = fileURLToPath(new URL('../shared', import.meta.url));

export default defineConfig({
  plugins: [react()],
  resolve: { alias: { '@shared': shared } },
  server: { fs: { allow: ['..'] }, port: 5173 },
  build: { outDir: 'dist', sourcemap: false },
  test: { environment: 'jsdom', include: ['src/**/*.test.{ts,tsx}'] },
});
