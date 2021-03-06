;;; flycheck-nimsuggest.el --- Yet another flycheck plugin for Nim language -*- lexical-binding: t; -*-

;; Copyright (C) 2016 by Yuta Yamada

;; Author: Yuta Yamada <cokesboy"at"gmail.com>

;;; License:
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; On the fly syntax check support using Nimsuggest and flycheck.el.
;; You could find another flycheck backend for Nim at https://github.com/ALSchwalm/flycheck-nim
;; which use `nim check` command.

;; Because of introducing new flymake (https://lists.gnu.org/archive/html/emacs-devel/2017-09/msg00953.html)
;; from Emacs 26, this package might be moved to other repository on the future.
;; (for less dependencies)

;; Manual setup:
;;     ;; write below configuration in your init file.
;;     (add-hook 'nimsuggest-mode-hook 'flycheck-nimsuggest-setup)

;; TODO: move this package to MELPA

;;; Code:

(require 'flycheck)
(require 'cl-lib)

;;;###autoload
(add-hook 'nimsuggest-mode-hook 'flycheck-nimsuggest-setup)

(defvar nim-use-flycheck-nimsuggest t
  "Set nil if you really don’t want to use flycheck-nimsuggest.
Mainly this variable is debug purpose.")

(autoload 'nimsuggest--call-epc "nim-suggest")
(autoload 'nimsuggest-available-p "nim-suggest")

(defvar flycheck-nimsuggest-error-parser 'flycheck-nimsuggest-error-parser
  "Error parser that parse nimsuggest's erorrs.
You may use `flycheck-parse-with-patterns' symbol if you use old nimsuggest.")

(defvar flycheck-nimsuggest-patterns
  (mapcar (lambda (p)
            (cons (flycheck-rx-to-string `(and ,@(cdr p)) 'no-group)
                  (car p)))
         `((error line-start (file-name) "(" line ", " column ") "
           "Error:"
           (message (one-or-more not-newline)
                    (optional
                     (and "\nbut expected one of:"
                          (minimal-match (one-or-more anything))
                          "\n\n"))))
           (warning line-start (file-name) "(" line ", " column ") "
                    (or "Hint:" "Warning:") (message) line-end))))
(put 'nim-nimsuggest 'flycheck-error-patterns flycheck-nimsuggest-patterns)

;;;###autoload
(defun flycheck-nim-nimsuggest-start (checker callback)
  "Start nimsuggest’s ‘chk’ method syntax check with CHECKER.

CALLBACK is the status callback passed by Flycheck."
  ;; The syntax checker being run, just in case the :start function is
  ;; being shared among different syntax checkers.
  ;; A callback function, which shall be used to report the results of a
  ;; syntax check back to Flycheck.
  (let ((buffer (current-buffer)))
    (nimsuggest--call-epc
     'chk
     (lambda (errors)
       (condition-case err
           (let ((res
                  (funcall flycheck-nimsuggest-error-parser errors checker buffer)))
             (funcall callback 'finished (delq nil res)))
         ;; TODO: add proper error handler
         (error (funcall callback 'errored err)))))))

(defun flycheck-nimsuggest-error-parser (errors checker buffer)
  "Return list of `flycheck-error` struct from ERRORS.
CHECKER and BUFFER are passed to flycheck's function."
  (cl-loop for (_ _ _ file lvl line col msg _) in errors
           ;; column starts from 1 on nimsuggest, but emacs is 0
           for column = (1+ col)
           for level  = (cl-case (string-to-char lvl)
                          (?E 'error)
                          (?w 'warning)
                          (t  'info)) ; for Hint
           collect (flycheck-error-new-at
                    line column level msg
                    :checker checker :buffer buffer :filename file)))

;;;###autoload
(defun flycheck-nimsuggest-setup ()
  "Setup flycheck configuration for nimsuggest."
  (when (and (bound-and-true-p nim-use-flycheck-nimsuggest)
             (not (bound-and-true-p flymake-mode))
             (funcall 'nimsuggest-available-p)
             (not flycheck-checker))
    (flycheck-select-checker 'nim-nimsuggest)))

;;;###autoload
(eval-after-load "flycheck"
  '(progn
     (flycheck-define-generic-checker 'nim-nimsuggest
       "A syntax checker for Nim lang using nimsuggest.

See URL `https://github.com/nim-lang/nimsuggest'."
       :start 'flycheck-nim-nimsuggest-start
       :modes '(nim-mode nimscript-mode)
       :predicate (lambda () (and
                         (bound-and-true-p nim-use-flycheck-nimsuggest)
                         (nimsuggest-available-p))))

     (add-to-list 'flycheck-checkers 'nim-nimsuggest)))

(provide 'flycheck-nimsuggest)

;; Local Variables:
;; coding: utf-8
;; mode: emacs-lisp
;; End:

;;; flycheck-nimsuggest.el ends here
