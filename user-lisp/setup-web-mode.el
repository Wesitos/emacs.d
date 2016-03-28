(require 'web-mode)
(require 'rainbow-mode)

(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[gj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))

(defun react-mode ()
  (interactive)
  (web-mode)
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-content-type "jsx")
  )

(add-to-list 'auto-mode-alist '("\\.jsx\\'" . react-mode))

(setq web-mode-content-types-alist
      '(
        ("jsx" . "\\.jsx\\'"))
      )

(setq web-mode-code-indent-offset 2)

(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (rainbow-mode t) ;; That's pretty
  )



(add-hook 'web-mode-hook 'my-web-mode-hook)

(setq web-mode-enable-current-column-highlight t
      web-mode-enable-current-element-highlight nil
      web-mode-enable-auto-closing t
      web-mode-enable-auto-pairing t
      web-mode-enable-auto-opening t
      web-mode-enable-part-face nil
      web-mode-enable-auto-quoting nil)
(provide 'setup-web-mode)
