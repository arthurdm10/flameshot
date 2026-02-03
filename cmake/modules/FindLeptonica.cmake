# FindLeptonica.cmake
#
# Finds the Leptonica library.
#
# This will define:
# Leptonica_FOUND        - True if Leptonica was found
# Leptonica_INCLUDE_DIRS - The Leptonica include directories
# Leptonica_LIBRARIES    - The Leptonica libraries

find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
    pkg_check_modules(PC_LEPTONICA QUIET lept leptonica)
endif()

find_path(Leptonica_INCLUDE_DIR
    NAMES leptonica/allheaders.h
    HINTS ${PC_LEPTONICA_INCLUDE_DIRS}
    PATHS /usr/include /usr/local/include
)

find_library(Leptonica_LIBRARY
    NAMES lept leptonica
    HINTS ${PC_LEPTONICA_LIBRARY_DIRS}
    PATHS /usr/lib /usr/local/lib
)

if (Leptonica_INCLUDE_DIR AND Leptonica_LIBRARY)
    set(Leptonica_FOUND TRUE)
    set(Leptonica_LIBRARIES ${Leptonica_LIBRARY})
    set(Leptonica_INCLUDE_DIRS ${Leptonica_INCLUDE_DIR})

    if(NOT TARGET Leptonica::Leptonica)
        add_library(Leptonica::Leptonica UNKNOWN IMPORTED)
        set_target_properties(Leptonica::Leptonica PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${Leptonica_INCLUDE_DIRS}"
            IMPORTED_LOCATION "${Leptonica_LIBRARIES}"
        )
    endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Leptonica DEFAULT_MSG Leptonica_LIBRARY Leptonica_INCLUDE_DIR)

mark_as_advanced(Leptonica_INCLUDE_DIR Leptonica_LIBRARY)
