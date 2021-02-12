package strprocess

import (
	"fmt"
	"reflect"
	"testing"
)


func assertCorrectString(t testing.TB, got, want string) {
		t.Helper()
		if got != want {
			t.Errorf("got %q want %q", got, want)
		}
	}

func assertCorrectMap(t testing.TB, got, want map[string]int) {
	t.Helper()
	if reflect.DeepEqual(got, want) == false {
		// %#v is a printing 'verb' that prints a go syntax
		// representation of the value
		t.Errorf("got %#v want %#v", got, want)
	}
}


func TestGetFirst(t *testing.T) {
	s1 := "This is a sample."
	t.Run("test first word in " + s1, func(t *testing.T) {
		got := GetFirst(s1)
		want := "This"
		assertCorrectString(t, got, want)
		t.Logf("string %q -> %q", s1, got)
	})

	s2 := "¿This is a sample?"
	t.Run("test first word in " + s2, func(t *testing.T) {
		got := GetFirst(s2)
		want := "This"
		assertCorrectString(t, got, want)
		t.Logf("string %q -> %q", s2, got)
	})

	s3 := "私は 日本語が 少し 話せます。"
	t.Run("test first word in japanese " + s3, func(t *testing.T) {
		got := GetFirst(s3)
		want := "私は"
		assertCorrectString(t, got, want)
		t.Logf("string %q -> %q", s3, got)
	})
}

func ExampleGetFirst() {
	first := GetFirst("'This' started with a quote.")
	fmt.Println(first)
	// Output: This
}


func TestCountWords(t *testing.T) {
	got := CountWords("foobar bar a foo foobar bar foobar")
	want := map[string]int{"foo": 1, "bar": 2, "foobar": 3, "a": 1}
	assertCorrectMap(t, got, want)
}

func ExampleCountWords() {
	count := CountWords("foobar bar a foo foobar bar foobar")
	fmt.Println(count)
	// Output: map[a:1 bar:2 foo:1 foobar:3]
}


func TestLongestLines(t *testing.T) {
	got := LongestLines("a long line\nwith many chars\nsort of")
	want := make([]string, 1)
	want[0] = "with many chars"
	if reflect.DeepEqual(got, want) == false {
		t.Errorf("got %q want %q", got, want)
	}
}


func TestOutputCharGroups(t *testing.T) {
	s1 := "hello old wool"
	t.Run("test group \"" + s1 + "\"", func(t *testing.T) {
		got := OutputCharGroups(s1)
		want := "h, e, ll, o,  , o, l, d,  , w, oo, l"
		assertCorrectString(t, got, want)
		t.Logf("string %q -> %q", s1, got)
	})

	s2 := ""
	t.Run("test group \"" + s1 + "\"", func(t *testing.T) {
		got := OutputCharGroups(s2)
		want := ""
		assertCorrectString(t, got, want)
		t.Logf("string %q -> %q", s1, got)
	})
}

func ExampleOutputCharGroups() {
	groups := OutputCharGroups("hello old wool")
	fmt.Println(groups)
	// Output: h, e, ll, o,  , o, l, d,  , w, oo, l
}


func TestSubstring(t *testing.T) {
	got := Substring("this is awesome", 2, 7)
	want := "is is"
	assertCorrectString(t, got, want)
}


func TestReplaceSubstring(t *testing.T) {
	got := ReplaceSubstring("this is awesome", "is", "was")
	want := "thwas was awesome"
	assertCorrectString(t, got, want)
}
