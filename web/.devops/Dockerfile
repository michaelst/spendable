FROM node:18.1.0-alpine AS build

RUN npm install -g esbuild

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci

COPY public public
COPY scripts scripts
COPY src src
COPY tsconfig.json ./

RUN npm run build

FROM nginxinc/nginx-unprivileged:alpine AS app

ENV LANG=C.UTF-8

WORKDIR /home/app

COPY --from=build /app/public /usr/share/nginx/html
