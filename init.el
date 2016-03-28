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


(setq backup-by-copying t   ; don't clobber symlinks
      version-control t     ; use versioned backups
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2)

;; Make backups of files, even when they're in version control
(setq vc-make-backup-files t)

(setq auto-save-file-name-transforms
      `((".*" , (expand-file-name
                 (concat user-emacs-directory "auto-saves")) t)
        ))

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
     f ;; Funciones para trabajar con archivos
     exec-path-from-shell ;; sirve para incluir el path de nvm al llamar a eslint
     flx-ido
     ido-ubiquitous
     flycheck
     gist ;; gist.github.com
     jabber ;; cliente de chat
     undo-tree
     whitespace-cleanup-mode

     ;;Para programar
     rainbow-delimiters  ;;Parentesis de colores diferentes
     smartparens   ;;Manejo de parentesis
     pretty-mode  ;; :3
     auto-complete
     company
     expand-region
     flycheck

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
     markdown-mode

     ;;python
     python-mode
     python-environment
     jedi
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
     cider
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
     ac-js2
     json-mode
     sass-mode ;; old sass
     scss-mode ;; modern sass

     ;; lalala
     xkcd

     ;; Org mode
     ox-gfm ;; Github flavored markdown

     ;;dash-at-point

     ;;twittering-mode ;;cliente de twitter
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

;; this hopefully sets up path and other vars better
;;(exec-path-from-shell-initialize)

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

;; Abramos la lista de tareas
(find-file "~/TODO.org")
