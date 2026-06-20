Prerequisite: install [ripgrep](https://github.com/BurntSushi/ripgrep).

## Python

LSP: pyright (auto-installed via mason). Lint/format: ruff via none-ls.

Python 2 vs 3 routing (per project root, in order):
1. `<root>/{.venv,venv,env}/lib/python2.*/` exists → `pythonVersion = "2.7"`
2. `<root>/.python-version` starts with `2.` → `pythonVersion = "2.7"`
3. `<root>/.py2-project` sentinel file → `pythonVersion = "2.7"`
4. Otherwise → default (latest py3)

Files using py2-only syntax (raw `print` statements etc.) will show parse-error
diagnostics. To override per-project, drop a `pyrightconfig.json` in the repo root.
