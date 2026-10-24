# Single container for cloud hosting: the API also serves the built web app (WEB_DIST).
# Local multi-container setup: see docker-compose.yml.
FROM node:22-alpine AS web
WORKDIR /app
COPY package.json turbo.json tsconfig.base.json ./
COPY packages/shared/package.json packages/shared/
COPY packages/rules-engine/package.json packages/rules-engine/
COPY apps/web/package.json apps/web/
COPY apps/api/package.json apps/api/
COPY apps/ai-service/package.json apps/ai-service/
RUN npm install --workspace=@onboardiq/web --include=dev --no-audit --no-fund
COPY packages/shared/ packages/shared/
COPY apps/web/ apps/web/
RUN npm run build --workspace=@onboardiq/web

FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY package.json turbo.json tsconfig.base.json ./
COPY packages/shared/package.json packages/shared/
COPY packages/rules-engine/package.json packages/rules-engine/
COPY apps/api/package.json apps/api/
COPY apps/web/package.json apps/web/
COPY apps/ai-service/package.json apps/ai-service/
RUN npm install --workspace=@onboardiq/api --include=dev --no-audit --no-fund

COPY packages/ packages/
COPY apps/api/ apps/api/
COPY data/ data/
COPY --from=web /app/apps/web/dist /app/web-dist

RUN mkdir -p storage/documents output && chown -R node:node /app
USER node

ENV WEB_DIST=/app/web-dist \
    SEED_ON_START=true \
    PORT=4000
EXPOSE 4000
WORKDIR /app/apps/api
CMD ["npx", "tsx", "src/index.ts"]
