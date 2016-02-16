;;; org-inline-image.el --- Inline images into org-mode buffers

;; Copyright (C) 2014 Matus Goljer <matus.goljer@gmail.com>

;; Author: Matus Goljer <matus.goljer@gmail.com>
;; Maintainer: Matus Goljer <matus.goljer@gmail.com>
;; Version: 0.0.1
;; Created: 26 April 2014
;; Package-requires: ((dash "2.5.0"))
;; Keywords: outlines, hypermedia, calendar, wp
;; URL: https://github.com/Fuco1/org-inline-image

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package adds functionality to inline images into an `org-mode'
;; buffer.  The images can be present locally on the filesystem (not
;; implemented yet) or downloaded from the internet automatically.

;; In addition to a simple direct-to-image links, this package
;; supports a resolving mechanism to inline images from popular
;; websites such as imgur, deviantart, tumblr and others.  There is
;; also planned support for galleries.

;; An example use-case is a bookmarks file, where the user can easily
;; display the images/galleries in emacs without switching to the
;; browser, which is often not necessary.

;; Use
;; ---

;; Call `org-inline-image' when the point is on the link to inline it
;; there.  The link text will be overlayed with the image.  To hide
;; the image, hit `h' (or call `org-inline-image-hide') while the
;; point is on the image.  Gif images are animated automatically when
;; inlined.  To animate it again, hit `a' (or call
;; `org-inline-image-animate').

;; Supported websites
;; ------------------

;; See the file `examples.org' for all supported links.  If you want
;; your preferred site to be supported, please write a resolver and
;; submit a patch, or at least start an issue where details could be
;; discussed.

;; The built in `org-inline-image--regexp-resolver' uses an alist
;; `org-inline-image-regexp-resolver-alist' to feed the URL to a
;; function which will return the URL of the image by matching the
;; supplied URL to a regexp.  For a more sophisticated resolver, you
;; can write a custom function and add it to
;; `org-inline-image-resolvers'.  See the documentation of the
;; mentioned functions for more informations.

;;; Code:

(require 'org)
(require 'dash)
(require 'f)
(require 'url)

(defgroup org-inline-image ()
  "Inline images into org-mode buffers."
  :group 'org
  :prefix "org-inline-image-")

(defcustom org-inline-image-root "/tmp/org-inline-image/"
  "Root directory where temp files are stored."
  :type 'directory
  :group 'org-inline-image)

(defcustom org-inline-image-resolvers '(org-inline-image--regexp-resolver identity)
  "List of functions which resolve URLs.

Each function should take one input argument.

The input is an arbitrary URL.

The output is a direct URL to the image resource (presumably
related to the input URL).  The first non-nil result is used."
  :type 'hook
  :options '(org-inline-image--regexp-resolver identity)
  :group 'org-inline-image)

(defcustom org-inline-image-regexp-resolver-alist
  '(("deviantart\\.com/art/" . org-inline-image--resolve-deviantart-image)
    ("//\\(www\\.\\)?imgur\\.com" . org-inline-image--resolve-imgur-image))
  "Alist maping a regular expressions to a resolver.

Resolver should be a function mapping the input URL to an URL
pointing to an image resource (presumably related to the input
URL).

This is used in `org-inline-image-regexp-resolver'."
  :type '(alist
          :key-type regexp
          :value-type function)
  :group 'org-inline-image)

(defvar org-inline-image-keymap
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "a") 'org-inline-image-animate)
    (define-key map (kbd "h") 'org-inline-image-hide)
    map)
  "Keymap active when point is on the image.")

(defun org-inline-image--regexp-resolver (input)
  "Resolve the URL by regexp.

Map the INPUT URL to an image resource associated with this URL.

This function uses the `org-inline-image-regexp-resolver-alist'
to convert INPUTs to outputs."
  (let ((resolvers org-inline-image-regexp-resolver-alist))
    (while (and (caar resolvers)
              (not (string-match-p
                  (caar resolvers)
                  input)))
      (pop resolvers))
    (when resolvers
      (funcall (cdar resolvers) input))
    ))

(defun org-inline-image--resolve-deviantart-image (input)
  "Resolve deviantart.com/art/ URL."
  (let ((hexified (url-hexify-string input)))
    (save-match-data
      (with-current-buffer
          (url-retrieve-synchronously (concat "http://backend.deviantart.com/oembed?url=" hexified))
        (goto-char (point-min))
        (when (re-search-forward "\"url\":\"\\(.*?\\)\"")
          (match-string 1))))))

(defun org-inline-image--resolve-imgur-image (input)
  "Resolve imgur.com URL."
  (unless (string-match-p "gallery" input)
    (with-current-buffer (url-retrieve-synchronously input)
      (goto-char (point-min))
      (when (re-search-forward "<link rel=\"image_src\" href=\"\\(.*?\\)\"/>")
        (match-string 1)))))

(defun org-inline-image--create-root-maybe ()
  "Create root directory if it doesn't exist yet."
  (unless (file-exists-p org-inline-image-root)
    (make-directory org-inline-image-root t)))

(defun org-inline-image--get-image-props (file)
  "Return image properties for FILE."
  `(image :type ,(image-type file)
          :file ,file
          :relief 0
          :margin 0))

(defun org-inline-image--get-current-image ()
  "Return the overlay associated with the image under point."
  (car (--select (eq (overlay-get it 'type) 'oii) (overlays-at (point)))))

(defun org-inline-image--get (prop)
  "Return the value of property PROP for image under point."
  (overlay-get (org-inline-image--get-current-image) prop))

;; TODO: cache downloaded images?
;; TODO: add support for local images
;;;###autoload
(defun org-inline-image ()
  "Inline an image."
  (interactive)
  (org-inline-image--create-root-maybe)
  (-when-let (link-data (org-inline-image--get-link))
    (lexical-let* ((current-buf (current-buffer))
                   (link-data link-data)
                   (resolved-link (run-hook-with-args-until-success
                                   'org-inline-image-resolvers
                                   (plist-get link-data :link)))
                   (name (concat org-inline-image-root (f-filename resolved-link))))
      (deferred:$
        (deferred:url-retrieve resolved-link)
        (deferred:nextc it
          (lambda (buf)
            (with-current-buffer buf
              (progn
                (goto-char (point-min))
                (re-search-forward "^$" nil 'move)
                (delete-region (point-min) (+ (point) 1))
                (write-file name)))
            (kill-buffer buf)))
        (deferred:nextc it
          (lambda ()
            (let ((ov (make-overlay (plist-get link-data :beg) (plist-get link-data :end)))
                  (image-props (org-inline-image--get-image-props name)))
              (with-current-buffer current-buf 
                (progn
                  (overlay-put ov 'type 'oii)
                  (overlay-put ov 'display image-props)
                  (overlay-put ov 'face 'default)
                  (overlay-put ov 'original-file name)
                  (overlay-put ov 'keymap org-inline-image-keymap))
                (when (image-animated-p image-props)
                  (image-animate image-props)))
              ;; (goto-char (plist-get link-data :beg))
              ))))
      )))

;; TODO: make removing optional?
(defun org-inline-image-hide ()
  "Hide the inlined image at point.

The file is also removed from the filesystem.  Repeated inlining
will re-download the file."
  (interactive)
  (let ((ov (org-inline-image--get-current-image))
        (original-file (org-inline-image--get 'original-file)))
    (delete-overlay ov)
    (delete-file original-file)))

(defun org-inline-image-animate ()
  "Animate the image if it's possible."
  (interactive)
  (let ((image-props (org-inline-image--get 'display)))
    (when (image-animated-p image-props)
      (image-animate image-props))))

(defun org-inline-image--get-link ()
  "Get link at point."
  (let (beg end link)
    (cond
     ((org-in-regexp org-bracket-link-regexp)
      (setq beg (match-beginning 0))
      (setq end (match-end 0))
      (setq link (match-string 1)))
     ((org-in-regexp org-angle-link-re)
      (setq beg (match-beginning 0))
      (setq end (match-end 0))
      (setq link (match-string 1)))
     ((org-in-regexp org-plain-link-re)
      (setq beg (match-beginning 0))
      (setq end (match-end 0))
      (setq link (match-string 0))))
    (list :beg beg :end end :link (plist-get (get-text-property 1 'htmlize-link link) :uri))))

(defun org-display-inline-images (&optional include-linked refresh beg end)
  "Display inline images.

An inline image is a link which follows either of these
conventions:

  1. Its path is a file with an extension matching return value
     from `image-file-name-regexp' and it has no contents.

  2. Its description consists in a single link of the previous
     type.

  3. Its path is a http or https with an extension matching return
     value from `image-file-name-regexp' and it has no contents.

When optional argument INCLUDE-LINKED is non-nil, also links with
a text description part will be inlined.  This can be nice for
a quick look at those images, but it does not reflect what
exported files will look like.

When optional argument REFRESH is non-nil, refresh existing
images between BEG and END.  This will create new image displays
only if necessary.  BEG and END default to the buffer
boundaries."
  (interactive "P")
  (org-inline-image--create-root-maybe)
  (when (display-graphic-p)
    (unless refresh
      (org-remove-inline-images)
      (when (fboundp 'clear-image-cache) (clear-image-cache)))
    (org-with-wide-buffer
     (goto-char (or beg (point-min)))
     (let ((case-fold-search t)
	   (file-extension-re (image-file-name-regexp)))
       (while (re-search-forward "[][]\\[\\(?:\\|[./~]\\)" end t)
	 (let* ((link (save-match-data (org-element-context)))
                (link-type (org-element-property :type link)))
	   ;; Check if we're at an inline image.
	   (when (and (or (equal link-type "file")
                       (equal link-type "https")
                       (equal link-type "http"))
                    (or include-linked
                       (not (org-element-property :contents-begin link)))
                    (let ((parent (org-element-property :parent link)))
                      (or (not (eq (org-element-type parent) 'link))
                         (not (cdr (org-element-contents parent)))))
                    (org-string-match-p file-extension-re
                                        (org-element-property :path link)))
	     (if (equal link-type "file")
                 (let file (expand-file-name
                          (org-link-unescape
                           (org-element-property :path link)
                           (insert-inline-image file link))))
               (lexical-let* ((link link)
                              (resolved-link (run-hook-with-args-until-success
                                             'org-inline-image-resolvers
                                             (org-element-property :raw-link link)))
                             (file (concat
                                    org-inline-image-root
                                    (md5 resolved-link)))
                             (current-buf (current-buffer)))
                 (deferred:$
                   (deferred:url-retrieve resolved-link)
                   (deferred:nextc it
                     (lambda (buf)
                       (with-current-buffer buf
                         (progn
                           (goto-char (point-min))
                           (re-search-forward "^$" nil 'move)
                           (delete-region (point-min) (+ (point) 1))
                           (write-file file)))
                       (kill-buffer buf)))
                   (deferred:nextc it
                     (lambda ()
                       (with-current-buffer current-buf
                         (insert-inline-image file link)))))
                 (message "Done deferred"))
               )
             )))))))

(defun insert-inline-image (file link)
  (when (file-exists-p file)
    (let ((width
           ;; Apply `org-image-actual-width' specifications.
           (cond
            ((not (image-type-available-p 'imagemagick)) nil)
            ((eq org-image-actual-width t) nil)
            ((listp org-image-actual-width)
             (or
              ;; First try to find a width among
              ;; attributes associated to the paragraph
              ;; containing link.
              (let ((paragraph
                     (let ((e link))
                       (while (and (setq e (org-element-property
                                          :parent e))
                                 (not (eq (org-element-type e)
                                        'paragraph))))
                       e)))
                (when paragraph
                  (save-excursion
                    (goto-char (org-element-property :begin paragraph))
                    (when
                        (re-search-forward
                         "^[ \t]*#\\+attr_.*?: +.*?:width +\\(\\S-+\\)"
                         (org-element-property
                          :post-affiliated paragraph)
                         t)
                      (string-to-number (match-string 1))))))
              ;; Otherwise, fall-back to provided number.
              (car org-image-actual-width)))
            ((numberp org-image-actual-width)
             org-image-actual-width)))
          (old (get-char-property-and-overlay
                (org-element-property :begin link)
                'org-image-overlay)))
      (if (and (car-safe old) refresh)
          (image-refresh (overlay-get (cdr old) 'display))
        (let ((image (create-image file
                                   (and width 'imagemagick)
                                   nil
                                   :width width)))
          (when image
            (let* ((link
                    ;; If inline image is the description
                    ;; of another link, be sure to
                    ;; consider the latter as the one to
                    ;; apply the overlay on.
                    (let ((parent
                           (org-element-property :parent link)))
                      (if (eq (org-element-type parent) 'link)
                          parent
                        link)))
                   (ov (make-overlay
                        (org-element-property :begin link)
                        (progn
                          (goto-char
                           (org-element-property :end link))
                          (skip-chars-backward " \t")
                          (point)))))
              (overlay-put ov 'display image)
              (overlay-put ov 'face 'default)
              (overlay-put ov 'org-image-overlay t)
              (overlay-put
               ov 'modification-hooks
               (list 'org-display-inline-remove-overlay))
              (push ov org-inline-image-overlays))))))))
(provide 'org-inline-image)


;;; org-inline-image.el ends here
