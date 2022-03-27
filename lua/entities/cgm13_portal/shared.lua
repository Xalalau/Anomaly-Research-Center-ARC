-- Seamless portals addon by Mee
-- You may use this code as a reference for your own projects, but please do not publish this addon as your own.
-- 	   New: Adapted to gm_construct 13 beta as a library, as MIT license and GMod Workshop rules allow.
--          This is by no means an addon reupload, the code has been modified and the rights respected.

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.Category     = "Seamless Portals"
ENT.PrintName    = "Seamless Portal"
ENT.Author       = "Mee"
ENT.Purpose      = ""
ENT.Instructions = ""
ENT.Spawnable    = false

function ENT:IncrementPortal()
	CGM13.Portals.portalIndex = CGM13.Portals.portalIndex + 1
end

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "PortalExit")
	self:NetworkVar("Vector", 0, "PortalScale")
	self:NetworkVar("Bool", 0, "DisableBackface")
end

function ENT:LinkPortal(ent)
	if not ent or not ent:IsValid() then return end
	self.PORTAL_EXIT = ent
	ent.PORTAL_EXIT = self
	self:SetPortalExit(ent)
	ent:SetPortalExit(self)
end

function ENT:GetExitSize()
	return CLIENT and self:GetPortalScale() or SERVER and self.PORTAL_SCALE
end

-- get exit portal
function ENT:ExitPortal()
	return CLIENT and self:GetPortalExit() or SERVER and self.PORTAL_EXIT
end

-- custom size for portal
function ENT:SetExitSize(n)
	self.PORTAL_SCALE = n
	self:SetPortalScale(n)
	self:UpdatePhysmesh(n)
end

function ENT:OnRemove()
	CGM13.Portals.portalIndex = CGM13.Portals.portalIndex - 1
	if SERVER and self.PORTAL_REMOVE_EXIT then
		SafeRemoveEntity(self:ExitPortal())
	end
end

-- scale the physmesh
function ENT:UpdatePhysmesh()
	self:PhysicsInit(6)
	if self:GetPhysicsObject():IsValid() then
		local finalMesh = {}
		for k, tri in pairs(self:GetPhysicsObject():GetMeshConvexes()[1]) do
			tri.pos = tri.pos * self:GetExitSize()
			table.insert(finalMesh, tri.pos)
		end
		self:PhysicsInitConvex(finalMesh)
		self:EnableCustomCollisions(true)
		self:GetPhysicsObject():EnableMotion(false)
		self:GetPhysicsObject():SetMaterial("glass")
		self:GetPhysicsObject():SetMass(250)

		if CLIENT then 
			local mins, maxs = self:GetModelBounds()
			self:SetRenderBounds(mins * self:GetExitSize(), maxs * self:GetExitSize())
		end
	else
		self:PhysicsDestroy()
		self:EnableCustomCollisions(false)
		print("CGM13 Portal: Failure to create a portal physics mesh " .. self:EntIndex())
	end
end

CGM13.Portals.portalIndex = #ents.FindByClass("cgm13_portal") -- for hotreloading
CGM13.Portals.MaxRTs = 6
CGM13.Portals.TransformPortal = function(a, b, pos, ang)
	if not a or not b or not b:IsValid() or not a:IsValid() then return Vector(), Angle() end
	local editedPos = Vector()
	local editedAng = Angle()

	if pos then
		editedPos = a:WorldToLocal(pos) * (b:GetExitSize()[1] / a:GetExitSize()[1])
		editedPos = b:LocalToWorld(Vector(editedPos[1], -editedPos[2], -editedPos[3]))
		editedPos = editedPos + b:GetUp()
	end

	if ang then
		local clonedAngle = Angle(ang[1], ang[2], ang[3]) -- rotatearoundaxis modifies original variable
		clonedAngle:RotateAroundAxis(a:GetForward(), 180)
		editedAng = b:LocalToWorldAngles(a:WorldToLocalAngles(clonedAngle))
	end

	return editedPos, editedAng
end
