set "cwd=%cd%"

set "LIBRARY_PREFIX=%LIBRARY_PREFIX:\=/%"

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

mingw32-make info

mingw32-make -j%CPU_COUNT%
mingw32-make install
mingw32-make check

sed -i.bu "s/%BUILD_PREFIX:/=\/%/%LIBRARY_PREFIX:/=\/%/g" %LIBRARY_PREFIX%/lib/esmf.mk && rm %LIBRARY_PREFIX%/lib/esmf.mk.bu
