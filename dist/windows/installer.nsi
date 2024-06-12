Var uninstallerPath

Section "-hidden"

    ;Search if qSneedTorrent is already installed.
    FindFirst $0 $1 "$uninstallerPath\uninst.exe"
    FindClose $0
    StrCmp $1 "" done

    ;Run the uninstaller of the previous install.
    DetailPrint $(inst_unist)
    ExecWait '"$uninstallerPath\uninst.exe" /S _?=$uninstallerPath'
    Delete "$uninstallerPath\uninst.exe"
    RMDir "$uninstallerPath"

    done:

SectionEnd


Section $(inst_qbt_req) ;"qSneedTorrent (required)"

  SectionIn RO

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR

  ;Create 'translations' directory
  CreateDirectory $INSTDIR\translations

  ; Put file there
  File "qsneedtorrent.exe"
  File "qsneedtorrent.pdb"
  File "qt.conf"
  File /r "qtbase_*.qm"  ; omit translations folder path to preserve folder structure
  File /oname=translations\qt_fa.qm "translations\qt_fa.qm"
  File /oname=translations\qt_gl.qm "translations\qt_gl.qm"
  File /oname=translations\qt_lt.qm "translations\qt_lt.qm"
  File /oname=translations\qt_pt.qm "translations\qt_pt.qm"
  File /oname=translations\qt_sl.qm "translations\qt_sl.qm"
  File /oname=translations\qt_sv.qm "translations\qt_sv.qm"
  File /oname=translations\qt_zh_CN.qm "translations\qt_zh_CN.qm"

  ; Write the installation path into the registry
  WriteRegStr HKLM "Software\qSneedTorrent" "InstallLocation" "$INSTDIR"

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\qSneedTorrent" "DisplayName" "qSneedTorrent ${PROG_VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\qSneedTorrent" "UninstallString" '"$INSTDIR\uninst.exe"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\qSneedTorrent" "DisplayIcon" '"$INSTDIR\qsneedtorrent.exe",0'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\qSneedTorrent" "Publisher" "The qSneedTorrent project"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\qSneedTorrent" "URLInfoAbout" "https://www.qsneedtorrent.org"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\qSneedTorrent" "DisplayVersion" "${PROG_VERSION}"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\qSneedTorrent" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\qSneedTorrent" "NoRepair" 1
  WriteUninstaller "uninst.exe"
  ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
  IntFmt $0 "0x%08X" $0
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\qSneedTorrent" "EstimatedSize" "$0"

  ; qSneedTorrent ProgID
  WriteRegStr HKLM "Software\Classes\qSneedTorrent" "" "qSneedTorrent Torrent File"
  WriteRegStr HKLM "Software\Classes\qSneedTorrent" "FriendlyTypeName" "qSneedTorrent Torrent File"
  WriteRegStr HKLM "Software\Classes\qSneedTorrent\shell" "" "open"
  WriteRegStr HKLM "Software\Classes\qSneedTorrent\shell\open\command" "" '"$INSTDIR\qsneedtorrent.exe" "%1"'
  WriteRegStr HKLM "Software\Classes\qSneedTorrent\DefaultIcon" "" '"$INSTDIR\qsneedtorrent.exe",1'

SectionEnd

; Optional section (can be disabled by the user)
Section /o $(inst_dekstop) ;"Create Desktop Shortcut"

  CreateShortCut "$DESKTOP\qSneedTorrent.lnk" "$INSTDIR\qsneedtorrent.exe"

SectionEnd

Section $(inst_startmenu) ;"Create Start Menu Shortcut"

  CreateDirectory "$SMPROGRAMS\qSneedTorrent"
  CreateShortCut "$SMPROGRAMS\qSneedTorrent\qSneedTorrent.lnk" "$INSTDIR\qsneedtorrent.exe"
  CreateShortCut "$SMPROGRAMS\qSneedTorrent\$(inst_uninstall_link_description).lnk" "$INSTDIR\uninst.exe"

SectionEnd

Section /o $(inst_startup) ;"Start qSneedTorrent on Windows start up"

  !insertmacro UAC_AsUser_Call Function inst_startup_user ${UAC_SYNCREGISTERS}|${UAC_SYNCOUTDIR}|${UAC_SYNCINSTDIR}

SectionEnd

Function inst_startup_user

  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "qSneedTorrent" "$INSTDIR\qsneedtorrent.exe"

FunctionEnd

Section $(inst_torrent) ;"Open .torrent files with qSneedTorrent"

  ReadRegStr $0 HKLM "Software\Classes\.torrent" ""

  StrCmp $0 "qSneedTorrent" clear_errors 0
  ;Check if empty string
  StrCmp $0 "" clear_errors 0
  ;Write old value to OpenWithProgIds
  WriteRegStr HKLM "Software\Classes\.torrent\OpenWithProgIds" $0 ""

  clear_errors:
  ClearErrors

  WriteRegStr HKLM "Software\Classes\.torrent" "" "qSneedTorrent"
  WriteRegStr HKLM "Software\Classes\.torrent" "Content Type" "application/x-bittorrent"

  !insertmacro UAC_AsUser_Call Function inst_torrent_user ${UAC_SYNCREGISTERS}|${UAC_SYNCOUTDIR}|${UAC_SYNCINSTDIR}

  System::Call 'Shell32::SHChangeNotify(i ${SHCNE_ASSOCCHANGED}, i ${SHCNF_IDLIST}, i 0, i 0)'

SectionEnd

Function inst_torrent_user

  ReadRegStr $0 HKCU "Software\Classes\.torrent" ""

  StrCmp $0 "qSneedTorrent" clear_errors 0
  ;Check if empty string
  StrCmp $0 "" clear_errors 0
  ;Write old value to OpenWithProgIds
  WriteRegStr HKCU "Software\Classes\.torrent\OpenWithProgIds" $0 ""

  clear_errors:
  ClearErrors

  WriteRegStr HKCU "Software\Classes\.torrent" "" "qSneedTorrent"
  WriteRegStr HKCU "Software\Classes\.torrent" "Content Type" "application/x-bittorrent"

FunctionEnd

Section $(inst_magnet) ;"Open magnet links with qSneedTorrent"

  WriteRegStr HKLM "Software\Classes\magnet" "" "URL:Magnet link"
  WriteRegStr HKLM "Software\Classes\magnet" "Content Type" "application/x-magnet"
  WriteRegStr HKLM "Software\Classes\magnet" "URL Protocol" ""
  WriteRegStr HKLM "Software\Classes\magnet\DefaultIcon" "" '"$INSTDIR\qsneedtorrent.exe",1'
  WriteRegStr HKLM "Software\Classes\magnet\shell" "" "open"
  WriteRegStr HKLM "Software\Classes\magnet\shell\open\command" "" '"$INSTDIR\qsneedtorrent.exe" "%1"'

  !insertmacro UAC_AsUser_Call Function inst_magnet_user ${UAC_SYNCREGISTERS}|${UAC_SYNCOUTDIR}|${UAC_SYNCINSTDIR}

  System::Call 'Shell32::SHChangeNotify(i ${SHCNE_ASSOCCHANGED}, i ${SHCNF_IDLIST}, i 0, i 0)'

SectionEnd

Function inst_magnet_user

  WriteRegStr HKCU "Software\Classes\magnet" "" "URL:Magnet link"
  WriteRegStr HKCU "Software\Classes\magnet" "Content Type" "application/x-magnet"
  WriteRegStr HKCU "Software\Classes\magnet" "URL Protocol" ""
  WriteRegStr HKCU "Software\Classes\magnet\DefaultIcon" "" '"$INSTDIR\qsneedtorrent.exe",1'
  WriteRegStr HKCU "Software\Classes\magnet\shell" "" "open"
  WriteRegStr HKCU "Software\Classes\magnet\shell\open\command" "" '"$INSTDIR\qsneedtorrent.exe" "%1"'

FunctionEnd

Section $(inst_firewall)

  DetailPrint $(inst_firewallinfo)
  nsisFirewallW::AddAuthorizedApplication "$INSTDIR\qsneedtorrent.exe" "qSneedTorrent"

SectionEnd

Section $(inst_pathlimit) ;"Disable Windows path length limit (260 character MAX_PATH limitation, requires Windows 10 1607 or later)"

  WriteRegDWORD HKLM "SYSTEM\CurrentControlSet\Control\FileSystem" "LongPathsEnabled" 1

SectionEnd

;--------------------------------

Function .onInit

  !insertmacro Init "installer"
  !insertmacro MUI_LANGDLL_DISPLAY

  ${IfNot} ${AtLeastWin7}
    MessageBox MB_OK|MB_ICONEXCLAMATION $(inst_requires_win7)
    Abort
  ${EndIf}

  !ifdef APP64BIT
    ${IfNot} ${RunningX64}
      MessageBox MB_OK|MB_ICONEXCLAMATION $(inst_requires_64bit)
      Abort
    ${EndIf}
  !endif

  ;Search if qSneedTorrent is already installed.
  FindFirst $0 $1 "$INSTDIR\uninst.exe"
  FindClose $0
  StrCmp $1 "" done

  ;Copy old value to var so we can call the correct uninstaller
  StrCpy $uninstallerPath $INSTDIR

  ;Inform the user
  MessageBox MB_OKCANCEL|MB_ICONINFORMATION $(inst_uninstall_question) /SD IDOK IDOK done
  Quit

  done:

FunctionEnd

Function check_instance

  check:
  FindProcDLL::FindProc "qsneedtorrent.exe"
  StrCmp $R0 "1" 0 notfound
  MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION $(inst_warning) IDRETRY check IDCANCEL done

  done:
  Abort

  notfound:

FunctionEnd

Function PageFinishRun

  !insertmacro UAC_AsUser_ExecShell "" "$INSTDIR\qsneedtorrent.exe" "" "" ""

FunctionEnd

Function .onInstSuccess
  SetErrorLevel 0
FunctionEnd
