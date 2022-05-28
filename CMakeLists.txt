cmake_minimum_required(VERSION 3.14)

# Project properties
set(PROJECT_ORG cmake-wheel)
set(PROJECT_NAME ${PROJECT_ORG}-example)
set(PROJECT_DESCRIPTION "This is an example project, to show how to use cmeel")
set(PROJECT_URL https://github.com/${PROJECT_NAMESPACE}/${PROJECT_NAME})

# Project options
option(BUILD_PYTHON_INTERFACE "Build the python binding" ON)
option(SUFFIX_SO_VERSION "Suffix library name with its version" ON)

# Project configuration
set(PROJECT_USE_CMAKE_EXPORT TRUE)
set(CUSTOM_HEADER_DIR ${PROJECT_ORG}/example)

include(FetchContent)
FetchContent_Declare("jrl-cmakemodules"
  GIT_REPOSITORY "https://github.com/nim65s/jrl-cmakemodules.git"
  GIT_TAG "py-dev")
FetchContent_MakeAvailable("jrl-cmakemodules")
FetchContent_GetProperties("jrl-cmakemodules" SOURCE_DIR JRL_CMAKE_MODULES)

# JRL-cmakemodule setup
include("${JRL_CMAKE_MODULES}/base.cmake")
include("${JRL_CMAKE_MODULES}/python.cmake")

# Project definition
COMPUTE_PROJECT_ARGS(PROJECT_ARGS LANGUAGES CXX)
project(${PROJECT_NAME} ${PROJECT_ARGS})

# Project dependencies
find_package(pybind11 QUIET)

if(NOT pybind11_FOUND)
  FetchContent_Declare("pybind11"
    GIT_REPOSITORY "https://github.com/pybind/pybind11.git")
  FetchContent_MakeAvailable("pybind11")
endif()

if(BUILD_PYTHON_INTERFACE)
  FINDPYTHON()
  string(REGEX REPLACE "-" "_" PY_NAME ${PROJECT_NAME})
  set(${PY_NAME}_INSTALL_DIR ${PYTHON_SITELIB}/${PY_NAME})
endif()

# Main Library
set(${PROJECT_NAME}_HEADERS
  include/${HEADER_DIR}/adder.hpp
  )

set(${PROJECT_NAME}_SOURCES
  src/adder.cpp
  )

add_library(${PROJECT_NAME} SHARED ${${PROJECT_NAME}_SOURCES} ${${PROJECT_NAME}_HEADERS})
target_include_directories(${PROJECT_NAME} PUBLIC $<INSTALL_INTERFACE:include>)

if(SUFFIX_SO_VERSION)
  set_target_properties(${PROJECT_NAME} PROPERTIES SOVERSION ${PROJECT_VERSION})
endif()

# Main Executable
set(${PROJECT_NAME}_EXE ${PROJECT_ORG}-add)
add_executable(${${PROJECT_NAME}_EXE} src/main.cpp)
target_link_libraries(${${PROJECT_NAME}_EXE} ${PROJECT_NAME})
set_target_properties(${${PROJECT_NAME}_EXE} PROPERTIES
  INSTALL_RPATH "\$ORIGIN/../lib")

# Python Bindings
if(BUILD_PYTHON_INTERFACE)
  add_subdirectory(python)
endif()

# Unit tests
add_subdirectory(tests)

# Installation
install(TARGETS ${PROJECT_NAME} EXPORT ${TARGETS_EXPORT_NAME} DESTINATION ${CMAKE_INSTALL_LIBDIR})
install(TARGETS ${${PROJECT_NAME}_EXE} RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(FILES package.xml DESTINATION share/${PROJECT_NAME})
