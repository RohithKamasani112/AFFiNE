# Use the official Affine base image
FROM ghcr.io/toeverything/affine:stable

WORKDIR /root/.affine

# Create directories even if you don't copy anything
RUN mkdir -p /root/.affine/config /root/.affine/storage

# Copy only if they exist
# Using a trick to avoid build errors
COPY config ./config 2>/dev/null || true
COPY storage ./storage 2>/dev/null || true

EXPOSE 3010

ENV AFFINE_INDEXER_ENABLED=false \
    REDIS_SERVER_HOST=redis \
    DATABASE_URL=postgresql://postgres:password@postgres:5432/affine

CMD ["npm", "run", "start"]
