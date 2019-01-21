#!/bin/bash

export ESMF_DIR=$(pwd)

export ESMF_INSTALL_PREFIX=${PREFIX}
export ESMF_INSTALL_BINDIR=${PREFIX}/bin
export ESMF_INSTALL_DOCDIR=${PREFIX}/doc
export ESMF_INSTALL_HEADERDIR=${PREFIX}/include
export ESMF_INSTALL_LIBDIR=${PREFIX}/lib
export ESMF_INSTALL_MODDIR=${PREFIX}/mod

export ESMF_NETCDF="split"
export ESMF_NETCDF_INCLUDE=${PREFIX}/include
export ESMF_NETCDF_LIBPATH=${PREFIX}/lib

export ESMF_COMM=mpich3

if [[ $(uname) == Darwin ]]; then
  export LDFLAGS="-headerpad_max_install_names $LDFLAGS"
fi

#their build tool is dumb
if [[ $(uname) == Linux ]]; then
  ln -s "${CC}" "${BUILD_PREFIX}/bin/gcc"
  ln -s "${FC}" "${BUILD_PREFIX}/bin/gfortran"
fi

make -j${CPU_COUNT}
# make check -j${CPU_COUNT}
make install

if [[ $(uname) == Darwin ]]; then
  ESMF_ORIGINAL_LIB_PATH=$(find $(pwd) -type f -name "libesmf.dylib")
  ESMF_LIB_PATH=${PREFIX}/lib/libesmf.dylib

  APPS=( ESMF_Info ESMF_RegridWeightGen ESMF_Regrid ESMF_Scrip2Unstruct )
  for APP in "${APPS[@]}"; do
    ESMF_APP_PATH=$PREFIX/bin/$APP
    install_name_tool -change $ESMF_ORIGINAL_LIB_PATH $ESMF_LIB_PATH ${ESMF_APP_PATH}
  done
fi
