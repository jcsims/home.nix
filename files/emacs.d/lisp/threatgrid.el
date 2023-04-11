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

(defun tg-convert-issue-to-pr (repo branch-name upstream)
  "Convert a particular issue branch BRANCH-NAME to a pull-request against REPO.
Pass different UPSTREAM to target something other than master for the PR.
See: https://developer.github.com/v3/pulls/#alternative-input"
  (let ((branch-name (or branch-name (magit-get-current-branch))))
    (if (not (string-prefix-p "issue-" branch-name))
        (message "branch-name should be of the format `issue-<issue number>`.")
      (let ((repo (or repo "threatgrid/threatbrain"))
            (upstream (or upstream (tg-get-current-upstream-branch) "master"))
            (issue-number (string-to-number (substring branch-name 6)))
            (pr-head (concat tg-gh-username ":" branch-name)))
        (ghub-post (concat "/repos/" repo "/pulls")
                   nil
                   :payload (list
                             (cons 'issue issue-number)
                             (cons 'head pr-head)
                             (cons 'base upstream)
			     (cons 'maintainer_can_modify nil))
                   :host tg-gh-host)
        (message "Created PR")))))

(defun preq ()
  "Convert an issue to a PR."
  (interactive)
  (tg-convert-issue-to-pr nil nil nil))

(defun app-preq ()
  "Convert an issue in the appliance repo to a PR."
  (interactive)
  (tg-convert-issue-to-pr "threatgrid/appliance" nil nil))

(provide 'threatgrid)
;;; threatgrid.el ends here
