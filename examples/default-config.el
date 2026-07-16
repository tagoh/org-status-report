;;; default-config.el --- Example: Default configuration (Tue-Mon week)

;; This is the default configuration with Tuesday-Monday work week
;; Week split: Tue-Wed (first half), Thu-Fri-Mon (second half)
;; This matches many organizations' bi-weekly reporting schedules

(use-package org-status-report
  :straight (org-status-report :type git
                                :host github
                                :repo "tagoh/org-status-report")
  :after org
  :demand t
  :config
  ;; All defaults - no customization needed!
  (org-status-report-setup))

;; Or with explicit defaults shown:
;;
;; (use-package org-status-report
;;   :straight (org-status-report :type git
;;                                 :host github
;;                                 :repo "tagoh/org-status-report")
;;   :after org
;;   :demand t
;;   :custom
;;   ;; Week starts Tuesday
;;   (org-status-week-start-day 2)
;;
;;   ;; First half: Tuesday, Wednesday (comes first chronologically)
;;   (org-status-first-half-days '(2 3))
;;   (org-status-first-half-label "First Half (Tue-Wed)")
;;
;;   ;; Second half: Thursday, Friday, Monday
;;   (org-status-second-half-days '(4 5 1))
;;   (org-status-second-half-label "Second Half (Thu-Fri-Mon)")
;;
;;   ;; Org-style bullets
;;   (org-status-export-bullet-char "*")
;;
;;   ;; Capture keys
;;   (org-status-capture-template-key "s")
;;   (org-status-capture-dated-template-key "S")
;;
;;   ;; File location
;;   (org-status-file (expand-file-name "status.org" org-directory))
;;
;;   :config
;;   (org-status-report-setup))

;;; default-config.el ends here
