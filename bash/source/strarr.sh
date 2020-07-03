#!/bin/bash

function dirNameToArrStr() {
  local arr
  local fDir
  local path="$1""/"
  # Проход в цикле по всем файлам в каталоге
  for dir in  "${path}"*
  do
    # Если это директория добавляем
    if [ -d "${dir}" ]; then
      # Обрезаем полный путь
      fDir=$(echo "${dir}" | awk -F / '{print $NF}')
      # Требование "strArr(:) масива" - Разделитель должен стоять только после значения
      if [ -n "${arr}" ] ; then
        arr+=":"
      fi
      # Добавляем в "strArr(:) масив" название
      arr+="${fDir}"
    fi
  done
  echo "${arr}"
}

function fileNameToArrStr() {
  local arr
  local fName
  local path="$1""/"
  # Проход в цикле по всем файлам в каталоге
  for file in  "${path}"*
  do
    # Если это обычный файл - добавляем
    if [ -f "${file}" ]; then
      # Обрезаем полный путь
      fName=$(echo "${file}" | awk -F / '{print $NF}')
      # Требование "strArr(:) масива" - Разделитель должен стоять только после значения
      if [ -n "${arr}" ] ; then
        arr+=":"
      fi
      # Добавляем в "strArr(:) масив" название
      arr+="${fName}"
    fi
  done
  echo "${arr}"
}

function fileToArrStr() {
  local arr
  while IFS= read -r line
  do
    # Требование "strArr(:) масива" - Разделитель должен стоять только после значения
    if [ -n "${arr}" ] ; then
      arr+=":"
    fi
    arr+="$line"
  done <"$1"
  echo "${arr}"
}

function getArrRange() {
  local arr
  local arr_str=()
  IFS=$':' read -a arr_str <<< $1
  unset IFS
  for (( index="$2"; index <= "$3"; index++ ))
  do
    # Требование "strArr(:) масива" - Разделитель должен стоять только после значения
    if [ -n "${arr}" ] ; then
      arr+=":"
    fi
    arr+="${arr_str[$index]}"
  done
  echo "${arr}"
}

# Печать strArr(:) масива  c индексами( от 1 )
# Первый параметр - strArr(:) масив
# Второй параметр - Строка отступа(по умолчанию "    ")
function printArr() {
  local tab="    "
  if [ -n "$2" ] ; then
    tab="$2"
  fi
  local arr_str=()
  IFS=$':' read -a arr_str <<< $1
  unset IFS
  local print_index=0
  for index in ${!arr_str[*]}
  do
    let "print_index += 1"
    echo "${tab}""${print_index}"": ""${arr_str[$index]}"
  done
}

# Печать элемента strArr(:) масива
# Первый параметр - strArr(:) масив
# Второй параметр - номер элемента
function printArrIndex() {
  local index="$2"
  local arr_str=()
  IFS=$':' read -a arr_str <<< $1
  unset IFS
  echo "${arr_str[$index]}"
}

# Печать диапазона элементов strArr(:) масива
# Первый параметр - strArr(:) масив
# Второй параметр - начальный элемент
# Третий параметр - конечный элемент
# Четвертый параметр - Строка отступа(по умолчанию "    ")
function printArrRange() {
local tab="    "
  if [ -n "$4" ] ; then
    tab="$4"
  fi
  local arr_str=()
  IFS=$':' read -a arr_str <<< $1
  unset IFS
  local print_index=0
  for (( index="$2"; index <= "$3"; index++ ))
  do
    let "print_index += 1"
    echo "${tab}""${print_index}"": ""${arr_str[$index]}"
  done
}

# Получение числа элементов в масиве strArr(:)
# Первый параметр - strArr(:) масив
function getArrSize() {
  local arr_str=()
  IFS=$':' read -a arr_str <<< $1
  unset IFS
  echo "${#arr_str[@]}"
}

function pushBackArr() {
  local arr=$1
  # Требование "strArr(:) масива" - Разделитель должен стоять только после значения
  if [ -n "${arr}" ] ; then
    arr+=":"
  fi
  arr+="$2"
  echo "${arr}"
}