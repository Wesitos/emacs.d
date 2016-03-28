(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

;; Para que no de advertencias sobre comas al final de arrays u objetos
(setq js2-strict-trailing-comma-warning nil)

(setq js2-basic-offset 2)

(add-hook 'js-mode-hook 'js2-minor-mode)
(add-hook 'js2-mode-hook 'ac-js2-mode)


(require 'flycheck)
(add-hook 'after-init-hook #'global-flycheck-mode)

(setq-default flycheck-disabled-checkers
  (append flycheck-disabled-checkers
    '(javascript-jshint)))

;; use eslint with web-mode for jsx files
(flycheck-add-mode 'javascript-eslint 'web-mode)

;; disable json-jsonlist checking for json files
(setq-default flycheck-disabled-checkers
  (append flycheck-disabled-checkers
    '(json-jsonlist)))


(provide 'setup-js)
;;; Setup-js.el ends here
