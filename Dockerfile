# Simple single-stage Dockerfile (keeps build simple; uses npm install so it works without package-lock.json)
# Use this if you want the easiest-to-run Dockerfile. It is larger than multi-stage images but simple to debug.
FROM node:18-bullseye-slim

# Create app directory
WORKDIR /app

# Copy only package files first to leverage layer caching
COPY package*.json ./

# Install dependencies (uses npm install so it does not require package-lock.json)
RUN npm install --no-audit --prefer-offline

# Copy application source
COPY . .

# Adjust port to your application's listening port
EXPOSE 3000

# Default start command - change if your app uses a different script or entrypoint
CMD ["npm", "start"]
