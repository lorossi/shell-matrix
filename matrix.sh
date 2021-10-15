#!/bin/bash

ESCAPE="\033["
WIDTH=$(tput cols)
HEIGHT=$(tput lines)

clear_screen () {
  echo -e "${ESCAPE}2J" # clear screen
  echo -e "${ESCAPE}0M" # reset styles
  echo -e "${ESCAPE}?25l" # hide cursor
}

ctrlc () {
  [[ -z "$(jobs -p)" ]] || kill $(jobs -p) # kill all subprocesses
  echo -e "${ESCAPE}2J" # clear screen
  echo -e "${ESCAPE}0M" # reset styles
  echo -e "${ESCAPE}H" # go to 0, 0
  echo -e "${ESCAPE}?25h" # show cursor
}

write_at_color () {
  # random chance of the letter being white if $4 == 255
  # aka first letter

  if (( $4 > 220 )) && (( RANDOM % 10 >= 9 ))
  then
    echo -e "${ESCAPE}$2;$1H${ESCAPE}97m$3"
  else
    echo -e "${ESCAPE}$2;$1H${ESCAPE}38;2;0;$4;0m$3"
  fi
}

clear_at () {
  echo -e "${ESCAPE}$2;$1H "
}

strings_fall() {
  # string coordinates
  X=$(($1))
  Y=$((RANDOM % HEIGHT))
  # string length
  LEN=$((RANDOM % 20 + 10))
  # utf-8 starting kanji
  BASE_CHAR=0x30a0
  # random delay at start
  sleep $(echo "scale=4;${RANDOM}.0/32767.0/4" | bc )

  while true
  do
    for (( i = 0; i < LEN; i++ ))
    do      
      # new Y
      NY=$((Y - i))
      
      if (( NY < 0 ))
      then
        NY=$((NY + HEIGHT))
      fi
      # previous Y
      PY=$((NY - 1))
      
      if (( PY < 0 ))
      then
        PY=$((PY + HEIGHT))
      fi
      # seed to generate letter
      SEED=$((RANDOM % 95))
      # calculate the utf code for the letter
      CHAR=$(printf '%x\n' $((BASE_CHAR + SEED)) )
      # calculate green fading
      FADE=$((255 - 255 * i / LEN))
      # clear old char
      clear_at $X $PY
      # write new char
      write_at_color $X $NY "\u${CHAR}" $FADE
    done
    # update Y coordinate
    ((Y = (Y + 1) % HEIGHT))
    # small delay
    sleep 0.01
  done
}

# catch SIGINT
trap ctrlc SIGINT

# clear the screen
clear_screen
# spawn string
for ((i = 0; i < WIDTH/3; i++))
do
  # they run in parallel
  strings_fall $((i * 3)) &
done
# loop forever
wait 
