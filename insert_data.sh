#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

TEAM_VALUES=""
GAME_VALUES=""
while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  if [[ $year == "year" ]]
  then
    continue
  fi

  TEAM_VALUES+="${TEAM_VALUES:+,}('$winner'),('$opponent')"
  GAME_VALUES+="${GAME_VALUES:+,}($year,'$round','$winner','$opponent',$winner_goals,$opponent_goals)"
done < games.csv

INSERT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES $TEAM_VALUES ON CONFLICT (name) DO NOTHING; INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) SELECT game.year, game.round, winner.team_id, opponent.team_id, game.winner_goals, game.opponent_goals FROM (VALUES $GAME_VALUES) AS game(year, round, winner, opponent, winner_goals, opponent_goals) JOIN teams AS winner ON winner.name = game.winner JOIN teams AS opponent ON opponent.name = game.opponent")
