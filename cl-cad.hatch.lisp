(in-package :cl-cad)

(defvar *hatch-type* :solid)
(defstruct hatch title)

(defun hatch-window ()
  (within-main-loop
    (let* ((window (make-instance 'gtk-window 
				  :type :toplevel 
				  :title "Hatch" 
				  :window-position :center))
	   (frame1 (make-instance 'frame :label "Pattern"))
	   (frame2 (make-instance 'frame :label "Preview"))
	   (v-box1 (make-instance 'v-box))
	   (h-box1 (make-instance 'h-box))
	   (h-box (make-instance 'h-box))
	   (v-box (make-instance 'v-box))
	   (image (make-instance 'image :file (hatch-picture-selector)))
	   (model (make-instance 'array-list-store))
	   (combo (make-instance 'combo-box :model model))
	   (scale-label (make-instance 'label :label "Scale"))
	   (scale-entry (make-instance 'entry))
	   (angle-label (make-instance 'label :label "Angle"))
	   (angle-entry (make-instance 'entry))
	   (button-ok (make-instance 'button :label "Ok"))
	   (button-cancel (make-instance 'button :label "Cancel")))
      (container-add window v-box1)
      (box-pack-start v-box1 h-box :expand nil)
      (box-pack-start v-box1 h-box1 :expand nil)
      (box-pack-start h-box frame1 :expand nil)
      (container-add frame1 v-box)
      (box-pack-start h-box frame2)
      (container-add frame2 image)
      (box-pack-start v-box combo :expand nil)
      (box-pack-start v-box scale-label :expand nil)
      (box-pack-start v-box scale-entry :expand nil )
      (box-pack-start v-box angle-label :expand nil)
      (box-pack-start v-box angle-entry :expand nil)
      (box-pack-start h-box1 button-ok :expand nil)
      (box-pack-start h-box1 button-cancel :expand nil)
      (store-add-column model "gchararray" #'hatch-title)
      (hatcher model)
      (let ((renderer (make-instance 'cell-renderer-text :text "A text")))
	(cell-layout-pack-start combo renderer :expand t)
	(cell-layout-add-attribute combo renderer "text" 0))
      (connect-signal window "destroy" (lambda (w) (declare (ignore w)) (leave-gtk-main)))
      (connect-signal button-ok "clicked" (lambda (w) (declare (ignore w)) (object-destroy window)))
      (connect-signal button-cancel "clicked" (lambda (w) (declare (ignore w)) (object-destroy window)))
      (gobject:g-signal-connect combo "changed" (lambda (c) (declare (ignore c)) (hatch-type-select combo)))
      (widget-show window))))

(defun hatch-type-select (combo)
  (cond 
    ((equal (combo-box-active combo) 0) (setf *hatch-type* :solid))
    ((equal (combo-box-active combo) 1) (setf *hatch-type* :ansi))))

(defun hatcher (model)
  (store-add-item model (make-hatch :title "Solid"))
  (store-add-item model (make-hatch :title "Ansi")))

(defun hatch-picture-selector ()
  (cond 
    ((equal *hatch-type* :solid) (namestring (merge-pathnames "graphics/hatch/solid.svg" *src-location*)))
    ((equal *hatch-type* :angle) (namestring (merge-pathnames "graphics/hatch/angle.svg" *src-location*)))))