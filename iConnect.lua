--
-- HorrorClown (PewX)
-- Using: IntelliJ IDEA 13 Ultimate
-- Date: 24.11.2014 - Time: 03:54
-- License: MIT/X11
-- pewx.de // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--
wcf = {}
wcf.__index = wcf

function wcf:connect(host, username, password, database)
	local c = {}
	c.hCon = mysql:connect("mysql", ("dbname=%s;host=%s"):format(database, host), username, password, "autoreconnect=1")
    setmetatable(c, wcf)
    return c
end

function wcf:disconnect()
	destroyElement(self.hCon)
end

---
--MySQL
---
mysql = {}
mysql.__index = mysql

function mysql:connect(host, username, password, database)
    local c = {}
    c.hCon = dbConnect(host, username, password, database)
    setmetatable(c, mysql)
    return c
end

function mysql:query(q, ...)
    local query = dbQuery(self.hCon, q, ...)
    local result, qRows, qliID = dbPoll(query, 100)
    if result == false then
       return false
    elseif result then
        return result, qRows, qliID
    else dbFree(query) end
end