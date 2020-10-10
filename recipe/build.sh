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

if [[ $(uname) == Darwin ]]; then
  export ESMF_CPP="clang-cpp -P -x c"
else
  export ESMF_CPP="${CPP} -E -P -x c"
fi

if [[ -z "$mpi" || "$mpi" == "nompi" ]]; then
  export ESMF_F90=${FC}
  export ESMF_CXX=${CXX}
else
  export ESMF_F90=mpif90
  export ESMF_CXX=mpicxx
fi

if [[ $mpi == 'mpich' ]]; then
  export ESMF_COMM=mpich3
elif [[ $mpi == 'openmpi' ]]; then
  export ESMF_COMM=openmpi
  export ESMF_MPIRUN="mpirun --oversubscribe"
elif [[ $mpi == 'nompi' ]]; then
  export ESMF_COMM=mpiuni
fi

if [[ $(uname) == Darwin ]]; then
  export LDFLAGS="-headerpad_max_install_names $LDFLAGS"
  export ESMF_F90LINKOPTS="$LDFLAGS -pthread"
  export ESMF_CXXLINKOPTS="$LDFLAGS -pthread"
fi

make -j${CPU_COUNT}
make check
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
