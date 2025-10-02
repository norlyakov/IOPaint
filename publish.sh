#!/usr/bin/env bash

TWINE_REPOSITORY='mountbit'

CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${CUR_DIR}"

PYTHON="${CUR_DIR}/venv/bin/python"
TWINE="${CUR_DIR}/venv/bin/twine"


echo "Build SDIST and WHEEL"
${PYTHON} setup.py -q sdist bdist_wheel
echo
echo "Check dists by Twine"
${TWINE} check dist/*
rm -rf dist build


echo "Make release"

exit_handler() {
  # Restore test files and directories
  cd "${CUR_DIR}/src/mountbit"
  git clean -fdx mountbit/*
  git restore mountbit/*
}
trap exit_handler EXIT

rm -rf dist build
# Delete all tests before build a wheel
find mountbit -type d -name "tests" -exec rm -rf {} +
find mountbit -type f \( -name "test_*.py" -o -name "tests.py" \) -delete
${PYTHON} setup.py bdist_wheel

TWINE_REPOSITORY=${TWINE_REPOSITORY} ${TWINE} upload dist/*
rm -rf dist build

cd "${CUR_DIR}"
echo OK
