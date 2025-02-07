FROM oven/bun:1.2-alpine AS base
ENV NODE_ENV production

FROM base AS dependencies
WORKDIR /app
COPY bun.lock package.json .
RUN bun install --frozen-lockfile

FROM base AS build
WORKDIR /app
COPY --from=dependencies /app/node_modules node_modules
COPY . .
RUN bun run build

FROM base
RUN apk add postgresql-client
USER bun
WORKDIR /app
COPY --from=build /app/out .
CMD ["bun", "run", "index.js"]
