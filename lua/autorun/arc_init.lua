--[[
	Anomaly Research Center (A.R.C.) Exploration
	Revealing and exposing curses.
	https://github.com/Xalalau/Anomaly-Research-Center-ARC
	https://discord.gg/97UpY3D7XB

	Created by Xalalau and A.R.C. Community, 2022
	MIT License
]]

CGM13 = { -- Community GM13
	luaFolder = "arc",
	Vehicle = {},
	Addon = {}
}

hook.Add("Initialize", CGM13.luaFolder .. "_init", function()
	GM13:IncludeBase(CGM13)
end)
