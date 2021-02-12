(ns van-challenge.strs-test
  (:require [clojure.test :refer :all]
            [van-challenge.strs :refer :all]))

(deftest test-first-word
  (testing "single word"
    (is (= (first-word "hello") "hello")))
  (testing "multiple words"
    (is (= (first-word "hello there") "hello")))
  (testing "empty input"
    (is (= (first-word "") ""))))

(deftest test-word-count
  (testing "single word"
    (is (= (word-count "a") {"a" 1})))
  (testing "multiple words"
    (is (= (word-count "a a b") {"a" 2 "b" 1})))
  (testing "empty input"
    (is (= (word-count "")) {"" 1})))

(deftest test-longest-line
  (testing "single line"
    (is (= (longest-line "a") "a")))
  (testing "multiple lines"
    (is (= (longest-line "aa\nb") "aa")))
  (testing "empty input"
    (is (= (longest-line "") ""))))

(deftest test-char-groups
  (testing "single char"
    (is (= (char-groups "a") ["a"])))
  (testing "run of same char"
    (is (= (char-groups "aa") ["aa"])))
  (testing "different chars"
    (is (= (char-groups "ab") ["a" "b"])))
  (testing "run of different chars"
    (is (= (char-groups "aab") ["aa" "b"])))
  (testing "run of multiple different chars"
    (is (= (char-groups "aabcc") ["aa" "b" "cc"]))))