;;Para utilizar Jedi (o cualquier de las alternativas de
;; autocompletado) es necesario tener instalado el paquete
;; virtualenv de python y ejecutar M-x jedi:install-server
;; jedi mostrara documentacion de los modulos instalados en el
;; ambiente virtual .python-enviroments/jedi y en el scope
;; global por defecto
(require 'python)
(require 'jedi)

;; Python 3.5 new keywords
(font-lock-add-keywords 'python-mode
                        '(("async" . font-lock-keyword-face)
                          ("await" . font-lock-keyword-face)))

(declare-function python-shell-calculate-exec-path "python")

(require 'flycheck)

(defun flycheck-virtualenv-set-python-executables ()
  "Set Python executables for the current buffer."
  (let ((exec-path (python-shell-calculate-exec-path)))
    (setq-local flycheck-python-pylint-executable
                (executable-find "pylint"))
    (setq-local flycheck-python-flake8-executable
                (executable-find "flake8"))))

(defun flycheck-virtualenv-setup ()
  "Setup Flycheck for the current virtualenv."
  (when (derived-mode-p 'python-mode)
    (add-hook 'hack-local-variables-hook
              #'flycheck-virtualenv-set-python-executables 'local)))

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
              '("--python" "/usr/bin/python3.5")))

(provide 'setup-python)
