# Base Stage
FROM node:lts-alpine3.18 as base
WORKDIR /usr/src/wpp-server
ENV NODE_ENV=production PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && \
    pnpm install --production && \
    pnpm cache clean

# Build Stage
FROM base as build
WORKDIR /usr/src/wpp-server
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --production=false && \
    pnpm cache clean
COPY . .
RUN pnpm build

# Final Stage
FROM base
WORKDIR /usr/src/wpp-server/
RUN apk add --no-cache chromium
RUN pnpm cache clean
COPY . .
COPY --from=build /usr/src/wpp-server/ /usr/src/wpp-server/
EXPOSE 21465
ENTRYPOINT ["node", "dist/server.js"]
