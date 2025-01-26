FROM denoland/deno:latest

WORKDIR /app

COPY . .

RUN deno cache src/main.ts

EXPOSE 6858

CMD ["deno", "run", "--allow-net", "--allow-read", "src/main.ts"]