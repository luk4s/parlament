#!/bin/bash -l
set -e

install() {
  bundle exec rails db:migrate RAILS_ENV=production
}
sidekiq() {
  bundle exec sidekiq -e "${RAILS_ENV}"
}
server() {
  bundle exec puma -e "${RAILS_ENV}" -p 3000
}
case "$1" in
"bash")
  bash -l
  ;;
"rails")
  bundle exec rails "$2"
  ;;
"install")
  install
  ;;
"server")
  server
  ;;
"sidekiq")
  sidekiq
  ;;
"start")
  install && server
  ;;
*)
  cat <<EOF
  Unknown action. Possible actions are:
   * bash
   * rails <subcommand>
   * test
   * install
   * server
   * sidekiq
   * start (alias for install & server)
EOF
  exit 1
  ;;
esac
