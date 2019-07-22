cmake_minimum_required(VERSION 3.7)
project(netopeer-change-saver)

set(CMAKE_CXX_STANDARD 11)
set(THREADS_PREFER_PTHREAD_FLAG ON)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set (CMAKE_EXE_LINKER_FLAGS "-Wl,--unresolved-symbols=ignore-all")
link_directories(.)

find_package(Threads REQUIRED)

add_executable(netopeer-change-saver main.cpp sysrepo.h Application.cpp Application.h KafkaWrapper.cpp KafkaWrapper.h
        SysrepoCallback.cpp SysrepoCallback.h)
file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/libSysrepo-cpp.so
        DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/bin)

target_link_libraries(netopeer-change-saver libSysrepo-cpp.so)
target_link_libraries(netopeer-change-saver libsysrepo.so)
target_link_libraries(netopeer-change-saver Threads::Threads)
target_link_libraries(netopeer-change-saver librdkafka.so)