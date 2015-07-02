;; IMPORTANTE: Agregar la linea (provide 'jabber-autoloads) al final de 
;;jabber-autoloads.el(que se encuentra en algun lugar de la carpeta elpa)
;; al parecer las ultimas versiones no lo incluyen ._.
(require 'jabber-autoloads)
(require 'auth-source)


(defadvice jabber-connect-all (before jabber-read-from-authinfo)
  (let ((auths (auth-source-search :port "xmpp"
                                   :require '(:secret))))
    (setq jabber-account-list
          (mapcar (lambda (account-auth)
                    (let ((acc (list (concat (plist-get account-auth :user) "@"
                                             (plist-get account-auth :host)))))
                      (if (string= (plist-get account-auth :host) "gmail.com")
                          (append acc '((:network-server . "talk.google.com")
                                        (:connection-type . ssl)))
                        acc)))
                  auths))))

;; http://stackoverflow.com/questions/5583413/how-do-i-get-jabber-el-to-not-show-the-user-icons
(setq
 jabber-show-offline-contacts nil
 jabber-roster-line-format " %c %-25n %u %-8s (%r)"
 jabber-roster-buffer "*-jabber-*"
 jabber-mode-line-mode t
 jabber-chat-buffer-format "*-jabber-%n-*"
 jabber-avatar-verbose nil
 jabber-auto-reconnect t
 ;;jabber-vcard-avatars-retrieve nil
 ;; jabber-chat-buffer-show-avatar nil
 jabber-history-enabled nil
 jabber-use-global-history nil
 jabber-backlog-number 40
 jabber-backlog-days 30)

(setq jabber-alert-presence-message-function
      (lambda (who oldstatus newstatus statustext)
        nil))

;;(message "jabber - Autosmiley")
;; En la desktop el smiley está roto
;;(require 'autosmiley)
;;(add-hook 'jabber-chat-mode-hook 'autosmiley-mode)
(add-hook 'jabber-chat-mode-hook 'visual-line-mode)
;;Resaltar urls
(add-hook 'jabber-chat-mode-hook 'goto-address)

(defun jabber-visit-history (jid)
  "Visit jabber history with JID in a new buffer.

 Performs well only for small files. Expect to wait a few seconds
 for large histories. Adapted from `jabber-chat-create-buffer'."
  (interactive (list (jabber-read-jid-completing "JID: ")))
  (let ((buffer (generate-new-buffer (format "*-jabber-history-%s-*"
                                             (jabber-jid-displayname jid)))))
    (switch-to-buffer buffer)
    (make-local-variable 'jabber-chat-ewoc)
    (setq jabber-chat-ewoc (ewoc-create #'jabber-chat-pp))
    (mapc 'jabber-chat-insert-backlog-entry
          (nreverse (jabber-history-query nil nil t t "."
                                          (jabber-history-filename jid))))
    (view-mode)))

(message "setup-jabber")
(provide 'setup-jabber)
