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
After analyzing their form with respect to home and away games. I'd also like to analyze it with respect to the months in the football season. This will be used to determine the months where they played well and those where they didnt.
```sql 





























The full .SQL file can be found [here](https://github.com/TemiAbdullah/Exploratory_Data_Analysis_With_SQL/blob/c6520a66fd6efd174e3d5fe0dd5a855989745aed/European%20Soccer%20Project.sql). Any comments and feedback would be greatly appreciated. 


