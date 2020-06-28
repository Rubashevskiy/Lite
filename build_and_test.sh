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
  lecho "Выход(Exit)"
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

function build() {
  clear
  local bDir="${BuildDir}""$(printArrIndex "${Project}" "$1")"
  if ( ! createDir ${bDir}); then
    lecho "$(printArrIndex "${Menu}" 10)"
    return 1
  fi
  
  local result
  if (("$2"=="1")); then
    local cDir="${CmakeDir}""$(printArrIndex "${Project}" "$1")"
    #Переход в каталог сборки
    cd "${bDir}"
    #Генерируем Makefile и собираем проект
    if (cmake ${cDir}) && (make); then
      result=0
    else
      result=1
    fi
  else
    local mDir="${ClassicDir}""$(printArrIndex "${Project}" "$1")""/Makefile"
    #Переход в каталог сборки
    cd "${bDir}"
    if (make -f "${mDir}"); then
      result=0
    else
      result=1
    fi
  fi
  local pResult="$(printArrIndex "${Menu}" 9) ""$(printArrIndex "${Project}" "$1")"": "
  if (("${result}"=="0")); then
    lecho "${pResult}""$(printArrIndex "${Menu}" 10)"
  else
    lecho "${pResult}""$(printArrIndex "${Menu}" 11)"
  fi
  anyKey
  return 0;
}

function buildPreparation() {
  while true; do
    clear
    local countMenu=$(getArrCount "${Project}")
    let "countMenu += 1"
    printArrIndex "${Menu}" 4
    printArr "${Project}"
    lecho "   ${countMenu}"": $(printArrIndex "${Menu}" 8)"
    getNumber 1 "${countMenu}"
    local buildPrj="$REPLY"
    let "buildPrj -= 1"
    if (("$REPLY"=="${countMenu}")); then
      return 0
    fi
    clear
    lecho "$(printArrIndex "${Menu}" 5) ""$(printArrIndex "${Project}" "${buildPrj}")"
    printArrRange "${Menu}" 6 8
    getNumber 1 3
    local buildType="$REPLY"
    if (("${buildType}"<"3")); then
      build ${buildPrj} ${buildType};
    fi
  done
}

function main() {
  while true; do
    # Очистка
    clear
    # Вывод заголовка на выбранном языке
    printArrIndex "${menu}" 0
    # Вывод основного меню
    printArrRange "${menu}" 1 4
    # Ожидаем "решения пользователя"
    getNumber 4 $(printArrIndex "${menu}" 14)
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

loadProject
setLanguage
main
