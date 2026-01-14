
# Beispiel: Node.js
FROM dhi.io/node24 AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build || echo "no build step, continue"

FROM dhi.io/node24
WORKDIR /app
COPY --from=build /app ./
EXPOSE 3000
CMD ["npm", "start"]
