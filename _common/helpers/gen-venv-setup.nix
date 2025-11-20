{ pythonPkg, pkgs }:
''
  # allow pip to install wheels
  unset SOURCE_DATE_EPOCH
  # ensure that we rebuild the venv when the python package changes
  VENV_DIR=".venv-${builtins.baseNameOf (builtins.toString pythonPkg)}-3"
  for other_venv in .venv-*; do
    if [ "$other_venv" != "$VENV_DIR" ]; then
      echo Removing unused venv: "$other_venv"
      rm -fr "$other_venv"
    fi
  done
  IS_NEW_VENV=false
  if [ ! -d "$VENV_DIR" ]; then
    echo "Creating new venv environment in path: '$VENV_DIR'"
    ${pythonPkg}/bin/python -m venv "$VENV_DIR" --system-site-packages
    export PYTHONHOME=${pythonPkg}/bin
    # point home in pyvenv.cfg to the correct site packages (venv module bug?)
    ${pkgs.gawk}/bin/gawk -i inplace \
      '{sub(/(home = ).+/, "home = " ENVIRON["PYTHONHOME"])}1' \
      "$VENV_DIR/pyvenv.cfg"
    source "$VENV_DIR/bin/activate"
    IS_NEW_VENV=true
  else
    source "$VENV_DIR/bin/activate"
  fi
''