#!/bin/sh
# usage:
# eclipse.sh [args]    -- launches eclipse using specified command line args
# eclipse.sh           -- launches Eclipse with default command line args

PYTHON_INSTALL=
JAVA_INSTALL=
ANT_INSTALL=
ECLIPSE_INSTALL=
CAVE_INSTALL=

INSTALL_LOCATION=`rpm -q --queryformat '%{INSTALLPREFIX}\n' awips2-python`
RC="$?"
if [ ! "${RC}" = "0" ]; then
   echo "ERROR: awips2-python Is Not Installed."
   echo "Unable To Continue ... Terminating"
   exit 1
fi
PYTHON_INSTALL=${INSTALL_LOCATION}

IS_INSTALLED=`rpm -q --queryformat '%{NAME}\n' awips2-java`
RC="$?"
if [ ! "${RC}" = "0" ]; then
   echo "ERROR: awips2-java Is Not Installed."
   echo "Unable To Continue ... Terminating"
   exit 1
fi
JAVA_INSTALL=/awips2/java

INSTALL_LOCATION=`rpm -q --queryformat '%{INSTALLPREFIX}\n' awips2-ant`
RC="$?"
if [ ! "${RC}" = "0" ]; then
   echo "ERROR: awips2-ant Is Not Installed."
   echo "Unable To Continue ... Terminating"
   exit 1
fi
ANT_INSTALL=${INSTALL_LOCATION}
ECLIPSE_INSTALL=`rpm -q --queryformat '%{INSTALLPREFIX}\n' awips2-eclipse`

# grab the CL argument; if none set a reasonable default
if [ $# -ne 0 ]; then
   # there are arguments, convert them into a string
   args=${1}
   shift 1
   for a in $@; do
      args="${args} ${a}"
   done
else
   # set a reasonable default for performance
   args='-clean -vmargs -Xms512m -Xmx1024m -XX:MaxPermSize=256m'
fi

# setup environment variables
export JAVA_HOME=${JAVA_INSTALL}
export ANT_HOME=${ANT_INSTALL}

# set LD_PRELOAD
export LD_PRELOAD=${PYTHON_INSTALL}/lib/libpython2.7.so

# update path type variables
export LD_LIBRARY_PATH=${PYTHON_INSTALL}/lib:$LD_LIBRARY_PATH
export PATH=${ECLIPSE_INSTALL}:${PYTHON_INSTALL}/bin:${JAVA_INSTALL}/bin:${ANT_INSTALL}/bin:$PATH

# determine if cave has been installed for TMCP_HOME
INSTALL_LOCATION=`rpm -q --queryformat '%{INSTALLPREFIX}\n' awips2-cave`
RC="$?"
if [ "${RC}" = "0" ]; then
   CAVE_INSTALL="${INSTALL_LOCATION}"
   export TMCP_HOME=${CAVE_INSTALL}/caveEnvironment
else
   echo "WARNING: awips2-cave is not installed; so, TMCP_HOME will not be set."
fi

umask 02

ant -Dinstall.dir=/awips2/edex -Dupdate.python=false -Dmcast.port=61000 -f deploy-install.xml deploy.all

echo ""
echo "JAVA_HOME=${JAVA_HOME}"
exit 0

# more stuff
