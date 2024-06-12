#!/bin/bash

set -xe

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

if [[ "$(echo $fortran_compiler_version | cut -d '.' -f 1)" -gt 9 ]]; then
  # allow argument mismatch in Fortran
  # https://github.com/esmf-org/esmf/releases/tag/ESMF_8_2_0
  # see https://trac.macports.org/ticket/60954
  export ESMF_F90COMPILEOPTS="-fallow-argument-mismatch"
fi

echo ESMF_F90COMPILEOPTS=${ESMF_F90COMPILEOPTS}

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" ]]; then
  if [[ "${target_platform}" == "linux-aarch64" ]]; then
    export ESMF_MACHINE="aarch64"
  elif [[ "${target_platform}" == "linux-ppc64le" ]]; then
    export ESMF_MACHINE="ppc64le"
  elif [[ "${target_platform}" == "arm64" ]]; then
    export ESMF_OS="arm64"
  fi
fi

echo ESMF_MACHINE=${ESMF_MACHINE}


if [[ $(uname) == Darwin ]]; then
  export ESMF_COMPILER=gfortranclang
  export ESMF_CPP="clang-cpp -P -x c"
else
  export ESMF_CPP="${CPP} -E -P -x c"
fi

if [[ -z "$mpi" || "$mpi" == "nompi" ]]; then
  export ESMF_F90=${FC}
  export ESMF_CXX=${CXX}
  export ESMF_C=${CC}
  export ESMF_F90LINKER=${FC}
  export ESMF_CXXLINKER=${CXX}
  export ESMF_CLINKER=${CC}
else
  export ESMF_F90=mpif90
  export ESMF_CXX=mpicxx
  export ESMF_C=mpicc
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

export ESMF_CLINKOPTS="$LDFLAGS"
if [[ $(uname) == Darwin ]]; then
  export LDFLAGS="-headerpad_max_install_names -Wl,-no_compact_unwind $LDFLAGS"
  export ESMF_F90LINKOPTS="$LDFLAGS -pthread -lc++"
  export ESMF_CXXLINKOPTS="$LDFLAGS -pthread"
else
  export ESMF_F90LINKOPTS="$LDFLAGS"
  export ESMF_CXXLINKOPTS="$LDFLAGS"
fi

make -j${CPU_COUNT}
if [[ ( "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ) \
          && ! ( "${target_platform}" == "linux-ppc64le" && $mpi == "mpich" ) ]]; then
make check
fi
make install

sed -i.bu "s:${BUILD_PREFIX}:${PREFIX}:g" ${PREFIX}/lib/esmf.mk && rm ${PREFIX}/lib/esmf.mk.bu

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

for shell in sh csh fish
do
  for act_deact in activate deactivate
  do
    act_deact_dir=${PREFIX}/etc/conda/${act_deact}.d
    mkdir -p ${act_deact_dir}
    cp ${RECIPE_DIR}/scripts/${act_deact}.${shell} ${act_deact_dir}/esmf-${act_deact}.${shell}
  done
done
