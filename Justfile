# Pull updates for all submodules
update-submodules:
  git submodule foreach --recursive git pull origin $(git rev-parse --abbrev-ref HEAD)

# Init all submodules
init-submodules:
  git submodule update --init --recursive
