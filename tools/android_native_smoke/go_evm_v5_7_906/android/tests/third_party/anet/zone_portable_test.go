package anet

import (
	"net"
	"net/netip"
	"strconv"
	"testing"
)

// This checks the public numeric-zone route available to a known interface.
// It does not claim that anet's removed private named-zone cache is equivalent.
func TestMobileNumericIPv6ZoneForKnownInterface(t *testing.T) {
	iface := net.Interface{Name: "wlan0", Index: 7}
	linkLocal := netip.MustParseAddr("fe80::1").WithZone(strconv.Itoa(iface.Index))
	if linkLocal.Zone() != "7" {
		t.Fatalf("numeric zone = %q", linkLocal.Zone())
	}
	resolved, err := net.ResolveUDPAddr("udp6", "["+linkLocal.String()+"]:1234")
	if err != nil {
		t.Fatal(err)
	}
	if resolved.Zone != "7" || !resolved.IP.Equal(net.ParseIP("fe80::1")) {
		t.Fatalf("resolved address = %+v", resolved)
	}
}
