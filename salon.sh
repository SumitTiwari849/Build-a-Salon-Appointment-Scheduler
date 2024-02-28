#! /bin/bash

# initialization, define function
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU () {
  # Print 1st argument if given
  if [[ $1 ]];
  then
    echo -e "\n$1"
  fi
  # Show services list
  SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICES_LIST" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # go to select_service
  SELECT_SERVICE
}

SELECT_SERVICE () {
  # get service id from user
  read SELECT_SERVICE_ID
  # check if SELECT_SERVICE_ID is valid
  if [[ ! $SELECT_SERVICE_ID =~ ^[0-9]+$ ]];
  then
    # if SELECT_SERVICE_ID is not a number, then show list again
    MAIN_MENU "I could not find that service. What would you like today?"
  else  
    # check if SELECT_SERVICE_ID exist
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SELECT_SERVICE_ID'" | sed -E 's/^ //g')
    # echo "$SERVICE_NAME"

    if [[ -z $SERVICE_NAME ]];
    then
      # if SELECT_SERVICE_ID is a number but outside of list, then show list again
      MAIN_MENU "I could not find that service. What would you like today?"
    fi
  fi
}

MAKE_APPOINTMENT () {
  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed -E 's/^ +| +$//g')
  
  # insert to appointments table
  INSERT_APT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SELECT_SERVICE_ID, '$SERVICE_TIME')")

  # print message
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
}

# ------------------- Main Program Starts Here
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"
MAIN_MENU

# get customer's phone
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# query for customer name by phone
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed -E 's/^ +| +$//g')

if [[ -z $CUSTOMER_NAME ]];
then
  # if not exist in customers table, then ask for new customer name
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  INSERT_CUST_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

fi

# ask for service time
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

MAKE_APPOINTMENT