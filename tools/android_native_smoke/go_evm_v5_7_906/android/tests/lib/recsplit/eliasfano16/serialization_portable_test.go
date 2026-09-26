package eliasfano16

import (
	"bytes"
	"crypto/sha256"
	"fmt"
	"testing"
)

func TestMobileBoundSingleSerialization(t *testing.T) {
	values := []uint64{0, 2, 5, 9}
	ef := NewEliasFano(uint64(len(values)), values[len(values)-1], 2)
	for _, value := range values {
		ef.AddOffset(value)
	}
	ef.Build()
	var buf bytes.Buffer
	if err := ef.Write(&buf); err != nil {
		t.Fatal(err)
	}
	if gotHash := fmt.Sprintf("%x", sha256.Sum256(buf.Bytes())); gotHash != "d40cdada8bebd158a33088ffabc16414b7eb009f8dd397d7bb6543c2de24d27d" {
		t.Fatalf("single wire SHA256 changed: %s", gotHash)
	}
	got, consumed := ReadEliasFano(buf.Bytes())
	if consumed != buf.Len() {
		t.Fatalf("consumed %d of %d bytes", consumed, buf.Len())
	}
	for i, want := range values {
		if value := got.Get(uint64(i)); value != want {
			t.Fatalf("Get(%d) = %d, want %d", i, value, want)
		}
	}
}

func TestMobileBoundDoubleSerialization(t *testing.T) {
	keys := []uint64{0, 2, 5, 9}
	positions := []uint64{0, 3, 7, 12}
	var ef DoubleEliasFano
	ef.Build(keys, positions)
	var buf bytes.Buffer
	if err := ef.Write(&buf); err != nil {
		t.Fatal(err)
	}
	if gotHash := fmt.Sprintf("%x", sha256.Sum256(buf.Bytes())); gotHash != "abba52ca23c5a6ae149a98ab2a5328b3b5460478592389918611c0a11e2a63dc" {
		t.Fatalf("double wire SHA256 changed: %s", gotHash)
	}
	var got DoubleEliasFano
	if consumed := got.Read(buf.Bytes()); consumed != buf.Len() {
		t.Fatalf("consumed %d of %d bytes", consumed, buf.Len())
	}
	for i := range keys {
		key, position := got.Get2(uint64(i))
		if key != keys[i] || position != positions[i] {
			t.Fatalf("Get2(%d) = (%d, %d), want (%d, %d)", i, key, position, keys[i], positions[i])
		}
	}
}
