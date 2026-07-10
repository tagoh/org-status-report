# org-status-report.el

An Emacs package for automated weekly status report organization in org-mode.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## Features

- 📅 **Automatic weekly organization** - Customizable week structure (default: Tuesday to Monday)
- 🔀 **Configurable week splits** - First half (Thu-Fri-Mon) and Second half (Tue-Wed)
- ⚡ **Quick capture** - `C-c c s` for today, `S` for any date
- 📤 **Easy export** - Export to plain text via `C-c C-e s s`
- 🎨 **Fully customizable** - Week start day, labels, bullet styles
- 🔧 **use-package compatible** - Easy installation with modern Emacs configs
- 📦 **Zero dependencies** - Only requires Emacs 27.1+ and org-mode 9.0+

## Demo

**Auto-generated structure:**
```org
* 2026
** Week 28 (2026-07-07 to 2026-07-13)
*** Second Half (Tue-Wed)
**** 2026-07-08 Wednesday
***** Project A: Fix memory leak in cache module
      https://github.com/example/project-a/issues/123
***** Project B: Update configuration files
*** First Half (Thu-Fri-Mon)
**** 2026-07-10 Friday
***** Project C: Add support for new API
```

**Exported output:**
```
Second Half (Tue-Wed)

* Project A: Fix memory leak in cache module
  https://github.com/example/project-a/issues/123
* Project B: Update configuration files
```

## Installation

### Prerequisites

- Emacs 27.1 or later
- org-mode 9.0 or later (usually bundled with Emacs)

### Using straight.el (Recommended)

Add to your `init.el`:

```elisp
(use-package org-status-report
  :straight (org-status-report :type git
                                :host github
                                :repo "tagoh/org-status-report")
  :after org
  :demand t
  :config
  (org-status-report-setup))
```

### Using quelpa

```elisp
(use-package org-status-report
  :quelpa (org-status-report :fetcher github
                              :repo "tagoh/org-status-report")
  :after org
  :demand t
  :config
  (org-status-report-setup))
```

### Using vc-use-package (Emacs 29+)

```elisp
(use-package org-status-report
  :vc (:fetcher github :repo tagoh/org-status-report)
  :after org
  :demand t
  :config
  (org-status-report-setup))
```

### Manual Installation

```bash
# Clone the repository to your preferred location
git clone https://github.com/tagoh/org-status-report.git ~/.emacs.d/site-lisp/org-status-report
```

Then add to your `init.el`:

```elisp
(use-package org-status-report
  :load-path "~/.emacs.d/site-lisp/org-status-report"
  :after org
  :demand t
  :config
  (org-status-report-setup))
```

Or without use-package:

```elisp
(add-to-list 'load-path "~/.emacs.d/site-lisp/org-status-report")
(require 'org-status-report)
(org-status-report-setup)
```

### Verification

After installation and restarting Emacs:

1. **Check if loaded:**
   ```
   M-x describe-function RET org-status-report-setup RET
   ```
   Should show function documentation.

2. **Test capture:**
   ```
   C-c c
   ```
   You should see "s" for "Status Report" in the capture menu.
   
   > **Note**: The standard org-mode capture binding is `C-c c`. If your configuration uses a different binding (like `C-c o x`), use that instead.

3. **Create a test entry:**
   ```
   C-c c → s → Enter "test" for project → Enter "test task" → C-c C-c
   ```
   Then open `~/org/status.org` to verify the structure was created.

### Updating

**With straight.el:**
```
M-x straight-pull-package RET org-status-report RET
```

**Manual installation:**
```bash
cd ~/.emacs.d/site-lisp/org-status-report
git pull
```
Then restart Emacs or run `M-x org-status-report-setup`.

## Quick Start

After installation, restart Emacs and:

1. **Capture work**: `C-c c` → `s` → Enter project and task
2. **View report**: Open `~/org/status.org`
3. **Export**: Navigate to heading → `C-c @` → `C-c C-e` → `s s`

> **Note**: If your Emacs uses a different capture binding, substitute `C-c c` with your configured binding throughout this guide.

## Configuration

### Basic Configuration

```elisp
(use-package org-status-report
  :straight (org-status-report :type git :host github :repo "tagoh/org-status-report")
  :after org
  :demand t
  :custom
  ;; Week structure
  (org-status-week-start-day 2)              ; Week starts Tuesday
  (org-status-second-half-days '(2 3))       ; Tue, Wed
  (org-status-first-half-days '(4 5 1))      ; Thu, Fri, Mon
  
  ;; Labels
  (org-status-second-half-label "Second Half (Tue-Wed)")
  (org-status-first-half-label "First Half (Thu-Fri-Mon)")
  
  ;; Export format
  (org-status-export-bullet-char "*")        ; Use * for bullets
  
  :config
  (org-status-report-setup))
```

### Alternative Week Structures

**Standard work week (Mon-Fri):**

```elisp
(use-package org-status-report
  :custom
  (org-status-week-start-day 1)              ; Week starts Monday
  (org-status-first-half-days '(1 2 3))      ; Mon, Tue, Wed
  (org-status-second-half-days '(4 5))       ; Thu, Fri
  (org-status-first-half-label "First Half (Mon-Wed)")
  (org-status-second-half-label "Second Half (Thu-Fri)")
  :config
  (org-status-report-setup))
```

**Markdown-style bullets for export:**

```elisp
(use-package org-status-report
  :custom
  (org-status-export-bullet-char "-")  ; Markdown style
  :config
  (org-status-report-setup))
```

**Custom file location:**

```elisp
(use-package org-status-report
  :custom
  (org-status-file "~/Documents/work-status.org")
  :config
  (org-status-report-setup))
```

**Custom template keys (avoid conflicts):**

```elisp
(use-package org-status-report
  :custom
  (org-status-capture-template-key "r")      ; Use "r" instead of "s"
  (org-status-capture-dated-template-key "R") ; Use "R" instead of "S"
  :config
  (org-status-report-setup))
```

## Usage

### Capturing Work

**Quick capture (today's date):**
```
C-c c      → Open capture menu (standard org-mode binding)
s          → Select "Status Report"
           → Enter project name
           → Enter task description
           → [Optional: Add URL/reference on next line]
C-c C-c    → Save
```

**Capture for specific date:**
```
C-c c      → Open capture menu
S          → Select "Status Report (specific date)"
           → Calendar appears - select date
           → Enter project and task
C-c C-c    → Save
```

> **Note**: Replace `C-c c` with your configured org-capture binding if different.

### Exporting Reports

**For bi-weekly text reports:**

1. Open `~/org/status.org`
2. Navigate to heading (e.g., "Second Half (Tue-Wed)")
3. `C-c @` - Mark subtree (see what's highlighted)
4. `C-c C-e` - Open export menu
5. `s s` - Export Status Report → To buffer
6. Copy from `*Status Report Export*` buffer
7. Paste to your reporting tool

**For weekly email reports:**

1. Navigate to "Week 28 (...)" heading
2. `C-c @` - Mark subtree
3. `C-c C-e s s` - Export to buffer
4. Copy and paste to email

**Save to file:**
```
C-c @       → Mark subtree
C-c C-e     → Export menu
s f         → Export to file
            → Enter filename
```

## Customization

Access all settings:
```
M-x customize-group RET org-status RET
```

### Available Options

| Variable | Default | Description |
|----------|---------|-------------|
| `org-status-file` | `~/org/status.org` | Where reports are stored |
| `org-status-week-start-day` | `2` (Tue) | Day week starts (1=Mon...7=Sun) |
| `org-status-second-half-days` | `'(2 3)` | Days in second half |
| `org-status-first-half-days` | `'(4 5 1)` | Days in first half |
| `org-status-second-half-label` | `"Second Half (Tue-Wed)"` | Second half heading label |
| `org-status-first-half-label` | `"First Half (Thu-Fri-Mon)"` | First half heading label |
| `org-status-export-bullet-char` | `"*"` | Export bullet character |
| `org-status-capture-template-key` | `"s"` | Quick capture key |
| `org-status-capture-dated-template-key` | `"S"` | Dated capture key |

## Documentation

- [User Guide](GUIDE.md) - Comprehensive usage guide for beginners
- [Example Configurations](examples/) - Common configuration examples

## Troubleshooting

### Capture templates not appearing

1. Make sure `(org-status-report-setup)` is called in your config
2. Restart Emacs or run `M-x org-status-report-setup`
3. Check that org-mode is loaded: `M-x org-version`

### Capture binding doesn't work

The standard org-mode capture binding is `C-c c`. If this doesn't work:
- Check your org-capture binding: `C-h k` then press your capture key
- Your configuration may use a different binding (common: `C-c o x`)
- Use whatever binding works for `org-capture` in your setup

### Export menu doesn't show "s" option

The export backend loads with `ox`. If it doesn't appear, add:
```elisp
(require 'ox)
```
before calling `org-status-report-setup`.

### Template key conflicts

If `"s"` or `"S"` conflicts with existing templates:

```elisp
(setq org-status-capture-template-key "r")
(setq org-status-capture-dated-template-key "R")
```

### Wrong week numbers

Week numbers are ISO weeks based on your configured week start day. If you set `org-status-week-start-day` to 2 (Tuesday), calculations use Tuesday's ISO week.

### File location issues

The default location is `~/org/status.org`, which depends on your `org-directory` setting. The file is created automatically on first capture. To check your org-directory:
```
M-x eval-expression RET org-directory RET
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

GPL-3.0-or-later. See [LICENSE](LICENSE) file for details.

## Author

Akira TAGOH <akira@tagoh.org>

## Development

This package was developed with the assistance of [Claude](https://claude.ai) (Anthropic's AI assistant). The interactive development process helped create a well-structured, production-ready Emacs package with comprehensive documentation.

## Acknowledgments

Inspired by the need for structured, automated status reporting in professional environments.
