# FindTesseract.cmake
#
# Finds the Tesseract OCR library.

# 1. Try to find via CONFIG (vcpkg and modern installs)
find_package(Tesseract CONFIG QUIET)
if(NOT Tesseract_FOUND)
    find_package(tesseract CONFIG QUIET)
endif()

if(Tesseract_FOUND OR tesseract_FOUND)
    set(Tesseract_FOUND TRUE)
    
    # Try to find the best available target
    if(TARGET Tesseract::libtesseract)
        set(TESS_TARGET Tesseract::libtesseract)
    elseif(TARGET tesseract::libtesseract)
        set(TESS_TARGET tesseract::libtesseract)
    elseif(TARGET libtesseract)
        set(TESS_TARGET libtesseract)
    endif()

    if(TESS_TARGET)
        if(NOT TARGET Tesseract::Tesseract)
            add_library(Tesseract::Tesseract INTERFACE IMPORTED)
            set_target_properties(Tesseract::Tesseract PROPERTIES
                INTERFACE_LINK_LIBRARIES ${TESS_TARGET}
            )
        endif()
        
        get_target_property(TESS_INC ${TESS_TARGET} INTERFACE_INCLUDE_DIRECTORIES)
        if(TESS_INC)
            set(Tesseract_INCLUDE_DIRS ${TESS_INC})
        endif()
        set(Tesseract_LIBRARIES ${TESS_TARGET})
    endif()
endif()

# 2. Fallback to manual search if CONFIG failed or didn't provide enough info
if(NOT Tesseract_INCLUDE_DIRS OR NOT Tesseract_LIBRARIES)
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
        NAMES tesseract libtesseract tesseract55 tesseract54 tesseract53 tesseract52 tesseract51 tesseract50
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
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Tesseract DEFAULT_MSG Tesseract_LIBRARIES Tesseract_INCLUDE_DIRS)

mark_as_advanced(Tesseract_INCLUDE_DIR Tesseract_LIBRARY)
