#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')"
else
  GAMES_PLAYED=$(echo $USER_INFO | cut -d '|' -f 1)
  BEST_GAME=$(echo $USER_INFO | cut -d '|' -f 2)

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$((RANDOM % 1000 + 1))
GUESSES=0

echo "Guess the secret number between 1 and 1000:"
read GUESS

while true
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
    continue
  fi

  ((GUESSES++))

  if [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    break
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi

  read GUESS
done

((GUESSES++))

echo "You guessed it in $GUESSES tries. The secret number was $((GUESSES - 1)). Nice job!"

if [[ -z $USER_INFO ]]
then
  $PSQL "UPDATE users SET games_played = 1, best_game = $GUESSES WHERE username='$USERNAME'"
else
  $PSQL "UPDATE users SET games_played = games_played + 1, best_game = LEAST(best_game, $GUESSES) WHERE username='$USERNAME'"
fi
