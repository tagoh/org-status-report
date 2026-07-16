.PHONY: test clean

# Run all tests
test:
	@echo "Running test suite..."
	@emacs --batch -l test-org-status-report.el

# Clean up any test artifacts
clean:
	@echo "Cleaning up test artifacts..."
	@rm -f *.elc

# Run tests with verbose output
test-verbose:
	@echo "Running test suite (verbose)..."
	@emacs --batch -l test-org-status-report.el 2>&1

# Check if package loads without errors
check-load:
	@echo "Checking if package loads..."
	@emacs --batch --eval "(progn (add-to-list 'load-path \".\") (load-file \"org-status-report.el\") (message \"✓ Package loaded successfully\"))"

# Run all checks (load + tests)
check: check-load test

help:
	@echo "Available targets:"
	@echo "  test         - Run test suite"
	@echo "  test-verbose - Run test suite with verbose output"
	@echo "  check-load   - Check if package loads without errors"
	@echo "  check        - Run both load check and tests"
	@echo "  clean        - Remove test artifacts"
	@echo "  help         - Show this help message"
