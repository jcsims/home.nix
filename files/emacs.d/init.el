;;; init.el --- user-init-file                    -*- lexical-binding: t -*-
;;; Early birds

;; Seed the PRNG anew, from the system's entropy pool
(random t)

(defmacro comment (&rest _body)
  "Comment out one or more s-expressions. Borrowed from Clojure."
  nil)

(eval-and-compile ;;     startup
  (defvar before-user-init-time (current-time)
    "Value of `current-time' when Emacs begins loading `user-init-file'.")
  (message "Loading Emacs...done (%.3fs)"
           (float-time (time-subtract before-user-init-time
                                      before-init-time)))
  (defvar work-install (string= "csims" user-login-name)
    "Is this instance of Emacs running on a work laptop?")
  (setq user-emacs-directory "~/.emacs.d/")
  (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
  (message "Loading %s..." user-init-file)
  (setq inhibit-startup-buffer-menu t)
  (setq inhibit-startup-screen t)
  (setq initial-buffer-choice t)
  (setq initial-scratch-message "")
  (setq ring-bell-function 'ignore)
  (when work-install
    (setq shell-file-name "~/.nix-profile/bin/fish"))
  (when (fboundp 'scroll-bar-mode)
    (scroll-bar-mode 0))
  (when (fboundp 'tool-bar-mode)
    (tool-bar-mode 0))
  (when (fboundp 'tooltip-mode)
    (tooltip-mode 0))
  (menu-bar-mode 0)
  (when (file-exists-p custom-file)
    (load custom-file)))

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(eval-and-compile ;; `use-package'
  (unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))
  ;; use-package-enable-imenu-support must be
  ;; set before requiring use-package.
  (setq use-package-enable-imenu-support t)
  (require 'use-package)
  (setq use-package-verbose t
        use-package-always-ensure t))

(use-package gcmh
  :config (gcmh-mode))

(use-package dash
  :config (global-dash-fontify-mode))

(use-package server
  :ensure f
  :config (or (bound-and-true-p server-process)
              (server-mode)))

;; Font
(if (eq system-type 'gnu/linux)
    (set-frame-font "Hack Nerd Font 10")
  (set-frame-font "Hack Nerd Font 12"))

(eval-and-compile                       ;theme
  (defvar jcs-active-theme)
  (defvar jcs-dark-theme)
  (defvar jcs-light-theme)

  (use-package color-theme-sanityinc-tomorrow
    :config
    (setq jcs-active-theme 'sanityinc-tomorrow-eighties
          jcs-dark-theme 'sanityinc-tomorrow-eighties
          jcs-light-theme 'sanityinc-tomorrow-day)
    ;; Do the initial load.
    (load-theme jcs-active-theme t))

  (defun jcs/toggle-dark-light-theme ()
    "Toggle the current theme between light and dark."
    (interactive)
    (disable-theme jcs-active-theme)
    (if (eq jcs-active-theme jcs-light-theme)
        (setq jcs-active-theme jcs-dark-theme)
      (setq jcs-active-theme jcs-light-theme))
    (load-theme jcs-active-theme t)
    (sml/apply-theme 'automatic)))

(use-package smart-mode-line
  :custom (sml/theme 'automatic)
  :config
  (add-to-list 'sml/replacer-regexp-list '("^~/code/work" ":work:") t)
  (add-to-list 'sml/replacer-regexp-list '("^~/.config/home-manager/" ":home-manager:") t)
  (sml/setup))

(eval-and-compile ;     startup
  (message "Loading early birds...done (%.3fs)"
           (float-time (time-subtract (current-time)
                                      before-user-init-time))))

;;; Long tail

(use-package ansi-color
  :ensure f
  ;; Interpret ANSI color codes in compilation buffer
  :hook (compilation-filter . ansi-color-compilation-filter))

(use-package apheleia
  :if work-install
  :hook clojure-mode)

(use-package atomic-chrome
  :if (display-graphic-p)
  :config
  (setq atomic-chrome-url-major-mode-alist
        '(("github\\.com" . gfm-mode)))
  (atomic-chrome-start-server))

(use-package autorevert
  :ensure f
  :config
  (setq global-auto-revert-non-file-buffers t ; Refresh dired buffers
        auto-revert-verbose nil)              ; but do it quietly
  ;; Auto-refresh buffers
  (global-auto-revert-mode))

(use-package bazel)

(use-package breadcrumb
  :config (breadcrumb-mode))

;; Borrowed from
;; https://skybert.net/emacs/get-clickable-jira-links-in-your-org-files/
;; This highlights the Linear ticket comments we use in the code.
(use-package bug-reference
  :ensure f
  :config
  (setq bug-reference-bug-regexp "\\(\\(RATE-[0-9]+\\|LOS-[0-9]+\\|AR-[0-9]+\\)\\)"
        bug-reference-url-format "https://splashfinancial.atlassian.net/browse/%s")
  :hook (prog-mode . bug-reference-prog-mode))

(use-package cider
  :after (clojure-mode paredit)
  :commands (cider-mode)
  :bind (:map cider-mode-map
              ("C-c i" . cider-inspect-last-result)
              ("M-s-." . cider-find-var))
  :custom
  (cider-save-file-on-load t)
  (cider-repl-use-pretty-printing t)
  (nrepl-use-ssh-fallback-for-remote-hosts t)
  (cider-auto-jump-to-error 'errors-only)
  ;; Remove 'deprecated since LSP does that as well
  (cider-font-lock-dynamically '(macro core))
  ;; Make sure that cider doesn't overwrite xref keybindings, but let LSP handle
  ;; everything.
  (cider-xref-fn-depth 90)
  :config
  (add-hook 'cider-repl-mode-hook 'paredit-mode)
  ;; kill REPL buffers for a project as well
  (add-to-list 'project-kill-buffer-conditions
               '(derived-mode . cider-repl-mode)
               t)
  (setq cider-repl-display-help-banner nil
        nrepl-log-messages nil))

(use-package clojure-mode
  :after (paredit)
  :mode (("\\.edn\\'" . clojure-mode))
  :config (when work-install
            (setq clojure-indent-style 'always-indent))
  :hook
  (clojure-mode . paredit-mode)
  (clojure-mode . cider-mode))

(use-package company
  :config
  (setq company-idle-delay .3) ; decrease delay before autocompletion popup shows
  (setq company-echo-delay 0)  ; remove annoying blinking
  (global-company-mode))

(use-package company-quickhelp
  :config (company-quickhelp-mode))

(use-package consult
  :bind (("C-x b" . consult-buffer)))

;; TODO: Pull out this one function and its dependencies.
(use-package crux
  :bind (("C-a" . crux-move-beginning-of-line)))

(use-package deadgrep)

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
  :config (setq dired-listing-switches "-alh")
  :custom (dired-vc-rename-file t))

(use-package display-line-numbers
  :ensure f
  :config
  (setq display-line-numbers-width-start t)
  (global-display-line-numbers-mode))

(use-package eat
  ;; Borrowed from https://github.com/purcell/emacs.d/blob/master/lisp/init-terminals.el
  :config
  (defun jcs/on-eat-exit (process)
    (when (zerop (process-exit-status process))
      (kill-buffer)
      (unless (eq (selected-window) (next-window))
        (delete-window))))
  :hook (eat-exit . jcs/on-eat-exit))

(use-package ediff
  :ensure f
  :config
  (setq ediff-split-window-function 'split-window-horizontally)
  (setq ediff-window-setup-function 'ediff-setup-windows-plain))

(use-package eglot
  :hook
  ((clojure-mode
    go-ts-mode
    nix-mode
    php-mode
    python-mode
    rust-ts-mode
    sh-mode)
   . eglot-ensure)
  (eglot-managed-mode . eglot-inlay-hints-mode)
  :config (setq eglot-autoshutdown t
                eglot-confirm-server-edits nil
                read-process-output-max (* 1024 1024)
                eglot-extend-to-xref t
                ;; Don't block on connecting to the lsp server at all
                eglot-sync-connect nil)
  :bind (:map eglot-mode-map
              ("C-M-." . xref-find-references)
              ("s-l f" . eglot-format)
              ("s-l a" . eglot-code-actions)
              ("s-l r" . eglot-rename)
              ("s-l c n" . eglot-code-action-organize-imports))
  :custom (eglot-connect-timeout 240))

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

(use-package fish-mode
  :custom (fish-enable-auto-indent t)
  :hook (before-save . fish_indent-before-save))

(use-package flycheck
  :config (global-flycheck-mode)
  :bind (:map flycheck-mode-map
              ("M-n" . flycheck-next-error)
              ("M-p" . flycheck-previous-error))
  :custom (flycheck-global-modes '(not org-mode
                                       cider-repl-mode)))

(use-package flymake
  :ensure f
  :bind (:map flymake-mode-map
              ("M-n" . flymake-goto-next-error)
              ("M-p" . flymake-goto-prev-error)))

(use-package git-link)

(use-package git-timemachine)

(use-package go-ts-mode
  :ensure f
  :mode (("\\.go\\'" . go-ts-mode))
  ;; These shouldn't be on the global hooks, just for go-ts-mode
  :hook (;;(before-save . eglot-format-buffer)
         ;;(before-save . eglot-code-action-organize-imports)
         (go-ts-mode . set-go-local-config))
  :config
  (defun set-go-local-config ()
    (setq-local tab-width 2
                compile-command "go test -v && go vet && golangci-lint run --color never")))

(use-package graphql-mode
  :if work-install)

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

(use-package hl-todo
  :config (global-hl-todo-mode))

(eval-and-compile ;    `isearch'
  (setq isearch-allow-scroll t
        ;; Show a count of matches in the minibuffer (and which one you're at).
        isearch-lazy-count t))

;; Enable emacs to open jar files. This is essential with eglot for reading
;; dependency sources!
(use-package jarchive
  :config (jarchive-mode))

(use-package jinx
  :demand t
  :bind (:map jinx-mode-map
              ("C-." . jinx-correct))
  :config (global-jinx-mode))

(use-package just-mode)

(use-package lisp-mode
  :ensure f
  :config
  (add-hook 'emacs-lisp-mode-hook 'outline-minor-mode)
  (add-hook 'emacs-lisp-mode-hook 'reveal-mode)
  (defun indent-spaces-mode ()
    (setq indent-tabs-mode nil))
  (add-hook 'lisp-interaction-mode-hook 'indent-spaces-mode))

(use-package magit
  :bind (("C-c g"   . magit-status))
  :custom
  (magit-branch-prefer-remote-upstream t)
  (magit-save-repository-buffers 'dontask)
  :config (when work-install
            (remove-hook 'magit-status-headers-hook #'magit-insert-tags-header)))

(use-package man
  :ensure f
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

(use-package nix-mode
  :hook (before-save . nix-format-before-save))

(use-package nix-update)

(use-package no-littering)

(use-package obsidian
  :demand t
  :custom (obsidian-directory "~/notes/notes")
  :config
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
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(defvar org-dir (file-truename "~/org"))
(defvar jcs/org-roam-dir (file-truename "~/org-roam"))

;; org-babel
(use-package ob
  :ensure f
  :after org
  :config
  (org-babel-do-load-languages 'org-babel-load-languages
                               '((clojure . t)
                                 (php . t)
                                 (shell . t)
                                 (sql . t)
                                 (emacs-lisp . t))))

(use-package ob-php)

(use-package org
  :ensure f
  :custom
  ;; Don't create a bookmark during org capture.
  (org-capture-bookmark nil)
  (org-refile-use-outline-path 'file)
  (org-refile-allow-creating-parent-nodes 'confirm)
  (org-priority-default ?C)
  (org-priority-lowest ?D)
  (org-tag-alist (quote (("@mike" . ?m)
                         ("@rick" . ?r)
                         ("@maja" . ?p)
                         ("@karl" . ?k)
                         ("@goose" . ?g)
                         ("@tim" . ?t)
                         ("@chris" . ?c)
                         ("@luke" . ?l)
                         (:newline)
                         ("delegated" . ?d))))

  :config
  (setq org-special-ctrl-a/e t
        org-hide-leading-stars t
        org-hide-emphasis-markers t ;; Hide things like `*` for bold, etc.
        org-pretty-entities t
        org-ellipsis "…"
        org-directory org-dir
        org-log-done 'time
        org-log-into-drawer t
        org-startup-indented t
        org-startup-folded t
        org-src-fontify-natively t
        org-use-fast-todo-selection t
        org-outline-path-complete-in-steps nil
        ;; Don't ask every time before evaluating an org source block
        org-confirm-babel-evaluate nil
        ;; Display images in org by default
        org-startup-with-inline-images t
        ;; Try to keep image widths in emacs to a sane value (measured in pixels)
        org-image-actual-width 1000)
  (setq org-todo-keywords
        (quote ((sequence "TODO(t)" "DOING(o)" "|" "DONE(d)")
                (sequence "DELEGATED(e@/!)" "WAITING(w@/!)" "BLOCKED(b@/!)" "HAMMOCK(h@/!)" "|" "CANCELLED(c@/!)"))))

  ;; These tend to modify files, so save after doing it
  (advice-add 'org-refile :after 'org-save-all-org-buffers)
  (advice-add 'org-archive-subtree-default :after 'org-save-all-org-buffers)
  (advice-add 'org-agenda-archive-default-with-confirmation :after 'org-save-all-org-buffers)
  (advice-add 'org-agenda-todo :after 'org-save-all-org-buffers)

  ;; Modified from https://stackoverflow.com/a/31868530
  (defun jcs/org-screenshot ()
    "Take a screenshot into a time stamped unique-named file in the
same directory as the org-buffer and insert a link to this file."
    (interactive)
    (setq filename
          (concat
           (make-temp-name
            (concat (file-name-nondirectory (buffer-file-name))
                    "_imgs/"
                    (format-time-string "%Y%m%d_%H%M%S_")))
           ".png"))
    (unless (file-exists-p (file-name-directory filename))
      (make-directory (file-name-directory filename)))
                                        ; take screenshot
    (if (eq system-type 'darwin)
        (call-process "screencapture" nil nil nil "-i" filename)
      (call-process "import" nil nil nil filename))
    ;; insert into file if correctly taken
    (if (file-exists-p filename)
        (insert (concat "[[file:" filename "]]")))
    (org-display-inline-images))

  ;; Borrowed from http://mbork.pl/2021-05-02_Org-mode_to_Markdown_via_the_clipboard
  (defun org-copy-region-as-markdown ()
    "Copy the region (in Org) to the system clipboard as Markdown."
    (interactive)
    (if (use-region-p)
        (let* ((region
                (buffer-substring-no-properties
                 (region-beginning)
                 (region-end)))
               (markdown
                (org-export-string-as region 'md t '(:with-toc nil))))
          (gui-set-selection 'CLIPBOARD markdown))))
  :bind (("C-c l" . org-store-link)
         ("C-c a" . org-agenda)
         :map org-mode-map
         ("C-a" . org-beginning-of-line)))

(use-package org-agenda
  :ensure f
  :after (org vulpea)
  :config
  (setq org-agenda-window-setup 'current-window
        org-agenda-block-separator nil
        org-agenda-tags-column -80
        org-agenda-show-future-repeats nil)

  ;; Stolen from
  ;; https://d12frosted.io/posts/2020-06-24-task-management-with-roam-vol2.html
  ;; This ensures that the label prior to the TODO in the agenda is
  ;; readable and sane. This is especially useful using org-roam,
  ;; since the filenames are prefixed with a timestamp, making the
  ;; usual pattern (the filename) useless.
  (setq org-agenda-prefix-format
        '((agenda . " %i %(vulpea-agenda-category 12)%?-12t% s")
          (todo . " %i %(vulpea-agenda-category 12) ")
          (tags . " %i %(vulpea-agenda-category 12) ")
          (search . " %i %(vulpea-agenda-category 12) ")))

  (defun vulpea-agenda-category (&optional len)
    "Get category of item at point for agenda.

     Category is defined by one of the following items:

     - CATEGORY property
     - TITLE keyword
     - TITLE property
     - filename without directory and extension

     When LEN is a number, resulting string is padded right with
     spaces and then truncated with ... on the right if result is
     longer than LEN.

     Usage example:

       (setq org-agenda-prefix-format
             '((agenda . \" %(vulpea-agenda-category) %?-12t %12s\")))

     Refer to `org-agenda-prefix-format' for more information."
    (let* ((file-name (when buffer-file-name
                        (file-name-sans-extension
                         (file-name-nondirectory buffer-file-name))))
           (title (vulpea-buffer-prop-get "title"))
           (category (org-get-category))
           (result
            (or (if (and
                     title
                     (string-equal category file-name))
                    title
                  category)
                "")))
      (if (numberp len)
          (s-truncate len (s-pad-right len " " result))
        result)))

  (defun vulpea-project-files ()
    "Return a list of org-roam files containing the `project' tag."
    (seq-uniq
     (seq-map
      #'car
      (org-roam-db-query
       [:select [nodes:file]
                :from tags
                :left-join nodes
                :on (= tags:node-id nodes:id)
                :where (like tag (quote "%\"project\"%"))]))))

  (defun vulpea-agenda-files-update (&rest _)
    "Update the value of `org-agenda-files' based on `project' tag."
    (setq org-agenda-files (vulpea-project-files)))

  (advice-add 'org-agenda :before #'vulpea-agenda-files-update)
  (advice-add 'org-todo-list :before #'vulpea-agenda-files-update)

  (defun jcs/tomorrow ()
    "Returns a timestamp representing midnight of the next day."
    (let ((current (decode-time (current-time))))
      (setcar current 0)
      (setcar (cdr current) 0)
      (setcar (nthcdr 2 current) 0)
      (setcar (nthcdr 3 current) (+ 1 (nth 3 current)))
      (encode-time current)))

  ;; Mostly borrowed from https://stackoverflow.com/a/54704297
  (defun jcs/org-skip-function (part)
    "Partitions things to decide if they should go into the agenda '(agenda future-scheduled done)"
    (let* ((skip (save-excursion (org-entry-end-position)))
           (dont-skip nil)
           (scheduled-time (org-get-scheduled-time (point)))
           (result
            (or (and scheduled-time
                     ;; This makes sure that tasks scheduled for a future date
                     ;; (and not a future timestamp), which have a scheduled
                     ;; time that's equivalent to midnight, are skipped unless
                     ;; they're actually scheduled for today.
                     (time-less-p (time-add (jcs/tomorrow) -1) scheduled-time)
                     'future-scheduled) ; This is scheduled for a future date
                (and (org-entry-is-done-p) ; This entry is done and should probably be ignored
                     'done)
                'agenda)))             ; Everything else should go in the agenda
      (if (eq result part) dont-skip skip)))

  (setq org-agenda-custom-commands
        `(("c" "Agenda and tasks"
           ((agenda ""
                    ((org-agenda-skip-function
                      '(org-agenda-skip-if nil '(todo done)))))
            ;; (todo ""
            ;;       ((org-agenda-overriding-header "To Refile")
            ;;        (org-agenda-files (list ,jcs/inbox-file))))
            (todo "BLOCKED"
                  ((org-agenda-overriding-header "Blocked")
                   (org-agenda-skip-function
                    '(jcs/org-skip-function 'agenda))))
            (todo "DOING"
                  ((org-agenda-overriding-header "In Progress")))
            (todo "TODO"
                  ((org-agenda-overriding-header "Todo")
                   (org-agenda-skip-function
                    '(jcs/org-skip-function 'agenda))))
            (todo "WAITING"
                  ((org-agenda-overriding-header "Waiting")
                   (org-agenda-skip-function
                    '(jcs/org-skip-function 'agenda))))
            (todo "DELEGATED"
                  ((org-agenda-overriding-header "Delegated")
                   (org-agenda-skip-function
                    '(jcs/org-skip-function 'agenda))))
            (todo "HAMMOCK"
                  ((org-agenda-overriding-header "Hammock")
                   (org-agenda-skip-function
                    '(jcs/org-skip-function 'agenda)))))))))

(use-package org-mac-link)

(use-package org-roam
  :after (org vulpea)
  :custom (org-roam-directory jcs/org-roam-dir)
  :bind (("C-c o l" . org-roam-buffer-toggle)
         ("C-c o f" . org-roam-node-find)
         ("C-c o i" . org-roam-node-insert)
         ("C-c o c" . org-roam-capture)
         ("C-c o r" . org-roam-refile)
         ;; Dailies
         ("C-c o d" . org-roam-dailies-goto-today)
         ("C-c o p" . org-roam-dailies-goto-previous-note)
         ("C-c o n" . org-roam-dailies-goto-next-note)
         ("C-c o j" . org-roam-dailies-capture-today))
  :hook ((find-file . vulpea-project-update-tag)
         (before-save . vulpea-project-update-tag))
  :config
  (org-roam-db-autosync-mode)
  (advice-add 'org-roam-refile :after 'org-save-all-org-buffers)

  ;; Help make agenda loading faster by only including org-roam files
  ;; with todo headers in the agenda files
  ;; Stolen from
  ;; https://d12frosted.io/posts/2021-01-16-task-management-with-roam-vol5.html
  (add-to-list 'org-tags-exclude-from-inheritance "project")

  (defun vulpea-project-p ()
    "Return non-nil if current buffer has any todo entry.

TODO entries marked as done are ignored, meaning this function
returns nil if current buffer contains only completed or
canceled tasks."
    (org-element-map
        (org-element-parse-buffer 'headline)
        'headline
      (lambda (headline)
        (eq (org-element-property :todo-type headline)
            'todo))
      nil
      'first-match))

  ;; Update org-roam node tags with a special tag to help filter
  ;; org-agenda buffers.

  (defun vulpea-project-update-tag ()
    "Update PROJECT tag in the current buffer."
    (when (and (not (active-minibuffer-window))
               (org-roam-buffer-p))
      (save-excursion
        (goto-char (point-min))
        (let* ((tags (vulpea-buffer-tags-get))
               (original-tags tags))
          (if (vulpea-project-p)
              (setq tags (cons "project" tags))
            (setq tags (remove "project" tags)))

          ;; Remove duplicates
          (setq tags (seq-uniq tags))

          ;; Update tags in the buffer if they've changed
          (when (or (seq-difference tags original-tags)
                    (seq-difference original-tags tags))
            (apply #'vulpea-buffer-tags-set tags))))))

  (defun org-roam-buffer-p ()
    "Return non-nil of the currently visited buffer is an org-roam buffer."
    (and buffer-file-name
         (string-prefix-p
          (expand-file-name (file-name-as-directory org-roam-directory))
          (file-name-as-directory buffer-file-name)))))

(use-package org-tempo :ensure f)

(use-package paredit
  :hook (emacs-lisp-mode . paredit-mode)
  :bind (:map paredit-mode-map
              ("RET" . nil)))

(use-package paredit-everywhere
  :after (paredit)
  :hook (prog-mode . paredit-everywhere-mode))

(use-package paren
  :ensure f
  :config (show-paren-mode))

;; TODO: Try out pixel-scroll-precision-mode

(use-package php-mode
  :if work-install
  :hook (php-mode . php-cs-fixer-format-on-save-mode)
  :init
  (require 'reformatter)

  (defgroup php-cs-fixer-format nil
    "PHP file formatting using php-cs-fixer."
    :group 'php)

  (defcustom php-cs-fixer-format-command
    "php-cs-fixer"
    "Name of the php-cs-fixer executable."
    :group 'php-cs-fixer-format
    :type 'string)

  (defcustom php-cs-fixer-format-arguments
    nil
    "Arguments to pass to php-cs-fixer."
    :group 'php-cs-fixer-format
    :type '(repeat string))

;;;###autoload (autoload 'php-cs-fixer-format-buffer "php-cs-fixer-format" nil t)
;;;###autoload (autoload 'php-cs-fixer-format-region "php-cs-fixer-format" nil t)
;;;###autoload (autoload 'php-cs-fixer-format-on-save-mode "php-cs-fixer-format" nil t)
  (reformatter-define
    php-cs-fixer-format
    :program php-cs-fixer-format-command
    :stdin nil
    :stdout nil
    :args (append '("fix" "-q") php-cs-fixer-format-arguments (list input-file))
    :lighter " php-cs-fixer"
    :group 'php-cs-fixer-format)

  :config
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
                 '((php-mode) . ("intelephense" "--stdio")))))

(use-package prog-mode
  :ensure f
  :config
  (defun indicate-buffer-boundaries-left ()
    (setq indicate-buffer-boundaries 'left))
  (defun esk-local-comment-auto-fill ()
    "Only auto-fill in comment strings, in prog-mode-derived buffers."
    (set (make-local-variable 'comment-auto-fill-only-comments) t)
    (auto-fill-mode t))
  (add-hook 'prog-mode-hook 'indicate-buffer-boundaries-left)
  (add-hook 'prog-mode-hook 'esk-local-comment-auto-fill))

(use-package project
  :ensure f
  :custom
  (project-vc-extra-root-markers '(".dir-locals.el"))
  ;; In some oddly-formed projects, .gitignore patterns aren't picked up by
  ;; project (and finding files and searching get polluted).
  ;; TODO: Find out why that's the case!
  ;; In the meantime, ignore these paths that I basically never want to get
  ;; search results or fuzzy-find files from.
  (project-vc-ignores '(".clj-kondo"
                        ".cpcache"
                        ".lsp/.cache"))
  :config (add-to-list 'project-switch-commands '(magit-project-status "Magit" ?m) t))

(use-package recentf
  :ensure f
  :config
  (setq recentf-max-saved-items 1000)
  (add-to-list 'recentf-exclude "^/\\(?:ssh\\|su\\|sudo\\)?x?:")
  (recentf-mode))

(use-package rust-ts-mode
  :ensure f
  :mode (("\\.rs\\'" . rust-ts-mode)))

(use-package savehist
  :ensure f
  :init (savehist-mode))

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

(use-package environ :if work-install)
(use-package splash
  :if work-install
  :load-path "/Users/csims/code/work/stonehenge/development/emacs/"
  :custom
  (splash-stonehenge-dir "/Users/csims/code/work/stonehenge/")
  (splash-website-dir "/Users/csims/code/work/Website/"))

(use-package sqlformat
  :config (setq sqlformat-command 'sql-formatter))

;; Recommended by magit in emacs < 29
(use-package sqlite3)

(use-package symbol-overlay
  :bind (:map mode-specific-map
              ("h h" . symbol-overlay-put)
              ("h r" . symbol-overlay-remove-all)
              ("h m" . symbol-overlay-mode)
              ("h n" . symbol-overlay-switch-forward)
              ("h p" . symbol-overlay-switch-backward)))

(use-package terraform-mode
  :if work-install
  :custom (terraform-format-on-save t))

(eval-and-compile ;    `text-mode'
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

(use-package treemacs
  :config (treemacs-resize-icons 16))

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

(use-package vulpea)

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
  :config (windmove-default-keybindings '(control shift)))

(use-package winner
  :ensure f
  :config (winner-mode))

(use-package xref
  :ensure f
  :custom
  (xref-search-program 'ripgrep))

(use-package yaml-ts-mode :ensure f)

;; This needs to come late, so that it's the first hook that gets executed -
;; hooks prepend as they get added.
(use-package envrc
  :config (envrc-global-mode))

;;; Tequila worms

(eval-and-compile ;     startup
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


(eval-and-compile                                  ; personalize

  (setq sentence-end-double-space nil   ; Sentences can end with a single space.
        select-enable-primary t         ; Use the clipboard for yank and kill
        save-interprogram-paste-before-kill t
        scroll-preserve-screen-position 'always
        scroll-error-top-bottom t       ; Scroll similar to vim
        user-full-name "Chris Sims"
        user-mail-address "chris@jcsi.ms"
        use-short-answers t
        ;; Prevent eldoc from using so much of the minibuffer
        max-mini-window-height 0.2)

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
    "Find the FILEPATH under ~/.config/home-manager."
    (interactive)
    (find-file (expand-file-name filepath "~/.config/home-manager/")))

  ;; Some helpful accessors for commonly-found files.
  (global-set-key (kbd "C-c e e") (lambda () (interactive) (find-nix-file "files/emacs.d/init.el")))
  (global-set-key (kbd "C-c e f") (lambda () (interactive) (find-nix-file "flake.nix")))
  (global-set-key (kbd "C-c e b") (lambda () (interactive) (find-nix-file "base.nix")))
  (global-set-key (kbd "C-c e w") (lambda () (interactive) (find-nix-file "work.nix")))
  (global-set-key (kbd "C-c e l") (lambda () (interactive) (find-nix-file "linux-gui.nix")))
  (global-set-key (kbd "C-c e p") (lambda () (interactive) (find-nix-file "files/Brewfile")))
  (global-set-key (kbd "C-c e c") (lambda () (interactive) (find-file "/etc/nixos/configuration.nix")))

  ;; Taken from the Emacs Wiki: http://www.emacswiki.org/emacs/InsertDate
  (eval-and-compile
    (defun insert-date (prefix)
      "Insert the current date. With PREFIX, use ISO format."
      (interactive "P")
      (let ((format (cond
                     ((not prefix) "%a %d %b %Y")
                     ((equal prefix '(4)) "%Y-%m-%d"))))
        (insert (format-time-string format))))
    (global-set-key (kbd "C-c d") 'insert-date))

  ;; Taken from http://whattheemacsd.com/editing-defuns.el-01.html
  (eval-and-compile
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

  (eval-and-compile
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

  (eval-and-compile
    (defun jcs/epoch-at-point (prefix)
      "Convert the epoch timestamp at point into a human-readable
format. With PREFIX, copy to kill ring."
      (interactive "P")
      (let* ((time-at-point (thing-at-point 'word 'no-properties))
             (time (seconds-to-time (string-to-number time-at-point)))
             (human-readable (format-time-string "%FT%T" time)))
        (when prefix
          (kill-new human-readable))
        (message human-readable)))

    (global-set-key (kbd "C-c t") 'jcs/epoch-at-point))

  (eval-and-compile
    (defun jcs/decode-jwt-at-point ()
      "Decode JWT at point into a temporary buffer."
      (interactive)
      (let* ((jwt-buffer "*jwt*")
             (jwt (thing-at-point 'symbol 'no-properties))
             (claims (-map #'base64-decode-string
                           (-take 2 (s-split "\\." jwt))))
             (json-encoding-pretty-print t))
        (with-temp-buffer-window jwt-buffer nil nil
          (with-current-buffer jwt-buffer
            ;; TODO: bind `q` to `quit-window` in this buffer. I don't think I
            ;; want to use `local-set-key` because of this:
            ;; > The binding goes in the current buffer's local map, which in most
            ;; > cases is shared with all other buffers in the same major mode.
            ;; This would affect all `js-mode` buffers if e.g. I set the buffer mode
            ;; to `js-mode` instead of `special-mode`.
            (-each claims
              (lambda (claim)
                (insert (json-encode (json-read-from-string claim)))))
            (js-mode)
            (switch-to-buffer jwt-buffer)))))

    (global-set-key (kbd "C-c j") 'jcs/decode-jwt-at-point))

  (eval-and-compile ;; Borrowed from
    ;; https://github.com/chopmo/dotfiles/blob/master/.emacs.d/customizations/jpt-yaml.el
    ;; Print the yaml path at point.
    (defun jpt-yaml-indentation-level (s)
      (if (string-match "^ " s)
          (+ 1 (jpt-yaml-indentation-level (substring s 1)))
        0))

    (defun jpt-yaml-current-line ()
      (buffer-substring-no-properties (point-at-bol) (point-at-eol)))

    (defun jpt-yaml-clean-string (s)
      (let* ((s (replace-regexp-in-string "^[ -:]*" "" s))
             (s (replace-regexp-in-string ":$" "" s)))
        s))

    (defun jpt-yaml-not-blank-p (s)
      (string-match "[^[:blank:]]" s))

    (defun jpt-yaml-path-to-point ()
      (save-excursion
        (let* ((line (jpt-yaml-current-line))
               (level (jpt-yaml-indentation-level line))
               result)
          (while (> (point) (point-min))
            (beginning-of-line 0)
            (setq line (jpt-yaml-current-line))

            (let ((new-level (jpt-yaml-indentation-level line)))
              (when (and (jpt-yaml-not-blank-p line)
                         (< new-level level))

                (setq level new-level)
                (setq result (push (jpt-yaml-clean-string line) result)))))

          (mapconcat 'identity result " => "))))

    (defun jpt-yaml-show-path-to-point ()
      (interactive)
      (message (jpt-yaml-path-to-point)))

    (eval-after-load 'yaml-ts-mode
      '(eval-and-compile
         (define-key yaml-ts-mode-map (kbd "C-c p") 'jpt-yaml-show-path-to-point))))

  (eval-and-compile ;; Brightness helper
    (defun set-brightness (level)
      (interactive "n")
      (if (<= 0 level 100)
          (call-process "ddcutil" nil nil nil "setvcp" "10" (number-to-string level))
        (message (format "Unable to set brightness to %d" level))))

    (defun morning-bright ()
      (interactive)
      (set-brightness 55))

    (defun evening-bright ()
      (interactive)
      (set-brightness 5)))

  (eval-and-compile ;; Reinstall packages via package.el, if needed
    ;; Borrowed from https://emacsredux.com/blog/2020/09/12/reinstalling-emacs-packages/
    (defun jcs/reinstall-package (pkg)
      (interactive (list (intern (completing-read "Reinstall package: " (mapcar #'car package-alist)))))
      (unload-feature pkg)
      (package-reinstall pkg)
      (require pkg)))

  (eval-and-compile ;; Borrowed from https://xenodium.com/building-your-own-bookmark-launcher/
    (require 'org-roam-id)
    (require 'org-element)
    (require 'seq)

    (defvar bookmarks-node-id (if work-install
                                  "DECD703F-028C-4414-ADAD-0910F8283CD8"
                                "DD137EE9-E13C-4450-973E-DFDA7770A871"))

    (defun browser-bookmarks (org-file)
      "Return all links from ORG-FILE."
      (with-temp-buffer
        (let (links)
          (insert-file-contents org-file)
          (org-mode)
          (org-element-map (org-element-parse-buffer) 'link
            (lambda (link)
              (let* ((raw-link (org-element-property :raw-link link))
                     (content (org-element-contents link))
                     (title (substring-no-properties (or (seq-first content) raw-link))))
                (push (concat title
                              " | "
                              (propertize raw-link 'face 'whitespace-space))
                      links)))
            nil nil 'link)
          (seq-sort 'string-greaterp links))))

    (comment
     (benchmark-run 1
       (browser-bookmarks
        (car (org-roam-id-find bookmarks-node-id)))))

    (defun open-bookmark ()
      (interactive)
      (browse-url (seq-elt
                   (split-string
                    (completing-read "Open: "
                                     (browser-bookmarks
                                      (car (org-roam-id-find bookmarks-node-id))))
                    " | ")
                   1)))

    ;; TODO: Bind escape to close the minibuffer
    (defmacro present (&rest body)
      "Create a buffer with BUFFER-NAME and eval BODY in a basic frame."
      (declare (indent 1) (debug t))
      `(let* ((buffer (get-buffer-create (generate-new-buffer-name "*present*")))
              (frame (make-frame '((auto-raise . t)
                                   (font . "Hack Nerd Font 15")
                                   (top . 200)
                                   (height . 13)
                                   (width . 110)
                                   (internal-border-width . 20)
                                   (left . 0.33)
                                   (left-fringe . 0)
                                   (line-spacing . 3)
                                   (menu-bar-lines . 0)
                                   (minibuffer . only)
                                   (right-fringe . 0)
                                   (tool-bar-lines . 0)
                                   (undecorated . t)
                                   (unsplittable . t)
                                   (vertical-scroll-bars . nil)))))
         ;; (set-face-attribute 'ivy-current-match frame
         ;;                     :background "#2a2a2a"
         ;;                     :foreground 'unspecified)
         (select-frame frame)
         (select-frame-set-input-focus frame)
         (with-current-buffer buffer
           (condition-case nil
               (unwind-protect
                   ,@body
                 (delete-frame frame)
                 (kill-buffer buffer))
             (quit (delete-frame frame)
                   (kill-buffer buffer))))))

    (defun present-open-bookmark-frame ()
      (present (open-bookmark))))

  (let ((file (expand-file-name (concat (user-real-login-name) ".el")
                                user-emacs-directory)))
    (when (file-exists-p file)
      (load file))))

;; Local Variables:
;; indent-tabs-mode: nil
;; End:
;;; init.el ends here
