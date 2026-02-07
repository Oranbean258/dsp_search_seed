if (BUILD_PYTHON STREQUAL "ON")
    find_program(PYTHON_EXECUTABLE NAMES python3 python)
    # python
    message(STATUS "PYTHON_EXECUTABLE:${PYTHON_EXECUTABLE}")
    execute_process( COMMAND ${PYTHON_EXECUTABLE} "-c" "from __future__ import print_function; import os; import pybind11; print(os.path.dirname(pybind11.__file__),end='');" RESULT_VARIABLE _PYTHON_SUCCESS OUTPUT_VARIABLE PYBIND11_DIR)
    if (NOT _PYTHON_SUCCESS MATCHES 0)
        message(STATUS "PYBIND11_DIR: ${PYBIND11_DIR}")
        message(FATAL_ERROR "Pybind11 config Error.")
    endif ()
    # pybind11
    message(STATUS "PYBIND11_DIR = ${PYBIND11_DIR}")
    list(APPEND CMAKE_PREFIX_PATH ${PYBIND11_DIR})
    find_package(pybind11 REQUIRED)
    include_directories(
        ${Python3_INCLUDE_DIRS}
        ${pybind11_INCLUDE_DIRS}
        ${PROJECT_SOURCE_DIR}/cpp_source_code
        ${PROJECT_SOURCE_DIR}/cpp_source_code/python_wrapper
    )

    file(GLOB_RECURSE PY_SRC_FILES ${PROJECT_SOURCE_DIR}/cpp_source_code/*.cpp)
    pybind11_add_module(_pydsp_seed_search ${PY_SRC_FILES} ${SRC_FILES})
    set_target_properties(_pydsp_seed_search PROPERTIES
        CXX_STANDARD 20
        INTERPROCEDURAL_OPTIMIZATION ON
        OUTPUT_NAME "_pydsp_seed_search"
    )
    target_compile_definitions(_pydsp_seed_search PRIVATE
        GLM_ENABLE_EXPERIMENTAL
        SUPPORT_AVX2
        $<$<CONFIG:Release>:NDEBUG>
        CL_HPP_TARGET_OPENCL_VERSION=200
    )
    target_compile_options(_pydsp_seed_search PRIVATE
            $<$<CONFIG:Release>:/O2>
            $<$<CONFIG:Release>:/Ot>
    )
    target_link_options(_pydsp_seed_search PRIVATE
        $<$<CONFIG:Release>:/OPT:REF>
        $<$<CONFIG:Release>:/OPT:ICF>
    )
    target_link_libraries(_pydsp_seed_search PRIVATE
        glm::glm
        OpenCL::Headers
        OpenCL::HeadersCpp
        OpenCL::OpenCL
    )
    install(TARGETS _pydsp_seed_search
        RUNTIME DESTINATION python
                COMPONENT seed_search
        LIBRARY DESTINATION python
                COMPONENT seed_search
        ARCHIVE DESTINATION python
                COMPONENT seed_search
    )
endif ()