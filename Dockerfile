# https://github.com/vercel/next.js/blob/f43c53a759e10a2c4e7ab702196d0ba070ff5b29/examples/with-docker/Dockerfile

ARG NONROOT_USERNAME=nextjs
ARG NONROOT_GROUPNAME=nextjs
ARG NONROOT_UID=1001
ARG NONROOT_GID=1001

FROM node:22.5.1-slim AS base
ARG NONROOT_USERNAME
ARG NONROOT_GROUPNAME
ARG NONROOT_UID
ARG NONROOT_GID

# Install pnpm
RUN --mount=source=package.json,target=/tmp/package.json \
  cd /tmp && corepack enable
# Add non-root user
RUN groupadd -g ${NONROOT_GID} ${NONROOT_GROUPNAME} && \
  useradd -u ${NONROOT_UID} -g ${NONROOT_GROUPNAME} -m ${NONROOT_USERNAME}
# Create /app directory and change the owner to the non-root user
RUN mkdir /app && chown ${NONROOT_GROUPNAME}:${NONROOT_USERNAME} /app
USER ${NONROOT_USERNAME}
WORKDIR /app

# Install dependencies only when needed
FROM base AS deps

# Install dependencies based on the preferred package manager
RUN --mount=source=package.json,target=package.json \
  --mount=source=pnpm-lock.yaml,target=pnpm-lock.yaml \
  --mount=type=cache,target=/home/${NONROOT_USERNAME}/.local/share/pnpm/store/v3 \
  corepack pnpm install --frozen-lockfile

# Rebuild the source code only when needed
FROM base AS builder

COPY . .

ENV NEXT_TELEMETRY_DISABLED=1

RUN --mount=from=deps,source=/app/node_modules,target=node_modules \
  corepack pnpm build

# Production image, copy all the files and run next
FROM base AS runner

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

COPY --from=builder /app/public ./public

COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

EXPOSE 3000

ENV PORT=3000

CMD HOSTNAME="0.0.0.0" node server.js
