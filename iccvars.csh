#
# Copyright  (C) 1985-2016 Intel Corporation. All rights reserved.
#
# The information and source code contained herein is the exclusive property
# of Intel Corporation and may not be disclosed, examined, or reproduced in
# whole or in part without explicit written authorization from the Company.
#

#!/bin/csh

set PROD_DIR="/vol/matlab/intel/parallel_studio_xe_2017.0.035/compilers_and_libraries_2017/linux"

set INTEL_TARGET_ARCH
set INTEL_TARGET_PLATFORM=linux

if ( -e "$PROD_DIR/bin/intel64/icl_fbsd.cfg" ) then
  set INTEL_TARGET_ARCH=intel64
  set INTEL_TARGET_PLATFORM=freebsd
endif

set COMPILERVARS_ARGV=$#argv
if ( $#argv == 0 ) then
  if ($?COMPILERVARS_ARCHITECTURE) then
    set INTEL_TARGET_ARCH=$COMPILERVARS_ARCHITECTURE
  endif
  if ($?COMPILERVARS_PLATFORM) then
    set INTEL_TARGET_PLATFORM=$COMPILERVARS_PLATFORM
  endif
endif

while ( $#argv != 0 ) 
switch ( $argv[1] )
case "-arch" :
  shift
  set INTEL_TARGET_ARCH="$1"
  shift
  breaksw 
case "-platform" :
    shift
    set INTEL_TARGET_PLATFORM="$1"
    shift
    breaksw 
default :
  set INTEL_TARGET_ARCH="$1"
  shift
  breaksw
endsw
end

if ( ( ! -e "$PROD_DIR/bin/intel64/icl_fbsd.cfg" ) && \
     ( "$INTEL_TARGET_ARCH" != "ia32" && "$INTEL_TARGET_ARCH" != "intel64" || \
       "$INTEL_TARGET_PLATFORM" != "android" && "$INTEL_TARGET_PLATFORM" != "linux" && "$INTEL_TARGET_PLATFORM" != "mac" ) ) then

  echo "compilervars.csh [-arch] <arch> [-platform <platform>]"
  echo ""
  echo "  <arch> must be one of the following:"
  echo "      ia32           : Set up for IA-32 target."
  echo "      intel64        : Set up for Intel(R)64 target."
  echo "  <platform> must be of the following:"
  if ( "`uname`" == "Darwin" ) then
    echo "      linux          : Set to Linux* target."
    echo "      mac            : Set to OS X* target.(default)"
  else
    echo "      android        : Set to Android* target."
    echo "      linux          : Set to Linux* target.(default)"
  endif
  echo ""
  echo "If the arguments to the sourced script are ignored (consult docs"
  echo "for your shell) the alternative way to specify target is environment"
  echo "variables COMPILERVARS_ARCHITECTURE to pass <arch> to the script"
  echo "and COMPILERVARS_PLATFORM to pass <platform>"

  exit 1
else if ( ( -e "$PROD_DIR/bin/intel64/icl_fbsd.cfg" ) && \
          ( "$INTEL_TARGET_ARCH" != "intel64" || \
        "$INTEL_TARGET_PLATFORM" != "freebsd" ) ) then
  echo "compilervars.csh [-arch <arch>] [-platform <platform>]"
  echo ""
  echo "  <arch> must be one of the following:"
  echo "      intel64        : Set up for Intel(R)64 target."
  echo "  <platform> must be of the following:"
  echo "      freebsd        : Set to FreeBSD* target."
  echo ""
  echo "If the arguments to the sourced script are ignored (consult docs"
  echo "for your shell) the alternative way to specify target is environment"
  echo "variables COMPILERVARS_ARCHITECTURE to pass <arch> to the script"
  echo "and COMPILERVARS_PLATFORM to pass <platform>"

  exit 1
endif

if ( "$INTEL_TARGET_PLATFORM" == "mac" ) then
  set INTEL_TARGET_PLATFORM="linux"
endif

if ( $COMPILERVARS_ARGV == 0 ) then
  #pass default values via COMPILERVARS_*
  if ( ! $?COMPILERVARS_ARCHITECTURE ) then
    set COMPILERVARS_ARCHITECTURE="$INTEL_TARGET_ARCH"
  endif
  if ( ! $?COMPILERVARS_PLATFORM ) then
    set COMPILERVARS_PLATFORM="$INTEL_TARGET_PLATFORM"
  endif
  set INTEL_TARGET_ARCH
  set INTEL_TARGET_PLATFORM
endif

if ( -e "$PROD_DIR/daal/bin/daalvars.csh" ) then
   source "$PROD_DIR/daal/bin/daalvars.csh" $INTEL_TARGET_ARCH;
endif 
if ( -e "$PROD_DIR/../../debugger_2017/bin/debuggervars.csh" ) then
  source "$PROD_DIR/../../debugger_2017/bin/debuggervars.csh" $INTEL_TARGET_ARCH;
endif 
if ( -e "$PROD_DIR/tbb/bin/tbbvars.csh" ) then
   source "$PROD_DIR/tbb/bin/tbbvars.csh" $INTEL_TARGET_ARCH $INTEL_TARGET_PLATFORM;
endif 
if ( -e "$PROD_DIR/mkl/bin/mklvars.csh" ) then
  source "$PROD_DIR/mkl/bin/mklvars.csh" $INTEL_TARGET_ARCH;
endif 
if ( -e "$PROD_DIR/ipp/bin/ippvars.csh" ) then
  source "$PROD_DIR/ipp/bin/ippvars.csh" $INTEL_TARGET_ARCH $INTEL_TARGET_PLATFORM;
endif
if ( -e "$PROD_DIR/mpi/intel64/bin/mpivars.csh" ) then
  if ( $COMPILERVARS_ARGV == 0 ) then
    if ( "$COMPILERVARS_ARCHITECTURE" == "intel64" ) then
      source "$PROD_DIR/mpi/intel64/bin/mpivars.csh";
    endif
  else if ( "$INTEL_TARGET_ARCH" == "intel64" ) then
    source "$PROD_DIR/mpi/intel64/bin/mpivars.csh";
  endif
endif
if ( -e "$PROD_DIR/pkg_bin/compilervars_arch.csh" ) then
   source "$PROD_DIR/pkg_bin/compilervars_arch.csh" $INTEL_TARGET_ARCH $INTEL_TARGET_PLATFORM;
endif 
