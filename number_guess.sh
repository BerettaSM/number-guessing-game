#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t -c"


MAIN() {
  echo -e "Enter your username:"
  read USERNAME

  # Ask for username.
  USER_EXISTS=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")

  # If no such user exists.
  if [[ -z $USER_EXISTS ]] ; then
    # Insert user into db.
    RESULT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
    # Print basic welcome message.
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
  fi

  USER=$($PSQL "SELECT user_id, username, games_played, best_game FROM users WHERE username = '$USERNAME'")

  read USER_ID BAR USERNAME BAR GAMES_PLAYED BAR BEST_GAME <<< $USER

  if [[ $USER_EXISTS ]] ; then
    # Print existing user welcome message.
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

  SECRET_NUMBER=$(($RANDOM % 1000 + 1))

  # echo -e "\nPssttt. The number is $SECRET_NUMBER.\n"

  echo -e "Guess the secret number between 1 and 1000:"

  USER_GUESS=$((-1))
  NUMBER_OF_GUESSES=0

  while [[ $USER_GUESS -ne $SECRET_NUMBER ]] ; do

    ((NUMBER_OF_GUESSES++))

    read USER_GUESS

    if [[ ! $USER_GUESS =~ ^[0-9]+$ ]] ; then
      echo "That is not an integer, guess again:"
    elif [[ $USER_GUESS -lt $SECRET_NUMBER ]] ; then
      echo "It's higher than that, guess again:"
    elif [[ $USER_GUESS -gt $SECRET_NUMBER ]] ; then
      echo "It's lower than that, guess again:"
    fi

  done

  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

  RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE user_id = $USER_ID")

  if [[ $BEST_GAME -eq 0 || $NUMBER_OF_GUESSES -lt $BEST_GAME ]] ; then

    RESULT=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE user_id = $USER_ID")

  fi

}

MAIN
