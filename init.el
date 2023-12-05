(setq inhibit-startup-message t
      ispell-dictionary "en"
      display-line-numbers-type t
      sentence-end-double-space nil)

(tool-bar-mode -1)

(setq user-full-name "Nat Tuck"
      user-mail-address "nat@ferrus.net")

(setq-default cursor-in-non-selected-windows nil)

(add-to-list 'auto-mode-alist '("\\.js\\'" . js-jsx-mode))

(setq js-indent-level 2)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4) 

; https://lists.gnu.org/archive/html/help-gnu-emacs/2011-04/msg00262.html
(add-hook 'java-mode-hook
          '(lambda ()
             "Treat Java 1.5 @-style annotations as comments."
             (setq c-comment-start-regexp 
                   "\\(@\\|/\\(/\\|[*][*]?\\)\\)")
             (modify-syntax-entry ?@ "< b"
                                  java-mode-syntax-table)
             (c-set-offset 'arglist-intro '+)))


(set-face-attribute 'default nil :font "Hack" :height 160 :weight 'regular)

(if (string-equal (system-name) "psyduck")
  (set-face-attribute 'default nil :font "Hack" :height 140 :weight 'regular))

;(setq backup-directory-alist `(("." . "~/.cache/emacs/backups")))
;(setq auto-save-file-name-transforms `(("." "~/.cache/emacs/autosaves/" t)))

(setq create-lockfiles nil)

(setq projectile-indexing-method 'hybrid)

;; bootstrap straight.el
(setq straight-use-package-by-default t)
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq use-package-always-ensure t)

(use-package mmm-mode)

(require 'mmm-auto)
(setq mmm-global-mode 'maybe)
(mmm-add-classes
 '((java-text-block
    :submode fundamental-mode
    :front ".+\"\"\"$"
    :back ".*\"\"\".*"
    :face mmm-code-submode-face
    )))
(mmm-add-mode-ext-class 'java-mode "\\.java$" 'java-text-block)



(use-package no-littering
  :config
  (no-littering-theme-backups))

;; https://github.com/hlissner/doom-emacs/blob/master/modules/config/default/config.el#L6
(defvar default-minibuffer-maps
  (append '(minibuffer-local-map
            minibuffer-local-ns-map
            minibuffer-local-completion-map
            minibuffer-local-must-match-map
            minibuffer-local-isearch-map
            read-expression-map))
  "A list of all the keymaps used for the minibuffer.")

(defun open-scratch-buffer ()
  "Open *scratch* buffer."
  (interactive)
  (switch-to-buffer "*scratch*"))

(defun open-init-file ()
  "Open the init file."
  (interactive)
  (find-file user-init-file))

(defun reload-init-file ()
  "Reload `init.el' without closing Emacs."
  (interactive)
  (load-file user-init-file))

;; based on http://emacsredux.com/blog/2013/04/03/delete-file-and-buffer/
(defun delete-file-and-buffer ()
  "Kill the current buffer and deletes the file it is visiting."
  (interactive)
  (let ((filename (buffer-file-name)))
    (if filename
        (if (y-or-n-p (concat "Do you really want to delete file " filename " ?"))
            (progn
              (delete-file filename)
              (message "Deleted file %s." filename)
              (kill-buffer)))
      (message "Not a file visiting buffer!"))))

;; https://kundeveloper.com/blog/buffer-files/
(defun fdx/rename-current-buffer-file ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let ((name (buffer-name))
	(filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
	(error "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (read-file-name "New name: " filename)))
	(if (get-buffer new-name)
	    (error "A buffer named '%s' already exists!" new-name)
	  (rename-file filename new-name 1)
	  (rename-buffer new-name)
	  (set-visited-file-name new-name)
	  (set-buffer-modified-p nil)
	  (message "File '%s' successfully renamed to '%s'"
		   name (file-name-nondirectory new-name)))))))

(use-package general
  :config
  (general-evil-setup t)
  (defconst my-leader "SPC")
  (general-create-definer my-leader-def
    :prefix my-leader)

  (my-leader-def
    :states '(motion normal visual)
    :keymaps 'override ;; https://github.com/noctuid/general.el/issues/99#issuecomment-360914335

    "u" '(universal-argument :which-key "Universal argument")
    ";" '(eval-region :which-key "eval-region")
    ;"SPC" '(projectile-find-file :which-key "Projectile find file")
    "x" '(open-scratch-buffer :which-key "Open scratch buffer")

    ;; Editor?
    "e" '(:ignore t :which-key "Editor")
    "eu" '(vundo :which-key "vundo")
    "ev" '(vundo :which-key "vundo")
    "er" '(query-replace :which-key "query-replace")

    ;; Buffers
    "b" '(:ignore t :which-key "Buffer")
    "bb" '(consult-buffer :which-key "consult-buffer")
    "b[" '(previous-buffer :which-key "Previous buffer")
    "bp" '(previous-buffer :which-key "Previous buffer")
    "b]" '(next-buffer :which-key "Next buffer")
    "bn" '(next-buffer :which-key "Next buffer")
    "bd" '(kill-current-buffer :which-key "Kill buffer")
    "bk" '(kill-current-buffer :which-key "Kill buffer")
    "bl" '(evil-switch-to-windows-last-buffer :which-key "Switch to last buffer")
    ;"bb" '(evil-switch-to-windows-last-buffer :which-key "Switch to last buffer")
    "br" '(revert-buffer-no-confirm :which-key "Revert buffer")

    ;; config
    "c" '(:ignore t :which-key "Config")
    "co" '(open-init-file :which-key "Open init.el")
    "cr" '(reload-init-file :which-key "Reload init.el")

    ;; file
    "f" '(:ignore t :which-key "File")
    "fD" '(delete-file-and-buffer :which-key "Delete file and close buffer")
    "fr" '(fdx/rename-current-buffer-file :which-key "Rename current file")

    ;; project
    "p" '(:ignore t :which-key "Project")
    "pp" '(projectile-switch-project :which-key "Switch Project")
    "pb" '(projectile-switch-to-buffer :which-key "Switch project buffer")
    "po" '(projectile-find-other-file :which-key "projectile-find-other-file")
    "pi" '(projectile-invalidate-cache :which-key "projectile-invalidate-cache")
    "pf" '(projectile-find-file :which-key "Projectile find file")
    "pK" '(projectile-kill-buffers :which-key "Projectile kill buffers")

    ;; window
    "w" '(:ignore t :which-key "Window")
    "wm" '(delete-other-windows :which-key "Delete Other Windows"))

  (general-define-key
    :keymaps default-minibuffer-maps
    [escape] 'abort-recursive-edit ;; escape should always quit

    "C-a" 'move-beginning-of-line
    "C-e" 'move-end-of-line

    "C-w" 'backward-delete-word
    "C-v" 'yank)

  ;; insert mode hotkeys
  (general-define-key
    :states 'insert
    "C-SPC" 'completion-at-point ;; bring up corfu completion
    "C-v" 'yank ;; C-v should paste clipboard contents

    "C-<backspace>" 'my-backward-kill-word
    "M-<backspace>" 'my-backward-kill-line

    ;; some emacs editing hotkeys inside insert mode
    "C-a" 'evil-beginning-of-visual-line
    "C-e" 'evil-end-of-visual-line
    "C-n" 'evil-next-visual-line
    "C-p" 'evil-previous-visual-line
    "C-k" 'kill-whole-line)
  
  ; end of general keybinds
  )

(defun liu233w/ex-kill-buffer-and-close ()
  (interactive)
  (unless (char-equal (elt (buffer-name) 0) ?*)
    (kill-this-buffer)))

(defun liu233w/ex-save-kill-buffer-and-close ()
  (interactive)
  (save-buffer)
  (kill-this-buffer))

(use-package evil
  :init
  (setq evil-want-keybinding nil
	evil-undo-system 'undo-fu)

  ;:general
  ;('normal "Q" 'fill-paragraph)

  :config
  (setq-default evil-cross-lines t)

  ;(define-key evil-normal-state-map "Q" 'fill-paragraph)
  (evil-ex-define-cmd "q[uit]" 'liu233w/ex-kill-buffer-and-close)
  (evil-ex-define-cmd "wq" 'liu233w/ex-save-kill-buffer-and-close)
  (general-def 'normal "Q" 'fill-paragraph)

  (setq +default-want-RET-continue-comments nil)

  (evil-mode))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-goggles
  :after evil
  :init
  (setq evil-goggles-duration 0.1)
  ;; disable slow actions
  (setq evil-goggles-enable-change nil)
  (setq evil-goggles-enable-delete nil)
  :config
  (evil-goggles-mode))

(use-package undo-fu
  :after evil
  :config
  ;; increase history limits
  ;; https://github.com/emacsmirror/undo-fu#undo-limits
  (setq undo-limit 6710886400 ;; 64mb.
	undo-strong-limit 100663296 ;; 96mb.
	undo-outer-limit 1006632960) ;; 960mb.
  )

(use-package editorconfig
  :config
  (editorconfig-mode 1))

(use-package projectile
  :init
  ;; some configs that doom uses https://github.com/doomemacs/doomemacs/blob/bc32e2ec4c51c04da13db3523b19141bcb5883ba/core/core-projects.el#L29
  (setq projectile-auto-discover nil ;; too slow to discover projects automatically, use `projectile-discover-projects-in-search-path' instead
        projectile-enable-caching t  ;; big performance boost, especially for `projectile-find-file'
        projectile-globally-ignored-files '(".DS_Store" "TAGS")
        projectile-globally-ignored-file-suffixes '(".elc" ".pyc" ".o")
        projectile-project-search-path '("~/Code"))
  :config
  (projectile-mode +1))

(use-package doom-themes
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold nil    ; if nil, bold is universally disabled
        doom-themes-enable-italic nil) ; if nil, italics is universally disabled
  (load-theme 'doom-one t)

  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package markdown-mode
  ;:straight nil
  :config
  ;; syntax highlighting in code blocks
  (setq markdown-fontify-code-blocks-natively t))

(use-package which-key
    :init
    (setq which-key-sort-order #'which-key-key-order-alpha
        which-key-sort-uppercase-first nil
        which-key-add-column-padding 1
        which-key-max-display-columns nil
        which-key-min-display-lines 6
        which-key-side-window-slot -10)
    (which-key-mode))

(use-package vundo
  :config
  (setq vundo-compact-display t))

(use-package consult)

(use-package tab-bar
  :straight (:type built-in)
  :init
  ;; remember window configuration changes
  (tab-bar-history-mode 1)
  :custom
  ;; hide tab back/forward buttons for tab-bar-history-mode
  (tab-bar-format '(tab-bar-format-tabs tab-bar-separator tab-bar-format-add-tab))

  :config
  (setq tab-bar-show nil
        tab-bar-close-button-show nil
        tab-bar-new-button-show nil))

(use-package vertico
  :init
  (vertico-mode)
  ;; https://systemcrafters.cc/emacs-tips/streamline-completions-with-vertico/
  :general
  (:keymaps 'vertico-map
    "C-j" 'vertico-next
    "C-k" 'vertico-previous)
  :config
  (setq vertico-resize nil
        vertico-count 17
        ;; enable cycling for `vertico-next' and `vertico-previous'
        vertico-cycle t))

(use-package orderless
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(basic orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles basic partial-completion)))))

(use-package elixir-ts-mode)

(use-package kotlin-ts-mode)

;:(use-package tramp)




(server-start)

;; references
;; https://github.com/ZacJoffe/zemacs/blob/master/init.el
;; https://emacs-china.org/t/evil-q-kill-buffer/626/5
