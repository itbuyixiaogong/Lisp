(ns room-escape.common
  (:gen-class))

(use '[clojure.string :as string])

(defn display [message & args]
  (println (str message (string/join args))))

(defn enclose [object-name]
  (str "["object-name"]"))

(defn parse-int
  ([s] (Integer/parseInt s))
  ([s default-int] (try
                     (Integer/parseInt s)
                     (catch java.lang.NumberFormatException ne default-int))))

(def players (atom {}))

(defn locate-by-id [player-id object-id]
  (let [objects (:player-objects (get @players player-id))]
    (first (filter (comp #(= % object-id) #(:id %)) objects))))

(defn get-name [player-id object-id]
  (:name (locate-by-id player-id object-id)))

(defn locate-by-name [player-id name]
  (let [objects (:player-objects (get @players player-id))]
    (first (filter (comp #(= % name) #(:name %)) objects))))

(defn locate-by-category [player-id category-id]
  (let [objects (:player-objects (get @players player-id))]
    (filter (comp #(= % category-id) #(:category %)) objects)))

(defn visible? [player-id object-id]
  (let [visible-context (:visible (get @players player-id))]
    (contains? @visible-context object-id)))

(defn set-visible [player-id object-id]
  (let [visible-context (:visible (get @players player-id))]
    (swap! visible-context conj object-id)))

(defn set-invisible [player-id object-id]
  (let [visible-context (:visible (get @players player-id))]
    (swap! visible-context disj object-id)))

(defn toggle-visible [player-id object-id]
  (if (visible? player-id object-id)
    (set-invisible player-id object-id)
    (set-visible player-id object-id)))

(defn win? [player-id]
  @(:win (get @players player-id)))

(defn set-win [player-id]
  (swap! (:win (get @players player-id)) not))
