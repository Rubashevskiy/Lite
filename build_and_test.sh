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

# Каталог для проведения сборки проектов(временная, удаляется при очистки)
buildDir="${PWD}/build/"
# Каталог размещения примеров
projectDir="${PWD}/example/"
# Каталог размещения файлов cmake(CMakeLists.txt)
cmakeFileDir="${PWD}/cmake/"
# Каталог размещения файлов make(Makefile)
makeFileDir="${PWD}/make/"
# Каталог размещения файлов "языков меню"
languageDir="${PWD}/bash/language/"

# Функция выхода из скрипта
function bye() {
  lecho "$(printArrIndex "${menu}" "4")"
  exit 0
}

#   Функция для получения каталогов с тестовыми проектами
# и вставка имен в "strArr(:) масив" для дальнейшей работы
# (поддержка имен содержащих пробелы)
function loadProject() {
  local fDir
  # Проход в цикле по всем директориям в каталоге
  for dir in  ${projectDir}*
  do
    # Если это директория добавляем
    if [ -d "${dir}" ]; then
      # Обрезаем полный путь
      fDir=$(lecho "${dir}" | awk -F / '{print $NF}')
      # Требование "strArr(:) масива" - Разделитель должен стоять только после значения
      if [ -n "${project}" ] ; then
        project+=":"
      fi
      # Добавляем в "strArr(:) масив" название тестового примера
      project+="${fDir}"
    fi
  done
}

# Функция выбора и загрузки языка меню
function setLanguage() {
  # Очиска экрана
  clear
  # Загрузка списка языков
  local fileLanguageArr
  local fDir
  # Проход в цикле по всем директориям в каталоге
  for dir in  ${languageDir}*
  do
    # Обрезаем полный путь
    fDir=$(lecho "${dir}" | awk -F / '{print $NF}')
    # Требование "strArr(:) масива" - Разделитель должен стоять только после значения
    if [ -n "${fileLanguageArr}" ] ; then
      fileLanguageArr+=":"
    fi
      # Добавляем в "strArr(:) масив" имя файла языка
      fileLanguageArr+="${fDir}"
  done
  
  # Вывод приглашения
  lecho "Выбор языка меню/Auswahl der Menüsprache/Menu language selection"
  # Вывод языков
  printArr "${fileLanguageArr}"
  # Подготовка сообщения для выбора
  local msgLanguage=$(lecho "Выберете номер/Wähle eine Nummer/Choose a number")
  # Выбор пользователем языка
  getNumber $(getArrSize "${fileLanguageArr}") "$msgLanguage"
  # Получаем индекс выбранного языка
  local num="$REPLY"
  let "num -= 1"
  # Формируем путь до требуемого языка
  local fileMenu="${languageDir}""$(printArrIndex "${fileLanguageArr}" "${num}")"
  # Загрузка файла меню
  while IFS= read -r line
  do
    # Требование "strArr(:) масива" - Разделитель должен стоять только после значения
    if [ -n "${menu}" ] ; then
      menu+=":"
    fi
    menu+="$line"
  done <"$fileMenu"
}

# Функция для проведения сборки проекта
function build() {
  # Очиска экрана
  clear
  # Формируем папку для сборки проекта
  local bDir="${buildDir}""$(printArrIndex "${project}" "$1")"
  # Создание каталога
  if ( ! createDir ${bDir}); then
    lecho "$(printArrIndex "${menu}" 14)"
    return 1
  fi
  # Формируем результирующую строку
  local pResult="$(printArrIndex "${menu}" 10) ""$(printArrIndex "${project}" "$1")"": "
  # Собираем Cmake
  if (("$2"=="1")); then
    # Формируем путь до cmake файла(CMakeLists.txt)
    local cDir="${cmakeFileDir}""$(printArrIndex "${project}" "$1")"
    #Переход в каталог сборки
    cd "${bDir}"
    #Генерируем Makefile и собираем проект
    if (cmake ${cDir}) && (make); then
      # Проект собран успешно
      lecho "${pResult}""$(printArrIndex "${menu}" 11)"
      anyKey "$(printArrIndex "${menu}" 15)"
      return 0
    else
      # Ошибка
      lecho "${pResult}""$(printArrIndex "${menu}" 12)"
      anyKey "$(printArrIndex "${menu}" 15)"
      return 1
    fi
  else
    # Формируем путь до make файла(Makefile)
    local mDir="${makeFileDir}""$(printArrIndex "${project}" "$1")""/Makefile"
    # Переход в каталог сборки
    cd "${bDir}"
    # собираем проект make
    if (make -f "${mDir}"); then
      # Проект собран успешно
      lecho "${pResult}""$(printArrIndex "${menu}" 11)"
      anyKey "$(printArrIndex "${menu}" 15)"
      return 0
    else
      # Ошибка
      lecho "${pResult}""$(printArrIndex "${menu}" 12)"
      anyKey "$(printArrIndex "${menu}" 15)"
      return 1
    fi
  fi
}

# Функция для проведения подготовки сборки проекта
function buildPreparation() {
  while true; do
    # Очистка
    clear
    # Вывод заголовка сборки
    printArrIndex "${menu}" 5
    # Вывод списка проектов
    printArr "${project}"
    # Получим число проектов
    local countMenu=$(getArrSize "${project}")
    # Добавим в меню "Назад"
    let "countMenu += 1"
    lecho "   ${countMenu}"": $(printArrIndex "${menu}" 9)"
    # Ожидаем "решения пользователя"
    getNumber "${countMenu}" "$(printArrIndex "${menu}" 13)"
    # Если выбранно "Назад" выходим в главное меню
    if (("$REPLY"=="${countMenu}")); then
      return 0
    fi
    # Получаем индекс проекта в масиве
    local buildNum="$REPLY"
    let "buildNum -= 1"
    # Очистка
    clear
    # Заголовок меню выбора "тип сборки"
    lecho "$(printArrIndex "${menu}" 6): ""$(printArrIndex "${project}" "${buildNum}")"
    # Вывод вариантов "сборки"
    printArrRange "${menu}" 7 9
    # Ожидаем "решения пользователя"
    getNumber "3" "$(printArrIndex "${menu}" 13)"
    # Сохраним выбор
    local buildType="$REPLY"
    # Если "тип сборки" выбран - отправляем на сборку
    if (("${buildType}"<"3")); then
      build "${buildPrj}" "${buildType}"
    fi
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
    getNumber 4 "$(printArrIndex "${menu}" 13)"
    # Выполняем команду
    case "$REPLY" in
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

# Загрузка проектов
loadProject
# Загрузка и выбор языка
setLanguage
# Главное меню
main
