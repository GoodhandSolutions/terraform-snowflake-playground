# Install the Python packages.
install:
	poetry install --with test,dev

lint:
	poetry run sqlfluff lint . --ignore parsing
