;;Para utilizar Jedi (o cualquier de las alternativas de
;; autocompletado) es necesario tener instalado el paquete
;; virtualenv de python y ejecutar M-x jedi:install-server
;; jedi mostrara documentacion de los modulos instalados en el
;; ambiente virtual .python-enviroments/jedi y en el scope
;; global por defecto
(require 'python)
(require 'jedi)

;; From https://github.com/jhamrick/emacs
(setq
 python-shell-interpreter "ipython"
 python-shell-interpreter-args (if system-is-mac
                                   "--matplotlib=osx --colors=Linux"
                                 (if system-is-linux
                                     "--gui=gtk3 --matplotlib=gtk3 --colors=Linux"))
 python-shell-prompt-regexp "In \\[[0-9]+\\]: "
 python-shell-prompt-output-regexp "Out\\[[0-9]+\\]: "
 python-shell-completion-setup-code
 "from IPython.core.completerlib import module_completion"
 python-shell-completion-module-string-code
 "';'.join(module_completion('''%s'''))\n"
 python-shell-completion-string-code
 "';'.join(get_ipython().Completer.all_completions('''%s'''))\n")

(add-hook 'python-mode-hook (lambda ()
                              (jedi:setup)
                              ;; Para evitar que  C-tab sea asignado a otra funcion
                              (define-key jedi-mode-map (kbd "<C-tab>") nil)
                              ))
(setq jedi:complete-on-dot t)
(setq jedi:environment-root
      (expand-file-name "jedi" python-environment-directory))

(provide 'setup-python)
