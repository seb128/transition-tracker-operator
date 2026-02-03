PROJECT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

SRC := $(PROJECT)src
TESTS := $(PROJECT)tests
ALL := $(SRC) $(TESTS)

export PYTHONPATH = $(PROJECT):$(PROJECT)/lib:$(SRC)

update-dependencies:
	uv lock --upgrade

lint:
	uv run --group lint ruff check $(ALL)
	uv run --group lint ruff format --check --diff $(ALL)

format:
	uv run --group lint ruff check --fix $(ALL)
	uv run --group lint ruff format $(ALL)

static:
	uv run --group static --group test pyright $(ALL) $(ARGS)

unit:
	uv run --group test \
		coverage run \
		--source=$(SRC) \
		-m pytest \
		--tb native \
		tests/unit \
		-v \
		-s \
		$(ARGS)
	uv run --group test coverage report

integration:
	uv run --group test \
		-m pytest \
		--tb native \
		tests/integration \
		-v \
		-s \
		--log-cli-level=INFO \
		$(ARGS)

clean:
	rm -rf .coverage
	rm -rf .pytest_cache
	rm -rf .ruff_cache
	rm -rf .venv
	rm -rf *.charm
	rm -rf *.rock
	rm -rf **/__pycache__
	rm -rf **/*.egg-info
