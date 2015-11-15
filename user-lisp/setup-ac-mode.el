(require 'auto-complete-config)
;; Porque capitalizas las palabras por defecto???? Sabes cuanto sufri por eso?
(setq ac-ignore-case nil)
(ac-config-default)
(ac-linum-workaround)
(ac-flyspell-workaround)
(ac-set-trigger-key "TAB")
(provide 'setup-ac-mode)
