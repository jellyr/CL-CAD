(in-package :cl-cad)

(defvar *signal* nil)
(defvar *end* nil)

(defun draw-shadow ()
  (cond
    ((equal *signal* :line) (input-for-line))
    ((equal *signal* :circle) (input-for-circle))
    ;((equal *signal* :arc) (input-for-arc))
    ;((equal *signal* :continious) (input-for-continious))
    ;((equal *signal* :ray) (input-for-ray))
    ((equal *signal* :point) (input-for-point))
    ))

(defun get-coord-angle ()
  (* (atan (/ (- *current-y* *y*)
	      (- *current-x* *x*)))
     (/ 180 pi)))

(defun input-for-line ()
  (set-source-rgb 1 0 0)
  (set-line-width 0.5)
  (move-to 
   (if (equal *x* 0) 
       *current-x*
       *x*)
   (if (equal *y* 0) 
       *current-y*
       *y*))
  (line-to *current-x* *current-y*)
  (stroke)
  (set-source-rgb 0 0 0)
  (move-to *x* *y*)
  (line-to *x* (- *y* 20))
  (move-to *current-x* *current-y*)
  (line-to *current-x* (- *current-y* 20))
  (move-to *x* (- *y* 17))
  (line-to *current-x* (- *current-y* 17))
  (stroke))
 ; (if (equal *end* nil)
 ;  (progn 
 ;    (add-line "0" *last-x* *last-y* 0 *x* *y* 0 "continious" 1 1 1)
 ;    (setf *x* 0 *y* 0)
 ;    (setf *end* nil))))

(defun input-for-circle ()
  (set-source-rgb 1 0 0)
  (set-line-width 0.5)
  (arc (if (equal *x* 0) 
	   *current-x*
	   *x*)
       (if (equal *y* 0) 
	   *current-y*
	   *y*)
       (sqrt
	(+
	 (* (- *x* *current-x*)
	    (- *x* *current-x*))
	 (* (- *y* *current-y*)
	    (- *y* *current-y*))))
        0 (* 2 pi))
  (stroke)
  (set-source-rgb 0 0 0)
  (move-to (+ *x* 5) *y*)
  (line-to (- *x* 5) *y*)
  (move-to *x* (+ *y* 5))
  (line-to *x* (- *y* 5))
  (stroke)
  (set-source-rgb 0 1 0)
  (move-to *x* *y*)
  (line-to *current-x* *current-y*)
  (stroke))

;  (if (equal *end* t)
;      (progn
;	(add-circle "0" 
;		    *x* 
;		    *y* 
;		    0 
;		    (sqrt
;		     (+
;		      (* (- *x* *current-x*)
;			 (- *x* *current-x*))
;		      (* (- *y* *current-y*)
;			 (- *y* *current-y*))))
;		    1 1 1 1)
;	(setf *x* 0 *y* 0)
;	(setf *end* nil))))

(defun input-for-point ()
  (set-source-rgb 1 0 0)
  (set-line-width 0.5)
  (rectangle (- (/ *scroll-units* *current-x*) 0.5)
	     (- (/ *scroll-units* *current-y*) 0.5)
	     1 1)
  (fill-path)
  (restore))