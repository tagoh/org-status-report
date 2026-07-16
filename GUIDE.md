# Org-Mode Status Report Guide

## Overview

This guide explains how to use org-status-report for creating weekly and bi-weekly status reports with automated organization.

## Work Week Structure

**Default Configuration** (fully customizable - see Customization section):

- **Week runs**: Tuesday to Monday (not standard calendar week)
- **Week numbering**: Based on Tuesday's date (ISO week number)
- **First Half**: Tuesday, Wednesday (2 days) - reported bi-weekly
- **Second Half**: Thursday, Friday, Monday (3 days) - reported bi-weekly
- **Full Week**: Reported weekly via email

> **Note**: All these settings can be customized via `M-x customize-group RET org-status RET`

### Example: Week 28

**Week 28 = Tuesday July 7 to Monday July 13, 2026**

- First Half: Tuesday July 7, Wednesday July 8
- Second Half: Thursday July 9, Friday July 10, Monday July 13
- (Weekends are skipped)

## File Structure

All status reports are stored in: **`~/org/status.org`**

(The exact path depends on your `org-directory` setting)

## Daily Workflow: Capturing Tasks

### Option 1: Quick Capture (Today's Date)

When you complete work on a task today:

```
C-c c      (opens org-capture menu)
s          (select "Status Report" - lowercase s)
```

> **Note**: The default org-mode capture binding is `C-c c`. If your Emacs uses a different binding (like `C-c o x`), use that instead.

### Option 2: Capture for a Specific Date

To add a task for a past date (e.g., forgot to log yesterday's work):

```
C-c c      (opens org-capture menu)
S          (select "Status Report (specific date)" - capital S)
[Calendar appears - navigate and select date]
```

**Calendar Navigation:**
- `<` / `>` : Previous/next month
- `S-<left>` / `S-<right>` : Previous/next week
- Arrow keys: Navigate days
- `.` : Jump to today
- `RET` : Select date

### Step 2: Enter Task Details

You'll be prompted for:
1. **Project**: e.g., "Project A", "Project B", "Project C"
2. **Task**: e.g., "Fix memory leak in cache handling"

### Step 3: Add URL/Reference (Optional)

After capturing, add the URL or ticket reference on the next line:

```org
* Project A: Fix memory leak in cache handling
  https://github.com/example/project-a/issues/123
```

Press `C-c C-c` to save and close.

## Auto-Generated Structure

The system automatically creates this hierarchy:

```org
* 2026
** Week 28 (2026-07-07 to 2026-07-13)
*** First Half (Tue-Wed)
**** 2026-07-07 Tuesday
***** Project A: Fix memory leak in cache handling
      https://github.com/example/project-a/issues/123
***** Project B: Update configuration files
      https://github.com/example/project-b/pull/456
**** 2026-07-08 Wednesday
***** Project C: Add support for new features
      https://github.com/example/project-c/issues/321

*** Second Half (Thu-Fri-Mon)
**** 2026-07-09 Thursday
***** General maintenance work
      - Code reviews
      - Bug triage
**** 2026-07-10 Friday
***** Project A: Performance optimization
**** 2026-07-13 Monday
***** Project B: Fix crash on startup
      https://github.com/example/project-b/issues/789
```

## Creating Reports

### For Bi-Weekly Text Report (First or Second Half)

1. Open `~/org/status.org`
2. Navigate to the current week's heading
3. Put cursor on "First Half (Tue-Wed)" or "Second Half (Thu-Fri-Mon)" heading line
4. `C-c C-e` (open export menu)
5. `C-s` (toggle Subtree mode - bottom of menu shows `[X] Subtree`)
6. `s s` (Export Status Report → To buffer)
7. A new buffer "*Status Report Export*" appears with tasks formatted as bullet points
8. Copy all text from that buffer and paste to your reporting tool

**Example output:**
```
First Half (Tue-Wed)

* Project A: Review MR for Fix parsing regression
  https://github.com/example/project-a/pull/456
* Project A: Discuss caching issues
* Project B: Update configuration files
  https://github.com/example/project-b/pull/456
```

### For Weekly Email Report (Full Week)

1. Open `~/org/status.org`
2. Navigate to the week heading (e.g., "Week 28 (2026-07-07 to 2026-07-13)")
3. Put cursor on the week heading line
4. `C-c C-e` (open export menu)
5. `C-s` (toggle Subtree mode - bottom shows `[X] Subtree`)
6. `s s` (Export Status Report → To buffer)
7. Copy all text from "*Status Report Export*" buffer and paste to email

### Save Report to File

To save the report as a text file:

1. Put cursor on the heading you want to export
2. `C-c C-e` (open export menu)
3. `C-s` (toggle Subtree mode ON)
4. `s f` (Export Status Report → To file)
5. Enter filename (default: `status-report.txt`)

### Export Options in the Menu

When you press `C-c C-e`, you'll see the export menu with various options.

**Important:** Press `C-s` to toggle Subtree mode. The bottom of the menu will show:
- `[ ] Subtree` - exports entire file
- `[X] Subtree` - exports only the heading where your cursor is

**Export options:**

**`s s` - Status Report to buffer (Recommended)**
```
* Project A: Review MR
  https://github.com/example/project-a/pull/456
* Project B: Update tables
```
Best for: email, messaging tools, quick copy-paste

**`s f` - Status Report to file**  
Same format as above, but saves to a file you specify.

**`t A` - ASCII export to buffer (Traditional)**  
Includes all headings with dates and full structure - use only if you need the complete hierarchy.

## Org-Mode Navigation Shortcuts

| Keybinding | Action |
|------------|--------|
| `C-c C-j` | Jump to heading (type "Week 28") |
| `TAB` | Fold/unfold current heading |
| `S-TAB` | Fold/unfold all headings |
| `C-c @` | Mark subtree (visual selection - optional) |
| `M-RET` | Create new heading at same level |
| `M-<left>` | Promote heading (fewer stars) |
| `M-<right>` | Demote heading (more stars) |

## Export Shortcuts

| Keybinding | Action |
|------------|--------|
| `C-c C-e` | Open org export menu |
| `C-s` (in export menu) | Toggle Subtree mode - exports only current heading |
| `C-c C-e s s` | **Export Status Report to buffer (recommended)** - Tasks only, no dates |
| `C-c C-e s f` | Export Status Report to file |
| `C-c C-e t A` | Export to ASCII buffer (includes all headings/dates) |

## Tips for Beginners

1. **Don't worry about the structure**: The capture template creates everything automatically
2. **Just capture daily**: Use `C-c c` then `s` every time you complete a task
3. **Fold sections**: Press `TAB` on a heading to hide/show details
4. **Jump quickly**: Use `C-c C-j` to jump to any week
5. **URLs work automatically**: Just paste them on their own line below a task

## Example Full Workflow

### Monday (First Half) - Quick Capture

```
1. Fix a bug in Project B
2. C-c c → s
3. Project: Project B
4. Task: Fix crash on startup
5. Add URL: https://github.com/example/project-b/issues/789
6. C-c C-c to save
```

### Tuesday (Second Half starts)

```
1. Review code for Project A
2. C-c c → s
3. Project: Project A
4. Task: Code review for PR #123
5. Add URL: https://github.com/example/project-a/pull/456
6. C-c C-c to save
```

### Tuesday Evening - Forgot Friday's Work

```
1. Remember you forgot to log work from last Friday
2. C-c c → S (capital S)
3. Calendar appears → navigate to last Friday → RET
4. Project: Project C
5. Task: Performance optimization
6. Add URL if needed
7. C-c C-c to save
   (Task gets inserted under Friday's date automatically)
```

### Wednesday Evening (Create Text Report)

```
1. Open ~/org/status.org
2. C-c C-j → type "Week 28" → navigate to "First Half (Tue-Wed)"
3. Put cursor on "First Half (Tue-Wed)" heading line
4. C-c C-e (open export menu)
5. C-s (toggle Subtree mode - bottom shows [X] Subtree)
6. s s (Export Status Report → To buffer)
7. *Status Report Export* buffer appears with clean bullet points
8. C-x h (select all) → M-w (copy)
9. Paste to your reporting tool
```

**The exported format looks like:**
```
First Half (Tue-Wed)

* Project A: Code review for PR #123
  https://github.com/example/project-a/pull/456
* Project C: Add support for new features
  https://github.com/example/project-c/issues/321
```

## Troubleshooting

### Capture template not showing up

1. Make sure the package is properly installed
2. Verify `(org-status-report-setup)` was called in your init file
3. Restart Emacs or evaluate the setup: `M-x org-status-report-setup`

### Wrong week number

The week number is calculated based on Tuesday's date using ISO week numbering. If your week starts on a different day, customize `org-status-week-start-day`.

### Can't find ~/org/status.org

The file will be created automatically the first time you capture a task. The location depends on your `org-directory` setting. By default it's `~/org/status.org`.

You can customize the location:
```elisp
(setq org-status-file "~/Documents/work-status.org")
```

### Capture keybinding doesn't work

The standard org-mode capture binding is `C-c c`. If this doesn't work:
- Check if you have org-mode loaded: `M-x org-version`
- Check your capture binding: `C-h k` then press your capture key
- Some configurations use different bindings (e.g., `C-c o x`)

## Customization

### Using the Customize Interface

The easiest way to customize:

```
M-x customize-group RET org-status RET
```

This shows all available options with documentation.

### Manual Customization

Add to your init file before calling `(org-status-report-setup)`:

```elisp
;; Change which day the week starts (1=Mon, 2=Tue, ..., 7=Sun)
(setq org-status-week-start-day 2)  ; Default: Tuesday

;; Change which days are in first half
(setq org-status-first-half-days '(2 3))  ; Default: Tue, Wed

;; Change which days are in second half  
(setq org-status-second-half-days '(4 5 1))  ; Default: Thu, Fri, Mon

;; Change the labels
(setq org-status-first-half-label "First Half (Tue-Wed)")
(setq org-status-second-half-label "Second Half (Thu-Fri-Mon)")

;; Change bullet point character for exports
(setq org-status-export-bullet-char "*")  ; Default: "*"
;; Other options: "-" (Markdown), "+" , "•"

;; Change file location
(setq org-status-file "~/Documents/work-status.org")

;; Change capture keys if they conflict
(setq org-status-capture-template-key "r")
(setq org-status-capture-dated-template-key "R")
```

### Example: Standard Mon-Fri Work Week

If you want Mon-Wed as first half, Thu-Fri as second half:

```elisp
(setq org-status-week-start-day 1)  ; Week starts Monday
(setq org-status-first-half-days '(1 2 3))  ; Mon, Tue, Wed
(setq org-status-second-half-days '(4 5))  ; Thu, Fri
(setq org-status-first-half-label "First Half (Mon-Wed)")
(setq org-status-second-half-label "Second Half (Thu-Fri)")
```

### Example: Markdown Export Style

Use Markdown-style dashes for exports:

```elisp
(setq org-status-export-bullet-char "-")
```

### Example: Fancy Unicode Bullets

Use fancy Unicode bullets:

```elisp
(setq org-status-export-bullet-char "•")
```

## Complete Setup Example

Here's a complete setup in your init file:

```elisp
;; Using use-package (recommended)
(use-package org-status-report
  :after org
  :demand t
  :custom
  (org-status-week-start-day 2)              ; Tuesday
  (org-status-first-half-days '(2 3))        ; Tue, Wed
  (org-status-second-half-days '(4 5 1))     ; Thu, Fri, Mon
  (org-status-export-bullet-char "*")
  :config
  (org-status-report-setup))

;; Or manually (without use-package)
(require 'org-status-report)
(setq org-status-week-start-day 2)
(setq org-status-export-bullet-char "*")
(org-status-report-setup)
```

## Reference

- **Package**: org-status-report.el
- **Status file**: `~/org/status.org` (default)
- **Org-mode manual**: `C-h i` then select "Org Mode"
- **Customization**: `M-x customize-group RET org-status RET`

## Common Org-Mode Commands

If you're new to org-mode, these commands are helpful:

| Command | Keybinding | Description |
|---------|------------|-------------|
| org-capture | `C-c c` | Start capturing |
| org-export-dispatch | `C-c C-e` | Export menu |
| org-mark-subtree | `C-c @` | Mark current subtree |
| org-goto | `C-c C-j` | Jump to heading |
| org-cycle | `TAB` | Fold/unfold |
| org-global-cycle | `S-TAB` | Fold/unfold all |

For more org-mode help: `C-h i` → Org Mode
