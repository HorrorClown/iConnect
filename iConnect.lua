--
-- HorrorClown (PewX)
-- Using: IntelliJ IDEA 13 Ultimate
-- Date: 24.11.2014 - Time: 03:54
-- License: MIT/X11
-- pewx.de // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--
Cwbbc = {}

function Cwbbc:constructor(sHost, sUser, sPass, sDBName, sPort)
    self.sHost = sHost
    self.sUser = sUser
    self.sDBname = sDBName
    self.hCon = dbConnect("mysql", ("dbname=%s;host=%s;port=%s"):format(sDBName, sHost, sPort), sUser, sPass, "autoreconnect=1")
    if self.hCon then
        self:message("Successfully connected!")
    else
        self:message("Can't connect to mysql server!")
        stopResource(getThisResource())
    end
end

function Cwbbc:destructor()
    destroyElement(self.hCon)
    self.hCon = ni
end

--//Woltlab Community Framework

function Cwbbc:comparePassword(sUsername, sPW)
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(sUsername) == "string", "Invalid string @ argument 1")
	assert(type(sUsername, sPW) == "string", "Invalid string @ argument 2")
	if self:get("wcf1_user", "username", "username", sUsername) then
		local dbHash = self:get("wcf1_user", "password", "username", sUsername)
		local pwHash = getDoubleSaltedHash(dbHash, sUsername, sPW)
		return (dbHash == pwHash)
	end
	return false
end

function Cwbbc:getUserID(sUsername)
    if not self.hCon then self:message("Not connected to mysql server!") return false end
    assert(type(sUsername) == "string", "Invalid string @ argument 1")
    return tonumber(self:get("wcf1_user", "userID", "username", sUsername))
end

function Cwbbc:getUserName(nUID)
    if not self.hCon then self:message("Not connected to mysql server!") return false end
    assert((type(nUID) == "number"), "Invalid number @ argument 1")
    return self:get("wcf1_user", "username", "userID", nUID)
end

function Cwbbc:getUserTitle(nUID)
	if not self.hCon then self:message("Not connected to mysql server") return false end
	assert(type(nUID) == "number", "Invalid number @ argument 1")
	return self:get("wcf1_user", "userTitle", "userID", nUID)
end

function Cwbbc:setUserTitle(nUID, sTitle)
	if not self:hCon then self:message("Not connected to mysql server") return false end
	assert(type(nUID) == "number", "Invalid number @ argument 1")
	assert(type(sTitle) == "string", "Invalid string @ argument 2")
	return self:set("wcf1_user", "userTitle", sTitle, "userID", nUID)
end

function Cwbbc:isUserActivated(nUID)
	if not self:hCon then self:message("Not connected to mysql server") return false end
	assert(type(nUID) == "number", "Invalid number @ argument 1")
	return (self:get("wcf1_user", "activationCode", "userID", nUID) == 0)
end

function Cwbbc:getUserLanguageID(nUID)
	if not self:hCon then self:message("Not connected to mysql server") return false end
	assert(type(nUID) == "number", "Invalid number @ argument 1")
	return tonumber(self:get("wcf1_user", "languageID", "userID", nUID))
end

function Cwbbc:setUserLanguageID(nUID, nLanguageID)
	if not self:hCon then self:message("Not connected to mysql server") return false end
	assert(type(nUID) == "number", "Invalid number @ argument 1")
	assert(type(nLanguageID) == "number", "Invalid number @ argument 2")
	return self:set("wcf1_user", "languageID", nLanguageID, "userID", nUID)
end

function Cwbbc:getLanguageItemText(sLanguageItem, nLanguageID)
	if not self:hCon then self:message("Not connected to mysql server") return false end
	assert(type(sLanguageItem) == "string", "Invalid string @ argument 1")
	assert(type(nLanguageID) == "number", "Invalid number @ argument 2")
	return self:get("wcf1_language_item", "languageItemValue", "languageItem", sLanguageItem, "languageID", nLanguageID) or false
end

--//Woltlab Burning Board

function Cwbbc:getBoardTitle(nBoardID)
	if not self:hCon then self:message("Not connected to mysql server") return false end
	assert(type(nBoardID) == "number", "Invalid number @ argument 1")
	return self:get("wbb1_board", "title", "boardID", nBoardID) or false
end

function Cwbbc:getBoardID(sTitle, nBoardType)
	if not self:hCon then self:message("Not connected to mysql server") return false end
	assert(type(sTitle) == "string", "Invalid string @ argument 1")
	assert(type(nBoardType) == "number", "Invalid number @ argument 2")
	return tonumber(mysql.get("wbb1_board", "boardID", "title", sTitle, "boardType", nBoardType))
end

function Cwbbc:addThread(nUID, nBoardID, sTitle, sText)
	if not self:hCon then self:message("Not connected to mysql server") return false end
	assert(type(nUID) == "number", "Invalid number @ argument 1")
	assert(type(nBoardID) == "number", "Invalid number @ argument 2")
	assert(type(sTitle) == "string", "Invalid string @ argument 3")
	assert(type(sText) == "string", "Invalid string @ argument 4")
	local username = wcf.getUsername(nUID)
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
	if not self:hCon then self:message("Not connected to mysql server") return false end
	assert(type(nUID) == "number", "Invalid number @ argument 1")
	assert(type(nThreadID) == "number", "Invalid number @ argument 2")
	assert(type(sSubject) == "string", "Invalid string @ argument 3")
	assert(type(sText) == "string", "Invalid string @ argument 4")
	local username = wcf.getUsername(nUID)
	local timestamp = getRealTime().timestamp
	local result, _, postID = self:query("INSERT INTO wbb1_post (threadID, userID, username, subject, message, time) VALUES (?,?,?,?,?,?)", nThreadID, nUID, username, sSubject, sText, timestamp)
	if result then
		local replies = tonumber(self:get("wbb1_thread", "replies", "threadID", nThreadID))
		return (self:set("wbb1_thread", "lastPostID", postID, "threadID", nThreadID) and self:set("wbb1_thread", "lastPostTime", timestamp, "threadID", nThreadID) and self:set("wbb1_thread", "replies", replies + 1, "threadID", nThreadID))
	end
end

--//Useful

function Cwbbc:message(sMessage)
	outputDebugString(("[%s:%s@%s]: %s"):format(self:sUser, self.sHost, self.sPort, self.sDBName, sMessage), 0, 255, 0, 255)
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

function Cwbbc:set(t, c, cV, w, wV)   		--t = table | c = column | cV = columnValue | w = where | wV = whereValue
    return dbExec(self.hCon, "UPDATE ?? SET ??=? WHERE ??=?", t, c, cV, w, wV)
end

function Cwbbc:get(t, c, w, wV, wO, wVO)    --t = table | c = column | w = where | wV = whereValue | wO = whereOpational | wVO = whereValueOptional
    local q, rs
    if wO and wVO then q, rs = self:query(("SELECT %s FROM %s WHERE %s = '%s' AND %s = '%s'"):format(c, t, w, wV, wO, wVO)) else q, rs = self:query(("SELECT %s FROM %s WHERE %s = '%s'"):format(c, t, w, wV)) end
    if not q then return false end
    if rs > 1 then return q end

    for _, row in ipairs(q) do
        return row[c]
    end
end
