# Checkout remote repository
macro(clone_repo name url tag)
    string(TOLOWER ${name} name_lower)
    string(TOUPPER ${name} name_upper)

    if(NOT ${name_upper}_REPOSITORY)
        set(${name_upper}_REPOSITORY ${url})
    endif()
    if(NOT ${name_upper}_TAG)
        set(${name_upper}_TAG ${tag})
    endif()

    message(STATUS "Fetching ${name} ${${name_upper}_REPOSITORY} ${${name_upper}_TAG}")

    # Check for FetchContent cmake support
    if(${CMAKE_VERSION} VERSION_LESS 3.11)
        message(FATAL_ERROR "CMake 3.11 required to fetch ${name}")
    else()
        include(FetchContent)

        # EXCLUDE_FROM_ALL support was added to FetchContent in CMake 3.28.
        # For older versions, use FetchContent_Populate and add_subdirectory
        # with EXCLUDE_FROM_ALL manually.
        if(CMAKE_VERSION VERSION_LESS 3.28)
            FetchContent_Declare(${name}
                GIT_REPOSITORY ${${name_upper}_REPOSITORY}
                GIT_TAG ${${name_upper}_TAG}
                SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third_party/${name_lower})

            FetchContent_GetProperties(${name})
            if(NOT ${name_lower}_POPULATED)
                FetchContent_Populate(${name})
            endif()
        else()
            FetchContent_Declare(${name}
                GIT_REPOSITORY ${${name_upper}_REPOSITORY}
                GIT_TAG ${${name_upper}_TAG}
                SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third_party/${name_lower}
                EXCLUDE_FROM_ALL)

            FetchContent_MakeAvailable(${name})
        endif()

        set(${name_upper}_SOURCE_DIR ${${name_lower}_SOURCE_DIR})
        set(${name_upper}_BINARY_DIR ${${name_lower}_BINARY_DIR})

        # For CMake < 3.28, manually add subdirectory with EXCLUDE_FROM_ALL
        # if the fetched content has a CMakeLists.txt.
        # For CMake >= 3.28, FetchContent_MakeAvailable already handles this.
        if(CMAKE_VERSION VERSION_LESS 3.28)
            if(EXISTS ${${name_upper}_SOURCE_DIR}/CMakeLists.txt)
                add_subdirectory(${${name_upper}_SOURCE_DIR} ${${name_upper}_BINARY_DIR} EXCLUDE_FROM_ALL)
            endif()
        endif()
    endif()
endmacro()