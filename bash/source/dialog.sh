#!/bin/bash

# @author Yuriy Rubashevskiy (r9182230628@gmail.com)
# @brief "Набор функций" для  BASH отвечабщий за взаимодействие с пользователем
# @version 0.0.1b
# @date 2020-07-01
# @donate Автору на 'печеньки': http://yasobe.ru/na/avtoru_na_pe4enki
# 
# @copyright Copyright (c) 2020 Free   Software   Foundation,  Inc.
#     License  GPLv3+:  GNU  GPL  version  3  or  later <http://gnu.org/licenses/gpl.html>.
#     This is free software: you are free to change and redistribute it.  
#     There is NO WARRANTY, to the  extent  permitted by law.
#

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
# Первый параметр - сообщение
function anyKey() {
  read -p "$(echo "$1")" -n 1 -r
}