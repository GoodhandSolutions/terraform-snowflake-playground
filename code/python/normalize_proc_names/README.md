# Normalize Procedure Names Function

## Installation

For execution, run:

```bash
poetry install
```

If you want to be able to run the tests:

```bash
poetry install --with test
```

## Testing

To run the tests:

```bash
poetry run python -m pytest
```

### Update Tests

Test comparisons use the [snapshottest](https://pypi.org/project/snapshottest/) package. To update the test comparisons, use:

```bash
poetry run python -m pytest --snapshot-update
```
