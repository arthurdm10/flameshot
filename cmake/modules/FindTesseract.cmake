find_path(Tesseract_INCLUDE_DIR
  NAMES tesseract/baseapi.h
  PATHS /usr/include /usr/local/include
)

find_library(Tesseract_LIBRARY
  NAMES tesseract
  PATHS /usr/lib /usr/local/lib
)

if (Tesseract_INCLUDE_DIR AND Tesseract_LIBRARY)
  set(Tesseract_FOUND TRUE)
else()
  set(Tesseract_FOUND FALSE)
endif()

if (Tesseract_FOUND)
  message(STATUS "Found Tesseract: ${Tesseract_LIBRARY}")
  message(STATUS "Include directory: ${Tesseract_INCLUDE_DIR}")
  set(Tesseract_LIBRARIES ${Tesseract_LIBRARY})
  set(Tesseract_INCLUDE_DIRS ${Tesseract_INCLUDE_DIR})
else()
  message(FATAL_ERROR "Tesseract not found")
endif()