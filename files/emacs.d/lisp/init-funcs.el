;;; init-funcs.el --- Collection of functions added

;;; Commentary:

;;; Code:
;; Taken from the Emacs Wiki: http://www.emacswiki.org/emacs/InsertDate
(defun insert-date (prefix)
  "Insert the current date. With prefix-argument, use ISO
  format."
  (interactive "P")
  (let ((format (cond
		 ((not prefix) "%a %d %b %Y")
		 ((equal prefix '(4)) "%Y-%m-%d"))))
    (insert (format-time-string format))))

(global-set-key (kbd "C-c d") 'insert-date)

;; Taken from http://whattheemacsd.com/editing-defuns.el-01.html
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
(global-set-key (kbd "<C-S-return>") 'open-line-above)

;; A few taken from bodil
(defun sudo-edit ()
  "Edit current buffer using sudo."
  (interactive)
  (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name)))

;; Set transparency of current frame
(defun transparency (value)
  "Set the transparency of the frame window.  VALUE: 0=transparent/100=opaque."
  (interactive "nTransparency Value 0 - 100 opaque:")
  (set-frame-parameter (selected-frame) 'alpha value))

;; Define a nice multi-purpose commenting command
;; Taken from http://endlessparentheses.com/implementing-comment-line.html
(defun endless/comment-line-or-region (n)
  "Comment or uncomment current line and leave point after it.
With positive prefix, apply to N lines including current one.
With negative prefix, apply to -N lines above.
If region is active, apply to active region instead."
  (interactive "p")
  (if (use-region-p)
      (comment-or-uncomment-region
       (region-beginning) (region-end))
    (let ((range
	   (list (line-beginning-position)
		 (goto-char (line-end-position n)))))
      (comment-or-uncomment-region
       (apply #'min range)
       (apply #'max range)))
    (forward-line 1)
    (back-to-indentation)))

(global-set-key (kbd "C-c ;") 'endless/comment-line-or-region)

;; Clear buffer in eshell
(defun eshell-clear-buffer ()
  "Clear eshell buffer."
  (interactive)
  (let ((inhibit-read-only t))
    (erase-buffer)
    (eshell-send-input)))

(add-hook 'eshell-mode-hook
	  #'(lambda ()
	      (local-set-key (kbd "C-l") 'eshell-clear-buffer)))

(defun dired-do-ispell (&optional arg)
  "Check all marked files ARG with ispell. Borrowed from the Emacswiki."
  (interactive "P")
  (dolist (file (dired-get-marked-files
		 nil arg
		 #'(lambda (f)
		     (not (file-directory-p f)))))
    (save-window-excursion
      (with-current-buffer (find-file file)
	(ispell-buffer)))
    (message nil)))

;; Some functions carried over from the emacs starter kit
(defun esk-local-comment-auto-fill ()
  "Only auto-fill in comment strings, in prog-mode-derived buffers."
  (set (make-local-variable 'comment-auto-fill-only-comments) t)
  (auto-fill-mode t))

;; (defun esk-pretty-lambdas ()
;;   "Make the `lambda` keyword a pretty one."
;;   (font-lock-add-keywords
;;    nil `(("(?\\(lambda\\>\\)"
;;           (0 (progn (compose-region (match-beginning 1) (match-end 1)
;;                                     ,(make-char 'greek-iso8859-7 107))
;;                     nil))))))

(add-hook 'prog-mode-hook 'esk-local-comment-auto-fill)
;;(add-hook 'prog-mode-hook 'esk-pretty-lambdas)

(require 'use-package)
(use-package magit-git :ensure magit)
(use-package git-commit :ensure magit)
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

(defun urldecode ()
  "Call `url-unhex-string` on the active region."
  (interactive)
  (if (not (use-region-p))
      (message "`urldecode` only works with an active region!")
    (let ((unhexed (url-unhex-string
		    (buffer-substring-no-properties
		     (region-beginning) (region-end)))))
      (kill-new unhexed)
      (message "%s" unhexed))))

(defun urlencode ()
  "Call `url-hexify-string` on the active region."
  (interactive)
  (if (not (use-region-p))
      (message "`urlencode` only works with an active region!")
    (let ((hexed (url-hexify-string
		  (buffer-substring-no-properties
		   (region-beginning) (region-end)))))
      (kill-new hexed)
      (message "%s" hexed))))

(defun random-lowercase-char ()
  "Return a random lowercase character, from a-z."
  (format "%c" (+ 97 (random 26))))

(defvar jcs/tab-sensitive-modes '(makefile-bsdmake-mode go-mode))
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

;; Info about installed packages, and where they came from. Stolen
;; from https://www.manueluberti.eu//emacs/2021/09/01/package-report/
(defun jcs-package-report ()
  "Report total installed package counts, grouped by archive."
  (interactive)
  (package-refresh-contents)
  (jcs--display-package-report
   (let* ((arch-pkgs (jcs--archive-packages))
	  (counts (seq-sort-by #'cdr #'> (jcs--archive-counts arch-pkgs)))
	  (by-arch (seq-group-by #'car arch-pkgs)))
     (concat
      (format "Total packages: %s\n\n" (apply #'+ (mapcar #'cdr counts)))
      (mapconcat
       (lambda (archive)
	 (concat "• "
		 (format ":%s (%s)" (car archive) (cdr archive))
		 ": "
		 (mapconcat (lambda (ap-pair) (cdr ap-pair))
			    (alist-get (car archive) by-arch)
			    ", ")))
       counts
       "\n\n)")))))

(defun jcs--display-package-report (output)
  "Display OUTPUT in a popup buffer."
  (let ((buffer-name "*package-report*"))
    (with-help-window buffer-name
      (with-current-buffer buffer-name
	(visual-line-mode 1)
	(erase-buffer)
	(insert output)
	(goto-char (point-min))))))

(defun jcs--archive-packages ()
  "Return a list of (archive . package) cons cells."
  (seq-reduce
   (lambda (res package)
     (let ((archive (package-desc-archive
		     (cadr (assq package package-archive-contents))))
	   (pkg (symbol-name package)))
       (push (cons archive pkg) res)))
   (mapcar #'car package-alist)
   nil))

(defun jcs--archive-counts (arch-pkgs)
  "Return a list of cons cells from alist ARCH-PKGS.
The cars are package archives, the cdrs are the number of
packages installed from each archive."
  (seq-reduce
   (lambda (counts key)
     (cons (cons key (+ 1 (or (cdr (assoc key counts))
			      0)))
	   (assoc-delete-all key counts)))
   (mapcar #'car arch-pkgs)
   nil))

;; Stolen from https://emacs.stackexchange.com/a/12164
(defun goto-next-file (&optional backward)
  "Find the next file (by name) in the current directory.

With prefix argument BACKWARD, find the previous file."
  (interactive "P")
  (when buffer-file-name
    (let* ((file (expand-file-name buffer-file-name))
	   (files (cl-remove-if (lambda (file) (cl-first (file-attributes file)))
				(sort (directory-files (file-name-directory file) t nil t) 'string<)))
	   (pos (mod (+ (cl-position file files :test 'equal) (if backward -1 1))
		     (length files))))
      (find-file (nth pos files)))))

(provide 'init-funcs)
;;; init-funcs.el ends here
