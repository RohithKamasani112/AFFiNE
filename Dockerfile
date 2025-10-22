# Use the official Affine image as a base
FROM ghcr.io/toeverything/affine:stable

# Set working directory
WORKDIR /root/.affine

# Copy optional configuration or uploads (if you have them)
# You can create these folders in your repo to customize storage/config
COPY config ./config
COPY storage ./storage

# Expose Affine port
EXPOSE 3010

# Environment variables (override via .env in Compose or Helm)
ENV AFFINE_INDEXER_ENABLED=false \
    REDIS_SERVER_HOST=redis \
    DATABASE_URL=postgresql://postgres:password@postgres:5432/affine

# Run the Affine server
CMD ["npm", "run", "start"]
