;; No mostrar pantalla de inicio
(setq inhibit-startup-message t)

;;Ocultar barra de herramientas
(tool-bar-mode -1)

;; Set path to dependencies
(setq site-lisp-dir
      (expand-file-name "site-lisp" user-emacs-directory))

(setq user-lisp-dir
      (expand-file-name "user-lisp" user-emacs-directory))

;; Set up load path

(add-to-list 'load-path site-lisp-dir)
(add-to-list 'load-path user-lisp-dir)

;;Mantener configuraciones personalizadas de emacs en un archivo diferente
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)

;; Set up appearance early
(load-file (expand-file-name "appearance.el" user-emacs-directory))

;; Write backup files to own directory
(setq backup-directory-alist
      `(("." . ,(expand-file-name
                 (concat user-emacs-directory "backups")))))

;; Make backups of files, even when they're in version control
(setq vc-make-backup-files t)

;; Tildes y otras teclas muertas
(require 'iso-transl)

;; Are we on a mac?
(setq system-is-mac (equal system-type 'darwin))

;; Are we on Gnu/linux?
(setq system-is-linux (equal system-type 'gnu/linux))

;; Setup packages
(load-file (expand-file-name "setup-package.el" user-emacs-directory))

;; Install extensions if they're missing
(defun init--install-packages ()
  (packages-install
   '(dired-details
     diminish  ;; Permite ocultar nombres de la barra de modos
     flx-ido
     ido-ubiquitous
     flycheck
     gist ;; gist.github.com
     jabber ;; cliente de chat
     undo-tree

     ;;Para programar
     rainbow-delimiters  ;;Parentesis de colores diferentes
     smartparens   ;;Manejo de parentesis
     pretty-mode  ;; :3
     auto-complete
     company
     expand-region

     ;;Git
     magit    ;;Trabajar con git
     git-timemachine
     gitignore-mode

     ;;Some modes
     gnuplot-mode
     matlab-mode
     arduino-mode
     yaml-mode
     csv-mode

     ;;python
     jedi
     python-environment
     ;;ein

     ;;Orden
     perspective
     multi-term
     saveplace ;;Guarda ubicaciones en un archivo
     prodigy ;;Gestiona servicios externos
     org  ;;Gestion de notas
     projectile  ;;proyectos

     ;;LaTeX
     auctex
     ac-math

     helm ;;Helm and stuff
     helm-themes
     helm-c-yasnippet
     helm-projectile
     helm-spotify ;;Weeee

     ;;Clojure
     ;;ac-nrepl ;;No longer in repositories
     ;;ac-cider ;;Now is company
     cider
     ;;cider-tracing ;;No longer in repositories
     clj-refactor
     clojure-cheatsheet
     clojure-snippets
     latest-clojure-libraries
     align-cljlet

     ;;Web
     web-mode
     restclient ;;Para enviar peticiones http rest
     impatient-mode ;;Visualizacion de html en tiempo real
     php-mode ;; Puede ser util
     rainbow-mode
     w3m ;;Navegador web
     nginx-mode
     js2-mode ;; jsx :p
     json-mode
     sass-mode ;; old sass
     scss-mode ;; modern sass

     ;; lalala
     xkcd

     ;;dash-at-point

     ;;twittering-mode ;;cliente de twitter
     ;; whitespace-cleanup-mode
     ;; browse-kill-ring
     ;; quickrun
     ;; guide-key
     ;; itail
     ;; diff-hl
     ;; powerline
     )))

(condition-case nil
    (init--install-packages)
  (error
   (package-refresh-contents)
   (init--install-packages)))

;; Lets start with a smattering of sanity
(load-file (expand-file-name "sane-defaults.el" user-emacs-directory))

;; Emacs server
(require 'server)
(unless (server-running-p)
  (server-start)
  (message "Server started"))

;; Load user specific configuration
(when (file-exists-p user-lisp-dir)
  (mapc 'load (directory-files user-lisp-dir nil "^[^#].*el$")))

;; Setup Key bindings after smartparens config
(load-file (expand-file-name "key-bindings.el" user-emacs-directory))
