# XTerm Cursor Changer
This is a tiny Emacs Lisp package to change cursor figure of Emacs on XTerm or URxvt.

## Configuration

If you are using evil package, put below setting to your .emacs

```lisp
(require 'xterm-cursor-changer)
(advice-add 'evil-set-cursor :before
            (lambda (&rest _r) (xcc-change-cursor-color-and-shape-on-evil)))
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
