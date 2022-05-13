FROM node:18.1.0-alpine AS build

RUN npm install -g esbuild

WORKDIR /app

COPY . .
RUN npm i && npm run build

FROM nginxinc/nginx-unprivileged:alpine AS app

ENV LANG=C.UTF-8

WORKDIR /home/app

COPY --from=build /app/public /usr/share/nginx/html
