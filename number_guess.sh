#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo -e "\n~~~Number Guessing Game~~~\n"

# get the secret number
RANDOM_NUMB=$(( $RANDOM % 1000 + 1 ))
REGEX='^([1-9][0-9]{0,2})$'
# get user info
echo "Enter your username:"
read USERNAME
USER_INFO=$($PSQL "SELECT name, games_played, best_game FROM guesser WHERE name='$USERNAME' ")
USER_ID=$($PSQL "SELECT guesser_id FROM guesser WHERE name='$USERNAME' ")
GAMES_PLAYED_COUNT=$($PSQL "SELECT games_played FROM guesser WHERE name='$USERNAME' ")
BEST_GAME_STAT=$($PSQL "SELECT best_game FROM guesser WHERE name='$USERNAME' ")
CURRENT_STAT=0

# if not found
if [[ -z $USER_INFO ]] 
then
# insert new user
INSERT_USER=$($PSQL "INSERT INTO guesser(name) VALUES('$USERNAME')")
echo "Welcome, $USERNAME! It looks like this is your first time here."
USER_ID=$($PSQL "SELECT guesser_id FROM guesser WHERE name='$USERNAME' ")
GAMES_PLAYED_COUNT=0
BEST_GAME_STAT=999999999999999999999
else
  echo $USER_INFO | while read NAME BAR GAMES_PLAYED BAR BEST_GAME
  do
    # if [[ -z $BEST_GAME ]]
    # # then
    #   echo "Welcome back, $NAME! You have played 0 games, and your best game took 0 guesses."
    # else
      echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    # fi
  done
fi
BEST_GAME_STAT=999999999999999999999
echo "Guess the secret number between 1 and 1000:"

MAIN_MENU(){

read NUMB
if  [[ ! $NUMB =~ [0-9]+ ]]
then  
  echo "That is not an integer, guess again:"
  CURRENT_STAT=$(( $CURRENT_STAT + 1 ))
  MAIN_MENU 
fi

if [[ $NUMB -gt $RANDOM_NUMB ]]
then
  echo "It's lower than that, guess again:"
  CURRENT_STAT=$(( $CURRENT_STAT + 1 ))
  MAIN_MENU 
elif [[ $NUMB -lt $RANDOM_NUMB ]]
then
  echo "It's higher than that, guess again:"
  CURRENT_STAT=$(( $CURRENT_STAT + 1 ))
  MAIN_MENU 
elif [[ $NUMB == $RANDOM_NUMB ]]
then
  CURRENT_STAT=$(( $CURRENT_STAT + 1 ))
  echo "You guessed it in $CURRENT_STAT tries. The secret number was $RANDOM_NUMB. Nice job!"
  if [[ -z $GAMES_PLAYED_COUNT ]]
  then
    GAMES_PLAYED_COUNT=1
  else
    GAMES_PLAYED_COUNT=$(( $GAMES_PLAYED_COUNT+1 ))
  fi
  if [[ $CURRENT_STAT -lt $BEST_GAME_STAT ]]
  then
    UPDATE_RESULT=$($PSQL "UPDATE guesser SET games_played=$GAMES_PLAYED_COUNT, best_game=$CURRENT_STAT WHERE guesser_id=$USER_ID")
  else
    UPDATE_RESULT=$($PSQL "UPDATE guesser SET games_played=$GAMES_PLAYED_COUNT, best_game=$BEST_GAME_STAT WHERE guesser_id=$USER_ID").
  exit
  fi
fi

}

MAIN_MENU