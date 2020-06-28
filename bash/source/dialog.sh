#!/bin/bash

# Функция в замен echo для вывода текста в нужной кодировке
function lecho() {
  iconv -s -f "UTF-8" <<< "$1"
}

# Печать strArr(:) масива  c индексами( от 1 )
# Первый параметр - strArr(:) масив
# Второй параметр - Строка отступа(по умолчанию "    ")
function printArr() {
  local tab="   "
  if [ -n "$2" ] ; then
    tab="$2"
  fi
  IFS=$':' read -a arr_str <<< $1
  unset IFS
  local print_index=0
  for index in ${!arr_str[*]}
  do
    let "print_index += 1"
    lecho "${tab}""${print_index}"": ""${arr_str[$index]}"
  done
}


# Печать элемента strArr(:) масива
# Первый параметр - strArr(:) масив
# Второй параметр - номер элемента
function printArrIndex() {
  local index="$2"
  IFS=$':' read -a arr_str <<< $1
  unset IFS
  lecho "${arr_str[$index]}"
}

# Печать диапазона элементов strArr(:) масива
# Первый параметр - strArr(:) масив
# Второй параметр - начальный элемент
# Третий параметр - конечный элемент
# Четвертый параметр - Строка отступа(по умолчанию "    ")
function printArrRange() {
local tab="   "
  if [ -n "$4" ] ; then
    tab="$4"
  fi
  IFS=$':' read -a arr_str <<< $1
  unset IFS
  local print_index=0
  for (( index="$2"; index <= "$3"; index++ ))
  do
    let "print_index += 1"
    lecho "${tab}""${print_index}"": ""${arr_str[$index]}"
  done
}

function getArrSize() {
  IFS=$':' read -a arr_str <<< $1
  unset IFS
  lecho "${#arr_str[@]}"
}

# Получения номера от пользователя
# Первый параметр максимальное значение
# Второй параметр текст сообщения
function getNumber() {
  while true ; do
    read -p "$(lecho "[1..$1] $2: ")" -r
    re='^[0-9]+$'
    if [[ $REPLY =~ $re ]] ; then
      if [ "$REPLY" -gt "0" ] && [ "$REPLY" -le "$1" ] ; then
        return $REPLY
        break
      fi
    fi
  done
}


# Получение от пользователя нажатие любой клавиши
function anyKey() {
  read -p "$(lecho "Для продолжения нажмите любую клавишу(<Any key>)")" -n 1 -r
}