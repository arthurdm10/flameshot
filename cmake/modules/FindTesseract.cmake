# FindTesseract.cmake
#
# Finds the Tesseract OCR library.
#
# This will define:
# Tesseract_FOUND        - True if Tesseract was found
# Tesseract_INCLUDE_DIRS - The Tesseract include directories
# Tesseract_LIBRARIES    - The Tesseract libraries

find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
    pkg_check_modules(PC_TESSERACT QUIET tesseract)
endif()

find_path(Tesseract_INCLUDE_DIR
    NAMES tesseract/baseapi.h
    HINTS ${PC_TESSERACT_INCLUDE_DIRS}
    PATHS /usr/include /usr/local/include
)

find_library(Tesseract_LIBRARY
    NAMES tesseract
    HINTS ${PC_TESSERACT_LIBRARY_DIRS}
    PATHS /usr/lib /usr/local/lib
)

if (Tesseract_INCLUDE_DIR AND Tesseract_LIBRARY)
    set(Tesseract_FOUND TRUE)
    set(Tesseract_LIBRARIES ${Tesseract_LIBRARY})
    set(Tesseract_INCLUDE_DIRS ${Tesseract_INCLUDE_DIR})
    
    if(NOT TARGET Tesseract::Tesseract)
        add_library(Tesseract::Tesseract UNKNOWN IMPORTED)
        set_target_properties(Tesseract::Tesseract PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${Tesseract_INCLUDE_DIRS}"
            IMPORTED_LOCATION "${Tesseract_LIBRARIES}"
        )
    endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Tesseract DEFAULT_MSG Tesseract_LIBRARY Tesseract_INCLUDE_DIR)

mark_as_advanced(Tesseract_INCLUDE_DIR Tesseract_LIBRARY)
