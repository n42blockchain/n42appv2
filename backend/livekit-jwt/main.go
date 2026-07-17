package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

func main() {
	cfg, err := loadConfig()
	if err != nil {
		log.Fatal(err)
	}

	client := &http.Client{Timeout: 10 * time.Second}
	handler := tokenHandler{
		matrix: &matrixClient{
			homeserver: cfg.MatrixHomeserver,
			httpClient: client,
		},
		issuer: liveKitIssuer{
			apiKey:    cfg.LiveKitAPIKey,
			apiSecret: cfg.LiveKitAPISecret,
			ttl:       cfg.TokenTTL,
		},
	}

	server := &http.Server{
		Addr:              fmt.Sprintf(":%d", cfg.Port),
		Handler:           handler,
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       10 * time.Second,
		WriteTimeout:      10 * time.Second,
		IdleTimeout:       60 * time.Second,
	}
	log.Printf("[livekit-jwt] listening on %s (homeserver=%s)", server.Addr, cfg.MatrixHomeserver)
	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Printf("[livekit-jwt] server error: %v", err)
		os.Exit(1)
	}
}
