file(GLOB SRC_FILES ${CMAKE_CURRENT_LIST_DIR}/*.cpp)
add_library(seed_search_object OBJECT ${SRC_FILES})
target_include_directories(seed_search_object PRIVATE ${CMAKE_CURRENT_LIST_DIR})
target_link_libraries(seed_search_object PRIVATE
    glm::glm
    OpenCL::Headers
    OpenCL::HeadersCpp
)
target_compile_definitions(seed_search_object PRIVATE GLM_ENABLE_EXPERIMENTAL)

add_library(seed_search_shard SHARED $<TARGET_OBJECTS:seed_search_object>)
set_target_properties(seed_search_shard PROPERTIES OUTPUT_NAME "dsp_seed_search")
target_link_libraries(seed_search_shard PUBLIC
    OpenCL::OpenCL
)

if (BUILD_PYTHON STREQUAL "ON")
    add_subdirectory(python_wrapper)
endif()

install(TARGETS seed_search_shard
    RUNTIME DESTINATION bin
            COMPONENT seed_search
    LIBRARY DESTINATION lib64
            COMPONENT seed_search
    ARCHIVE DESTINATION lib64
            COMPONENT seed_search
)