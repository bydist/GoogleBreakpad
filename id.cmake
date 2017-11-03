set(package GoogleBreakpad)
set(version 42.0-unowhy)

byd__package__info(${package}
    MAINTAINER_NAME "David Callu"
    MAINTAINER_EMAIL "callu.david@gmail.com"
    VERSION ${version}-1
    ABI ${version}
    )

byd__package__download_info(${package}
    GIT_REPOSITORY http://github.com/ledocc/breakpad.git
    GIT_TAG unowhy
)
