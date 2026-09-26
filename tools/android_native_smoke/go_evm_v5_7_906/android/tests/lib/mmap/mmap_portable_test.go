//go:build !windows

package mmap

import (
	"bytes"
	"os"
	"testing"
)

func TestMobileBoundSmallFileMapping(t *testing.T) {
	f, err := os.CreateTemp(t.TempDir(), "mmap-*.bin")
	if err != nil {
		t.Fatal(err)
	}
	defer f.Close()
	if err := f.Truncate(4096); err != nil {
		t.Fatal(err)
	}
	writable, handle, err := MmapRw(f, 4096)
	if err != nil {
		t.Fatal(err)
	}
	copy(writable, []byte("n42-mobile-mmap"))
	if err := Munmap(writable, handle); err != nil {
		t.Fatal(err)
	}
	if err := f.Sync(); err != nil {
		t.Fatal(err)
	}
	readable, handle, err := Mmap(f, 4096)
	if err != nil {
		t.Fatal(err)
	}
	if !bytes.Equal(readable[:15], []byte("n42-mobile-mmap")) {
		t.Fatalf("mapped bytes = %q", readable[:15])
	}
	if err := Munmap(readable, handle); err != nil {
		t.Fatal(err)
	}
}
