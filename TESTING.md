# Testing Guide

This document describes how to run and write tests for org-status-report.

## Running Tests

### Quick Start

Run all tests using Make:

```bash
make test
```

### Available Test Commands

```bash
make test          # Run test suite with standard output
make test-verbose  # Run with verbose output (includes all Emacs messages)
make check-load    # Check if package loads without errors
make check         # Run both load check and full test suite
```

### Direct Test Execution

You can also run tests directly with Emacs:

```bash
emacs --batch -l test-org-status-report.el
```

## Test Organization

Tests are located in `test-org-status-report.el` and organized into categories:

### 1. Default Configuration Tests
Verify that all default values are correct:
- Week start day
- First/second half day assignments
- Labels

### 2. Day-to-Half Assignment Tests
Test the `org-status--determine-half` function:
- Each weekday maps to correct half
- Weekend days have defined behavior

### 3. Week Structure Calculation Tests
Test `org-status--week-structure` function:
- Correct year, week number, half, and date
- Multiple weeks and dates
- Cross-week boundaries

### 4. Week Offset Calculation Tests
Test `org-status--calculate-week-offset` function:
- Correct offset for each day of week
- Wraparound from Monday to previous Tuesday

### 5. Semantic Correctness Tests
Verify the meaning and ordering:
- First half contains earlier days (Tue-Wed)
- Second half contains later days (Thu-Fri-Mon)
- Labels match the day assignments

### 6. Edge Case Tests
Test boundary conditions:
- Year boundaries
- Week wraparound
- First/last week of year

## Writing New Tests

### Test Assertion Functions

The test suite provides three assertion functions:

```elisp
;; Assert a boolean condition
(test-assert condition "Description of what should be true")

;; Assert equality (uses `equal`)
(test-equal actual expected "Description")

;; Assert string equality (uses `string=`)
(test-string= actual expected "Description")
```

### Example Test Function

```elisp
(defun test-my-feature ()
  "Test description."
  (message "\n=== Testing My Feature ===")
  
  (test-equal (my-function 1) 'expected-result
              "my-function with arg 1 returns expected result")
  
  (test-string= (my-string-function) "expected string"
                "my-string-function returns correct string")
  
  (test-assert (my-predicate)
               "my-predicate returns true"))
```

### Adding Tests to the Suite

Add your test function to `run-all-tests`:

```elisp
(defun run-all-tests ()
  "Run all tests and report results."
  (setq test-failures 0)
  (setq test-passes 0)

  ;; ... existing tests ...
  
  (test-my-feature)  ; Add your test here
  
  ;; ... rest of function ...
)
```

## Test Output

### Successful Test Run

```
========================================
org-status-report.el Test Suite
========================================

=== Testing Default Configuration ===
  ✓ Week starts on Tuesday (day 2)
  ✓ First half includes Tuesday and Wednesday
  ...

========================================
Test Results
========================================
Passed: 41
Failed: 0
Total:  41
========================================

✓ ALL TESTS PASSED
```

### Failed Test Run

When a test fails, you'll see:

```
  ✗ FAIL: Description of failed test
      Expected: expected-value
      Got:      actual-value
```

The exit code will be 1 (non-zero) on failure, 0 on success.

## Continuous Integration

The test suite runs automatically on GitHub Actions for:
- Every push to `main` branch
- Every pull request

See `.github/workflows/test.yml` for CI configuration.

Tests run against multiple Emacs versions:
- Emacs 27.1, 27.2
- Emacs 28.1, 28.2
- Emacs 29.1
- Emacs snapshot (development version)

## Regression Testing

The test suite is specifically designed to catch regressions, especially for the critical first/second half logic.

### Critical Invariants

These invariants must always hold:

1. **First Half Comes First**: `org-status-first-half-days` contains days that occur earlier in the week chronologically (Tue-Wed)

2. **Second Half Comes Second**: `org-status-second-half-days` contains days that occur later (Thu-Fri-Mon), including Monday from the next calendar week

3. **Label Consistency**: Labels must match the actual day assignments

4. **Function Consistency**: All functions (`org-status--determine-half`, `org-status--week-structure`, etc.) must produce consistent results

### Adding Regression Tests

If you find a bug:

1. Write a test that reproduces the bug
2. Verify the test fails
3. Fix the bug
4. Verify the test passes
5. Commit both the fix and the test

This ensures the bug doesn't reappear in future changes.

## Test Coverage

Current test coverage (91 tests):

- ✓ Default configuration values (5 tests)
- ✓ Day-to-half assignment (7 tests)
- ✓ Week structure calculation (11 tests)
- ✓ Week offset calculation (7 tests)
- ✓ Semantic correctness (7 tests)
- ✓ Edge cases (3 tests)
- ✓ Capture cancellation cleanup (9 tests)
- ✓ Export deduplication (15 tests)
- ✓ Task name parsing (8 tests)
- ✓ Task name collection (19 tests)

## Debugging Failed Tests

If tests fail:

1. **Run with verbose output**:
   ```bash
   make test-verbose
   ```

2. **Run tests interactively**:
   ```bash
   emacs -l test-org-status-report.el
   ```
   Then call `M-x run-all-tests`

3. **Test a specific function**:
   ```elisp
   (test-default-configuration)
   ```

4. **Check intermediate values**:
   ```elisp
   (org-status--week-structure "2026-07-16")
   (org-status--determine-half 2)
   ```

## Questions?

If you have questions about testing or need help writing tests:

- Open an issue on GitHub
- See existing tests in `test-org-status-report.el` for examples
