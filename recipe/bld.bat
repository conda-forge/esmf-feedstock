set "cwd=%cd%"

rem set "LIBRARY_PREFIX=%LIBRARY_PREFIX:\=/%"
rem set "MINGWBIN=%LIBRARY_PREFIX%/mingw-w64/bin"

rem :: These flags cause errors during CMake; disable for now?
rem set "LDFLAGS=-L%LIBRARY_PREFIX%/lib -Wl,-rpath,%LIBRARY_PREFIX%/lib"
rem ::            Left out: -lcurl -lhdf5 -lhdf5_hl -ldf -lmfhdf
rem set "CFLAGS=-fPIC -I%LIBRARY_PREFIX%/include"
rem :: PENDING -> PARALLEL MPI STUFF
rem :: set PARALLEL=""

set "ESMF_DIR=%cd%"

rem set "ESMF_INSTALL_PREFIX=%LIBRARY_PREFIX%"
rem set "ESMF_INSTALL_BINDIR=%LIBRARY_PREFIX%/bin"
rem set "ESMF_INSTALL_DOCDIR=%LIBRARY_PREFIX%/doc"
rem set "ESMF_INSTALL_HEADERDIR=%LIBRARY_PREFIX%/include"
rem set "ESMF_INSTALL_LIBDIR=%LIBRARY_PREFIX%/lib"
rem set "ESMF_INSTALL_MODDIR=%LIBRARY_PREFIX%/mod"

rem set "ESMF_NETCDF=split"
rem set "ESMF_NETCDF_INCLUDE=%LIBRARY_PREFIX%/include"
rem set "ESMF_NETCDF_LIBPATH=%LIBRARY_PREFIX%/lib"


rem if [[ "$(echo $fortran_compiler_version | cut -d '.' -f 1)" -gt 9 ]]; then
rem   # allow argument mismatch in Fortran
rem   # https://github.com/esmf-org/esmf/releases/tag/ESMF_8_2_0
rem   # see https://trac.macports.org/ticket/60954
rem   set "ESMF_F90COMPILEOPTS="-fallow-argument-mismatch""
rem fi

:: echo ESMF_F90COMPILEOPTS=${ESMF_F90COMPILEOPTS}

rem set "ESMF_CPP=%MINGWBIN%/cpp.exe -E -P -x c"

rem set "ESMF_F90=%MINGWBIN%/gfortran.exe"
rem set "ESMF_CXX=%MINGWBIN%/g++.exe"


set "ESMF_OS=MinGW"

mingw32-make info

mingw32-make -j%CPU_COUNT%
mingw32-make install
mingw32-make check

sed -i.bu "s:%BUILD_PREFIX%:%LIBRARY_PREFIX%:g" %LIBRARY_PREFIX%/lib/esmf.mk && rm %LIBRARY_PREFIX%/lib/esmf.mk.bu
