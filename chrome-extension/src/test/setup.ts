import { webcrypto } from 'node:crypto';
import { beforeEach, vi } from 'vitest';

Object.defineProperty(globalThis, 'crypto', { value: webcrypto, configurable: true });

const storage = new Map<string, unknown>();
Object.defineProperty(globalThis, 'chrome', {
  value: {
    storage: {
      local: {
        get: vi.fn(async (key: string) => ({ [key]: storage.get(key) })),
        set: vi.fn(async (items: Record<string, unknown>) => {
          for (const [key, value] of Object.entries(items)) storage.set(key, value);
        }),
      },
    },
  },
  configurable: true,
});

beforeEach(() => storage.clear());
