package services

import "testing"

func TestShouldTriggerAlert(t *testing.T) {
	cases := []struct {
		direction       string
		target, current float64
		want            bool
	}{
		{"above", 70000, 70000, true}, // 等于即触发
		{"above", 70000, 70001, true},
		{"above", 70000, 69999, false},
		{"below", 0.1, 0.1, true},
		{"below", 0.1, 0.09, true},
		{"below", 0.1, 0.11, false},
		{"ABOVE", 100, 150, true},     // 大小写不敏感
		{"sideways", 100, 150, false}, // 未知方向不触发
		{"", 100, 150, false},
	}
	for i, c := range cases {
		if got := ShouldTriggerAlert(c.direction, c.target, c.current); got != c.want {
			t.Fatalf("case %d (%s target=%v current=%v): got %v want %v",
				i, c.direction, c.target, c.current, got, c.want)
		}
	}
}
