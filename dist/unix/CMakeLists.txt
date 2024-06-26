if (SYSTEMD)
    if (NOT SYSTEMD_SERVICES_INSTALL_DIR)
        find_package(Systemd)
        if (NOT SYSTEMD_FOUND)
            message(
                FATAL_ERROR
                "Could not locate systemd services install dir."
                " Either pass the -DSYSTEMD_SERVICES_INSTALL_DIR=/path/to/systemd/services option"
                " or install systemd pkg-config"
            )
        endif()
    endif()
    set(EXPAND_BINDIR ${CMAKE_INSTALL_FULL_BINDIR})
    configure_file(systemd/qsneedtorrent-nox@.service.in ${CMAKE_CURRENT_BINARY_DIR}/qsneedtorrent-nox@.service @ONLY)
    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/qsneedtorrent-nox@.service"
        DESTINATION ${SYSTEMD_SERVICES_INSTALL_DIR}
        COMPONENT data
    )
endif()

if (GUI)
    list(APPEND MAN_FILES ${PROJECT_SOURCE_DIR}/doc/qsneedtorrent.1)
else()
    list(APPEND MAN_FILES ${PROJECT_SOURCE_DIR}/doc/qsneedtorrent-nox.1)
endif()

install(FILES ${MAN_FILES}
    DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
    COMPONENT doc
)

if (GUI)
    install(FILES org.qsneedtorrent.qSneedTorrent.desktop
        DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/applications/
        COMPONENT data
    )

    install(FILES org.qsneedtorrent.qSneedTorrent.appdata.xml
        DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/metainfo/
        COMPONENT data
    )

    install(DIRECTORY menuicons/
        DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor
        COMPONENT data
    )

    install(FILES
        ${PROJECT_SOURCE_DIR}/src/icons/qsneedtorrent-tray.svg
        ${PROJECT_SOURCE_DIR}/src/icons/qsneedtorrent-tray-dark.svg
        ${PROJECT_SOURCE_DIR}/src/icons/qsneedtorrent-tray-light.svg
        DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor/scalable/status
        COMPONENT data
    )
endif()
