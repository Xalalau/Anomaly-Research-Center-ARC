--[[
	Anomaly Research Center (A.R.C.) Exploration
	Revealing and exposing curses.
	https://github.com/Xalalau/Anomaly-Research-Center-ARC
	https://discord.gg/97UpY3D7XB

	Created by Xalalau and A.R.C. Community, 2022
	MIT License
]]

CGM13 = { -- Community GM13
	name = "arc",
	toolCategories = { 
		"ARC Tools"
	},
	Vehicle = {},
	Custom = {},
	Portals = {
		portalIndex = 0
	}
}

hook.Add("Initialize", CGM13.name .. "_int", function()
	GM13:IncludeBase(CGM13)
end)
