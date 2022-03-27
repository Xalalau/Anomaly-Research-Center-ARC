include("shared.lua")

-- create global table
CGM13.Portals.VarDrawDistance = CreateClientConVar("cgm13_portal_drawdistance", "2500", true, false, "Sets the size of the portal along the Y axis", 0)

local function startUpdateMesh(ent)
    if ent.UpdatePhysmesh then
        ent:UpdatePhysmesh()
    else
        -- takes a minute to try and find the portal, if it cant, oh well...
        timer.Create("cgm13_portal_init" .. CGM13.Portals.portalIndex, 1, 60, function()
            if not ent or not ent:IsValid() or not ent.UpdatePhysmesh then return end

            ent:UpdatePhysmesh()
            timer.Remove("cgm13_portal_init" .. CGM13.Portals.portalIndex)
        end)
    end
end

function ENT:Initialize()
	self:IncrementPortal()
	startUpdateMesh(self)
end

-- set physmesh pos
function ENT:Think()
    local phys = self:GetPhysicsObject()
    if phys:IsValid() and phys:GetPos() ~= self:GetPos() then
        phys:EnableMotion(false)
        phys:SetMaterial("glass")
        phys:SetPos(self:GetPos())
        phys:SetAngles(self:GetAngles())
    end
end

hook.Add("InitPostEntity", "cgm13_portal_init", function()
    for k, v in ipairs(ents.FindByClass("cgm13_portal")) do
		self:IncrementPortal()
		startUpdateMesh(v)
    end

    -- this code creates the rendertargets to be used for the portals
    CGM13.Portals.PortalRTs = {}
    CGM13.Portals.PortalMaterials = {}

    for i = 1, CGM13.Portals.MaxRTs do
        CGM13.Portals.PortalRTs[i] = GetRenderTarget("CGM13SeamlessPortal" .. i, ScrW(), ScrH())
        CGM13.Portals.PortalMaterials[i] = CreateMaterial("CGM13.PortalsMaterial" .. i, "GMODScreenspace", {
            ["$basetexture"] = CGM13.Portals.PortalRTs[i]:GetName(),
            ["$model"] = "1"
        })
    end
end)

local function DrawQuadEasier(e, multiplier, offset, rotate)
	local ex, ey, ez = e:GetForward(), e:GetRight(), e:GetUp()
	local rotate = (tonumber(rotate) or 0)
	local mx = ey * multiplier.x
	local my = ex * multiplier.y
	local mz = ez * multiplier.z
	local ox = ey * offset.x -- currently zero
	local oy = ex * offset.y -- currently zero
	local oz = ez * offset.z

	local pos = e:GetPos() + ox + oy + oz
	if rotate == 0 then
		render.DrawQuad(
			pos + mx - my + mz,
			pos - mx - my + mz,
			pos - mx + my + mz,
			pos + mx + my + mz
		)
	elseif rotate == 1 then
		render.DrawQuad(
			pos + mx + my - mz,
			pos - mx + my - mz,
			pos - mx + my + mz,
			pos + mx + my + mz
		)
	elseif rotate == 2 then
		render.DrawQuad(
			pos + mx - my + mz,
			pos + mx - my - mz,
			pos + mx + my - mz,
			pos + mx + my + mz
		)
	else
		print("CGM13 Portal: Failed processing rotation:", tostring(rotate))
	end
end

local drawMat1 = Material("models/props_combine/combine_interface_disp")
local drawMat2 = Material("Models/effects/vol_light001")
function ENT:Draw()
	local exsize = self:GetExitSize()
	local backAmt = 3 * exsize[3]
	local backVec = Vector(0, 0, -backAmt)
	local epos, spos, vup = EyePos(), self:GetPos(), self:GetUp()
	local scalex = (self:OBBMaxs().x - self:OBBMins().x) * 0.5 - 0.1
	local scaley = (self:OBBMaxs().y - self:OBBMins().y) * 0.5 - 0.1

	-- optimization checks
	local exitInvalid = not self:ExitPortal() or not self:ExitPortal():IsValid()
	local shouldRenderPortal = false
	if not CGM13.Portals.Rendering and not exitInvalid then
		local margnPortal = CGM13.Portals.VarDrawDistance:GetFloat()^2
		local behindPortal = (epos - spos):Dot(vup) < (-10 * exsize[1]) -- true if behind the portal, false otherwise
		local distPortal = epos:DistToSqr(spos) > (margnPortal * exsize[1]) -- too far away

		shouldRenderPortal = behindPortal or distPortal
	end

	self.PORTAL_SHOULDRENDER = not shouldRenderPortal

	if exitInvalid then
		render.SetMaterial(drawMat1)
	else
		render.SetMaterial(drawMat2)
	end

	-- holy shit lol this if statment
	if CGM13.Portals.Rendering or exitInvalid or shouldRenderPortal or halo.RenderedEntity() == self then
		if not self:GetDisableBackface() then
			render.DrawBox(spos, self:LocalToWorldAngles(Angle(0, 90, 0)), Vector(-scaley, -scalex, -backAmt * 2), Vector(scaley, scalex, 0))
		end

		return
	end

	-- outer quads
	if not self:GetDisableBackface() then
		DrawQuadEasier(self, Vector( scaley, -scalex, -backAmt), backVec)
		DrawQuadEasier(self, Vector( scaley, -scalex,  backAmt), backVec, 1)
		DrawQuadEasier(self, Vector( scaley,  scalex, -backAmt), backVec, 1)
		DrawQuadEasier(self, Vector( scaley, -scalex,  backAmt), backVec, 2)
		DrawQuadEasier(self, Vector(-scaley, -scalex, -backAmt), backVec, 2)
	end

	-- do cursed stencil stuff
	render.ClearStencil()
	render.SetStencilEnable(true)
	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)
	render.SetStencilReferenceValue(1)
	render.SetStencilFailOperation(STENCIL_KEEP)
	render.SetStencilZFailOperation(STENCIL_KEEP)
	render.SetStencilPassOperation(STENCIL_REPLACE)
	render.SetStencilCompareFunction(STENCIL_ALWAYS)

	-- draw the quad that the 2d texture will be drawn on
	-- teleporting causes flashing if the quad is drawn right next to the player, so we offset it
	DrawQuadEasier(self, Vector( scaley,  scalex, -backAmt), backVec)
	DrawQuadEasier(self, Vector( scaley,  scalex,  backAmt), backVec, 1)
	DrawQuadEasier(self, Vector( scaley, -scalex, -backAmt), backVec, 1)
	DrawQuadEasier(self, Vector( scaley,  scalex,  backAmt), backVec, 2)
	DrawQuadEasier(self, Vector(-scaley,  scalex, -backAmt), backVec, 2)

	-- draw the actual portal texture
	render.SetMaterial(CGM13.Portals.PortalMaterials[self.PORTAL_RT_NUMBER or 1])
	render.SetStencilCompareFunction(STENCIL_EQUAL)
	render.DrawScreenQuad()
	render.SetStencilEnable(false)

	--self.PORTAL_SHOULDRENDER = true
end