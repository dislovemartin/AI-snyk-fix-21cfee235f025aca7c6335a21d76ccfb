
# Rust Service Dockerfile
FROM rust:1.58

WORKDIR /app
COPY . .
RUN cargo build --release

EXPOSE 8081
CMD ["./target/release/rust-service"]
