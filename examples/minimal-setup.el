;;; minimal-setup.el --- Example: Minimal setup without use-package

;; Minimal setup for those not using use-package
;; Assumes org-status-report.el is in load-path

;; Option 1: Manual clone and load
;; Clone: git clone https://github.com/tagoh/org-status-report.git ~/.emacs.d/site-lisp/org-status-report

(add-to-list 'load-path "~/.emacs.d/site-lisp/org-status-report")
(require 'org-status-report)

;; Optional: Customize settings before setup
(setq org-status-week-start-day 2)
(setq org-status-export-bullet-char "*")

;; Required: Run setup
(org-status-report-setup)

;; That's it! Now use:
;; C-c o x -> s (capture today)
;; C-c o x -> S (capture specific date)
;; C-c C-e -> s s (export)

;;; minimal-setup.el ends here
