FROM golang:1.26.8-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/livekit-jwt .

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /out/livekit-jwt /livekit-jwt
EXPOSE 8080
ENTRYPOINT ["/livekit-jwt"]
