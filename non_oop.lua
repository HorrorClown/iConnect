--Add this file to meta.xml, if you wan't to use iConnect without OOP.
--Füge diese Datei zur meta.xml hinzu, wenn du iConnect ohne OOP nutzen möchtest.

local wbb = {}
local host = ""
local user = ""
local pass = ""
local db = ""

addEventHandler("onResourceStart", resourceRoot, function()
	wbb = new(Cwbbc, host, user, pass, db, 3306)
end)

function register(sUsername, sPassword, sEmail, nGroupID, nRankID)
	return wbb:register(sUsername, sPassword, sEmail, nGroupID, nRankID)
end

function login(sUsername, sPassword)
	return wbb:login(sUsername, sPassword)
end

function getUserID(sUsername)
	return wbb:getUserID(sUsername)
end

function getUserName(nUserID)
	return wbb:getUserName(nUserID)
end

function getUserMail(nUserID)
    return wbb:getUserMail(nUserID)
end

function getUserTitle(nUserID)
	return wbb:getUserTitle(nUserID)
end

function setUserTitle(nUserID, sNewTitle)
	return wbb:setUserTitle(nUserID, sNewTitle)
end

function isUserActivated(nUserID)
	return wbb:isUserActivated(nUserID)
end

function getUserLanguageID(nUserID)
	return wbb:getUserLanguageID(nUserID)
end

function setUserLanguageID(nUserID, nNewLang)
	return wbb:setUserLanguageID(nUserID, nNewLang)
end

function getLanguageItemText(sLanguageItem, nLanguageID)
	return wbb:getLanguageItemText(sLanguageItem, nLanguageID)
end

function getBoardTitle(nBoardID)
	return wbb:getBoardTitle(nBoardID)
end

function getBoardID(sTitle, nBoardType)
	return wbb:getBoardID(sTitle, nBoardType)
end

function addThread(nUserID, nBoardID, sTitle, sText)
	return wbb:addThread(nUserID, nBoardID, sTitle, sText)
end

function addPost(nUserID, nThreadID, sSubject, sText)
	return wbb:addPost(nUserID, nThreadID, sSubject, sText)
end

function getGroups()
	return wbb:getGroups()
end

function getGroupName(nGroupID)
	return wbb:getGroupName(nGroupID)
end

function isGroupExists(snGroup)
	return wbb:isGroupExists(snGroup)
end

function isUserInGroup(nUserID, nGroupID)
	return wbb:isUserInGroup(nUserID, nGroupID)
end

function addUserToGroup(nUserID, nGroupID)
	return wbb:addUserToGroup(nUserID, nGroupID)
end

function removeUserFromGroup(nUserID, nGroupID)
	return wbb:removeUserFromGroup(nUserID, nGroupID)
end

function getConversations(nUserID)
	return wbb:getConversations(nUserID)
end

function getConversation(nConversationID)
	return wbb:getConversation(nConversationID)
end

function newConversation(nUID, tnRecieverID, sSubject, sMessage)
	return wbb:newConversation(nUID, tnRecieverID, sSubject, sMessage)
end

function replyConversation(nUserID, nConversationID, sMessage, bAutoJoin)
	return wbb:getConversation(nConversationID, sMessage, bAutoJoin)
end

function joinConversation(nUID, nConversationID)
	return wbb:joinConversation(nUID, nConversationID)
end

function leaveConversation(nUID, nConversationID)
	return wbb:leaveConversation(nUID, nConversationID)
end

function setConversationRead(nByUID, nConversationID, bIsRead)
	return wbb:setConversationRead(nByUID, nConversationID, bIsRead)
end

function isConversationRead(nByUID, nConversationID)
	return wbb:isConversationRead(nByUID, nConversationID)
end

function hideConversation(nForUID, nConversationID, bToHidden)
	return wbb:hideConversation(nForUID, nConversationID, bToHidden)
end

function isConversationHidden(nForUID, nConversationID)
	return wbb:isConversationHidden(nForUID, nConversationID)
end

function isUserInConversation(nUID, nConversationID)
	return wbb:isUserInConversation(nUID, nConversationID)
end

function getUserStorage(nUID, sField)
	return wbb:getUserStorage(nUID, sField)
end