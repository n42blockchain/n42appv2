package recsplit

import (
	"bytes"
	"crypto/sha256"
	"encoding/binary"
	"fmt"
	"testing"
)

func TestMobileBoundGolombSerialization(t *testing.T) {
	var encoded GolombRice
	encoded.appendFixed(1, 2)
	encoded.appendFixed(2, 2)
	encoded.appendUnaryAll([]uint64{1, 2})
	var wire bytes.Buffer
	if err := encoded.Write(&wire); err != nil {
		t.Fatal(err)
	}
	if gotHash := fmt.Sprintf("%x", sha256.Sum256(wire.Bytes())); gotHash != "750623a3af5e571a8bcedb1859685d2da8bed8620537afb66ed06eb1bc8b2655" {
		t.Fatalf("Golomb wire SHA256 changed: %s", gotHash)
	}
	if words := binary.BigEndian.Uint64(wire.Bytes()[:8]); words != uint64(len(encoded.Data())) {
		t.Fatalf("wire declares %d words, built %d", words, len(encoded.Data()))
	}
	decoded := make([]uint64, len(encoded.Data()))
	for i := range decoded {
		decoded[i] = binary.LittleEndian.Uint64(wire.Bytes()[8+i*8:])
	}
	reader := GolombRiceReader{data: decoded}
	reader.ReadReset(0, 4)
	if value := reader.ReadNext(2); value != 5 {
		t.Fatalf("first value = %d, want 5", value)
	}
	if value := reader.ReadNext(2); value != 10 {
		t.Fatalf("second value = %d, want 10", value)
	}
}
