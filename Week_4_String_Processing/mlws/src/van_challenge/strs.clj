(ns van-challenge.strs
  (:require [clojure.string :as str]))

(defn first-word [value]
  (first (str/split value #" ")))

(defn word-count [value]
  (frequencies (str/split value #" ")))

(defn longest-line [value]
  (reduce
   #(if (> (count %1) (count %2)) %1 %2)
   (str/split-lines value)))

(defn char-groups [value]
  (reduce
   (fn [acc x]
     (let [last-val (last acc)]
       (if (= x last-val)
         (assoc acc (- (count acc) 1) (str last-val x))
         (conj acc x))))
   []
   (str/split value #"")))