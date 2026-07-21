;;; org-status-report.el --- Weekly status report system for org-mode -*- lexical-binding: t -*-

;; Copyright (C) 2026 Akira TAGOH

;; Author: Akira TAGOH <akira@tagoh.org>
;; Version: 1.0.0
;; Package-Requires: ((emacs "27.1") (org "9.0"))
;; Keywords: org, productivity, reporting
;; URL: https://github.com/tagoh/org-status-report

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides an automated status report system for org-mode.
;; It organizes completed work by week and allows easy export for
;; weekly/bi-weekly status reports.
;;
;; This package was developed with the assistance of Claude (Anthropic's AI
;; assistant) through an interactive development process.

;; FEATURES:
;; - Automatic weekly organization with customizable week start day
;; - Split weeks into configurable halves (e.g., Tue-Wed, Thu-Fri-Mon)
;; - Quick capture: C-c c s (today) or S (specific date)
;; - Export to plain text bullets via C-c C-e C-s s s
;; - Fully customizable: week structure, labels, bullet style
;; - Zero dependencies beyond Emacs and org-mode

;; INSTALLATION:
;;
;; With use-package and straight.el (recommended):
;;
;;   (use-package org-status-report
;;     :straight (org-status-report :type git
;;                                   :host github
;;                                   :repo "tagoh/org-status-report")
;;     :after org
;;     :demand t
;;     :custom
;;     (org-status-week-start-day 2)              ; Tuesday
;;     (org-status-first-half-days '(2 3))        ; Tue, Wed
;;     (org-status-second-half-days '(4 5 1))     ; Thu, Fri, Mon
;;     (org-status-export-bullet-char "*")
;;     :config
;;     (org-status-report-setup))
;;
;; Manual installation:
;;
;;   (add-to-list 'load-path "~/.emacs.d/site-lisp/org-status-report")
;;   (require 'org-status-report)
;;   (setq org-status-week-start-day 2)
;;   (org-status-report-setup)

;; CUSTOMIZATION:
;;
;; Use the customize interface:
;;   M-x customize-group RET org-status RET
;;
;; Or set variables directly:
;;   (setq org-status-week-start-day 1)         ; Monday
;;   (setq org-status-first-half-days '(1 2 3)) ; Mon-Wed

;; USAGE:
;;
;; 1. Capture completed work:
;;    C-c c -> s (for today)
;;    C-c c -> S (for specific date)
;;
;;    Note: C-c c is the standard org-mode capture binding.
;;    If your configuration uses a different binding, use that instead.
;;
;; 2. Navigate to weeks (when in status.org):
;;    C-c C-x w                        ; Jump to latest week
;;    C-u C-c C-x w                    ; Prompt for date, jump to that week
;;    C-u 28 C-c C-x w                 ; Jump to week 28
;;    M-28 C-c C-x w                   ; Jump to week 28 (alternative)
;;
;;    You can also call directly:
;;    M-x org-status-goto-week         ; Jump to latest week
;;    (org-status-goto-week 28)        ; Jump to week 28 (from Lisp)
;;    (org-status-goto-week "2026-07-14") ; Jump to week containing that date
;;
;; 3. Export status report:
;;    - Open ~/org/status.org
;;    - Put cursor on the heading you want to export
;;    - C-c C-e (open export menu)
;;    - C-s (toggle Subtree mode - bottom shows [X] Subtree)
;;    - s s (export to buffer)
;;    - Copy and paste to your reporting tool

;; STRUCTURE CREATED:
;;
;; The package automatically creates a 5-level hierarchy:
;;
;;   * 2026                                          <- Level 1: Year
;;   ** Week 28 (2026-07-07 to 2026-07-13)          <- Level 2: Week
;;   *** First Half (Tue-Wed)                       <- Level 3: Half
;;   **** 2026-07-08 Wednesday                      <- Level 4: Date
;;   ***** Project A: Fix memory leak in cache      <- Level 5: Task
;;         https://github.com/example/project-a/issues/123
;;   *** Second Half (Thu-Fri-Mon)
;;   **** 2026-07-10 Friday
;;   ***** Project B: Update configuration files

;;; Code:

(require 'org)
(require 'org-capture)

;;; Constants

;; Hierarchy: Year(1) -> Week(2) -> Half(3) -> Date(4) -> Task(5)

(defconst org-status--year-level 1
  "Org heading level for year entries.")

(defconst org-status--week-level 2
  "Org heading level for week entries.")

(defconst org-status--half-level 3
  "Org heading level for half-week entries.")

(defconst org-status--date-level 4
  "Org heading level for date entries.")

(defconst org-status--task-level 5
  "Org heading level for task entries.")

;;; Customization

(defgroup org-status nil
  "Status report configuration for org-mode."
  :group 'org
  :prefix "org-status-")

(defcustom org-status-file (expand-file-name "status.org" org-directory)
  "File where status reports are stored.
Defaults to ~/org/status.org (or your org-directory)."
  :type 'file
  :group 'org-status)

(defcustom org-status-week-start-day 2
  "Day of week when work week starts.
1=Monday, 2=Tuesday, 3=Wednesday, ..., 7=Sunday.
Default is 2 (Tuesday)."
  :type 'integer
  :group 'org-status)

(defcustom org-status-first-half-days '(2 3)
  "List of days in the first half of the work week.
Days are numbered: 1=Monday, 2=Tuesday, 3=Wednesday, etc.
Default is (2 3) meaning Tuesday and Wednesday."
  :type '(repeat integer)
  :group 'org-status)

(defcustom org-status-second-half-days '(4 5 1)
  "List of days in the second half of the work week.
Days are numbered: 1=Monday, 2=Tuesday, 3=Wednesday, etc.
Default is (4 5 1) meaning Thursday, Friday, and Monday."
  :type '(repeat integer)
  :group 'org-status)

(defun org-status--day-abbrev (day-num)
  "Return abbreviated day name for DAY-NUM (1=Monday, 7=Sunday)."
  (aref ["Mon" "Tue" "Wed" "Thu" "Fri" "Sat" "Sun"] (1- day-num)))

(defun org-status--make-half-label (name days)
  "Generate a half-week label from NAME and DAYS list."
  (format "%s (%s)" name
          (mapconcat #'org-status--day-abbrev days "-")))

(defun org-status-first-half-label ()
  "Return the label for the first half of the work week."
  (org-status--make-half-label "First Half" org-status-first-half-days))

(defun org-status-second-half-label ()
  "Return the label for the second half of the work week."
  (org-status--make-half-label "Second Half" org-status-second-half-days))

(defcustom org-status-export-bullet-char "*"
  "Character to use for bullet points in status report exports.
Common choices:
  \"*\" - org-style (default)
  \"-\" - Markdown style
  \"+\" - plus signs
  \"•\" - Unicode bullet"
  :type 'string
  :group 'org-status)

(defcustom org-status-capture-template-key "s"
  "Key for quick status report capture (today's date).
Default is \"s\". Change if it conflicts with existing templates."
  :type 'string
  :group 'org-status)

(defcustom org-status-capture-dated-template-key "S"
  "Key for status report capture with date selection.
Default is \"S\" (capital S). Change if it conflicts with existing templates."
  :type 'string
  :group 'org-status)

;;; Internal variables

(defvar org-status--capture-date nil
  "Temporary variable holding the date for status report capture.
This is dynamically bound when capturing for a specific date
instead of today. Should not be set directly by users.")

(defvar org-status--created-new-structure nil
  "Flag indicating whether new heading structure was created during capture.
Set to t when new headings are created, used to trigger display refresh.")

;;; Week structure calculation

(defun org-status--calculate-week-offset (day-of-week)
  "Calculate offset in days from current DAY-OF-WEEK to week start.
DAY-OF-WEEK is 1=Monday through 7=Sunday.
Returns number of days to subtract to get to week start."
  (if (< day-of-week org-status-week-start-day)
      ;; Day is before week start (e.g., Monday when week starts Tuesday)
      ;; Need to go back to previous week's start day
      (+ (- 7 org-status-week-start-day) day-of-week)
    ;; Day is on or after week start
    (- day-of-week org-status-week-start-day)))

(defun org-status--determine-half (day-of-week)
  "Determine which half of the week DAY-OF-WEEK belongs to.
Returns the label from `org-status-first-half-label' or `org-status-second-half-label'."
  (if (member day-of-week org-status-first-half-days)
      (org-status-first-half-label)
    (org-status-second-half-label)))

(defun org-status--week-structure (&optional time-string)
  "Calculate the org outline path for status report organized by work week.
If TIME-STRING is provided (e.g., \"2026-07-05\"), use that date instead of today.
Returns a list: (year-heading week-heading half-heading date-heading)."
  (let* ((time (if time-string
                   (apply #'encode-time (org-parse-time-string time-string))
                 (or org-status--capture-date (current-time))))
         (day-of-week (string-to-number (format-time-string "%u" time)))
         (days-offset (org-status--calculate-week-offset day-of-week))
         (week-start (time-subtract time (days-to-time days-offset)))
         (week-end (time-add week-start (days-to-time 6)))
         (year (format-time-string "%Y" week-start))
         (week-num (string-to-number (format-time-string "%V" week-start)))
         (week-heading (format "Week %d (%s to %s)"
                               week-num
                               (format-time-string "%Y-%m-%d" week-start)
                               (format-time-string "%Y-%m-%d" week-end)))
         (half (org-status--determine-half day-of-week))
         (date-str (format-time-string "%Y-%m-%d %A" time)))
    (list year week-heading half date-str)))

;;; Heading navigation and creation

(defun org-status--make-heading-regexp (heading level)
  "Create regexp to match HEADING at LEVEL.
HEADING is the text without stars, LEVEL is the number of stars."
  (concat "^"
          (regexp-quote (make-string level ?*))
          " "
          (regexp-quote heading)
          "$"))

(defun org-status--find-or-create-heading (heading level parent-end)
  "Find or create HEADING at LEVEL before PARENT-END.
HEADING is the heading text (without stars).
LEVEL is the number of stars (1-5).
PARENT-END is the point where the parent subtree ends.

If found, moves point to the beginning of the heading line.
If not found, creates the heading at PARENT-END.
Returns point at the beginning of the heading line."
  (let ((heading-re (org-status--make-heading-regexp heading level)))
    (if (re-search-forward heading-re parent-end t)
        (beginning-of-line)
      (goto-char parent-end)
      (insert (make-string level ?*) " " heading "\n")
      (beginning-of-line)
      ;; Mark that we created new structure
      (setq org-status--created-new-structure t))
    (point)))

(defun org-status--position-for-capture ()
  "Position point for org-capture to insert new task.
Moves to end of current heading's content and ensures a newline exists."
  (org-end-of-subtree t t)
  ;; Back up if we're on the next heading
  (when (and (bolp) (looking-at "^\\*"))
    (forward-line -1))
  (end-of-line)
  ;; Move past newline or insert one
  (if (eq (char-after) ?\n)
      (forward-char 1)
    (insert "\n"))
  (point))

;;;###autoload
(defun org-status--goto-or-create ()
  "Navigate to or create the appropriate heading for status report capture.
Uses `org-status--capture-date' if set, otherwise uses current date.
Creates the complete 5-level hierarchy if it doesn't exist:
  Year -> Week -> Half -> Date -> [Task goes here]

Positions point after the date heading for org-capture to insert new task."
  ;; Reset flag at start of capture
  (setq org-status--created-new-structure nil)
  (let* ((path (org-status--week-structure))
         (headings (list (cons (nth 0 path) org-status--year-level)
                         (cons (nth 1 path) org-status--week-level)
                         (cons (nth 2 path) org-status--half-level)
                         (cons (nth 3 path) org-status--date-level))))
    (goto-char (point-min))
    ;; Navigate/create each level of the hierarchy
    (dolist (heading-info headings)
      (let* ((heading (car heading-info))
             (level (cdr heading-info))
             (parent-end (if (= level org-status--year-level)
                             (point-max)
                           (save-excursion (org-end-of-subtree t t) (point)))))
        (when (> level org-status--year-level)
          (forward-line 1))
        (org-status--find-or-create-heading heading level parent-end)))
    (org-status--position-for-capture)))

;;;###autoload
(defun org-status--goto-or-create-with-date ()
  "Navigate to or create heading for status report with date prompt.
Prompts the user to select a date using org-mode's date picker,
then creates/navigates to the appropriate heading structure for that date."
  (let* ((date-string (org-read-date nil nil nil "Select date for status report: "))
         (org-status--capture-date (apply #'encode-time (org-parse-time-string date-string))))
    (org-status--goto-or-create)))

;;; Display refresh after capture

(defun org-status--heading-has-tasks-p ()
  "Check if current heading has any task-level (level 5) children.
Returns t if tasks exist, nil otherwise."
  (let ((has-tasks nil)
        (task-re (concat "^"
                         (regexp-quote (make-string org-status--task-level ?*))
                         " "))
        (end (save-excursion (org-end-of-subtree t t) (point))))
    (save-excursion
      (forward-line 1)
      (when (re-search-forward task-re end t)
        (setq has-tasks t)))
    has-tasks))

(defun org-status--remove-empty-date-heading ()
  "Remove current date heading if it has no tasks.
Returns t if heading was removed, nil otherwise."
  (when (and (org-at-heading-p)
             (= (org-current-level) org-status--date-level)
             (not (org-status--heading-has-tasks-p)))
    (delete-region (line-beginning-position)
                   (save-excursion (org-end-of-subtree t t) (point)))
    t))

(defun org-status--remove-empty-half-heading ()
  "Remove current half heading if it has no date children.
Returns t if heading was removed, nil otherwise."
  (when (and (org-at-heading-p)
             (= (org-current-level) org-status--half-level))
    (let ((has-dates nil)
          (date-re (concat "^"
                           (regexp-quote (make-string org-status--date-level ?*))
                           " "))
          (end (save-excursion (org-end-of-subtree t t) (point))))
      (save-excursion
        (forward-line 1)
        (when (re-search-forward date-re end t)
          (setq has-dates t)))
      (when (not has-dates)
        (delete-region (line-beginning-position)
                       (save-excursion (org-end-of-subtree t t) (point)))
        t))))

(defun org-status--remove-empty-week-heading ()
  "Remove current week heading if it has no half children.
Returns t if heading was removed, nil otherwise."
  (when (and (org-at-heading-p)
             (= (org-current-level) org-status--week-level))
    (let ((has-halves nil)
          (half-re (concat "^"
                           (regexp-quote (make-string org-status--half-level ?*))
                           " "))
          (end (save-excursion (org-end-of-subtree t t) (point))))
      (save-excursion
        (forward-line 1)
        (when (re-search-forward half-re end t)
          (setq has-halves t)))
      (when (not has-halves)
        (delete-region (line-beginning-position)
                       (save-excursion (org-end-of-subtree t t) (point)))
        t))))

(defun org-status--remove-empty-year-heading ()
  "Remove current year heading if it has no week children.
Returns t if heading was removed, nil otherwise."
  (when (and (org-at-heading-p)
             (= (org-current-level) org-status--year-level))
    (let ((has-weeks nil)
          (week-re (concat "^"
                           (regexp-quote (make-string org-status--week-level ?*))
                           " "))
          (end (save-excursion (org-end-of-subtree t t) (point))))
      (save-excursion
        (forward-line 1)
        (when (re-search-forward week-re end t)
          (setq has-weeks t)))
      (when (not has-weeks)
        (delete-region (line-beginning-position)
                       (save-excursion (org-end-of-subtree t t) (point)))
        t))))

(defun org-status--cleanup-empty-structure ()
  "Clean up empty heading structure after capture.
Removes empty date, half, week, and year headings bottom-up.
This is safe to run after any capture - it only removes truly empty headings."
  (let ((status-buffer (get-file-buffer org-status-file)))
    (when status-buffer
      (with-current-buffer status-buffer
        (save-excursion
          ;; Process from bottom-up to handle nested deletions correctly
          ;; We go through the buffer multiple times until no more deletions occur
          (let ((deleted-something t))
            (while deleted-something
              (setq deleted-something nil)

              ;; Remove empty date headings
              (goto-char (point-min))
              (while (re-search-forward
                      (concat "^" (regexp-quote (make-string org-status--date-level ?*)) " ")
                      nil t)
                (beginning-of-line)
                (if (org-status--remove-empty-date-heading)
                    (setq deleted-something t)
                  (forward-line 1)))

              ;; Remove empty half headings
              (goto-char (point-min))
              (while (re-search-forward
                      (concat "^" (regexp-quote (make-string org-status--half-level ?*)) " ")
                      nil t)
                (beginning-of-line)
                (if (org-status--remove-empty-half-heading)
                    (setq deleted-something t)
                  (forward-line 1)))

              ;; Remove empty week headings
              (goto-char (point-min))
              (while (re-search-forward
                      (concat "^" (regexp-quote (make-string org-status--week-level ?*)) " ")
                      nil t)
                (beginning-of-line)
                (if (org-status--remove-empty-week-heading)
                    (setq deleted-something t)
                  (forward-line 1)))

              ;; Remove empty year headings
              (goto-char (point-min))
              (while (re-search-forward
                      (concat "^" (regexp-quote (make-string org-status--year-level ?*)) " ")
                      nil t)
                (beginning-of-line)
                (if (org-status--remove-empty-year-heading)
                    (setq deleted-something t)
                  (forward-line 1))))))))))

(defun org-status--refresh-display-after-capture ()
  "Refresh org-mode display and clean up empty structure after capture.
This function is called via `org-capture-after-finalize-hook'.

Always runs cleanup to remove any empty headings (from aborted captures).
Then refreshes display if new structure was created."
  (when org-status--created-new-structure
    (let ((status-buffer (get-file-buffer org-status-file)))
      (when status-buffer
        (with-current-buffer status-buffer
          ;; Always clean up empty structure (handles both abort and success cases)
          (org-status--cleanup-empty-structure)

          ;; Refresh display
          (when (bound-and-true-p org-indent-mode)
            (org-indent-indent-buffer))
          (font-lock-flush)
          (font-lock-ensure))))
    ;; Reset flag
    (setq org-status--created-new-structure nil)))

;;; Navigation functions

;;;###autoload
(defun org-status-goto-week (&optional arg)
  "Jump to a week entry in the status report.

With no argument (or nil), jump to the latest week.
With a date string argument (e.g., \"2026-07-14\"), jump to that date's week.
With a numeric argument, jump to that week number in current year.

Examples:
  (org-status-goto-week)              ; Jump to latest week
  (org-status-goto-week \"2026-07-14\") ; Jump to week containing that date
  (org-status-goto-week 28)           ; Jump to week 28

When called interactively:
  C-c C-x w         -> Jump to latest week
  C-u C-c C-x w     -> Prompt for date, jump to that week
  C-u 28 C-c C-x w  -> Jump to week 28
  M-28 C-c C-x w    -> Jump to week 28"
  (interactive
   (list (cond
          ;; Numeric prefix argument: use as week number
          ((and current-prefix-arg (numberp current-prefix-arg))
           current-prefix-arg)
          ;; Non-numeric prefix (C-u): prompt for date
          (current-prefix-arg
           (org-read-date nil nil nil "Jump to week containing date: "))
          ;; No prefix: nil (latest week)
          (t nil))))
  (with-current-buffer (find-file-noselect org-status-file)
    (cond
     ;; No argument: jump to latest week
     ((null arg)
      (goto-char (point-max))
      (if (re-search-backward
           (concat "^"
                   (regexp-quote (make-string org-status--week-level ?*))
                   " Week [0-9]+")
           nil t)
          (progn
            (org-show-context 'tree)
            (org-show-subtree)
            (switch-to-buffer (current-buffer))
            (message "Jumped to latest week"))
        (message "No week entries found")))

     ;; String argument: treat as date
     ((stringp arg)
      (let* ((time (apply #'encode-time (org-parse-time-string arg)))
             (path (let ((org-status--capture-date time))
                     (org-status--week-structure)))
             (week-heading (nth 1 path)))  ; "Week N (start to end)"
        (goto-char (point-min))
        (if (re-search-forward
             (org-status--make-heading-regexp week-heading org-status--week-level)
             nil t)
            (progn
              (beginning-of-line)
              (org-show-context 'tree)
              (org-show-subtree)
              (switch-to-buffer (current-buffer))
              (message "Jumped to %s" week-heading))
          (message "Week for date %s not found" arg))))

     ;; Numeric argument: treat as week number
     ((numberp arg)
      (goto-char (point-min))
      (if (re-search-forward
           (concat "^"
                   (regexp-quote (make-string org-status--week-level ?*))
                   " Week " (number-to-string arg) " ")
           nil t)
          (progn
            (beginning-of-line)
            (org-show-context 'tree)
            (org-show-subtree)
            (switch-to-buffer (current-buffer))
            (message "Jumped to Week %d" arg))
        (message "Week %d not found" arg)))

     (t
      (message "Invalid argument type: %S" arg)))))

;;; Task extraction and formatting

(defun org-status--extract-tasks (subtreep)
  "Extract tasks (level 5 headings) from current buffer or subtree.
If SUBTREEP is non-nil, only extract from current subtree.
Returns an alist of (task-title . task-content) where:
  task-title is the heading text
  task-content is any text/links under the heading (trimmed)"
  (let ((tasks '())
        (task-re (concat "^"
                         (regexp-quote (make-string org-status--task-level ?*))
                         " \\(.+\\)$"))
        (heading-re (format "^\\*\\{1,%d\\} " org-status--task-level)))
    (save-excursion
      (save-restriction
        (when subtreep
          (org-narrow-to-subtree))
        (goto-char (point-min))
        (while (re-search-forward task-re nil t)
          (let* ((task-title (match-string 1))
                 (task-start (point))
                 (task-end (save-excursion
                             (if (re-search-forward heading-re nil t)
                                 (match-beginning 0)
                               (point-max))))
                 (task-content (string-trim
                                (buffer-substring-no-properties task-start task-end))))
            (push (cons task-title task-content) tasks)))
        (widen)))
    (nreverse tasks)))

(defun org-status--format-task (task bullet-char)
  "Format a single TASK using BULLET-CHAR.
TASK is a cons cell (title . content)."
  (let ((title (car task))
        (content (cdr task)))
    (if (string-empty-p content)
        (concat bullet-char " " title)
      (concat bullet-char " " title "\n"
              (mapconcat (lambda (line)
                           (concat "  " (string-trim line)))
                         (split-string content "\n" t)
                         "\n")))))

(defun org-status--format-tasks (tasks bullet-char)
  "Format TASKS as bullet list using BULLET-CHAR.
TASKS is an alist of (title . content).
Returns formatted string with each task as a bullet point,
with content indented by two spaces."
  (mapconcat (lambda (task)
               (org-status--format-task task bullet-char))
             tasks
             "\n"))

;;; Export functions

(defun org-status--get-export-heading-title (subtreep)
  "Get heading title for export.
If SUBTREEP is non-nil, returns the current heading's title.
Otherwise returns \"Status Report\"."
  (if subtreep
      (save-excursion
        (unless (org-at-heading-p)
          (org-back-to-heading t))
        (org-get-heading t t t t))
    "Status Report"))

(defun org-status--prepare-export-tasks (subtreep)
  "Prepare tasks for export.
If SUBTREEP is non-nil, extracts tasks from current subtree.
Otherwise extracts from entire buffer."
  (save-excursion
    (when subtreep
      (unless (org-at-heading-p)
        (org-back-to-heading t)))
    (org-status--extract-tasks subtreep)))

(defun org-status--format-export-content (subtreep)
  "Format export content based on SUBTREEP.
Returns a cons cell (title . content-string)."
  (let ((heading-title (org-status--get-export-heading-title subtreep))
        (tasks (org-status--prepare-export-tasks subtreep)))
    (cons heading-title
          (concat heading-title "\n\n"
                  (org-status--format-tasks tasks org-status-export-bullet-char)))))

;;;###autoload
(defun org-status-export-to-buffer (&optional async subtreep visible-only body-only ext-plist)
  "Export status report as plain bullet list to buffer.
When SUBTREEP is non-nil (via C-s toggle in export menu),
exports only tasks from the current heading's subtree.

Creates a buffer named \"*Status Report Export*\" with tasks
formatted as bullet points, ready to copy/paste."
  (interactive)
  (let* ((export-data (org-status--format-export-content subtreep))
         (heading-title (car export-data))
         (content (cdr export-data))
         (outbuf (get-buffer-create "*Status Report Export*")))
    (with-current-buffer outbuf
      (erase-buffer)
      (insert content)
      (goto-char (point-min)))
    (switch-to-buffer-other-window outbuf)
    (message "Exported status report from '%s'" heading-title)))

;;;###autoload
(defun org-status-export-to-file (&optional async subtreep visible-only body-only ext-plist)
  "Export status report as plain bullet list to file.
When SUBTREEP is non-nil (via C-s toggle in export menu),
exports only tasks from the current heading's subtree.

Prompts for a filename and saves the formatted report there."
  (interactive)
  (let* ((export-data (org-status--format-export-content subtreep))
         (heading-title (car export-data))
         (content (cdr export-data))
         (outfile (read-file-name "Export to file: " nil nil nil "status-report.txt")))
    (with-temp-file outfile
      (insert content))
    (message "Exported status report to %s" outfile)))

;;; Keybinding setup

(defun org-status--setup-keybindings ()
  "Set up buffer-local keybindings for status report file.
This function is called automatically when opening the status report file."
  (when (and buffer-file-name
             (string= (expand-file-name buffer-file-name)
                      (expand-file-name org-status-file)))
    (local-set-key (kbd "C-c C-x w") #'org-status-goto-week)))

;;; Setup function

(defun org-status--make-capture-template ()
  "Create org-capture template string for task entry.
Uses explicit level 5 heading with proper indentation."
  (let ((stars (make-string org-status--task-level ?*))
        (indent (make-string (1+ org-status--task-level) ?\s)))
    (format "%s %%^{Project}: %%^{Task}\n%s%%?" stars indent)))

;;;###autoload
(defun org-status-report-setup ()
  "Set up org-status-report capture templates and export backend.
This function should be called once in your init file, typically
in the :config section of a use-package declaration.

Sets up:
1. Two org-capture templates (quick and dated)
2. Custom org export backend for status reports
3. Buffer-local keybinding (C-c C-x w) for navigation
4. Display refresh hook for proper indentation after capture

After running this, you can:
- Capture tasks with C-c c s (or your capture binding + s)
- Navigate with C-c C-x w (when in status.org)
- Export with C-c C-e s s"
  (interactive)

  ;; Add capture templates
  ;; Using plain type with explicit stars - plain doesn't auto-adjust level
  (let ((template (org-status--make-capture-template)))
    (add-to-list 'org-capture-templates
                 `(,org-status-capture-template-key
                   "Status Report"
                   plain
                   (file+function ,org-status-file org-status--goto-or-create)
                   ,template
                   :jump-to-captured t)
                 t)

    (add-to-list 'org-capture-templates
                 `(,org-status-capture-dated-template-key
                   "Status Report (specific date)"
                   plain
                   (file+function ,org-status-file org-status--goto-or-create-with-date)
                   ,template
                   :jump-to-captured t)
                 t))

  ;; Set up keybindings for status report file
  (add-hook 'org-mode-hook #'org-status--setup-keybindings)

  ;; Set up display refresh after capture
  (add-hook 'org-capture-after-finalize-hook #'org-status--refresh-display-after-capture)

  ;; Register export backend
  (with-eval-after-load 'ox
    (org-export-define-backend 'status-report
      '((template . (lambda (contents info) contents)))
      :menu-entry
      '(?s "Export Status Report"
           ((?s "To buffer"
                (lambda (&optional a s v b e)
                  (interactive)
                  (org-status-export-to-buffer a s v b e)))
            (?f "To file"
                (lambda (&optional a s v b e)
                  (interactive)
                  (org-status-export-to-file a s v b e)))))))

  (message "org-status-report: Setup complete. Capture keys: %s (today), %s (specific date)"
           org-status-capture-template-key
           org-status-capture-dated-template-key))

(provide 'org-status-report)

;;; org-status-report.el ends here
