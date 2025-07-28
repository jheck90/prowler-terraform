# These were the changes I needed to make to Prowler source to get this to work

1. Pull source https://github.com/prowler-cloud/prowler, as of https://github.com/prowler-cloud/prowler/commit/92a804bf88e57424d3468bc31e3e838854696269
2. api/src/backend/config/settings/celery.py

```python
from config.env import env

VALKEY_HOST = env("VALKEY_HOST", default="valkey")
VALKEY_PORT = env("VALKEY_PORT", default="6379")
VALKEY_DB = env("VALKEY_DB", default="0")
VALKEY_SSL = env.bool("VALKEY_SSL", default=False)

# Construct broker URL with SSL support
if VALKEY_SSL:
    CELERY_BROKER_URL = (
        f"rediss://{VALKEY_HOST}:{VALKEY_PORT}/{VALKEY_DB}?ssl_cert_reqs=none"
    )
else:
    CELERY_BROKER_URL = f"redis://{VALKEY_HOST}:{VALKEY_PORT}/{VALKEY_DB}"

CELERY_RESULT_BACKEND = "django-db"
CELERY_TASK_TRACK_STARTED = True
CELERY_BROKER_CONNECTION_RETRY_ON_STARTUP = True
CELERY_DEADLOCK_ATTEMPTS = env.int("DJANGO_CELERY_DEADLOCK_ATTEMPTS", default=5)
```

3. ui/next.config.js

```javascript
/** @type {import('next').NextConfig} */

// HTTP Security Headers
// 'unsafe-eval' is configured under `script-src` because it is required by NextJS for development mode
const cspHeader = `
  default-src 'self';
  script-src 'self' 'unsafe-inline' 'unsafe-eval' https://js.stripe.com https://www.googletagmanager.com;
  connect-src 'self' https://api.iconify.design https://api.simplesvg.com https://api.unisvg.com https://js.stripe.com https://www.googletagmanager.com;
  img-src 'self' https://www.google-analytics.com https://www.googletagmanager.com;
  font-src 'self';
  style-src 'self' 'unsafe-inline';
  frame-src 'self' https://js.stripe.com https://www.googletagmanager.com;
  frame-ancestors 'none';
`;

module.exports = {
  poweredByHeader: false,
  // Use standalone only in production deployments, not for CI/testing
  ...(process.env.NODE_ENV === "production" &&
    !process.env.CI && {
      output: "standalone",
    }),
  // Configure server to bind to all interfaces
  experimental: {
    serverComponentsExternalPackages: [],
  },
  async headers() {
    return [
      {
        source: "/(.*)",
        headers: [
          {
            key: "Content-Security-Policy",
            value: cspHeader.replace(/\n/g, ""),
          },
          {
            key: "X-Content-Type-Options",
            value: "nosniff",
          },
          {
            key: "Referrer-Policy",
            value: "strict-origin-when-cross-origin",
          },
        ],
      },
    ];
  },
};
```

4. ui/app/api/health/route.ts

```typescript
import { NextResponse } from "next/server";

export async function GET() {
  return NextResponse.json({ status: "ok" }, { status: 200 });
}
```

5. replace whatever Dockerfiles are in `/ui` or `/api` with what I have in this dir.
6. Push those built docker images to your local ECR, and point ECS to them.
