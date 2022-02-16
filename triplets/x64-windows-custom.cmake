set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)  # Runtime always dynamically linked.
set(VCPKG_LIBRARY_LINKAGE static)  # Libs are static by default.
set(VCPKG_PLATFORM_TOOLSET v140)  # Enforce v140 toolset.
set(VCPKG_BUILD_TYPE release)  # Skip debug builds.

if (PORT STREQUAL libsndfile)  # Only libsndfile is dynamic.
	set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
