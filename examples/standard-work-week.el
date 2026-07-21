;;; standard-work-week.el --- Example: Standard Mon-Fri work week

;; Configuration for a standard Monday-Friday work week
;; Week split: Mon-Wed (first half), Thu-Fri (second half)

(use-package org-status-report
  :straight (org-status-report :type git
                                :host github
                                :repo "tagoh/org-status-report")
  :after org
  :demand t
  :custom
  ;; Week starts Monday
  (org-status-week-start-day 1)

  ;; First half: Monday, Tuesday, Wednesday
  (org-status-first-half-days '(1 2 3))

  ;; Second half: Thursday, Friday
  (org-status-second-half-days '(4 5))

  ;; Use Markdown-style bullets for easy copy-paste
  (org-status-export-bullet-char "-")

  :config
  (org-status-report-setup))

;;; standard-work-week.el ends here
