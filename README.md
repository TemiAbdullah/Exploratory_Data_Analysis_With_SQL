# Exploring European Soccer Data With SQL
![](https://github.com/TemiAbdullah/Exploratory_Data_Analysis_With_SQL/blob/23fd2861a5618f3fe0fa157b92771b4c607982fd/Football%20Pitch.jpg)

For this project, I attempted to combine two of my interests; football (soccer) and data analysis with SQL. I decided to analyze Barcelona's 2015/2016 league season; looking at their form, their goal scoring and other relevant metrics that can be used to paint a broad picture of their performance in that league season. 
---

## Data Source and Description
The data used for this project was gotten from [Kaggle](https://www.kaggle.com/datasets/hugomathien/soccer). The database contains +25,000 matches, +10,000 players, 11 European Countries with their lead championship, seasons 2008 to 2016, detailed match events (goal types, possession, corner, cross, fouls, cards etc…) for +10,000 matches and so on. 
The SQL skills demonstrated in this project include:
* Data Transformation
* Data Joins
* Data Aggregation
* Common Table Expression (CTE)
* Conditional Logic
* Data Formatting
* Data Filtering
* Mathematical Operations etc. 

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

Before the starting the analysis, I thought it would be useful to find the keys and values that uniquely identify Bareclona.
```sql
SELECT * FROM Team$ WHERE team_long_name = 'FC Barcelona' 
--the team_api_id is the primary key for this table. It can be used to identify each specific team. For barcelona it is 8634. 
```
| id | team_api_id | team_fifa_api_id | team_long_name | team_short_name |
| --- | --- | --- | --- | --- |
| 43042	| 8634 | 241 |	FC Barcelona |	BAR |

I'll use 8634 to identify Barcelona from here on as it is a unique value.


#### 1. The total number of games Barcelona played in the 2015/2016 season. And the games played at home and away. 
Soccer fans should already know that it's 38 with 19 home games and 19 away games.
```sql
SELECT
    COUNT(*) AS total_games_played,
    SUM(CASE WHEN home_team_api_id = 8634 THEN 1 ELSE 0 END) AS home_games_played,
    SUM(CASE WHEN away_team_api_id = 8634 THEN 1 ELSE 0 END) AS away_games_played
FROM Match$
WHERE season = '2015/2016' 
    AND (home_team_api_id = 8634 OR away_team_api_id = 8634);
```

| total_games_played | home_games_played | away_games_played |
| --- | --- | --- |
| 38 | 19 | 19 |


#### 2. Their wins, losses and draws in the season. 
```sql
SELECT
    SUM(CASE 
        WHEN home_team_api_id = 8634 AND home_team_goal > away_team_goal THEN 1
        WHEN away_team_api_id = 8634 AND away_team_goal > home_team_goal THEN 1
        ELSE 0 END) AS wins,
    SUM(CASE 
        WHEN home_team_api_id = 8634 AND home_team_goal < away_team_goal THEN 1
        WHEN away_team_api_id = 8634 AND away_team_goal < home_team_goal THEN 1
        ELSE 0 END) AS losses,
    SUM(CASE 
        WHEN (home_team_api_id = 8634 OR away_team_api_id = 8634) AND home_team_goal = away_team_goal THEN 1
        ELSE 0
    END) AS draws
FROM Match$
WHERE season = '2015/2016' 
    AND (home_team_api_id = 8634 OR away_team_api_id = 8634);
```

| wins | losses | draws |
| --- |--- | --- |
| 29 | 5 | 4 |

#### 3. Their win percentage. 
The previous query showed that Barcelona won a majority of their games in the season. But it could also be useful o know the percenatage of wins of the 38 games played. 
```sql
WITH Games AS (
    SELECT
        CASE 
            WHEN home_team_api_id = 8634 AND home_team_goal > away_team_goal THEN 1
            WHEN away_team_api_id = 8634 AND away_team_goal > home_team_goal THEN 1
            ELSE 0 
        END AS wins
    FROM Match$
    WHERE season = '2015/2016'
)
SELECT CONCAT(CEILING(SUM(wins) * 100.0 / 38), '%') AS win_percentage
FROM Games;
```

| win_percentage |
| --- |
| 77% |

#### 4. The total number of points accrued from their wins, draws and losses. 
In soccer, a win is 3 points, a loss is 0 and a draw is 1. 
```sql
WITH MatchResults AS (
    SELECT
        CASE
            WHEN home_team_api_id = 8634 AND home_team_goal > away_team_goal THEN 3
            WHEN away_team_api_id = 8634 AND away_team_goal > home_team_goal THEN 3
            WHEN home_team_api_id = 8634 AND home_team_goal = away_team_goal THEN 1
			WHEN away_team_api_id = 8634 AND away_team_goal = home_team_goal THEN 1
            ELSE 0
        END AS points
    FROM Match$
    WHERE season = '2015/2016'
)
SELECT SUM(points) AS total_points
FROM MatchResults;
```

| total_points |
| --- |
| 91 |

#### 5. The number of goals they scored and the number they conceded over the full course of the season. 
```sql
SELECT
    SUM(CASE 
        WHEN home_team_api_id = 8634 THEN home_team_goal
        ELSE away_team_goal END) AS total_goals_scored,
    SUM(CASE 
        WHEN away_team_api_id = 8634 THEN home_team_goal
        ELSE away_team_goal END) AS total_goals_conceded
FROM Match$
WHERE season = '2015/2016' 
    AND (home_team_api_id = 8634 OR away_team_api_id = 8634);
```

| goals_scored | goals_conceded |
| --- | --- |
| 115 | 29 |

#### 6. Their home form. 
We know their wins, losses and draws over the season but it could also be useful go more in debth into their form to discover how many of those were at home. 
```sql
--Home Form = home wins, home losses, home_draws , home goals scored and conceded.
SELECT 
	SUM (CASE 
		WHEN home_team_api_id = 8634 AND home_team_goal > away_team_goal THEN 1
		ELSE 0 END) AS home_wins,
	SUM (CASE
		WHEN home_team_api_id = 8634 AND home_team_goal < away_team_goal THEN 1
		ELSE 0 END) AS home_losses,
	SUM (CASE
		WHEN home_team_api_id = 8634 AND home_team_goal = away_team_goal THEN 1
		ELSE 0 END) AS home_draws,
	SUM (CASE
		WHEN home_team_api_id = 8634 THEN home_team_goal
		ELSE 0 END) AS home_goals_scored,
	SUM (CASE 
		WHEN home_team_api_id = 8634 THEN away_team_goal
		ELSE 0 END) AS home_goals_conceded
FROM Match$
	WHERE season = '2015/2016' 
	AND (home_team_api_id = 8634 OR away_team_api_id = 8634);
```

| home_ wins | home_losses | home_draws | goals_scored_at_home | goals_conceded_at_home |
| --- | --- | --- | --- | --- |
| 16 |	2 |	1 | 67 | 14 |

#### 7. Their away form
```sql
--Away form= away wins, losses, draws, goals scored and goals conceded
SELECT
	SUM (CASE
		WHEN away_team_api_id = 8634 AND away_team_goal > home_team_goal THEN 1
		ELSE 0 END) AS away_wins,
	SUM (CASE
		WHEN away_team_api_id = 8634 AND away_team_goal < home_team_goal THEN 1
		ELSE 0	END) AS away_losses,
	SUM (CASE
		WHEN away_team_api_id = 8634 AND away_team_goal = home_team_goal THEN 1
		ELSE 0 END) AS away_draws,
	SUM (CASE
		WHEN away_team_api_id = 8634 THEN away_team_goal
		ELSE 0 END) AS away_goals_scored,
	SUM (CASE 
		WHEN away_team_api_id = 8634 THEN home_team_goal
		ELSE 0 END) AS away_goals_conceded
FROM Match$
WHERE season = '2015/2016'
	AND (home_team_api_id = 8634 OR away_team_api_id = 8634);
```

| away_wins | away_losses | away_draws | goals_scored_away | goals_conceded_away | 
| --- | --- | --- | --- | --- |
| 13 | 3 |	3 |	45 | 15 |

#### 8. Their form across the football calendar year
After analyzing their form with respect to home and away games. I'd also like to analyze it with respect to the months in the soccer season. This will be used to determine the months where they played well and those where they didnt. The La Liga calender for the 205/2016 season started in August 2015
```sql 
SELECT
    DATENAME(MONTH, date) AS month,
	SUM(CASE 
        WHEN home_team_api_id = 8634 AND home_team_goal > away_team_goal THEN 1
        WHEN away_team_api_id = 8634 AND away_team_goal > home_team_goal THEN 1
        ELSE 0 END) AS wins,
    SUM(CASE 
        WHEN home_team_api_id = 8634 AND home_team_goal < away_team_goal THEN 1
        WHEN away_team_api_id = 8634 AND away_team_goal < home_team_goal THEN 1
        ELSE 0 END) AS losses,
    SUM(CASE 
        WHEN (home_team_api_id = 8634 OR away_team_api_id = 8634) AND home_team_goal = away_team_goal THEN 1
        ELSE 0 END) AS draws   
FROM Match$
WHERE season = '2015/2016' AND (home_team_api_id = 8634 OR away_team_api_id = 8634)
GROUP BY DATENAME(MONTH, date)
ORDER BY MIN(date);
```

| month | wins | losses | draws |
| --- | --- |--- | --- |
| August | 2 | 0 | 0 |
| September | 3	| 1 | 0 |
| October | 3 | 1 | 0 |
| November | 3	| 0 | 0 |
| December | 1	| 0 | 2 |
| January | 4 |	0 | 1 |
| February | 5 | 0 | 0 |
| March	| 3 | 0 | 1 |
| April	| 3 | 3 | 0 |
| May | 2 | 0 |	0 |

#### 9. Scoreline for all 38 games Barcelona played in the 2015/2016 season. 
Finally, I'd like to take a look at all the games they played in the season and the scorelines in those games.
```sql
SELECT
    CONVERT(DATE, date) AS match_date,
	CONCAT(ht.team_long_name, ' vs ', at.team_long_name) AS match,
	CASE	
		WHEN ht.team_long_name = 'FC BARCELONA' THEN m.home_team_goal
		WHEN ht.team_long_name = 'FC BARCELONA' THEN m.away_team_goal
		ELSE m.away_team_goal 
		END AS barcelona_goals,
	CASE 
		WHEN ht.team_long_name != 'FC BARCELONA' THEN m.home_team_goal
		WHEN ht.team_long_name != 'FC BARCELONA' THEN m.away_team_goal
		ELSE m.away_team_goal 
		END AS opposition_goals,
	CASE
        WHEN ht.team_long_name = 'FC Barcelona' THEN m.home_team_goal - m.away_team_goal
        WHEN at.team_long_name = 'FC Barcelona' THEN m.away_team_goal - m.home_team_goal
        ELSE NULL -- Handle cases where Barcelona is neither the home nor away team (optional)
    END AS barcelona_goal_difference
FROM Match$ AS m
JOIN Team$ AS ht ON m.home_team_api_id = ht.team_api_id
JOIN Team$ AS at ON m.away_team_api_id = at.team_api_id
WHERE m.season = '2015/2016'
    AND (ht.team_long_name = 'FC Barcelona' OR at.team_long_name = 'FC Barcelona')
ORDER BY match_date;
```

| date | match | barcelona_goals | opposition_goals | barcelona_goal_difference | 
| --- | --- | --- | --- | --- | 
| 2015-08-23 | Athletic Club de Bilbao vs FC Barcelona | 1 |	0 |	1 |
| 2015-08-29 | FC Barcelona vs MÃ¡laga CF |	1 |	0 |	1 |
| 2015-09-12 |	AtlÃ©tico Madrid vs FC Barcelona |	2 |	1 |	1 |
| 2015-09-20 |	FC Barcelona vs Levante UD |	4 |	1 |	3 |
| 2015-09-23 |	RC Celta de Vigo vs FC Barcelona |	1 |	4 |	-3 |
| 2015-09-26 |	FC Barcelona vs UD Las Palmas |	2 |	1 |	1 |
| 2015-10-03 |	Sevilla FC vs FC Barcelona |	1 |	2 |	-1 |
| 2015-10-17 |	FC Barcelona vs Rayo Vallecano |	5 |	2 |	3 |
| 2015-10-25 |	FC Barcelona vs SD Eibar |	3 |	1 |	2 |
| 2015-10-31 |	Getafe CF vs FC Barcelona |	2 |	0 |	2 |
| 2015-11-08 |	FC Barcelona vs Villarreal CF |	3 |	0 |	3 |
| 2015-11-21 |	Real Madrid CF vs FC Barcelona |	4 |	0 |	4 |
| 2015-11-28 |	FC Barcelona vs Real Sociedad |	4 |	0 |	4 |
| 2015-12-05 |	Valencia CF vs FC Barcelona |	1 |	1 |	0 |
| 2015-12-12 |	FC Barcelona vs RC Deportivo de La CoruÃ±a |	2 |	2 |	0 |
| 2015-12-30 |	FC Barcelona vs Real Betis BalompiÃ© |	4 |	0 |	4 |
| 2016-01-02 |	RCD Espanyol vs FC Barcelona |	0 |	0 |	0 |
| 2016-01-09 |	FC Barcelona vs Granada CF |	4 |	0 |	4 |
| 2016-01-17 |	FC Barcelona vs Athletic Club de Bilbao	| 6 |	0 |	6 |
| 2016-01-23 |	MÃ¡laga CF vs FC Barcelona |	2 |	1 |	1 |
| 2016-01-30 |	FC Barcelona vs AtlÃ©tico Madrid |	2 |	1 |	1 |
| 2016-02-07 |	Levante UD vs FC Barcelona |	2 |	0 |	2 |
| 2016-02-14 |	FC Barcelona vs RC Celta de Vigo |	6 | 	1 |	5 |
| 2016-02-17 |	Real Sporting de GijÃ³n vs FC Barcelona |	3 |	1 |	2 |
| 2016-02-20 |	UD Las Palmas vs FC Barcelona |	2 |	1 |	1 |
| 2016-02-28 |	FC Barcelona vs Sevilla FC |	2 |	1 |	1 |
| 2016-03-03 |	Rayo Vallecano vs FC Barcelona |	5 |	1 |	4 |
| 2016-03-06 |	SD Eibar vs FC Barcelona |	4 |	0 |	4 |
| 2016-03-12 |	FC Barcelona vs Getafe CF |	6 |	0 |	6 |
| 2016-03-20 |	Villarreal CF vs FC Barcelona |	2 |	2 |	0 |
| 2016-04-02 |	FC Barcelona vs Real Madrid CF |	1 |	2 |	-1 |
| 2016-04-09 |	Real Sociedad vs FC Barcelona |	0 |	1 |	-1 |
| 2016-04-17 |	FC Barcelona vs Valencia CF |	1 |	2 |	-1 |
| 2016-04-20 |	RC Deportivo de La CoruÃ±a vs FC Barcelona |	8 |	0 |	8 |
| 2016-04-23 |	FC Barcelona vs Real Sporting de GijÃ³n |	6 |	0 |	6 |
| 2016-04-30 |	Real Betis BalompiÃ© vs FC Barcelona |	2 |	0 |	2 |
| 2016-05-08 |	FC Barcelona vs RCD Espanyol |	5 |	0 |	5 |
| 2016-05-14 |	Granada CF vs FC Barcelona |	3 |	0 |	3 |


#### 10. Biggest wins and biggest losses. 
The query above can be repurposed to see a list of Barcelona's 5 biggest wins and 5 biggest losses across the season. This can be done simply by changing the ORDER BY to goal_difference. 

##### Biggest wins
```sql
--insert the code above
ORDER BY barcelona_goal_difference  DESC
```
| date | match | barcelona_goals | opposition_goals | barcelona_goal_difference | 
| --- | --- | --- | --- | --- | 
| 2016-04-20 |	RC Deportivo de La CoruÃ±a vs FC Barcelona |	8 |	0 |	8 |
| 2016-04-23 |	FC Barcelona vs Real Sporting de GijÃ³n |	6 |	0 |	6 |
| 2016-03-12 |	FC Barcelona vs Getafe CF |	6 |	0 |	6 |
| 2016-01-17 |	FC Barcelona vs Athletic Club de Bilbao	| 6 |	0 |	6 |
| 2016-02-14 |	FC Barcelona vs RC Celta de Vigo |	6 | 	1 |	5 |

#### Biggest loss
```sql
--insert code from 9.
ORDER BY barcelona_goal_difference  DESC
```
| date | match | barcelona_goals | opposition_goals | barcelona_goal_difference | 
| --- | --- | --- | --- | --- | 
| 2015-09-23 |	RC Celta de Vigo vs FC Barcelona |	1 |	4 |	-3 |

---
## Insights

1. The "Team$" table has 299 rows and 5 columns. The columns are id, team_api_id, team_fifa_api_id, team_long_name and team_short_name. 
2. The "Match$" table has 25979 and 11 columns. The 11 columns include the id, country_id, season, home_team, away_team etc. 
3. There a couple of unique keys that can be used to identify Barcelona. Its team_api_id, team_fifa_api_id. The team_long_name and team_short_name can also be used, but there is not guarantee that they are unique.
4. Barcelona played 38 games in the 2015/2016 season with 19 at home and 19 away. 
5. They won 29 games, lost 5 and drew 4. Resulting in 91 points and a win percentage of 77%.  
6. Barcelona was able to score 112 goals and conceded only 29.
7. The analysis of their home and away form showed that their home form was better than their away form. They won more, lost less, drew less, scored more and conceded less at home than away.
8. The analysis of their form based on the months in the calendar year showed that they enjoyed their best form in February and their worst in April.
9. They only failed to score in two games throughout the season. In their away games against Real Sociedad and RCD Espanyol. 
10. Their biggest win of the season was an 8-0 win against RC Deportivo de La Coruna. While their biggest loss was in a game against Celta Vigo where they lost 4-1.


The .SQL file can be found [here](https://github.com/TemiAbdullah/Exploratory_Data_Analysis_With_SQL/blob/c6520a66fd6efd174e3d5fe0dd5a855989745aed/European%20Soccer%20Project.sql). Any comments and feedback would be greatly appreciated. 


