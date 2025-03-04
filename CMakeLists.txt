cmake_minimum_required(VERSION 3.29.3)

# Conan integration

set(CONAN_OUTPUT_DIR ${CMAKE_BINARY_DIR}/dependencies)

# Ensure Conan is installed
find_program(CONAN_EXECUTABLE conan)
if(NOT CONAN_EXECUTABLE)
    message(FATAL_ERROR "Conan not found. Please install it with 'pip install conan'.")
endif()

# Run conan install
if(CMAKE_GENERATOR MATCHES "Ninja")
    message(STATUS "Using MinGW profile for Ninja build")
    execute_process(
        COMMAND ${CONAN_EXECUTABLE} install . -b missing -pr:h mingw -pr:b mingw -of ${CONAN_OUTPUT_DIR}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        RESULT_VARIABLE CONAN_RESULT
    )
else()
    message(STATUS "Using default profile for MSVC build")
    execute_process(
        COMMAND ${CONAN_EXECUTABLE} install . -b missing -of ${CONAN_OUTPUT_DIR}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        RESULT_VARIABLE CONAN_RESULT
    )
endif()

if(NOT CONAN_RESULT EQUAL 0)
    message(FATAL_ERROR "Conan install failed with result: ${CONAN_RESULT}")
endif()

# Include Conan-generated toolchain
include(${CONAN_OUTPUT_DIR}/conan_toolchain.cmake)

project(MediaCentre VERSION 0.1 LANGUAGES CXX)

# Generator settings after project() to ensure MSVC is detected
if(MSVC)
    message(STATUS "MSVC build confirmed in ${CMAKE_SOURCE_DIR}")
    set(CMAKE_GENERATOR "Visual Studio 17 2022" CACHE STRING "CMake Generator" FORCE)
    set(CMAKE_GENERATOR_PLATFORM "x64" CACHE STRING "Generator Platform" FORCE)
else()
    message(STATUS "non-MSVC build confirmed in ${CMAKE_SOURCE_DIR}")
    set(CMAKE_GENERATOR "Ninja" CACHE STRING "CMake Generator" FORCE)
    unset(CMAKE_GENERATOR_PLATFORM CACHE)
    unset(CMAKE_GENERATOR_TOOLSET CACHE)
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Diagnostic output
message(STATUS "C++ standard set to: ${CMAKE_CXX_STANDARD}")

# Find Qt
find_package(Qt6 REQUIRED COMPONENTS Core Quick Multimedia)

# Set PKG_CONFIG_PATH for GStreamer
if(WIN32)
    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        set(ENV{PKG_CONFIG_PATH} "C:/gstreamer/1.0/mingw_x86_64/lib/pkgconfig;$ENV{PKG_CONFIG_PATH}")
    else()
        set(ENV{PKG_CONFIG_PATH} "C:/gstreamer/1.0/msvc_x86_64/lib/pkgconfig;$ENV{PKG_CONFIG_PATH}")
    endif()
endif()

# Find GStreamer
find_package(PkgConfig REQUIRED)
pkg_check_modules(GST REQUIRED gstreamer-1.0 gstreamer-video-1.0 gstreamer-audio-1.0 gstreamer-app-1.0)

# Explicitly set GStreamer library paths for Windows
if(WIN32)
    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        set(GST_LIBRARY_DIR "C:/gstreamer/1.0/mingw_x86_64/lib" CACHE PATH "Path to GStreamer libraries")
        set(MINGW_LIB_DIR "C:/Qt/Tools/llvm-mingw1706_64/x86_64-w64-mingw32/lib" CACHE PATH "Path to MinGW runtime libraries")
    else()
        set(GST_LIBRARY_DIR "C:/gstreamer/1.0/msvc_x86_64/lib" CACHE PATH "Path to GStreamer libraries")
    endif()
    link_directories(${GST_LIBRARY_DIR} $<$<CXX_COMPILER_ID:Clang>:${MINGW_LIB_DIR}>)
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
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}
)

# Temporary verbose output
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -v" CACHE STRING "Linker flags" FORCE)
endif()

target_link_libraries(appMediaCentre PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Multimedia
    ${GST_LIBRARIES}
    # Add MinGW runtime libs for Clang
    $<$<CXX_COMPILER_ID:Clang>:${MINGW_LIB_DIR}/libmingw32.a>
    $<$<CXX_COMPILER_ID:Clang>:${MINGW_LIB_DIR}/libssp.a>
)

include(GNUInstallDirs)
install(TARGETS appMediaCentre
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Copy QML files to build directory
file(COPY ${CMAKE_SOURCE_DIR}/main.qml DESTINATION ${CMAKE_BINARY_DIR})
