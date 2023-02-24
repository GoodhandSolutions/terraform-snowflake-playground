# Python Files

This folder contains the Python files used in the Procedures deployed by the Terraform module.

There is a top-level poetry configuration which can be used for the sub-folders.

## Environment Configuration

```bash
poetry install --with test,dev
```

## Linting

Linting of this folder is handled by [flake8](https://flake8.pycqa.org/en/latest/index.html). Run the linting using:

Requirements:

- Python 3.8
- Poetry

Run linting:

```bash
poetry run flake8 .
```
