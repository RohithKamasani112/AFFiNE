# Base image
FROM ghcr.io/toeverything/affine:stable

WORKDIR /root/.affine

# Always ensure these directories exist
RUN mkdir -p config storage

# Expose Affine port
EXPOSE 3010

# Environment variables
ENV AFFINE_INDEXER_ENABLED=false \
    REDIS_SERVER_HOST=redis \
    DATABASE_URL=postgresql://postgres:password@postgres:5432/affine

# Start Affine
CMD ["npm", "run", "start"]
