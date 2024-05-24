#!/bin/bash

printf "matrix={\"include\":[" > ./matrix_file.txt
for ((i=0; i<REPEAT; i++)); do printf "{\"project\":\"config.json\"}," >> ./matrix_file.txt; done
printf "]}" >> ./matrix_file.txt