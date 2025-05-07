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

# Set Qt6 path for MSVC
if(WIN32 AND MSVC)
    message(STATUS "Defining Qt6_DIR")
    set(Qt6_DIR "C:/Qt/6.8.2/msvc2022_64/lib/cmake/Qt6" CACHE PATH "Path to Qt6 CMake config")
endif()

# Find Qt
find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick)

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
include_directories(${GST_INCLUDE_DIRS} ${CMAKE_SOURCE_DIR}/include)

# Explicitly set Windows SDK library path to ensure Mf.lib is found
if(WIN32)
    # Adjust the SDK version to match your installed version (e.g., 10.0.22621.0)
    set(WINDOWS_SDK_LIB_PATH "C:/Program Files (x86)/Windows Kits/10/Lib/10.0.22621.0/um/x64")
    link_directories(${WINDOWS_SDK_LIB_PATH})
    message(STATUS "Windows SDK library path: ${WINDOWS_SDK_LIB_PATH}")
endif()

qt_policy(SET QTP0004 NEW)

qt_standard_project_setup(REQUIRES 6.5)

# Include source and header CMake files
include(../src/sources.cmake)
include(../include/include.cmake)

message(STATUS "SOURCE_FILES: ${SOURCE_FILES}")

qt_add_executable(appMediaCentre
    ${HEADER_FILES}
    ${SOURCE_FILES}
    ${CMAKE_SOURCE_DIR}/resources.qrc
)

qt_add_qml_module(appMediaCentre
    URI MediaCentre
    VERSION 1.0
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

# Add include directory
include_directories(${CMAKE_SOURCE_DIR}/include)

# Temporary verbose output
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -v" CACHE STRING "Linker flags" FORCE)
endif()

# Verify that Media Foundation libraries are found
find_library(MF_LIB NAMES Mf mf PATHS ${WINDOWS_SDK_LIB_PATH})
find_library(MFPLAT_LIB NAMES mfplat Mfplat PATHS ${WINDOWS_SDK_LIB_PATH})
find_library(MFUUID_LIB NAMES mfuuid Mfuuid PATHS ${WINDOWS_SDK_LIB_PATH})
find_library(OLE32_LIB NAMES ole32 Ole32 PATHS ${WINDOWS_SDK_LIB_PATH})

if(MF_LIB)
    message(STATUS "Found Mf library: ${MF_LIB}")
else()
    message(WARNING "Mf library not found in ${WINDOWS_SDK_LIB_PATH}")
endif()

if(MFPLAT_LIB)
    message(STATUS "Found mfplat library: ${MFPLAT_LIB}")
else()
    message(WARNING "mfplat library not found in ${WINDOWS_SDK_LIB_PATH}")
endif()

if(MFUUID_LIB)
    message(STATUS "Found mfuuid library: ${MFUUID_LIB}")
else()
    message(WARNING "mfuuid library not found in ${WINDOWS_SDK_LIB_PATH}")
endif()

if(OLE32_LIB)
    message(STATUS "Found ole32 library: ${OLE32_LIB}")
else()
    message(WARNING "ole32 library not found in ${WINDOWS_SDK_LIB_PATH}")
endif()

target_link_libraries(appMediaCentre PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    ${GST_LIBRARIES}
    # Add MinGW runtime libs for Clang
    $<$<CXX_COMPILER_ID:Clang>:${MINGW_LIB_DIR}/libmingw32.a>
    $<$<CXX_COMPILER_ID:Clang>:${MINGW_LIB_DIR}/libssp.a>
    # Add Media Foundation and COM libraries for webcam enumeration
    Mf
    mfplat
    mfuuid
    ole32
)

include(GNUInstallDirs)
install(TARGETS appMediaCentre
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Define paths (adjust these based on your system)
set(QT_DIR "C:/Qt/6.8.2/msvc2022_64")
set(GSTREAMER_DIR "C:/gstreamer/1.0/msvc_x86_64")
set(QML_SOURCE_DIR "${CMAKE_SOURCE_DIR}/qml")

# --- Deploy Qt DLLs with windeployqt ---
add_custom_command(TARGET appMediaCentre POST_BUILD
    COMMAND ${QT_DIR}/bin/windeployqt.exe
        --qmldir ${QML_SOURCE_DIR}
        $<TARGET_FILE:appMediaCentre>
    COMMENT "Deploying Qt dependencies with windeployqt"
    WORKING_DIRECTORY $<TARGET_FILE_DIR:appMediaCentre>
)

# --- Copy GStreamer Core DLLs ---
add_custom_command(TARGET appMediaCentre POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${GSTREAMER_DIR}/bin"
        $<TARGET_FILE_DIR:appMediaCentre>
    COMMENT "Copying GStreamer core DLLs to Release directory"
)

# --- Copy GStreamer Plugins ---
add_custom_command(TARGET appMediaCentre POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${GSTREAMER_DIR}/lib/gstreamer-1.0"
        $<TARGET_FILE_DIR:appMediaCentre>/gstreamer-1.0
    COMMENT "Copying GStreamer plugins to Release/gstreamer-1.0 directory"
)
