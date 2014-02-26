#!/bin/bash

################################################################################
# Simple Nagios plugin to monitor nova instance creation                       #
# Author: Daniel Shirley                                                       #
################################################################################

VERSION="Version 0.10a"
AUTHOR="2014 Daniel Shirley (daniel.l.shirley@hp.com)"
PROGNAME=`/bin/basename $0`

# Exit codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

# File Includes ################################################################

. enviroment.conf

# Helper functions #############################################################

function print_revision {
   # Print the revision number
   echo "$PROGNAME - $VERSION"
}

function print_usage {
   # Print a short usage statement
   echo "Usage: $PROGNAME [-v] -w <limit> -c <limit>"
}

function print_help {
   # Print detailed help information
   print_revision
   echo "$AUTHOR"
   echo "Check if NOVA will create an instance"
   echo "Requires enviroment verables set in enviroment.conf and python-novaclient installed"
   echo "you can install this by typeing -- pip install python-novaclient"
   
   print_usage

   /bin/cat <<__EOT

Options:
-h
   Print detailed help screen
-V
   Print version information

-w INTEGER
   Exit with WARNING status if instance creation takes longer than (min)
-c INTEGER
   Exit with CRITICAL status if instance creation takes longer than (min)
-v
   Verbose output
__EOT
}

# Verbosity level
verbosity=0
# Warning threshold
thresh_warn=
# Critical threshold
thresh_crit=

# Parse command line options
while [ "$1" ]; do
   case "$1" in
       -h | --help)
           print_help
           exit $STATE_OK
           ;;
       -V | --version)
           print_revision
           exit $STATE_OK
           ;;
       -v | --verbose)
           : $(( verbosity++ ))
           shift
           ;;
       -w | --warning | -c | --critical)
           if [[ -z "$2" || "$2" = -* ]]; then
               # Threshold not provided
               echo "$PROGNAME: Option '$1' requires an argument"
               print_usage
               exit $STATE_UNKNOWN
           elif [[ "$2" = +([0-9]) ]]; then
               # Threshold is a number (MB)
               thresh=$2
           else
               # Threshold is neither a number nor a percentage
               echo "$PROGNAME: Threshold must be integer or percentage"
               print_usage
               exit $STATE_UNKNOWN
           fi
           [[ "$1" = *-w* ]] && thresh_warn=$thresh || thresh_crit=$thresh
           shift 2
           ;;
       -?)
           print_usage
           exit $STATE_OK
           ;;
       *)
           echo "$PROGNAME: Invalid option '$1'"
           print_usage
           exit $STATE_UNKNOWN
           ;;
   esac
done


if [[ -z "$thresh_warn" || -z "$thresh_crit" ]]; then
   # One or both thresholds were not specified
   echo "$PROGNAME: Threshold not set"
   print_usage
   exit $STATE_UNKNOWN
elif [[ "$thresh_crit" -lt "$thresh_warn" ]]; then
   # The warning threshold must be less than the critical threshold
   echo "$PROGNAME: Warning creation time should be less than critical creation time"
   print_usage
   exit $STATE_UNKNOWN
fi

# Main #########################################################################













# Verbosity settings ###########################################################
if [[ "$verbosity" -ge 2 ]]; then
   # Print debugging information
   /bin/cat <<__EOT
Debugging information:
  Warning threshold: $thresh_warn MIN
  Critical threshold: $thresh_crit MIN
  Verbosity level: $verbosity
  Completed Time: $time
  NOVA Output: $nova_output
__EOT
fi


