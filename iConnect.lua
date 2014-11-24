--
-- HorrorClown (PewX)
-- Using: IntelliJ IDEA 13 Ultimate
-- Date: 24.11.2014 - Time: 03:54
-- License: MIT/X11
-- pewx.de // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--
wfc = {}
wfc.__index = wcf

function wcf:connect(host, username, password, database)
	local c = {}
	c.hCon = dbConnect("mysql", ("dbname=%s;host=%s"):format(database, host), username, password, "autoreconnect=1")
	return setmetatable(c, wcf)
end

function wcf:disconnect()
	destroyElement(self.hCon)
end