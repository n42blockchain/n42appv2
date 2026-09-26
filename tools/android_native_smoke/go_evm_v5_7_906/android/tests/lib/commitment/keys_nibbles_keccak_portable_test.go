package commitment

import (
	"crypto/sha256"
	"fmt"
	"testing"

	"golang.org/x/crypto/sha3"
)

func TestMobileKeccakAndCommitmentKeyVectors(t *testing.T) {
	vectors := []struct {
		length     int
		keccak     string
		keyHash    string
		directHash string
	}{
		{0, "c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470", "9d76d47f6f2afdb6800e81d5518eaadf7dc7087e8f38ca08d04119250ad36b5d", "9d76d47f6f2afdb6800e81d5518eaadf7dc7087e8f38ca08d04119250ad36b5d"},
		{1, "bc36789e7a1e281436464229828f817d6612f7b477d66591ff96a9e064bcc98a", "ba6f7fa7402b82e52f4f5512338d3096f3498f14825c418141314d8b9b9e97fa", "ba6f7fa7402b82e52f4f5512338d3096f3498f14825c418141314d8b9b9e97fa"},
		{20, "27de39f50eaf89fe36fa279026a22605711fde9c16c0f23ae2c3e9faf4eed6ae", "8d4d386ae0240afa87bd96b3d4981cc69cbd21b2b5a580bb93d5f2b5f966ffe2", "8d4d386ae0240afa87bd96b3d4981cc69cbd21b2b5a580bb93d5f2b5f966ffe2"},
		{21, "3c73b64ac0b35803891ce2e239d30eed547433951b4db1477e700524f15765e2", "e33c2615d82d2a798fdd6081e42400da1846da1f0f69da79e4654a6b2c980327", "88ef9f69b61d9918d644475d99d6cc510974d906d640f38dd710c6fb34927fab"},
		{135, "cbdfd9dee5faad3818d6b06f95a219fd290b0e1706f6a82e5a595b9ce9faca62", "e54d29ea2045e7a2bd51d22b86308f6c3b3bb688ec2aa6c3e3bf54b3d9a87291", "02d5232f8c76deedf223ad10afb66f3fd4a2c2ffb56f2ba16b0b41cbafc90cf6"},
		{136, "7ce759f1ab7f9ce437719970c26b0a66ff11fe3e38e17df89cf5d29c7d7f807e", "6b2d3e4454b2339af0f10ae3767d9e0452b9d9a84ae2c4385873b545a2fc7cfa", "7284e34ff9f8c44f88ef1a5a7a11f4bab1bab4cce806e092b7e27748600a4db4"},
		{137, "ac73d4fae68b8453f764007c1a20ce95994187861f0c3227a3a8e99a73a3b1db", "c7c415b1e15940dee503450ec892f26cfbc260e8e525482803ac4db3bfb8e6fc", "ee42b298a318cdbfeeb1645ea7fb4ad7e151d651a04cf390d9fc244c28d17e66"},
		{272, "fdf2ec49e749960d3c8521a0219af8d03e30e2b3bf19bd16150ee0eaf133d66e", "7e44ceff4718019f8dfd93565bc15d920d3f4a99b29d9fa34ad4ec03149e80c1", "cab66003228d2903c4c70a07d178ce451882c93e937bed215a0bcca17e2072aa"},
	}
	for _, vector := range vectors {
		t.Run(fmt.Sprintf("length_%d", vector.length), func(t *testing.T) {
			key := make([]byte, vector.length)
			for i := range key {
				key[i] = byte(i)
			}
			hasher := sha3.NewLegacyKeccak256()
			_, _ = hasher.Write(key)
			if got := fmt.Sprintf("%x", hasher.Sum(nil)); got != vector.keccak {
				t.Fatalf("legacy Keccak digest = %s, want %s", got, vector.keccak)
			}
			if got := fmt.Sprintf("%x", sha256.Sum256(KeyToHexNibbleHash(key))); got != vector.keyHash {
				t.Fatalf("account/storage key digest = %s, want %s", got, vector.keyHash)
			}
			if got := fmt.Sprintf("%x", sha256.Sum256(KeyToNibblizedHash(key))); got != vector.directHash {
				t.Fatalf("direct key digest = %s, want %s", got, vector.directHash)
			}
		})
	}
}
