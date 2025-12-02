--============================
-- Indo Saka Reform Scripts

-- Author: Litharion, DeI 1.2
--4/22/20 added Media reform - Dresden
--6/25/2017 - Dresden- added Getae reforms
-- 11/11/2016
-- functions are revised
-- region keys adapted for new GC map

--Additions - Dacian and Mauryan reforms

--============================
-- The content of the script belongs to DeI and as such cannot be used
-- elsewhere without express consent.

---------------------------------
-- regions must be hold 20 turns we raise the counter as long as we have all the regions under control
-- the timer will reset if the player losses control
-------------------------------------------

-- Make the script a module one
module(..., package.seeall);

-- Used to have the object library able to see the variables in this new environment
_G.main_env = getfenv(1);

-- Load libraries
-- require "lua_scripts.saka_reform_script_header";
scripting = require "lua_scripts.EpisodicScripting";

-- Log variables
isLogAllowed = false;

-- General Variables
-- variables to save the current status of the Reform
saka_reform_successful = false
saka_reform_counter_start = false
saka_units_unlock = false
saka_reform_counter = 0
saka_global_info = false
saka_first_turn_setup = false
saka_player_info = false
scythian_saramatian_battles_fought = 0
scythian_first_turn_setup = false
scythian_units_unlock = false
scythian_global_info = false
scythian_player_info = false
scythian_reform_go = false
getae_reform_successful = false
getae_reform_counter_start = false
getae_units_unlock = false
getae_reform_counter = 0
getae_global_info = false
getae_first_turn_setup = false
getae_player_info = false
getae_battles_fought = 0
maurya_reform_successful = false
maurya_reform_counter_start = false
maurya_units_unlock = false
maurya_reform_counter = 0
maurya_global_info = false
maurya_first_turn_setup = false
maurya_player_info = false
maurya_battles_fought = 0
media_reform_successful = false
media_reform_counter_start = false
media_units_unlock = false
media_reform_counter = 0
media_global_info = false
media_first_turn_setup = false
media_player_info = false
media_reform_successful1 = false
media_reform_counter_start1 = false
media_units_unlock1 = false
media_reform_counter1 = 0
media_global_info1 = false
media_player_info1 = false

--================================
-- Saka Reform Unit List
-- As the Script only checks the restricted unit entries on the first turn, changes to the list will not work with save games
--================================

saka_restricted_units =
    {
    "Ste_Saka_Heavy_Hoplites",
    "Ste_Indo_Greek_Nobles",
    "Ste_Indo_Greek_Heavy_Cavalry",
    "Ste_Scythian_Royal_Horse",
    }

saka_reform_units =
    {
    "Ste_Saka_Heavy_Hoplites",
    "Ste_Indo_Greek_Nobles",
    "Ste_Indo_Greek_Heavy_Cavalry",
    "Ste_Scythian_Royal_Horse",
    }

scythian_sarmatian_restricted_units =
    {
    "Scy_reform_horse_archers",
    "Scy_reform_lancers",
    "Scy_reform_mounted_peltasts",
"Late_Sarmatian_Cataphract",
    }

scythian_sarmatian_reform_units =
    {
    "Scy_reform_horse_archers",
    "Scy_reform_lancers",
    "Scy_reform_mounted_peltasts",
"Late_Sarmatian_Cataphract",
    }

scythian_faction =
    {
    "rom_budini",
    "rom_catiaroi",
    "rom_scythia",
    }

sarmatian_factions =
    {
    "rom_aorsoi",
    "rom_siraces",
    "rom_roxolani",
    }
	
getae_restricted_units =
    {
    "dac_late_spearmen",
"dac_late_chosen_spearmen",
"dac_late_heavy_falxmen",
"dac_late_swordsmen",
"dac_late_foot_nobles",
"dac_late_archers",
"dac_late_elite_archers",
"dac_late_bodyguard_cav",
"dac_late_royal_cav",
"dac_late_cataphract_cav",
    }

getae_reform_units =
    {
  "dac_late_spearmen",
"dac_late_chosen_spearmen",
"dac_late_heavy_falxmen",
"dac_late_swordsmen",
"dac_late_foot_nobles",
"dac_late_archers",
"dac_late_elite_archers",
"dac_late_bodyguard_cav",
"dac_late_royal_cav",
"dac_late_cataphract_cav",
    }

maurya_restricted_units =
    {
"ind_greek_guard",
"ind_reform_peltasts",
"ind_reform_cav",
    }

maurya_reform_units =
    {
"ind_greek_guard",
"ind_reform_peltasts",
"ind_reform_cav",
    }
	
	media_restricted_units =
    {
  "Eas_Atr_Late_Noble_Cav",
"Eas_Atr_Late_Med_Cav",
"Eas_Atr_Late_Cataphracts",
"Eas_Atr_Daylami_Infantry",
"Eas_Atr_Royal_Archers",
"Eas_Atr_Iran_Thureos",
"Eas_Atr_Median_Cataphract",
"Eas_Atr_Reformed_Median_Cavalry",
"Eas_Median_Horse_Archers",
"Eas_Atr_Late_Cataphracts_com",
    }

media_reform_units =
    {
"Eas_Atr_Late_Noble_Cav",
"Eas_Atr_Late_Med_Cav",
"Eas_Atr_Late_Cataphracts",
"Eas_Atr_Daylami_Infantry",
"Eas_Atr_Royal_Archers",
"Eas_Atr_Iran_Thureos",
"Eas_Atr_Median_Cataphract",
"Eas_Atr_Reformed_Median_Cavalry",
"Eas_Median_Horse_Archers",
"Eas_Atr_Late_Cataphracts_com",
    }

media_reform_units1 =
    {
"Eas_Atr_Iran_Thureos",
"Eas_Atr_Median_Cataphract",
"Eas_Atr_Reformed_Median_Cavalry",
"Eas_Median_Horse_Archers",
    }
	
-- ************************************************************************
--
-- GENERAL FUNCTIONS
--
-- These are functions that don't pertain to a specific section
-- but are used by both Global and Player Reforms.
--
-- ************************************************************************
function Log(text, isTitle, isNew)
  if not isLogAllowed then return end

  local logfile;
  text = tostring(text);
  if isNew then
    logfile = io.open("DeI_Saka_Reform_Log.txt","w");
    local curr_date = os.date("%A, %m %B %Y");
    local text = tostring("- Divide et Impera Saka Reform Log\n".."- "..curr_date);
    logfile:write(text.."\n\n");
  else
    logfile = io.open("DeI_Saka_Reform_Log.txt","a");
    if not logfile then logfile = io.open("DeI_Saka_Reform_Log.txt","w") end
  end

  if isTitle then
    local title_text = "*************************************************************************\n";
    text = "\n"..title_text..text.."\n"..title_text;
  end

  logfile:write(text.."\n");
  logfile:close();
end


function contains(element, list)
  for _, v in ipairs(list) do
    if element == v then
                 return true
    end
  end
  return false
end

-- ************************************************************************
--
-- EVENTS FUNCTIONS
--
-- These are the functions that control the events in the game
--
-- ************************************************************************


--============================
-- Indo Saka Reform

-- SakaFirstTurnSetup
-- SakaPlayerInfo
-- SakaReform
-- sakacounter
--============================

-- called once to restrict the Reform Units
local function SakaReform(context)
local current_faction = context.string

-- SakaFirstTurnSetup
  if current_faction == "rom_massagetae" then
    local turn_num = scripting.game_interface:model():turn_number()

    if not saka_first_turn_setup
      and turn_num >= 1 then
          for i = 1, #saka_restricted_units do
            local units = saka_restricted_units[i]
            scripting.game_interface:add_event_restricted_unit_record(units)
          end
        saka_first_turn_setup = true
        Log("Saka Reform Units locked")
    end

    if context:faction():is_human() then

    -- this function is used to create a message about the reform for the scythian player
      if turn_num == 5
        then scripting.game_interface:show_message_event("custom_event_171", 0, 0)
      end

    -- main functions for the saka reform
      if not saka_reform_successful then
          CheckSakaReform(current_faction, turn_num)
          Log("CheckSakaReform")

        if saka_reform_counter_start then
          CheckSakaReformCounter()
          Log("CheckSakaReformCounter")
        end
      end

      if saka_reform_counter  == 1
        then effect.advance_contextual_advice_thread("Saka.20.turns", 1, context);
      elseif saka_reform_counter  == 10
        then effect.advance_contextual_advice_thread("Saka.10.turns", 1, context);
      elseif saka_reform_counter  == 15
        then effect.advance_contextual_advice_thread("Saka.5.turns", 1, context);
      end

      if saka_reform_successful
        and saka_units_unlock == false then
        setSakaUnits()
      end

      -- Reform Message
      if saka_units_unlock
        and not saka_player_info
          then scripting.game_interface:show_message_event("custom_event_170", 0, 0)
        Log("Player Message displayed");
        saka_player_info = true
      end

    elseif context:faction():is_human() == false then

      if not saka_units_unlock
        and turn_num >= 80  -- AI reforms, set global var
          then setSakaUnits()
      end
    end
  end
end

function CheckSakaReform(current_faction, turn_num)
    local region_bactria_baktria = scripting.game_interface:model():world():region_manager():region_by_key("emp_bactria_baktria")
    local owner_bactria_baktria = region_bactria_baktria:owning_faction():name()

    local region_bactria_eucratides = scripting.game_interface:model():world():region_manager():region_by_key("emp_bactria_eucratides")
    local owner_bactria_eucratides = region_bactria_eucratides:owning_faction():name()

    local region_bactria_kapisene = scripting.game_interface:model():world():region_manager():region_by_key("emp_bactria_kapisene")
    local owner_bactria_kapisene = region_bactria_kapisene:owning_faction():name()

    local region_transoxania_bukhara = scripting.game_interface:model():world():region_manager():region_by_key("emp_transoxania_bukhara")
    local owner_transoxania_bukhara = region_transoxania_bukhara:owning_faction():name()

    local region_transoxania_maracanda = scripting.game_interface:model():world():region_manager():region_by_key("emp_transoxania_maracanda")
    local owner_transoxania_maracanda = region_transoxania_maracanda:owning_faction():name()

    if owner_bactria_baktria == current_faction
      and owner_bactria_eucratides == current_faction
      and owner_bactria_kapisene == current_faction
      and owner_transoxania_bukhara == current_faction
      and owner_transoxania_maracanda == current_faction
        then saka_reform_counter_start = true;
        Log("Saka Reform Counter start");
      else saka_reform_counter_start = false;
           saka_reform_counter = 0
          Log("ReformCounter: Reset to ("..saka_reform_counter..")");
    end
end

function CheckSakaReformCounter()
  if saka_reform_counter  >= 20 -- global VAR please !!!!
    then saka_reform_successful = true
    Log("Saka Reform successful");

  else saka_reform_counter = saka_reform_counter + 1
    Log("ReformCounter: New Number achieved! ("..saka_reform_counter..")");
  end
end

function setSakaUnits()
  for i = 1, #saka_reform_units do
    local units = saka_reform_units[i]
    scripting.game_interface:remove_event_restricted_unit_record(units)
  end
    saka_units_unlock = true
    Log("Saka Reform Units unlocked")
end

-- Reform Message
local function GlobalMessage(context)
local current_faction = context.string
  if saka_units_unlock
    and context:faction():is_human() == true
    and not saka_global_info
    and current_faction ~= "rom_massagetae"
      then scripting.game_interface:show_message_event("custom_event_172", 0, 0)
      Log("Global Message displayed");
      saka_global_info = true
      saka_player_info = true
  end

  if scythian_units_unlock
    and context:faction():is_human() == true
    and not scythian_global_info
    and not (contains(current_faction,scythian_faction) or contains(current_faction,sarmatian_factions))
      then scripting.game_interface:show_message_event("custom_event_191", 0, 0)
      Log("Scythian Reform Global Message displayed");
    scythian_global_info =  true
  end
end

--============================
-- Skytho Sarmatian Reform

-- scythianFirstTurnSetup
-- scythian_collect_battles_fought
-- scythian_unlock_units
--============================
local function ScythianReform(context)
local current_faction = context.string

  if context:faction():subculture() == "sc_rom_barb_east" then
    local turn_num = scripting.game_interface:model():turn_number()

-- SakaFirstTurnSetup
    if not scythian_first_turn_setup then
      for i = 1, #scythian_sarmatian_restricted_units do
        local units = scythian_sarmatian_restricted_units[i]
        scripting.game_interface:add_event_restricted_unit_record(units)
      end
      scythian_first_turn_setup = true
      Log("Skythian Reform Units locked")
   end

    if (contains(current_faction,scythian_faction) or contains(current_faction,sarmatian_factions)) then

-- check if reform requirements are met
      if not scythian_units_unlock
        and not scythian_reform_go then
          ScythianReformCheck(turn_num)
          Log("Scythian ScythianReformCheck");
      elseif not scythian_units_unlock
        and scythian_reform_go then
          ScythianUnlockUnits()
          Log("Scythian ScythianUnlockUnits");
      end

-- human scythian player section
      if context:faction():is_human() then
-- player Info Message about reforms triggers on turn 2
        if turn_num == 2 then
          scripting.game_interface:show_message_event("custom_event_190", 0, 0)
          Log("Scythian Starting Global Message displayed");
        end
-- player reform message displayed
        if scythian_units_unlock
          and not scythian_player_info
            then scripting.game_interface:show_message_event("custom_event_192", 0, 0)
            Log("Scythian Reform Player Message displayed");
          scythian_player_info = true
        end
      end
    end
  end
end


function ScythianUnlockUnits()
  for i = 1, #scythian_sarmatian_reform_units do
    local units = scythian_sarmatian_reform_units[i]
    scripting.game_interface:remove_event_restricted_unit_record(units)
  end
      scythian_units_unlock = true;
      Log("Skythian Units unlocked");
end

function ScythianReformCheck(turn_num)
  -- scythian regions
    local region_sarmatia_melgunov = scripting.game_interface:model():world():region_manager():region_by_key("emp_sarmatia_melgunov")
    local owner_sarmatia_melgunov = region_sarmatia_melgunov:owning_faction():name()

    local region_sarmatia_olbia = scripting.game_interface:model():world():region_manager():region_by_key("emp_sarmatia_olbia")
    local owner_sarmatia_olbia = region_sarmatia_olbia:owning_faction():name()

    local region_sarmatia_solokha = scripting.game_interface:model():world():region_manager():region_by_key("emp_sarmatia_solokha")
    local owner_sarmatia_solokha = region_sarmatia_solokha:owning_faction():name()

-- sarmatian regions
    local region_scythia_gelonus = scripting.game_interface:model():world():region_manager():region_by_key("emp_scythia_gelonus")
    local owner_scythia_gelonus = region_scythia_gelonus:owning_faction():name()

    local region_scythia_samandar = scripting.game_interface:model():world():region_manager():region_by_key("emp_scythia_samandar")
    local owner_scythia_samandar = region_scythia_samandar:owning_faction():name()

    local region_scythia_sarai = scripting.game_interface:model():world():region_manager():region_by_key("emp_scythia_sarai")
    local owner_scythia_sarai = region_scythia_sarai:owning_faction():name()

    local region_scythia_siracena = scripting.game_interface:model():world():region_manager():region_by_key("emp_scythia_siracena")
    local owner_scythia_siracena = region_scythia_siracena:owning_faction():name()

    if (contains(owner_sarmatia_melgunov,scythian_faction)
      or contains(owner_sarmatia_olbia,scythian_faction)
      or contains(owner_sarmatia_solokha,scythian_faction)
      or contains(owner_scythia_gelonus,sarmatian_factions)
      or contains(owner_scythia_samandar,sarmatian_factions)
	  or contains(owner_scythia_sarai,sarmatian_factions)
      or contains(owner_scythia_siracena,sarmatian_factions))

      and turn_num >= 100 -- 100
        then scythian_reform_go = true
        Log("Scythian Regions Go")
    elseif scythian_saramatian_battles_fought >= 10 --10
      and turn_num >= 70 -- 70
        then scythian_reform_go = true
        Log("Scythian Reform Battles Go")
    end
end


local function ScythianCollectBattlesFought(context)
if not scythian_units_unlock then
  --IF sarmatians and scythians fight eachother we add +1
  local attacking_faction = context:pending_battle():attacker():faction()
  local defending_faction = context:pending_battle():defender():faction()
if ((defending_faction:name() == "rom_aorsoi" or defending_faction:name() == "rom_siraces" or defending_faction:name() == "rom_roxolani")
and (attacking_faction:name() == "rom_budini" or attacking_faction:name() == "rom_catiaroi" or attacking_faction:name() == "rom_scythia"))
then scythian_saramatian_battles_fought = scythian_saramatian_battles_fought + 1
  Log("pending battle between:"..context:pending_battle():attacker():faction():name().." v "..context:pending_battle():defender():faction():name())
  Log("Number of Battles fought"..scythian_saramatian_battles_fought)
return
elseif ((attacking_faction:name() == "rom_siraces" or attacking_faction:name() == "rom_aorsoi" or attacking_faction:name() == "rom_roxolani")
and (defending_faction:name() == "rom_budini" or defending_faction:name() == "rom_catiaroi" or defending_faction:name() == "rom_scythia"))
then scythian_saramatian_battles_fought = scythian_saramatian_battles_fought + 1
  Log("pending battle between:"..context:pending_battle():attacker():faction():name().." v "..context:pending_battle():defender():faction():name())
  Log("Number of Battles fought"..scythian_saramatian_battles_fought)
return
end
end
end

--============================
-- Getae Reform

-- GetaeFirstTurnSetup
-- GetaePlayerInfo
-- GetaeReform
-- getaecounter
--============================

-- called once to restrict the Reform Units
local function GetaeReform(context)
local current_faction = context.string

-- GetaeFirstTurnSetup
  if current_faction == "rom_getae" then
    local turn_num = scripting.game_interface:model():turn_number()

    if not getae_first_turn_setup
      and turn_num >= 1 then
          for i = 1, #getae_restricted_units do
            local units = getae_restricted_units[i]
            scripting.game_interface:add_event_restricted_unit_record(units)
          end
        getae_first_turn_setup = true
        Log("Getae Reform Units locked")
    end

    if context:faction():is_human() then

    -- this function is used to create a message about the reform for the player
      if turn_num == 2
        then scripting.game_interface:show_message_event("custom_event_501", 0, 0)
      end

    -- main functions for the getae reform
      if not getae_reform_successful then
          CheckGetaeReform(current_faction, turn_num)
          Log("CheckGetaeReform")

        if getae_reform_counter_start then
          CheckGetaeReformCounter()
          Log("CheckGetaeReformCounter")
        end
      end

      if getae_reform_counter == 1
        then effect.advance_contextual_advice_thread("getae.10.turns", 1, context);
      elseif getae_reform_counter == 5
        then effect.advance_contextual_advice_thread("getae.5.turns", 1, context);
      end

      if getae_reform_successful
        and getae_units_unlock == false then
        setGetaeUnits()
      end

      -- Reform Message
      if getae_units_unlock
        and not getae_player_info
          then scripting.game_interface:show_message_event("custom_event_502", 0, 0)
        Log("Player Message displayed");
        getae_player_info = true
      end

    elseif context:faction():is_human() == false then

      if not getae_units_unlock
        and turn_num >= 130  -- AI reforms, set global var
          then setGetaeUnits()
      end
    end
  end
end

function CheckGetaeReform(current_faction, turn_num)
    if turn_num >= 100
	  and getae_battles_fought >= 10
        then getae_reform_counter_start = true;
        Log("getae Reform Counter start");
      else getae_reform_counter_start = false;
           getae_reform_counter = 0
          Log("ReformCounter: Reset to ("..getae_reform_counter..")");
    end
end

function CheckGetaeReformCounter()
  if getae_reform_counter  >= 10 -- global VAR please !!!!
    then getae_reform_successful = true
    Log("getae Reform successful");

  else getae_reform_counter = getae_reform_counter + 1
    Log("ReformCounter: New Number achieved! ("..getae_reform_counter..")");
  end
end

function setGetaeUnits()
  for i = 1, #getae_reform_units do
    local units = getae_reform_units[i]
    scripting.game_interface:remove_event_restricted_unit_record(units)
  end
    getae_units_unlock = true
    Log("getae Reform Units unlocked")
end

-- Reform Message
local function GlobalMessageGetae(context)
local current_faction = context.string
  if getae_units_unlock
    and context:faction():is_human() == true
    and not getae_global_info
    and current_faction ~= "rom_getae"
      then scripting.game_interface:show_message_event("custom_event_503", 0, 0)
      Log("Global Message displayed");
      getae_global_info = true
      getae_player_info = true
  end
end


local function getaeCollectBattlesFought(context)
if not getae_units_unlock then
  local attacking_faction = context:pending_battle():attacker():faction()
  local defending_faction = context:pending_battle():defender():faction()
if ((attacking_faction:name() == "rom_getae" or attacking_faction:name() == "gen_getae")
and (defending_faction:name() == "gen_rome" or defending_faction:name() == "rom_rome"))
then getae_battles_fought = getae_battles_fought + 1
  Log("pending battle between:"..context:pending_battle():attacker():faction():name().." v "..context:pending_battle():defender():faction():name())
  Log("Number of Battles fought"..getae_battles_fought)
return
elseif ((attacking_faction:name() == "rom_rome" or attacking_faction:name() == "gen_rome")
and (defending_faction:name() == "rom_getae" or defending_faction:name() == "gen_getae"))
then getae_battles_fought = getae_battles_fought + 1
  Log("pending battle between:"..context:pending_battle():attacker():faction():name().." v "..context:pending_battle():defender():faction():name())
  Log("Number of Battles fought"..getae_battles_fought)
return
end
end
end

--============================
-- Maurya Reform

-- MauryaFirstTurnSetup
-- MauryaPlayerInfo
-- MauryaReform
-- mauryacounter
--============================

-- called once to restrict the Reform Units
local function MauryaReform(context)
local current_faction = context.string

-- MauryaFirstTurnSetup
  if current_faction == "rom_maurya" then
    local turn_num = scripting.game_interface:model():turn_number()

    if not maurya_first_turn_setup
      and turn_num >= 1 then
          for i = 1, #maurya_restricted_units do
            local units = maurya_restricted_units[i]
            scripting.game_interface:add_event_restricted_unit_record(units)
          end
        maurya_first_turn_setup = true
        Log("Maurya Reform Units locked")
    end

    if context:faction():is_human() then

    -- this function is used to create a message about the reform for the player
      if turn_num == 2
        then scripting.game_interface:show_message_event("custom_event_530", 0, 0)
      end

    -- main functions for the maurya reform
      if not maurya_reform_successful then
          CheckMauryaReform(current_faction, turn_num)
          Log("CheckMauryaReform")

        if maurya_reform_counter_start then
          CheckMauryaReformCounter()
          Log("CheckMauryaReformCounter")
        end
      end

      if maurya_reform_counter == 1
        then effect.advance_contextual_advice_thread("maurya.10.turns", 1, context);
      elseif maurya_reform_counter == 5
        then effect.advance_contextual_advice_thread("maurya.5.turns", 1, context);
      end

      if maurya_reform_successful
        and maurya_units_unlock == false then
        setMauryaUnits()
      end

      -- Reform Message
      if maurya_units_unlock
        and not maurya_player_info
          then scripting.game_interface:show_message_event("custom_event_531", 0, 0)
        Log("Player Message displayed");
        maurya_player_info = true
      end

    elseif context:faction():is_human() == false then

      if not maurya_units_unlock
        and turn_num >= 130  -- AI reforms, set global var
          then setMauryaUnits()
      end
    end
  end
end

function CheckMauryaReform(current_faction, turn_num)
    if turn_num >= 100
	  and maurya_battles_fought >= 10
        then maurya_reform_counter_start = true;
        Log("maurya Reform Counter start");
      else maurya_reform_counter_start = false;
           maurya_reform_counter = 0
          Log("ReformCounter: Reset to ("..maurya_reform_counter..")");
    end
end

function CheckMauryaReformCounter()
  if maurya_reform_counter  >= 10 -- global VAR please !!!!
    then maurya_reform_successful = true
    Log("maurya Reform successful");

  else maurya_reform_counter = maurya_reform_counter + 1
    Log("ReformCounter: New Number achieved! ("..maurya_reform_counter..")");
  end
end

function setMauryaUnits()
  for i = 1, #maurya_reform_units do
    local units = maurya_reform_units[i]
    scripting.game_interface:remove_event_restricted_unit_record(units)
  end
    maurya_units_unlock = true
    Log("maurya Reform Units unlocked")
end

-- Reform Message
local function GlobalMessageMaurya(context)
local current_faction = context.string
  if maurya_units_unlock
    and context:faction():is_human() == true
    and not maurya_global_info
    and current_faction ~= "rom_maurya"
      then scripting.game_interface:show_message_event("custom_event_532", 0, 0)
      Log("Global Message displayed");
      maurya_global_info = true
      maurya_player_info = true
  end
end


local function mauryaCollectBattlesFought(context)
if not maurya_units_unlock then
  local attacking_faction = context:pending_battle():attacker():faction()
  local defending_faction = context:pending_battle():defender():faction()
if ((attacking_faction:name() == "rom_maurya")
and (defending_faction:name() == "gen_baktria" or defending_faction:name() == "rom_baktria"))
then maurya_battles_fought = maurya_battles_fought + 1
  Log("pending battle between:"..context:pending_battle():attacker():faction():name().." v "..context:pending_battle():defender():faction():name())
  Log("Number of Battles fought"..maurya_battles_fought)
return
elseif ((attacking_faction:name() == "gen_baktria" or attacking_faction:name() == "rom_baktria")
and (defending_faction:name() == "rom_maurya"))
then maurya_battles_fought = maurya_battles_fought + 1
  Log("pending battle between:"..context:pending_battle():attacker():faction():name().." v "..context:pending_battle():defender():faction():name())
  Log("Number of Battles fought"..maurya_battles_fought)
return
end
end
end

--============================
-- Media Reform

--============================

-- called once to restrict the Reform Units
local function MediaReform(context)
local current_faction = context.string

-- MediaFirstTurnSetup
  if current_faction == "rom_media_atropatene" then
    local turn_num = scripting.game_interface:model():turn_number()

    if not media_first_turn_setup
      and turn_num >= 1 then
          for i = 1, #media_restricted_units do
            local units = media_restricted_units[i]
            scripting.game_interface:add_event_restricted_unit_record(units)
          end
        media_first_turn_setup = true
        Log("Media Reform Units locked")
    end

    if context:faction():is_human() then

    -- this function is used to create a message about the reform for the media player
      if turn_num == 3
        then scripting.game_interface:show_message_event("custom_event_8001", 0, 0)
      end

    -- main functions for the media reform
	if not media_reform_successful1 then
          CheckMediaReform1(current_faction, turn_num)
          Log("CheckMediaReform1")

        if media_reform_counter_start1 then
          CheckMediaReformCounter1()
          Log("CheckMediaReformCounter1")
        end
      end
	  
      if not media_reform_successful then
          CheckMediaReform(current_faction, turn_num)
          Log("CheckMediaReform")

        if media_reform_counter_start then
          CheckMediaReformCounter()
          Log("CheckMediaReformCounter")
        end
      end

	  if media_reform_counter1  == 1
        then effect.advance_contextual_advice_thread("Media.10.turns1", 1, context);
      elseif media_reform_counter1  == 5
        then effect.advance_contextual_advice_thread("Media.5.turns1", 1, context);
      end

      if media_reform_successful1
        and media_units_unlock1 == false then
        setMediaUnits1()
      end
	  
      if media_reform_counter  == 1
        then effect.advance_contextual_advice_thread("Media.10.turns", 1, context);
      elseif media_reform_counter  == 5
        then effect.advance_contextual_advice_thread("Media.5.turns", 1, context);
      end

      if media_reform_successful
        and media_units_unlock == false then
        setMediaUnits()
      end

      -- Reform Message
	  if media_units_unlock1
        and not media_player_info1
          then scripting.game_interface:show_message_event("custom_event_80021", 0, 0)
        Log("Player Message displayed");
        media_player_info1 = true
      end
	  
      if media_units_unlock
        and not media_player_info
          then scripting.game_interface:show_message_event("custom_event_8002", 0, 0)
        Log("Player Message displayed");
        media_player_info = true
      end

    elseif context:faction():is_human() == false then
		
	 if not media_units_unlock1
        and turn_num >= 65  -- AI reforms, set global var
          then setMediaUnits1()
      end
	  
      if not media_units_unlock
        and turn_num >= 205  -- AI reforms, set global var
          then setMediaUnits()
      end
    end
  end
end

function CheckMediaReform1(current_faction, turn_num)
    if turn_num >= 55
        then media_reform_counter_start1 = true;
        Log("Media Reform Counter start1");
      else media_reform_counter_start1 = false;
           media_reform_counter1 = 0
          Log("Media ReformCounter1: Reset to ("..media_reform_counter1..")");
    end
end

function CheckMediaReform(current_faction, turn_num)
local region_persis_persepolis = scripting.game_interface:model():world():region_manager():region_by_key("emp_persis_persepolis")
    local owner_persis_persepolis = region_persis_persepolis:owning_faction():name()

    local region_parthia_nisa = scripting.game_interface:model():world():region_manager():region_by_key("emp_parthia_nisa")
    local owner_parthia_nisa = region_parthia_nisa:owning_faction():name()

    local region_mesop_ctes = scripting.game_interface:model():world():region_manager():region_by_key("emp_mesopotamia_ctesiphon")
    local owner_mesop_ctes = region_mesop_ctes:owning_faction():name()


    if owner_persis_persepolis == current_faction
      and owner_parthia_nisa == current_faction
      and owner_mesop_ctes == current_faction
	  and turn_num >= 201
        then media_reform_counter_start = true;
        Log("Media Reform Counter start");
      else media_reform_counter_start = false;
           media_reform_counter = 0
          Log("Media ReformCounter: Reset to ("..media_reform_counter..")");
    end
end

function CheckMediaReformCounter1()
  if media_reform_counter1  >= 10 -- global VAR please !!!!
    then media_reform_successful1 = true
    Log("Media Reform successful1");

  else media_reform_counter1 = media_reform_counter1 + 1
    Log("Media ReformCounter1: New Number achieved! ("..media_reform_counter1..")");
  end
end

function CheckMediaReformCounter()
  if media_reform_counter  >= 10 -- global VAR please !!!!
    then media_reform_successful = true
    Log("Media Reform successful");

  else media_reform_counter = media_reform_counter + 1
    Log("Media ReformCounter: New Number achieved! ("..media_reform_counter..")");
  end
end

function setMediaUnits1()
  for i = 1, #media_reform_units1 do
    local units = media_reform_units1[i]
    scripting.game_interface:remove_event_restricted_unit_record(units)
  end
    media_units_unlock1 = true
    Log("Media Reform Units unlocked1")
end

function setMediaUnits()
  for i = 1, #media_reform_units do
    local units = media_reform_units[i]
    scripting.game_interface:remove_event_restricted_unit_record(units)
  end
    media_units_unlock = true
    Log("Media Reform Units unlocked")
end

-- Reform Message
local function GlobalMessageMedia(context)
local current_faction = context.string
 if media_units_unlock1
    and context:faction():is_human() == true
    and not media_global_info1
    and current_faction ~= "rom_media_atropatene"
      then scripting.game_interface:show_message_event("custom_event_80032", 0, 0)
      Log("Global Message displayed1");
      media_global_info1 = true
      media_player_info1 = true
  end
  if media_units_unlock
    and context:faction():is_human() == true
    and not media_global_info
    and current_faction ~= "rom_media_atropatene"
      then scripting.game_interface:show_message_event("custom_event_8003", 0, 0)
      Log("Global Message displayed");
      media_global_info = true
      media_player_info = true
  end
end


----SAVE/LOAD


local function OnSavingSaka(context)
  scripting.game_interface:save_named_value("saka_reform_successful", saka_reform_successful, context)
  scripting.game_interface:save_named_value("saka_reform_counter_start", saka_reform_counter_start, context)
  scripting.game_interface:save_named_value("saka_reform_counter", saka_reform_counter, context)
  scripting.game_interface:save_named_value("scythian_saramatian_battles_fought", scythian_saramatian_battles_fought, context)
  scripting.game_interface:save_named_value("saka_units_unlock", saka_units_unlock, context)
  scripting.game_interface:save_named_value("saka_global_info", saka_global_info, context)
  scripting.game_interface:save_named_value("saka_first_turn_setup", saka_first_turn_setup, context)
  scripting.game_interface:save_named_value("saka_player_info", saka_player_info, context)
  scripting.game_interface:save_named_value("scythian_units_unlock", scythian_units_unlock, context)
  scripting.game_interface:save_named_value("scythian_player_info", scythian_player_info, context)
  scripting.game_interface:save_named_value("scythian_first_turn_setup", scythian_first_turn_setup, context)
  scripting.game_interface:save_named_value("scythian_global_info", scythian_global_info, context)
  scripting.game_interface:save_named_value("scythian_reform_go", scythian_reform_go, context)
  scripting.game_interface:save_named_value("getae_reform_successful", getae_reform_successful, context)
  scripting.game_interface:save_named_value("getae_reform_counter_start", getae_reform_counter_start, context)
  scripting.game_interface:save_named_value("getae_reform_counter", getae_reform_counter, context)
  scripting.game_interface:save_named_value("getae_battles_fought", getae_battles_fought, context)
  scripting.game_interface:save_named_value("getae_units_unlock", getae_units_unlock, context)
  scripting.game_interface:save_named_value("getae_global_info", getae_global_info, context)
  scripting.game_interface:save_named_value("getae_first_turn_setup", getae_first_turn_setup, context)
  scripting.game_interface:save_named_value("getae_player_info", getae_player_info, context)
   scripting.game_interface:save_named_value("maurya_reform_successful", maurya_reform_successful, context)
  scripting.game_interface:save_named_value("maurya_reform_counter_start", maurya_reform_counter_start, context)
  scripting.game_interface:save_named_value("maurya_reform_counter", maurya_reform_counter, context)
  scripting.game_interface:save_named_value("maurya_battles_fought", maurya_battles_fought, context)
  scripting.game_interface:save_named_value("maurya_units_unlock", maurya_units_unlock, context)
  scripting.game_interface:save_named_value("maurya_global_info", maurya_global_info, context)
  scripting.game_interface:save_named_value("maurya_first_turn_setup", maurya_first_turn_setup, context)
  scripting.game_interface:save_named_value("maurya_player_info", maurya_player_info, context)
    scripting.game_interface:save_named_value("media_reform_successful", media_reform_successful, context)
  scripting.game_interface:save_named_value("media_reform_counter_start", media_reform_counter_start, context)
  scripting.game_interface:save_named_value("media_reform_counter", media_reform_counter, context)
  scripting.game_interface:save_named_value("media_units_unlock", media_units_unlock, context)
  scripting.game_interface:save_named_value("media_global_info", media_global_info, context)
  scripting.game_interface:save_named_value("media_first_turn_setup", media_first_turn_setup, context)
  scripting.game_interface:save_named_value("media_player_info", media_player_info, context)
   scripting.game_interface:save_named_value("media_reform_successful1", media_reform_successful1, context)
  scripting.game_interface:save_named_value("media_reform_counter_start1", media_reform_counter_start1, context)
  scripting.game_interface:save_named_value("media_reform_counter1", media_reform_counter1, context)
  scripting.game_interface:save_named_value("media_units_unlock1", media_units_unlock1, context)
  scripting.game_interface:save_named_value("media_global_info1", media_global_info1, context)
  scripting.game_interface:save_named_value("media_player_info1", media_player_info1, context)
end

local function OnLoadingSaka(context)
  saka_reform_successful = scripting.game_interface:load_named_value("saka_reform_successful", false, context)
  saka_reform_counter_start = scripting.game_interface:load_named_value("saka_reform_counter_start", false, context)
  saka_reform_counter = scripting.game_interface:load_named_value("saka_reform_counter", 0, context)
  scythian_saramatian_battles_fought = scripting.game_interface:load_named_value("scythian_saramatian_battles_fought", 0, context)
  saka_units_unlock = scripting.game_interface:load_named_value("saka_units_unlock", false, context)
  saka_global_info = scripting.game_interface:load_named_value("saka_global_info", false, context)
  saka_player_info = scripting.game_interface:load_named_value("saka_player_info", false, context)
  saka_first_turn_setup = scripting.game_interface:load_named_value("saka_first_turn_setup", false, context)
  scythian_units_unlock = scripting.game_interface:load_named_value("scythian_units_unlock", false, context)
  scythian_global_info = scripting.game_interface:load_named_value("scythian_global_info", false, context)
  scythian_player_info = scripting.game_interface:load_named_value("scythian_player_info", false, context)
  scythian_first_turn_setup = scripting.game_interface:load_named_value("scythian_first_turn_setup", false, context)
  scythian_reform_go = scripting.game_interface:load_named_value("scythian_reform_go", false, context)
  getae_reform_successful = scripting.game_interface:load_named_value("getae_reform_successful", false, context)
  getae_reform_counter_start = scripting.game_interface:load_named_value("getae_reform_counter_start", false, context)
  getae_reform_counter = scripting.game_interface:load_named_value("getae_reform_counter", 0, context)
  getae_battles_fought = scripting.game_interface:load_named_value("getae_battles_fought", 0, context)
  getae_units_unlock = scripting.game_interface:load_named_value("getae_units_unlock", false, context)
  getae_global_info = scripting.game_interface:load_named_value("getae_global_info", false, context)
  getae_player_info = scripting.game_interface:load_named_value("getae_player_info", false, context)
  getae_first_turn_setup = scripting.game_interface:load_named_value("getae_first_turn_setup", false, context)
   maurya_reform_successful = scripting.game_interface:load_named_value("maurya_reform_successful", false, context)
  maurya_reform_counter_start = scripting.game_interface:load_named_value("maurya_reform_counter_start", false, context)
  maurya_reform_counter = scripting.game_interface:load_named_value("maurya_reform_counter", 0, context)
  maurya_battles_fought = scripting.game_interface:load_named_value("maurya_battles_fought", 0, context)
  maurya_units_unlock = scripting.game_interface:load_named_value("maurya_units_unlock", false, context)
  maurya_global_info = scripting.game_interface:load_named_value("maurya_global_info", false, context)
  maurya_player_info = scripting.game_interface:load_named_value("maurya_player_info", false, context)
  maurya_first_turn_setup = scripting.game_interface:load_named_value("maurya_first_turn_setup", false, context)
    media_reform_successful = scripting.game_interface:load_named_value("media_reform_successful", false, context)
  media_reform_counter_start = scripting.game_interface:load_named_value("media_reform_counter_start", false, context)
  media_reform_counter = scripting.game_interface:load_named_value("media_reform_counter", 0, context)
  media_units_unlock = scripting.game_interface:load_named_value("media_units_unlock", false, context)
  media_global_info = scripting.game_interface:load_named_value("media_global_info", false, context)
  media_player_info = scripting.game_interface:load_named_value("media_player_info", false, context)
  media_first_turn_setup = scripting.game_interface:load_named_value("media_first_turn_setup", false, context)
     media_reform_successful1 = scripting.game_interface:load_named_value("media_reform_successful1", false, context)
  media_reform_counter_start1 = scripting.game_interface:load_named_value("media_reform_counter_start1", false, context)
  media_reform_counter1 = scripting.game_interface:load_named_value("media_reform_counter1", 0, context)
  media_units_unlock1 = scripting.game_interface:load_named_value("media_units_unlock1", false, context)
  media_global_info1 = scripting.game_interface:load_named_value("media_global_info1", false, context)
  media_player_info1 = scripting.game_interface:load_named_value("media_player_info1", false, context)
end

--------------------------------------------------------------------------------------
scripting.AddEventCallBack("LoadingGame", OnLoadingSaka)
scripting.AddEventCallBack("SavingGame", OnSavingSaka)
scripting.AddEventCallBack("FactionTurnStart", SakaReform)
scripting.AddEventCallBack("FactionTurnStart", ScythianReform)
scripting.AddEventCallBack("FactionTurnStart", GlobalMessage)
scripting.AddEventCallBack("PendingBattle", ScythianCollectBattlesFought)
scripting.AddEventCallBack("FactionTurnStart", GetaeReform)
scripting.AddEventCallBack("FactionTurnStart", GlobalMessageGetae)
scripting.AddEventCallBack("PendingBattle", getaeCollectBattlesFought)
scripting.AddEventCallBack("FactionTurnStart", MauryaReform)
scripting.AddEventCallBack("FactionTurnStart", GlobalMessageMaurya)
scripting.AddEventCallBack("PendingBattle", mauryaCollectBattlesFought)
scripting.AddEventCallBack("FactionTurnStart", MediaReform)
scripting.AddEventCallBack("FactionTurnStart", GlobalMessageMedia)
--------------------------------------------------------------------------------------
