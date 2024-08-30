@echo on

set "cwd=%cd%"

set "LIBRARY_PREFIX=%LIBRARY_PREFIX:\=/%"

set "HOST=x86_64-w64-mingw32"
set "CC=%HOST%-gcc.exe"
set "CXX=%HOST%-g++.exe"
set "FC=%HOST%-gfortran.exe"

set "ESMF_F90COMPILER=%FC%"
set "ESMF_CCOMPILER=%CC%"
set "ESMF_CXXCOMPILER=%CXX%"
set "ESMF_CPP=%CC% -E -P -x c -C -nostdinc"

set "ESMF_DIR=%cd:\=/%"

bash -lc "echo 'none /tmp usertemp binary,posix=0 0 0' >>/etc/fstab"
bash -lc "mount"

set "ESMF_INSTALL_PREFIX=%LIBRARY_PREFIX%"
set "ESMF_INSTALL_BINDIR=%LIBRARY_PREFIX%/bin"
set "ESMF_INSTALL_DOCDIR=%LIBRARY_PREFIX%/doc"
set "ESMF_INSTALL_HEADERDIR=%LIBRARY_PREFIX%/include"
set "ESMF_INSTALL_LIBDIR=%LIBRARY_PREFIX%/lib"
set "ESMF_INSTALL_MODDIR=%LIBRARY_PREFIX%/mod"

set "ESMF_NETCDF=split"
set "ESMF_NETCDF_INCLUDE=%LIBRARY_PREFIX%/include"
set "ESMF_NETCDF_LIBPATH=%LIBRARY_PREFIX%/lib"

set "ESMF_CXXCOMPILECPPFLAGS=-D_USE_MATH_DEFINES"

set "ESMF_OS=MinGW"

make info

@REM make -j%CPU_COUNT%
@REM make install
@REM make check

@REM sed -i.bu "s/%BUILD_PREFIX:/=\/%/%LIBRARY_PREFIX:/=\/%/g" %LIBRARY_PREFIX%/lib/esmf.mk && rm %LIBRARY_PREFIX%/lib/esmf.mk.bu

@REM set "ACTIVATE_DIR=%PREFIX%\etc\conda\activate.d"
@REM set "DEACTIVATE_DIR=%PREFIX%\etc\conda\deactivate.d"

@REM mkdir %ACTIVATE_DIR%
@REM mkdir %DEACTIVATE_DIR%

@REM copy %RECIPE_DIR%\scripts\activate.bat %ACTIVATE_DIR%\esmf-activate.bat
@REM if errorlevel 1 exit 1

@REM copy %RECIPE_DIR%\scripts\deactivate.bat %DEACTIVATE_DIR%\esmf-deactivate.bat
@REM if errorlevel 1 exit 1