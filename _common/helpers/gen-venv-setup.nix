{ pythonPkg }:
''
  # allow pip to install wheels
  unset SOURCE_DATE_EPOCH
  # ensure that we rebuild the venv when the python package changes
  VENV_DIR=".venv-${builtins.baseNameOf (builtins.toString pythonPkg)}"
  for other_venv in .venv-*; do
    if [ "$other_venv" != "$VENV_DIR" ]; then
      echo Removing unused venv: "$other_venv"
      rm -fr "$other_venv"
    fi
  done
  IS_NEW_VENV=false
  if [ ! -d "$VENV_DIR" ]; then
    echo "Creating new venv environment in path: '$VENV_DIR'"
    ${pythonPkg}/bin/python -m venv "$VENV_DIR"
    source "$VENV_DIR/bin/activate"
    IS_NEW_VENV=true
  else
    source "$VENV_DIR/bin/activate"
  fi
''