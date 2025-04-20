#!/bin/bash 

>"processed_new_line.csv"

awk 'BEGIN {
	line="";
	in_quotation_mark=0;
}{
	line = line $0;
	num_of_quotation_mark = gsub(/"/, "&", $0);
	
	# if number of quotation marks is odd, it will be inside the quote
	if (num_of_quotation_mark % 2 == 1) {
		in_quotation_mark = 1 - in_quotation_mark;
	}
	
	if (in_quotation_mark == 0) {
		print line; 
		line="";
	} else {
		line = line " ";
	}
}' tmdb-movies.csv > processed_new_line.csv
