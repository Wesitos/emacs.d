(require 'helm-config)
(require 'helm-projectile)

(setq helm-ff-transformer-show-only-basename nil)

;; sauce: http://stackoverflow.com/questions/19283368/how-can-i-open-quickly-a-file-in-emacs
;; you'll need to require helm-config and helm-projectile somewhere above
(defun helm-overlord (&rest arg)
  ;; just in case someone decides to pass an argument, helm-omni won't fail.
  (interactive)
  (helm-other-buffer
   (append ;; projectile errors out if you're not in a project
    (when (projectile-project-p) ;; so look before you leap
      '(helm-source-projectile-buffers-list
        helm-source-projectile-recentf-list
        helm-source-projectile-files-list)
      ) ;; files in current directory
    '(helm-source-buffers-list ;; list of all open buffers
      helm-source-recentf ;; all recent files
      helm-source-files-in-current-dir
      helm-source-bookmarks ;; bookmarks too
      helm-source-buffer-not-found)) ;; ask to create a buffer otherwise
   "*all-seeing-eye*"))

(provide 'setup-helm)
