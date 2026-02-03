# FindLeptonica.cmake
#
# Finds the Leptonica library.

# 1. Try to find via CONFIG
find_package(leptonica CONFIG QUIET)
if(leptonica_FOUND)
    if(NOT TARGET Leptonica::Leptonica)
        if(TARGET leptonica)
            add_library(Leptonica::Leptonica INTERFACE IMPORTED)
            set_target_properties(Leptonica::Leptonica PROPERTIES
                INTERFACE_LINK_LIBRARIES leptonica
            )
        endif()
    endif()
    set(Leptonica_FOUND TRUE)
    if(TARGET leptonica)
        get_target_property(Leptonica_INCLUDE_DIRS leptonica INTERFACE_INCLUDE_DIRECTORIES)
        set(Leptonica_LIBRARIES leptonica)
    endif()
endif()

if(NOT Leptonica_FOUND)
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
        NAMES lept leptonica libleptonica leptonica-1.85.0 leptonica-1.84.1 leptonica-1.84.0 leptonica-1.83.0 leptonica-1.82.0
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
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Leptonica DEFAULT_MSG Leptonica_LIBRARIES Leptonica_INCLUDE_DIRS)

mark_as_advanced(Leptonica_INCLUDE_DIR Leptonica_LIBRARY)