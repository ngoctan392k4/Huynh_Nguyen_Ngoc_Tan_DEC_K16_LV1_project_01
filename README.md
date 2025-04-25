# PROJECT 1. MOVIES ANALYSIS WITH LINUX COMMAND
# Step 1: Check the connection to the host
```
ping -c 5 [raw.githubusercontent.com](http://raw.githubusercontent.com/)
```
# Step 2: Download the given csv file and change the LC_NUMERIC
```
cd Desktop/
wget [raw.githubusercontent.com/yinghaoz1/tmdb-movie-dataset-analysis/master/tmdb-movies.csv](http://raw.githubusercontent.com/yinghaoz1/tmdb-movie-dataset-analysis/master/tmdb-movies.csv)
export LC_NUMERIC=en_US.UTF-8 # Ensure that the float using . to seperate decimal part and the fractional part
```
# Step 3: Pre-Processing data with "\n" in quotation like "a\n b"
- Reason: Due to "\n" in some field, overview as an example, the information is broken into new line, making the records lacking information. For instance, in the 2nd field, the sentence is “One day \n he met her”, so when we use awk -F, ‘{print $1}’, we can get “he met her” since this information is broken from the previous field into the new line ⇒ impossible to process correct data
- Solution:
    - Using awk to read line by line
    - In each line, count the number of quotation marks.
        - If it is even, it means that there is enough quotation marks and the data is full ⇒ then, just print the line again in the new file
        - If it is odd, it means that the record lacks of quotation marks and the record lacks information ⇒ we keep this line and add a space “ ” to be able to combine with the upcoming line to complete the record

# Step 4: Pre-Processing data with comma in the quotation marks
- Reason: Since comma can cause error when we wanna get specific column. For instance, in tagline column, there exists the sentence like "(.One who has returned, as if from the dead)". Since in this sentences, there exists comma, so awk -F, has recognized this comma as the field and break it => impossible to get the correct comma (from delimiter of csv) => impossible to process data
- Solution:
    - Using awk to read line by line
    - In each line, we check every character
        - If the character is quotation mark ( ” ), we change the value of the checker from 1 to 0 and vice versa, and still get this character
        - If the value of the checker is 1 and the character is comma, we substitute the comma by the space
        - If the character is not in above cases, we just get the character
        - After all, just print all the characters that we get into the new file.

# Step 5: Pre-processing type of data for release_date
- Reason: The type of date now is in format like M/D/YY or MM/D/YY or M/DD/YY. They are inconsistent, making it impossible to compare and sort. Moreover, YY is quite confusing, since it might 15 for 2015 or 60 for 1960, but the sort tools will recognize 60 being greater than 15 instead of 2015 being greater 1960. As a result, we need to edit the format into the consistent one with clear date format YYYY/MM/DD
- Solution:
    - Using awk and check column 16 with delimiter comma
    - In each column, we split the value into 3 parts by ( / )
    - Formatting the year with the 3rd part: Since now we are in 2025, so if the last part is greater than 25, it means from 19xx ⇒ give 19 before the last part
    - Formatting the month with the 1st part: if the month is less than 10, add “0” before it
    - Formatting the day with the 2st part: if the day is less than 10, add “0” before it
    - After that, set new format is YYYY/MM/DD
    - Then, we print all column into the new file with the column $16 being the new format

# Question 1: Sort the movies by release date in descending order and save to a new file
```
(head -n 1 main_data.csv && tail -n +2 main_data.csv | sort -t, -k16,16r) > latest_to_oldest_movies.csv
```

# Question 2: Filter out movies with an average rating above 7.5 and save them to a new file.

```
(head -n 1 main_data.csv && tail -n +2 main_data.csv | awk -F, '$18 > "7.5"') > vote_avr_above_75.csv
```

# Question 3: Tìm ra phim nào có doanh thu cao nhất và doanh thu thấp nhất
**The maximum and minimum revenue by revenue field**

```
head -n 1 main_data.csv > max_min_revenue.csv
max_revenue=$(tail -n +2 main_data.csv | awk -F,  '{print $5}' | sort -gr | head -n 1)
awk -F, -v max="$max_revenue" '$5 == max' main_data.csv >> max_min_revenue.csv

min_revenue=$(tail -n +2 main_data.csv | awk -F,  '{print $5}' | sort -g | head -n 1)
awk -F, -v min="$min_revenue" '$5 == min' main_data.csv >> max_min_revenue.csv
```

**The maximum and minimum revenue by revenue_adj field**
```
head -n 1 main_data.csv > max_min_revenue_adj.csv
max_revenue=$(tail -n +2 main_data.csv | sort -t, -k21,21 -gr | head -n 1 | awk -F,  '{print $21}')
awk -F, -v max="$max_revenue" '$21 == max' main_data.csv >> max_min_revenue_adj.csv

min_revenue=$(tail -n +2 main_data.csv | sort -t, -k21,21 -g | head -n 1 | awk -F,  '{print $21}')
awk -F, -v min="$min_revenue" '$21 == min' main_data.csv >> max_min_revenue_adj.csv
```
**Problem when sorting maximum and minimum revenue by revenue_adj field**
- Since this field is in float/ double, so when I use flag -n for number it does not work well
    - Solution: Use flag -g for general numeric

# Question 4: Calculate total revenue of all movies
**The sum of revenue by revenue field**
```
awk -F, '{sum+=$5} END {printf "The sum of revenue by revenue field %.10f\n", sum}' main_data.csv >> single_output.txt
```

**The sum of revenue by revenue_adj field**
```
awk -F, '{sum+=$21} END {printf "The sum of revenue by revenue_adj field: %.10f\n", sum}' main_data.csv >> single_output.txt
```
**Problem when calculating with floating**
- Since the number is really large like 2,75014e+09 for number 2750136651, making it hard to understand all number
    - Solution: Use "%.10f\n" to get full number

# Question 5: Top 10 highest grossing movies

**The profit by revenue and budget fields**
```
(head -n 1 main_data.csv && tail -n +2 main_data.csv | awk -F, '{print "%.10f\n", ($5 - $4) "," $0}' |sort -t, -k1,1nr | cut -d, -f2- ) | head > top_ten_profit_by_revenue.csv
```

**The profit by revenue_adj and budget_adj fields**
```
(head -n 1 main_data.csv && tail -n +2 main_data.csv | awk -F, '{print "%.10f\n", ($21 - $20) "," $0 }' | sort -t, -k1,1 -gr | cut -d, -f2- ) | head > top_ten_profit_by_revenue_adj.csv
```
**Problem when sorting profit by revenue_adj and budget_adj fields**
- Since the number is really large like 2,75014e+09 for number 2750136651, leading to incorrect sorting since sort tool see that 2,7 < 2128035625
    - Solution: Use "%.10f\n" to get full number

# Question 6: Which director has the most films and which actor/ actress has the most films?
**The director has the most movies**
```
echo -n "The director has the most movies is: " >> single_output.txt
tail -n +2 main_data.csv | awk -F, '{print $9}' | tr '|' '\n' | grep -v '^$' | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2 " (" $1 " movies)"}' >> single_output.txt
```

**The actor or actress has the most movies**
```
echo -n "The actor or actress has the most movies is: " >> single_output.txt
tail -n +2 main_data.csv | awk -F, '{print $7}' | tr '|' '\n' | grep -v '^$' | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2 " (" $1 " movies)"}' >> single_output.txt
```
**Problem when translating '|' '\n', making some unexpected characters**
- There exists many blank after translating, so when we sort and uniq, it count the blank as the most, leading to incorrect answers
    - Solution: I had to filter out blank lines with grep
        - grep to find
        - -v to avoid
        - ^ is the start and $ is the and, so ^$ with no data in the middle means this is the blank

# Question 7: Count the number of movies by genre. For example, how many movies are in the Action genre, how many are in the Family genre, etc.

```
tail -n +2 main_data.csv | awk -F, '{print $14}' | tr '|' '\n' | grep -v '^$' | sort | uniq -c | sort -nr > statistic_movies.txt
```
