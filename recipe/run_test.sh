#!/usr/bin/env bash

set -xe

cp -r ${RECIPE_DIR}/test_data .

if [[ "$mpi" == "nompi" ]]; then
  MPI_CMD=""
else
  MPI_CMD="mpirun -np 2"
fi

# ** Unstructured mesh to lat/lon grid tests
SRC_TYPES=( "esmf" "scrip" "esmf" )
DST_TYPES=( "scrip" "scrip" "esmf" )

for i in "${!SRC_TYPES[@]}"
do
  SRC_TYPE=""${SRC_TYPES[i]}""
  DST_TYPE=""${DST_TYPES[i]}""
  for METHOD in bilinear conserve
  do
    ${MPI_CMD} ${PREFIX}/bin/ESMF_RegridWeightGen \
        --source test_data/unstructured_QU1920_${SRC_TYPE}.nc \
        --destination test_data/lat_lon_5.0x5.0degree_${DST_TYPE}.nc \
        --weight map_QU1920_${SRC_TYPE}_to_5.0x5.0degree_${DST_TYPE}_${METHOD}.nc \
        --method ${METHOD} \
        --src_loc center \
        --dst_loc center \
        --src_regional \
        --ignore_unmapped || cat PET*.Log
  done
done

# ** Lat/lon grid to unstructured mesh tests
SRC_TYPES=( "scrip" "scrip" "esmf" )
DST_TYPES=( "esmf" "scrip" "esmf" )

for i in "${!SRC_TYPES[@]}"
do
  SRC_TYPE=""${SRC_TYPES[i]}""
  DST_TYPE=""${DST_TYPES[i]}""
  for METHOD in bilinear conserve
  do
    ${MPI_CMD} ${PREFIX}/bin/ESMF_RegridWeightGen \
        --source test_data/lat_lon_5.0x5.0degree_${DST_TYPE}.nc \
        --destination test_data/unstructured_QU1920_${SRC_TYPE}.nc \
        --weight map_5.0x5.0degree_${SRC_TYPE}_to_QU1920_${DST_TYPE}_${METHOD}.nc \
        --method ${METHOD} \
        --src_loc center \
        --dst_loc center \
        --dst_regional \
        --ignore_unmapped || cat PET*.Log
  done
done
