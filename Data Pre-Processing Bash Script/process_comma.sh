#!/bin/bash 

>"processed_comma_newline.csv"

awk '{
	in_quotation_mark=0;
	out="";
	
	for(i=1; i<= length($0); i++){
		char = substr($0, i, 1);
		if (char == "\"") {
			in_quotation_mark = 1- in_quotation_mark;
			out = out char
		} else if (char == "," && in_quotation_mark == 1) {
			out = out " "
		} else {
			out = out char;
		}
	}
	print out;
}' processed_new_line.csv > processed_comma_newline.csv
