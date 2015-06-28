(require 'cider)

;;Enable eldoc
(add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)
;;Avoid special buffers from apearing when switching buffers
(setq nrepl-hide-special-buffers t)
;;Prevent the auto-display of the REPL buffer in a separate 
;;window after connection is established:
(setq cider-repl-pop-to-buffer-on-connect nil)
;;Stop the error buffer from popping up
(setq cider-popup-stacktraces nil)
;;Enable error buffer popping also in the REPL:
(setq cider-repl-popup-stacktraces t)
;;To auto-select the error buffer when it's displayed:
(setq cider-auto-select-error-buffer t)

;;More shit
(setq cider-stacktrace-default-filters '(tooling dup))
(setq nrepl-buffer-name-separator "-")
(setq nrepl-buffer-name-show-port t)
(setq cider-repl-display-in-current-window t)
(setq cider-repl-print-length 100)
(setq cider-prompt-save-file-on-load nil)
(setq cider-repl-result-prefix ";; => ")
(setq cider-interactive-eval-result-prefix ";; => ")
(setq cider-repl-use-clojure-font-lock t)
(setq cider-repl-wrap-history t)
(setq cider-repl-history-size 1000)
(setq cider-repl-history-file "~/.emacs.d/cider-history")
(add-hook 'cider-repl-mode-hook 'subword-mode)
(add-hook 'cider-repl-mode-hook 'smartparens-strict-mode)
(add-hook 'cider-repl-mode-hook 'rainbow-delimiters-mode)

;; Indent and highlight more commands
(put-clojure-indent 'match 'defun)

;;(require 'ac-cider)
;;(add-hook 'cider-repl-mode-hook 'ac-cide-setup)
;;(add-hook 'cider-mode-hook 'ac-cider-setup)
;; (eval-after-load "auto-complete"
;;   '(progn
;;      (add-to-list 'ac-modes 'cider-mode)
;;      (add-to-list 'ac-modes 'cider-repl-mode)))

;; (defun set-auto-complete-as-completion-at-point-function ()
;;   (setq completion-at-point-functions '(auto-complete)))
;; (add-hook 'auto-complete-mode-hook 'set-auto-complete-as-completion-at-point-function)

;; (add-hook 'cider-repl-mode-hook 'set-auto-complete-as-completion-at-point-function)
;; (add-hook 'cider-mode-hook 'set-auto-complete-as-completion-at-point-function)
(add-hook 'cider-repl-mode-hook #'company-mode)
(add-hook 'cider-mode-hook #'company-mode)

(eval-after-load "cider"
  '(define-key cider-mode-map (kbd "C-c C-d") 'ac-nrepl-popup-doc))

(define-clojure-indent
  (defroutes 'defun)
  (GET 2)
  (POST 2)
  (PUT 2)
  (DELETE 2)
  (HEAD 2)
  (ANY 2)
  (context 2))

(require 'clj-refactor)
(add-hook 'clojure-mode-hook (lambda ()
                               (clj-refactor-mode 1)
                               (cljr-add-keybindings-with-prefix "C-c C-m")))

(require 'align-cljlet)

(provide 'setup-cider)
