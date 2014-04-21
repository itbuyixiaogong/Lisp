(defun make-board ()
        (list 'board 0 0 0 0 0 0 0 0 0)) 

(setf *computer* 10) 
(setf *opponent* 1)
(setf *opponent-name* NIL)
(setf *level* 0)
(setf *mode* 1)
(setf *players*
        '(player 1 10))
(setf *players-name*
        '(playername NIL NIL))

(setf *centre* 5)
(setf *triplets*
        '((1 2 3) (4 5 6) (7 8 9) (1 4 7) (2 5 8) (3 6 9) (1 5 9) (3 5 7)))

(setf *corners*
      '(1 3 7 9))

(setf *sides*
      '(2 4 6 8))

(defun convert-to-letter (v)
        (cond ((equal v 1) "O")
              ((equal v 10) "X")
              (T " ")))

(defun print-row (x y z)
        (format T "~&   ~A | ~A | ~A"
                (convert-to-letter x)
                (convert-to-letter y)
                (convert-to-letter z)))

(defun print-board (board)
        (format T "~%")
        (print-row (nth 1 board) (nth 2 board) (nth 3 board))
        (format T "~&  -----------")
        (print-row (nth 4 board) (nth 5 board) (nth 6 board))
        (format T "~&  -----------")
        (print-row (nth 7 board) (nth 8 board) (nth 9 board))
        (format T "~%~%"))

(defun winner-p (board)
        (let ((sums (compute-sums board)))
        (cond ((equal *mode* 1)
                (or (member (* 3 *computer*) sums)
                    (member (* 3 *opponent*) sums)))
              ((equal *mode* 2)
                (or (member (* 3 (nth 1 *players*)) sums)
                    (member (* 3 (nth 2 *players*)) sums)))
	      (T NIL))))

(defun sum-triplet (board triplet)
        (+ (nth (first triplet) board)
           (nth (second triplet) board)
           (nth (third triplet) board)))

(defun compute-sums (board)
        (mapcar #'(lambda (triplet)
                        (sum-triplet board triplet))
                *triplets*))

(defun make-move (player pos board)
        (setf (nth pos board) player)
        board)

(defun the-other-player (id)
	(cond ((equal id 1) 2)
	      ((equal id 2) 1)
	      (T NIL)))

(defun get-name-by-id (id)
	(nth id *players-name*))

(defun player-move (board playerId)
	(let* ((pos (read-a-legal-move board (get-name-by-id playerId)))
		(new-board (make-move (nth playerId *players*) pos board)))
	(print-board new-board)
	(cond ((winner-p new-board)
		(format T "~&Player ~S wins!" (get-name-by-id playerId)))
	      ((board-full-p new-board)
		(format T "~&Tie game."))
	      (T (player-move new-board (the-other-player playerId))))))

(defun read-a-legal-move (board playerName)
	(format T "~&~S's move: " playerName)
	(let ((pos (read)))
	(cond ((not (and (integerp pos) (<= 1 pos 9)))
		(format t "~&Invalid input.")
		(read-a-legal-move board))
	      ((not (zerop (nth pos board)))
		(format t "~&That space is already occupied.")
		(read-a-legal-move board playerName))
	      (T pos))))

(defun opponent-move (board)
        (let* ((pos (read-a-legal-move board *opponent-name*))
                (new-board (make-move *opponent* pos board)))
        (print-board new-board)
        (cond ((winner-p new-board)
                (format T "~&You win!"))
              ((board-full-p new-board)
                (format T "~&Tie game."))
              (T (computer-move new-board)))))

(defun computer-move (board)
	(let* ((best-move (choose-best-move board *level*))
		(pos (first best-move))
		(strategy (second best-move))
		(new-board (make-move *computer* pos board)))
	(format T "~&My move: ~S" pos)
	(format T "~&My strategy: ~A~%" strategy)
	(print-board new-board)
	(cond ((winner-p new-board)
		(format T "~&I win!"))
		((board-full-p new-board)
		(format T "~&Tie game."))
		(T (opponent-move new-board)))))

(defun choose-best-move (board level)
	(or (make-three-in-a-row board)
	    (block-opponent-win board)
            (if (> level 0)
		(block-squeeze-play board))
	    (if (> level 1)
            	(or (make-squeeze-play board)
		    (occupy-centre-strategy board)))
            (random-move-strategy board)))

(defun random-move-strategy (board)
	(list (pick-random-empty-position board) "random move"))

(defun occupy-centre-strategy (board)
	(let ((pos (pick-central-position board)))
		(cond (pos
			(list pos "occupy centre"))
			(T NIL))))

(defun block-squeeze-play (board)
    (cond ((has-squeeze-play board)
           (let ((pos (find-empty-position board *sides*)))
		(when pos
			(list pos "block squeeze play"))))
          (T NIL)))

(defun make-squeeze-play (board)
    (let ((triplet (has-squeeze-opportunity board)))
         (cond (triplet (list (find-empty-position board triplet) "make squeeze play"))
               (T NIL))))

(defun pick-central-position (board)
	(cond ((zerop (nth *centre* board))
		(setf (nth *centre* board) *computer*)
		*centre*)
		(T NIL)))

(defun pick-random-empty-position (board)
	(let ((pos (+ 1 (random 9))))
	(if (zerop (nth pos board))
		pos
		(pick-random-empty-position board))))

(defun find-empty-position (board squares)
	(find-if #'(lambda (pos)
		(zerop (nth pos board)))
		squares))

(defun has-squeeze-play (board)
  (let ((target-sum (+ (* *opponent* 2) *computer*)))
    (find-if #'(lambda (trip)
                 (and (intersection trip *corners*)
                      (equal (sum-triplet board trip) target-sum)))
             *triplets*)))

(defun has-squeeze-opportunity (board)
  (find-if #'(lambda (trip)
               (and (not (member (first trip) *sides*))
                    (or (and
                          (equal (nth (first trip) board) *computer*)
                          (zerop (nth (third trip) board)))
                        (and
                          (equal (nth (third trip) board) *computer*)
                          (zerop (nth (first trip) board))))
                    (equal (nth (second trip) board) *opponent*)))
           *triplets*))

(defun win-or-block (board target-sum)
	(let ((triplet (find-if
		#'(lambda (trip)
			(equal (sum-triplet board trip)
				target-sum))
		*triplets*)))
	(when triplet
		(find-empty-position board triplet))))

(defun block-opponent-win (board)
	(let ((pos (win-or-block board (* 2 *opponent*))))
	(and pos (list pos "block opponent"))))

(defun make-three-in-a-row (board)
	(let ((pos (win-or-block board (* 2 *computer*))))
	(and pos (list pos "make three in a row"))))

(defun board-full-p (board)
	(not (member 0 board)))

(defun play-one-game (mode)
	(cond ((equal mode 1)
		(if (y-or-n-p "~&Would you like to go first? ")
			(opponent-move (make-board))
			(computer-move (make-board))))
	      ((equal mode 2)
		(if (y-or-n-p "~&Player 1 goes first? ")
			(player-move (make-board) 1)
			(player-move (make-board) 2)))))

(defun set-level (level)
	(setf *level* level)
	(cond ((equal *level* 0) "Beginner level")
	      ((equal *level* 1) "Amateur level")
	      ((equal *level* 2) "Master level")))

(defun choose-mode ()
	(format T "~&Select players(1/2): 1 - Player vs Computer; 2 - Two Players~&")
	(let ((mode (read)))
	     (cond ((or (equal mode 1) (equal mode 2))
		   	(setf *mode* mode))
                   (T (format T "~&Invalid input.")
                      (choose-mode)))))
                  
(defun choose-level ()
        (format T "~&Select level(0/1/2): 0 - Beginner level; 1 - Amateur level; 2 - Master level.~&")
        (let ((level (read)))
		(cond ((not (or (equal level 0) (equal level 1) (equal level 2)))
			(format t "~&Invalid input.")
		        (choose-level))
		      (T (setf *level* level)))))

(defun input-name (mode)
	(cond ((equal mode 1)
		(format T "Enter your name: ")
		(setf *opponent-name* (read)))
	      ((equal mode 2)
		(format T "Enter player 1's name: ")
		(setf (nth 1 *players-name*) (read)) 
		(format T "Enter player 2's name: ")
		(setf (nth 2 *players-name*) (read))))) 

(defun show-options ()
        (choose-mode)
        (if (equal *mode* 1)
		(choose-level))
	(input-name *mode*))

(defun play ()
	(show-options)
	(play-one-game *mode*))
