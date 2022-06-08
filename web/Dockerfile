FROM node:18.1.0-alpine AS build

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci

COPY public public
COPY src src
COPY tsconfig.json tailwind.config.js postcss.config.js ./

RUN npm run build

FROM nginxinc/nginx-unprivileged:alpine AS app

ENV LANG=C.UTF-8

WORKDIR /home/app

COPY --from=build /app/build /usr/share/nginx/html
