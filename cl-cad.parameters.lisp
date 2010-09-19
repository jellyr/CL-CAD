(in-package :cl-cad)

(defparameter *src-location* (asdf:component-pathname (asdf:find-system :cl-cad)))
(defvar *scroll-units* 1)
(defparameter *current-layer* "system")
(defvar *current-color* (make-color :PIXEL 136747408 :RED 65535 :GREEN 65535 :BLUE 65535))
(defparameter *line-type* :continious)
(defparameter *color-current-layer* nil)
(defparameter *current-width* 1)
(defvar *current-font* "Sans 10")
(defvar *text-buffer-count* "")
(defparameter *week-day-names* '("Monday" 
				 "Tuesday"
				 "Wednesday"
				 "Fhursday" 
				 "Friday" 
				 "Saturday" 
				 "Sunday"))
(defvar *grid-step* 5)

;osnaps
(defvar *x* nil)
(defvar *y* nil)
(defvar *x1* nil)
(defvar *y1* nil)
(defvar *x2* nil)
(defvar *y2* nil)
(defvar *angle1* 0)
(defvar *angle2* 0)
(defvar *length* 0)
(defvar *current-x* nil)
(defvar *current-y* nil)
(defparameter *osnap-area-delta* 10)
(defparameter *osnap-center* nil)
(defparameter *osnap-end* t)
(defparameter *osnap-insert* nil)
(defparameter *osnap-intersection* t)
(defparameter *osnap-midpoint* nil)
(defparameter *osnap-nearest* nil)
(defparameter *osnap-point* nil)
(defparameter *osnap-perpendicular* nil)
(defparameter *osnap-quadrant* nil)
(defparameter *osnap-tangent* nil)
(defparameter *osnap-track* nil)
(defparameter *osnap-grid* nil)
(defparameter *osnap-ortho* nil)
(defparameter *osnap-grid* nil)

(defstruct units count)

(defun color-cairo-to-gdk (a)
  (* a 65535))

(defun color-gtk-to-cairo (a)
  (/ a 65535))

(defun draw-properties-window (parent-window)
  (within-main-loop
   (let* ((window (make-instance 'gtk-window 
				 :title "Properties" 
				 :type :toplevel 
				 :window-position :center 
				 :default-width 600 
				 :default-height 400 
				 :destroy-with-parent t
				 :transient-for parent-window))
	 (v-box (make-instance 'v-box))
	 (h-box (make-instance 'h-box))
	 (notebook (make-instance 'notebook :enable-popup t :tab-pos :left))
	 (button-save (make-instance 'button :label "Save"))
	 (button-cancel (make-instance 'button :label "Cancel"))
	 (basic-vbox (make-instance 'v-box))
	 (basic-table (make-instance 'table :n-rows 7 :n-columns 2 :homogeneous nil))
	 (units-label (make-instance 'label :label "Default units"))
	 (model (make-instance 'array-list-store))
	 (combo-box (make-instance 'combo-box :model model))
	 (highlight (make-instance 'label :label "Highlight points"))
	 (highlight-check (make-instance 'check-button :label "Boxes are drawn around point obgects" :active (config-highlight-points *config*)))
	 (split (make-instance 'label :label "Autosplitting"))
	 (split-check (make-instance 'check-button :label "New points split existing entities" :active (config-autosplitting *config*)))
	 (drawing-area-color (make-instance 'label :label "Drawing area color"))
	 (button-drawing-area-color-selection (make-instance 'color-button :color (config-drawing-area-color *config*)))
	 (dim-color (make-instance 'label :label "Dimension color"))
	 (button-dim-color-selection (make-instance 'color-button :color (config-dim-color *config*)))
	 (osnap-color (make-instance 'label :label "Osnap color"))
	 (button-osnap-color-selection (make-instance 'color-button :color (config-osnap-color *config*)))
	 (point-color (make-instance 'label :label "Object points color"))
	 (button-point-color-selection (make-instance 'color-button :color (config-point-color *config*)))
	 (author-entry (make-instance 'entry :text (config-author *config*)))
	 (new-vbox (make-instance 'v-box))
	 (screen-vbox (make-instance 'v-box))
	  (grid-step-spin-box (make-instance 'spin-button)))
     (store-add-column model "gchararray" #'units-count)
     (store-add-item model (make-units :count "Millimeters"))
     (store-add-item model (make-units :count "Micrometers"))
     (store-add-item model (make-units :count "Meters"))
     (store-add-item model (make-units :count "Kilometers"))
     (store-add-item model (make-units :count "Inches"))
     (store-add-item model (make-units :count "Feet"))
     (store-add-item model (make-units :count "Yard"))
     (store-add-item model (make-units :count "Miles"))
     (box-pack-start basic-vbox basic-table)
     (table-attach basic-table units-label 0 1 0 1)
     (table-attach basic-table combo-box 1 2 0 1)
     (table-attach basic-table highlight  0 1 1 2)
     (table-attach basic-table highlight-check 1 2 1 2)
     (table-attach basic-table split 0 1 2 3)
     (table-attach basic-table split-check 1 2 2 3)
     (table-attach basic-table drawing-area-color 0 1 3 4)
     (table-attach basic-table button-drawing-area-color-selection 1 2 3 4)
     (table-attach basic-table dim-color 0 1 4 5)
     (table-attach basic-table button-dim-color-selection 1 2 4 5)
     (table-attach basic-table osnap-color 0 1 5 6)
     (table-attach basic-table button-osnap-color-selection 1 2 5 6)
     (table-attach basic-table point-color 0 1 6 7)
     (table-attach basic-table button-point-color-selection 1 2 6 7)
     (box-pack-start v-box notebook)
     (box-pack-start v-box h-box :expand nil)
     (notebook-add-page notebook
			basic-vbox
			(make-instance 'label :label "Basic"))
     (notebook-add-page notebook
			new-vbox
			(make-instance 'label :label "New drawings"))
     (notebook-add-page notebook
			screen-vbox
			(make-instance 'label :label "Current screen"))
     (notebook-add-page notebook
			(make-instance 'v-box)
			(make-instance 'label :label "Current draw"))
     (box-pack-start new-vbox author-entry :expand nil)
     (box-pack-start screen-vbox grid-step-spin-box :expand nil)
     (box-pack-start h-box button-save :expand nil)
     (box-pack-start h-box button-cancel :expand nil)
     (container-add window v-box)
     (let ((renderer (make-instance 'cell-renderer-text :text "A text")))
        (cell-layout-pack-start combo-box renderer :expand t)
        (cell-layout-add-attribute combo-box renderer "text" 0))
     (gobject:g-signal-connect window "destroy" (lambda (w) (declare (ignore w)) (leave-gtk-main)))
     (gobject:g-signal-connect button-cancel "clicked" (lambda (b) (declare (ignore b)) (object-destroy window)))
     (gobject:g-signal-connect combo-box "changed" (lambda (c)
						     (declare (ignore c))
						     (format t "You clicked on row ~A~%" (combo-box-active combo-box))))
     (gobject:g-signal-connect button-drawing-area-color-selection "color-changed" (lambda (s) 
										     (declare (ignore s)) 
										     (unless (color-selection-adjusting-p button-drawing-area-color-selection)
										       (format t "color: ~A~%" (color-selection-current-color button-drawing-area-color-selection)))))
     (gobject:g-signal-connect button-dim-color-selection "color-changed" (lambda (s) 
									    (declare (ignore s)) 
									    (unless (color-selection-adjusting-p button-dim-color-selection) 
									      (format t "color: ~A~%" (color-selection-current-color button-dim-color-selection)))))
     (gobject:g-signal-connect button-osnap-color-selection "color-changed" (lambda (s) 
									      (declare (ignore s)) 
									      (unless (color-selection-adjusting-p button-osnap-color-selection) 
										(format t "color: ~A~%" (color-selection-current-color button-osnap-color-selection)))))
     (gobject:g-signal-connect button-point-color-selection "color-changed" (lambda (s) 
									      (declare (ignore s)) 
									      (unless (color-selection-adjusting-p button-point-color-selection) 
										(format t "color: ~A~%" (color-selection-current-color button-point-color-selection)))))
     (gobject:g-signal-connect highlight-check "toggled" (lambda (s)
							   (declare (ignore s))
							   (if (equal (config-highlight-points *config*) nil)
							       (setf (config-highlight-points *config*) t)
							       (setf (config-highlight-points *config*) nil))))
     (gobject:g-signal-connect split-check "toggled" (lambda (s)
						       (declare (ignore s))
						       (if (equal (config-autosplitting *config*) nil)
							   (setf (config-autosplitting *config*) t)
							   (setf (config-autosplitting *config*) nil))))
     (gobject:g-signal-connect button-save "clicked" (lambda (b)
						     (declare (ignore b))
						     (setf (config-author *config*) (or (entry-text author-entry) ""))
						     (setf (config-drawing-area-color *config*) (color-button-color button-drawing-area-color-selection))
						     (setf (config-dim-color *config*) (color-button-color button-dim-color-selection))
						     (setf (config-osnap-color *config*) (color-button-color button-osnap-color-selection))
						     (setf (config-point-color *config*) (color-button-color button-point-color-selection))
						     (save-config)
						     (object-destroy window)))
     (widget-show window))))