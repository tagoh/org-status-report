# Configuration Examples

This directory contains example configurations for different use cases.

## Available Examples

### [default-config.el](default-config.el)

The default configuration with Tuesday-Monday work week. Use this if your organization has:
- Bi-weekly text reports on Wednesday/Thursday and Sunday/Monday
- Week starts on Tuesday
- Split: First half (Tue-Wed), Second half (Thu-Fri-Mon)

**When to use:**
- Default for most bi-weekly reporting schedules
- When you want to see all configuration options explicitly

### [standard-work-week.el](standard-work-week.el)

Standard Monday-Friday work week configuration. Use this if you:
- Work Monday through Friday
- Want first half = Mon-Wed, second half = Thu-Fri
- Need Markdown-style bullets for copy-paste

**When to use:**
- Standard corporate work week
- Weekly/bi-weekly reporting aligned with calendar weeks

### [minimal-setup.el](minimal-setup.el)

Bare minimum setup without use-package. Use this if you:
- Don't use use-package
- Want the simplest possible configuration
- Are just testing the package

**When to use:**
- Learning Emacs
- Simple init.el setup
- Quick testing

## How to Use These Examples

### Copy and paste

Simply copy the configuration that matches your needs into your `init.el`.

### Adapt to your needs

Modify the example to fit your workflow:

```elisp
;; Start from standard-work-week.el, but customize
(use-package org-status-report
  :straight (org-status-report :type git :host github :repo "tagoh/org-status-report")
  :custom
  ;; Your custom work week
  (org-status-week-start-day 3)              ; Week starts Wednesday
  (org-status-first-half-days '(3 4))        ; Wed, Thu
  (org-status-second-half-days '(5 1 2))     ; Fri, Mon, Tue
  (org-status-export-bullet-char "•")        ; Fancy bullets
  :config
  (org-status-report-setup))
```

## Common Customizations

### Change bullet style

```elisp
(org-status-export-bullet-char "*")   ; Org-style (default)
(org-status-export-bullet-char "-")   ; Markdown style
(org-status-export-bullet-char "+")   ; Plus signs
(org-status-export-bullet-char "•")   ; Unicode bullet
```

### Change file location

```elisp
(org-status-file "~/Documents/work-status.org")
(org-status-file (expand-file-name "reports/status.org" org-directory))
```

### Change capture keys

```elisp
;; If "s" and "S" conflict with other templates
(org-status-capture-template-key "r")
(org-status-capture-dated-template-key "R")
```

## Creating Your Own Configuration

1. Start with the example closest to your needs
2. Adjust `org-status-week-start-day` (1=Mon, 2=Tue, ... 7=Sun)
3. Set which days are in each half using `org-status-first-half-days` and `org-status-second-half-days`
4. Update labels to match: `org-status-first-half-label` and `org-status-second-half-label`
5. Choose your export bullet character
6. Test with `M-x org-status-report-setup` to reload

## Need Help?

- See the main [README.md](../README.md) for full documentation
- Check the [User Guide](../GUIDE.md) for detailed usage instructions
- Open an issue if you need help with a custom configuration
