(ns van-challenge.core
  (:require [van-challenge.csv-data :as cd])
  (:gen-class))

(defn -main
  [& args]
  (cd/main args))