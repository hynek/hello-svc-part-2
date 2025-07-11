set dotenv-load

PORT := env("PORT", "8000")
ARGS_TEST := env("_UV_RUN_ARGS_TEST", "")
ARGS_SERVE := env("_UV_RUN_ARGS_SERVE", "")


@_:
    just --list


# Run tests
[group('qa')]
test *args:
    uv run {{ ARGS_TEST }} -m pytest {{ args }}

_cov *args:
    uv run -m coverage {{ args }}

# Run tests and measure coverage
[group('qa')]
@cov:
    just _cov erase
    just _cov run -m pytest tests
    # Ensure ASGI entrypoint is importable.
    # You can also use coverage to run your CLI entrypoints.
    just _cov run -m hello_svc.asgi
    just _cov combine
    just _cov report
    just _cov html

# Run linters
[group('qa')]
lint:
    uvx ruff check
    uvx ruff format

# Check types
[group('qa')]
typing:
    uvx ty check --python .venv src

# Perform all checks
[group('qa')]
check-all: lint cov typing


# Run development server
[group('run')]
serve:
    uv run {{ ARGS_SERVE }} -m fastapi dev src/hello_svc/asgi.py --port {{ PORT }}

# Send HTTP request to development server
[group('run')]
req path="" *args:
    @just _http {{ args }} http://127.0.0.1:{{ PORT }}/{{ path }}

_http *args:
    uvx --from httpie http {{ args }}

# Open development server in web browser
[group('run')]
browser:
    uv run -m webbrowser -t http://127.0.0.1:{{ PORT }}


# Update dependencies
[group('lifecycle')]
update:
    uv sync --upgrade

# Ensure project virtualenv is up to date
[group('lifecycle')]
install:
    uv sync

# Remove temporary files
[group('lifecycle')]
clean:
    uv run python -c "import shutil; shutil.rmtree('.venv', ignore_errors=True)"
    uvx pyclean . -d all

# Recreate project virtualenv from nothing
[group('lifecycle')]
fresh: clean install
