(require 'perspective)
(require 'org)

;; loading code for our custom perspectives
;; taken from Magnar Sveen
(defmacro custom-persp (name &rest body)
  `(let ((initialize (not (gethash ,name perspectives-hash)))
         (current-perspective persp-curr))
     (persp-switch ,name)
     (when initialize ,@body)
     (setq persp-last current-perspective)))

;; Jump to last perspective
;; taken from Magnar Sveen
(defun custom-persp-last ()
  (interactive)
  (persp-switch (persp-name persp-last)))

(defun persp-cycle-next ()
  "Cycle throught the available perspectives."
  (interactive)
  (let ((next-pos (1+ (cl-position (persp-name persp-curr) (persp-names))))
        (list-size (length (persp-all-names))))
    (cond ((eq 1 list-size) (persp-switch nil))
          ((>= next-pos list-size) (persp-switch (nth 0 (persp-all-names))))
          (t (persp-next)))))

(defun persp-cycle-prev ()
  "Cycle throught the available perspectives."
  (interactive)
  (let ((next-pos (- (cl-position (persp-name persp-curr) (persp-names)) 1))
        (list-size (length (persp-all-names))))
    (cond ((eq 1 list-size) (persp-switch nil))
          ((< next-pos 0) (persp-switch (nth (- list-size 1) (persp-all-names))))
          (t (persp-prev)))))

;; Easily switch to your last perspective
(define-key persp-mode-map (kbd "C-x p -") 'custom-persp-last)

;; muh perspectives
(defun custom-persp/emacs ()
  (interactive)
  (custom-persp "@emacs"
                (find-file "~/.emacs.d/init.el")
                (find-file "~/.emacs.d/sane-defaults.el")
                (find-file "~/.emacs.d/key-bindings.el")
                (find-file "~/.emacs.d/appearance.el")
                ))

(define-key persp-mode-map (kbd "C-x p e") 'custom-persp/emacs)

;; (defun custom-persp/irc ()
;;   (interactive)
;;   (custom-persp "@IRC" (rcirc nil)))
;; (define-key persp-mode-map (kbd "C-x p i") 'custom-persp/irc)

(defun connect-to-jabber ()
  (jabber-connect-all)
  (jabber-switch-to-roster-buffer))
(defun custom-persp/jabber ()
  (interactive)
  (custom-persp "@Jabber"
                (split-window-right)
                (connect-to-jabber)))
(define-key persp-mode-map (kbd "C-x p j") 'custom-persp/jabber)

;; (defun custom-persp/twitter ()
;;   (interactive)
;;   (custom-persp "@Twitter" (twit)))
;; (define-key persp-mode-map (kbd "C-x p t") 'custom-persp/twitter)

(defun custom-persp/org ()
  (interactive)
  (custom-persp "@org"
                (find-file (first org-agenda-files))))
(define-key persp-mode-map (kbd "C-x p o") 'custom-persp/org)

(defun custom-persp/matlab ()
  (interactive)
  (custom-persp "@matlab"
                (split-window-right)
                (matlab-shell)
                ))
(define-key persp-mode-map (kbd "C-x p m") 'custom-persp/matlab)

(defun custom-persp/octave ()
  (interactive)
  (custom-persp "@octave"
                (split-window-right)
                (run-octave)
                ))
(define-key persp-mode-map (kbd "C-x p o") 'custom-persp/octave)

(defun custom-persp/react-init ()
  (interactive)
  (custom-persp "@react-init"
                (find-file "~/Copy/pucp/makerlab/react/react-init/README.md")
                ))
(define-key persp-mode-map (kbd "C-x p r") 'custom-persp/react-init)


(persp-mode)

(provide 'setup-persp-mode)
