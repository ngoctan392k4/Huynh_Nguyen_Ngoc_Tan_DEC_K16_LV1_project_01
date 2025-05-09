#!/bin/bash

cd Desktop/
wget raw.githubusercontent.com/yinghaoz1/tmdb-movie-dataset-analysis/master/tmdb-movies.csv
export LC_NUMERIC=en_US.UTF-8 # Ensure that the float using . to seperate decimal part and the fractional part

# Process new line format in fields
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

# Process comma format in the records (the information in some fields)

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

# Process date format into YYYY/MM/DD
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


# Sorting movies based on released_date
(head -n 1 main_data.csv && tail -n +2 main_data.csv | sort -t, -k16,16r) > latest_to_oldest_movies.csv

# Vote_average above 7.5
(head -n 1 main_data.csv && tail -n +2 main_data.csv | awk -F, '$18 > "7.5"') > vote_avr_above_75.csv

# The maximum and minimum revenue by revenue field
head -n 1 main_data.csv > max_min_revenue.csv
max_revenue=$(tail -n +2 main_data.csv | awk -F,  '{print $5}' | sort -gr | head -n 1)
awk -F, -v max="$max_revenue" '$5 == max' main_data.csv >> max_min_revenue.csv

min_revenue=$(tail -n +2 main_data.csv | awk -F,  '{print $5}' | sort -g | head -n 1)
awk -F, -v min="$min_revenue" '$5 == min' main_data.csv >> max_min_revenue.csv

# The maximum and minimum revenue by revenue_adj field
head -n 1 main_data.csv > max_min_revenue_adj.csv
max_revenue=$(tail -n +2 main_data.csv | sort -t, -k21,21 -gr | head -n 1 | awk -F,  '{print $21}')
awk -F, -v max="$max_revenue" '$21 == max' main_data.csv >> max_min_revenue_adj.csv

min_revenue=$(tail -n +2 main_data.csv | sort -t, -k21,21 -g | head -n 1 | awk -F,  '{print $21}')
awk -F, -v min="$min_revenue" '$21 == min' main_data.csv >> max_min_revenue_adj.csv

# The sum of revenue by revenue field
awk -F, '{sum+=$5} END {printf "The sum of revenue by revenue field %.10f\n", sum}' main_data.csv >> single_output.txt

# The sum of revenue by revenue_adj field
awk -F, '{sum+=$21} END {printf "The sum of revenue by revenue_adj field: %.10f\n", sum}' main_data.csv >> single_output.txt

# Top 10 profit by revenue and budget fields
(head -n 1 main_data.csv && tail -n +2 main_data.csv | awk -F, '{print "%.10f\n", ($5 - $4) "," $0}' |sort -t, -k1,1gr | cut -d, -f2- ) | head > top_ten_profit_by_revenue.csv

# Top 10 profit by revenue_adj and budget_adj fields
(head -n 1 main_data.csv && tail -n +2 main_data.csv | awk -F, '{print "%.10f\n", ($21 - $20) "," $0 }' | sort -t, -k1,1 -gr | cut -d, -f2- ) | head > top_ten_profit_by_revenue_adj.csv

# The director has the most movies
echo -n "The director has the most movies is: " >> single_output.txt
tail -n +2 main_data.csv | awk -F, '{print $9}' | tr '|' '\n' | grep -v '^$' | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2 " (" $1 " movies)"}' >> single_output.txt

# The actor or actress has the most movies
echo -n "The actor or actress has the most movies is: " >> single_output.txt
tail -n +2 main_data.csv | awk -F, '{print $7}' | tr '|' '\n' | grep -v '^$' | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2 " (" $1 " movies)"}' >> single_output.txt

# Statistics of number of movies by genre
tail -n +2 main_data.csv | awk -F, '{print $14}' | tr '|' '\n' | grep -v '^$' | sort | uniq -c | sort -nr > statistic_movies.txt
