cmake_minimum_required(VERSION 3.16)
#cmake_minimum_required(VERSION 3.29.3)



# Force these settings because Qt Creator v15.0.1 (at least) keeps messing these settings up...
#if(MSVC)
#    message(STATUS "MSVC build in ${CMAKE_SOURCE_DIR}")
#    set(CMAKE_GENERATOR "Visual Studio 17 2022" CACHE STRING "CMake Generator" FORCE)
#    set(CMAKE_GENERATOR_PLATFORM "x64" CACHE STRING "Generator Platform" FORCE)
#else()
#    message(STATUS "non-MSVC build in ${CMAKE_SOURCE_DIR}")
#    set(CMAKE_GENERATOR "Ninja" CACHE STRING "CMake Generator" FORCE)
#    # Explicitly unset Visual Studio-specific variables for non-MSVC builds
#    unset(CMAKE_GENERATOR_PLATFORM CACHE)
#    unset(CMAKE_GENERATOR_TOOLSET CACHE)
#endif()



project(MediaCentre VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Force C++17 for Clang (LLVM-MinGW)
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    # For LLVM-MinGW (Clang-based)
    #add_compile_options(-std=c++17)
    # Ensure __cplusplus reflects C++17
    #add_compile_definitions(_WIN32_CLANG_TEST __cplusplus=201703L)
endif()

# Diagnostic output
message(STATUS "C++ standard set to: ${CMAKE_CXX_STANDARD}")


## Conan

# Define Conan output directory relative to build directory
set(CONAN_OUTPUT_DIR ${CMAKE_BINARY_DIR}/dependencies)

# Ensure Conan is installed
find_program(CONAN_EXECUTABLE conan)
if(NOT CONAN_EXECUTABLE)
    message(FATAL_ERROR "Conan not found. Please install it with 'pip install conan'.")
endif()

# Run 'conan install . --build=missing --output=./dependencies'
execute_process(
    COMMAND ${CONAN_EXECUTABLE} install . --build=missing --output-folder=${CONAN_OUTPUT_DIR}
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    RESULT_VARIABLE CONAN_RESULT
)
if(NOT CONAN_RESULT EQUAL 0)
    message(FATAL_ERROR "Conan install failed with result: ${CONAN_RESULT}")
endif()

# Include Conan-generated toolchain
include(${CONAN_OUTPUT_DIR}/conan_toolchain.cmake)

if(MSVC)
    message(STATUS "MSVC build in ${CMAKE_SOURCE_DIR}")
    set(CMAKE_GENERATOR "Visual Studio 17 2022" CACHE STRING "CMake Generator" FORCE)
    set(CMAKE_GENERATOR_PLATFORM "x64" CACHE STRING "Generator Platform" FORCE)
else()
    message(STATUS "non-MSVC build in ${CMAKE_SOURCE_DIR}")
    set(CMAKE_GENERATOR "Ninja" CACHE STRING "CMake Generator" FORCE)
    # Explicitly unset Visual Studio-specific variables for non-MSVC builds
    unset(CMAKE_GENERATOR_PLATFORM CACHE)
    unset(CMAKE_GENERATOR_TOOLSET CACHE)
endif()

# Find Qt
#find_package(Qt6 6.8.2 REQUIRED COMPONENTS Core Quick Multimedia)
find_package(Qt6 REQUIRED COMPONENTS Core Quick Multimedia)

# Find GStreamer
find_package(PkgConfig REQUIRED)
pkg_check_modules(GST REQUIRED gstreamer-1.0 gstreamer-video-1.0 gstreamer-audio-1.0 gstreamer-app-1.0)

# Explicitly set GStreamer library paths for Windows
if(WIN32)
    set(GST_LIBRARY_DIR "C:/gstreamer/1.0/msvc_x86_64/lib" CACHE PATH "Path to GStreamer libraries")
    link_directories(${GST_LIBRARY_DIR})
endif()

# Include directories
include_directories(${GST_INCLUDE_DIRS})

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appMediaCentre
    main.cpp
)

qt_add_qml_module(appMediaCentre
    URI MediaCentre
    VERSION 1.0
    QML_FILES
        Main.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appMediaCentre PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appMediaCentre
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appMediaCentre PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Multimedia
    ${GST_LIBRARIES}
)

include(GNUInstallDirs)
install(TARGETS appMediaCentre
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Copy QML files to build directory
set_target_properties(appMediaCentre PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}
)
file(COPY ${CMAKE_SOURCE_DIR}/main.qml DESTINATION ${CMAKE_BINARY_DIR})
