AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_tank"
ENT.PrintName = "Tiger"
ENT.Spawnable = false

ENT.ChassisModel = "models/blu/tanks/tiger.mdl"

DEFINE_BASECLASS( "base_glide_tank" )

ENT.TurretBaseBone = "turret_yaw"
ENT.CannonBaseBone = "cannon_pitch"

if CLIENT then
    ENT.CameraCenterOffset = Vector( 0, 0, 32 )
    ENT.CameraOffset = Vector( -380, 0, 150 )

    ENT.WeaponInfo = {
        { name = "#glide.weapons.cannon", icon = "glide/icons/tank.png" },
        { name = "#glide.weapons.mgs", icon = "glide/icons/bullets.png" }
    }

    ENT.EngineFireOffsets = {}

    ENT.EngineSmokeStrips = {}

    ENT.SuspensionParamsLeft = {}
    ENT.SuspensionParamsRight = {}
    ENT.WheelBonesLeft = {}
    ENT.WheelBonesRight = {}

    function ENT:OnActivateMisc()
        self:SetupLeftTrack( 1, "models/blu/track" )
        self:SetupRightTrack( 2, "models/blu/track" )

        self.lastSpinL = 0
        self.lastSpinR = 0

        -- Turret
        self.turretBase = self:LookupBone( self.TurretBaseBone )
        self.cannonBase = self:LookupBone( self.CannonBaseBone )

        -- Left suspension

        self.leftSuspension = {}

        for k, v in ipairs( self.SuspensionParamsLeft ) do
            table.insert( self.leftSuspension, self:LookupPoseParameter( v ) )
        end

        self.leftWheels = {}

        for k, v in ipairs( self.WheelBonesLeft ) do
            table.insert( self.leftWheels, self:LookupBone( v ) )
        end

        self.rightSuspension = {}

        for k, v in ipairs( self.SuspensionParamsRight ) do
            table.insert( self.rightSuspension, self:LookupPoseParameter( v ) )
        end

        self.rightWheels = {}

        for k, v in ipairs( self.WheelBonesRight ) do
            table.insert( self.rightWheels, self:LookupBone( v ) )
        end
    end

    local spinAng = Angle()

    function ENT:OnUpdateAnimations()
        if not self.turretBase then return end

        local dt = FrameTime()
        local spinL = -self:GetWheelSpin( 2 )

        spinAng[1] = 0
        spinAng[3] = 0
        spinAng[2] = -spinL

        self.leftTrackScroll[2] = self.leftTrackScroll[2] + ( self.lastSpinL - spinL ) * dt * 0.4
        self.lastSpinL = spinL

        for _, id in ipairs( self.leftWheels ) do
            self:ManipulateBoneAngles( id, spinAng )
        end

        local spinR = -self:GetWheelSpin( 5 )
        spinAng[2] = -spinR

        self.rightTrackScroll[2] = self.rightTrackScroll[2] + ( self.lastSpinR - spinR ) * dt * 0.35
        self.lastSpinR = spinR

        for _, id in ipairs( self.rightWheels ) do
            self:ManipulateBoneAngles( id, spinAng )
        end

        if next( self.wheels ) == nil then return end

        -- Update left side of the tracks, using the 3 wheels we have there.
        local wheelOffsetsL = {}

        for i = 1, #self.wheels / 2 do
            table.insert( wheelOffsetsL, self:GetWheelOffset( i ) + 14 )
        end

        -- Linear interpolation
        for k, id in ipairs( self.leftSuspension ) do
            local nk = ( k - 1 ) / ( #self.leftSuspension - 1 ) * ( #wheelOffsetsL - 1 ) + 1
            local left = math.floor( nk )
            local right = math.ceil( nk )

            local height = 0

            if left == right then
                if !wheelOffsetsL[ left ] then
                    error( "Tell an admin these numbers: left: " .. left .. " nk: " .. nk .. " #leftSuspension: " .. #self.leftSuspension .. " #wheelOffsetsL: " .. #wheelOffsetsL )
                end
                height = wheelOffsetsL[ left ]
            else
                height = ( wheelOffsetsL[ left ] * ( right - nk ) + wheelOffsetsL[ right ] * ( nk - left ) ) / ( right - left )
            end

            -- self:ManipulateBonePosition( id, offset )
            self:SetPoseParameter( id, -height )
        end

        -- Update right side of the tracks, using the 3 wheels we have there.
        local wheelOffsetsR = {}

        for i = #self.wheels / 2 + 1, #self.wheels do
            table.insert( wheelOffsetsR, self:GetWheelOffset( i ) + 14 )
        end

        -- Linear interpolation
        for k, id in ipairs( self.rightSuspension ) do
            local nk = ( k - 1 ) / ( #self.rightSuspension - 1 ) * ( #wheelOffsetsR - 1 ) + 1
            local left = math.floor( nk )
            local right = math.ceil( nk )

            local height = 0

            if left == right then
                height = wheelOffsetsR[ left ]
            else
                height = ( wheelOffsetsR[ left ] * ( right - nk ) + wheelOffsetsR[ right ] * ( nk - left ) ) / ( right - left )
            end

            self:SetPoseParameter( id, -height )
        end
    end
end

if SERVER then
    ENT.SpawnPositionOffset = Vector( 0, 0, 50 )

    ENT.ExplosionGibs = {}

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( 70, 0, 28 ), Angle( 0, 270, 30 ), Vector( 61, 130, 15 ), false )

        -- Front left
        self:CreateWheel( Vector( 90, 45, 32 ), {
            steerMultiplier = 1.25,
            suspensionLength = 24
        } )

        -- Middle left
        self:CreateWheel( Vector( 5, 45, 32 ), {
            suspensionLength = 24
        } )

        -- Rear left
        self:CreateWheel( Vector( -70, 45, 32 ), {
            suspensionLength = 24
        } )

        -- Front right
        self:CreateWheel( Vector( 90, -45, 32 ), {
            steerMultiplier = 1.25,
            suspensionLength = 24
        } )

        -- Middle right
        self:CreateWheel( Vector( 5, -45, 32 ), {
            suspensionLength = 24
        } )

        -- Rear right
        self:CreateWheel( Vector( -70, -45, 32 ), {
            suspensionLength = 24
        } )


        for _, w in ipairs( self.wheels ) do
            Glide.HideEntity( w, true )
        end

        -- Manipulate these on the server side only, to allow
        -- spawning projectiles on the correct position.
        self.turretBase = self:LookupBone( self.TurretBaseBone )
        self.cannonBase = self:LookupBone( self.CannonBaseBone )
        self.cannonMuzzle = self:LookupAttachment( "muzzle" )
    end

    function ENT:GetProjectileStartPos()
        if self.cannonMuzzle then
            return self:GetAttachment( self.cannonMuzzle ).Pos
        end

        return BaseClass.GetProjectileStartPos( self )
    end

    function ENT:GetMachineGunStartPos()
        return vector_origin
    end

    ENT.TurretFireSound = "tiger_fire"
    ENT.TurretReloadSound = "tiger_reload"
    ENT.MGFireSound = "tiger_fire_mg_new"

    ENT.WeaponSlots = {
        { maxAmmo = 0, fireRate = 3.5, ammoType = "cannon" },
        { maxAmmo = 0, fireRate = 0.07, ammoType = "mg" }
    }

    function ENT:OnWeaponFire( weapon )
        if self:WaterLevel() > 2 then return end

        if weapon.ammoType == "cannon" then
            if self.isCannonInsideWall then
                weapon.nextFire = 0
                return
            end

            local aimPos = self:GetTurretAimPosition()
            local projectilePos = self:GetProjectileStartPos()

            -- Make the projectile point towards the direction the
            -- turret is aiming at, no matter where it spawned.
            local dir = aimPos - projectilePos
            dir:Normalize()

            local projectile = Glide.FireProjectile( projectilePos, dir:Angle(), self:GetDriver(), self )
            projectile.damage = self.TurretDamage

            self:EmitSound( self.TurretFireSound, 100, math.random( 95, 105 ), self.TurretFireVolume )
            self:EmitSound( self.TurretReloadSound, 70, math.random( 90, 100 ), 1 )

            local eff = EffectData()
            eff:SetOrigin( projectilePos )
            eff:SetNormal( dir )
            eff:SetScale( 1 )
            util.Effect( "glide_tank_cannon", eff )

            local phys = self:GetPhysicsObject()

            if IsValid( phys ) then
                phys:ApplyForceOffset( dir * phys:GetMass() * -self.TurretRecoilForce, projectilePos )
            end

            local driver = self:GetDriver()

            if IsValid( driver ) then
                Glide.SendViewPunch( driver, -0.2 )
            end
        else
            self:EmitSound( self.MGFireSound )

            local pos = self:GetMachineGunStartPos()
            local aimPos = self:GetTurretAimPosition()

            local dir = aimPos - pos
            dir:Normalize()


            self:FireBullet( {
                pos = pos,
                ang = dir:Angle(),
                attacker = attacker,
                spread = 0.5,
                damage = 20,
            } )
        end
    end

    function ENT:GetSpawnColor()
        return Color( 255, 255, 255 )
    end

    function ENT:InitializePhysics()
        self:SetSolid( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:PhysicsInit( SOLID_VPHYSICS, Vector( 0, 0, 8 ) )
    end
end

local ang = Angle()

function ENT:ManipulateTurretBones( turretAng )
    if not self.turretBase then return end

    ang[1] = turretAng[2]
    ang[2] = 0
    ang[3] = 0

    self:ManipulateBoneAngles( self.turretBase, ang, false )

    ang[1] = 0
    ang[2] = 0
    ang[3] = turretAng[1]

    self:ManipulateBoneAngles( self.cannonBase, ang, false )
end

function ENT:GetFirstPersonOffset()
    return Vector( 0, 0, 135 )
end