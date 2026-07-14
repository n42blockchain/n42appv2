package main

import (
	"context"
	"log"
)

func main() {
	cfg, err := loadConfig()
	if err != nil {
		log.Fatal(err)
	}
	database, err := newPostgresStore(cfg.DatabaseDSN)
	if err != nil {
		log.Fatalf("database: %v", err)
	}
	defer database.Close()
	chain, err := newContractChain(
		context.Background(),
		cfg.RPCURL,
		cfg.ContractAddress,
		cfg.RelayerPrivateKey,
	)
	if err != nil {
		log.Fatalf("chain: %v", err)
	}
	defer chain.Close()
	h := newHandler(chain, database, newRemoteAuthVerifier(cfg.AuthVerifyURL), cfg.InternalToken)
	log.Printf("N42 loyalty relayer listening on :%s", cfg.Port)
	if err := h.router().Run(":" + cfg.Port); err != nil {
		log.Fatal(err)
	}
}
