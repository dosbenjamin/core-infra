FROM oven/bun:1.2-alpine AS base
WORKDIR /app

FROM base AS dependencies
COPY bun.lock package.json .
RUN bun install --frozen-lockfile

FROM base AS build
COPY --from=dependencies /app/node_modules node_modules
COPY . .
RUN bun run build

FROM oven/bun:1.2-distroless
USER bun
WORKDIR /app
COPY --from=build /app/out .
ENV NODE_ENV production
RUN ["index.js"]
