;;; threatgrid.el --- Helper functions for working at Threatgrid

;;; Commentary:
;; Two main helper functions for git + threatgrid.  `preq` will convert
;; an issue to a pull request for you, and `tg-weekly-work-report`
;; will generate a markdown list of the PRs assigned to you that have
;; been merged in the last 8 days.

;; Github API docs:https://developer.github.com/enterprise/2.9/v3/

;; There are a few dependencies:
;; - ghub
;; - magit
;; - dash

;; Configuration:
;; - Make sure you set the `tg-gh-username` var
;; - Set git config for ghub:
;;    [github "github.threatbuild.com"]
;;       user = <username>
;; - Configure auth for ghub: https://github.com/magit/ghub#github-enterprise-support
;;; Code:

(require 'ghub)
(require 'magit-git)
(require 'dash)

(defvar tg-gh-host "github.threatbuild.com/api/v3")
(defvar tg-work-repos '("threatgrid/threatbrain"))
(defvar tg-gh-username)


;;; Issue -> Pull Request
(defun tg-get-current-upstream-branch ()
  "Get the bare branch name of the currently configured upstream."
  (replace-regexp-in-string
   (concat (magit-get-upstream-remote) "/")
   ""
   (magit-get-upstream-branch)))

(defun tg-convert-issue-to-pr (branch-name upstream)
  "Convert a particular issue branch BRANCH-NAME to a pull-request.
Pass different UPSTREAM to target something other than master for the PR.
See: https://developer.github.com/v3/pulls/#alternative-input"
  (let ((branch-name (or branch-name (magit-get-current-branch))))
    (if (not (string-prefix-p "issue-" branch-name))
        (message "branch-name should be of the format `issue-<issue number>`.")
      (let ((repo "threatgrid/threatbrain")
            (upstream (or upstream (tg-get-current-upstream-branch) "master"))
            (issue-number (string-to-number (substring branch-name 6)))
            (pr-head (concat tg-gh-username ":" branch-name)))
        (ghub-post (concat "/repos/" repo "/pulls")
                   nil
                   :payload (list
                             (cons 'issue issue-number)
                             (cons 'head pr-head)
                             (cons 'base upstream))
                   :host tg-gh-host)
        (message "Created PR")))))

(defun preq ()
  "Convert an issue to a PR."
  (interactive)
  (tg-convert-issue-to-pr nil nil))

;;; Reporting
(defun tg--prs-for-user (prs username)
  "Filter a list of PRS for a specific USERNAME."
  (-filter (lambda (pr)
             (let ((assignee (alist-get 'assignee pr)))
               (equal username (alist-get 'login assignee))))
           prs))

(defun tg--prs-in-time-range (prs start end)
  "Filter a list of PRS based on START and END times.
nil START or END will not bracket.  START and END are Emacs time structures."
  (-filter (lambda (pr)
             (let ((closed-at (date-to-time (alist-get 'closed_at pr))))
               (and
                (if start
                    (time-less-p start closed-at)
                  t)
                (if end
                    (time-less-p closed-at end)
                  t))))
           prs))

(defun tg-weekly-work (username)
  "Return a list of PRs completed by USERNAME in the last week."
  (let ((latest-prs (--mapcat (ghub-get (concat "/repos/" it "/pulls")
                                        nil
                                        :query (list (cons 'state "closed")
                                                     (cons 'per_page "100"))
                                        :host tg-gh-host)
                              tg-work-repos))
        (eight-days-ago (time-add (current-time) (* -1 8 24 60 60))))
    (-> latest-prs
      (tg--prs-in-time-range eight-days-ago (current-time))
      (tg--prs-for-user username))))

(defun tg-print-weekly-closed-prs (username)
  "Pretty-print a list of PRs completed in the last week by USERNAME."
  (let ((prs (reverse (tg-weekly-work username))))
    (-reduce-from (lambda (acc pr)
                    (concat acc
                            (format "- %s\n  %s\n"
                                    (alist-get 'title pr)
                                    (alist-get 'html_url pr))))
                  ""
                  prs)))

(defun tg-open-prs (username)
  "Return a list of PRs currently open by USERNAME."
  (let ((open-prs (--mapcat (ghub-get (concat "/repos/" it "/pulls")
                                      (list (cons 'state "open")
                                            (cons 'per_page "100"))
                                      :host tg-gh-host)
                            tg-work-repos)))
    (tg--prs-for-user open-prs username)))

(defun tg-print-weekly-open-prs (username)
  "Pretty-print a list of PRs completed in the last week by USERNAME."
  (let ((prs (tg-open-prs username)))
    (-reduce-from (lambda (acc pr)
                    (concat acc
                            (format "- %s\n  %s\n"
                                    (alist-get 'title pr)
                                    (alist-get 'html_url pr))))
                  ""
                  prs)))

(defun tg-in-progress-issues ()
  "Return a list of issues assigned to the auth'd user and labeled `in progress`."
  (ghub-get "/issues"
            nil
            :query (list (cons 'labels "in progress")
                         (cons 'per_page "100"))
            :host tg-gh-host))

(defun tg-print-in-progress-issues ()
  "Pretty-print a list of issues assigned to the auth'd user and labeled `in progress`."
  (let ((issues (tg-in-progress-issues)))
    (-reduce-from (lambda (acc issue)
                    (concat acc
                            (format "- %s\n  %s\n"
                                    (alist-get 'title issue)
                                    (alist-get 'html_url issue))))
                  ""
                  issues)))

(defun tg-insert-weekly-work-report ()
  "Insert a pretty-printed list of work done in the last week at point."
  (interactive)
  (insert "## Did\n"
          (tg-print-weekly-closed-prs tg-gh-username)
          "## Doing\n"
          (tg-print-weekly-open-prs tg-gh-username)
          (tg-print-in-progress-issues)))

(defun tg-insert-unassigned-prs ()
  "Insert a pretty-printed list of work done in the last week at point, that had no assignee."
  (interactive)
  (insert (tg-print-weekly-closed-prs nil)))

(defun tg--create-issue (repo title)
  "Create a new issue in REPO with TITLE, adding the issue number to the kill ring."
  (let* ((response (ghub-post (concat "/repos/" repo "/issues")
                              nil
                              :payload (list (cons 'title title))
                              :host tg-gh-host))
         (issue-number (alist-get 'number response)))
    (kill-new (number-to-string issue-number))
    (message "Created issue: %s" (alist-get 'html_url response))))

(defun tg-create-tb-issue (title)
  "Create a new issue in the threatbrain repo, with title TITLE."
  (interactive "MIssue Title: ")
  (tg--create-issue "threatgrid/threatbrain" title))

(provide 'threatgrid)
;;; threatgrid.el ends here
