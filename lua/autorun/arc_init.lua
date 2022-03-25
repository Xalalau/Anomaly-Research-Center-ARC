--[[
	Anomaly Research Center (A.R.C.) Exploration
	Revealing and exposing curses.
	https://github.com/Xalalau/Anomaly-Research-Center-ARC
	https://discord.gg/97UpY3D7XB

	Created by Xalalau and ARC community, 2022
	MIT License
]]

CGM13 = { -- Community GM13
	Vehicle = {},
	Custom = {}
}

hook.Add("Initialize", "arc_int", function()
	GM13:IncludeBase("arc")
end)
