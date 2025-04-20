#!/bin/bash

> "main_data.csv"

head -n 1 processed_comma_newline.csv > main_data.csv

tail -n +2 processed_comma_newline.csv |
awk -F',' '{
    split($16, d, "/");


    # Process year
    if (d[3] + 0 > 25) {
        d[3] = "19" d[3];
    } else {
        d[3] = "20" d[3];
    }

    # Process month
    if (length(d[1]) == 1) {
        d[1] = "0" d[1];
    }

    # Process day
    if (length(d[2]) == 1) {
        d[2] = "0" d[2];
    }

    out = d[3] "/" d[1] "/" d[2];

    # Update $16 to new format YYYY/MM/DD
    $16 = out;

    # Write file again
    OFS=","; 
    for (i = 1; i <= NF; i++) {
        if (i == 16) {
            printf "%s", out;
        } else {
            printf "%s", $i;
        }
        if (i < NF) {
            printf ",";
        } else {
            printf "\n";
        }
    }

}' >> main_data.csv

