;;; xterm-cursor-changer.el --- Change cursor color and shape on xterm -*- lexical-binding: t; -*-

;; Copyright (C) 2015-2016  Yuta Yamada

;; Author: Yuta Yamada <sleepboy.zzz@gmail.com>
;; URL: https://github.com/yuutayamada/xterm-cursor-changer-el
;; Version: 0.1.0
;; Package-Requires: ((emacs "25") (cl-lib "0.5"))
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; This package provides changing cursor color and shape on xterm.

;; If you are using evil package, put below setting to your .emacs
;; (require 'xterm-cursor-changer)
;; (defadvice evil-set-cursor (around xcc-evil-change-cursor activate)
;;   (if (xcc-xterm-p)
;;       (xcc-change-cursor-color-and-shape-on-evil)
;;     ad-do-it))

;; Or you can configure yourself
;; Note that you can only specify 'box, 'bar and 'hbar
;; (if (your-condition)
;;   (xcc-change-cursor-color-and-shape "red" 'box))

;; Note that if you are using Emacs on Tmux, you may need following
;; configuration on your .tmux.conf to fix escape problem on Tmux:
;; -----
;;   # see also https://www.mail-archive.com/tmux-users@lists.sourceforge.net/msg03044.html
;;   setw -ga terminal-overrides ',*:Cc=\E[?120;%p1%s;240c:Cr=\E[?120;0;240c:civis=\E[?25l:cnorm=\E[?25h:cvvis=\E[?25h,'
;; -----

;; Memo
;; https://github.com/sjl/vitality.vim/issues/8
;; http://www.cplusplus.com/forum/unices/36461/
;; http://superuser.com/questions/270214/how-can-i-change-the-colors-of-my-xterm-using-ansi-escape-sequences

;;; Code:

(require 'cl-lib)
(require 'subr-x) ; if-let

(defvar xcc-use-blink nil)
(defvar xcc-timer-delay 0.1 "Use this to prevent chattering.")
(defvar xcc-before-send-hook nil)
(defvar xcc-nocalled-hook nil)

;; Internal Variable
(defvar xcc-cursor-color-format "]12;%s")
(defvar xcc-timer nil "Xcc timer object.")

;;;###autoload
(defun xcc-change-cursor-color-and-shape (&optional color type)
  "Change cursor COLOR and TYPE.
The TYPE has to match to `cursor-type' variable and it only allow box,
  bar, and hbar, which can change cursor shape on xterm.  If you specify
other types, it will be ignored (i.e., 'hollow)."
  (if (xcc-xterm-p)
      (xcc-send-string color type)
    (run-hook-with-args 'xcc-nocalled-hook color type)))

;;;###autoload
(defun xcc-change-cursor-color-and-shape-on-evil ()
  "Change cursor color and shape on `evil-mode'.
Like `xcc-change-cursor-color-and-shape', but this function uses variable
that correspond to evil-XXX-state-cursor variables."
  (when (and (or (bound-and-true-p evil-local-mode)
                 (bound-and-true-p evil-mode)))
    (xcc-change-cursor-color-and-shape
     (car (xcc-evil-get-cursor-type))
     (cdr (xcc-evil-get-cursor-type)))))

;;;###autoload
(defun xcc-xterm-p ()
  "Check whether on xterm or not."
  (and (not (display-graphic-p))
       (or (getenv "COLORTERM")
           (getenv "XTERM_VERSION"))))

(defun xcc-send-string (color type)
  "Send terminal to apply cursor COLOR and TYPE of shape."
  (let ((c (format xcc-cursor-color-format color))
        (s (xcc-get-cursor-shape-format type)))
    ;; Prevent chattering
    (when xcc-timer (cancel-timer xcc-timer))
    (setq xcc-timer
          (run-with-timer xcc-timer-delay nil
                          `(lambda ()
                             (run-hook-with-args 'xcc-before-send-hook ,color ,s)
                             (send-string-to-terminal ,(concat c s))
                             (setq xcc-timer nil))))))

;; Memo
;; \e[1 q -- box with blink
;; \e[2 q -- box without blink
;; \e[3 q -- hbar(underline) with blink
;; \e[4 q -- hbar(underline) without blink
;; \e[5 q -- bar(vertical) line with blink
;; \e[6 q -- bar(vertical) line without blink
(defun xcc-get-cursor-shape-format (spec)
  "Extract adapt format from SPEC."
  (when spec
    (let* ((type (cl-typecase spec
                   (list (car spec))
                   (symbol spec)))
           (shape (cl-case type
                    (box  1)
                    (hbar 3)
                    (bar  5))))
      (when shape
        (format "\e[%d q" (if xcc-use-blink shape (1+ shape)))))))

(defun xcc-evil-get-cursor-type ()
  "Return cons sell of cursor color and type for setting of evil.el."
  (cl-loop with specs = (with-no-warnings (evil-state-property evil-state :cursor t))
           with color and type
           for spec in specs
           do (cl-typecase spec
                (function nil)
                (string (setq color spec))
                (list   (when (member (car spec) '(box hbar bar))
                          (setq type (car spec))))
                (symbol (when (member spec '(box hbar bar))
                          (setq type spec))))
           finally return (cons color type)))

(provide 'xterm-cursor-changer)
;;; xterm-cursor-changer.el ends here
