
;;; Basic parser for assembly code

;;; LMC LOAD
(defun lmc-load (filename)
  (let ((newmem (list-formatting (lmc-open filename))))
    (let ((labelist (parse-labels newmem)))
      (fillmem
       (opcodes
        (del-labels newmem labelist) labelist)))))

;;; LMC RUN
(defun lmc-run (filename in)
  (execution-loop (list 'state
                        :acc 0
                        :pc 0
                        :mem (lmc-load filename)
                        :in in
                        :out ()
                        :flag 'noflag)))

(defun state (acc pc mem in out flag)
   (list 'state :acc acc :pc pc :mem mem :in in :out out :flag flag))

(defun halted-state (acc pc mem in out flag)
   (list 'halted-state :acc acc :pc pc :mem mem :in in :out out :flag flag))

(defun one-instruction (x)
    (cond
      ;; Halted State
      ((= (get-opcode (get-cell-value
                      (get-pc x) x)) 0)
      (halted-state (get-accumulator x)
                    (get-pc x)
                    (get-memory x)
                    (get-input x)
                    (get-output x)
                    (get-flag x)))
      ;; ADD
      ((= (get-opcode (get-cell-value
                      (get-pc x) x)) 1)
       (sum-instruction x))
      ;; SUB
      ((= (get-opcode (get-cell-value
                      (get-pc x) x)) 2)
       (sub-instruction x))
      ;; STORE
      ((= (get-opcode (get-cell-value
                      (get-pc x) x)) 3)
       (store-instruction x))
      ;; LOAD
      ((= (get-opcode (get-cell-value
                      (get-pc x) x)) 5)
       (load-instruction x))
      ;; BRANCH
      ((= (get-opcode (get-cell-value
                      (get-pc x) x)) 6)
       (branch-instruction x))
      ;; BRANCHZ
      ((= (get-opcode (get-cell-value
                      (get-pc x) x)) 7)
       (branch-zero-instruction x))
      ;; BRANCHP
      ((= (get-opcode (get-cell-value
                      (get-pc x) x)) 8)
       (branch-positive-instruction x))
      ;; I/O
      ((= (get-opcode (get-cell-value
                      (get-pc x) x)) 9)
       (cond ((= (get-cell-index (get-cell-value
                                 (get-pc x)x)) 1) (input-instruction x))
             ((= (get-cell-index (get-cell-value
                                 (get-pc x)x)) 2) (output-instruction x)))

)))

;;; inizio operazioni di load

(defun load-instruction (x)
 (state (load-value x) (incremento-pc x) (get-memory x)
        (get-input x) (get-output x) (get-flag x)))

(defun load-value (x)
  (get-cell-value (get-cell-index (get-cell-value (get-pc x) x)) x))

;;; fine operazioni di load

;;; inizio operazioni di branch

(defun branch-instruction (x)
  (state (get-accumulator x) (jump-to x) (get-memory x)
         (get-input x) (get-output x) (get-flag x)))

(defun jump-to (x)
  (get-cell-index (get-cell-value (get-pc x) x)))

(defun branch-zero-instruction (x)
  (if (and (eq (nth 12 x) 'noflag) (= (get-accumulator x) 0))
      ; then
      (branch-instruction x)
      ; else
      (state (get-accumulator x)
             (incremento-pc x)
             (get-memory x)
             (get-input x)
             (get-output x)
             (get-flag x))))

(defun branch-positive-instruction (x)
  (if (eq (nth 12 x) 'noflag)
      ; then
      (branch-instruction x)
      ; else
      (state (get-accumulator x)
             (incremento-pc x)
             (get-memory x)
             (get-input x)
             (get-output x)
             (get-flag x))))

;;; fine operazioni di branch

;;; inizio operazioni di store

(defun store-instruction (x)
  (state (get-accumulator x)
         (incremento-pc x)
         (store-valore (get-memory x) (get-accumulator x)
                       (get-cell-index (get-cell-value (get-pc x) x)))
         (get-input x)
         (get-output x)
         (get-flag x)))

(defun store-valore (x y z)
  (setf (nth z x) y)
  x )

;;; fine operazioni di store

;;; inizio operazioni di somma

(defun sum-instruction (x)
  (cond ((> (make-sum x) 1000)
          (state (rem (make-sum x) 1000)
                 (incremento-pc x)
                 (get-memory x)
                 (get-input x)
                 (get-output x)
                 'flag))
          (T (state (make-sum x)
                 (incremento-pc x)
                 (get-memory x)
                 (get-input x)
                 (get-output x)
                 'noflag))))

(defun make-sum (x)
        (+ (get-accumulator x)
           (get-cell-value (get-cell-index (get-cell-value (get-pc x) x)) x)))

;;; fine operazioni di somma

;;; inizio operazioni di sottrazione

(defun sub-instruction (x)
  (cond ((< (make-sub x) 0)
          (state (mod (make-sub x) 1000)
                 (incremento-pc x)
                 (get-memory x)
                 (get-input x)
                 (get-output x)
                 'flag))
          (T (state (make-sub x)
                 (incremento-pc x)
                 (get-memory x)
                 (get-input x)
                 (get-output x)
                 'noflag))))

(defun make-sub (x)
        (- (get-accumulator x)
           (get-cell-value (get-cell-index (get-cell-value (get-pc x) x)) x)))

;;; fine operazioni di sottrazione

;;; inizio operazioni di input

(defun input-instruction (x)
  (state (pop (nth 8 x))
         (incremento-pc x)
         (get-memory x)
         (get-input x)
         (get-output x)
         (get-flag x)))


;;; fine operazioni di input

;;; inizio operazioni di output

(defun output-instruction (x)
  (state (get-accumulator x)
         (incremento-pc x)
         (get-memory x)
         (get-input x)
         (append (nth 10 x) (list (get-accumulator x)))
         (get-flag x)))

;;; fine operazioni di output

;;; inizio istruzioni di execution loop

(defun execution-loop (x)
  (cond ((eq (nth 0 x) 'halted-state) (nth 10 x))
        (T (execution-loop (one-instruction x)))))

;;; fine istruzioni di execution loop


(defun get-opcode (x)
  (floor x 100))

(defun get-cell-value (x y)
  (nth x (nth 6 y)))

(defun get-cell-index (x)
  (mod x 100))

(defun get-pc (x)
  (nth 4 x))

(defun get-accumulator (x)
  (nth 2 x))

(defun incremento-pc (x)
  (mod (+ (get-pc x) 1) 100))

(defun get-memory (x)
  (nth 6 x))

(defun get-input (x)
  (nth 8 x))

(defun get-output (x)
  (nth 10 x))

(defun get-flag (x)
  (nth 12 x))


;;; Leggi da file e genera una lista con create-list
(defun lmc-open (file)
  (with-open-file (in file
                        :direction :input
                        :if-does-not-exist :error)
    (create-list in)))

(defun create-list (input-stream)
  (let ((e (read-line input-stream nil 'eof)))
    (unless (eq e 'eof)
      (append (list e) (create-list input-stream)))))

;;; Imposta uppercase e taglia
(defun make-upper (line)
  (string-upcase
   (string-trim '(#\Space #\Newline #\Tab)
                (del-comments line))))

;;; Rimuove i commenti
(defun del-comments (line)
  (subseq line 0 (search "//" line)))

;;; Rimuove linee vuote
(defun del-empty (lista)
  (cond ((null lista) nil)
        ((equal (first lista) "")
         (del-empty (rest lista)))
        (T (cons (first lista) (del-empty (rest lista))))))

;;; Formatta lista
(defun list-formatting (oldlist)
  (let ((newlist (mapcar 'make-upper oldlist)))
    (del-empty newlist)))

;;; Labels
(defun parse-labels (lista)
  (cond ((null lista) nil)
        ((eql (find (read-from-string(first lista))
                    '(ADD SUB STA LDA BRA BRZ BRP INP OUT HLT DAT)
                    :test #'equal) NIL)
         (cons (read-from-string (first lista)) (parse-labels (rest lista))))
        (T (cons 0 (parse-labels (rest lista))))))

;;; Clean labels
(defun del-labels (mem label)
  (cond ((null mem) nil)
        ((equal (find (read-from-string (first mem)) label)
              (read-from-string (first mem)))
         (cons (string-trim '(#\Space #\Newline #\Tab)
                           (subseq (first mem) (search " " (first mem))))
               (del-labels (rest mem) label)))
        (T (cons (first mem) (del-labels (rest mem) label)))))


;;; Label pointer e parser numeri
(defun label-pointer (string label)
  (if (numberp (read-from-string string))
      (parse-integer string)
    (if (eql (find (read-from-string string) label :test #'equal) NIL)
        (progn
          (write-line "No such Label")
          NIL)
      (position (read-from-string string) label))))

;;; Memory fill
(defun fillmem (mem)
  (append mem (make-list (- 100 (length mem)) :initial-element 0)))

;;; Estrazione Opcode
(defun opcodes (mem lab)
  (cond ((null mem) nil)
    ;; ADD
    ((equal (read-from-string (first mem)) 'ADD)
     (cons (+ 100 (label-pointer (string-trim '(#\Space #\Newline #\Tab)
                        (subseq (first mem) (search " " (first mem)))) lab))
           (opcodes (rest mem) lab)))
    ;; SUB
    ((equal (read-from-string (first mem)) 'SUB)
     (cons (+ 200 (label-pointer (string-trim '(#\Space #\Newline #\Tab)
                        (subseq (first mem) (search " " (first mem)))) lab))
           (opcodes (rest mem) lab)))
    ;; STORE
    ((equal (read-from-string (first mem)) 'STA)
     (cons (+ 300 (label-pointer (string-trim '(#\Space #\Newline #\Tab)
                        (subseq (first mem) (search " " (first mem)))) lab))
           (opcodes (rest mem) lab)))
    ;; LOAD
    ((equal (read-from-string (first mem)) 'LDA)
     (cons (+ 500 (label-pointer (string-trim '(#\Space #\Newline #\Tab)
                        (subseq (first mem) (search " " (first mem)))) lab))
           (opcodes (rest mem) lab)))
    ;; BRANCH
    ((equal (read-from-string (first mem)) 'BRA)
     (cons (+ 600 (label-pointer (string-trim '(#\Space #\Newline #\Tab)
                        (subseq (first mem) (search " " (first mem)))) lab))
           (opcodes (rest mem) lab)))
    ;; BRANCHZ
    ((equal (read-from-string (first mem)) 'BRZ)
     (cons (+ 700 (label-pointer (string-trim '(#\Space #\Newline #\Tab)
                        (subseq (first mem) (search " " (first mem)))) lab))
           (opcodes (rest mem) lab)))
    ;; BRANCHP
    ((equal (read-from-string (first mem)) 'BRP)
     (cons (+ 800 (label-pointer (string-trim '(#\Space #\Newline #\Tab)
                        (subseq (first mem) (search " " (first mem)))) lab))
           (opcodes (rest mem) lab)))
    ;; INPUT
    ((equal (read-from-string (first mem)) 'INP)
     (cons 901 (opcodes (rest mem) lab)))
    ;; OUTPUT
    ((equal (read-from-string (first mem)) 'OUT)
     (cons 902 (opcodes (rest mem) lab)))
    ;; HALT
    ((equal (read-from-string (first mem)) 'HLT)
     (cons 000 (opcodes (rest mem) lab)))
    ;; DAT
    ((equal (read-from-string (first mem)) 'DAT)
     (if (equal (string-trim '(#\Space #\Newline #\Tab) (first mem)) "DAT")
       (cons 000 (opcodes (rest mem) lab))
       (cons (parse-integer (string-trim '(#\Space #\Newline #\Tab)
                          (subseq (first mem) (search " " (first mem)))))
             (opcodes (rest mem) lab))))
    ;; Ricorsione
    (T (cons (first mem) (del-labels (rest mem) lab)))))
