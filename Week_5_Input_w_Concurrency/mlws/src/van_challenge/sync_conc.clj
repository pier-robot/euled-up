(ns van-challenge.sync-conc
  (:require [clojure.string]
            [clojure.java.io :refer [reader]]
            [clojure.core.async :refer [close! chan >!! <!! >! <! go put! take! go-loop]]))

(defn count-file-lines
  ; 😍 this function
  [file]
  (-> file
      reader
      line-seq
      count))

(defn count-file-lines-concurrent
  [file]
  (let [line-chan (chan)
        done-chan (chan)]
    ; start first go block to read each line and send it on the channel
    ; then block wait for the total
    (go
      (doseq [line (line-seq (reader file))]
        (>! line-chan line))
      (close! line-chan)
      (printf "reader:total=%s%n" (<! done-chan)))
    ; start second go block to print each line from the channel, keeping a
    ; total and then sending that
    (go-loop [total 0]
      (if-let [line (<! line-chan)]
        (do
          (printf "printer:%s%n" line)
          (recur (inc total)))
        (>! done-chan total)))))

(defn main
  [args]
  (assert (= (count args) 1) "Must provide one argument <file to read>")

  (let [in-file (first args)]
    (println ">>> SIMPLE LINE COUNT >>>")
    (printf "Line count is: %s%n" (count-file-lines in-file))
    (println ">>> CONCURRENT LINE COUNT >>>")
    ; we need the <!! to make the program block until the loop is finished!
    (<!! (count-file-lines-concurrent in-file))))
