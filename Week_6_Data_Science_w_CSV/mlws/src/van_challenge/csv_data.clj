(ns van-challenge.csv-data
  (:require [clojure.data.csv :refer [read-csv]]
            [clojure.string :as strs]))


(defn load-csv
  "Slurps a file and returns it as csv"
  [file]
  (-> file
      slurp
      read-csv))

(defn parse-int
  [n]
  (try (Integer/parseInt n)
       (catch NumberFormatException e nil)))

(defn parse-float
  [n]
  (try (Float/parseFloat n)
       (catch NumberFormatException e nil)))

(defn make-weather-record
  [row]
  {:min (parse-float (get row 9))
   :max (parse-float (get row 11))
   :date (get row 4)})

(defn is-valid-weather-record
  [{min :min max :max}]
  (and (some? min) (some? max)))

(defn temp-diff
  [{min :min max :max}]
  (Math/abs (- max min)))

(defn weather-diff
  []
  (->>  (load-csv "../data/weather.csv")
        (drop 1) ; skip header row
        (map make-weather-record)
        (filter is-valid-weather-record)
        (reduce
         (fn [totals row]
           (if (and
                (nil? (:biggest-diff-day totals))
                (nil? (:smallest-diff-day totals)))
             {:biggest-diff-day row
              :smallest-diff-day row}
             (let [diff (temp-diff row)
                   biggest-diff (temp-diff (:biggest-diff-day totals))
                   smallest-diff (temp-diff (:smallest-diff-day totals))]
               (cond
                 (< biggest-diff diff) (assoc totals :biggest-diff-day row)
                 (> smallest-diff diff) (assoc totals :smallest-diff-day row)
                 :else totals))))
         {})))


(defn score-diff
  [{min :min max :max}]
  (Math/abs (- max min)))

(defn make-score-record
  [row]
  {:min (parse-int (get row 2))
   :max (parse-int (get row 12))
   :club (get row 0)})

(defn is-valid-score-record
  [{min :min max :max}]
  (and (some? min) (some? max)))

(defn rugby-scores-diff
  []
  (->>  (load-csv "../data/rugby.csv")
        (drop 1) ; skip header row
        (map make-score-record)
        (filter is-valid-score-record)
        (reduce
         (fn [totals row]
           (if (and
                (nil? (:biggest-diff-club totals))
                (nil? (:smallest-diff-club totals)))
             {:biggest-diff-club row
              :smallest-diff-club row}
             (let [diff (score-diff row)
                   biggest-diff (score-diff (:biggest-diff-club totals))
                   smallest-diff (score-diff (:smallest-diff-club totals))]
               (cond
                 (< biggest-diff diff) (assoc totals :biggest-diff-club row)
                 (> smallest-diff diff) (assoc totals :smallest-diff-club row)
                 :else totals))))
         {})))

(def get-sale-value (comp last first))
(def get-transaction-value (comp last last))
(def get-sale-id (comp first first))

(defn accounting-errors
  []
  (let [sales-csv (load-csv "../data/sales.csv")
        transactions-csv (load-csv "../data/transactions.csv")]
    (->> (map vector sales-csv transactions-csv) ; zip the sequences together
         (drop 1)
         (filter #(not= (get-sale-value %) (get-transaction-value %)))
         (map get-sale-id))))

(defn main
  [& args]
  (let [ruggers (rugby-scores-diff)
        weather (weather-diff)
        acc-errors (accounting-errors)]
    (println ">>> Rugby stats >>>")
    (printf "Biggest score difference was for %s with difference of %s%n"
            (get-in ruggers [:biggest-diff-club :club])
            (score-diff (:biggest-diff-club ruggers)))
    (printf "Smallest score difference was for %s with difference of %s%n"
            (get-in ruggers [:smallest-diff-club :club])
            (score-diff (:smallest-diff-club ruggers)))

    (println ">>> Weather stats >>>")
    (printf "Biggest day difference was on %s with difference of %sC%n"
            (get-in weather [:biggest-diff-day :date])
            (temp-diff (:biggest-diff-day weather)))
    (printf "Smallest day difference was on %s with difference of %sC%n"
            (get-in weather [:smallest-diff-day :date])
            (temp-diff (:smallest-diff-day weather)))
    
    (println ">>> Accounting >>>")
    (printf "Total of %s accounting errors%n" (count acc-errors))
    (printf "IDs of first 5 errors: %s%n" (strs/join ", " (take 5 acc-errors)))))
