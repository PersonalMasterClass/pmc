CWD="$(pwd)"
cd "$(git rev-parse --show-toplevel)" &&
docker build -t pmc . &&
cd "${CWD}"
