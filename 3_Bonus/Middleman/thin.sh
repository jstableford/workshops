# /etc/init.d/thin

#!/bin/sh
### BEGIN INIT INFO
# Provides:          thin
# Required-Start:    $local_fs $remote_fs
# Required-Stop:     $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      S 0 1 6
# Short-Description: thin initscript
# Description:       thin
### END INIT INFO

# Original author: Forrest Robertson

# Do NOT "set -e"

DAEMON=/usr/local/bin/thin
SCRIPT_NAME=/etc/init.d/thin
CONFIG_PATH=/etc/thin
HOME=<%= @home_directory %>

# Exit if the package is not installed
[ -x "$DAEMON" ] || exit 0

case "$1" in
  start)
  HOME=$HOME $DAEMON start --all $CONFIG_PATH
  ;;
  stop)
  HOME=$HOME $DAEMON stop --all $CONFIG_PATH
  ;;
  restart)
  HOME=$HOME $DAEMON restart --all $CONFIG_PATH
  ;;
  *)
  echo "Usage: $SCRIPT_NAME {start|stop|restart}" >&2
  exit 3
  ;;
esac

: