# Install the Python packages.
install:
	poetry install --with test,dev

test-tidy-playground:
	cd tidy_playground; poetry run python -m pytest

test-normalize-proc-names:
	cd normalize_proc_names; poetry run python -m pytest

update-tidy-playground-tests:
	cd tidy_playground; poetry run python -m pytest --snapshot-update

update-normalize-proc-names-tests:
	cd normalize_proc_names; poetry run python -m pytest --snapshot-update

test: test-tidy-playground test-normalize-proc-names

lint:
	poetry run flake8 .
