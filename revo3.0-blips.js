//Use this function instead of Citizen.Wait()
function Delay(ms) {
    return new Promise((res) => {
        setTimeout(res, ms)
    })
}

// Draw text with x y
function DrawTxt(text, x, y) {
  SetTextFont(1)
  SetTextProportional(1)
  SetTextScale(0.0, 0.6)
  SetTextDropshadow(1, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x, y)
}

// Draw 3D Text
function DrawText3D(x, y, z, text, r, g, b) {
  SetDrawOrigin(x, y, z, 0)
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.0, 0.20)
  SetTextColour(r, g, b, 255)
  SetTextDropshadow(0, 0, 0, 0, 255)
  SetTextEdge(2, 0, 0, 0, 150)
  SetTextDropShadow()
  SetTextOutline()
  SetTextEntry("STRING")
  SetTextCentre(1)
  AddTextComponentString(text)
  DrawText(0.0, 0.0)
  ClearDrawOrigin()
}

//RGB Text
function RGB(frequency) {
  var result = {}
  var curtime = GetGameTimer() / 2000
  result.r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
  result.g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
  result.b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)

  return result
}

//notification
function notify(text) {
  SetNotificationTextEntry("STRING")
  AddTextComponentString(text)
  DrawNotification(true, false)
}


// Input Mode
function GetInputMode() {
  return IsInputDisabled(2) && "MouseAndKeyboard" || "GamePad"
}

// KeyboardInput
async function KeyboardInput(TextEntry, ExampleText, MaxStringLength) {
  AddTextEntry("FMMC_KEY_TIP1", TextEntry + ":")
  DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
  while (UpdateOnscreenKeyboard() == 0){
    DisableAllControlActions(0)
    if (IsDisabledControlPressed(0, 322)) return ""
    await Delay(5)
  }
  if (GetOnscreenKeyboardResult()){
    var result = GetOnscreenKeyboardResult()
    return result
  }
}

////////////////////////////////FUNCTIONS//////////////////////////////
// TPToNearCar
function TPtoNearCar() {
  var playerPed = GetPlayerPed(-1)
  var playerPedPos = GetEntityCoords(playerPed, true)
  var NearestVehicle = GetClosestVehicle(GetEntityCoords(playerPed, true), 1000.0, 0, 4)
  var NearestVehiclePos = GetEntityCoords(NearestVehicle, true)
  var NearestPlane = GetClosestVehicle(GetEntityCoords(playerPed, true), 1000.0, 0, 16384)
  var NearestPlanePos = GetEntityCoords(NearestPlane, true)
  if ((NearestVehicle == 0) && (NearestPlane == 0)) {
    notify("~b~No Vehicle Found", true)
  } else if ((NearestVehicle == 0) && (NearestPlane != 0)) {
    if (IsVehicleSeatFree(NearestPlane, -1)) {
      SetPedIntoVehicle(playerPed, NearestPlane, -1)
      SetVehicleAlarm(NearestPlane, false)
      SetVehicleDoorsLocked(NearestPlane, 1)
      SetVehicleNeedsToBeHotwired(NearestPlane, false)
    } else {
      var driverPed = GetPedInVehicleSeat(NearestPlane, -1)
      ClearPedTasksImmediately(driverPed)
      SetEntityAsMissionEntity(driverPed, 1, 1)
      DeleteEntity(driverPed)
      SetPedIntoVehicle(playerPed, NearestPlane, -1)
      SetVehicleAlarm(NearestPlane, false)
      SetVehicleDoorsLocked(NearestPlane, 1)
      SetVehicleNeedsToBeHotwired(NearestPlane, false)
    }
    notify("~g~Teleported Into Nearest Vehicle!", false)
  } else if ((NearestVehicle != 0) && (NearestPlane == 0)) {
    if (IsVehicleSeatFree(NearestVehicle, -1)) {
      SetPedIntoVehicle(playerPed, NearestVehicle, -1)
      SetVehicleAlarm(NearestVehicle, false)
      SetVehicleDoorsLocked(NearestVehicle, 1)
      SetVehicleNeedsToBeHotwired(NearestVehicle, false)
    } else {
      var driverPed = GetPedInVehicleSeat(NearestVehicle, -1)
      ClearPedTasksImmediately(driverPed)
      SetEntityAsMissionEntity(driverPed, 1, 1)
      DeleteEntity(driverPed)
      SetPedIntoVehicle(playerPed, NearestVehicle, -1)
      SetVehicleAlarm(NearestVehicle, false)
      SetVehicleDoorsLocked(NearestVehicle, 1)
      SetVehicleNeedsToBeHotwired(NearestVehicle, false)
    }
    notify("~g~Teleported Into Nearest Vehicle!", false)
  } else if ((NearestVehicle != 0) && (NearestPlane != 0)) {
    if (Vdist(NearestVehiclePos.x, NearestVehiclePos.y, NearestVehiclePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) < Vdist(NearestPlanePos.x, NearestPlanePos.y, NearestPlanePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z)) {
      if (IsVehicleSeatFree(NearestVehicle, -1)) {
        SetPedIntoVehicle(playerPed, NearestVehicle, -1)
        SetVehicleAlarm(NearestVehicle, false)
        SetVehicleDoorsLocked(NearestVehicle, 1)
        SetVehicleNeedsToBeHotwired(NearestVehicle, false)
      } else {
        var driverPed = GetPedInVehicleSeat(NearestVehicle, -1)
        ClearPedTasksImmediately(driverPed)
        SetEntityAsMissionEntity(driverPed, 1, 1)
        DeleteEntity(driverPed)
        SetPedIntoVehicle(playerPed, NearestVehicle, -1)
        SetVehicleAlarm(NearestVehicle, false)
        SetVehicleDoorsLocked(NearestVehicle, 1)
        SetVehicleNeedsToBeHotwired(NearestVehicle, false)
      }
    }
  } else if (Vdist(NearestVehiclePos.x, NearestVehiclePos.y, NearestVehiclePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) > Vdist(NearestPlanePos.x, NearestPlanePos.y, NearestPlanePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z)) {
      if (IsVehicleSeatFree(NearestPlane, -1)) {
        SetPedIntoVehicle(playerPed, NearestPlane, -1)
        SetVehicleAlarm(NearestPlane, false)
        SetVehicleDoorsLocked(NearestPlane, 1)
        SetVehicleNeedsToBeHotwired(NearestPlane, false)
      } else {
        var driverPed = GetPedInVehicleSeat(NearestPlane, -1)
        ClearPedTasksImmediately(driverPed)
        SetEntityAsMissionEntity(driverPed, 1, 1)
        DeleteEntity(driverPed)
        SetPedIntoVehicle(playerPed, NearestPlane, -1)
        SetVehicleAlarm(NearestPlane, false)
        SetVehicleDoorsLocked(NearestPlane, 1)
        SetVehicleNeedsToBeHotwired(NearestPlane, false)
      }
    }
    notify("~g~Teleported Into Nearest Vehicle!", false)
  }

  function RandomSkin(target) {
    var ped = GetPlayerPed(target)
    SetPedRandomComponentVariation(ped, false)
    SetPedRandomProps(ped)
  }
  /*
  function custlp() {
    let playerPed = GetPlayerped(-1)
    let playerVeh = GetVehiclePedIsIn(playerPed, true)
    let result = KeyboardInput("Enter the plate license you want", "", 100)
    if (result != "") {
      SetVehicleNumberPlateText(playerVeh, result)
    }
  }


function rapidfire() {
  DisablePlayerFiring(PlayerPedId(), true)
  if (IsDisabledControlPressed(0, 24)) {
    var _, weapon = GetCurrentPedWeapon(PlayerPedId())
    var wepent = GetCurrentPedWeaponEntityIndex(PlayerPedId())
    var camDir = GetCamDirFromScreenCenter()
    var camPos = GetGameplayCamCoord()
    var launchPos = GetEntityCoords(wepent)
    var targetPos = camPos + (camDir * 200.0)

    ClearAreaOfProjectiles(launchPos, 0.0, 1)

    ShootSingleBulletBetweenCoords(launchPos, targetPos, 5, 1, weapon, PlayerPedId(), true, true, 24000.0)
    ShootSingleBulletBetweenCoords(launchPos, targetPos, 5, 1, weapon, PlayerPedId(), true, true, 24000.0)
  }
}*/

//###################\\
// On / Off GLOBALS
//###################\\
var Visibility            = true
var Godmode               = false
var Superjump             = false
var InfinityStamina       = false
var ThermalVision         = false
var NightVision           = false
var FastRun               = false
var Noclip                = false
var sbelt                 = false
var antirag               = false
var demigod               = false
var epunch                = false
var aman                  = false
var trackplayer           = false 
var infammo               = false
var nameabove             = true
var SelectedPlayer        = null
var Spectate              = false
var tinyTim               = false
var bcFlash               = false
var xhair1                = false
var xhair2                = false
var xhair3                = false
var trigBot               = false
var alwaysClean           = false
var vehGod                = false
var waterProof            = false
//var shandle               = false 
//var rfire                 = false
//var explosiveAmmo         = false
var SvMaxPlayers = 128
var PlayerBlips = true
//###################\\
// Settings
//###################\\
var items = [ 'Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5' ]
var currentItemIndex = 1
var selectedItemIndex = 1
var boats = ["Dinghy", "Dinghy2", "Dinghy3", "Dingh4", "Jetmax", "Marquis", "Seashark", "Seashark2", "Seashark3", "Speeder", "Speeder2", "Squalo", "Submersible", "Submersible2", "Suntrap", "Toro", "Toro2", "Tropic", "Tropic2", "Tug"]
var Commercial = ["Benson", "Biff", "Cerberus", "Cerberus2", "Cerberus3", "Hauler", "Hauler2", "Mule", "Mule2", "Mule3", "Mule4", "Packer", "Phantom", "Phantom2", "Phantom3", "Pounder", "Pounder2", "Stockade", "Stockade3", "Terbyte"]
var Compacts = ["Blista", "Blista2", "Blista3", "Brioso", "Dilettante", "Dilettante2", "Issi2", "Issi3", "issi4", "Iss5", "issi6", "Panto", "Prarire", "Rhapsody"]
var Coupes = [ "CogCabrio", "Exemplar", "F620", "Felon", "Felon2", "Jackal", "Oracle", "Oracle2", "Sentinel", "Sentinel2", "Windsor", "Windsor2", "Zion", "Zion2"]
var cycles = [ "Bmx", "Cruiser", "Fixter", "Scorcher", "Tribike", "Tribike2", "tribike3" ]
var Emergency = [ "Ambulance", "FBI", "FBI2", "FireTruk", "PBus", "Police", "Police2", "Police3", "Police4", "PoliceOld1", "PoliceOld2", "PoliceT", "Policeb", "Polmav", "Pranger", "Predator", "Riot", "Riot2", "Sheriff", "Sheriff2"]
var Helicopters = [ "Akula", "Annihilator", "Buzzard", "Buzzard2", "Cargobob", "Cargobob2", "Cargobob3", "Cargobob4", "Frogger", "Frogger2", "Havok", "Hunter", "Maverick", "Savage", "Seasparrow", "Skylift", "Supervolito", "Supervolito2", "Swift", "Swift2", "Valkyrie", "Valkyrie2", "Volatus"]
var Industrial = [ "Bulldozer", "Cutter", "Dump", "Flatbed", "Guardian", "Handler", "Mixer", "Mixer2", "Rubble", "Tiptruck", "Tiptruck2"]
var Military = [ "APC", "Barracks", "Barracks2", "Barracks3", "Barrage", "Chernobog", "Crusader", "Halftrack", "Khanjali", "Rhino", "Scarab", "Scarab2", "Scarab3", "Thruster", "Trailersmall2"]
var Motorcycles = [ "Akuma", "Avarus", "Bagger", "Bati2", "Bati", "BF400", "Blazer4", "CarbonRS", "Chimera", "Cliffhanger", "Daemon", "Daemon2", "Defiler", "Deathbike", "Deathbike2", "Deathbike3", "Diablous", "Diablous2", "Double", "Enduro", "esskey", "Faggio2", "Faggio3", "Faggio", "Fcr2", "fcr", "gargoyle", "hakuchou2", "hakuchou", "hexer", "innovation", "Lectro", "Manchez", "Nemesis", "Nightblade", "Oppressor", "Oppressor2", "PCJ", "Ratbike", "Ruffian", "Sanchez2", "Sanchez", "Sanctus", "Shotaro", "Sovereign", "Thrust", "Vader", "Vindicator", "Vortex", "Wolfsbane", "zombiea", "zombieb"]
var muscle = [ "Blade", "Buccaneer", "Buccaneer2", "Chino", "Chino2", "clique", "Deviant", "Dominator", "Dominator2", "Dominator3", "Dominator4", "Dominator5", "Dominator6", "Dukes", "Dukes2", "Ellie", "Faction", "faction2", "faction3", "Gauntlet", "Gauntlet2", "Hermes", "Hotknife", "Hustler", "Impaler", "Impaler2", "Impaler3", "Impaler4", "Imperator", "Imperator2", "Imperator3", "Lurcher", "Moonbeam", "Moonbeam2", "Nightshade", "Phoenix", "Picador", "RatLoader", "RatLoader2", "Ruiner", "Ruiner2", "Ruiner3", "SabreGT", "SabreGT2", "Sadler2", "Slamvan", "Slamvan2", "Slamvan3", "Slamvan4", "Slamvan5", "Slamvan6", "Stalion", "Stalion2", "Tampa", "Tampa3", "Tulip", "Vamos,", "Vigero", "Virgo", "Virgo2", "Virgo3", "Voodoo", "Voodoo2", "Yosemite"]
var OffRoad = ["BFinjection", "Bifta", "Blazer", "Blazer2", "Blazer3", "Blazer5", "Bohdi", "Brawler", "Bruiser", "Bruiser2", "Bruiser3", "Caracara", "DLoader", "Dune", "Dune2", "Dune3", "Dune4", "Dune5", "Insurgent", "Insurgent2", "Insurgent3", "Kalahari", "Kamacho", "LGuard", "Marshall", "Mesa", "Mesa2", "Mesa3", "Monster", "Monster4", "Monster5", "Nightshark", "RancherXL", "RancherXL2", "Rebel", "Rebel2", "RCBandito", "Riata", "Sandking", "Sandking2", "Technical", "Technical2", "Technical3", "TrophyTruck", "TrophyTruck2", "Freecrawler", "Menacer"]
var Planes = ["AlphaZ1", "Avenger", "Avenger2", "Besra", "Blimp", "blimp2", "Blimp3", "Bombushka", "Cargoplane", "Cuban800", "Dodo", "Duster", "Howard", "Hydra", "Jet", "Lazer", "Luxor", "Luxor2", "Mammatus", "Microlight", "Miljet", "Mogul", "Molotok", "Nimbus", "Nokota", "Pyro", "Rogue", "Seabreeze", "Shamal", "Starling", "Stunt", "Titan", "Tula", "Velum", "Velum2", "Vestra", "Volatol", "Striekforce"]
var SUVs = ["BJXL", "Baller", "Baller2", "Baller3", "Baller4", "Baller5", "Baller6", "Cavalcade", "Cavalcade2", "Dubsta", "Dubsta2", "Dubsta3", "FQ2", "Granger", "Gresley", "Habanero", "Huntley", "Landstalker", "patriot", "Patriot2", "Radi", "Rocoto", "Seminole", "Serrano", "Toros", "XLS", "XLS2"]
var Sedans = ["Asea", "Asea2", "Asterope", "Cog55", "Cogg552", "Cognoscenti", "Cognoscenti2", "emperor", "emperor2", "emperor3", "Fugitive", "Glendale", "ingot", "intruder", "limo2", "premier", "primo", "primo2", "regina", "romero", "stafford", "Stanier", "stratum", "stretch", "surge", "tailgater", "warrener", "Washington"]
var Service = [ "Airbus", "Brickade", "Bus", "Coach", "Rallytruck", "Rentalbus", "Taxi", "Tourbus", "Trash", "Trash2", "WastIndr", "PBus2"]
var Sports = ["Alpha", "Banshee", "Banshee2", "BestiaGTS", "Buffalo", "Buffalo2", "Buffalo3", "Carbonizzare", "Comet2", "Comet3", "Comet4", "Comet5", "Coquette", "Deveste", "Elegy", "Elegy2", "Feltzer2", "Feltzer3", "FlashGT", "Furoregt", "Fusilade", "Futo", "GB200", "Hotring", "Infernus2", "Italigto", "Jester", "Jester2", "Khamelion", "Kurama", "Kurama2", "Lynx", "MAssacro", "MAssacro2", "neon", "Ninef", "ninfe2", "omnis", "Pariah", "Penumbra", "Raiden", "RapidGT", "RapidGT2", "Raptor", "Revolter", "Ruston", "Schafter2", "Schafter3", "Schafter4", "Schafter5", "Schafter6", "Schlagen", "Schwarzer", "Sentinel3", "Seven70", "Specter", "Specter2", "Streiter", "Sultan", "Surano", "Tampa2", "Tropos", "Verlierer2", "ZR380", "ZR3802", "ZR3803"]
var SportsClassic = ["Ardent", "BType", "BType2", "BType3", "Casco", "Cheetah2", "Cheburek", "Coquette2", "Coquette3", "Deluxo", "Fagaloa", "Gt500", "JB700", "JEster3", "MAmba", "Manana", "Michelli", "Monroe", "Peyote", "Pigalle", "RapidGT3", "Retinue", "Savastra", "Stinger", "Stingergt", "Stromberg", "Swinger", "Torero", "Tornado", "Tornado2", "Tornado3", "Tornado4", "Tornado5", "Tornado6", "Viseris", "Z190", "ZType"]
var Super = ["Adder", "Autarch", "Bullet", "Cheetah", "Cyclone", "EntityXF", "Entity2", "FMJ", "GP1", "Infernus", "LE7B", "Nero", "Nero2", "Osiris", "Penetrator", "PFister811", "Prototipo", "Reaper", "SC1", "Scramjet", "Sheava", "SultanRS", "Superd", "T20", "Taipan", "Tempesta", "Tezeract", "Turismo2", "Turismor", "Tyrant", "Tyrus", "Vacca", "Vagner", "Vigilante", "Visione", "Voltic", "Voltic2", "Zentorno", "Italigtb", "Italigtb2", "XA21"]
var Trailer = [ "ArmyTanker", "ArmyTrailer", "ArmyTrailer2", "BaleTrailer", "BoatTrailer", "CableCar", "DockTrailer", "Graintrailer", "Proptrailer", "Raketailer", "TR2", "TR3", "TR4", "TRFlat", "TVTrailer", "Tanker", "Tanker2", "Trailerlogs", "Trailersmall", "Trailers", "Trailers2", "Trailers3"]
var trains = ["Freight", "Freightcar", "Freightcont1", "Freightcont2", "Freightgrain", "Freighttrailer", "TankerCar"]
var Utility = ["Airtug", "Caddy", "Caddy2", "Caddy3", "Docktug", "Forklift", "Mower", "Ripley", "Sadler", "Scrap", "TowTruck", "Towtruck2", "Tractor", "Tractor2", "Tractor3", "TrailerLArge2", "Utilitruck", "Utilitruck3", "Utilitruck2"]
var Vans = ["Bison", "Bison2", "Bison3", "BobcatXL", "Boxville", "Boxville2", "Boxville3", "Boxville4", "Boxville5", "Burrito", "Burrito2", "Burrito3", "Burrito4", "Burrito5", "Camper", "GBurrito", "GBurrito2", "Journey", "Minivan", "Minivan2", "Paradise", "pony", "Pony2", "Rumpo", "Rumpo2", "Rumpo3", "Speedo", "Speedo2", "Speedo4", "Surfer", "Surfer2", "Taco", "Youga", "youga2"]
var CarTypes = ["Boats", "Commercial", "Compacts", "Coupes", "Cycles", "Emergency", "Helictopers", "Industrial", "Military", "Motorcycles", "Muscle", "Off-Road", "Planes", "SUVs", "Sedans", "Service", "Sports", "Sports Classic", "Super", "Trailer", "Trains", "Utility", "Vans"]
var Trailers = [ "ArmyTanker", "ArmyTrailer", "ArmyTrailer2", "BaleTrailer", "BoatTrailer", "CableCar", "DockTrailer", "Graintrailer", "Proptrailer", "Raketailer", "TR2", "TR3", "TR4", "TRFlat", "TVTrailer", "Tanker", "Tanker2", "Trailerlogs", "Trailersmall", "Trailers", "Trailers2", "Trailers3"]
var allWeapons = ["WEAPON_KNIFE","WEAPON_KNUCKLE","WEAPON_NIGHTSTICK","WEAPON_HAMMER","WEAPON_BAT","WEAPON_GOLFCLUB","WEAPON_CROWBAR","WEAPON_BOTTLE","WEAPON_DAGGER","WEAPON_HATCHET","WEAPON_MACHETE","WEAPON_FLASHLIGHT","WEAPON_SWITCHBLADE","WEAPON_PISTOL","WEAPON_PISTOL_MK2","WEAPON_COMBATPISTOL","WEAPON_APPISTOL","WEAPON_PISTOL50","WEAPON_SNSPISTOL","WEAPON_HEAVYPISTOL","WEAPON_VINTAGEPISTOL","WEAPON_STUNGUN","WEAPON_FLAREGUN","WEAPON_MARKSMANPISTOL","WEAPON_REVOLVER","WEAPON_MICROSMG","WEAPON_SMG","WEAPON_SMG_MK2","WEAPON_ASSAULTSMG","WEAPON_MG","WEAPON_COMBATMG","WEAPON_COMBATMG_MK2","WEAPON_COMBATPDW","WEAPON_GUSENBERG","WEAPON_MACHINEPISTOL","WEAPON_ASSAULTRIFLE","WEAPON_ASSAULTRIFLE_MK2","WEAPON_CARBINERIFLE","WEAPON_CARBINERIFLE_MK2","WEAPON_ADVANCEDRIFLE","WEAPON_SPECIALCARBINE","WEAPON_BULLPUPRIFLE","WEAPON_COMPACTRIFLE","WEAPON_PUMPSHOTGUN","WEAPON_SAWNOFFSHOTGUN","WEAPON_BULLPUPSHOTGUN","WEAPON_ASSAULTSHOTGUN","WEAPON_MUSKET","WEAPON_HEAVYSHOTGUN","WEAPON_DBSHOTGUN","WEAPON_SNIPERRIFLE","WEAPON_HEAVYSNIPER","WEAPON_HEAVYSNIPER_MK2","WEAPON_MARKSMANRIFLE","WEAPON_GRENADELAUNCHER","WEAPON_GRENADELAUNCHER_SMOKE","WEAPON_RPG","WEAPON_STINGER","WEAPON_FIREWORK","WEAPON_HOMINGLAUNCHER","WEAPON_GRENADE","WEAPON_STICKYBOMB","WEAPON_PROXMINE","WEAPON_BZGAS","WEAPON_SMOKEGRENADE","WEAPON_MOLOTOV","WEAPON_FIREEXTINGUISHER","WEAPON_PETROLCAN","WEAPON_SNOWBALL","WEAPON_FLARE","WEAPON_BALL"]
//###################\\
// Menu Definitions
//###################\\
ForceMenu.CreateMenu('revolution', 'Revolution Menu', 'Main Menu')
ForceMenu.CreateSubMenu('closeMenu', 'revolution', 'Are you sure?')
ForceMenu.CreateSubMenu('selfMenu', 'revolution', 'Self Options') // Self Menu
ForceMenu.CreateSubMenu('vMenu', 'revolution', 'Vehicle Options') //vehicle menu
ForceMenu.CreateSubMenu('wMenu', 'revolution', 'Weapon Options') //weapon menu
ForceMenu.CreateSubMenu('xMenu', 'wMenu', 'Crosshair Options') //xhair menu
ForceMenu.CreateSubMenu('GSWP', 'wMenu', 'Give Single Weapon') 
ForceMenu.CreateSubMenu('tpMenu', 'revolution', 'Teleport Options')  //Teleport Options
ForceMenu.CreateSubMenu('onlinePlayers', 'revolution', 'Online Menu') //Online options
ForceMenu.CreateSubMenu('advMenu', 'revolution', 'Advanced Options') //Advanced Menu
ForceMenu.CreateSubMenu('lMenu', 'revolution', 'Lua Options') // Lua Menu
ForceMenu.CreateSubMenu('ESXMoney', 'lMenu', 'ESX Money Options') // Lua Menu
ForceMenu.CreateSubMenu('ESXDrutems', 'lMenu', 'ESX Drug/Items  Options') // Lua Menu
ForceMenu.CreateSubMenu('ESXMisc', 'lMenu', 'ESX Misc  Options') // Lua Menu
ForceMenu.CreateSubMenu('VRPMenu', 'lMenu', 'VRP Options') // VRP Options
ForceMenu.CreateSubMenu('VRPMisc', 'VRPMenu', 'VRP Misc Options') // VRP Options
ForceMenu.CreateSubMenu('allPlayers', 'revolution', 'All Player Options') // All Players
ForceMenu.CreateSubMenu('playerSelected', 'revolution', 'Selected Player Options') // Selected Option
ForceMenu.CreateSubMenu('trollMenu', 'revolution', 'Troll Options') // Troll Options
ForceMenu.CreateSubMenu('aprMenu', 'selfMenu', 'Appearance Options') // Appearance

//###################\\
// Menu Thread
//###################\\
setTick(async () => {

  // Ordinary
  var player          = PlayerPedId()
  var lastcoords      = null
  //////////////////////////

  // Menu Drawing
  if(ForceMenu.IsMenuOpened('revolution')) {
    if(ForceMenu.MenuButton('~h~~s~Self Menu~p~                                                ~p~»', 'selfMenu')) {
    } else if(ForceMenu.MenuButton('~h~Online ~s~Players                                         ~p~»', 'onlinePlayers')) {     
    } else if(ForceMenu.MenuButton('~h~Teleport ~s~Menu                                         ~p~»', 'tpMenu')) {    
    } else if(ForceMenu.MenuButton('~h~Vehicle ~s~Menu                                           ~p~»', 'vMenu')) {   
    } else if(ForceMenu.MenuButton('~h~Weapon ~s~Menu                                         ~p~»', 'wMenu')) {
    } else if(ForceMenu.MenuButton('~h~Lua ~s~Menu                                                ~p~»', 'lMenu')) {
    } else if(ForceMenu.MenuButton('~h~Advanced ~s~Mode                                      ~p~»', 'advMenu')) {
    } else if(ForceMenu.MenuButton('~r~~h~End Menu', 'closeMenu')) {
    }

  }

  // Self Options
  else if (ForceMenu.IsMenuOpened('selfMenu')) {
    if(ForceMenu.Button('~p~->~s~ Appearance Menu')) {
      ForceMenu.OpenMenu('aprMenu')
    }
    if(ForceMenu.CheckBox('God Mode', Godmode, false)) {
      Godmode = !Godmode
      console.log("God Mode "+Godmode);
    }
    if(ForceMenu.CheckBox('Demigod', demigod, false)) {
      demigod = !demigod
      console.log("Demigod "+demigod);
    }
    if(ForceMenu.CheckBox('Visibility', Visibility)) {
      Visibility = !Visibility
      console.log("Visibility "+Visibility);
    }
    if(ForceMenu.Button('Suicide')) {
      SetEntityHealth(PlayerPedId(-1), 0)
    }
    if(ForceMenu.Button('Revive Yourself')) {
      lastcoords = GetEntityCoords(player)
      SetEntityCoordsNoOffset(player, lastcoords[0], lastcoords[1], lastcoords[2], false, false, false, true)
    	NetworkResurrectLocalPlayer(lastcoords[0], lastcoords[1], lastcoords[2], 0, true, false)
    	SetPlayerInvincible(player, false)
      ClearPedBloodDamage(player)
      emitNet("esx_ambulancejob:revive")
    }
    if(ForceMenu.Button('Heal')) {
      SetEntityHealth(PlayerPedId(), 200);
      emitNet('mythic_hospital:client:RemoveBleed')
      emitNet('mythic_hospital:client:ResetLimbs')
      emitNet('mythic_hospital:client:RemoveBleed')
      emitNet('mythic_hospital:client:ResetLimbs')
    }
    if(ForceMenu.Button('Give Armor')) {
      SetPedArmour(PlayerPedId(-1), 100)
    }
    if(ForceMenu.CheckBox('Infinity Stamina', InfinityStamina, false)) {
      InfinityStamina = !InfinityStamina
      console.log("Infinity Stamina "+InfinityStamina);
    }
    if(ForceMenu.CheckBox('Anti Ragdoll', antirag, false)) {
      antirag = !antirag
      console.log("Anti Ragdoll "+antirag);
    }
    if(ForceMenu.CheckBox('Thermal Vision', ThermalVision, false)) {
      ThermalVision = !ThermalVision
      console.log("Thermal Vision "+ThermalVision);
    }
    if(ForceMenu.CheckBox('Night Vision', NightVision, false)) {
      NightVision = !NightVision
      console.log("Night Vision "+NightVision);
    }
    if(ForceMenu.CheckBox('Aquaman', aman, false)) {
      aman = !aman
      console.log("Explosive Punch "+aman);
    }
    if(ForceMenu.CheckBox('Explosive Punch', epunch, false)) {
      epunch = !epunch
      console.log("Explosive Punch "+epunch);
    }
    if(ForceMenu.CheckBox('Fast Run', FastRun, false)) {
      FastRun = !FastRun
      console.log("Fast Run "+FastRun);
    }
    if(ForceMenu.CheckBox('Super Jump', Superjump, false)) {
      Superjump = !Superjump
      console.log("Super Jump "+Superjump);
    }
    if(ForceMenu.CheckBox('Become Tiny', tinyTim, false)) {
      tinyTim = !tinyTim
      console.log("Become Tiny "+tinyTim);
    }
    if(ForceMenu.CheckBox('Become Flash', bcFlash, false)) {
      bcFlash = !bcFlash
      console.log("Become Flash "+bcFlash);
    }
    if(ForceMenu.CheckBox('Noclip', Noclip, false)) {
      Noclip = !Noclip
      console.log("Noclip "+Noclip);
    }
  }

  //Appearance Menu
  else if (ForceMenu.IsMenuOpened('aprMenu')) {
    if(ForceMenu.Button('~y~Random Skin')) {
      RandomSkin(PlayerId(-1))
    }
    if(ForceMenu.Button('~o~Random Clothes')) {
      SetPedRandomComponentVariation(PlayerPedId(), true)
    }
    if(ForceMenu.Button('~g~Reset to FiveM Player')) {
      let model = "mp_m_freemode_01"
      RequestModel(GetHashKey(model))
      if( HasModelLoaded(GetHashKey(model))) {
        SetPlayerModel(PlayerId(), GetHashKey(model))
      }
    }
    if(ForceMenu.Button('🤡 Clown Model')) {
      let model = "s_m_y_clown_01"
      RequestModel(GetHashKey(model))
      if( HasModelLoaded(GetHashKey(model))) {
        SetPlayerModel(PlayerId(), GetHashKey(model))
      }
    }
    if(ForceMenu.Button('🔒 Prisoner Model')) {
      let model = "S_M_Y_PrisMuscl_01"
      RequestModel(GetHashKey(model))
      if( HasModelLoaded(GetHashKey(model))) {
        SetPlayerModel(PlayerId(), GetHashKey(model))
      }
    }
    if(ForceMenu.Button('👮 Cop Model')) {
      let model = "s_m_y_cop_01"
      RequestModel(GetHashKey(model))
      if( HasModelLoaded(GetHashKey(model))) {
        SetPlayerModel(PlayerId(), GetHashKey(model))
      }
    }
    if(ForceMenu.Button('👮‍♀️ Cop Model')) {
      let model = "MP_F_Cop_01"
      RequestModel(GetHashKey(model))
      if( HasModelLoaded(GetHashKey(model))) {
        SetPlayerModel(PlayerId(), GetHashKey(model))
      }
    }
  }

  else if (ForceMenu.IsMenuOpened('onlinePlayers')) {
    if(ForceMenu.Button('~p~->~s~ All Players')) {
        ForceMenu.OpenMenu('allPlayers')
    } else {
      var playerlist = GetActivePlayers()
      for (var i = 0; i < playerlist.length; i++) {
        var currPlayer = playerlist[i]
        var status = "ALIVE"
        if(IsPedDeadOrDying(GetPlayerPed(currPlayer))) {
          status = "DEAD"
        }
        if(ForceMenu.Button('[' + GetPlayerServerId(currPlayer)+"] " + GetPlayerName(currPlayer) + " "+ status)) {
          SelectedPlayer = currPlayer
          ForceMenu.OpenMenu('playerSelected')
        }
      }
    }
  }

  // Selected Player
  else if (ForceMenu.IsMenuOpened('playerSelected')) {
    if(SelectedPlayer !== null) {
      if(ForceMenu.Button('~p~->~s~ Troll Menu')) {
        ForceMenu.OpenMenu('trollMenu')
      }
      if(ForceMenu.Button('Revive / Heal')) {
        var medkitname = "PICKUP_HEALTH_STANDARD"
        var medkit = GetHashKey(medkitname)
        var coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
        var pickup = CreateAmbientPickup(medkit, coords[0], coords[1], coords[2] + 1.0, 1, 1, medkit, 1, 0)
        SetPickupRegenerationTime(pickup, 60)
        emitNet("esx_ambulancejob:revive", SelectedPlayer)
      }
      if(ForceMenu.Button('Give Armour')) {
        var ped = GetPlayerPed(SelectedPlayer)
        SetPedArmour(ped, 100)
      }
      if(ForceMenu.CheckBox('Spectate', Spectate, false)) {
        Spectate = !Spectate
        console.log("Spectate "+Spectate);

        var playerPed = PlayerPedId(-1)
        var targetPed = GetPlayerPed(player)

        if (Spectate){
          var targetcoords = GetEntityCoords(targetPed, false)

          RequestCollisionAtCoord(targetcoords[0], targetcoords[1], targetcoords[2])
          NetworkSetInSpectatorMode(true, targetPed)
        }
        else {
          var targetcoords = GetEntityCoords(targetPed, false)

          RequestCollisionAtCoord(targetcoords[0], targetcoords[1], targetcoords[2])
          NetworkSetInSpectatorMode(false, targetPed)
        }
      }
      if(ForceMenu.CheckBox('Track Player', trackplayer, false)) {
        trackplayer = !trackplayer
        var TrackedPlayer = SelectedPlayer
        console.log("Track Player "+trackplayer);
      }

      if(ForceMenu.Button('Teleport to')) {
        var entity = IsPedInAnyVehicle(PlayerPedId(-1), false) && GetVehiclePedIsUsing(PlayerPedId(-1)) || PlayerPedId(-1)
        var targetcoords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
        SetEntityCoords(entity, targetcoords[0], targetcoords[1], targetcoords[2], 0.0, 0.0, 0.0, false)
      }
      if(ForceMenu.Button('Freeze Player')) {
        emitNet("OG_cuffs:cuffCheckNearest", SelectedPlayer)
        emitNet("CheckHandcuff", SelectedPlayer)
        emitNet("cuffServer", SelectedPlayer)
        emitNet("cuffGranted", SelectedPlayer)
        emitNet("police:cuffGranted", SelectedPlayer)
        emitNet("esx_handcuffs:cuffing", SelectedPlayer)
        emitNet("esx_policejob:handcuff", SelectedPlayer)
      }
      if(ForceMenu.Button('Give All Weapons')) {
        var ped = GetPlayerPed(SelectedPlayer)
        for (var i = 0; i < allWeapons.length; i++) {
          GiveWeaponToPed(ped, GetHashKey(allWeapons[i]), 9999, false, false)
        }
      }
      if(ForceMenu.Button('Remove All Weapons')) {
        RemoveAllPedWeapons(SelectedPlayer, true)
      }
      if(ForceMenu.Button('Give Vehicle')) {
        var ped = GetPlayerPed(SelectedPlayer)
        var pedcoords = GetEntityCoords(ped)
        var ModelName = KeyboardInput("Enter Vehicle Spawn Name", "", 100)
        if (await ModelName && IsModelValid(await ModelName) && IsModelAVehicle(await ModelName)){
           RequestModel(await ModelName)
           while (!HasModelLoaded(await ModelName)){
             await Delay(5)
           }
           var veh = CreateVehicle(GetHashKey(await ModelName), pedcoords[0] , pedcoords[1], pedcoords[2], GetEntityHeading(ped)+90, true, true)
        }
      }
      if(ForceMenu.Button('Send to Jail')) {
        var ReasonOfJail = KeyboardInput("Reason", "", 100)
        emitNet("esx-qalle-jail:jailPlayer", SelectedPlayer, 5000, await ReasonOfJail)
        emitNet("esx_jailer:sendToJail", SelectedPlayer, 45 * 60)
        emitNet("esx_jail:sendToJail", SelectedPlayer, 45 * 60)
        emitNet("js:jailuser", SelectedPlayer, 45 * 60, ReasonOfJail)
      }
      if(ForceMenu.Button('Evade from Jail')) {
        var entity = IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), false) && GetVehiclePedIsUsing(GetPlayerPed(SelectedPlayer)) || GetPlayerPed(SelectedPlayer)
        SetEntityCoords(entity, 500, 500, 175, 0.0, 0.0, 0.0, false)
      }
    }
  }

  // All Players
  else if (ForceMenu.IsMenuOpened('allPlayers')) {
    if(ForceMenu.Button('Chicken Army')) {
        for (var i = 0; i < 256; i++) {

          var pedname = "a_c_hen"
          var wep = "WEAPON_PISTOL"
          for (var i = 0; i < 10; i++) {
            var coords = GetEntityCoords(GetPlayerPed(i))
            RequestModel(GetHashKey(pedname))
            await Delay(50)
            if(HasModelLoaded(GetHashKey(pedname))) {
              var ped = CreatePed(21, GetHashKey(pedname),coords[0] + i, coords[1] - i, coords[2], 0, true, true) && CreatePed(21, GetHashKey(pedname),coords[0] - i, coords[1] + i, coords[2], 0, true, true)
              NetworkRegisterEntityAsNetworked(ped)
              if(DoesEntityExist(ped) && !IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                var netped = PedToNet(ped)
                NetworkSetNetworkIdDynamic(netped, false)
                SetNetworkIdCanMigrate(netped, true)
                SetNetworkIdExistsOnAllMachines(netped, true)
                await Delay(500)
                NetToPed(netped)
                GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                SetEntityInvincible(ped, true)
                SetPedCanSwitchWeapon(ped, true)
                TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
              } else if(IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
              } else {
                await Delay(0)
              }
            }
          }

        }
    }

    if(ForceMenu.Button('Chimp Army')) {
        for (var i = 0; i < 256; i++) {

          var pedname = "a_c_chimp"
          var wep = "weapon_hammer"
          for (var i = 0; i < 10; i++) {
            var coords = GetEntityCoords(GetPlayerPed(i))
            RequestModel(GetHashKey(pedname))
            await Delay(50)
            if(HasModelLoaded(GetHashKey(pedname))) {
              var ped = CreatePed(21, GetHashKey(pedname),coords[0] + i, coords[1] - i, coords[2], 0, true, true) && CreatePed(21, GetHashKey(pedname),coords[0] - i, coords[1] + i, coords[2], 0, true, true)
              NetworkRegisterEntityAsNetworked(ped)
              if(DoesEntityExist(ped) && !IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                var netped = PedToNet(ped)
                NetworkSetNetworkIdDynamic(netped, false)
                SetNetworkIdCanMigrate(netped, true)
                SetNetworkIdExistsOnAllMachines(netped, true)
                await Delay(500)
                NetToPed(netped)
                GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                SetEntityInvincible(ped, true)
                SetPedCanSwitchWeapon(ped, true)
                TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
              } else if(IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
              } else {
                await Delay(0)
              }
            }
          }

        }
    }

    if(ForceMenu.Button('Lion Army')) {
        for (var i = 0; i < 256; i++) {

          var pedname = "a_c_mtlion"
          var wep = ""
          for (var i = 0; i < 10; i++) {
            var coords = GetEntityCoords(GetPlayerPed(i))
            RequestModel(GetHashKey(pedname))
            await Delay(50)
            if(HasModelLoaded(GetHashKey(pedname))) {
              var ped = CreatePed(21, GetHashKey(pedname),coords[0] + i, coords[1] - i, coords[2], 0, true, true) && CreatePed(21, GetHashKey(pedname),coords[0] - i, coords[1] + i, coords[2], 0, true, true)
              NetworkRegisterEntityAsNetworked(ped)
              if(DoesEntityExist(ped) && !IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                var netped = PedToNet(ped)
                NetworkSetNetworkIdDynamic(netped, false)
                SetNetworkIdCanMigrate(netped, true)
                SetNetworkIdExistsOnAllMachines(netped, true)
                await Delay(500)
                NetToPed(netped)
                GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                SetEntityInvincible(ped, true)
                SetPedCanSwitchWeapon(ped, true)
                TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
              } else if(IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
              } else {
                await Delay(0)
              }
            }
          }

        }
    }

    if(ForceMenu.Button('Seagull Army')) {
        for (var i = 0; i < 256; i++) {

          var pedname = "a_c_seagull"
          var wep = ""
          for (var i = 0; i < 10; i++) {
            var coords = GetEntityCoords(GetPlayerPed(i))
            RequestModel(GetHashKey(pedname))
            await Delay(50)
            if(HasModelLoaded(GetHashKey(pedname))) {
              var ped = CreatePed(21, GetHashKey(pedname),coords[0] + i, coords[1] - i, coords[2], 0, true, true) && CreatePed(21, GetHashKey(pedname),coords[0] - i, coords[1] + i, coords[2], 0, true, true)
              NetworkRegisterEntityAsNetworked(ped)
              if(DoesEntityExist(ped) && !IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                var netped = PedToNet(ped)
                NetworkSetNetworkIdDynamic(netped, false)
                SetNetworkIdCanMigrate(netped, true)
                SetNetworkIdExistsOnAllMachines(netped, true)
                await Delay(500)
                NetToPed(netped)
                GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                SetEntityInvincible(ped, true)
                SetPedCanSwitchWeapon(ped, true)
                TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
              } else if(IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
              } else {
                await Delay(0)
              }
            }
          }

        }
    }

    if(ForceMenu.Button('Pig Army')) {
        for (var i = 0; i < 256; i++) {

          var pedname = "a_c_pig"
          var wep = ""
          for (var i = 0; i < 10; i++) {
            var coords = GetEntityCoords(GetPlayerPed(i))
            RequestModel(GetHashKey(pedname))
            await Delay(50)
            if(HasModelLoaded(GetHashKey(pedname))) {
              var ped = CreatePed(21, GetHashKey(pedname),coords[0] + i, coords[1] - i, coords[2], 0, true, true) && CreatePed(21, GetHashKey(pedname),coords[0] - i, coords[1] + i, coords[2], 0, true, true)
              NetworkRegisterEntityAsNetworked(ped)
              if(DoesEntityExist(ped) && !IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                var netped = PedToNet(ped)
                NetworkSetNetworkIdDynamic(netped, false)
                SetNetworkIdCanMigrate(netped, true)
                SetNetworkIdExistsOnAllMachines(netped, true)
                await Delay(500)
                NetToPed(netped)
                GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                SetEntityInvincible(ped, true)
                SetPedCanSwitchWeapon(ped, true)
                TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
              } else if(IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
              } else {
                await Delay(0)
              }
            }
          }

        }
    }

    if(ForceMenu.Button('Rat Army')) {
        for (var i = 0; i < 256; i++) {

          var pedname = "a_c_rat"
          var wep = ""
          for (var i = 0; i < 10; i++) {
            var coords = GetEntityCoords(GetPlayerPed(i))
            RequestModel(GetHashKey(pedname))
            await Delay(50)
            if(HasModelLoaded(GetHashKey(pedname))) {
              var ped = CreatePed(21, GetHashKey(pedname),coords[0] + i, coords[1] - i, coords[2], 0, true, true) && CreatePed(21, GetHashKey(pedname),coords[0] - i, coords[1] + i, coords[2], 0, true, true)
              NetworkRegisterEntityAsNetworked(ped)
              if(DoesEntityExist(ped) && !IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                var netped = PedToNet(ped)
                NetworkSetNetworkIdDynamic(netped, false)
                SetNetworkIdCanMigrate(netped, true)
                SetNetworkIdExistsOnAllMachines(netped, true)
                await Delay(500)
                NetToPed(netped)
                GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                SetEntityInvincible(ped, true)
                SetPedCanSwitchWeapon(ped, true)
                TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
              } else if(IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
              } else {
                await Delay(0)
              }
            }
          }

        }
    }

    if(ForceMenu.Button('Stingray Army')) {
        for (var i = 0; i < 256; i++) {

          var pedname = "a_c_stingray"
          var wep = ""
          for (var i = 0; i < 10; i++) {
            var coords = GetEntityCoords(GetPlayerPed(i))
            RequestModel(GetHashKey(pedname))
            await Delay(50)
            if(HasModelLoaded(GetHashKey(pedname))) {
              var ped = CreatePed(21, GetHashKey(pedname),coords[0] + i, coords[1] - i, coords[2], 0, true, true) && CreatePed(21, GetHashKey(pedname),coords[0] - i, coords[1] + i, coords[2], 0, true, true)
              NetworkRegisterEntityAsNetworked(ped)
              if(DoesEntityExist(ped) && !IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                var netped = PedToNet(ped)
                NetworkSetNetworkIdDynamic(netped, false)
                SetNetworkIdCanMigrate(netped, true)
                SetNetworkIdExistsOnAllMachines(netped, true)
                await Delay(500)
                NetToPed(netped)
                GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                SetEntityInvincible(ped, true)
                SetPedCanSwitchWeapon(ped, true)
                TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
              } else if(IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
              } else {
                await Delay(0)
              }
            }
          }

        }
    }

    if(ForceMenu.Button('Zombie Army')) {
        for (var i = 0; i < 256; i++) {

          var pedname = "u_m_y_zombie_01"
          var wep = ""
          for (var i = 0; i < 10; i++) {
            var coords = GetEntityCoords(GetPlayerPed(i))
            RequestModel(GetHashKey(pedname))
            await Delay(50)
            if(HasModelLoaded(GetHashKey(pedname))) {
              var ped = CreatePed(21, GetHashKey(pedname),coords[0] + i, coords[1] - i, coords[2], 0, true, true) && CreatePed(21, GetHashKey(pedname),coords[0] - i, coords[1] + i, coords[2], 0, true, true)
              NetworkRegisterEntityAsNetworked(ped)
              if(DoesEntityExist(ped) && !IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                var netped = PedToNet(ped)
                NetworkSetNetworkIdDynamic(netped, false)
                SetNetworkIdCanMigrate(netped, true)
                SetNetworkIdExistsOnAllMachines(netped, true)
                await Delay(500)
                NetToPed(netped)
                GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                SetEntityInvincible(ped, true)
                SetPedCanSwitchWeapon(ped, true)
                TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
              } else if(IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
              } else {
                await Delay(0)
              }
            }
          }

        }
    }


    if(ForceMenu.Button('Zoo Attack')) {
        for (var i = 0; i < 256; i++) {

          var pedname = "a_c_stingray"
          var wep = ""
          for (var i = 0; i < 10; i++) {
            var coords = GetEntityCoords(GetPlayerPed(i))
            RequestModel(GetHashKey(pedname))
            await Delay(50)
            if(HasModelLoaded(GetHashKey(pedname))) {
              var ped = CreatePed(21, GetHashKey(pedname),coords[0] + i, coords[1] - i, coords[2], 0, true, true) && CreatePed(21, GetHashKey(pedname),coords[0] - i, coords[1] + i, coords[2], 0, true, true)
              NetworkRegisterEntityAsNetworked(ped)
              if(DoesEntityExist(ped) && !IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                var netped = PedToNet(ped)
                NetworkSetNetworkIdDynamic(netped, false)
                SetNetworkIdCanMigrate(netped, true)
                SetNetworkIdExistsOnAllMachines(netped, true)
                await Delay(500)
                NetToPed(netped)
                GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                SetEntityInvincible(ped, true)
                SetPedCanSwitchWeapon(ped, true)
                TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
              } else if(IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
              } else {
                await Delay(0)
              }
            }
          }

          var pedname = "a_c_pig"
          var wep = ""
          for (var i = 0; i < 10; i++) {
            var coords = GetEntityCoords(GetPlayerPed(i))
            RequestModel(GetHashKey(pedname))
            await Delay(50)
            if(HasModelLoaded(GetHashKey(pedname))) {
              var ped = CreatePed(21, GetHashKey(pedname),coords[0] + i, coords[1] - i, coords[2], 0, true, true) && CreatePed(21, GetHashKey(pedname),coords[0] - i, coords[1] + i, coords[2], 0, true, true)
              NetworkRegisterEntityAsNetworked(ped)
              if(DoesEntityExist(ped) && !IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                var netped = PedToNet(ped)
                NetworkSetNetworkIdDynamic(netped, false)
                SetNetworkIdCanMigrate(netped, true)
                SetNetworkIdExistsOnAllMachines(netped, true)
                await Delay(500)
                NetToPed(netped)
                GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                SetEntityInvincible(ped, true)
                SetPedCanSwitchWeapon(ped, true)
                TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
              } else if(IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
              } else {
                await Delay(0)
              }
            }
          }

          var pedname = "a_c_rabbit_01"
          var wep = ""
          for (var i = 0; i < 10; i++) {
            var coords = GetEntityCoords(GetPlayerPed(i))
            RequestModel(GetHashKey(pedname))
            await Delay(50)
            if(HasModelLoaded(GetHashKey(pedname))) {
              var ped = CreatePed(21, GetHashKey(pedname),coords[0] + i, coords[1] - i, coords[2], 0, true, true) && CreatePed(21, GetHashKey(pedname),coords[0] - i, coords[1] + i, coords[2], 0, true, true)
              NetworkRegisterEntityAsNetworked(ped)
              if(DoesEntityExist(ped) && !IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                var netped = PedToNet(ped)
                NetworkSetNetworkIdDynamic(netped, false)
                SetNetworkIdCanMigrate(netped, true)
                SetNetworkIdExistsOnAllMachines(netped, true)
                await Delay(500)
                NetToPed(netped)
                GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                SetEntityInvincible(ped, true)
                SetPedCanSwitchWeapon(ped, true)
                TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
              } else if(IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
              } else {
                await Delay(0)
              }
            }
          }

          var pedname = "a_c_retriever"
          var wep = ""
          for (var i = 0; i < 10; i++) {
            var coords = GetEntityCoords(GetPlayerPed(i))
            RequestModel(GetHashKey(pedname))
            await Delay(50)
            if(HasModelLoaded(GetHashKey(pedname))) {
              var ped = CreatePed(21, GetHashKey(pedname),coords[0] + i, coords[1] - i, coords[2], 0, true, true) && CreatePed(21, GetHashKey(pedname),coords[0] - i, coords[1] + i, coords[2], 0, true, true)
              NetworkRegisterEntityAsNetworked(ped)
              if(DoesEntityExist(ped) && !IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                var netped = PedToNet(ped)
                NetworkSetNetworkIdDynamic(netped, false)
                SetNetworkIdCanMigrate(netped, true)
                SetNetworkIdExistsOnAllMachines(netped, true)
                await Delay(500)
                NetToPed(netped)
                GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                SetEntityInvincible(ped, true)
                SetPedCanSwitchWeapon(ped, true)
                TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
              } else if(IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
              } else {
                await Delay(0)
              }
            }
          }

          var pedname = "a_c_deer"
          var wep = ""
          for (var i = 0; i < 10; i++) {
            var coords = GetEntityCoords(GetPlayerPed(i))
            RequestModel(GetHashKey(pedname))
            await Delay(50)
            if(HasModelLoaded(GetHashKey(pedname))) {
              var ped = CreatePed(21, GetHashKey(pedname),coords[0] + i, coords[1] - i, coords[2], 0, true, true) && CreatePed(21, GetHashKey(pedname),coords[0] - i, coords[1] + i, coords[2], 0, true, true)
              NetworkRegisterEntityAsNetworked(ped)
              if(DoesEntityExist(ped) && !IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                var netped = PedToNet(ped)
                NetworkSetNetworkIdDynamic(netped, false)
                SetNetworkIdCanMigrate(netped, true)
                SetNetworkIdExistsOnAllMachines(netped, true)
                await Delay(500)
                NetToPed(netped)
                GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                SetEntityInvincible(ped, true)
                SetPedCanSwitchWeapon(ped, true)
                TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
              } else if(IsEntityDead(GetPlayerPed(SelectedPlayer))) {
                TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
              } else {
                await Delay(0)
              }
            }
          }

        }
    }
  }

  // Troll Menu
  else if (ForceMenu.IsMenuOpened('trollMenu')) {
    if(ForceMenu.Button('Silent Kill Player')) {
      var coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
      AddExplosion(coords.x, coords.y, coords.z, 4, 0.1, 0, 1, 0.0)
    }
    if(ForceMenu.Button('Kick From Vehicle')) {
      ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))
    }
    if(ForceMenu.Button('Explode Vehicle')) {
      if (IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), true)) {
        AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 4, 1337.0, false, true, 0.0)
      } else {
        notify("~b~Player not in a vehicle~s~.", false)
      }
    }
    if(ForceMenu.Button('Fake Chat Message')) {
      var message = KeyboardInput("Enter message to send", "", 100)
      var dude = GetPlayerName(SelectedPlayer)
      if (await message){
        emitNet("_chat:messageEntered", dude, "ComposerDevil", await message)
      }
    }
    if(ForceMenu.Button('Kick From Vehicle')) {
      ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))
    }
    if(ForceMenu.Button('Explode Vehicle')) {
      if (IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), true)){
        var coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
        AddExplosion(coords[0], coords[1], coords[2], 4, 1337.0, false, true, 0.0)
      }
    }
    if(ForceMenu.Button('Spawn Swat AK')) {
      var pedname = "s_m_y_swat_01"
      var wep = "WEAPON_ASSAULTRIFLE"
      for (var i = 0; i < 10; i++) {
        var coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
        RequestModel(GetHashKey(pedname))
        await Delay(50)
        if(HasModelLoaded(GetHashKey(pedname))) {
          var ped = CreatePed(21, GetHashKey(pedname),coords[0] + i, coords[1] - i, coords[2], 0, true, true) && CreatePed(21, GetHashKey(pedname),coords[0] - i, coords[1] + i, coords[2], 0, true, true)
          NetworkRegisterEntityAsNetworked(ped)
          if(DoesEntityExist(ped) && !IsEntityDead(GetPlayerPed(SelectedPlayer))) {
            var netped = PedToNet(ped)
            NetworkSetNetworkIdDynamic(netped, false)
            SetNetworkIdCanMigrate(netped, true)
            SetNetworkIdExistsOnAllMachines(netped, true)
            await Delay(500)
            NetToPed(netped)
            GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
            SetEntityInvincible(ped, true)
            SetPedCanSwitchWeapon(ped, true)
            TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
          } else if(IsEntityDead(GetPlayerPed(SelectedPlayer))) {
            TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
          } else {
            await Delay(0)
          }
        }
      }
    }
    if(ForceMenu.Button('Crash Player ( Whale Attack )')) {
      var pedname = "a_c_humpback"
      var wep = "weapon_rpg"
      for (var i = 0; i < 10; i++) {
        var coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
        RequestModel(GetHashKey(pedname))
        await Delay(50)
        if(HasModelLoaded(GetHashKey(pedname))) {
          var ped = CreatePed(21, GetHashKey(pedname),coords[0] + i, coords[1] - i, coords[2], 0, true, true) && CreatePed(21, GetHashKey(pedname),coords[0] - i, coords[1] + i, coords[2], 0, true, true)
          NetworkRegisterEntityAsNetworked(ped)
          if(DoesEntityExist(ped) && !IsEntityDead(GetPlayerPed(SelectedPlayer))) {
            var netped = PedToNet(ped)
            NetworkSetNetworkIdDynamic(netped, false)
            SetNetworkIdCanMigrate(netped, true)
            SetNetworkIdExistsOnAllMachines(netped, true)
            await Delay(500)
            NetToPed(netped)
            GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
            SetEntityInvincible(ped, true)
            SetPedCanSwitchWeapon(ped, true)
            TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
          } else if(IsEntityDead(GetPlayerPed(SelectedPlayer))) {
            TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
          } else {
            await Delay(0)
          }
        }
      }
    }
    if(ForceMenu.Button('Hot RPG')) {
      var pedname = "a_m_m_tranvest_01"
      var wep = "weapon_rpg"
      for (var i = 0; i < 10; i++) {
        var coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
        RequestModel(GetHashKey(pedname))
        await Delay(50)
        if(HasModelLoaded(GetHashKey(pedname))) {
          var ped = CreatePed(21, GetHashKey(pedname),coords[0] + i, coords[1] - i, coords[2], 0, true, true) && CreatePed(21, GetHashKey(pedname),coords[0] - i, coords[1] + i, coords[2], 0, true, true)
          NetworkRegisterEntityAsNetworked(ped)
          if(DoesEntityExist(ped) && !IsEntityDead(GetPlayerPed(SelectedPlayer))) {
            var netped = PedToNet(ped)
            NetworkSetNetworkIdDynamic(netped, false)
            SetNetworkIdCanMigrate(netped, true)
            SetNetworkIdExistsOnAllMachines(netped, true)
            await Delay(500)
            NetToPed(netped)
            GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
            SetEntityInvincible(ped, true)
            SetPedCanSwitchWeapon(ped, true)
            TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
          } else if(IsEntityDead(GetPlayerPed(SelectedPlayer))) {
            TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
          } else {
            await Delay(0)
          }
        }
      }
    }
    if(ForceMenu.Button('Banana Party')) {
      var obj1 = CreateObject(-1207431159, 0, 0, 0, true, true, true)
      var obj2 = CreateObject(GetHashKey("cargoplane"), 0, 0, 0, true, true, true)
      var obj3 = CreateObject(GetHashKey("prop_beach_fire"), 0, 0, 0, true, true, true)
      AttachEntityToEntity(obj1, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
      AttachEntityToEntity(obj2, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
      AttachEntityToEntity(obj3, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
    }
    if(ForceMenu.Button('Explode')) {
      AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 5, 3000.0, true, false, 100000.0)
      AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 5, 3000.0, true, false, true)
    }
  }

  //TP Menu
  else if (ForceMenu.IsMenuOpened('tpMenu')) {
    if(ForceMenu.Button('TP to Nearest Vehicle')) {
      TPtoNearCar()
    }
  }

  // Vehicle Menu
  else if (ForceMenu.IsMenuOpened('vMenu')) {
    if(ForceMenu.Button('Repair Engine')) {
      SetVehicleEngineHealth(GetVehiclePedIsUsing(PlayerPedId(-1)), 1000)
      SetVehicleEngineOn(GetVehiclePedIsUsing(PlayerPedId(-1)), true, true, true)
    }
    if(ForceMenu.Button('Repair Vehicle')) {
      SetVehicleFixed(GetVehiclePedIsUsing(PlayerPedId(-1), false))
      SetVehicleDirtLevel(GetVehiclePedIsUsing(PlayerPedId(-1), false), 0.0)
      SetVehicleLights(GetVehiclePedIsUsing(PlayerPedId(-1), false), 0)
      SetVehicleBurnout(GetVehiclePedIsUsing(PlayerPedId(-1), false), false)
      SetVehicleUndriveable(GetVehiclePedIsUsing(PlayerPedId(-1), false))
    }
    if(ForceMenu.Button('Clean Vehicle')) {
      SetVehicleDirtLevel(GetVehiclePedIsUsing(PlayerPedId(-1), false), 1.0)
    }

    if(ForceMenu.Button('Dirty Vehicle')) {
      SetVehicleDirtLevel(GetVehiclePedIsUsing(PlayerPedId(-1), false), 15.0)
    }

    if(ForceMenu.CheckBox('Always Clean', alwaysClean, false)) {
      alwaysClean = !alwaysClean
    }

    if(ForceMenu.CheckBox('Vehicle Invincible', vehGod, false)) {
      vehGod = !vehGod
    }
    if(ForceMenu.CheckBox('Waterproof Car', waterProof, false)) {
      waterProof = !waterProof
    }

    if(ForceMenu.CheckBox('Seatbelt', sbelt, false)) {
      sbelt = !sbelt
      console.log("Seatbelt "+sbelt);
    }

    if(ForceMenu.Button('Max Tuning')) {
      SetVehicleModKit(GetVehiclePedIsUsing(PlayerPedId(-1), false), 0)
      SetVehicleWheelType(GetVehiclePedIsUsing(PlayerPedId(-1), false), 7)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 0, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 0) - 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 1, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 1) - 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 2, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 2) - 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 3, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 3) - 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 4, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 4) - 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 5, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 5) - 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 6, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 6) - 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 7, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 7) - 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 8, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 8) - 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 9, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 9) - 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 10, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 10) - 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 11, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 11) - 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 12, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 12) - 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 13, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 13) - 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 14, 16, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 15, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 15) - 2, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 16, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 16) - 1, false)
      ToggleVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 17, true)
      ToggleVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 18, true)
      ToggleVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 19, true)
      ToggleVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 20, true)
      ToggleVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 21, true)
      ToggleVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 22, true)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 23, 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 24, 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 25, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 25) - 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 27, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 27) - 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 28, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 28) - 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 30, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 30) - 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 33, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 33) - 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 34, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 34) - 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 35, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 35) - 1, false)
      SetVehicleMod(GetVehiclePedIsUsing(PlayerPedId(-1), false), 38, GetNumVehicleMods(GetVehiclePedIsUsing(PlayerPedId(-1), false), 38) - 1, true)
      SetVehicleWindowTint(GetVehiclePedIsUsing(PlayerPedId(-1), false), 1)
      SetVehicleTyresCanBurst(GetVehiclePedIsUsing(PlayerPedId(-1), false), false)
      SetVehicleNeonLightEnabled(GetVehiclePedIsUsing(PlayerPedId(-1)), 0, true)
      SetVehicleNeonLightEnabled(GetVehiclePedIsUsing(PlayerPedId(-1)), 1, true)
      SetVehicleNeonLightEnabled(GetVehiclePedIsUsing(PlayerPedId(-1)), 2, true)
      SetVehicleNeonLightEnabled(GetVehiclePedIsUsing(PlayerPedId(-1)), 3, true)
      SetVehicleNeonLightsColour(GetVehiclePedIsUsing(PlayerPedId(-1)), 222, 222, 255)
    }

    /*
    if(ForceMenu.Button('Customize License Plate')) {
      custlp()
    }

    if(ForceMenu.CheckBox('Super Handling', shandle, false)) {
      shandle = !shandle
      console.log("Super Handling "+shandle);
    }
    */
  }

  // Lua Menu
  else if (ForceMenu.IsMenuOpened('lMenu')) {
    if(ForceMenu.Button('~p~->~s~ ESX Money')) {
      ForceMenu.OpenMenu('ESXMoney')
    } 
    if(ForceMenu.Button('~p~->~s~ ESX Drugs/Items Menu')) {
      ForceMenu.OpenMenu('ESXDrutems')
    } 
    if(ForceMenu.Button('~p~->~s~ ESX Misc')) {
      ForceMenu.OpenMenu('ESXMisc')
    } 
    if(ForceMenu.Button('~p~->~s~ VRP Menu')) {
      ForceMenu.OpenMenu('VRPMenu')
    } 
  }

  else if (ForceMenu.IsMenuOpened('ESXMoney')) {
    if(ForceMenu.Button('~g~ESX ~y~Caution Give Back')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("esx_jobs:caution", "give_back", result)
      }
    }
    if(ForceMenu.Button('~g~ESX ~y~Eden Garage')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("eden_garage:payhealth", -result)
      }
    }
    if(ForceMenu.Button('~g~ESX ~y~Fuel Delivery')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("esx_fueldelivery:pay", result)
      }
    }
    if(ForceMenu.Button('~g~ESX ~y~Car Thief')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("esx_carthief:pay", result)
      }
    }
    if(ForceMenu.Button('~g~ESX ~y~DMV School')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("esx_dmvschool:pay", -result)
      }
    }
    if(ForceMenu.Button('~g~ESX ~y~Dirty Job')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("esx_godirtyjob:pay", result)
      }
    }
    if(ForceMenu.Button('~g~ESX ~y~Pizza Boy')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("esx_pizza:pay", result)
      }
    }
    if(ForceMenu.Button('~g~ESX ~y~Ranger Job')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("esx_ranger:pay", result)
      }
    }
    if(ForceMenu.Button('~g~ESX ~y~Garbage Job')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("esx_garbagejob:pay", result)
      }
    }
    if(ForceMenu.Button('~g~ESX ~y~Car Thief ~r~DIRTY MONEY')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("esx_carthief:pay", result)
      }
    }
    if(ForceMenu.Button('~g~ESX ~y~Trucker Job')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("esx_truckerjob:pay", result)
      }
    }
    if(ForceMenu.Button('~g~ESX ~y~Postal Job')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("esx_gopostaljob:pay", result)
      }
    }
    if(ForceMenu.Button('~g~ESX ~y~Admin Give Bank')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("AdminMenu:giveBank", result)
      }
    }
    if(ForceMenu.Button('~g~ESX ~y~Admin Give Cash')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("AdminMenu:giveCash", result)
      }
    }
    if(ForceMenu.Button('~g~ESX ~y~Banker Job')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("esx_banksecurity:pay", result)
      }
    }
    if(ForceMenu.Button('~g~ESX ~y~Slot Machine')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("esx_slotmachine:sv:2", result)
      }
    }
    if(ForceMenu.Button('~g~ESX ~y~Taxi')) {
      let result = KeyboardInput("Enter amount of times", "", 100)
      if (result != '') {
        for (i = 0; result; i++) {
          emitNet("esx_slotmachine:sv:2", result)
        }
      } else {
        notify("~b~Invalid amount~s~.", false)
      }
    }
    if(ForceMenu.Button('~g~ESX ~y~House Robbery')) {
      let result = KeyboardInput("Enter amount of times", "", 100)
      if (result != '') {
        for (i = 0; result; i++) {
          emitNet('houseRobberies:giveMoney')
        }
      } else {
        notify("~b~Invalid amount~s~.", false)
      }
    }
    if(ForceMenu.Button('~g~ESX ~y~Mug')) {
      let result = KeyboardInput("Enter amount of times", "", 100)
      if (result != '') {
        for (i = 0; result; i++) {
          emitNet("esx_mugging:giveMoney")
        }
      } else {
        notify("~b~Invalid amount~s~.", false)
      }
    }
    if(ForceMenu.Button('~g~ESX ~y~Dirty Bank')) {
      let result = KeyboardInput("Enter amount of times", "", 100)
      if (result != '') {
        for (i = 0; result; i++) {
          emitNet("bankrobberies:receiveCash")
        }
      } else {
        notify("~b~Invalid amount~s~.", false)
      }
    }
  }

  else if (ForceMenu.IsMenuOpened('ESXDrutems')) {
    if(ForceMenu.Button('Get Weed')) {
      for (i = 0; 5; i++) {
        emitNet("esx_drugs:startHarvestWeed")
      }
    }
    if(ForceMenu.Button('Process Weed')) {
      for (i = 0; 5; i++) {
        emitNet('esx_drugs:processCannabis')
      }
    }
    if(ForceMenu.Button('Get Opium')) {
      for (i = 0; 5; i++) {
        emitNet('esx_drugs:startHarvestOpium')
      }
    }
    if(ForceMenu.Button('Process Opium')) {
      for (i = 0; 5; i++) {
        emitNet('esx_drugs:startTransformOpium')
      }  
    }
    if(ForceMenu.Button('Get Coke')) {
      for (i = 0; 5; i++) {
        emitNet('esx_drugs:startHarvestCoke')
      }  
    }
    if(ForceMenu.Button('Process Coke')) {
      for (i = 0; 5; i++) {
        emitNet('esx_drugs:startTransformCoke')
      }  
    }
    if(ForceMenu.Button('Get Meth')) {
      for (i = 0; 5; i++) {
        emitNet('esx_drugs:startHarvestMeth')
      }  
    }
    if(ForceMenu.Button('Process Meth')) {
      for (i = 0; 5; i++) {
        emitNet('esx_drugs:startTransformMeth')
      }  
    }
    if(ForceMenu.Button('Sell Drugs')) {
      emitNet("esx_drugs:startSellWeed")
      emitNet('esx_illegal_drugs:startSellCoke')
      emitNet('esx_illegal_drugs:startSellMeth')
      emitNet('esx_illegal_drugs:startSellOpium')
      emitNet("t1ger_drugs:sellDrugs")
    }
    if(ForceMenu.Button('Get Jewels')) {
      for (i = 0; 5; i++) {
        emitNet("esx_vangelico_robbery:gioielli1")
      }  
    }
    if(ForceMenu.Button('Items from House Robbery')) {
      let result = KeyboardInput("Enter amount of times", "", 100)
      if (result != '') {
        for (i = 0; result; i++) {
          emitNet("houseRobberies:searchItem")
        }
      } else {
        notify("~b~Invalid amount~s~.", false)
      }
    }
    if(ForceMenu.Button('Spawn items from ~b~police')) {
      let itemName = KeyboardInput("Enter item spawn name", "", 100) 
      if (itemName) {
        let itemAmount = KeyboardInput("Enter amount", "", 100)
        if (itemAmount) {
          emitNet('esx_policejob:putStockItems', (itemName),-(itemAmount))
        }
      }
    }
    if(ForceMenu.Button('Spawn items from ~o~mech')) {
      let itemName = KeyboardInput("Enter item spawn name", "", 100) 
      if (itemName) {
        let itemAmount = KeyboardInput("Enter amount", "", 100)
        if (itemAmount) {
          emitNet('esx_mechanicjob:putStockItems', (itemName),-(itemAmount))
        }
      }
    }
    if(ForceMenu.Button('Spawn items from ~o~vehshop')) {
      let itemName = KeyboardInput("Enter item spawn name", "", 100) 
      if (itemName) {
        let itemAmount = KeyboardInput("Enter amount", "", 100)
        if (itemAmount) {
          emitNet('esx_vehicleshop:putStockItems', (itemName), -(itemAmount))
        }
      }
    }
    if(ForceMenu.Button('Spawn items from ~y~taxi')) {
      let itemName = KeyboardInput("Enter item spawn name", "", 100) 
      if (itemName) {
        let itemAmount = KeyboardInput("Enter amount", "", 100)
        if (itemAmount) {
          emitNet('esx_taxijob:putStockItems', (itemName), -(itemAmount))
        }
      }
    }
  }

  else if (ForceMenu.IsMenuOpened('ESXMisc')) {
    if(ForceMenu.Button('Remove GSR')) {
      emitNet("GSR:Remove")
    }
    if(ForceMenu.Button('Set Hunger')) {
      emitNet('esx_status:set', 'hunger', 0)
    }
    if(ForceMenu.Button('Set Thirst')) {
      emitNet('esx_status:set', 'thirst', 0)
    }
    if(ForceMenu.Button('Set Stress')) {
      emitNet('esx_status:set', 'stress', 0)
    }
    if(ForceMenu.Button('Get All License')) {
      emitNet("esx_dmvschool:addLicense", 'dmv')
      emitNet("esx_dmvschool:addLicense", 'drive')
      emitNet("esx_dmvschool:addLicense", 'drive_bike')
      emitNet("esx_dmvschool:addLicense", 'drive_truck')
    }
  }

  else if (ForceMenu.IsMenuOpened('VRPMenu')) {
    if (ForceMenu.Button('~p~->~s~ VRP Misc')) {
      ForceMenu.OpenMenu('VRPMisc')
    }
    if(ForceMenu.Button('Give Money ~y~Garage')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("lscustoms:payGarage", -result)
      }
    }
    if (ForceMenu.Button('~g~PayCheck Abuse')) {
      let result = KeyboardInput("Enter amount of times", "", 100)
      if (result != '') {
        for (i = 0; result; i++) {
          emitNet('paycheck:bonus')
          emitNet('paychecks:bonus')
        }
      } else {
        notify("~b~Invalid amount~s~.", false)
      }
    }
    if(ForceMenu.Button('~g~SalaryPay Abuse - You need a job!')) {
      let result = KeyboardInput("Enter amount of times", "", 100)
      if (result != '') {
        for (i = 0; result; i++) {
          emitNet('paycheck:salary')
          emitNet('paychecks:salary')
        }
      } else {
        notify("~b~Invalid amount~s~.", false)
      }
    }
    if(ForceMenu.Button('~g~WIN ~s~Slot Machine')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("vrp_slotmachine:server:2", result)
      }
    }
    if(ForceMenu.Button('~g~Drop Off Money')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("dropOff", result)
      }
    }
    if(ForceMenu.Button('~g~delivery Pay')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("delivery:success", result)
      }
    }
    if(ForceMenu.Button('~g~Trucker Fuel Pay')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("truckerfuel", result)
      }
    }
    if(ForceMenu.Button('~g~Trucker Job Pay')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("truckerJob:success", result)
      }
    }
    if(ForceMenu.Button('~g~VRP Pay')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("vRP:pay", result)
      }
    }
    if(ForceMenu.Button('~g~Repair Pay')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("PayForRepairNow", result)
      }
    }
    if(ForceMenu.Button('~g~Bank Deposit')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("bank:deposit", result)
        emitNet("Banca:deposit", result)
      }
    }
    if(ForceMenu.Button('~g~Bank Withdraw')) {
      let result = KeyboardInput("Enter amount of money", "", 100)
      if (result != '') {
        emitNet("bank:withdraw", result)
        emitNet("Banca:withdraw", result)
      }
    }
  }

  else if (ForceMenu.IsMenuOpened('VRPMisc')) {
    if(ForceMenu.Button('~r~Unhandcuff')) {
      //vRP.toggleHandcuff()
    }
    if(ForceMenu.Button('~g~Get Driving Licenses')) {
      emitNet("dmv:success")
      emitNet("dmv:success", drive)
      emitNet("dmv:success", drive_bike)
      emitNet("dmv:success", drive_truck)
    }
  }

  // Weapon Menu
  else if (ForceMenu.IsMenuOpened('wMenu')) {
    if (ForceMenu.Button('~p~->~s~ Crosshair Selection')) {
      ForceMenu.OpenMenu('xMenu')
    } 
    if (ForceMenu.Button('~p~->~s~ Give Single Weapon')) {
      ForceMenu.OpenMenu('GSWP')
    } 
    if (ForceMenu.Button('Give All Weapons')) {
      for (i = 1; allWeapons.length; i++) {
        GiveWeaponToPed(PlayerPedId(-1), GetHashKey(allWeapons[i]), 1000, false, false)
      }
    }
    if (ForceMenu.Button('Remove All Weapons')) {
      RemoveAllPedWeapons(GetPlayerPed(-1), true)
    }
    if (ForceMenu.Button('Drop Current Weapons')) {
      let a = GetPlayerPed(-1)
      let b = GetSelectedPedWeapon(a)
      SetPedDropsInventoryWeapon(GetPlayerPed(-1), b, 0, 2.0, 0, -1)
    }
    if (ForceMenu.Button('Add Ammo')) {
      let result = KeyboardInput("Enter the amount of ammo", "", 100)
      if (result != '') {
        SetPedAmmo(GetPlayerPed(-1), GetHashKey(WeaponSelected.id), result)
      }
    }
    if(ForceMenu.CheckBox('Infinite Ammo', infammo, false)) {
      infammo = !infammo
      console.log("Infinite Ammo "+infammo);
    }
    /*
    if(ForceMenu.CheckBox('Rapid Fire', rfire, false)) {
      rfire = !rfire
      console.log("Rapid Pew Pew "+rfire);
    }
    if(ForceMenu.CheckBox('Explosive Ammo', explosiveAmmo, false)) {
      explosiveAmmo = !explosiveAmmo
      console.log("Boom Boom Bullets "+explosiveAmmo);
    }*/
    if(ForceMenu.CheckBox('Triggerbot', trigBot, false)) {
      trigBot = !trigBot
      console.log("Calculated Trigonometry "+trigBot);
    }
  }
  // Single Weapon Menu
  else if (ForceMenu.IsMenuOpened('GSWP')) {
    for (var i = 0; i < allWeapons.length; i++) {
      if (ForceMenu.Button(allWeapons[i])) {
        GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(allWeapons[i]), 1000, false, true)
      }
    }
  }

  //Crosshair menu
  else if (ForceMenu.IsMenuOpened('xMenu')) {
    if(ForceMenu.CheckBox('Default', xhair1, false)) {
      xhair1 = !xhair1
    }
    if(ForceMenu.CheckBox('Cross', xhair2, false)) {
      xhair2 = !xhair2
    }
    if(ForceMenu.CheckBox('Red Dot', xhair3, false)) {
      xhair3 = !xhair3
    }
  }
  // Advanced Menu
  else if (ForceMenu.IsMenuOpened('advMenu')) {
   
    if(ForceMenu.Button('~p~->~s~ Destroyer Menu WIP')) {
      ForceMenu.OpenMenu('advMenu')
    }
    if(ForceMenu.CheckBox('Show Blips', playerBlips, false)) {
      playerBlips = !playerBlips
    }
    if(ForceMenu.CheckBox('Name Above', nameabove, false)) {
      nameabove = !nameabove
      console.log("Name Above "+nameabove);
    }

    if(ForceMenu.Button('Force 3rd Person')) {
      SetFollowVehicleCamViewMode(2)
      SetFollowPedCamViewMode(2)
    } 

    if(ForceMenu.Button('Opt FPS')) {
      ClearAllBrokenGlass()
      ClearAllHelpMessages()
      LeaderboardsReadClearAll()
      ClearBrief()
      ClearGpsFlags()
      ClearPrints()
      ClearSmallPrints()
      ClearReplayStats()
      LeaderboardsClearCacheData()
      ClearFocus()
      ClearHdArea()
      ClearPedBloodDamage(PlayerPedId())
      ClearPedWetness(PlayerPedId())
      ClearPedEnvDirt(PlayerPedId())
      ResetPedVisibleDamage(PlayerPedId())
    } 
  }

  //Open Menu Button
  else if(IsControlJustReleased(0, 178) ) { // delete by default 
    ForceMenu.OpenMenu('revolution')
  }

  // Close Menu
  else if (ForceMenu.IsMenuOpened('closeMenu')) {
    if(ForceMenu.Button('Yes')) {
      ForceMenu.CloseMenu()
      ForceMenu.EndMenu()
    }
    else if (ForceMenu.MenuButton('No', 'revolution')) {}
    else if (ForceMenu.MenuButton('Credits: EnVyP & MachineTherapist', 'revolution')) {}
  }
})

//###################\\
// Thread
//###################\\
setTick(async () => {
    // Show Menu
    ForceMenu.Display()
    DisplayRadar(true)
    // God mode
    SetPlayerInvincible(PlayerId(-1), Godmode)
    SetEntityInvincible(PlayerPedId(-1), Godmode)
    // Super Jump
    if(Superjump) SetSuperJumpThisFrame(PlayerId(-1));
    // Player Visibility
    SetEntityVisible(GetPlayerPed(), Visibility, 0)
    // Infinity Stamina
    if(InfinityStamina) RestorePlayerStamina(PlayerId(-1), 1.0);
    // Thermal Vision
    SetSeethrough(ThermalVision)
    // Night Vision
    SetNightvision(NightVision)

    if (xhair1) ShowHudComponentThisFrame(14);
    if (xhair2) DrawTxt("~r~+", 0.495, 0.484)
    if (xhair3) DrawTxt("~r~.", 0.4968, 0.478)

    //Tiny Man
    if (tinyTim) {
      SetPedConfigFlag(PlayerPedId(), 223, true) 
    } else {
      SetPedConfigFlag(PlayerPedId(), 223, false)
    }

    //Become Flash
    if (bcFlash) {
      SetSuperJumpThisFrame(PlayerId())
      SetRunSprintMultiplierForPlayer(PlayerId(), 1.49)
      SetPedMoveRateOverride(PlayerId(), 10)
      RequestNamedPtfxAsset("core")
      UseParticleFxAssetNextCall("core")
      StartNetworkedParticleFxNonLoopedOnEntity("ent_sht_electrical_box", PlayerPedId(), 0, 0, -0.5, 0, 0, 0, 1, false, false, false )
    } 

    // Fast Run
    if(FastRun) {
      SetRunSprintMultiplierForPlayer(PlayerId(-1), 2.49)
      SetPedMoveRateOverride(GetPlayerPed(-1), 2.15)
    } else {
      SetRunSprintMultiplierForPlayer(PlayerId(-1), 1.0)
      SetPedMoveRateOverride(GetPlayerPed(-1), 1.0)
    }
    // Anti Rag
    if(antirag) SetPedCanRagdoll(PlayerPedId(-1), false);

    // Demi God
    if(demigod) SetEntityHealth(PlayerPedId(), 200);

    // Explosive Punch
    if(epunch) SetExplosiveMeleeThisFrame(PlayerId());

    // Infinite Ammo 
    if(infammo) {
      SetPedInfiniteAmmoClip(GetPlayerPed(-1), true)
      PedSkipNextReloading(GetPlayerPed(-1))
      SetPedShootRate(GetPlayerPed(-1), 1000);
    }

    if (vehGod && (IsPedInAnyVehicle(PlayerPedId(-1), true))) SetEntityInvincible(GetVehiclePedIsUsing(PlayerPedId(-1)), true);

    if (waterProof && (IsPedInAnyVehicle(PlayerPedId(-1), true))) SetVehicleEngineOn(GetVehiclePedIsUsing(PlayerPedId(-1)), true, true, true);

    if (alwaysClean) {
      SetVehicleFixed(GetVehiclePedIsIn(GetPlayerPed(-1), false))
      SetVehicleDirtLevel(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0.0)
      SetVehicleLights(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
      SetVehicleBurnout(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
    }


    // Aquaman
    if(aman) {
      SetPedDiesInWater(PlayerId(-1), false)
      SetEnableScuba(PlayerId(-1), true) 
      SetPedMaxTimeUnderwater(PlayerId(-1), 999.9)
    } else {
      SetPedDiesInWater(PlayerId(-1), true)
      SetEnableScuba(PlayerId(-1), false) 
      SetPedMaxTimeUnderwater(PlayerId(-1), 1.0)
    }

    // Seatbelt
    if(sbelt) SetPedCanBeKnockedOffVehicle(PlayerPedId(-1), 1); 

    // nameabove
    if(nameabove) {
      var playerlist = GetActivePlayers()
      for (var i = 1; i < playerlist.length; i++) {
        var ra = RGB(1.0)
        var [x1, y1, z1] = GetEntityCoords(GetPlayerPed(-1), true)
        var [x2, y2, z2] = GetEntityCoords(GetPlayerPed(i), true)
        var disPlayerNames = 130
        var distance = Math.floor(GetDistanceBetweenCoords(x1, y1, z1, x2, y2, z2, true))
        if ((distance) < (disPlayerNames)) {
          if (NetworkIsPlayerTalking( i )) {
            DrawText3D(x2, y2, z2+1.2, GetPlayerServerId(i) + "  |  " + GetPlayerName(i), ra.r,ra.g,ra.b)
          } else {
            DrawText3D(x2, y2, z2+1.2, GetPlayerServerId(i) + "  |  " + GetPlayerName(i), 255,255,255)
          }
        }
      }
    }

    //Triggerbot
    if (trigBot) {
    var Aiming, Entity = GetEntityPlayerIsFreeAimingAt(PlayerId(-1), Entity)
      if (Aiming) {
        if ((IsEntityAPed(Entity)) && (!IsPedDeadOrDying(Entity, 0)) && IsPedAPlayer(Entity)) {
          ShootPlayer(Entity)
        }
      }
    }
    // Noclip
    if(Noclip) {
      var entity = IsPedInAnyVehicle(PlayerPedId(-1), false) && GetVehiclePedIsUsing(PlayerPedId(-1)) || PlayerPedId(-1)
      DrawTxt("NOCLIP ~g~ON", 0.70, 0.9)
      var currentSpeed = 2
      var noclipEntity = IsPedInAnyVehicle(PlayerPedId(-1), false) && GetVehiclePedIsUsing(PlayerPedId(-1)) || PlayerPedId(-1)

      var newPos = GetEntityCoords(entity)

      DisableControlAction(0, 32, true)
      DisableControlAction(0, 268, true)

      DisableControlAction(0, 31, true)

      DisableControlAction(0, 269, true)
      DisableControlAction(0, 33, true)

      DisableControlAction(0, 266, true)
      DisableControlAction(0, 34, true)

      DisableControlAction(0, 30, true)

      DisableControlAction(0, 267, true)
      DisableControlAction(0, 35, true)

      DisableControlAction(0, 44, true)
      DisableControlAction(0, 20, true)

      var yoff = 0.0
      var zoff = 0.0

      if (GetInputMode() === "MouseAndKeyboard") {
        if (IsDisabledControlPressed(0, 32)) yoff = 0.5
        if (IsDisabledControlPressed(0, 33)) yoff = -0.5
        if (IsDisabledControlPressed(0, 34)) SetEntityHeading(PlayerPedId(-1), GetEntityHeading(PlayerPedId(-1)) + 3.0)
        if (IsDisabledControlPressed(0, 35)) SetEntityHeading(PlayerPedId(-1), GetEntityHeading(PlayerPedId(-1)) - 3.0)
        if (IsDisabledControlPressed(0, 44)) zoff = 0.21
        if (IsDisabledControlPressed(0, 20)) zoff = -0.21
      }

      newPos = GetOffsetFromEntityInWorldCoords(noclipEntity, 0.0, yoff * (currentSpeed + 0.3), zoff * (currentSpeed + 0.3))

      var heading = GetEntityHeading(noclipEntity)
      SetEntityVelocity(noclipEntity, 0.0, 0.0, 0.0)
      SetEntityRotation(noclipEntity, 0.0, 0.0, 0.0, 0, false)
      SetEntityHeading(noclipEntity, heading)

      SetEntityCollision(noclipEntity, false, false)
      SetEntityCoordsNoOffset(noclipEntity, newPos[0], newPos[1], newPos[2], true, true, true)

      SetEntityCollision(noclipEntity, true, true)
    }

    /*
    // Track Player
    if(trackplayer) {
      var coords = GetEntityCoords(GetPlayerPed(TrackedPlayer))
      SetNewWaypoint(coords.x, coords.y)
    } 

    // Super Handling
    if(shandle) {
      var pVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
      if (IsPedInAnyVehicle(PlayerPedId())) {
        SetVehicleGravityAmount(pVehicle, 20.0)
        SetHandlingInt(GetVehiclePedIsUsing(PlayerPedId()), CHandlingData, fTractionCurveMin, 1000000)
      } else {
        SetVehicleGravityAmount(pVehicle, 10.0) 
      }
    }
    
    if (rfire) {
      rapidfire()
    }

    if (explosiveAmmo) {
      var ret, pos = GetPedLastWeaponImpactCoord(PlayerPedId())
      if (ret) {
        AddExplosion(pos.x, pos.y, pos.z, 1, 1.0, 1, 0, 0.1)
      }
    }
    */
   await Delay(1)
   for (var id = 0; id < SvMaxPlayers; id++) {
     if(NetworkIsPlayerActive(id) && GetPlayerPed(id) !== GetPlayerPed( -1 ) ) {
       var ped = GetPlayerPed( id )
       var blip = GetBlipFromEntity( ped )
       var myCoords = GetEntityCoords( GetPlayerPed( -1 ), true )
       var playerCoords = GetEntityCoords( GetPlayerPed( id ), true )
       var x1 = myCoords[0]
       var y1 = playerCoords[1]
       var z1 = myCoords[2]
       var x2 = playerCoords[0]
       var y2 = playerCoords[1]
       var z2 = playerCoords[2]
       var 
       var distance = Math.round(GetDistanceBetweenCoords(x1,  y1,  z1,  x2,  y2,  z2,  true))
       var headId = CreateFakeMpGamerTag(ped, GetPlayerName( id ), false, false, "", false )
       wantedLvl = GetPlayerWantedLevel ( id )

       if(showsprite) {
         SetMpGamerTagVisibility(headId, 0, true)
         if(wantedLvl) {
           SetMpGamerTagVisibility(headId, 7, true)
           SetMpGamerTagWantedLevel(headId, wantedLvl)
         } else {
           SetMpGamerTagVisibility(headId, 7, false)
         }
       } else {
         SetMpGamerTagVisibility(headId, 7, false)
         SetMpGamerTagVisibility(headId, 9, false)
         SetMpGamerTagVisibility(headId, 0, false)
       }

       if(PlayerBlips){
         if(!DoesBlipExist( blip )) {
           var blip = AddBlipForEntity( ped )
           SetBlipSprite(blip, 1)
           ShowHeadingIndicatorOnBlip(blip, true)
           SetBlipNameToPlayerName(blip, id)
         } else {
           var veh = GetVehiclePedIsIn( ped, false )
           var blipSprite = GetBlipSprite( blip )
           if(!GetEntityHealth( ped )) {
             if(blipSprite !== 274) {
               SetBlipSprite( blip, 274 )
               ShowHeadingIndicatorOnBlip(blip, false )
               SetBlipNameToPlayerName(blip, id)
             }
           } else if( veh ) {
             var vehClass = GetVehicleClass( veh )
             var vehModel = GetEntityModel( veh )

             if(vehClass === 15 ) {
               if(blipSprite !== 422 ) {
                 SetBlipSprite( blip, 422 )
                 ShowHeadingIndicatorOnBlip( blip, false )
                 SetBlipNameToPlayerName(blip, id)
               }
             } else if ( vehClass === 16 ) {
               if(vehModel === GetHashKey( "besra" ) || vehModel === GetHashKey( "hydra" ) || vehModel == GetHashKey( "lazer" ) ) {
                 if(blipSprite !== 424 ) {
                   SetBlipSprite( blip, 424 )
                   ShowHeadingIndicatorOnBlip(blip, false )
                   SetBlipNameToPlayerName(blip, id)
                 } else if ( blipSprite !== 423 ) {
                   SetBlipSprite( blip, 423 )
                   ShowHeadingIndicatorOnBlip(blip, false )
                 }
               }
             } else if ( vehClass === 14 ) {
               if( blipSprite !== 427 ) {
                 SetBlipSprite( blip, 427 )
                 ShowHeadingIndicatorOnBlip(blip, false )
               }
             } else if (vehModel == GetHashKey( "insurgent" ) || vehModel == GetHashKey( "insurgent2" )) {
               if(blipSprite !== 426) {
                 SetBlipSprite( blip, 426 )
                 ShowHeadingIndicatorOnBlip(blip, false )
                 SetBlipNameToPlayerName(blip, id)
               }
             } else if( vehModel == GetHashKey( "rhino" ) ) {
               if(blipSprite !== 421) {
                 SetBlipSprite( blip, 421 )
                 ShowHeadingIndicatorOnBlip(blip, false )
                 SetBlipNameToPlayerName(blip, id)
               }
             } else if ( blipSprite !== 1) {
               SetBlipSprite( blip, 1 )
               ShowHeadingIndicatorOnBlip(blip, true )
               SetBlipNameToPlayerName(blip, id)
             }

             SetBlipRotation( blip, Math.min( GetEntityHeading( veh ) ) ) 
             SetBlipNameToPlayerName( blip, id )
             SetBlipScale( blip,  0.85 )

             if(IsPauseMenuActive()) {
               SetBlipAlpha( blip, 255 )
             } else {
               myCoords = GetEntityCoords( GetPlayerPed( -1 ), true )
               playerCoords = GetEntityCoords( GetPlayerPed( id ), true )
               distance = ( Math.round( Math.abs( Math.sqrt(  ( x1 - x2 ) * ( x1 - x2 ) + ( y1 - y2 ) * ( y1 - y2 ) ) ) / -1 ) ) + 900
               if( distance < 0 ) {
                 distance = 0
               } else if(distance > 255) {
                 distance = 255
               }

               SetBlipAlpha( blip, distance )
               
             }
           }
         }
       } else {
         RemoveBlip(blip)
       }
     }
   }
})


