#!/bin/bash

# Проверка запущен ли скрипт под root
function isRoot() {
  if [[ $EUID -ne 0 ]]; then
    return 1
  else
    return 0
  fi
}

function createDir () {
  if ([ ! -n "$1" ]); then 
    echo "Error: createDir -> param is empty"
    exit 1
  fi
  if [ -d $1 ]; then
    return 0
  else
    if ( mkdir -p $1 ); then
      return 0
    else 
      echo "Error: createDir -> $1"
      return 1
    fi
  fi
}

# Вспомогательная функция для получение дистрибутива
function detectDistrib_parser() {
  if [ ! -n "$1" ] ; then
    echo ""
    return
  elif ( grep 'CentOS' <<< $1 > /dev/null 2>&1 ) ; then echo "CentOS"
  elif ( grep 'Red' <<< $1 > /dev/null 2>&1 ) ; then echo "RedHat"
  elif ( grep 'Fedora' <<< $1 > /dev/null 2>&1 ) ; then echo "Fedora"
  elif ( grep 'buntu' <<< $1 > /dev/null 2>&1 ) ; then echo "Ubuntu"
  elif ( grep 'Debian' <<< $1 > /dev/null 2>&1 ) ; then echo "Debian"
  elif ( grep 'Mint' <<< $1 > /dev/null 2>&1 ) ; then echo "Mint"
  elif ( grep 'Knoppix' <<< $1 > /dev/null 2>&1 ) ; then echo "Knoppix"
  else
    echo ""
  fi
}

# Получение дистрибутива через lsb_release
function detectDistrib_lsb() {
  local LSB=$( which lsb_release )
  if [ -n "$LSB" ] ; then
    local result_lsb=$( $LSB -a 2>/dev/null | grep -i 'Distributor' | cut -s -f2)
    local result=$( detectDistrib_parser "$result_lsb")
    if [ -n "$result" ] ; then
      echo "$result"
    else
      echo ""
    fi
  else
    echo ""
  fi
}

# Получение дистрибутива через hostnamectl
function detectDistrib_ctl() {
  local HNC=$( which hostnamectl )
  if [ -n "$HNC" ] ; then
    local result_hnc=$( $HNC | grep 'Operating System:' )
    local result=$( detectDistrib_parser "$result_hnc")
    if [ -n "$result" ] ; then
      echo "$result"
    else
      echo ""
    fi
  else
    echo ""
  fi
}

# Получение дистрибутива через парсинг файла /proc/version
function detectDistrib_file_version() {
  local result_fv=$( cat /proc/version)
  local result=$( detectDistrib_parser "$result_fv")
  if [ -n "$result" ] ; then
    echo "$result"
  else
    echo ""
  fi
}

# Получение дистрибутива через парсинг файла /etc/*-release*
function detectDistrib_file_release() {
  local result_fr=$( cat /etc/*-release* )
  local result=$( detectDistrib_parser "$result_fr")
  if [ -n "$result" ] ; then
    echo "$result"
  else
    echo ""
  fi
}

# Обобщающая функция для опрееления дистрибутива
# Каждая вызываемая функция возвращает либо имя дистрибутива либо пустую строку
# При первом нахождении имени дистрибутива остальные вызовы пропускаются
function detectDistrib() {
  local test_distrib=""
  test_distrib=$( detectDistrib_lsb )
  if [ -n "$test_distrib" ] ; then
    echo "$test_distrib"
    return
  fi
  test_distrib=$( detectDistrib_ctl )
  if [ -n "$test_distrib" ] ; then
    echo "$test_distrib"
    return
  fi
  test_distrib=$( detectDistrib_file_version )
  if [ -n "$test_distrib" ] ; then
    echo "$test_distrib"
    return
  fi
  test_distrib=$( detectDistrib_file_release )
  if [ -n "$test_distrib" ] ; then
    echo "$test_distrib"
    return
  fi
  return ""
}