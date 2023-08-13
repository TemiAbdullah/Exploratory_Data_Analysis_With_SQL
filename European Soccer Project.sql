/* Analyzing Barcelona's 2015/2016 season with SQL
linkedin.com/in/abdullaah-odunmbaku-958795199
*/


--The "Match$" table and the "Team$" table are the tables that will be used for the analysis. 
--First is a quick overview of the tables by running some queries.

--This query will show the number of rows and the number of columns for the table.
SELECT
    (SELECT COUNT(*) FROM Team$) AS row_count,
    COUNT(*) AS column_count
FROM information_schema.columns
WHERE table_name = 'Team$';

--This will show each column and the respective datatype. 
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'Team$';

--This query will show the number of rows and the number of columns for the table.
SELECT
    (SELECT COUNT(*) FROM Match$) AS row_count,
    COUNT(*) AS column_count
FROM information_schema.columns
WHERE table_name = 'Match$';

--This will show each column and the respective datatype. 
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'Match$';

--The query below also provides the first 10 rows for both tables.
SELECT TOP 10 * FROM Team$;
SELECT TOP 10 * FROM Match$;

--The following queries are for the purpose of an exploratory analysis of Barcelona's 2015/2016 LaLiga season. 
--Identifying Barcelona and it's corresponding keys
SELECT * FROM Team$ WHERE team_long_name = 'FC Barcelona' 
--the team_api_id is the primary key for this table. It can be used to identify each specific team. For barcelona it is 8634. 
--I'll use 8634 to identify Barcelona from here on as it is a unique identifier. 

--Total games played in the 2015/2015 season. Football fans should already know that it's 38 with 19 home games and 19 away games.
SELECT
    COUNT(*) AS total_games_played,
    SUM(CASE WHEN home_team_api_id = 8634 THEN 1 ELSE 0 END) AS home_games_played,
    SUM(CASE WHEN away_team_api_id = 8634 THEN 1 ELSE 0 END) AS away_games_played
FROM Match$
WHERE season = '2015/2016' 
    AND (home_team_api_id = 8634 OR away_team_api_id = 8634);

--Checking to see overall barca form for the season. Wins, losses and draws.
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

--Next is finding out their win percentage. That is the percentage of wins out of their 38 games. 
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
	
--To see the total number of points Barcelona scored after considering their wins, losses and draws. 
--In football, a win is 3 points, a draw is 1 point and a loss is 0 points. 
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

--I'd also like to know the total number of goals scored and those conceded over the course of the season. 
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

--Next is a analysis of their form home and away. Which considers home and away wins, draws and losses. As well as home and away goals scored and conceded.

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

--After analyzing their form with respect to home and away games. I'd also like to analyze it with respect to the months in the football season. This will be used to determine the months where they played well and those where they didnt.
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

--Finally, I'd like a list of all Barcelona games from the 2015/16 season and the goals scored in those games. 
--The list is arranged in order of Barca's goal difference so the games where they beat the opponent with the largest margins will be displayed first.
SELECT
    CONCAT(ht.team_long_name, ' vs ', at.team_long_name) AS Match,
	CASE	
		WHEN ht.team_long_name = 'FC BARCELONA' THEN m.home_team_goal
		WHEN ht.team_long_name = 'FC BARCELONA' THEN m.away_team_goal
		ELSE m.away_team_goal 
		END AS Barcelona_goals,
	CASE 
		WHEN ht.team_long_name != 'FC BARCELONA' THEN m.home_team_goal
		WHEN ht.team_long_name != 'FC BARCELONA' THEN m.away_team_goal
		ELSE m.away_team_goal 
		END AS Opposition_goals,
	CASE
        WHEN ht.team_long_name = 'FC Barcelona' THEN m.home_team_goal - m.away_team_goal
        WHEN at.team_long_name = 'FC Barcelona' THEN m.away_team_goal - m.home_team_goal
        ELSE NULL -- Handle cases where Barcelona is neither the home nor away team (optional)
    END AS Barcelona_goal_difference
FROM Match$ AS m
JOIN Team$ AS ht ON m.home_team_api_id = ht.team_api_id
JOIN Team$ AS at ON m.away_team_api_id = at.team_api_id
WHERE m.season = '2015/2016'
    AND (ht.team_long_name = 'FC Barcelona' OR at.team_long_name = 'FC Barcelona')
ORDER BY Barcelona_goal_difference DESC;


/* Some of the insights found in the data from the queries above. 
1. The "Team$" table has 299 rows and 5 columns. The columns are id, team_api_id, team_fifa_api_id, team_long_name and team_short_name. 
2. The "Match$" table has 25979 and 11 columns. The 11 columns include the id, country_id, season, home_team, away_team etc. 
3. There a couple of unique keys that can be used to identify Barcelona. Its team_api_id, team_fifa_api_id. The team_long_name and team_short_name can also be used, but there is not guarantee that they are unique.
4. Barcelona played 38 games in the 2015/2016 season with 19 at home and 19 away. 
5. They won 29 games, lost 5 and drew 4. Resulting in 91 points and a win percentage of 77%.  
6. Barcelona was able to score 112 goals and conceded only 29.
7. The analysis of their home and away form showed that their home form was better than their away form. They won more, lost less, drew less, scored more and conceded less at home than away.
8. The analysis of their form based on the months in the calendar year showed that they enjoyed their best form in February and their wirst in April.  
9. Their biggest win of the season was an 8-0 win against RC Deportivo de La Coruna. While their biggest loss was in a game against Celta Vigo where they lost 4-1.






