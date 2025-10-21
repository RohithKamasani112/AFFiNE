# Multi-stage Dockerfile for a Node.js application.
# - stage "builder": installs dev deps and builds the app if you have a build step
# - stage "runner": installs only production deps and runs the app
#
# Edit npm commands (build, start) and the EXPOSE port to match your project.

FROM node:18-alpine AS builder
WORKDIR /app

# Copy package files first to leverage Docker cache
COPY package*.json ./

# If your project uses yarn, replace with `yarn install --frozen-lockfile`
RUN npm ci --silent

# Copy the rest of the source
COPY . .

# If your project has a build step (e.g., React, Next, TS), uncomment the next line:
# RUN npm run build

# Final smaller image
FROM node:18-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Copy package files and install only production deps
COPY package*.json ./
RUN npm ci --production --silent

# Copy app files from builder stage.
# If your build outputs to /app/build or /app/dist, copy that instead.
COPY --from=builder /app ./

# Change this to your app's listening port
EXPOSE 3000

# Default start command, change if your project uses e.g. "node server.js" or "npm run start:prod"
CMD ["npm", "start"]
