# Exploring European Soccer Data With SQL
![](https://github.com/TemiAbdullah/Exploratory_Data_Analysis_With_SQL/blob/23fd2861a5618f3fe0fa157b92771b4c607982fd/Football%20Pitch.jpg)

For this project, I attempted to combine two of my interests; football (soccer) and data analysis with SQL. I decided to analyze Barcelona's 2015/2016 league season; looking at their form, their goal scoring and other relevant metrics that can be used to paint a broad picture of their performance in that league season. 
---

## Data Source and Description
The data used for this project was gotten from [Kaggle](https://www.kaggle.com/datasets/hugomathien/soccer). The database contains +25,000 matches, +10,000 players, 11 European Countries with their lead championship, seasons 2008 to 2016, detailed match events (goal types, possession, corner, cross, fouls, cards etc…) for +10,000 matches and so on. 

For my project, only the "Matches" table and the "Teams" table were used. An overview of both tables are contained below. 

#### The Teams Table
The Teams table contains data about all the teams in 11 European Countries as well as unique keys that can be used to identify them.
```sql
--This query will show the number of rows and the number of columns for the table.
SELECT
    (SELECT COUNT(*) FROM Team$) AS row_count,
    COUNT(*) AS column_count
FROM information_schema.columns
WHERE table_name = 'Team$';
```
| row_count | column_count |
| --- | --- |
| 299 | 5 |

```sql
--This will show each column in the table and the respective datatype. 
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'Team$';
```
| column_name | data_type |
| --- | --- |
| id | float |
| team_api_id | float |
| team_fifa_api_id | float |
| team_long_name | nvarchar |  
| team_short_name | nvarchar |


#### The Matches Table
The matches table contains a list of +10000 matches with their dates, home and away teams, goals scored and other relevant data.
```sql
--This query will show the number of rows and the number of columns for the table.
SELECT
    (SELECT COUNT(*) FROM Match$) AS row_count,
    COUNT(*) AS column_count
FROM information_schema.columns
WHERE table_name = 'Match$';
```
| row_count | column_count |
| --- | --- |
|  25979 |	11 |

```sql
--This will show each column and the respective datatype. 
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'Match$';
```
| column_name | data_type |
| --- | --- |
| id | float |
| country_id | float |
| league_id | float |
| season | nvarchar |
| stage | float |
| date | datetime |
| match_api_id | float |
| home_team_api_id | float |
| away_team_api_id | float |
| home_team_goal | float |
| away_team_goal | float |

---
## Analysis
To analyze Barcelona's performance for the 2015/2016 season, I sought to answer the following questions using SQL queries. 
* The total number of games played in the season and the games played at home and away.
* The number of wins, draws and losses in the season.
* The total points accrued from those wins, draws and losses.
* Their win percentage.
* Their home form vs their away form.
* Their form for each month of the football calender year.
* The scorline of all the games played. Including their biggest wins and their biggest losses.

The full .SQL file can be found [here](https://github.com/TemiAbdullah/Exploratory_Data_Analysis_With_SQL/blob/c6520a66fd6efd174e3d5fe0dd5a855989745aed/European%20Soccer%20Project.sql). Any comments and feedback would be greatly appreciated. 


