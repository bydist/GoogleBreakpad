include("${CMAKE_CURRENT_LIST_DIR}/id.cmake")


# GoogleBreakpad support only static library
set(BUILD_SHARED_LIBS OFF)

if(WIN32)
    if (MSVC)
        if(MSVC_VERSION EQUAL 1800)
	    set(MSVC_YEARS "2013")
        elseif(MSVC_VERSION EQUAL 1900)
            set(MSVC_YEARS "2015")
        elseif((MSVC_VERSION GREATER_EQUAL 1910) AND (MSVC_VERSION LESS_EQUAL 1919))
            set(MSVC_YEARS "2017")
	else()
	    message(SEND_ERROR "[byd][GoogleBreakpad] - msvc detected but version \"${MSVC_VERSION}\" is not handle by this script. Fix me if you can!")
	    return()
	endif()
    else()
	message(SEND_ERROR "[byd][GoogleBreakpad] - windows detected but only msvccompiler is supported by this script. Fix me if you can!")
	return()
    endif()


    byd__package__get_script_dir(${package} script_dir)
    byd__package__get_source_dir(${package} source_dir)
    byd__package__get_install_dir(${package} install_dir)


    byd__script__begin("${script_dir}/configure.cmake")
        byd__script__env__set(GYP_MSVS_VERSION ${MSVC_YEARS})
        byd__script__command("${source_dir}/src/tools/gyp/gyp.bat" --no-circular-check
                             "${source_dir}/src/client/windows/breakpad_client.gyp"
                             "${source_dir}/src/tools/windows/dump_syms/dump_syms.gyp")
    byd__script__end()
    byd__build_system__default_configure_command(${package})

    byd__script__begin("${script_dir}/build.cmake")
        byd__script__command(msbuild /p:Configuration=${CMAKE_BUILD_TYPE} "${source_dir}/src/client/windows/common.vcxproj")
        byd__script__command(msbuild /p:Configuration=${CMAKE_BUILD_TYPE} "${source_dir}/src/client/windows/crash_generation/crash_generation_client.vcxproj")
        byd__script__command(msbuild /p:Configuration=${CMAKE_BUILD_TYPE} "${source_dir}/src/client/windows/crash_generation/crash_generation_server.vcxproj")
        byd__script__command(msbuild /p:Configuration=${CMAKE_BUILD_TYPE} "${source_dir}/src/client/windows/handler/exception_handler.vcxproj")
        byd__script__command(msbuild /p:Configuration=${CMAKE_BUILD_TYPE} "${source_dir}/src/client/windows/sender/crash_report_sender.vcxproj")
        byd__script__command(msbuild /p:Configuration=${CMAKE_BUILD_TYPE} "${source_dir}/src/tools/windows/dump_syms/dump_syms.vcxproj")
    byd__script__end()
    byd__build_system__default_build_command(${package})

    byd__script__begin("${script_dir}/install.cmake")
        byd__script__command(python "${source_dir}/scripts/windows/install_google_breakpad.py" "${source_dir}" "${install_dir}")
    byd__script__end()
    byd__build_system__default_install_command(${package})


    byd__EP__add(${package})

elseif(CMAKE_HOST_UNIX)

    byd__autotool__add(${package} SKIP test)

endif()
