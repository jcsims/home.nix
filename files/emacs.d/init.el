;;; init --- configuration starting point -*- no-byte-compile: t -*-

;;; Commentary:
;; Most of what is found in these files has been pulled from the
;; dotfiles of others.  Take what you want, but be prepared to
;; troubleshoot yourself!

;;; Code:

;; Seed the PRNG anew, from the system's entropy pool
(random t)

(require 'package)
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
	("nongnu" . "https://elpa.nongnu.org/nongnu/")
	("melpa" . "https://melpa.org/packages/")))
(package-initialize)

;; Setup use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))
(setq use-package-always-ensure t
      use-package-compute-statistics t
      use-package-verbose t)
(use-package bind-key)

(use-package custom
  :ensure f
  :config
  (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
  (when (file-exists-p custom-file)
    (load custom-file)))

;; (use-package init-packages
;;   :ensure f
;;   :load-path "lisp")

;; Some combination of GNU TLS and Emacs fail to retrieve archive
;; contents over https.
;; https://www.reddit.com/r/emacs/comments/cdei4p/failed_to_download_gnu_archive_bad_request/etw48ux
;; https://debbugs.gnu.org/cgi/bugreport.cgi?bug=34341
(if (and (version< emacs-version "28.3") (>= libgnutls-version 30600))
    (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3"))

;; TODO: fix me
(setq source-directory (concat "~/code/emacs-" emacs-version))

;; Sentences can end with a single space.
(setq sentence-end-double-space nil)

(use-package no-littering
  :config
  (require 'files)
  (setq auto-save-file-name-transforms
	`((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))

(use-package auth-source
  :ensure f
  :custom (auth-sources '("~/.authinfo.gpg")))

;;; Misc settings
(setq inhibit-splash-screen t		; Don't show the splash screen
      ring-bell-function 'ignore	; Just ignore error notifications
      indent-tabs-mode nil		; Don't use tabs unless buffer-local
      select-enable-primary t
      save-interprogram-paste-before-kill t
      mouse-yank-at-point t
      ;; When scrolling, make sure to come back to the same spot
      scroll-preserve-screen-position 'always
      scroll-error-top-bottom t		; Scroll similar to vim
      )

;;; Personal info
(setq user-full-name "Chris Sims"
      user-mail-address "chris@jcsi.ms")

;; Always use UTF-8
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(prefer-coding-system 'utf-8)
(set-language-environment 'utf-8)
(setq locale-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)

;; Blank scratch buffer
(setq initial-scratch-message nil)

;; y/n keypresses instead of typing out yes or no
(setq use-short-answers t)

(put 'erase-buffer 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)

;; Get rid of the insert key. I never use it, and I turn it on
;; accidentally all the time
(global-set-key (kbd "<insert>") nil)

(setq isearch-allow-scroll t)
(global-set-key (kbd "C-S") 'isearch-forward-regexp)
(global-set-key (kbd "C-R") 'isearch-backward-regexp)
;; (global-set-key (kbd "C-M-s") 'isearch-forward)
;; (global-set-key (kbd "C-M-r") 'isearch-backward)

;; Turn off the toolbar, menu bar, and scroll bar
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(when (fboundp 'menu-bar-mode)
  (menu-bar-mode -1))

;; Font
(if (eq system-type 'gnu/linux)
    ;; provided in the AUR by `nerd-font-hack`
    (set-frame-font "Hack Nerd Font 9")
  (set-frame-font "Hack Nerd Font 12"))

;;; Themes
(use-package color-theme-sanityinc-tomorrow
  :config (load-theme 'sanityinc-tomorrow-eighties t))

(use-package smart-mode-line
  :custom (sml/theme 'automatic)
  :config (sml/setup))

;; Allow for seamless gpg interaction
(use-package epa-file
  :ensure f
  :config (epa-file-enable))

(use-package windmove
  :config (windmove-default-keybindings '(super meta)))

(use-package restclient)

;; Use es-mode for ElasticSearch buffers
(use-package es-mode)

(use-package autorevert
  :ensure f
  :config
  (setq global-auto-revert-non-file-buffers t ; Refresh dired buffers
	auto-revert-verbose nil)              ; but do it quietly
  ;; Auto-refresh buffers
  (global-auto-revert-mode))

(use-package dired
  :ensure f
  :config (setq dired-listing-switches "-alhv")
  :custom (dired-kill-when-opening-new-dired-buffer t))

(use-package saveplace
  :ensure f
  :when (version< "25" emacs-version)
  :config (save-place-mode t))

;;; Packages
(use-package vc-hooks
  :ensure f
  :config (setq vc-follow-symlinks t ; even when they're in version control
		))

(use-package recentf
  :ensure f
  :config
  (recentf-mode 1)
  (add-to-list 'recentf-exclude "^/\\(?:ssh\\|su\\|sudo\\)?:")
  (add-to-list 'recentf-exclude no-littering-var-directory)
  (add-to-list 'recentf-exclude no-littering-etc-directory))

(use-package files
  :ensure f
  :config
  (auto-save-visited-mode 1)
  (setq backup-directory-alist ; Save backups to a central location
	`(("." . ,(no-littering-expand-var-file-name "backup/")))
	auto-save-file-name-transforms
	`((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))

;; Handles ssh-agent and gpg-agent configuration from `keychain`
(use-package keychain-environment
  :if (eq system-type 'gnu/linux)
  :config (keychain-refresh-environment))

;; Used for async package updating in paradox
(use-package async)
(use-package paradox
  :after (auth-source epa-file epg exec-path-from-shell)
  :commands (paradox-list-packages)
  :config
  (setq paradox-execute-asynchronously t
	paradox-github-token (cadr (auth-source-user-and-password
				    "api.github.com" "jcsims^paradox")))
  (paradox-enable))

(use-package macrostep
  :bind ("C-c m" . macrostep-expand))

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x))
  :config (exec-path-from-shell-initialize))

(use-package re-builder
  :ensure f
  :bind (("C-c R" . re-builder))
  :config (setq reb-re-syntax 'string))

;; External user config
(use-package init-funcs
  :demand
  :ensure f
  :bind (("C-c C-f" . goto-next-file)
	 ("C-c f" . goto-next-file)
	 ("C-c n". cleanup-buffer))
  :load-path "lisp")

(use-package whitespace
  :config
  (setq-default fill-column 80)
  (setq whitespace-style '(face empty trailing))
  :hook
  (prog-mode . whitespace-mode)
  (text-mode . whitespace-mode))

(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
	 ("\\.md\\'" . markdown-mode)
	 ("\\.markdown\\'" . markdown-mode))
  :config (setq markdown-fontify-code-blocks-natively t))

(use-package minions
  :config
  (setq minions-prominent-modes '(flycheck-mode
				  vlf-mode
				  lsp-mode
				  whitespace-cleanup-mode))
  (minions-mode))

(defun find-nix-file (filepath)
  "Find the FILEPATH under ~/.config/nixpkgs."
  (interactive)
  (find-file (expand-file-name filepath "~/.config/nixpkgs/")))

(use-package simple
  :ensure f
  :after org
  :hook (org-mode . visual-line-mode)
  :config
  (column-number-mode)
  (setq-default what-cursor-show-names t)
  :bind
  ("M-SPC" . cycle-spacing)
  ("C-c e e" . (lambda () (interactive) (find-nix-file "files/emacs.d/init.el")))
  ("C-c e h" . (lambda () (interactive) (find-nix-file "home.nix")))
  ("C-c e w" . (lambda () (interactive) (find-nix-file "work.nix")))
  :hook ((text-mode org-mode markdown-mode) . turn-on-auto-fill))

(use-package tramp
  :ensure f
  :defer t
  :config
  (add-to-list 'tramp-default-proxies-alist '(nil "\\`root\\'" "/ssh:%h:"))
  (add-to-list 'tramp-default-proxies-alist '("localhost" nil nil))
  (add-to-list 'tramp-default-proxies-alist
	       (list (regexp-quote (system-name)) nil nil)))

;; Ensure that when we go to a new line, it's indented properly
(use-package electric
  :config (electric-indent-mode))

;; Ensure that a server is running for quicker start times
(use-package server
  :if (display-graphic-p)
  :config (unless (server-running-p)
	    (server-start)))

(use-package atomic-chrome
  :if (display-graphic-p)
  :config
  (setq atomic-chrome-url-major-mode-alist
	'(("github\\.com" . gfm-mode)
	  ("github\\.threatbuild\\.com" . gfm-mode)))
  (atomic-chrome-start-server))

;; Work-specific code - should be encrypted!
(defvar work-init (concat user-emacs-directory "lisp/init-work.el.gpg"))
(if (file-exists-p work-init)
    (load work-init))

;; Flyspell mode
(use-package flyspell
  :hook ((text-mode . flyspell-mode)
	 (prog-mode . flyspell-prog-mode)))

(use-package company
  :config
  (setq company-idle-delay .3)                          ; decrease delay before autocompletion popup shows
  (setq company-echo-delay 0)                           ; remove annoying blinking
  (global-company-mode))

(use-package company-quickhelp
  :config (company-quickhelp-mode))

(use-package elisp-slime-nav
  :config
  ;; Enable M-. and M-, along with C-c C-d {c,C-d} for elisp
  :hook ((emacs-lisp-mode ielm-mode) . elisp-slime-nav-mode))

(use-package symbol-overlay
  :bind (:map mode-specific-map
	      ("h h" . symbol-overlay-put)
	      ("h r" . symbol-overlay-remove-all)
	      ("h m" . symbol-overlay-mode)
	      ("h n" . symbol-overlay-switch-forward)
	      ("h p" . symbol-overlay-switch-backward)))

(use-package flycheck
  :config (global-flycheck-mode)
  :bind (:map flycheck-mode-map
	      ("M-n" . flycheck-next-error)
	      ("M-p" . flycheck-previous-error))
  :custom (flycheck-global-modes '(not org-mode
				       cider-repl-mode)))

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

(use-package vertico
  ;; :disabled
  :init (vertico-mode)
  :custom (vertico-cycle t)
  :bind (:map vertico-map
	      ("M-<backspace>" . jcs/minibuffer-backward-kill)))

(use-package orderless
  :init
  (setq completion-styles '(orderless)
	completion-category-defaults nil
	completion-category-overrides '((file (styles . (partial-completion))))))

(use-package consult
  :demand ;; never want to lazy-load this package
  :bind (("M-y" . consult-yank-from-kill-ring)
	 ([remap isearch-forward-regexp] . consult-line)))

(use-package marginalia
  :init (marginalia-mode))

(use-package magit
  :demand t
  :bind (("C-c g"   . magit-status)
	 ("C-c M-g" . magit-dispatch))
  :custom
  (magit-branch-prefer-remote-upstream t)
  (magit-branch-adjust-remote-upstream-alist '(("upstream/master" . "issue-")))
  (magit-save-repository-buffers 'dontask)
  :config
  (magit-add-section-hook 'magit-status-sections-hook
			  'magit-insert-modules
			  'magit-insert-stashes
			  'append))

(use-package git-modes)

(use-package git-timemachine)

(use-package paredit
  :hook (emacs-lisp-mode . paredit-mode))

(use-package paredit-everywhere
  :hook (prog-mode . paredit-everywhere-mode))

(use-package expand-region
  :bind ("C-=" . er/expand-region))

(use-package dockerfile-mode
  :mode "Dockerfile")

(use-package yaml-mode
  :mode (("\\.yml\\'" . yaml-mode)
	 ("\\.sls\\'" . yaml-mode)))

(use-package which-key
  :config (which-key-mode))

;; Some keybinds for this mode:
;; `diff-hl-diff-goto-hunk'  C-x v =
;; `diff-hl-revert-hunk'     C-x v n
;; `diff-hl-previous-hunk'   C-x v [
;; `diff-hl-next-hunk'       C-x v ]
(use-package diff-hl
  :config
  ;;(setq diff-hl-draw-borders nil)
  (global-diff-hl-mode)
  (diff-hl-dired-mode)
  (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh))

(use-package anzu
  :config
  (global-anzu-mode)
  (global-set-key [remap query-replace-regexp] 'anzu-query-replace-regexp)
  (global-set-key [remap query-replace] 'anzu-query-replace))

(use-package display-line-numbers
  :ensure f
  :config
  (setq display-line-numbers-width-start t)
  (global-display-line-numbers-mode))

(use-package multiple-cursors
  :bind
  (("C->"     . mc/mark-next-like-this)
   ("C-<"     . mc/mark-previous-like-this)
   ("C-c C->" . mc/mark-all-like-this)))

(use-package clojure-mode
  :hook
  (clojure-mode . paredit-mode)
  :mode (("\\.edn\\'" . clojure-mode))
  :config
  (define-clojure-indent
    (prop/for-all 1)))

(use-package cider
  :hook
  ((clojure-mode . cider-mode)
   (cider-repl-mode . paredit-mode)
   (cider-repl-mode . cider-company-enable-fuzzy-completion)
   (cider-mode . cider-company-enable-fuzzy-completion))
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
  :config
  ;; kill REPL buffers for a project as well
  (add-to-list 'project-kill-buffer-conditions
	       '(derived-mode . cider-repl-mode)
	       t)
  (setq cider-repl-display-help-banner nil
	nrepl-log-messages nil))

(use-package systemd :if (eq system-type 'gnu/linux))

(use-package browse-url
  :ensure f
  ;; browse-url decides not to use xdg-open if you don't use one of a
  ;; handful of desktop environments...
  :config (when (eq system-type 'gnu/linux)
	    (setq browse-url-browser-function 'browse-url-xdg-open)))

(use-package wgrep)

(use-package json-snatcher
  :config (setq jsons-path-printer 'jsons-print-path-jq))

(use-package jsonian)

(use-package jq-mode)

;; LSP
(use-package lsp-mode
  ;;:disabled
  :hook ((rust-mode
	  clojure-mode
	  go-mode
	  sh-mode
	  nix-mode)
	 . lsp)
  :config
  (setq read-process-output-max (* 1024 1024))
  (setq lsp-enable-indentation nil)
  ;; Using a locally-built version
  ;;:custom (lsp-clojure-custom-server-command
  ;;"/Users/jcsims/code/clojure-lsp/clojure-lsp")
  :custom (lsp-rust-analyzer-cargo-watch-command "clippy")
  :commands lsp)

(use-package eglot
  :disabled
  :hook ((rust-mode
	  clojure-mode
	  go-mode
	  sh-mode
	  nix-mode)
	 . eglot-ensure)
  :bind (:map eglot-mode-map
	      ("C-M-." . xref-find-references)))

(use-package lsp-ui
  ;;:disabled
  :after lsp-mode
  :commands lsp-ui-mode
  :bind (:map lsp-ui-mode-map
	      ("C-M-." . xref-find-references)
	      ([remap xref-find-references] . lsp-ui-peek-find-references))
  :custom
  (lsp-ui-sideline-show-code-actions nil)
  (lsp-ui-sideline-show-diagnostics nil)
  (lsp-ui-doc-use-webkit t))

(use-package rustic
  :hook (rustic-mode . (lambda ()
			 (setq indent-tabs-mode nil))))

(use-package flycheck-rust
  :after rust-mode
  :hook (flycheck-mode . flycheck-rust-setup))

(use-package yasnippet
  :config (yas-global-mode 1))

(use-package savehist
  :ensure f
  :config (savehist-mode))

(use-package crux
  :bind (("C-x 4 t" . crux-transpose-windows)
	 ("C-a" . crux-move-beginning-of-line)))

(use-package help
  :ensure f
  :config (temp-buffer-resize-mode))

(use-package helpful
  :bind (("C-h f" . helpful-callable)
	 ("C-h v" . helpful-variable)
	 ("C-h k" . helpful-key)
	 :map emacs-lisp-mode-map
	 ("C-c C-d" . helpful-at-point)))

(use-package git-link
  :config
  (add-to-list 'git-link-remote-alist
	       '("github\\.threatbuild\\.com" git-link-github)))

(use-package buffer-move
  :bind (("C-S-<up>" . buf-move-up)
	 ("C-S-<down>" . buf-move-down)
	 ("C-S-<right>" . buf-move-right)
	 ("C-S-<left>" . buf-move-left)))

(use-package groovy-mode
  :hook (groovy-mode . (lambda ()
			 (setq indent-tabs-mode nil)
			 (setq tab-width 2)))
  :custom (groovy-indent-offset 2))

(use-package hl-todo
  :config (global-hl-todo-mode))

(use-package pkgbuild-mode
  :if (eq system-type 'gnu/linux)
  :custom (pkgbuild-update-sums-on-save nil))

(use-package vlf
  :config (require 'vlf-setup))

(use-package newcomment
  :ensure f
  :config (global-set-key [remap comment-dwim] #'comment-line))

(use-package xref
  :ensure f
  :custom (xref-search-program 'ripgrep))

(use-package nix-mode)
(use-package nixpkgs-fmt
  :after nix-mode
  :bind (:map nix-mode-map
	      ("C-c C-f" . nixpkgs-fmt-buffer)))

(use-package hideshow
  :ensure f
  :hook (prog-mode . hs-minor-mode))

(use-package winner
  :ensure f
  :config (winner-mode))

(use-package go-mode
  :hook (go-mode . (lambda ()
		     (setq tab-width 2))))

(use-package hippie-expand
  :ensure f
  :bind (([remap dabbrev-expand] . hippie-expand)))

(use-package dash)
(use-package s)
(use-package obsidian
  :demand t
  :after (s dash)
  :config
  (obsidian-specify-path "~/notes/work")
  (global-obsidian-mode)

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

;; Local personalization
(let ((file (expand-file-name (concat (user-real-login-name) ".el")
			      user-emacs-directory)))
  (when (file-exists-p file)
    (load file)))

;;; init.el ends here
