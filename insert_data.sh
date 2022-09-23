#! /bin/bash

# Script to insert data from games.csv into worldcup database
if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games RESTART IDENTITY ")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[  $YEAR != year ]]
  then 
    # get team_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'");
    # if not found
    if [[ -z $WINNER_ID ]]
    then
      #insert team_name
      TEAM_NAME_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')");
      if [[ $TEAM_NAME_RESULT == "INSERT 0 1" ]]
      then echo Inserted into teams, $WINNER ;
      fi 
      # get new team_id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'");          
    fi
    # get opponent_id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'");
    # if not found
    if [[ -z $OPPONENT_ID ]]
    then
      #insert into teams
      TEAM_NAME_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $TEAM_NAME_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT;
      fi
      # get new opponent_id
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'"); 
    fi
    # insert games
    INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR , '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAMES_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into games, $YEAR $ROUND
    fi
  fi
done
