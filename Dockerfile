# Single-file multi-stage Dockerfile (Debian-based) that is robust for native modules
# - Uses node:18-bullseye for builder (better compatibility with native builds)
# - Uses node:18-bullseye-slim for final runtime to keep image smaller
# - Supports private npm registries via build arg NPM_TOKEN (kept out of final image)
# - Keeps npm errors visible (no --silent) so builds fail with useful output
#
# Usage examples:
#  - Public packages:
#      docker build -t affine:local .
#  - Private packages (pass token; DO NOT commit token):
#      docker build --build-arg NPM_TOKEN=${NPM_TOKEN} -t affine:local .
#
# If you are using minikube, prefer: eval $(minikube docker-env) && docker build -t affine:local .

########################################
# Builder stage
########################################
FROM node:18-bullseye AS builder
WORKDIR /app
# Accept an optional NPM token for private registry access during build
ARG NPM_TOKEN

# Copy lock and package files first to leverage Docker layer cache
COPY package*.json ./

# If an NPM token is provided, write a temporary .npmrc so npm can install private packages.
# We remove the .npmrc after installing so it doesn't remain in the build layers.
RUN if [ -n "$NPM_TOKEN" ]; then \
      printf "//registry.npmjs.org/:_authToken=%s\n" "$NPM_TOKEN" > .npmrc; \
    fi && \
    npm ci --no-audit --prefer-offline && \
    rm -f .npmrc

# Copy rest of the source
COPY . .

# If your project has a build step (React/Vite/TS/etc.) uncomment the following:
# RUN npm run build

########################################
# Runner stage
########################################
FROM node:18-bullseye-slim AS runner
WORKDIR /app
ENV NODE_ENV=production
ARG NPM_TOKEN

# Copy package files and install only production dependencies.
COPY package*.json ./

# If private packages are required at runtime installation, temporarily add .npmrc here too.
RUN if [ -n "$NPM_TOKEN" ]; then \
      printf "//registry.npmjs.org/:_authToken=%s\n" "$NPM_TOKEN" > .npmrc; \
    fi && \
    npm ci --only=production --no-audit --prefer-offline && \
    rm -f .npmrc || true

# Copy application files from the builder stage (includes built assets if you ran a build step)
COPY --from=builder /app ./

# Adjust the port to your app's listening port
EXPOSE 3000

# Use the appropriate start command for your app. Change if needed.
CMD ["npm", "start"]
