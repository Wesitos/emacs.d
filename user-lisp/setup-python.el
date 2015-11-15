;;Para utilizar Jedi (o cualquier de las alternativas de
;; autocompletado) es necesario tener instalado el paquete
;; virtualenv de python y ejecutar M-x jedi:install-server
;; jedi mostrara documentacion de los modulos instalados en el
;; ambiente virtual .python-enviroments/jedi y en el scope
;; global por defecto
(require 'python)
(require 'jedi)

(add-hook 'python-mode-hook (lambda ()
                              (jedi:setup)
                              ;; Para evitar que  C-tab sea asignado a otra funcion
                              (define-key jedi-mode-map (kbd "<C-tab>") nil)
                              ))
(setq jedi:complete-on-dot t)
(setq jedi:environment-root
      (expand-file-name "jedi" python-environment-directory))
;; Para utilizar python3 (por lo menos en ubuntu...)
;; En caso de haber problemas con jedi:install-server, esto puede
;; deberse a que intenta instalar epc con pip-2.7 en vez de pip 3.x
;; instalar epc con pip parece solucionar el problema...
(setq jedi:environment-virtualenv
      (append python-environment-virtualenv
              '("--python" "/usr/bin/python3")))

(provide 'setup-python)
