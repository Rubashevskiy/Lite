cmake_minimum_required(VERSION 3.0)
project(exception_test)
set(CMAKE_CXX_STANDARD 11)
set(SRC "../../example/exception/main.cpp")
add_executable(${PROJECT_NAME} ${SRC})
add_definitions(-g -export-dynamic -ldl)
target_link_libraries(${PROJECT_NAME} ${CMAKE_DL_LIBS})
