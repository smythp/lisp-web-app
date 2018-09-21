(ql:quickload '(cl-who hunchentoot parenscript))

(defpackage :retro-games
  (:use :cl :cl-who :hunchentoot :parenscript))

(in-package :retro-games)

(defclass game ()
  ((name :initarg :name
	 :reader name)
   (votes :accessor votes
	  :initform 0)))


(defvar *games*
  '())


(defun vote (game)
  (incf (votes game)))


(defun game-from-name (name)
  (find name *games* :key #'name
	:test #'string-equal))


(defun game-stored-p (game-name)
  (game-from-name game-name))


(defun add-game (game-name)
  (unless (game-stored-p game-name)
    (push (make-instance 'game :name game-name) *games*)))


(defun games ()
  (sort (copy-list *games*) #'> :key #'votes))


(add-game "Charles Barkley Shut Up and Jam")")


(defun most-popular-game ()
  (car (sort (copy-list *games*) #'> :key #'votes)))


(defmethod print-object ((object game) stream)
  (print-unreadable-object (object stream :type t)
    (with-slots (name votes) object
      (format stream "name ~s with ~d votes" name votes))))


(setf (html-mode) :html5)


(defmacro html-boilerplate (title link &body body)
  `(with-html-output-to-string (*standard-output* nil :prologue t :indent t)
     (:html :lang "en"
	    (:head
	     (:meta :charset "utf-8")
	     ,title
	     ,link
	    (:body
	     ,body)
	    ))))


(push (create-prefix-dispatcher "/index" 'retro-games)
      *dispatch-table*)


(defun retro-games ()
  (html-boilerplate (:title "Retro Games Homepage") (:link :rel "stylesheet" :href "styles.css" :type "text/css")
    (:br)
    (:div :id "main"
	  (:h1 "Retro Games Watch")
	  (:p "Vote for the best old game.")
	  (:p "Don't see your game here?"
	      (:a :href "add-game" "Add it here."))
	  (:ul :id "game-list"
	   (dolist (game (games))
	     (htm
	      (:li (str (name game)) " | " (str (votes game)))))))))


(push (create-static-file-dispatcher-and-handler
       "/styles.css" "~/projects/lisp-web-app/styles.css")
      *dispatch-table*)

