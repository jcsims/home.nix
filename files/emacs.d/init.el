;;; init.el --- user-init-file                    -*- lexical-binding: t -*-
;;; Early birds

;; Seed the PRNG anew, from the system's entropy pool
(random t)

(progn ;;     startup
  (defvar before-user-init-time (current-time)
    "Value of `current-time' when Emacs begins loading `user-init-file'.")
  (message "Loading Emacs...done (%.3fs)"
           (float-time (time-subtract before-user-init-time
                                      before-init-time)))
  (setq user-emacs-directory (file-name-directory user-init-file))
  (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
  (message "Loading %s..." user-init-file)
  (setq inhibit-startup-buffer-menu t)
  (setq inhibit-startup-screen t)
  (setq initial-buffer-choice t)
  (setq initial-scratch-message "")
  (setq ring-bell-function 'ignore)
  (when (fboundp 'scroll-bar-mode)
    (scroll-bar-mode 0))
  (when (fboundp 'tool-bar-mode)
    (tool-bar-mode 0))
  (menu-bar-mode 0)
  (when (file-exists-p custom-file)
    (load custom-file)))

(require 'package)
(add-to-list 'package-archives
               (cons "melpa" "https://melpa.org/packages/")
               t)

(eval-and-compile ;; `use-package'
  (unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))
  (require 'use-package)
  (setq use-package-verbose t
        use-package-always-ensure t))

(use-package dash
  :config (global-dash-fontify-mode))

(use-package server
  :ensure f
  :commands (server-running-p)
  :config (or (server-running-p) (server-mode)))

;; Font
(if (eq system-type 'gnu/linux)
    (set-frame-font "Hack Nerd Font 9")
  (set-frame-font "Hack Nerd Font 12"))

(use-package color-theme-sanityinc-tomorrow
  :config (load-theme 'sanityinc-tomorrow-eighties t))

(use-package smart-mode-line
  :custom (sml/theme 'automatic)
  :config
  (add-to-list 'sml/replacer-regexp-list '("^~/code/patch/" ":patch:") t)
  (add-to-list 'sml/replacer-regexp-list '("^~/.config/nixpgs/" ":home-manager:") t)
  (sml/setup))

(progn ;     startup
  (message "Loading early birds...done (%.3fs)"
           (float-time (time-subtract (current-time)
                                      before-user-init-time))))

;;; Long tail

(use-package anzu
  :disabled
  :config
  (global-anzu-mode)
  (global-set-key [remap query-replace-regexp] 'anzu-query-replace-regexp)
  (global-set-key [remap query-replace] 'anzu-query-replace))

(use-package atomic-chrome
  :if (display-graphic-p)
  :config
  (setq atomic-chrome-url-major-mode-alist
        '(("github\\.com" . gfm-mode)))
  (atomic-chrome-start-server))

(use-package auth-source
  :ensure f
  :custom (auth-sources '("~/.authinfo.gpg")))

(use-package autorevert
  :ensure f
  :config
  (setq global-auto-revert-non-file-buffers t ; Refresh dired buffers
        auto-revert-verbose nil)              ; but do it quietly
  ;; Auto-refresh buffers
  (global-auto-revert-mode))

(use-package cider
  :after (clojure-mode paredit)
  :bind (:map clojure-mode-map
	      ("C-c i" . cider-inspect-last-result)
	      ("M-s-." . cider-find-var))
  :custom
  (cider-save-file-on-load t)
  (cider-repl-use-pretty-printing t)
  (nrepl-use-ssh-fallback-for-remote-hosts t)
  (cider-auto-jump-to-error 'errors-only)
  ;; Remove 'deprecated since LSP does that as well
  (cider-font-lock-dynamically '(macro core))
  ;; Let LSP handle eldoc
  (cider-eldoc-display-for-symbol-at-point nil)
  (cider-use-xref nil)
  :config
  (add-hook 'clojure-mode-hook 'cider-mode)
  (add-hook 'cider-repl-mode-hook 'paredit-mode)
  (add-hook 'cider-repl-mode-hook 'cider-company-enable-fuzzy-completion)
  (add-hook 'cider-mode-hook 'cider-company-enable-fuzzy-completion)
  ;; kill REPL buffers for a project as well
  (add-to-list 'project-kill-buffer-conditions
	       '(derived-mode . cider-repl-mode)
	       t)
  (setq cider-repl-display-help-banner nil
	nrepl-log-messages nil
        cider-known-endpoints '(("patch" "localhost" "12345"))))

(use-package clojure-mode
  :after (paredit)
  :mode (("\\.edn\\'" . clojure-mode))
  :config (add-hook 'clojure-mode-hook 'paredit-mode))

(use-package company
  :config
  (setq company-idle-delay .3) ; decrease delay before autocompletion popup shows
  (setq company-echo-delay 0)  ; remove annoying blinking
  (global-company-mode))

(use-package company-quickhelp
  :config (company-quickhelp-mode))

;; TODO: Pull out this one function and its dependencies.
(use-package crux
  :bind (("C-a" . crux-move-beginning-of-line)))

(use-package diff-hl
  :config
  (setq diff-hl-draw-borders nil)
  (global-diff-hl-mode)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh t))

(use-package diff-mode
  :ensure f
  :defer t
  :config
  (when (>= emacs-major-version 27)
    (set-face-attribute 'diff-refine-changed nil :extend t)
    (set-face-attribute 'diff-refine-removed nil :extend t)
    (set-face-attribute 'diff-refine-added   nil :extend t)))

(use-package dired
  :ensure f
  :defer t
  :config (setq dired-listing-switches "-alh"))

(use-package display-line-numbers
  :ensure f
  :config
  (setq display-line-numbers-width-start t)
  (global-display-line-numbers-mode))

(use-package eglot
  :hook ((rust-mode
          clojure-mode
          python-mode
          sh-mode
          nix-mode)
         . eglot-ensure)
  :config (setq eglot-autoshutdown t
                eglot-confirm-server-initiated-edits nil
                read-process-output-max (* 1024 1024))
  :bind (:map eglot-mode-map
              ("C-M-." . xref-find-references)
              ("C-c l f" . eglot-format)
              ("C-c l a" . eglot-code-actions)))

(use-package eldoc
  :ensure f
  :when (version< "25" emacs-version)
  :config (global-eldoc-mode))

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x))
  :config (exec-path-from-shell-initialize))

(use-package files
  :ensure f
  :after (no-littering)
  :config
  (auto-save-visited-mode 1)
  (setq backup-directory-alist ; Save backups to a central location
        `(("." . ,(no-littering-expand-var-file-name "backup/")))
        auto-save-file-name-transforms
        `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))

(use-package flycheck
  :config (global-flycheck-mode)
  :bind (:map flycheck-mode-map
              ("M-n" . flycheck-next-error)
              ("M-p" . flycheck-previous-error))
  :custom (flycheck-global-modes '(not org-mode
                                       cider-repl-mode)))

(use-package flymake
  :bind (:map flymake-mode-map
              ("M-n" . flymake-goto-next-error)
              ("M-p" . flymake-goto-prev-error)))

(use-package flyspell
  :ensure f
  :config
  (add-hook 'text-mode-hook 'flyspell-mode)
  (add-hook 'prog-mode-hook 'flyspell-prog-mode)
  (setq ispell-program-name "aspell"))

(use-package forge
  :after (magit))

(use-package git-link)

(use-package git-timemachine)

(use-package help
  :ensure f
  :defer t
  :config (temp-buffer-resize-mode))

(use-package helpful
  :bind (("C-h f" . helpful-callable)
	 ("C-h v" . helpful-variable)
	 ("C-h k" . helpful-key)
	 :map emacs-lisp-mode-map
	 ("C-c C-d" . helpful-at-point)))

(use-package hippie-exp
  :ensure f
  :bind (([remap dabbrev-expand] . hippie-expand)))

(use-package hl-todo
  :config (global-hl-todo-mode))

(progn ;    `isearch'
  (setq isearch-allow-scroll t))

(use-package lisp-mode
  :ensure f
  :config
  (add-hook 'emacs-lisp-mode-hook 'outline-minor-mode)
  (add-hook 'emacs-lisp-mode-hook 'reveal-mode)
  (defun indent-spaces-mode ()
    (setq indent-tabs-mode nil))
  (add-hook 'lisp-interaction-mode-hook 'indent-spaces-mode))

(use-package magit
  :defer t
  :commands (magit-add-section-hook magit-get-current-branch)
  :bind (("C-c g"   . magit-status)
         ("C-c M-g" . magit-dispatch))
  :config
  (magit-add-section-hook 'magit-status-sections-hook
                          'magit-insert-modules
                          'magit-insert-stashes
                          'append)
  (defun jcs/magit-commit-template (&rest _)
    "Ensure that commits on an issue- branch have the issue name in
the commit as well."
    (let ((prefix (magit-get-current-branch)))
      (if (string-prefix-p "issue-" prefix)
          (let* ((issue-number (string-replace "issue-" "" prefix))
                 (issue-marker (concat "(#" issue-number ")")))
            (progn
              (goto-char (point-min))
              (if (not (search-forward issue-marker (line-end-position) t))
                  (progn
                    (goto-char (point-min))
                    (move-end-of-line nil)
                    (insert " " issue-marker)
                    (goto-char (point-min)))
                (goto-char (point-min))))))))
  (add-hook 'git-commit-mode-hook 'jcs/magit-commit-template)
  :custom
  (magit-branch-prefer-remote-upstream t)
  (magit-save-repository-buffers 'dontask))

(use-package man
  :defer t
  :config (setq Man-width 80))

(use-package marginalia
  :init (marginalia-mode))

(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :config (setq markdown-fontify-code-blocks-natively t))

(use-package minions
  :config
  (setq minions-prominent-modes '(eglot-mode
                                  flycheck-mode
                                  flymake-mode
                                  lsp-mode))
  (minions-mode))

(use-package multiple-cursors
  :bind
  (("C->"     . mc/mark-next-like-this)
   ("C-<"     . mc/mark-previous-like-this)
   ("C-c C->" . mc/mark-all-like-this)))

(use-package newcomment
  :ensure f
  :config (global-set-key [remap comment-dwim] #'comment-line))

(use-package nix-mode)

(use-package no-littering)

(use-package obsidian
  :demand t
  :after (dash elgrep s)
  :config
  (obsidian-specify-path "~/notes/patch")
  (global-obsidian-mode)

  (require 'dash)
  (require 's)
  (require 'seq)
  (defun jcs/open-todays-meeting ()
    "Open an Obsidian meeting note from today."
    (interactive)
    (let* ((today-string (format-time-string "%Y-%m-%d"))
	   (meeting-dir (expand-file-name "meetings" obsidian-directory))
	   (choices (->> (directory-files-recursively meeting-dir "\.*.md$")
			 (seq-filter #'obsidian-file-p)
			 (seq-map (lambda (f) (file-relative-name f meeting-dir)))
			 (seq-filter (lambda (f) (s-starts-with? today-string f))))))
      (if choices
	  (obsidian-find-file (expand-file-name (completing-read "Select file: " choices)
						meeting-dir))
	(message "No meeting files for today.")))))

(use-package orderless
  :init
  (setq completion-styles '(orderless)
	completion-category-defaults nil
	completion-category-overrides '((file (styles . (partial-completion))))))

(use-package paredit
  :hook (emacs-lisp-mode . paredit-mode)
  :bind (:map paredit-mode-map
              ("RET" . nil)))

(use-package paredit-everywhere
  :after (paredit)
  :hook (prog-mode . paredit-everywhere-mode))

(use-package paren
  :config (show-paren-mode))

;; TODO: Try out pixel-scroll-precision-mode

(use-package prog-mode
  :ensure f
  :config (global-prettify-symbols-mode)
  (defun indicate-buffer-boundaries-left ()
    (setq indicate-buffer-boundaries 'left))
  (defun esk-local-comment-auto-fill ()
    "Only auto-fill in comment strings, in prog-mode-derived buffers."
    (set (make-local-variable 'comment-auto-fill-only-comments) t)
    (auto-fill-mode t))
  (add-hook 'prog-mode-hook 'indicate-buffer-boundaries-left)
  (add-hook 'prog-mode-hook 'esk-local-comment-auto-fill))

(use-package recentf
  :ensure f
  :demand t
  :config (add-to-list 'recentf-exclude "^/\\(?:ssh\\|su\\|sudo\\)?x?:"))

(use-package savehist
  :ensure f
  :config (savehist-mode))

(use-package saveplace
  :ensure f
  :when (version< "25" emacs-version)
  :config (save-place-mode))

(use-package simple
  :ensure f
  :config (column-number-mode)
  :hook ((text-mode org-mode markdown-mode) . turn-on-auto-fill))

(use-package smerge-mode
  :ensure f
  :defer t
  :config
  (when (>= emacs-major-version 27)
    (set-face-attribute 'smerge-refined-removed nil :extend t)
    (set-face-attribute 'smerge-refined-added   nil :extend t)))

;; Recommended by magit in emacs < 29
(use-package sqlite3)

(use-package symbol-overlay
  :bind (:map mode-specific-map
              ("h h" . symbol-overlay-put)
              ("h r" . symbol-overlay-remove-all)
              ("h m" . symbol-overlay-mode)
              ("h n" . symbol-overlay-switch-forward)
              ("h p" . symbol-overlay-switch-backward)))

(progn ;    `text-mode'
  (add-hook 'text-mode-hook 'indicate-buffer-boundaries-left))

(use-package tramp
  :ensure f
  :defer t
  :config
  (add-to-list 'tramp-default-proxies-alist '(nil "\\`root\\'" "/ssh:%h:"))
  (add-to-list 'tramp-default-proxies-alist '("localhost" nil nil))
  (add-to-list 'tramp-default-proxies-alist
               (list (regexp-quote (system-name)) nil nil))
  (setq vc-ignore-dir-regexp
        (format "\\(%s\\)\\|\\(%s\\)"
                vc-ignore-dir-regexp
                tramp-file-name-regexp)))

(use-package tramp-sh
  :ensure f
  :defer t
  :config (cl-pushnew 'tramp-own-remote-path tramp-remote-path))

;; tree-sitter bindings
;; TODO: In Emacs 29+, use the built-in version instead.
(use-package tree-sitter
  :config
  (add-hook 'tree-sitter-after-on-hook 'tree-sitter-hl-mode)
  (global-tree-sitter-mode))

(use-package tree-sitter-langs)

(use-package vertico
  :init
  (vertico-mode)
  ;; Borrowed from https://github.com/daviwil/dotfiles/commit/58eff6723515e438443b9feb87735624acd23c73
  (defun jcs/minibuffer-backward-kill (arg)
    "When completing a filename in the minibuffer, kill according to path.
Passes ARG onto `zap-to-char` or `backward-kill-word` if used."
    (interactive "p")
    (if minibuffer-completing-file-name
        ;; Borrowed from https://github.com/raxod502/selectrum/issues/498#issuecomment-803283608
        (if (string-match-p "/." (minibuffer-contents))
            (zap-up-to-char (- arg) ?/)
          (delete-minibuffer-contents))
      (backward-kill-word arg)))
  :custom (vertico-cycle t)
  :bind (:map vertico-map
              ("M-<backspace>" . jcs/minibuffer-backward-kill)))

(use-package vc-hooks
  :ensure f
  ;; Follow links without asking
  :config (setq vc-follow-symlinks t))

(use-package vundo)

(use-package wgrep)

(use-package which-key
  :config (which-key-mode))

(use-package whitespace
  :ensure f
  :config
  (setq-default fill-column 80)
  (setq whitespace-style '(face empty trailing))
  (add-hook 'prog-mode-hook 'whitespace-mode)
  (add-hook 'text-mode-hook 'whitespace-mode))

(use-package windmove
  :ensure f
  :config (windmove-default-keybindings '(super meta)))

(use-package winner
  :ensure f
  :config (winner-mode))

(use-package xref
  :ensure f
  :custom (xref-search-program 'ripgrep))

(use-package yaml-mode
  :mode (("\\.yml\\'" . yaml-mode)))

;;; Tequila worms

(progn ;     startup
  (message "Loading %s...done (%.3fs)" user-init-file
           (float-time (time-subtract (current-time)
                                      before-user-init-time)))
  (add-hook 'after-init-hook
            (lambda ()
              (message
               "Loading %s...done (%.3fs) [after-init]" user-init-file
               (float-time (time-subtract (current-time)
                                          before-user-init-time))))
            t))


(progn ;     personalize

  (setq sentence-end-double-space nil ;; Sentences can end with a single space.
        select-enable-primary t ;; Use the clipboard for yank and kill
        save-interprogram-paste-before-kill t
        scroll-preserve-screen-position 'always
        scroll-error-top-bottom t               ; Scroll similar to vim
        user-full-name "Chris Sims"
        user-mail-address "chris@jcsi.ms"
        use-short-answers t)

  ;; Always use UTF-8
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)
  (set-default-coding-systems 'utf-8)
  (prefer-coding-system 'utf-8)
  (set-language-environment 'utf-8)
  (setq locale-coding-system 'utf-8)
  (set-selection-coding-system 'utf-8)

  ;; Get rid of the insert key. I never use it, and I turn it on
  ;; accidentally all the time
  (global-set-key (kbd "<insert>") nil)

  (defun find-nix-file (filepath)
    "Find the FILEPATH under ~/.config/nixpkgs."
    (interactive)
    (find-file (expand-file-name filepath "~/.config/nixpkgs/")))

  ;; Some helpful accessors for commonly-found files.
  (global-set-key (kbd "C-c e e") (lambda () (interactive) (find-nix-file "files/emacs.d/init.el")))
  (global-set-key (kbd "C-c e f") (lambda () (interactive) (find-nix-file "flake.nix")))
  (global-set-key (kbd "C-c e b") (lambda () (interactive) (find-nix-file "base.nix")))

  ;; Taken from the Emacs Wiki: http://www.emacswiki.org/emacs/InsertDate
  (progn
    (defun insert-date (prefix)
      "Insert the current date. With PREFIX, use ISO format."
      (interactive "P")
      (let ((format (cond
                     ((not prefix) "%a %d %b %Y")
                     ((equal prefix '(4)) "%Y-%m-%d"))))
        (insert (format-time-string format))))
    (global-set-key (kbd "C-c d") 'insert-date))

  ;; Taken from http://whattheemacsd.com/editing-defuns.el-01.html
  (progn
    (defun open-line-below ()
      "Anywhere on the line, open a new line below current line."
      (interactive)
      (end-of-line)
      (newline)
      (indent-for-tab-command))

    (defun open-line-above ()
      "Anywhere on the line, open a new line above current line."
      (interactive)
      (beginning-of-line)
      (newline)
      (forward-line -1)
      (indent-for-tab-command))

    (global-set-key (kbd "<C-return>") 'open-line-below)
    (global-set-key (kbd "<C-S-return>") 'open-line-above))

  (progn
    (defvar jcs/tab-sensitive-modes '(makefile-bsdmake-mode))
    (defvar jcs/indent-sensitive-modes '(conf-mode
                                         python-mode
                                         slim-mode
                                         yaml-mode))

    ;; Slightly  modified from crux's version
    (defun cleanup-buffer ()
      "Cleanup the buffer, including whitespace and indentation."
      (interactive)
      (unless (member major-mode jcs/indent-sensitive-modes)
        (indent-region (point-min) (point-max)))
      (unless (member major-mode jcs/tab-sensitive-modes)
        (untabify (point-min) (point-max)))
      (whitespace-cleanup))
    (global-set-key (kbd "C-c n") 'cleanup-buffer))


  (let ((file (expand-file-name (concat (user-real-login-name) ".el")
                                user-emacs-directory)))
    (when (file-exists-p file)
      (load file))))

;; Local Variables:
;; indent-tabs-mode: nil
;; End:
;;; init.el ends here
