(defun get-new-tacka (smer tacka)
  (cond   ((= desno smer)			(cons  (car tacka)(list (1+ (cadr tacka)))))
          ((= gore-desno smer)(cons  (next-char (car tacka)) (list (1+ (cadr tacka)))))
          ((= gore-levo smer)	(cons  (next-char (car tacka)) (list (cadr tacka))))
          ((= levo smer)			(cons  (car tacka)(list (1- (cadr tacka)))))
          ((= dole-levo smer)	(cons  (prev-char (car tacka)) (list (1- (cadr tacka)))))
          ((= dole-desno smer)(cons  (prev-char (car tacka)) (list (cadr tacka))))))

(defun state-remove-point (stanje player tacka)
  (if player
    (get-state
       (remove-point (state-white stanje) tacka)
       (state-black stanje))
    (get-state
      (state-white stanje)
      (remove-point (state-black stanje) tacka))))

(defun state-add-point (stanje player tacka)
  (if player
    (get-state
       (add-point (state-white stanje) tacka)
       (state-black stanje))
    (get-state
        (state-white stanje)
        (add-point (state-black stanje) tacka))))

(defun move-state-one (stanje tacka player smer)
  (let*(  (new-tacka (get-new-tacka smer tacka)))
          (cond
            ((out-of-table new-tacka) (state-remove-point stanje player tacka))
            ((find-ball new-tacka (occupied stanje)) stanje)
            (t (state-add-point (state-remove-point stanje player tacka) player new-tacka)))))

;(defun move-state-one (stanje tacka player smer)
;  (let*((new-tacka (get-new-tacka smer tacka))
;        (opp-balls (player-state stanje (not player)))
;        (balls (player-state stanje player))
;  			(empty (get-empty stanje)))
;
;        (if player
;          (get-state
;             (add-point (remove-point balls tacka) new-tacka)
;             opp-balls
;             (add-point (remove-point empty new-tacka) tacka))
;          (get-state
;              balls
;              (add-point (remove-point opp-balls tacka) new-tacka)
;              (add-point (remove-point empty new-tacka) tacka)))))

(defun move-state-two (stanje mx mn player smer)
  (let* ( (new-tacka (car (new-third-tacka smer mx mn)))
          (balls (player-state stanje player))
          (opp-balls (player-state stanje (not player)))
          (new-stanje (if (find-ball new-tacka opp-balls) (move-state-one stanje new-tacka (not player) smer) stanje)))
          (if (or (and (equal (car mx) (car mn)) (= smer desno))
                  (and (not (equal (car mx) (car mn))) (not (= (cadr mx) (cadr mn))) (= smer gore-desno))
                  (and (= (cadr mx) (cadr mn)) (= smer gore-levo)))
                  (move-state-one (move-state-one new-stanje mx player smer) mn player smer)
                  (move-state-one (move-state-one new-stanje mn player smer) mx player smer))))

(defun move-state-three (stanje mx mid mn player smer)
  (let* ( (new-tacka (car (new-third-tacka smer mx mn)))
          (balls (player-state stanje player))
          (opp-balls (player-state stanje (not player)))
          (new-stanje
                (cond
                  ((null new-tacka) stanje)
                  ((find-ball new-tacka opp-balls)
                    (let* ((next-new-tacka (car (new-third-tacka smer (max-tacka mx new-tacka) (min-tacka mn new-tacka)))))
                      (cond
                        ((null next-new-tacka) (move-state-one stanje new-tacka (not player) smer))
                        ((find-ball next-new-tacka opp-balls) (move-state-two stanje (max-tacka next-new-tacka new-tacka)(min-tacka new-tacka next-new-tacka) (not player) smer))
                        (t (move-state-one stanje new-tacka (not player) smer)))))
                  (t stanje))))
                  (if (or (and (equal (car mx) (car mn)) (= smer desno))
                          (and (not (equal (car mx) (car mn))) (not (= (cadr mx) (cadr mn))) (= smer gore-desno))
                          (and (= (cadr mx) (cadr mn)) (= smer gore-levo)))
                          (move-state-one (move-state-one (move-state-one new-stanje mx player smer) mid player smer) mn player smer)
                          (move-state-one (move-state-one (move-state-one new-stanje mn player smer) mid player smer) mx player smer))))

;(defun move-state-three (stanje tacka1 tacka2 tacka3 player smer)
;  (if (and (equal3 tacka1 tacka2 tacka3) (or (equal smer desno) (equal smer levo)))
;    (move-state-one (move-state-one (move-state-one stanje tacka3 player smer) stanje tacka2 player smer) tacka1 player smer)
;    (let*((new-tacka1 (get-new-tacka smer tacka3))
;          (new-tacka2 (get-new-tacka smer new-tacka1))
;          (white (state-white stanje))
;          (black (state-black stanje))
;          (removed-black (remove-point (remove-point black new-tacka1) new-tacka2))
;          (removed-white (remove-point (remove-point white new-tacka1) new-tacka2)))
;
;          (move-state-one (move-state-one (move-state-one
;            (if (and (equal removed-black black) (equal removed-white white))
;                stanje
;                (move-state-one (move-state-one stanje new-tacka2 (not player) smer)
;                  new-tacka1 (not player) smer))
;            tacka3 player smer) tacka2 player smer) tacka1 player smer))))