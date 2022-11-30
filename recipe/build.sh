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

if [[ "$mpi" != "nompi" ]]; then
  export ESMF_PIO="external"
  export ESMF_PIO_INCLUDE=${PREFIX}/include
  export ESMF_PIO_LIBPATH=${PREFIX}/lib
fi

# TODO: update once osx-64 gets gfortran>=10
if [[ "$(echo $fortran_compiler_version | cut -d '.' -f 1)" -gt 9 ]]; then
  # allow argument mismatch in Fortran
  # https://github.com/esmf-org/esmf/releases/tag/ESMF_8_2_0
  # see https://trac.macports.org/ticket/60954
  export ESMF_F90COMPILEOPTS="-fallow-argument-mismatch"
fi

echo ESMF_F90COMPILEOPTS=${ESMF_F90COMPILEOPTS}

if [[ $(uname) == Darwin ]]; then
  export ESMF_COMPILER=gfortranclang
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
  # for cross compiling using openmpi
  export OPAL_PREFIX=$PREFIX
elif [[ $mpi == 'nompi' ]]; then
  export ESMF_COMM=mpiuni
fi

if [[ $(uname) == Darwin ]]; then
  export LDFLAGS="-headerpad_max_install_names -Wl,-no_compact_unwind $LDFLAGS"
  export ESMF_F90LINKOPTS="$LDFLAGS -pthread -lc++"
  export ESMF_CXXLINKOPTS="$LDFLAGS -pthread"
fi

make -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
make check
fi
make install

if [[ $(uname) == Darwin ]]; then
  ESMF_ORIGINAL_LIB_PATH=$(find $(pwd) -type f -name "libesmf.dylib")
  ESMF_LIB_PATH=${PREFIX}/lib/libesmf.dylib

  APPS=( ESMF_PrintInfo ESMF_PrintInfoC ESMF_RegridWeightGen ESMF_Regrid \
	 ESMF_Scrip2Unstruct ESMF_WebServController )
  for APP in "${APPS[@]}"; do
    ESMF_APP_PATH=$PREFIX/bin/$APP
    install_name_tool -change $ESMF_ORIGINAL_LIB_PATH $ESMF_LIB_PATH ${ESMF_APP_PATH}
  done
fi
