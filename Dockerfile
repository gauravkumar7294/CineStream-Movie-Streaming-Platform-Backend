# ==========================
# STAGE 1: Builder
# ==========================
FROM rust:1.89 AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && \
    apt-get install -y pkg-config libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# Copy the entire project
COPY . .

# (Optional) Verify Rust version during build
RUN rustc --version
RUN cargo --version

# Build the application
RUN cargo build --release

# ==========================
# STAGE 2: Runtime
# ==========================
FROM debian:bookworm-slim

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y openssl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Copy the compiled binary
COPY --from=builder /app/target/release/netflix_backend /usr/local/bin/app

# Copy assets
COPY assets ./assets

# Expose the application port
ENV PORT=8080
EXPOSE 8080

# Run the application
CMD ["app"]