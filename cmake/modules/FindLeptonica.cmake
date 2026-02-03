# FindLeptonica.cmake
#
# Finds the Leptonica library.

# 1. Try to find via CONFIG
find_package(Leptonica CONFIG QUIET)
if(NOT Leptonica_FOUND)
    find_package(leptonica CONFIG QUIET)
endif()

if(Leptonica_FOUND OR leptonica_FOUND)
    set(Leptonica_FOUND TRUE)
    
    if(TARGET Leptonica::leptonica)
        set(LEPT_TARGET Leptonica::leptonica)
    elseif(TARGET leptonica::leptonica)
        set(LEPT_TARGET leptonica::leptonica)
    elseif(TARGET leptonica)
        set(LEPT_TARGET leptonica)
    endif()

    if(LEPT_TARGET)
        if(NOT TARGET Leptonica::Leptonica)
            add_library(Leptonica::Leptonica INTERFACE IMPORTED)
            set_target_properties(Leptonica::Leptonica PROPERTIES
                INTERFACE_LINK_LIBRARIES ${LEPT_TARGET}
            )
        endif()
        
        get_target_property(LEPT_INC ${LEPT_TARGET} INTERFACE_INCLUDE_DIRECTORIES)
        if(LEPT_INC)
            set(Leptonica_INCLUDE_DIRS ${LEPT_INC})
        endif()
        set(Leptonica_LIBRARIES ${LEPT_TARGET})
    endif()
endif()

# 2. Fallback
if(NOT Leptonica_INCLUDE_DIRS OR NOT Leptonica_LIBRARIES)
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
