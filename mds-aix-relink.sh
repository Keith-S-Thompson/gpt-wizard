#!/bin/sh

# $Id: mds-aix-relink.sh,v 1.6 2002-12-07 02:26:33-08 kst Exp $
# $Source: /home/kst/CVS_smov/tools/gpt-wizard/mds-aix-relink.sh,v $

#
# Based on Ben Clifford <benc@isi.edu>'s fixup script,
# <http://www.isi.edu/~benc/AIX/mds-aix-relink-2002-10-28.sh>,
# with modifications by Keith Thompson <kst@sdsc.edu>.
#

# ----------------------------------------------------------------------
Usage() {
    echo "$*" 1>&2
    cat <<EOF 1>&2
Usage: $0 option
    -builddir DIR       Build directory.
                        Mandatory.
    -compiler COMPILER  C compiler, generally "cc" or "gcc"
    -flavor FLAVOR      Specify flavor.
			If not specified, we attempt to infer it.
    -help               Show this message and exit.
EOF
    exit 1
} # Usage

# ----------------------------------------------------------------------

Die() {
    echo "$*" 1>&2
    exit 1
} # Die

# ----------------------------------------------------------------------

build_dir=""
compiler=""
flavor=""

while [ "$#" -ne 0 ]; do
    case "$1" in

        -builddir)
            if [ -n "$2" ] ; then
                if [ -n "$build_dir" ] ; then
                    Usage "Error: -builddir specified twice"
                else
                    build_dir="$2"
		    shift
                fi
            else
                Usage "Error: -builddir requires an argument"
            fi
            ;;

        -compiler)
            if [ -n "$2" ] ; then
                if [ -n "$compiler" ] ; then
                    Usage "Error: -compiler specified twice"
                else
                    compiler="$2"
		    shift
                fi
            else
                Usage "Error: -compiler requires an argument"
            fi
            ;;

        -flavor)
            if [ -n "$2" ] ; then
                if [ -n "$flavor" ] ; then
                    Usage "Error: -flavor specified twice"
                else
                    flavor="$2"
		    shift
                fi
            else
                Usage "Error: -flavor requires an argument"
            fi
            ;;

        -help)
            Usage
            ;;
    esac

    shift
done

if [ -z "$build_dir" ] ; then
    Usage "-builddir not specified"
fi

if [ -z "$flavor" ] ; then
    flavor="`ls $GLOBUS_LOCATION/libexec/openldap`"
    if [ `echo $flavor | wc -l` -ne 1 ] ; then
	Die "Can't determine flavor from $GLOBUS_LOCATION/libexec/openldap"
    fi
fi

if [ -z "$compiler" ] ; then
    Usage "-compiler not specified"
fi

globus_mds_back_giis_dir=`ls -d ${BUILD_DIR}/globus_mds_back_giis* | grep -v '\.tar\.gz'`
echo "... cd $globus_mds_back_giis_dir"
cd $globus_mds_back_giis_dir || Die "cd failed"
ld -o libback_giis.so.0 \
    ../globus_openssl_module-*/library/*.o \
    ../globus_gsi_openssl_error-*/library/*.o \
    ../globus_gsi_proxy_ssl-*/library/*.o \
    ../globus_gsi_sysconfig-*/library/*.o \
    ../globus_common-*/library/*.o \
    ../globus_gss_assist-*/*.o \
    *.o \
    ../globus_gsi_credential-*/library/*.o \
    ../globus_gssapi_gsi-*/library/*.o \
    ../globus_gsi_proxy_core-*/library/*.o \
    -bnoentry \
    -G \
    -bexpall \
    -bM:SRE \
    -lc \
    -ldl || Die "ld failed"
echo "... cp libback_giis.so.0 $GLOBUS_LOCATION/libexec/openldap/$flavor/."
cp libback_giis.so.0 $GLOBUS_LOCATION/libexec/openldap/$flavor/. || Die "cp failed"

globus_ldapmodules_dir=`ls -d ${BUILD_DIR}/globus_ldapmodules* | grep -v '\.tar\.gz'`
echo "... cd $globus_ldapmodules_dir"
cd $globus_ldapmodules_dir || Die "cd failed for globus_ldapmodules_dir"
ld -o libback_ldif.so.0 \
    ../globus_gss_assist-*/*.o \
    *.o \
    ../globus_gsi_callback-*/library/oldgaa/*.o \
    ../globus_gsi_proxy_core-*/library/*.o \
    ../globus_gsi_callback-*/library/*.o \
    ../globus_gsi_cert_utils-*/library/*.o \
    ../globus_gssapi_gsi-*/library/*.o \
    -bnoentry \
    -G \
    -bexpall \
    -bM:SRE \
    -lc \
    -ldl || Die "ld failed"
echo "... cp libback_ldif.so.0 $GLOBUS_LOCATION/libexec/openldap/$flavor/."
cp libback_ldif.so.0 $GLOBUS_LOCATION/libexec/openldap/$flavor/. || Die "cp failed"

echo "... cd $GLOBUS_LOCATION/libexec/openldap/$flavor"
cd $GLOBUS_LOCATION/libexec/openldap/$flavor || Die "cd failed"
echo "... ln -sf libback_giis.so.0 libback_giis.so"
ln -sf libback_giis.so.0 libback_giis.so || Die "ln failed"
echo "... ln -sf libback_ldif.so.0 libback_ldif.so"
ln -sf libback_ldif.so.0 libback_ldif.so || Die "ln failed"

echo "Creating $GLOBUS_LOCATION/libexec/openldap/$flavor/libback_giis.la"
cat > $GLOBUS_LOCATION/libexec/openldap/$flavor/libback_giis.la << EOF


# libback_giis.la - a libtool library file
# Generated by ltmain.sh - GNU libtool 1.3.5 (1.385.2.206 2000/05/27 11:12:27)
#
# Please DO NOT delete this file!
# It is necessary for linking the library.

# The name that we can dlopen(3).
dlname='libback_giis.so.0'

# Names of this library.
library_names=''

# The name of the static archive.
old_library=''

# Libraries that this one depends upon.
dependency_libs=' -L$GLOBUS_LOCATION/lib -lglobus_common_$flavor -lglobus_gss_assist_$flavor -lldap_$flavor -llber_$flavor -lglobus_gssapi_gsi_$flavor -lsasl_$flavor -lglobus_ssl_utils_$flavor -lltdl_$flavor -lssl_$flavor -lcrypto_$flavor'

# Version information for libback_giis.
current=0
age=0
revision=0

# Is this an already installed library?
installed=yes

# Directory that this library needs to be installed in:
libdir='$GLOBUS_LOCATION/libexec/openldap/$flavor'

EOF


echo "Creating $GLOBUS_LOCATION/libexec/openldap/$flavor/libback_ldif.la"
cat > $GLOBUS_LOCATION/libexec/openldap/$flavor/libback_ldif.la << EOF


# libback_ldif.la - a libtool library file
# Generated by ltmain.sh - GNU libtool 1.3.5 (1.385.2.206 2000/05/27 11:12:27)
#
# Please DO NOT delete this file!
# It is necessary for linking the library.

# The name that we can dlopen(3).
B
dlname='libback_ldif.so.0'

# Names of this library.
library_names=''

# The name of the static archive.
old_library=''

# Libraries that this one depends upon.
dependency_libs=' -L$GLOBUS_LOCATION/lib -lglobus_gss_assist_$flavor -lldap_$flavor -llber_$flavor -lglobus_gssapi_gsi_$flavor -lsasl_$flavor -lglobus_ssl_utils_$flavor -lltdl_$flavor -lssl_$flavor -lcrypto_$flavor'

# Version information for libback_ldif.
current=0
age=0
revision=0

# Is this an already installed library?
installed=yes

# Directory that this library needs to be installed in:
libdir='$GLOBUS_LOCATION/libexec/openldap/$flavor'
EOF

echo "... cd ${BUILD_DIR}/globus_openldap-*/openldap-*/servers/slapd"
cd ${BUILD_DIR}/globus_openldap-*/openldap-*/servers/slapd || Die "cd failed"

echo "Creating slapd"
$compiler *.o \
    -brtl \
    -bexpall \
    libbackends.a \
    -L$GLOBUS_LOCATION/lib \
    -L../../libraries \
    -lavl \
    -lldif \
    -lldbm \
    -llutil_$flavor \
    -lldap_r_$flavor \
    -llber_$flavor \
    -lsasl_$flavor \
    -lssl_$flavor \
    -lcrypto_$flavor \
    -ls \
    -lltdl_$flavor \
    -lpthread \
    -o slapd \
    $GLOBUS_LOCATION/libexec/openldap/$flavor/libback_ldif.so \
    $GLOBUS_LOCATION/libexec/openldap/$flavor/libback_giis.so || Die "$compiler failed"

echo "... cp slapd $GLOBUS_LOCATION/libexec/."
cp slapd $GLOBUS_LOCATION/libexec/. || Die "cp failed"
