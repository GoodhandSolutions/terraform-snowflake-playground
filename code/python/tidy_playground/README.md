# Tidy Playground Procedure

## Installation

For execution, make sure you have setup the Poetry venv from the [top python folder](../../python/).

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
