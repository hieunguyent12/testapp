FROM lukemathwalker/cargo-chef:latest-rust-1.68.0 as chef 
WORKDIR /app
RUN apt update && apt install lld clang -y

FROM chef as planner
COPY . .

# Compute a lock-like file for our project
RUN cargo chef prepare --recipe-path recipe.json
FROM chef as builder
COPY --from=planner /app/recipe.json recipe.json
# Build our project dependencies, not our application!
RUN cargo chef cook --release --recipe-path recipe.json
# Up to this point, if our dependency tree stays the same, # all layers should be cached.
COPY . .

# Build our project
RUN cargo build --release --bin test-rust-app 

FROM debian:bullseye-slim AS runtime 
WORKDIR /app
RUN apt-get update -y \
&& apt-get install -y --no-install-recommends openssl ca-certificates \ 
# Clean up
&& apt-get autoremove -y \
&& apt-get clean -y \
&& rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/test-rust-app test-rust-app
COPY --from=builder /app/dist dist
ENTRYPOINT ["./test-rust-app"]

# FROM rust:1.68 as builder

# WORKDIR /app
# RUN apt update && apt install lld clang -y
# COPY . .

# RUN cargo build --release

# FROM debian:bullseye-slim as runtime
# WORKDIR /app

# # Install OpenSSL - it is dynamically linked by some of our dependencies
# # Install ca-certificates - it is needed to verify TLS certificates
# # when establishing HTTPS connections
# RUN apt-get update -y \
#     && apt-get install -y --no-install-recommends openssl ca-certificates \
#     # Clean up
#     && apt-get autoremove -y \
#     && apt-get clean -y \
#     && rm -rf /var/lib/apt/lists/*

# # Copy the compiled binary from the builder environment
# # to our runtime environment
# COPY --from=builder /app/target/release/test-rust-app test-rust-app 


# CMD ["./target/release/test-rust-app"]