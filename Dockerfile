FROM golang:1.19-alpine AS builder
ENV CGO_ENABLED=0
WORKDIR /backend
COPY vm/go.* .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go mod download
COPY vm/. .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go build -trimpath -ldflags="-s -w" -o bin/service

FROM --platform=$BUILDPLATFORM node:18.9-alpine3.15 AS client-builder
WORKDIR /ui
# cache packages in layer
COPY ui/package.json /ui/package.json
COPY ui/package-lock.json /ui/package-lock.json
RUN --mount=type=cache,target=/usr/src/app/.npm \
    npm set cache /usr/src/app/.npm && \
    npm ci
# install
COPY ui /ui
RUN npm run build

FROM alpine
LABEL org.opencontainers.image.title="boringproxy" \
    org.opencontainers.image.description="boringproxy client extension" \
    org.opencontainers.image.vendor="IndieBits.io" \
    com.docker.desktop.extension.api.version="0.3.0" \
    com.docker.desktop.extension.icon="https://raw.githubusercontent.com/boringproxy/boringproxy-docker-extension/main/boringproxy_logo.svg" \
    com.docker.extension.screenshots="" \
    com.docker.extension.detailed-description="" \
    com.docker.extension.publisher-url="https://forum.indiebits.io" \
    com.docker.extension.additional-urls='[{"title":"Support","url":"https://forum.indiebits.io/"}]' \
    com.docker.extension.changelog=""

COPY --from=builder /backend/bin/service /
COPY docker-compose.yaml .
COPY metadata.json .
COPY boringproxy_logo.svg .
COPY --from=client-builder /ui/build ui
CMD /service -socket /run/guest-services/extension-boringproxy-docker-extension.sock
