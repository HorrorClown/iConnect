--
-- HorrorClown (PewX)
-- Using: IntelliJ IDEA 13 Ultimate
-- Date: 24.11.2014 - Time: 03:54
-- License: MIT/X11
-- pewx.de // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--
Cwbbc = {}

function Cwbbc:constructor(sHost, sUser, sPass, sDBName, sPort)
    self.hCon = dbConnect("mysql", ("dbname=%s;host=%s;port=%s"):format(sDBName, sHost, sPort), sUser, sPass, "autoreconnect=1")
    if self.hCon then
        outputDebugString("|wbbc| Connected to mysql server!")
    else
        outputDebugString("|wbbc| Can't connect to  mysql server!")
        stopResource(getThisResource())
    end
end

function Cwbbc:destructor()
    destroyElement(self.hCon)
    self.hCon = ni
end

function Cwbbc:getUserID(sUsername)
    if not self.hCon then self:message("Not connected to mysql server!") return false end
    assert(type(sUsername) == "string", "Invalid string @ argument 1")
    return self:get("wcf1_user", "userID", "username", sUsername)
end

function Cwbbc:getUserName(sUID)
    if not self.hCon then self:message("Not connected to mysql server!") return false end
    assert((type(sUID) == "number" or type(sUID) == "string"), "Invalid number/string @ argument 1")
    return self:get("wcf1_user", "username", "userID", sUID)
end

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