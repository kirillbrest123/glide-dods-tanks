AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_tank"
ENT.PrintName = "Sherman"
ENT.Spawnable = true

ENT.GlideCategory = "Day Of Defeat: Source"
ENT.ChassisModel = "models/blu/tanks/sherman.mdl"

DEFINE_BASECLASS( "glide_dods_tank_base" )

ENT.TurretBaseBone = "turret_yaw"
ENT.CannonBaseBone = "turret_pitch"

if CLIENT then
    ENT.CameraCenterOffset = Vector( 0, 0, 32 )
    ENT.CameraOffset = Vector( -380, 0, 150 )

    ENT.WeaponInfo = {
        { name = "#glide.weapons.cannon", icon = "glide/icons/tank.png" },
        { name = "#glide.weapons.mgs", icon = "glide/icons/bullets.png" }
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( -79.66, 0, 72.21 ), angle = Angle( 0, 90, 0 ), scale = 1.5 }
    }

    ENT.EngineSmokeStrips = {
        { offset = Vector( -57, 0, 75 ), angle = Angle( 0, 180, 0 ), width = 35 },
        -- { offset = Vector( -95, -45, 73 ), angle = Angle( 0, 180, 0 ), width = 25 }
    }

    ENT.SuspensionParamsLeft = {}
    ENT.SuspensionParamsRight = {}
    ENT.WheelBonesLeft = {}
    ENT.WheelBonesRight = {}

    for i = 1, 6 do
        table.insert( ENT.SuspensionParamsLeft, "suspension_left_" .. i )
    end

    for i = 1, 6 do
        table.insert( ENT.SuspensionParamsRight, "suspension_right_" .. i )
    end

    for i = 0, 7 do
        table.insert( ENT.WheelBonesLeft, "wheel_left_" .. i )
    end

    for i = 0, 7 do
        table.insert( ENT.WheelBonesRight, "wheel_right_" .. i )
    end

    local spinAng = Angle()

    function ENT:OnUpdateAnimations()
        if not self.turretBase then return end

        local dt = FrameTime()
        local spinL = -self:GetWheelSpin( 2 )

        spinAng[1] = 0
        spinAng[2] = 0
        spinAng[3] = spinL

        self.leftTrackScroll[2] = self.leftTrackScroll[2] + ( self.lastSpinL - spinL ) * dt * 0.4
        self.lastSpinL = spinL

        for _, id in ipairs( self.leftWheels ) do
            self:ManipulateBoneAngles( id, spinAng )
        end

        local spinR = -self:GetWheelSpin( 5 )
        spinAng[3] = spinR

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
                height = wheelOffsetsL[ left ]
            else
                height = ( wheelOffsetsL[ left ] * ( right - nk ) + wheelOffsetsL[ right ] * ( nk - left ) ) / ( right - left )
            end

            -- self:ManipulateBonePosition( id, offset )
            self:SetPoseParameter( id, height )
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

            self:SetPoseParameter( id, height )
        end
    end

    function ENT:OnCreateEngineStream( stream )
        stream.volume = 0.6

        stream:AddLayer( "m50", "simulated_vehicles/sherman/low.wav", {
            { "rpmFraction", 0, 0.8, "volume", 0, 1 },
            { "throttle", 0, 1, "volume", 0.7, 1 },
            { "rpmFraction", 0, 1, "pitch", 0.65, 1.1 },
            { "rpmFraction", 0.8, 1, "volume", 1, 0.4 },
        } )

        stream:AddLayer( "nanjing_loop", "simulated_vehicles/sherman/idle.wav", {
            { "rpmFraction", 0.2, 0.5, "volume", 0.8, 0 },
            { "rpmFraction", 0, 1, "pitch", 1, 1.2 },
        } )

        stream:AddLayer( "tiger_high", "simulated_vehicles/sherman/high.wav", {
            { "throttle", 0, 1, "volume", 0.4, 1 },
            { "rpmFraction", 0.8, 1, "volume", 0, 0.6 },
            -- { "rpmFraction", 0, 1, "pitch", 1, 1 },
        } )

    end
end

if SERVER then
    ENT.SpawnPositionOffset = Vector( 0, 0, 50 )

    ENT.ExplosionGibs = {
        "models/blu/tanks/sherman_gib_1.mdl",
        "models/blu/tanks/sherman_gib_2.mdl",
        "models/blu/tanks/sherman_gib_3.mdl",
        "models/blu/tanks/sherman_gib_4.mdl",
        "models/blu/tanks/sherman_gib_6.mdl",
        "models/blu/tanks/sherman_gib_7.mdl"
    }

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( 70, 0, 28 ), Angle( 0, 270, 30 ), Vector( 61, 110, 15 ), true )
        self:CreateSeat( Vector( 70, 0, 28 ), Angle( 0, 270, 30 ), Vector( 61, -110, 15 ), true )
        self:CreateSeat( Vector( 70, 0, 28 ), Angle( 0, 270, 30 ), Vector( -61, 110, 15 ), true )
        self:CreateSeat( Vector( 70, 0, 28 ), Angle( 0, 270, 30 ), Vector( -61, -110, 15 ), true )

        -- Front left
        self:CreateWheel( Vector( 85, 35, 30 ), {
            steerMultiplier = 1.25,
            -- suspensionLength = 24
        } )

        -- Middle left
        self:CreateWheel( Vector( 0, 35, 30 ), {
            -- suspensionLength = 24
        } )

        -- Rear left
        self:CreateWheel( Vector( -62, 35, 30 ), {
            -- suspensionLength = 24
        } )

        -- Front right
        self:CreateWheel( Vector( 85, -35, 30 ), {
            steerMultiplier = 1.25,
            -- suspensionLength = 24
        } )

        -- Middle right
        self:CreateWheel( Vector( 0, -35, 30 ), {
            -- suspensionLength = 24
        } )

        -- Rear right
        self:CreateWheel( Vector( -62, -35, 30 ), {
            -- suspensionLength = 24
        } )

        for _, w in ipairs( self.wheels ) do
            Glide.HideEntity( w, true )
        end

        -- Manipulate these on the server side only, to allow
        -- spawning projectiles on the correct position.
        self.turretBase = self:LookupBone( self.TurretBaseBone )
        self.cannonBase = self:LookupBone( self.CannonBaseBone )
        self.cannonMuzzle = self:LookupAttachment( "turret_cannon" )
        self.mgMuzzle = self:LookupAttachment( "turret_machinegun" )
    end

    ENT.TurretFireSound = "sherman_fire"
    ENT.TurretReloadSound = "sherman_reload"
    ENT.MGFireSound = "tiger_fire_mg"

    ENT.WeaponSlots = {
        { maxAmmo = 0, fireRate = 3.5, ammoType = "cannon" },
        { maxAmmo = 0, fireRate = 0.07, ammoType = "mg" }
    }

    function ENT:GetMachineGunStartPos()
        return self:GetAttachment( self.mgMuzzle ).Pos
    end

    function ENT:InitializePhysics()
        self:SetSolid( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:PhysicsInit( SOLID_VPHYSICS, Vector( 0, 0, 8 ) )
    end
end

function ENT:GetFirstPersonOffset()
    return Vector( -5, 0, 130 )
    -- return Vector( 40, 0, 115 )
end