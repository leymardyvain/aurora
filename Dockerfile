# --- Stage 1: Build & Dependencies ---
FROM node:20-alpine AS builder
WORKDIR .

# Copy package files first to leverage Docker layer caching
COPY package*.json ./

# Install all dependencies (including devDependencies for testing/building)
RUN npm edit-dependency-cache || npm ci

# Copy the rest of the application source code
COPY . .

# Build step (optional: uncomment if your project uses TypeScript, React, Next.js, etc.)
# RUN npm run build

# Remove development dependencies to keep the production image clean
RUN npm prune --production


# --- Stage 2: Final Production Run ---
FROM node:20-alpine
WORKDIR /app

# Set node environment to production
ENV NODE_ENV=production

# Copy only production dependencies and compiled code from builder stage
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app ./

# Expose the application port (adjust to your app's actual port)
EXPOSE 3000

# Run the app without root privileges for better container security
USER node

# Start command
CMD ["node", "index.js"]
