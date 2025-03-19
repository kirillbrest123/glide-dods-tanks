AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_tank"
ENT.PrintName = "Tiger"

ENT.Spawnable = true

ENT.GlideCategory = "Day Of Defeat: Source"
ENT.ChassisModel = "models/blu/tanks/tiger.mdl"

DEFINE_BASECLASS( "glide_dods_tank_base" )

ENT.TurretBaseBone = "turret_yaw"
ENT.CannonBaseBone = "cannon_pitch"

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
        { offset = Vector( -95, 45, 73 ), angle = Angle( 0, 180, 0 ), width = 25 },
        { offset = Vector( -95, -45, 73 ), angle = Angle( 0, 180, 0 ), width = 25 }
    }

    ENT.SuspensionParamsLeft = {}
    ENT.SuspensionParamsRight = {}
    ENT.WheelBonesLeft = {}
    ENT.WheelBonesRight = {}

    for i = 1, 8 do
        table.insert( ENT.SuspensionParamsLeft, "suspension_left_" .. i )
    end

    for i = 1, 8 do
        table.insert( ENT.SuspensionParamsRight, "suspension_right_" .. i )
    end

    for i = 0, 7 do
        table.insert( ENT.WheelBonesLeft, "wheel_left_" .. i )
    end

    for i = 0, 7 do
        table.insert( ENT.WheelBonesRight, "wheel_right_" .. i )
    end

    function ENT:OnCreateEngineStream( stream )
        stream.volume = 0.4

        stream:AddLayer( "m50", "simulated_vehicles/misc/m50.wav", {
            { "rpmFraction", 0, 0.8, "volume", 0, 1 },
            { "throttle", 0, 1, "volume", 0.7, 1 },
            { "rpmFraction", 0, 1, "pitch", 0.65, 1.1 },
            { "rpmFraction", 0.8, 1, "volume", 1, 0.4 },
        } )

        stream:AddLayer( "nanjing_loop", "simulated_vehicles/misc/nanjing_loop.wav", {
            { "rpmFraction", 0.2, 0.5, "volume", 0.8, 0 },
            { "rpmFraction", 0, 1, "pitch", 1, 1.2 },
        } )

        stream:AddLayer( "tiger_high", "simulated_vehicles/tiger/tiger_high.wav", {
            { "throttle", 0, 1, "volume", 0.4, 1 },
            { "rpmFraction", 0.8, 1, "volume", 0, 0.6 },
            { "rpmFraction", 0, 1, "pitch", 0.65, 0.75 },
        } )

    end
end

if SERVER then
    ENT.SpawnPositionOffset = Vector( 0, 0, 50 )

    ENT.ExplosionGibs = {
        "models/blu/tanks/tiger_gib_1.mdl",
        "models/blu/tanks/tiger_gib_2.mdl",
        "models/blu/tanks/tiger_gib_3.mdl",
        "models/blu/tanks/tiger_gib_4.mdl"
    }

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( 70, 0, 28 ), Angle( 0, 270, 30 ), Vector( 61, 130, 15 ), true )
        self:CreateSeat( Vector( 70, 0, 28 ), Angle( 0, 270, 30 ), Vector( 61, -130, 15 ), true )
        self:CreateSeat( Vector( 70, 0, 28 ), Angle( 0, 270, 30 ), Vector( -61, 130, 15 ), true )
        self:CreateSeat( Vector( 70, 0, 28 ), Angle( 0, 270, 30 ), Vector( -61, -130, 15 ), true )

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

    ENT.TurretFireSound = "tiger_fire"
    ENT.TurretReloadSound = "tiger_reload"
    ENT.MGFireSound = "tiger_fire_mg_new"
    ENT.MGOffset = Vector( -20, 0, -140 )

    ENT.WeaponSlots = {
        { maxAmmo = 0, fireRate = 3.5, ammoType = "cannon" },
        { maxAmmo = 0, fireRate = 0.07, ammoType = "mg" }
    }

    local offset = Vector( -20, 0, -140 )

    function ENT:GetMachineGunStartPos()
        local att = self:GetAttachment( self.cannonMuzzle )

        return LocalToWorld( offset, angle_zero, att.Pos, att.Ang )
    end

    function ENT:InitializePhysics()
        self:SetSolid( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:PhysicsInit( SOLID_VPHYSICS, Vector( 0, 0, 8 ) )
    end
end

function ENT:GetFirstPersonOffset()
    return Vector( 0, 0, 135 )
end