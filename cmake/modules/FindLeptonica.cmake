find_path(Leptonica_INCLUDE_DIR
  NAMES leptonica/allheaders.h
  PATHS /usr/include /usr/local/include
)

find_library(Leptonica_LIBRARY
  NAMES lept
  PATHS /usr/lib /usr/local/lib
)

if (Leptonica_INCLUDE_DIR AND Leptonica_LIBRARY)
  set(Leptonica_FOUND TRUE)
else()
  set(Leptonica_FOUND FALSE)
endif()

if (Leptonica_FOUND)
  message(STATUS "Found Leptonica: ${Leptonica_LIBRARY}")
  message(STATUS "Include directory: ${Leptonica_INCLUDE_DIR}")
  set(Leptonica_LIBRARIES ${Leptonica_LIBRARY})
  set(Leptonica_INCLUDE_DIRS ${Leptonica_INCLUDE_DIR})
else()
  message(FATAL_ERROR "Leptonica not found")
endif()