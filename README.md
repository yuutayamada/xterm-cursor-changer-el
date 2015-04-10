# Xterm Cursor Changer
This is a tiny Emacs Lisp package to change cursor figure on xterm for Emacs.

## Configuration

If you are using evil package, put below setting to your .emacs

```lisp
(require 'xterm-cursor-changer)
(defadvice evil-set-cursor (around xcc-evil-change-cursor activate)
  (if (xcc-xterm-p)
      (xcc-change-cursor-color-and-shape-on-evil)
    ad-do-it))
```

Or you can configure yourself

```lisp
(if (your-condition)
  (xcc-change-cursor-color-and-shape "red" 'box))
```

## Note

If you are using Tmux, you may need below configuration on your .tmux.conf.
See also https://www.mail-archive.com/tmux-users@lists.sourceforge.net/msg03044.html

```conf
setw -ga terminal-overrides ',*:Cc=\E[?120;%p1%s;240c:Cr=\E[?120;0;240c:civis=\E[?25l:cnorm=\E[?25h:cvvis=\E[?25h,'
```
