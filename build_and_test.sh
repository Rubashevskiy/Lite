#!/bin/bash

#
# Сборка и запуск тестовых проектов серии Lite
# Версия 0.0.2b
# Автор: Рубашевский Ю. А.
# Email: rubashevskiy_ya@magnit.ru
#

# include 
# Самописные вспомогательные функции на Bash

# dialog.sh Набор функций для взаимодействия с пользователем
source ./bash/source/dialog.sh
# system.sh Набор функций для системных нужд
source ./bash/source/system.sh
source ./bash/source/strarr.sh

# Каталог для проведения сборки проектов(временная, удаляется при очистки)
buildDir="${PWD}/build/"
# Каталог размещения примеров
projectDir="${PWD}/example/"
# Каталог размещения файлов cmake(CMakeLists.txt)
cmakeDir="${PWD}/cmake/"
# Каталог размещения файлов "языков меню"
langDir="${PWD}/bash/language/"

# Функция выбора и загрузки языка меню
function setLang() {
  # Очиска экрана
  clear
  # Загрузка списка языков
  local lang=$(fileNameToArrStr "${langDir}")
  if [ ! -n "${lang}" ] ; then
    echo "Файлы <языков> не найдены/Keine Sprachdateien gefunden/No language files found"
    exit 1
  fi
  # Вывод приглашения
  echo "Выбор языка меню/Auswahl der Menüsprache/Menu language selection"
  # Вывод языков
  printArr "${lang}"
  # Выбор пользователем языка
  local msgNum="Выберете номер/Wähle eine Nummer/Choose a number"
  local num=$(getNumber $(getArrSize "${lang}") "${msgNum}")
  let "num -= 1"
  # Формируем путь до требуемого языка
  local filePath="${langDir}""$(printArrIndex "${lang}" "${num}")"
  # Загрузка файла языка в массив
  menu=$(fileToArrStr ${filePath})
}

function loadProject() {
  # Загрузка списка проектов, если их нет выходим
  project=$(dirNameToArrStr "${projectDir}")
  if [ ! -n "${project}" ] ; then
    echo "$(printArrIndex "${menu}" "6")"
    anyKey "$(printArrIndex "${menu}" "13")"
    exit 1
  fi
}

# Функция выхода из скрипта
function bye() {
  echo "$(printArrIndex "${menu}" "14")"
  exit 0
}

# Функция для проведения сборки проекта
function build() {
  # Очиска экрана
  clear
  # Убедимся в наличии файла CMakeLists.txt
    if [ ! -f "$2""CMakeLists.txt" ] ; then
      echo "$(printArrIndex "${menu}" 9)"
      anyKey "$(printArrIndex "${menu}" 13)"
      return 1
    fi
  # Создание каталога
  if ( ! createDir $1 ); then
    echo "$(printArrIndex "${menu}" 8)"
    anyKey "$(printArrIndex "${menu}" 13)"
    return 1
  fi
  #Переход в каталог сборки
  cd "$1"
  #Генерируем Makefile и собираем проект
  if (cmake $2) && (make); then
    # Проект собран успешно
    echo "$(printArrIndex "${menu}" 10)"
    anyKey "$(printArrIndex "${menu}" 13)"
    return 0
  else
    # Ошибка
    echo "$(printArrIndex "${menu}" 11)"
    anyKey "$(printArrIndex "${menu}" 13)"
    return 1
  fi
}

# Функция для проведения подготовки сборки проекта
function buildPreparation() {
  while true; do
    # Очистка
    clear
      # Добавим в конец списка проектов пункт "Назад"
    local prj_menu=$(pushBackArr ${project} $(printArrIndex "${menu}" 7))
    # Вывод заголовка сборки
    printArrIndex "${menu}" 5
    # Вывод списка проектов
    printArr "${prj_menu}"
    # Ожидаем "решения пользователя"
    local num=$(getNumber "$(getArrSize "${prj_menu}")" "$(printArrIndex "${menu}" 12)")
    # Если выбранно "Назад" выходим в главное меню
    if (("$num"=="$(getArrSize "${prj_menu}")")); then
      return 0
    fi
    # Получение имени пректа
    let "num -= 1"
    # Формируем путь до cmake файла
    local cmakePath="${cmakeDir}""/""$(printArrIndex "${prj_menu}" "${num}")""/"
    # Формируем путь сборки
    local buildPath="${buildDir}""/""$(printArrIndex "${prj_menu}" "${num}")""/"
    # Сборка
    build "${buildPath}" "${cmakePath}"
  done
}

# Главная функция 
function main() {
  while true; do
    # Очистка
    clear
    # Вывод заголовка
    printArrIndex "${menu}" 0
    # Вывод основного меню
    printArrRange "${menu}" 1 4
    # Ожидаем "решения пользователя"
    local num=$(getNumber "4" "$(printArrIndex "${menu}" 12)")
    # Выполняем команду
    case "${num}" in
      1)
        # Подготовка и сборка нужного проекта
        buildPreparation
      ;;
      2)
        # Запуск нужного проекта если он был собран ранее
        lecho "To-Do Run"
      ;;
      3)
        # Очиска каталога сборки
        lecho "To-Do Clear"
      ;;
      4)
        # Выход
        bye
    esac
  done
}

# Загрузка и выбор языка
setLang
# Загрузка проектов
loadProject
# Главное меню
main
