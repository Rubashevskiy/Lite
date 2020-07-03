#!/bin/bash

# Получения номера от пользователя начиная от "1"
# Первый параметр максимальное значение
# Второй параметр текст сообщения
function getNumber() {
  while true ; do
    read -p "$(echo "[1..$1] $2: ")" -r
    re='^[0-9]+$'
    if [[ $REPLY =~ $re ]] ; then
      if [ "$REPLY" -gt "0" ] && [ "$REPLY" -le "$1" ] ; then
        echo "$REPLY"
        break
      fi
    fi
  done
}

# Получение от пользователя нажатие любой клавиши
# Первый параметр сообщение
function anyKey() {
  read -p "$(echo "$1")" -n 1 -r
}