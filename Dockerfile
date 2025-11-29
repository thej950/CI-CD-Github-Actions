# Stage 1: Builder
FROM node:20-alpine AS builder
WORKDIR /app
RUN mkdir -p /app/dist

COPY index.js /app/dist/index.js
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build --if-present

# Stage 2: Production image
FROM node:20-alpine AS prod
WORKDIR /app

COPY --from=builder /app/dist ./dist
COPY package*.json ./

RUN npm ci --only=production

CMD ["node", "dist/index.js"]