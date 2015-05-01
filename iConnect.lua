--
-- Launemax
-- www.launemax.at
-- Date: 01.03.2015 - Time: 00:00
-- License: MIT/X11
-- 
-- Thanks to HorrorClown (PewX) 
-- pewx.de // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--

Cwbbc = {}

function Cwbbc:constructor(sHost, sUser, sPass, sDBName, sPort)
    self.sHost = sHost
    self.sUser = sUser
    self.sDBName = sDBName
    self.hCon = dbConnect("mysql", ("dbname=%s;host=%s;port=%s"):format(sDBName, sHost, sPort), sUser, sPass, "autoreconnect=1")
    if self.hCon then
		self:query("SET NAMES utf8;")
	else
        self:message("Can't connect to mysql server!")
        stopResource(getThisResource())
    end
end

function Cwbbc:destructor()
    self.sHost = nil
    self.sUser = nil
    self.sDBName = nil
    destroyElement(self.hCon)
end

--//Woltlab Community Framework 

function Cwbbc:register(sUsername, sPW, sEmail, nGroupID, nRankID)
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(sUsername) == "string", "Invalid string @ argument 1")
	assert(type(sPW) == "string", "Invalid string @ argument 2")
	assert(type(sEmail) == "string", "Invalid string @ argument 3")
	assert(nGroupID == nil or type(nGroupID) == "number", "Invalid number @ argument 4")
	assert(nRankID == nil or type(nRankID) == "number", "Invalid number @ argument 5")
	if nGroupID == nil then nGroupID = 1 end
	if nRankID == nil then nRankID = 1 end
	local nLanguageID = 1
	local nTimestamp = getRealTime().timestamp
	local dbHash = self:get("wcf1_user", "password", "userID", 1) -- get Reference Hash from User 1
	sPW = getDoubleSaltedHash(dbHash, sPW)
	self:query("START TRANSACTION;")
	local result,_, userID = self:query("INSERT INTO wcf1_user(`username`,`email`,`password`,`languageID`,`registrationDate`, `lastActivityTime`,`rankID`,`userOnlineGroupID`) VALUES (?,?,?,?,?,?,?,?);", sUsername, sEmail, sPW, nLanguageID, nTimestamp, nTimestamp, nRankID, nGroupID)
	if result ~= false then
		local result = self:query("SELECT `optionID`,`defaultValue` FROM wcf1_user_option;")
		if result ~= false then
			local columns = {}
			local values = {}
			for _, row in ipairs(result) do 
				table.insert(columns, "userOption"..row["optionID"])
				local v = row["defaultValue"]
				if v == false then v = "" else v = tostring(v) end
				table.insert(values, v)
			end
			local result = self:query("INSERT INTO wcf1_user_option_value(`userID`, `"..table.concat(columns, "`,`").."`) VALUES (?, '"..table.concat(values, "','").."');", userID)
			if result ~= false then
				local result = self:query("INSERT INTO wcf1_user_to_group(`userID`,`groupID`) VALUES (?,?);", userID, nGroupID)
				if result ~= false then
					local result = self:query("INSERT INTO wcf1_user_to_language(`userID`,`languageID`) VALUES (?,?);", userID, nLanguageID)
					if result ~= false then
						self:query("COMMIT;")
						return true, userID
					end
				end
			end
		end
	end
	self:query("ROLLBACK;")
	return false
end

function Cwbbc:comparePassword(sUsername, sPW) return self:login(sUsername, sPW) end
function Cwbbc:login(sUsername, sPW)
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(sUsername) == "string", "Invalid string @ argument 1")
	assert(type(sPW) == "string", "Invalid string @ argument 2")
	if self:get("wcf1_user", "username", "username", sUsername) then
		local dbHash = self:get("wcf1_user", "password", "username", sUsername)
		local pwHash = getDoubleSaltedHash(dbHash, sPW)
		if (dbHash == pwHash) then
			return true, Cwbbc:getUserID(sUsername)
		else
			return false
		end
	end
	return false
end

function Cwbbc:getUserID(sUsername)
    if not self.hCon then self:message("Not connected to mysql server!") return false end
    assert(type(sUsername) == "string", "Invalid string @ argument 1")
    local qResult = self:get("wcf1_user", "userID", "username", sUsername)
    if qResult ~= nil then return tonumber(qResult) else return false end
end

function Cwbbc:getUserName(nUID)
    if not self.hCon then self:message("Not connected to mysql server!") return false end
    assert((type(nUID) == "number"), "Invalid number @ argument 1")
    return self:get("wcf1_user", "username", "userID", nUID) or false
end

function Cwbbc:getUserTitle(nUID)
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(nUID) == "number", "Invalid number @ argument 1")
	return self:get("wcf1_user", "userTitle", "userID", nUID)
end

function Cwbbc:setUserTitle(nUID, sTitle)
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(nUID) == "number", "Invalid number @ argument 1")
	assert(type(sTitle) == "string", "Invalid string @ argument 2")
	return self:set("wcf1_user", "userTitle", sTitle, "userID", nUID)
end

function Cwbbc:isUserActivated(nUID)
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(nUID) == "number", "Invalid number @ argument 1")
	return (self:get("wcf1_user", "activationCode", "userID", nUID) == 0)
end

function Cwbbc:getUserLanguageID(nUID)
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(nUID) == "number", "Invalid number @ argument 1")
	return tonumber(self:get("wcf1_user", "languageID", "userID", nUID))
end

function Cwbbc:setUserLanguageID(nUID, nLanguageID)
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(nUID) == "number", "Invalid number @ argument 1")
	assert(type(nLanguageID) == "number", "Invalid number @ argument 2")
	return self:set("wcf1_user", "languageID", nLanguageID, "userID", nUID)
end

function Cwbbc:getLanguageItemText(sLanguageItem, nLanguageID)
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(sLanguageItem) == "string", "Invalid string @ argument 1")
	assert(type(nLanguageID) == "number", "Invalid number @ argument 2")
	return self:get("wcf1_language_item", "languageItemValue", "languageItem", sLanguageItem, "languageID", nLanguageID) or false
end

--//Woltlab Burning Board

function Cwbbc:getBoardTitle(nBoardID)
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(nBoardID) == "number", "Invalid number @ argument 1")
	return self:get("wbb1_board", "title", "boardID", nBoardID) or false
end

function Cwbbc:getBoardID(sTitle, nBoardType)
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(sTitle) == "string", "Invalid string @ argument 1")
	assert(type(nBoardType) == "number", "Invalid number @ argument 2")
	return tonumber(mysql.get("wbb1_board", "boardID", "title", sTitle, "boardType", nBoardType))
end

function Cwbbc:addThread(nUID, nBoardID, sTitle, sText)
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(nUID) == "number", "Invalid number @ argument 1")
	assert(type(nBoardID) == "number", "Invalid number @ argument 2")
	assert(type(sTitle) == "string", "Invalid string @ argument 3")
	assert(type(sText) == "string", "Invalid string @ argument 4")
	local username = self:getUserName(nUID)
	local timestamp = getRealTime().timestamp
	local result, _, threadID = self:query("INSERT INTO wbb1_thread (boardID, topic, userID, lastPosterID, username, lastPoster, time, lastPostTime) VALUES (?,?,?,?,?,?,?,?)", nBoardID, sTitle, nUID, nUID, username, username, timestamp, timestamp)
	if result then
		local result, _, postID = self:query("INSERT INTO wbb1_post (threadID, userID, username, subject, message, time) VALUES (?,?,?,?,?,?)", threadID, nUID, username, sTitle, sText, timestamp)
		if result then
			self:set("wbb1_thread", "firstPostID", postID, "threadID", threadID)
			self:set("wbb1_thread", "lastPostID", postID, "threadID", threadID)
			return threadID
		end
	end
end

function Cwbbc:addPost(nUID, nThreadID, sSubject, sText)
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(nUID) == "number", "Invalid number @ argument 1")
	assert(type(nThreadID) == "number", "Invalid number @ argument 2")
	assert(type(sSubject) == "string", "Invalid string @ argument 3")
	assert(type(sText) == "string", "Invalid string @ argument 4")
	local username = self:getUserName(nUID)
	local timestamp = getRealTime().timestamp
	local result, _, postID = self:query("INSERT INTO wbb1_post (threadID, userID, username, subject, message, time) VALUES (?,?,?,?,?,?)", nThreadID, nUID, username, sSubject, sText, timestamp)
	if result then
		local replies = tonumber(self:get("wbb1_thread", "replies", "threadID", nThreadID))
		return (self:set("wbb1_thread", "lastPostID", postID, "threadID", nThreadID) and self:set("wbb1_thread", "lastPostTime", timestamp, "threadID", nThreadID) and self:set("wbb1_thread", "replies", replies + 1, "threadID", nThreadID)) or false
	end
end

--//Woltlab Community Framework Groups
function Cwbbc:getGroups()
    if not self.hCon then self:message("Not connected to mysql server") return false end
    return self:query("SELECT * FROM wcf1_user_group")
end

function Cwbbc:getGroupName(nGroupID)
    if not self.hCon then self:message("Not connected to mysql server") return false end
    assert(type(nGroupID) == "number", "Invalid number @ argument 1")
    return self:get("wcf1_user_group", "groupName", "groupID", nGroupID)
end

function Cwbbc:getGroupID(sGroupName)
    if not self.hCon then self:message("Not connected to mysql server") return false end
    assert(type(sGroupName) == "string", "Invalid string @ argument 1")
    return self:get("wcf1_user_group", "groupID", "groupName", sGroupName)
end

function Cwbbc:isGroupExists(snGroup)
    if not self.hCon then self:message("Not connected to mysql server") return false end
    assert((type(snGroup) == "number" or type(snGroup) == "string"), "Invalid number/string @ argument 1")
    if type(snGroup) == "string" then
        return (self:get("wcf1_user_group", "groupID", "groupName", snGroup) ~= nil)
    elseif type(snGroup) == "number" then
        return (self:get("wcf1_user_group", "groupName", "groupID", snGroup) ~= nil)
    end
end

function Cwbbc:isUserInGroup(nUID, nGroupID)
    if not self.hCon then self:message("Not connected to mysql server") return false end
    assert(type(nUID) == "number", "Invalid number @ argument 1")
    assert(type(nGroupID) == "number", "Invalid number @ argument 2")
    local result = self:get("wcf1_user_to_group", "groupID", "userID", nUID)
    for _, g in ipairs(result) do
        if tonumber(g.groupID) == tonumber(nGroupID) then return true end
    end
    return false
end

function Cwbbc:addUserToGroup(nUID, nGroupID)
    if not self.hCon then self:message("Not connected to mysql server") return false end
    assert(type(nUID) == "number", "Invalid number @ argument 1")
    assert(type(nGroupID) == "number", "Invalid number @ argument 2")
    return self:insert("wcf1_user_to_group", "userID, groupID", "?,?", nUID, nGroupID)
end

function Cwbbc:removeUserFromGroup(nUID, nGroupID)
    if not self.hCon then self:message("Not connected to mysql server") return false end
    assert(type(nUID) == "number", "Invalid number @ argument 1")
    assert(type(nGroupID) == "number", "Invalid number @ argument 2")
    return (self:query(("DELETE FROM wcf1_user_to_group WHERE userID = '%s' AND groupID = '%s'"):format(nUID, nGroupID)) ~= false) or true
end

--//Conversations

function Cwbbc:getConversations(nUID) 
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(nUID) == "number", "Invalid number @ argument 1")
	local result = self:query("SELECT c.conversationID, subject, c.userID, c.username, participantSummary, FROM_UNIXTIME(time) as time, ct.hideConversation as state FROM wcf1_conversation c LEFT JOIN wcf1_conversation_to_user ct ON ct.conversationID = c.conversationID AND ct.participantID = ? WHERE (userid = ? OR participantSummary LIKE '%s:6:\"userID\";s:?:\"?\"%') AND ct.hideConversation != 2 ORDER BY time", nUID, nUID, string.len(tostring(nUID)), nUID)
	if result then
		local conversations = {}
		for _, conv in ipairs(result) do 
			local conversation = {}
			conversation["ID"] = tonumber(conv["conversationID"])
			conversation["subject"] = conv["subject"]
			conversation["fromUserID"] = tonumber(conv["userID"])
			conversation["fromUsername"] = conv["username"]
			conversation["type"] = "in"
			if tonumber(conv["userID"]) == nUID then
				conversation["type"] = "out"
			end
			if tonumber(conv["state"]) == 0 then
				conversation["state"] = "visible"
			elseif tonumber(conv["state"]) == 1 then
				conversation["state"] = "hidden"
			end
			local _participants = unserialize(conv["participantSummary"])
			conversation["participants"] = {}
			for _, participant in pairs(_participants) do 
				conversation["participants"][tonumber(participant["userID"])] = participant["username"]
			end
			if conversation["participants"][nUID] == nil then
				conversation["participants"][conversation["fromUserID"]] = conversation["fromUsername"]
			end
			table.insert(conversations, conversation)
		end
		return conversations
	else
		return false, "Database Error"
	end
end

function Cwbbc:getConversation(nConversationID) 
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(nConversationID) == "number", "Invalid number @ argument 1")
	local result, _ = self:query("SELECT subject, userID, username, participantSummary FROM wcf1_conversation WHERE conversationID = ?", nConversationID)
	if result and #result > 0 then
		local subject = result[1]["subject"]
		local fromUserID = tonumber(result[1]["userID"])
		local fromUsername = result[1]["username"]
		local _participants = unserialize(result[1]["participantSummary"])
		local participants = {}
		participants[fromUserID] = fromUsername
		local messages = {}
		for _, participant in pairs(_participants) do 
			participants[tonumber(participant["userID"])] = participant["username"]
		end
		local result, _ = self:query("SELECT userid, username, message, FROM_UNIXTIME(time) as time FROM wcf1_conversation_message WHERE conversationID = ? ORDER BY time", nConversationID)
		if result and #result > 0 then
			for _, msg in ipairs(result) do 
				local message = {}
				message["userID"] = tonumber(msg["userid"])
				message["username"] = msg["username"]
				message["message"] = msg["message"]
				message["time"] = msg["time"]
				table.insert(messages, message)
			end
		end
		return subject, fromUserID, fromUsername, participants, messages
	else
		return false, "Conversation not found"
	end
end

function Cwbbc:replyConversation(nUID, nConversationID, sMessage, bAutoJoin) 
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(nUID) == "number", "Invalid number @ argument 1")
	assert(type(nConversationID) == "number", "Invalid number @ argument 2")
	assert(type(sMessage) == "string", "Invalid string @ argument 3")
	assert(bAutoJoin == nil or type(bAutoJoin) == "boolean", "Invalid boolean @ argument 4")
	if bAutoJoin == nil then bAutoJoin = false end
	local subject, fromUserID, fromUsername, participants, messages = self:getConversation(nConversationID)
	if subject ~= false then
		if participants[nUID] == nil then
			if bAutoJoin then
				local joined = self:joinConversation(nUID, nConversationID)
				if not joined then
					return false, "Can't join conversation"
				end
			else
				return false, "User is not part of this conversation"
			end
		end
		local sUsername = self:getUserName(tonumber(nUID))
		local iTimestamp = getRealTime().timestamp
		local result, _, messageID = self:query("INSERT INTO wcf1_conversation_message (conversationID, userID, username, message, time, ipAddress) VALUES (?,?,?,?,?,?)", conversationID, nUID, sUsername, sMessage, iTimestamp, "::ffff:5de6:2a0e")
		if result ~= false then
			return messageID
		else
			return false, "Can't add the message"
		end
	else
		return false, "Conversation not found"
	end
end

function Cwbbc:newConversation(nUID, tnRecieverID, sSubject, sMessage)
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(nUID) == "number", "Invalid number @ argument 1")
	assert(type(tnRecieverID) == "number" or type(tnRecieverID) == "table", "Invalid number/table @ argument 2")
	assert(type(sSubject) == "string", "Invalid string @ argument 3")
	assert(type(sMessage) == "string", "Invalid string @ argument 4")
	local nParticipantCount = 0
	local tParticipants = {}
	if type(tnRecieverID) == "number" then 
		local rid = tnRecieverID
		tnRecieverID = {}
		table.insert(tnRecieverID, rid)
	end
	local sUsername = self:getUserName(tonumber(nUID))
	local nTimestamp = getRealTime().timestamp
	
	for _, receiverID in ipairs(tnRecieverID) do 
		if receiverID ~= nil and tonumber(receiverID) ~= nil and tonumber(receiverID) ~= nUID then
			local _receipient = {}
			_receipient["userID"] = tostring(receiverID)
			_receipient["hideConversation"] = "0"
			_receipient["username"] = self:getUserName(tonumber(receiverID))
			table.insert(tParticipants, _receipient)
		end
	end
	nParticipantCount = #tParticipants
	self:query("START TRANSACTION;")
	local result, _, conversationID = self:query("INSERT INTO wcf1_conversation (subject, time, userID, username, lastPostTime, lastPosterID, lastPoster, participants, participantSummary) VALUES (?,?,?,?,?,?,?,?,?)", sSubject, nTimestamp, nUID, sUsername, nTimestamp, nUID, sUsername, nParticipantCount, serialize(tParticipants))
	if result and conversationID ~= nil and tonumber(conversationID) ~= nil then
		self:query("INSERT INTO wcf1_conversation_to_user (conversationID, participantID, username, lastVisitTime) VALUES (?,?,?,?)", conversationID, nUID, sUsername, nTimestamp)
		for receipientIndex, receipient in ipairs(tParticipants) do 
			self:query("INSERT INTO wcf1_conversation_to_user (conversationID, participantID, username) VALUES (?,?,?)", conversationID, receipient["userID"], receipient["username"])
		end
		local result, _, messageID = self:query("INSERT INTO wcf1_conversation_message (conversationID, userID, username, message, time, ipAddress) VALUES (?,?,?,?,?,?)", conversationID, nUID, sUsername, sMessage, nTimestamp, "::ffff:5de6:2a0e")
		if result ~= false then
			self:set("wcf1_conversation", "firstMessageID", messageID, "conversationID", conversationID)
			self:query("COMMIT;")
			return conversationID
		else
			self:query("ROLLBACK;")
			return false, "Can't add the message"
		end
	else
		self:query("ROLLBACK;")
		return false, "Can't create a new conversation"
	end
end

function Cwbbc:setConversationRead(nByUID, nConversationID, isRead)
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(nByUID) == "number", "Invalid number @ argument 1")
	assert(type(nConversationID) == "number", "Invalid number @ argument 2")
	assert(isRead == nil or type(isRead) == "boolean", "Invalid boolean @ argument 3")
	local nTimestamp = getRealTime().timestamp
	if isRead == false then nTimestamp = 0 end
	return (self:set("wcf1_conversation_to_user", "lastVisitTime", nTimestamp, "conversationID", nConversationID, "participantID", nByUID)~=false)
end

function Cwbbc:isConversationRead(nByUID, nConversationID)
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(nByUID) == "number", "Invalid number @ argument 1")
	assert(type(nConversationID) == "number", "Invalid number @ argument 2")
	return (tonumber(self:get("wcf1_conversation_to_user", "lastVisitTime", "conversationID", nConversationID, "participantID", nByUID)) > 0) or false
end

function Cwbbc:hideConversation(nForUID, nConversationID, toHidden)
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(nForUID) == "number", "Invalid number @ argument 1")
	assert(type(nConversationID) == "number", "Invalid number @ argument 2")
	assert(toHidden == nil or type(toHidden) == "boolean", "Invalid boolean @ argument 3")
	if toHidden == nil then toHidden = true end
	if toHidden then toHidden = 1 else toHidden = 0 end
	local ptable = self:get("wcf1_conversation", "participantSummary", "conversationID", nConversationID)
	local pCount = self:get("wcf1_conversation", "participants", "conversationID", nConversationID)
	if ptable then
		ptable = unserialize(ptable)
		for i, p in ipairs(ptable) do 
			if tonumber(p["userID"]) == nForUID then
				local oldState = tonumber(p["hideConversation"]) 
				ptable[i]["hideConversation"] = tostring(toHidden)
				self:set("wcf1_conversation", "participantSummary", serialize(ptable), "conversationID", nConversationID)
				if oldState == 2 then 
					self:set("wcf1_conversation", "participants", tonumber(pCount)+1, "conversationID", nConversationID)
				end
				return (self:set("wcf1_conversation_to_user", "hideConversation", toHidden, "conversationID", nConversationID, "participantID", nForUID)~=false)
			end
		end
		return (self:set("wcf1_conversation_to_user", "hideConversation", toHidden, "conversationID", nConversationID, "participantID", nForUID)~=false)
	else
		return false, "Conversation not found"
	end
end

function Cwbbc:isConversationHidden(nForUID, nConversationID)
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(nForUID) == "number", "Invalid number @ argument 1")
	assert(type(nConversationID) == "number", "Invalid number @ argument 2")
	return (tonumber(self:get("wcf1_conversation_to_user", "hideConversation", "conversationID", nConversationID, "participantID", nForUID)) == 1) or false
end

function Cwbbc:joinConversation(nUID, nConversationID)
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(nUID) == "number", "Invalid number @ argument 1")
	assert(type(nConversationID) == "number", "Invalid number @ argument 2")
	local subject, fromUserID, fromUsername, participants = self:getConversation(nConversationID)
	if subject ~= false then
		local ptable = self:get("wcf1_conversation", "participantSummary", "conversationID", nConversationID)
		ptable = unserialize(ptable)
		if participants[nUID] == nil then
			local _receipient = {}
			_receipient["userID"] = tostring(nUID)
			_receipient["hideConversation"] = "0"
			_receipient["username"] = self:getUserName(nUID)
			table.insert(ptable, _receipient)
			local nTimestamp = getRealTime().timestamp
			self:set("wcf1_conversation", "participantSummary", serialize(ptable), "conversationID", nConversationID)
			self:set("wcf1_conversation", "participants", (#ptable-1), "conversationID", nConversationID)
			return (self:query("INSERT INTO wcf1_conversation_to_user (conversationID, participantID, username, lastVisitTime) VALUES (?,?,?,?)", nConversationID, nUID, _receipient["username"], nTimestamp)~=false)
		else
			return false, "User is already part of this conversation"
		end
	else
		return false, "Conversation not found"
	end
end

function Cwbbc:leaveConversation(nUID, nConversationID)
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(nUID) == "number", "Invalid number @ argument 1")
	assert(type(nConversationID) == "number", "Invalid number @ argument 2")
	local ptable = self:get("wcf1_conversation", "participantSummary", "conversationID", nConversationID)
	local pCount = self:get("wcf1_conversation", "participants", "conversationID", nConversationID)
	if ptable ~= false then
		ptable = unserialize(ptable)
		for i, p in ipairs(ptable) do 
			if tonumber(p["userID"]) == nUID then
				local oldState = tonumber(p["hideConversation"])
				ptable[i]["hideConversation"] = "2"
				self:set("wcf1_conversation", "participantSummary", serialize(ptable), "conversationID", nConversationID)
				if oldState ~= 2 then
					self:set("wcf1_conversation", "participants", tonumber(pCount)-1, "conversationID", nConversationID)
				end
				return self:set("wcf1_conversation_to_user", "hideConversation", 2, "conversationID", nConversationID, "participantID", nUID)
			end
		end
		return self:set("wcf1_conversation_to_user", "hideConversation", 2, "conversationID", nConversationID, "participantID", nUID)
	else
		return false, "Conversation not found"
	end
end

function Cwbbc:isUserInConversation(nUID, nConversationID)
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(nByUID) == "number", "Invalid number @ argument 1")
	assert(type(nConversationID) == "number", "Invalid number @ argument 2")
	local subject, fromUserID, fromUsername, participants = self:getConversation(nConversationID)
	if subject ~= false then
		return (participants[nUID] ~= nil)
	else
		return false, "Conversation not found"
	end
end


--//Useful

function Cwbbc:message(sMessage)
	outputDebugString(("[%s:%s@%s]: %s"):format(self.sUser, self.sHost, self.sDBName, sMessage), 0, 255, 0, 255)
end

function getDoubleSaltedHash(sDBHash, sPW)
	local salt = string.sub(sDBHash, 1, 29)
	local hash = string.sub(bcrypt_digest(bcrypt_digest(sPW, salt), salt), 1, 60)
	return hash
end

--//Database

function Cwbbc:query(q, ...)
    local query = dbQuery(self.hCon, q, ...)
    local result, qRows, qliID = dbPoll(query, 100)
    if result == false then
        return false
    elseif result then
        return result, qRows, qliID
    else dbFree(query) end
end

function Cwbbc:insert(t, c, v, ...)         --t = table | c = columns | v = values
    return dbExec(self.hCon, ("INSERT INTO %s (%s) VALUES (%s)"):format(t, c, v), ...)
end

function Cwbbc:set(t, c, cV, w, wV, wO, wVO)   		--t = table | c = column | cV = columnValue | w = where | wV = whereValue | wO = whereOptional | wVO = whereValueOptional
    if wO ~= nil then
		return dbExec(self.hCon, "UPDATE ?? SET ??=? WHERE ??=? AND ??=?", t, c, cV, w, wV, wO, wVO)
	else
		return dbExec(self.hCon, "UPDATE ?? SET ??=? WHERE ??=?", t, c, cV, w, wV)
	end
end

function Cwbbc:get(t, c, w, wV, wO, wVO)    --t = table | c = column | w = where | wV = whereValue | wO = whereOptional | wVO = whereValueOptional
    local q, rs
    if wO and wVO then q, rs = self:query(("SELECT %s FROM %s WHERE %s = '%s' AND %s = '%s'"):format(c, t, w, wV, wO, wVO)) elseif w and wV then q, rs = self:query(("SELECT %s FROM %s WHERE %s = '%s'"):format(c, t, w, wV)) else q, rs = self:query(("SELECT %s FROM %s"):format(c, t)) end
    if not q then return false end
    if rs > 1 then return q end

    for _, row in ipairs(q) do
        return row[c]
    end
end

--//Informations

addEventHandler("onResourceStart", resourceRoot,
    function()
        if type(bcrypt_digest) ~= "function" then
           outputDebugString("[iConnect] bcrypt module required to compare passwords!", 2)
        end
    end
)
