# Use Node 18 as parent image for build stage
FROM node:18 AS build

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Final stage for runtime
FROM node:18-alpine AS final

# Set working directory
WORKDIR /app

# Copy installed dependencies from build stage
COPY --from=build /app/node_modules ./node_modules

# Copy source code from build stage
COPY --from=build /app ./

# Expose port
EXPOSE 3000

# Start the app
CMD ["npm", "start"]