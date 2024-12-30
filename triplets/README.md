VCPKG allows either, static builds, or dynamic builds. However, we need to 
build libsndfile as a dynamic library, but its dependencies should be 
statically linked.

These custom triplets accomplish this. They are a copy of the official
{arm64,x64,x86}-windows triplets at https://github.com/microsoft/vcpkg/tree/master/triplets,
but with all libraries except libsndfile configured for static linkage.