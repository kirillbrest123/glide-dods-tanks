list.Set( "GlideCategories", "Day Of Defeat: Source", {
    name = "Day Of Defeat: Source",
    icon = "games/16/dod.png"
} )

sound.Add( {
    name = "tiger_fire",
    channel = CHAN_ITEM,
    volume = 1.0,
    level = 140,
    pitch = { 90, 110 },
    sound = "^simulated_vehicles/weapons/tiger_cannon.wav"
} )

sound.Add( {
    name = "tiger_fire_mg",
    channel = CHAN_WEAPON,
    volume = 1.0,
    level = 110,
    pitch = { 90, 110 },
    sound = "^simulated_vehicles/weapons/tiger_mg.wav"
} )

sound.Add( {
    name = "tiger_fire_mg_new",
    channel = CHAN_WEAPON,
    volume = 1.0,
    level = 110,
    pitch = { 90, 110 },
    sound = {"^simulated_vehicles/weapons/tiger_mg1.wav","^simulated_vehicles/weapons/tiger_mg2.wav","^simulated_vehicles/weapons/tiger_mg3.wav"}
} )

sound.Add( {
    name = "tiger_reload",
    channel = CHAN_STREAM,
    volume = 1.0,
    level = 70,
    pitch = { 90, 110 },
    sound = "simulated_vehicles/weapons/tiger_reload.wav"
} )

sound.Add( {
    name = "sherman_fire",
    channel = CHAN_ITEM,
    volume = 1.0,
    level = 140,
    pitch = { 90, 110 },
    sound = "^simulated_vehicles/weapons/sherman_cannon.wav"
} )

-- fun fact: this one is never actually used
-- sound.Add( {
--     name = "sherman_fire_mg",
--     channel = CHAN_WEAPON,
--     volume = 1.0,
--     level = 110,
--     pitch = { 90, 110 },
--     sound = "^simulated_vehicles/weapons/sherman_mg.wav"
-- } )

sound.Add( {
    name = "sherman_reload",
    channel = CHAN_STREAM,
    volume = 1.0,
    level = 70,
    pitch = { 90, 110 },
    sound = "simulated_vehicles/weapons/sherman_reload.wav"
} )