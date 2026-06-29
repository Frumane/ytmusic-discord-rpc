' YouTube Music -> Discord Rich Presence
' node uygulamasini GIZLI pencerede (konsol gostermeden) calistirir.
' Cokerse 5 saniye sonra otomatik yeniden baslatir.
' Kalici durdurmak icin: uninstall-autostart.ps1
Option Explicit
Dim sh, fso, appDir
Set sh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
appDir = fso.GetParentFolderName(WScript.ScriptFullName)
sh.CurrentDirectory = appDir
Do
  ' 0 = gizli pencere, True = node cikana kadar bekle
  sh.Run "node index.js", 0, True
  WScript.Sleep 5000  ' cokerse kisa bekleyip yeniden basla
Loop
