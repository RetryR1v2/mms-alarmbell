Config = {}

Config.defaultlang = "de_lang"

-- Script Settings

Config.AlarmBells = {
    {
        -- Bell Settings
        AlarmName = 'Valentine Alarm',
        Coords = vector3(-304.02, 742.29, 118.25),
        BellCooldown = 60, -- Time in Sec BELL COOLDOWN MUST BE HIGHER THEN BELL DURATION COOLDOWN is Synced
        -- Blip Settings
        CreateBlip = true,
        BlipSprite = 'blip_moonshine_still',
        BlipSize = 2.0,
        -- Prop Settings
        CreateProp = true,
        PropModel = 'bra_01_bell01x',
        -- XSound Settings
        RingBell = true,
        BellLink = 'https://www.youtube.com/watch?v=mu1hYDrJNuM',
        BellVolume = 0.5,
        BellRadius = 500,
        BellDuration = 25,
    },
}