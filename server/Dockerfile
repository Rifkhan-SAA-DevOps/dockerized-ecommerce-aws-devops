FROM node:20-alpine

WORKDIR /app

# Alpine image may not include wget or curl
# We need it because Docker Compose healthcheck will use wget.
RUN apk add --no-cache wget  

COPY package*.json ./


RUN npm install

COPY . .

EXPOSE 5000

CMD ["npm", "start"]