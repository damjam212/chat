# Stage 1: Build the React application
FROM node:16-alpine AS public-build
WORKDIR /usr/src
COPY public/ ./public/
RUN cd public && npm install && npm run build

# Stage 2: Install dependencies for the server
FROM node:16-alpine AS server-build
WORKDIR /usr/src
COPY server/ ./server/
RUN cd server && npm install && ENVIRONMENT=production npm run build
RUN ls

# Final Stage: Combine built React app with the server
FROM node:16-alpine
WORKDIR /root/

COPY --from=public-build /usr/src/public/build ./public/build
COPY --from=server-build /usr/src/server/dist .
RUN ls

EXPOSE 8080

CMD ["node", "api.bundle.js"]
