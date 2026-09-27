cmake_minimum_required(VERSION 3.22.1)
project(n42_camera_core_surface LANGUAGES CXX)

# Maintained, single-target overlay on the exact AndroidX 1.6.1 boundary source.
# The upstream CMake configures the separate libyuv image-processing target.
add_library(surface_util_jni SHARED upstream/surface_util_jni.cc)
set_target_properties(surface_util_jni PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF)
target_compile_options(surface_util_jni PRIVATE
    -fvisibility=hidden
    -ffunction-sections
    -fdata-sections
    -flto)
target_link_libraries(surface_util_jni PRIVATE android)
target_link_options(surface_util_jni PRIVATE
    "-Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/upstream/jni.lds"
    # AndroidX lists optional JNI_OnLoad/Unload exports; this target defines neither.
    "-Wl,--undefined-version"
    "-Wl,-z,max-page-size=16384"
    "-Wl,-z,common-page-size=16384"
    "-Wl,-z,relro"
    "-Wl,-z,now"
    "-Wl,--gc-sections")
