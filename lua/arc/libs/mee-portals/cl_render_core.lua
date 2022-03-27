-- this is the rendering code for the portals, some references from: https://github.com/MattJeanes/world-portals

local sky_cvar = GetConVar("sv_skyname")
local sky_name = ""
local sky_materials = {}

local portals = {}
local oldHalo = 0
local timesRendered = 0

local skysize = 16384	--2^14, default zfar limit
local angle_zero = Angle(0, 0, 0)

local renderViewTable = {
	origin = Vector(),
	angles = Angle(),
	drawviewmodel = false,
}

-- sort the portals by distance since draw functions do not obey the z buffer
timer.Create("cgm13_portal_distance_fix", 0.25, 0, function()
	if not CGM13.Portals or CGM13.Portals.portalIndex < 1 then return end

	portals = ents.FindByClass("cgm13_portal")
	table.sort(portals, function(a, b) 
		return a:GetPos():DistToSqr(EyePos()) < b:GetPos():DistToSqr(EyePos())
	end)

	-- update sky material (I guess it can change?)
	if sky_name ~= sky_cvar:GetString() then
		sky_name = sky_cvar:GetString()

		local prefix = "skybox/" .. sky_name
		sky_materials[1] = Material(prefix .. "bk")
		sky_materials[2] = Material(prefix .. "dn")
		sky_materials[3] = Material(prefix .. "ft")
		sky_materials[4] = Material(prefix .. "lf")
		sky_materials[5] = Material(prefix .. "rt")
		sky_materials[6] = Material(prefix .. "up")
	end
end)

-- update the rendertarget here since we cant do it in postdraw (cuz of infinite recursion)
local physgun_halo = GetConVar("physgun_halo")
hook.Add("RenderScene", "cgm13_portals_draw", function(eyePos, eyeAngles, fov)
	if not CGM13.Portals or CGM13.Portals.portalIndex < 1 or CGM13.Portals.Rendering then return end
	CGM13.Portals.Rendering = true

	-- black halo clipping plane fix (Thanks to homonovus)
	physgun_halo = physgun_halo or GetConVar("physgun_halo")
	local oldHalo = physgun_halo:GetInt()
	physgun_halo:SetInt(0)

	for k, v in ipairs(portals) do
		if v:IsValid() and v:ExitPortal():IsValid() then
			if timesRendered < CGM13.Portals.MaxRTs and v.PORTAL_SHOULDRENDER then
				local exitPortal = v:ExitPortal()
				local editedPos, editedAng = CGM13.Portals.TransformPortal(v, exitPortal, eyePos, eyeAngles)

				renderViewTable.origin = editedPos
				renderViewTable.angles = editedAng
				renderViewTable.fov = fov

				v.PORTAL_RT_NUMBER = timesRendered + 1	-- the number index of the rendertarget it will use in rendering

				-- render the scene
				local oldClip = render.EnableClipping(true)
				render.PushRenderTarget(CGM13.Portals.PortalRTs[timesRendered + 1])
				render.PushCustomClipPlane(exitPortal:GetUp(), exitPortal:GetUp():Dot(exitPortal:GetPos() + exitPortal:GetUp() * 0.1))
				render.RenderView(renderViewTable)
				render.PopCustomClipPlane()
				render.EnableClipping(oldClip)
				render.PopRenderTarget()

				timesRendered = timesRendered + 1
			end

			if timesRendered >= CGM13.Portals.MaxRTs then break end
		end
	end

	physgun_halo:SetInt(oldHalo)

	CGM13.Portals.Rendering = false
	timesRendered = 0
end)

-- draw the player in renderview
hook.Add("ShouldDrawLocalPlayer", "cgm13_portal_drawplayer", function()
	if CGM13.Portals.Rendering and not CGM13.Portals.DrawPlayerInView then 
		return true 
	end
end)

-- (REWRITE THIS!)
-- draw the 2d skybox in place of the black (Thanks to Fafy2801)
local function drawsky(pos, ang, size, size_2, color, materials)
	-- BACK
	render.SetMaterial(materials[1])
	render.DrawQuadEasy(pos + Vector(0, size, 0), ang:Right(), size_2, size_2, color, 0)
	-- DOWN
	render.SetMaterial(materials[2])
	render.DrawQuadEasy(pos - Vector(0, 0, size), ang:Up(), size_2, size_2, color, 180)
	-- FRONT
	render.SetMaterial(materials[3])
	render.DrawQuadEasy(pos - Vector(0, size, 0), -ang:Right(), size_2, size_2, color, 0)
	-- LEFT
	render.SetMaterial(materials[4])
	render.DrawQuadEasy(pos - Vector(size, 0, 0), ang:Forward(), size_2, size_2, color, 0)
	-- RIGHT
	render.SetMaterial(materials[5])
	render.DrawQuadEasy(pos + Vector(size, 0, 0), -ang:Forward(), size_2, size_2, color, 0)
	-- UP
	render.SetMaterial(materials[6])
	render.DrawQuadEasy(pos + Vector(0, 0, size), -ang:Up(), size_2, size_2, color, 180)
end

hook.Add("PostDrawTranslucentRenderables", "cgm13_portal_skybox", function()
	if not CGM13.Portals or CGM13.Portals.portalIndex < 1 then return end
	if not CGM13.Portals.Rendering or util.IsSkyboxVisibleFromPoint(renderViewTable.origin) then return end
	render.OverrideDepthEnable(true, false)
	drawsky(renderViewTable.origin, angle_zero, skysize, -skysize * 2, color_white, sky_materials)
	render.OverrideDepthEnable(false , false)
end)
