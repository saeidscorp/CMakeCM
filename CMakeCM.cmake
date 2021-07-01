macro(_cmcm_set_if_undef varname)
    if(NOT DEFINED "${varname}")
        set(__default "${ARGN}")
    else()
        set(__default "${${varname}}")
    endif()
    set("${varname}" "${__default}" CACHE STRING "" FORCE)
endmacro()

# This is the base URL to resolve `LOCAL` modules
_cmcm_set_if_undef(CMCM_LOCAL_RESOLVE_URL "https://vector-of-bool.github.io/CMakeCM")
# This is the directory where CMakeCM will store its downloaded modules
_cmcm_set_if_undef(CMCM_MODULE_DIR "${CMAKE_BINARY_DIR}/_cmcm-modules")

function(cmcm_module name)
    set(options)
    set(args REMOTE LOCAL VERSION)
    set(list_args ALSO)
    cmake_parse_arguments(ARG "${options}" "${args}" "${list_args}" "${ARGV}")
    if(NOT ARG_REMOTE AND NOT ARG_LOCAL)
        message(FATAL_ERROR "Either LOCAL or REMOTE is required for cmcm_module")
    endif()
    if(NOT ARG_VERSION)
        message(FATAL_ERROR "Expected a VERSION for cmcm_module")
    endif()
    file(MAKE_DIRECTORY "${CMCM_MODULE_DIR}")
    file(WRITE "${CMCM_MODULE_DIR}/${name}"
        "_cmcm_include_module([[${name}]] [[${ARG_REMOTE}]] [[${ARG_LOCAL}]] [[${ARG_VERSION}]] [[${ARG_ALSO}]])\n"
        )
endfunction()

macro(_cmcm_include_module name remote local version also)
    set(__module_name "${name}")
    set(__remote "${remote}")
    set(__local "${local}")
    set(__version "${version}")
    get_filename_component(__resolved_dir "${CMCM_MODULE_DIR}/resolved" ABSOLUTE)
    get_filename_component(__resolved "${__resolved_dir}/${__module_name}" ABSOLUTE)
    get_filename_component(__resolved_stamp "${CMCM_MODULE_DIR}/resolved/${__module_name}.whence" ABSOLUTE)
    set(__whence_string "${CMCM_LOCAL_RESOLVE_URL}::${__remote}${__local}.${__version}")
    set(__download FALSE)
    if(EXISTS "${__resolved}")
        file(READ "${__resolved_stamp}" __stamp)
        if(NOT __stamp STREQUAL __whence_string)
            set(__download TRUE)
        endif()
    else()
        set(__download TRUE)
    endif()
    if(__download)
        file(MAKE_DIRECTORY "${__resolved_dir}")
        if(__remote)
            set(__url "${__remote}")
        else()
            set(__url "${CMCM_LOCAL_RESOLVE_URL}/${__local}")
        endif()
        message(STATUS "[CMakeCM] Downloading new module ${__module_name}")
        file(DOWNLOAD
            "${__url}"
            "${__resolved}"
            STATUS __st
            )
        list(GET __st 0 __rc)
        list(GET __st 1 __msg)
        if(__rc)
            message(FATAL_ERROR "Error while downloading file from '${__url}' to '${__resolved}' [${__rc}]: ${__msg}")
        endif()
        file(WRITE "${__resolved_stamp}" "${__whence_string}")
    endif()
    include("${__resolved}")
endmacro()

list(INSERT CMAKE_MODULE_PATH 0 "${CMCM_MODULE_DIR}")

cmcm_module(FindFilesystem.cmake
    LOCAL modules/FindFilesystem.cmake
    VERSION 2
    )

cmcm_module(CMakeRC.cmake
    REMOTE https://github.com/saeidscorp/cmrc/raw/9949a1cc237dd1ace568e96ba7b0ce2ebe33ddae/CMakeRC.cmake
    VERSION 1
    )

cmcm_module(FindBikeshed.cmake
    LOCAL modules/FindBikeshed.cmake
    VERSION 2
    )
    
cmcm_module(cotire.cmake
    REMOTE https://github.com/sakra/cotire/releases/download/cotire-1.8.0/cotire.cmake
    VERSION 1.8.0
    )

cmcm_module(C++Concepts.cmake
    LOCAL modules/C++Concepts.cmake
    VERSION 1
    )

cmcm_module(libman.cmake
    REMOTE https://github.com/vector-of-bool/libman/raw/85c5d23e700a9ed6b428aa78cfa556f60b925477/cmake/libman.cmake
    VERSION 1
    )

cmcm_module(cs-tools.cmake
    REMOTE https://github.com/StableCoder/cmake-scripts/raw/6c11e34cae48205cad84f4e433083c0579e7fa6b/tools.cmake
    VERSION 1
    )

cmcm_module(cs-c++-standards.cmake
    REMOTE https://github.com/StableCoder/cmake-scripts/raw/31cbfce8d84054aa6acbaf49b9121ab8789ec7bb/c%2B%2B-standards.cmake
    VERSION 1
    )

cmcm_module(cs-sanitizers.cmake
    REMOTE https://github.com/StableCoder/cmake-scripts/raw/2531dd656f9f940070b215266d1e2ed152c7a51d/sanitizers.cmake
    VERSION 1
    )

cmcm_module(cs-code-coverage.cmake
    REMOTE https://github.com/StableCoder/cmake-scripts/raw/e07087b0682da7ae0d2d9f9292fa4a7a6c821067/code-coverage.cmake
    VERSION 1
    )

cmcm_module(cs-compiler-options.cmake
    REMOTE https://github.com/StableCoder/cmake-scripts/raw/5f42869f09e812ec738d6d2d8387b2cf0bf2bb56/compiler-options.cmake
    VERSION 1
    )

cmcm_module(cs-dependency-graph.cmake
    REMOTE https://github.com/StableCoder/cmake-scripts/raw/8e52aeef77eed58f35b0f8f635011aec7a9bdb46/dependency-graph.cmake
    VERSION 1
    )

cmcm_module(cs-formatting.cmake
    REMOTE https://github.com/StableCoder/cmake-scripts/raw/0a7c837d2d3b363cb4752b299f5bd9c7eb359282/formatting.cmake
    VERSION 1
    )

cmcm_module(cs-glsl-shaders.cmake
    REMOTE https://github.com/StableCoder/cmake-scripts/raw/53bafc84da3c31325c5bac0f571420c59c95babc/glsl-shaders.cmake
    VERSION 1
    )

cmcm_module(cs-doxygen.cmake
    REMOTE https://github.com/StableCoder/cmake-scripts/raw/8e52aeef77eed58f35b0f8f635011aec7a9bdb46/doxygen.cmake
    VERSION 1
    )

cmcm_module(cs-prepare-catch.cmake
    REMOTE https://github.com/StableCoder/cmake-scripts/raw/53bafc84da3c31325c5bac0f571420c59c95babc/prepare-catch.cmake
    VERSION 1
    )

cmcm_module(cs-link-time-optimization.cmake
    REMOTE https://github.com/StableCoder/cmake-scripts/raw/e0cbdea29548996713ecddcac1ad3034730edac2/link-time-optimization.cmake
    VERSION 1
    )
