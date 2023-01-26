set "cwd=%cd%"

set "LIBRARY_PREFIX=%LIBRARY_PREFIX:\=/%"
set "MINGWBIN=%LIBRARY_PREFIX%/mingw-w64/bin"

:: These flags cause errors during CMake; disable for now?
set "LDFLAGS=-L%LIBRARY_PREFIX%/lib -Wl,-rpath,%LIBRARY_PREFIX%/lib"
::            Left out: -lcurl -lhdf5 -lhdf5_hl -ldf -lmfhdf
set "CFLAGS=-fPIC -I%LIBRARY_PREFIX%/include"
:: PENDING -> PARALLEL MPI STUFF
:: set PARALLEL=""

set "ESMF_DIR=%cd%"

set "ESMF_INSTALL_PREFIX=%LIBRARY_PREFIX%"
set "ESMF_INSTALL_BINDIR=%LIBRARY_PREFIX%/bin"
set "ESMF_INSTALL_DOCDIR=%LIBRARY_PREFIX%/doc"
set "ESMF_INSTALL_HEADERDIR=%LIBRARY_PREFIX%/include"
set "ESMF_INSTALL_LIBDIR=%LIBRARY_PREFIX%/lib"
set "ESMF_INSTALL_MODDIR=%LIBRARY_PREFIX%/mod"

set "ESMF_NETCDF=split"
set "ESMF_NETCDF_INCLUDE=%LIBRARY_PREFIX%/include"
set "ESMF_NETCDF_LIBPATH=%LIBRARY_PREFIX%/lib"


rem if [[ "$(echo $fortran_compiler_version | cut -d '.' -f 1)" -gt 9 ]]; then
rem   # allow argument mismatch in Fortran
rem   # https://github.com/esmf-org/esmf/releases/tag/ESMF_8_2_0
rem   # see https://trac.macports.org/ticket/60954
rem   set "ESMF_F90COMPILEOPTS="-fallow-argument-mismatch""
rem fi

:: echo ESMF_F90COMPILEOPTS=${ESMF_F90COMPILEOPTS}

set "ESMF_CPP=%MINGWBIN%/cpp.exe -E -P -x c"

set "ESMF_F90=%MINGWBIN%/gfortran.exe"
set "ESMF_CXX=%MINGWBIN%/g++.exe"

set "ESMF_COMM=mpiuni"

mingw32-make -j%CPU_COUNT%
mingw32-make install
mingw32-make check

sed -i.bu "s:%BUILD_PREFIX%:%LIBRARY_PREFIX%:g" %LIBRARY_PREFIX%/lib/esmf.mk && rm %LIBRARY_PREFIX%/lib/esmf.mk.bu
