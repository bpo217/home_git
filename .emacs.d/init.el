;; global variables
(setq
 inhibit-startup-screen t ;;I know how to use emacs
 create-lockfiles nil ;;I don't use this
 column-number-mode t ;;Set the columns
 line-number-mode t ;;Give me the line number xEmacs only
 scroll-error-top-bottom t ;;Don't ping me 
 show-paren-delay 0.5 ;;I don't know what this does
 use-package-always-ensure t
 make-backup-files nil
 split-height-threshold nil ;;the next two attempt to split vertically always instead of horizontally
 split-width-threshold 80
 tool-bar-mode 0) ;;No clickable toolbar, use hotkeys
(tool-bar-mode -1)
(global-linum-mode 1) ;;This may be the same as line-number-mode
(toggle-frame-maximized)
(desktop-save-mode 1)


;; sentence-end-double-space nil)  I like ending sentences with double spaces
;; Easy to remove them all with dired

;;Default font
(set-default-font "SF Mono 14")

;; buffer local variables
(setq-default
 indent-tabs-mode nil ;;No tab characters, just spaces
 tab-width 2
 c-basic-offset 2) ;;Not 100% what

;; modes
(electric-indent-mode 0) ;;emacs auto indent after you hit enter (I might like this)
;; enables with M-x

;; global keybindings
(global-unset-key (kbd "C-z"))

;; the package manager
(require 'package)
(setq
 package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                    ("org" . "http://orgmode.org/elpa/")
                    ("melpa" . "http://melpa.org/packages/")
                    ("melpa-stable" . "http://stable.melpa.org/packages/"))
 package-archive-priorities '(("melpa-stable" . 1)))

;; Package initialize
(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

;;Set the theme
(use-package "dracula-theme")
;;(load-theme 'dracula)

;;Scala mode
;;(use-package scala-mode
;;  :interpreter
;;  ("scala" . scala-mode))
(use-package nim-mode)
(use-package typescript-mode)
(use-package feature-mode)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("b46ee2c193e350d07529fcd50948ca54ad3b38446dcbd9b28d0378792db5c088" default)))
 '(package-selected-packages
   (quote
    (cargo nim-mode dracula-theme sass-mode use-package typescript-mode feature-mode)))
 '(typescript-indent-level 2))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
