(require 'csv-mode)

(setq csv-separators '("," " " "	"))

(add-hook 'csv-mode-hook (lambda ()
                           (setq tab-width 16)))
(define-key csv-mode-map (kbd "TAB") 'self-insert-command)

(provide 'setup-csv)
