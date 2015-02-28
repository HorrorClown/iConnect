iConnect
========

###UPDATE: 
Neue Funktionen wurden hinzugefügt!

```lua
- register (sUsername, sPW, sEmail, nGroupID, nRankID)
- login (sUsername, sPW) als Alternative zu comparePassword()
- getConversations(nUID)
- getConversation (nConversationID)
- newConversation (nUID, tnRecieverID, sSubject, sMessage)
- joinConversation (nUID, nConversationID)
- leaveConversation (nUID, nConversationID)
- replyConversation (nUID, nConversationID, sMessage, bAutoJoin)
- setConversationRead (nByUID, nConversationID, bIsRead)
- isConversationRead (nByUID, nConversationID)
- hideConversation (nForUID, nConversationID, bToHidden)
- isConversationHidden (nForUID, nConversationID)
- isUserInConversation (nUID, nConversationID)
```

Die Datei **serialize.lua** ist auch neu und wird ebenso benötigt!




Da der Woltlab Connector von xthepr0mise (Woltlab-Connector: Verbinde Server und Forum) ausschließlich mit dem Woltlab Burning Board 3 (kurz WBB3) funktioniert, habe ich mich schnell an die Arbeit gemacht und ein neues geschrieben, welches auf WBB4 ausgelegt ist. Dies werde ich für iGaming benötigen und ich denke, dass andere User auch einen Nutzen darin finden könnten.

###Allgemein
Ihr habt damit die Möglichkeit, euer Server mit eurem WBB4 Forum zu verbinden. Zum Beispiel für eine Login Funktion, die auf die Accounts des Forums zurückgreift. Ebenfalls habt ihr die Möglichkeit neue Threads zu erstellen und Posts hinzu zu fügen. Dies würde die Realisierung eines Support Systems in Verbindung mit dem Forum ermöglichen.

###Installation
Einfach die iConnect.lua und die serialize.lua in eure Resource hinzufügen und in die meta.xml als type="server" eintragen. Nicht vergessen *<oop>true</oop>* gehört auch in die meta.xml

#####Wichtig:
Um den Connector nutzen zu können, benötigt ihr das bcrypt Modul, da dies den Blowfish-Algorithmus zur Verfügung stellt, welcher in MTA leider (noch) nicht enthalten ist.
Windows: https://github.com/pzduniak/ml_bcrypt // https://github.com/Jusonex/mtasa-bcrypt
Linux: http://www.jusonex.net/public/mta/ml_bcrypt.so
An dieser Stelle ein Dankeschön an @Jusonex: :)
Quelle: Other Hashing Algorithmen
