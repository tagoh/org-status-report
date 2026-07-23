;;; test-org-status-report.el --- Tests for org-status-report -*- lexical-binding: t -*-

;; Copyright (C) 2026 Akira TAGOH

;; This file is part of org-status-report.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;;; Commentary:

;; Test suite for org-status-report.el
;; Run with: emacs --batch -l test-org-status-report.el

;;; Code:

(add-to-list 'load-path (file-name-directory (or load-file-name buffer-file-name)))
(require 'org-status-report)

(defvar test-failures 0
  "Number of test failures.")

(defvar test-passes 0
  "Number of test passes.")

(defun test-assert (condition message)
  "Assert that CONDITION is true, otherwise fail with MESSAGE."
  (if condition
      (progn
        (setq test-passes (1+ test-passes))
        (message "  ✓ %s" message))
    (setq test-failures (1+ test-failures))
    (message "  ✗ FAIL: %s" message)))

(defun test-equal (actual expected message)
  "Assert that ACTUAL equals EXPECTED, otherwise fail with MESSAGE."
  (if (equal actual expected)
      (progn
        (setq test-passes (1+ test-passes))
        (message "  ✓ %s" message))
    (setq test-failures (1+ test-failures))
    (message "  ✗ FAIL: %s" message)
    (message "      Expected: %S" expected)
    (message "      Got:      %S" actual)))

(defun test-string= (actual expected message)
  "Assert that ACTUAL string equals EXPECTED, otherwise fail with MESSAGE."
  (if (string= actual expected)
      (progn
        (setq test-passes (1+ test-passes))
        (message "  ✓ %s" message))
    (setq test-failures (1+ test-failures))
    (message "  ✗ FAIL: %s" message)
    (message "      Expected: %S" expected)
    (message "      Got:      %S" actual)))

;;; Test: Default configuration values

(defun test-default-configuration ()
  "Test that default configuration values are correct."
  (message "\n=== Testing Default Configuration ===")

  (test-equal org-status-week-start-day 2
              "Week starts on Tuesday (day 2)")

  (test-equal org-status-first-half-days '(2 3)
              "First half includes Tuesday and Wednesday")

  (test-equal org-status-second-half-days '(4 5 1)
              "Second half includes Thursday, Friday, and Monday")

  (test-string= (org-status-first-half-label) "First Half (Tue-Wed)"
                "First half label is 'First Half (Tue-Wed)'")

  (test-string= (org-status-second-half-label) "Second Half (Thu-Fri-Mon)"
                "Second half label is 'Second Half (Thu-Fri-Mon)'"))

;;; Test: Day-to-half assignment

(defun test-day-to-half-assignment ()
  "Test that days are assigned to correct halves."
  (message "\n=== Testing Day-to-Half Assignment ===")

  ;; Test Tuesday (day 2)
  (test-string= (org-status--determine-half 2) "First Half (Tue-Wed)"
                "Tuesday (2) -> First Half")

  ;; Test Wednesday (day 3)
  (test-string= (org-status--determine-half 3) "First Half (Tue-Wed)"
                "Wednesday (3) -> First Half")

  ;; Test Thursday (day 4)
  (test-string= (org-status--determine-half 4) "Second Half (Thu-Fri-Mon)"
                "Thursday (4) -> Second Half")

  ;; Test Friday (day 5)
  (test-string= (org-status--determine-half 5) "Second Half (Thu-Fri-Mon)"
                "Friday (5) -> Second Half")

  ;; Test Monday (day 1)
  (test-string= (org-status--determine-half 1) "Second Half (Thu-Fri-Mon)"
                "Monday (1) -> Second Half")

  ;; Saturday and Sunday should fall into second half (default behavior)
  (test-string= (org-status--determine-half 6) "Second Half (Thu-Fri-Mon)"
                "Saturday (6) -> Second Half (weekend)")

  (test-string= (org-status--determine-half 7) "Second Half (Thu-Fri-Mon)"
                "Sunday (7) -> Second Half (weekend)"))

;;; Test: Week structure calculation

(defun test-week-structure ()
  "Test week structure calculation for specific dates."
  (message "\n=== Testing Week Structure Calculation ===")

  ;; Week 28: 2026-07-07 (Tue) to 2026-07-13 (Mon)
  (let ((structure (org-status--week-structure "2026-07-08")))
    (test-string= (nth 0 structure) "2026"
                  "2026-07-08: Year is 2026")
    (test-string= (nth 1 structure) "Week 28 (2026-07-07 to 2026-07-13)"
                  "2026-07-08: Week 28 range")
    (test-string= (nth 2 structure) "First Half (Tue-Wed)"
                  "2026-07-08 (Wed) -> First Half"))

  (let ((structure (org-status--week-structure "2026-07-09")))
    (test-string= (nth 2 structure) "Second Half (Thu-Fri-Mon)"
                  "2026-07-09 (Thu) -> Second Half"))

  ;; Week 29: 2026-07-14 (Tue) to 2026-07-20 (Mon)
  (let ((structure (org-status--week-structure "2026-07-14")))
    (test-string= (nth 1 structure) "Week 29 (2026-07-14 to 2026-07-20)"
                  "2026-07-14: Week 29 range")
    (test-string= (nth 2 structure) "First Half (Tue-Wed)"
                  "2026-07-14 (Tue) -> First Half"))

  (let ((structure (org-status--week-structure "2026-07-15")))
    (test-string= (nth 2 structure) "First Half (Tue-Wed)"
                  "2026-07-15 (Wed) -> First Half"))

  (let ((structure (org-status--week-structure "2026-07-16")))
    (test-string= (nth 2 structure) "Second Half (Thu-Fri-Mon)"
                  "2026-07-16 (Thu) -> Second Half"))

  (let ((structure (org-status--week-structure "2026-07-17")))
    (test-string= (nth 2 structure) "Second Half (Thu-Fri-Mon)"
                  "2026-07-17 (Fri) -> Second Half"))

  (let ((structure (org-status--week-structure "2026-07-20")))
    (test-string= (nth 2 structure) "Second Half (Thu-Fri-Mon)"
                  "2026-07-20 (Mon) -> Second Half"))

  ;; Week 30: starts on 2026-07-21 (Tue)
  (let ((structure (org-status--week-structure "2026-07-21")))
    (test-string= (nth 1 structure) "Week 30 (2026-07-21 to 2026-07-27)"
                  "2026-07-21: Week 30 range")
    (test-string= (nth 2 structure) "First Half (Tue-Wed)"
                  "2026-07-21 (Tue) -> First Half")))

;;; Test: Week offset calculation

(defun test-week-offset-calculation ()
  "Test the week offset calculation logic."
  (message "\n=== Testing Week Offset Calculation ===")

  ;; Week starts on Tuesday (day 2)
  (test-equal (org-status--calculate-week-offset 2) 0
              "Tuesday: offset is 0 (week start)")

  (test-equal (org-status--calculate-week-offset 3) 1
              "Wednesday: offset is 1")

  (test-equal (org-status--calculate-week-offset 4) 2
              "Thursday: offset is 2")

  (test-equal (org-status--calculate-week-offset 5) 3
              "Friday: offset is 3")

  (test-equal (org-status--calculate-week-offset 6) 4
              "Saturday: offset is 4")

  (test-equal (org-status--calculate-week-offset 7) 5
              "Sunday: offset is 5")

  (test-equal (org-status--calculate-week-offset 1) 6
              "Monday: offset is 6 (wraps from previous week)"))

;;; Test: Semantic correctness

(defun test-semantic-correctness ()
  "Test that first/second half semantics are correct."
  (message "\n=== Testing Semantic Correctness ===")

  ;; First half should come first chronologically in the week
  (test-assert (member 2 org-status-first-half-days)
               "First half contains Tuesday (first work day of week)")

  (test-assert (member 3 org-status-first-half-days)
               "First half contains Wednesday")

  ;; Second half should come later chronologically
  (test-assert (member 4 org-status-second-half-days)
               "Second half contains Thursday")

  (test-assert (member 5 org-status-second-half-days)
               "Second half contains Friday")

  ;; Monday from next calendar week is in second half
  (test-assert (member 1 org-status-second-half-days)
               "Second half contains Monday (from next calendar week)")

  ;; Labels should match the days
  (test-assert (string-match-p "Tue-Wed" (org-status-first-half-label))
               "First half label mentions Tue-Wed")

  (test-assert (string-match-p "Thu-Fri-Mon" (org-status-second-half-label))
               "Second half label mentions Thu-Fri-Mon"))

;;; Test: Edge cases

(defun test-edge-cases ()
  "Test edge cases and boundary conditions."
  (message "\n=== Testing Edge Cases ===")

  ;; Test year boundary (Monday Jan 4, 2027 is in week starting Tue Jan 5, 2027)
  (let ((structure (org-status--week-structure "2027-01-04")))
    (test-string= (nth 2 structure) "Second Half (Thu-Fri-Mon)"
                  "Monday 2027-01-04 -> Second Half (before week start)"))

  ;; Test first Tuesday of year
  (let ((structure (org-status--week-structure "2027-01-05")))
    (test-string= (nth 2 structure) "First Half (Tue-Wed)"
                  "Tuesday 2027-01-05 -> First Half"))

  ;; Test end of year (Monday Dec 27, 2026)
  (let ((structure (org-status--week-structure "2026-12-28")))
    (test-string= (nth 2 structure) "Second Half (Thu-Fri-Mon)"
                  "Monday 2026-12-28 -> Second Half")))

;;; Test: Capture cancellation cleanup

(defun test-capture-cancellation-cleanup ()
  "Test that cancelled captures clean up empty heading structure."
  (message "\n=== Testing Capture Cancellation Cleanup ===")

  (with-temp-buffer
    (org-mode)

    ;; Create a structure as if capture created it
    (insert "* 2026\n")
    (insert "** Week 30 (2026-07-21 to 2026-07-27)\n")
    (insert "*** First Half (Tue-Wed)\n")
    (insert "**** 2026-07-21 Tuesday\n")

    ;; Test: empty date heading has no tasks
    (goto-char (point-min))
    (re-search-forward "^\\*\\*\\*\\* 2026-07-21")
    (beginning-of-line)
    (test-assert (not (org-status--heading-has-tasks-p))
                 "Empty date heading has no tasks")

    ;; Add a task and verify it's detected
    (goto-char (point-max))
    (insert "***** Test task\n")
    (goto-char (point-min))
    (re-search-forward "^\\*\\*\\*\\* 2026-07-21")
    (beginning-of-line)
    (test-assert (org-status--heading-has-tasks-p)
                 "Date heading with task is detected"))

  ;; Test empty structure cleanup
  (with-temp-buffer
    (org-mode)
    (setq org-status-file (buffer-file-name))

    ;; Create empty structure
    (insert "* 2026\n")
    (insert "** Week 30 (2026-07-21 to 2026-07-27)\n")
    (insert "*** First Half (Tue-Wed)\n")
    (insert "**** 2026-07-21 Tuesday\n")

    (let ((initial-content (buffer-string)))
      ;; Simulate cleanup
      (goto-char (point-min))
      (re-search-forward "^\\*\\*\\*\\* 2026-07-21")
      (beginning-of-line)
      (org-status--remove-empty-date-heading)

      (goto-char (point-min))
      (when (re-search-forward "^\\*\\*\\* First Half" nil t)
        (beginning-of-line)
        (org-status--remove-empty-half-heading))

      (goto-char (point-min))
      (when (re-search-forward "^\\*\\* Week 30" nil t)
        (beginning-of-line)
        (org-status--remove-empty-week-heading))

      (goto-char (point-min))
      (when (re-search-forward "^\\* 2026" nil t)
        (beginning-of-line)
        (org-status--remove-empty-year-heading))

      ;; After cleanup, buffer should be empty
      (test-assert (string-empty-p (string-trim (buffer-string)))
                   "Empty structure is completely removed after cleanup")))

  ;; Test that non-empty structure is preserved
  (with-temp-buffer
    (org-mode)

    (insert "* 2026\n")
    (insert "** Week 30 (2026-07-21 to 2026-07-27)\n")
    (insert "*** First Half (Tue-Wed)\n")
    (insert "**** 2026-07-21 Tuesday\n")
    (insert "***** Test task\n")

    (goto-char (point-min))
    (re-search-forward "^\\*\\*\\*\\* 2026-07-21")
    (beginning-of-line)
    (let ((removed (org-status--remove-empty-date-heading)))
      (test-assert (not removed)
                   "Date heading with tasks is not removed"))

    ;; Verify structure is intact
    (goto-char (point-min))
    (test-assert (re-search-forward "^\\* 2026" nil t)
                 "Year heading preserved when has content")
    (test-assert (re-search-forward "^\\*\\* Week 30" nil t)
                 "Week heading preserved when has content")
    (test-assert (re-search-forward "^\\*\\*\\* First Half" nil t)
                 "Half heading preserved when has content")
    (test-assert (re-search-forward "^\\*\\*\\*\\* 2026-07-21" nil t)
                 "Date heading preserved when has tasks")
    (test-assert (re-search-forward "^\\*\\*\\*\\*\\* Test task" nil t)
                 "Task preserved")))

;;; Test: Export deduplication

(defun test-export-deduplication ()
  "Test that export deduplicates tasks by title, keeping the last entry."
  (message "\n=== Testing Export Deduplication ===")

  ;; Single entry: unchanged
  (let ((tasks '(("Project A: Fix bug" . "found root cause"))))
    (let ((result (org-status--deduplicate-tasks tasks)))
      (test-equal (length result) 1
                  "Single entry: one result")
      (test-string= (caar result) "Project A: Fix bug"
                    "Single entry: title preserved")
      (test-string= (cdar result) "found root cause"
                    "Single entry: content preserved")))

  ;; Duplicate title: keep last content
  (let ((tasks '(("Project A: Fix bug" . "day 1 progress")
                 ("Project A: Fix bug" . "day 2 progress"))))
    (let ((result (org-status--deduplicate-tasks tasks)))
      (test-equal (length result) 1
                  "Duplicate title: deduplicated to one")
      (test-string= (cdar result) "day 2 progress"
                    "Duplicate title: last content kept")))

  ;; Multiple distinct titles: all preserved in order
  (let ((tasks '(("Project A: Fix bug" . "notes A")
                 ("Project B: Add feature" . "notes B")
                 ("Project C: Review" . "notes C"))))
    (let ((result (org-status--deduplicate-tasks tasks)))
      (test-equal (length result) 3
                  "Distinct titles: all three preserved")
      (test-string= (caar result) "Project A: Fix bug"
                    "Distinct titles: order preserved (first)")
      (test-string= (car (nth 2 result)) "Project C: Review"
                    "Distinct titles: order preserved (last)")))

  ;; Mixed: some duplicated, some unique
  (let ((tasks '(("Project A: Fix bug" . "day 1")
                 ("Project B: Add feature" . "notes B")
                 ("Project A: Fix bug" . "day 2")
                 ("Project C: Review" . "notes C")
                 ("Project A: Fix bug" . "day 3"))))
    (let ((result (org-status--deduplicate-tasks tasks)))
      (test-equal (length result) 3
                  "Mixed: three unique titles")
      (test-string= (cdar result) "day 3"
                    "Mixed: Project A keeps last (day 3)")
      (test-string= (caar result) "Project A: Fix bug"
                    "Mixed: first-seen order preserved for A")
      (test-string= (car (cadr result)) "Project B: Add feature"
                    "Mixed: B stays in second position")))

  ;; Full export pipeline with org buffer
  (with-temp-buffer
    (org-mode)
    (insert "* 2026\n")
    (insert "** Week 30 (2026-07-21 to 2026-07-27)\n")
    (insert "*** First Half (Tue-Wed)\n")
    (insert "**** 2026-07-21 Tuesday\n")
    (insert "***** Project A: Fix memory leak\n")
    (insert "      Found root cause in cache\n")
    (insert "**** 2026-07-22 Wednesday\n")
    (insert "***** Project A: Fix memory leak\n")
    (insert "      Submitted patch for review\n")
    (insert "***** Project B: Write docs\n")
    (insert "      Started API docs\n")

    (goto-char (point-min))
    (re-search-forward "^\\*\\*\\* First Half")
    (beginning-of-line)
    (let ((tasks (org-status--deduplicate-tasks
                  (org-status--extract-tasks t))))
      (test-equal (length tasks) 2
                  "Org buffer: two unique tasks from first half")
      (test-string= (cdar tasks) "Submitted patch for review"
                    "Org buffer: Project A keeps Wednesday's content")
      (test-string= (car (cadr tasks)) "Project B: Write docs"
                    "Org buffer: Project B preserved"))))

;;; Test: Task name parsing

(defun test-task-name-parsing ()
  "Test parsing of project and task names from task titles."
  (message "\n=== Testing Task Name Parsing ===")

  ;; Parse project from title
  (test-string= (org-status--parse-project-from-title "Project A: Fix bug")
                "Project A"
                "Parse project from 'Project A: Fix bug'")

  (test-string= (org-status--parse-project-from-title "No colon here")
                "No colon here"
                "Parse project with no separator returns full title")

  (test-string= (org-status--parse-project-from-title "Infra: CI: Fix pipeline")
                "Infra"
                "Parse project splits on first ': ' only")

  (test-string= (org-status--parse-project-from-title "")
                ""
                "Parse project from empty string")

  ;; Parse task from title
  (test-string= (org-status--parse-task-from-title "Project A: Fix bug")
                "Fix bug"
                "Parse task from 'Project A: Fix bug'")

  (test-string= (org-status--parse-task-from-title "No colon here")
                ""
                "Parse task with no separator returns empty string")

  (test-string= (org-status--parse-task-from-title "Infra: CI: Fix pipeline")
                "CI: Fix pipeline"
                "Parse task preserves everything after first ': '")

  (test-string= (org-status--parse-task-from-title "")
                ""
                "Parse task from empty string"))

;;; Test: Task name collection

(defun test-task-name-collection ()
  "Test collection of task titles, project names, and tasks per project."
  (message "\n=== Testing Task Name Collection ===")

  (let* ((temp-file (make-temp-file "org-status-test-" nil ".org"))
         (org-status-file temp-file))
    (unwind-protect
        (progn
          ;; Write sample org content
          (with-temp-file temp-file
            (insert "* 2026\n")
            (insert "** Week 28 (2026-07-07 to 2026-07-13)\n")
            (insert "*** First Half (Tue-Wed)\n")
            (insert "**** 2026-07-07 Tuesday\n")
            (insert "***** Project A: Fix memory leak\n")
            (insert "***** Project B: Write docs\n")
            (insert "**** 2026-07-08 Wednesday\n")
            (insert "***** Project A: Fix memory leak\n")
            (insert "***** Project A: Add tests\n")
            (insert "***** Project C: Code review\n"))

          ;; Test collect-task-titles
          (let ((titles (org-status--collect-task-titles)))
            (test-equal (length titles) 4
                        "Collect titles: 4 unique titles (deduped)")
            (test-assert (member "Project A: Fix memory leak" titles)
                         "Collect titles: includes 'Project A: Fix memory leak'")
            (test-assert (member "Project B: Write docs" titles)
                         "Collect titles: includes 'Project B: Write docs'"))

          ;; Test collect-project-names
          (let ((projects (org-status--collect-project-names)))
            (test-equal (length projects) 3
                        "Collect projects: 3 unique projects")
            (test-assert (member "Project A" projects)
                         "Collect projects: includes 'Project A'")
            (test-assert (member "Project B" projects)
                         "Collect projects: includes 'Project B'")
            (test-assert (member "Project C" projects)
                         "Collect projects: includes 'Project C'"))

          ;; Test collect-tasks-for-project
          (let ((tasks-a (org-status--collect-tasks-for-project "Project A")))
            (test-equal (length tasks-a) 2
                        "Tasks for Project A: 2 unique tasks")
            (test-assert (member "Fix memory leak" tasks-a)
                         "Tasks for Project A: includes 'Fix memory leak'")
            (test-assert (member "Add tests" tasks-a)
                         "Tasks for Project A: includes 'Add tests'"))

          (let ((tasks-b (org-status--collect-tasks-for-project "Project B")))
            (test-equal (length tasks-b) 1
                        "Tasks for Project B: 1 task")
            (test-string= (car tasks-b) "Write docs"
                          "Tasks for Project B: is 'Write docs'"))

          (let ((tasks-x (org-status--collect-tasks-for-project "Nonexistent")))
            (test-assert (null tasks-x)
                         "Tasks for nonexistent project: empty list")))

      ;; Cleanup
      (let ((buf (get-file-buffer temp-file)))
        (when buf (kill-buffer buf)))
      (delete-file temp-file)))

  ;; Test with empty/nonexistent file
  (let ((org-status-file "/tmp/org-status-nonexistent-test.org"))
    (let ((titles (org-status--collect-task-titles)))
      (test-assert (null titles)
                   "Collect titles from nonexistent file: nil"))))

;;; Test runner

(defun run-all-tests ()
  "Run all tests and report results."
  (setq test-failures 0)
  (setq test-passes 0)

  (message "========================================")
  (message "org-status-report.el Test Suite")
  (message "========================================")

  (test-default-configuration)
  (test-day-to-half-assignment)
  (test-week-structure)
  (test-week-offset-calculation)
  (test-semantic-correctness)
  (test-edge-cases)
  (test-capture-cancellation-cleanup)
  (test-export-deduplication)
  (test-task-name-parsing)
  (test-task-name-collection)

  (message "\n========================================")
  (message "Test Results")
  (message "========================================")
  (message "Passed: %d" test-passes)
  (message "Failed: %d" test-failures)
  (message "Total:  %d" (+ test-passes test-failures))
  (message "========================================")

  (if (= test-failures 0)
      (progn
        (message "\n✓ ALL TESTS PASSED")
        (kill-emacs 0))
    (progn
      (message "\n✗ SOME TESTS FAILED")
      (kill-emacs 1))))

;; Run tests when loaded in batch mode
(when noninteractive
  (run-all-tests))

(provide 'test-org-status-report)
;;; test-org-status-report.el ends here
