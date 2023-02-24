# SQL Files

This folder contains the SQL files used in the Views / Procedures deployed by the Terraform module.

## Linting

Linting of this folder is handled by [SQLFluff](https://github.com/sqlfluff/sqlfluff). Run the linting using:

Requirements:

- Python 3.8
- Poetry

Setup:

```bash
poetry install --dev-dependency
```

Run linting:

```bash
poetry run sqlfluff lint . --ignore parsing
```
