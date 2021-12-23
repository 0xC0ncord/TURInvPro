//=============================================================================
// InvasionPro.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//=======================================================
//InvasionPro Copyright � Shaun Goeppinger 2009 - 2012
//=======================================================
class InvasionPro extends Invasion config(TURInvPro);

const Version = $$__VERSION__$$;

const BOSS_WAIT_TIMER_DEFAULT       = 8;
const BOSS_TRANSITION_TIMER_DEFAULT = 8;

var() config string BossConfigMenu; //the ingame boss config menu
var() config string MonsterStatsConfigMenu; //the ingame monster stats menu
var() config string MonsterConfigMenu; //the ingame monster config menu
var() config string InvasionProConfigMenu; //main menu
var() const localized string InvasionProGroup; //new in game menu group
var() config bool bSpawnAtBases;
var() config bool bPermitVehicles;
var() config bool bHideRadar;
var() config bool bHidePlayerList;
var() config bool bHideMonsterCount;
var() config bool bAllowHitSounds;

var() config Object MonsterStats; //config holder for monster stats, setting this does nothing
var() config Object Monsters; //config holder for monster configs, setting this does nothing
var() config Object Waves; //waves information which is updated via the wave config menu, this is just a holder
var() config Object Bosses; //boss information which is updated via the wave config menu, this is just a holder
var() config Object InvasionProSettings;

var() config int TotalSpawned;  //the sum of all monsters ever spawned of all types
var() config int TotalDamage; //the sum of all damage every monster ever caused
var() config int TotalKills; //the sum of all kills every monster ever caused
var() config int TotalGames; //the number of games played
var() config string BestMonster; //the monster type that has the highest combined damage + kills
var() config string WorstMonster; //the monster type that has the lowest combined damage + kills
var() config string CommonMonster; //the monster that has spawned the most
var() config string RareMonster; //the least spawned monster
var() config int LastWave; //the new FinalWave variable
var() config int StartWave; //the new InitialWave variable
var() config bool bShareBossPoints;
var() config int SpawnProtection;
var() config bool bPreloadMonsters;
var() config bool bAerialView;
var() config int TeamSpawnGameRadius;
var() config String MonsterStartTag;
var() config String PlayerStartTag;
var() config int WaveNameDuration;
var() config int MonsterSpawnDistance;
var() config color WaveCountDownColour;
var() array<NavigationPoint> PlayerStartNavList;  //list of start locations for players
var() array<NavigationPoint> MonsterStartNavList; //list of start locations for monsters
var() NavigationPoint OldNode;
var() config string CustomGameTypePrefix;
var() float LastBossSpawnTime;

var() int MonsterTeamScore; //just a score for fun that is displayed if you spectate a monster
var() bool bBossWave; //is this a boss wave that is in progress
var() bool bBossWaiting; //true when the game is preparing a boss (for setting up warning message, etc.)
var() byte BossWaitTimer; //time to dictate between the warning of a boss and its actual spawn
var() byte BossTransitionTimer; //a simple timer to dictate wait time between bosses instead of spawning them immediately one after another
var() bool bBossTime; //true when the boss portion of the wave is active
var() bool bBossActive; //true when boss has spawned
var() bool bBossFinished; //true when all bosses have been killed
var() bool bBossesSpawnTogether;
var() bool bSpawnBossWithMonsters; //boss will spawn at beginning of wave alongside regular monsters; overrides wave time limit and wave max monsters
var() bool bAdvanceWaveWhenBossKilled; //when boss dies, wave is over
var() bool bBossDeathKillsMonsters; //when boss dies, all other monsters die
var() bool bTryingFallbackBoss;    //attempting to spawn fallback boss
var() float FallBackTimer;
var() bool bIgnoreFallback; //if one boss has spawned, dont fallback if others fail
var() bool bInfiniteBossTime;
var() class<Monster> WaveMonsterClass[__INVPRO_MAX_WAVE_MONSTERS__];
var() int WaveID;
var() int BossID;
var() int WaveMaxMonsters;
var() float MonstersPerPlayerCurve;
var() int MaxMonstersPerPlayer; //calculated variable for max monsters per player for this wave
var() int NumKilledMonsters; //how many monsters have died on the wave so far
var() int LastKilledMonsterScore;

var() array<int> WaveTable;
var() array<int> BossTable;

var() PlayerReplicationInfo FriendlyMonsterInfo;
var() Actor CollisionTestActor;
var() Color VehicleLockedMessageColour;
var() string CurrentMapPrefix;

var() config bool bIncludeSummons;
var() config bool bWaveTimeLimit;
var() config bool bWaveMonsterLimit;

struct WaveBoss
{
   var() int BossID;
   var() int FallbackBossID;
   var() int SpawnID;
};
var array<WaveBoss> WaveBossID;
var() float BossTimeLimit;
var() int OverTimeDamage;
var() config float OverTimeDamageIncreaseFraction; //percentage by which overtimedamage increases exponentially every second
var() bool bUseMonsterStartTag;
var() bool bUsePlayerStartTag;
var() byte BossSetupNum;

var() config bool bDoEffectSpawns; //do the spiraly spawning effect
var() config bool bMonstersAlwaysRelevant; //set bAlwaysRelevant to true on all monsters show they show up on the radar at all times
var() config bool bRateMonsterSpawns; //attempt to rate monster spawns based on how far away from players they are
var() config array<string> SuperWeaponClassNames;
var() config bool bCullMonsters;
var() config array<string> AdditionalPreloads; //list of class names for other objects (besides monsters in the monster table) that should be preloaded
var() config bool bNoTeamBoost; //players cannot shove each other which momentum fire

// internals
var() int CurrentBeamIns; //number of monster spawn effects on the map (so we don't overspawn monsters)
var() array<class<Weapon> > SuperWeaponClasses;
var() bool bHaltWaveProgression; //waves will stop advancing while this is true
var() array<NavigationPoint> MonsterSpawnSpots;
var() array<NavigationPoint> FlyingMonsterSpawnSpots;
var() array<name> WaveTags;
var() byte BossWarnStringCount;
var() InvasionProMutator InvProMut;
var() float WaveStartTime;
var() array<Controller> RevivedPlayers;
var() array<string> ReducedPreloadList;

event InitGame( string Options, out string Error )
{
   local int i, x, y, z, j;
   local bool bAlreadyExists, bFound;
   local class<Weapon> LoadedWeapon;
   local NavigationPoint N;
   local array<string> Possibles, IDs;

   if(CustomGameTypePrefix != "" && CustomGameTypePrefix != "None")
       MapPrefix = "DM,BR,CTF,AS,DOM,ONS,VCTF,"$CustomGameTypePrefix;

   TotalGames++;
   Super(xTeamGame).InitGame(Options, Error);
   bForceRespawn = true;

   for(i = 0; i < SuperWeaponClassNames.Length; i++)
   {
       LoadedWeapon = None;

       LoadedWeapon = class<Weapon>(DynamicLoadObject(SuperWeaponClassNames[i], class'Class'));
       if(LoadedWeapon != None)
           SuperWeaponClasses[SuperWeaponClasses.Length] = LoadedWeapon;
       else
           Log("SuperWeaponClassNames[" $ i $ "] could not be resolved.", 'InvasionPro');
   }

   for(N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
   {
       if(Door(N) == None && InventorySpot(N) == None && LiftExit(N) == None && LiftCenter(N) == None && Teleporter(N) == None)
       {
           if(FlyingPathNode(N) == None)
           {
               MonsterSpawnSpots[MonsterSpawnSpots.Length] = N;
               FlyingMonsterSpawnSpots[FlyingMonsterSpawnSpots.Length] = N;
           }
           else
               FlyingMonsterSpawnSpots[FlyingMonsterSpawnSpots.Length] = N;
       }
   }

   //load valid waves for the wave table
   for(i = 0; i < class'InvasionProConfigs'.default.Waves.Length; i++)
   {
       x = class'InvasionProConfigs'.default.Waves[i].WaveVariant - 1;
       if(x <= -1)
           continue;
       if(x >= Possibles.Length)
           Possibles.Length = x + 1;
       if(Possibles[x] == "")
       {
           Possibles[x] = string(i);
           continue;
       }
       Possibles[x] $= "," $ string(i);
   }

   //populate the wave table
   WaveTable.Length = LastWave + 1;
   for(i = 0; i < LastWave + 1; i++)
   {
       if(i >= Possibles.Length || Possibles[i] == "")
       {
           Warn("No wave variant found for wave" @ string(i + 1) @ "when constructing wave table! Using Wave ID 0 as fallback!");
           WaveTable[i] = 0;
           continue;
       }
       Split(Possibles[i], ",", IDs);
       WaveTable[i] = int(IDs[Rand(IDs.Length)]);
   }

   //load valid bosses for the boss table
   Possibles.Remove(0, Possibles.Length);
   for(i = 0; i < class'InvasionProConfigs'.default.BossTable.Length; i++)
   {
       x = class'InvasionProConfigs'.default.BossTable[i].WaveVariant - 1;
       if(class'InvasionProConfigs'.default.Waves[WaveTable[x]].bOverrideBoss)
       {
           if(Possibles[x] == "")
           {
               Possibles[x] = "0";
               continue;
           }
       }
       if(x <= -1)
           continue;
       if(x >= Possibles.Length)
           Possibles.Length = x + 1;
       if(Possibles[x] == "")
       {
           Possibles[x] = string(i);
           continue;
       }
       Possibles[x] $= "," $ string(i);
   }

   //populate the boss table
   BossTable.Length = LastWave + 1;
   for(i = 0; i < LastWave + 1; i++)
   {
       if(class'InvasionProConfigs'.default.Waves[WaveTable[i]].bOverrideBoss)
       {
           BossTable[i] = 0;
           continue;
       }
       if(i >= Possibles.Length || Possibles[i] == "")
       {
           BossTable[i] = -1;
           continue;
       }
       Split(Possibles[i], ",", IDs);
       BossTable[i] = int(IDs[Rand(IDs.Length)]);
   }

   //populate the preload lists
   for(i = 0; i < LastWave + 1; i++)
   {
       for(x = 0; x < __INVPRO_MAX_WAVE_MONSTERS__; x++)
       {
           if(class'InvasionProConfigs'.default.Waves[WaveTable[i]].Monsters[x] == "None")
               continue;
           if(bFound)
               bFound = false;
           for(y = 0; y < class'InvasionProMonsterTable'.default.MonsterTable.Length; y++)
           {
               if(class'InvasionProMonsterTable'.default.MonsterTable[y].MonsterName == class'InvasionProConfigs'.default.Waves[WaveTable[i]].Monsters[x])
               {
                   bFound = true;
                   j = y;
                   y = class'InvasionProMonsterTable'.default.MonsterTable.Length;
               }
           }
           if(bFound)
           {
               if(bAlreadyExists)
                   bAlreadyExists = false;
               for(z = 0; z < ReducedPreloadList.Length; z++)
               {
                   if(ReducedPreloadList[z] == class'InvasionProMonsterTable'.default.MonsterTable[j].MonsterClassName)
                   {
                       bAlreadyExists = true;
                       z = ReducedPreloadList.Length;
                   }
               }
               if(!bAlreadyExists)
                   ReducedPreloadList[ReducedPreloadList.Length] = class'InvasionProMonsterTable'.default.MonsterTable[j].MonsterClassName;
           }
       }
   }
}

function AddGameSpecificInventory(Pawn P)
{
    if (AllowTransloc())
        P.CreateInventory(string(class'TURTranslauncher'));
    Super(UnrealMPGameInfo).AddGameSpecificInventory(P);
}

function UpdateMonsterStats()
{
   BestMonster = CalculateBestMonster();
   WorstMonster = CalculateWorstMonster();
   CommonMonster = CalculateCommonMonster();
   RareMonster = CalculateRareMonster();
   SaveConfig();
}

function string CalculateBestMonster()
{
   local int i;
   local string CurrentBestMonster;
   local int TotalScore;
   local int CurrentBestScore;

   TotalScore = 0;
   CurrentBestScore = 0;

   for(i=0;i<class'InvasionProMonsterTable'.default.MonsterTable.Length;i++)
   {
       TotalScore = class'InvasionProMonsterTable'.default.MonsterTable[i].NumDamage + class'InvasionProMonsterTable'.default.MonsterTable[i].NumKills;

       if(TotalScore > CurrentBestScore)
       {
           CurrentBestScore = TotalScore;
           CurrentBestMonster = class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterClassName;
       }
   }

   return CurrentBestMonster;
}

function string CalculateWorstMonster()
{
   local int i;
   local string CurrentWorstMonster;
   local int TotalScore;
   local int CurrentWorstScore;

   TotalScore = 0;
   CurrentWorstScore = 0;

   for(i=0;i<class'InvasionProMonsterTable'.default.MonsterTable.Length;i++)
   {
       TotalScore = class'InvasionProMonsterTable'.default.MonsterTable[i].NumDamage + class'InvasionProMonsterTable'.default.MonsterTable[i].NumKills;

       if(TotalScore <= CurrentWorstScore)
       {
           CurrentWorstScore = TotalScore;
           CurrentWorstMonster = class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterClassName;
       }
   }

   return CurrentWorstMonster;
}

function string CalculateCommonMonster()
{
   local int i;
   local string CurrentCommonMonster;
   local int BestSpawn;

   BestSpawn = 0;

   for(i=0;i<class'InvasionProMonsterTable'.default.MonsterTable.Length;i++)
   {
       if(BestSpawn < class'InvasionProMonsterTable'.default.MonsterTable[i].NumSpawns)
       {
           BestSpawn = class'InvasionProMonsterTable'.default.MonsterTable[i].NumSpawns;
           CurrentCommonMonster = class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterClassName;
       }
   }

   return CurrentCommonMonster;
}

function string CalculateRareMonster()
{
   local int i;
   local string CurrentRareMonster;
   local int RareSpawn;

   RareSpawn = 100000;

   for(i=0;i<class'InvasionProMonsterTable'.default.MonsterTable.Length;i++)
   {
       if(RareSpawn >= class'InvasionProMonsterTable'.default.MonsterTable[i].NumSpawns)
       {
           RareSpawn = class'InvasionProMonsterTable'.default.MonsterTable[i].NumSpawns;
           CurrentRareMonster = class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterClassName;
       }
   }

   return CurrentRareMonster;
}

function Reset()
{
   UpdateMaxLives();
    Super(xTeamGame).Reset();
}

event PreBeginPlay()
{
   local InvasionProMonsterReplicationInfo IGI;
   local int i;
   local class<Monster> M;
   local string BossNameLeft, BossNameRight;

   Super(xTeamGame).PreBeginPlay();

   if(bPermitVehicles)
   {
       bAllowVehicles = true;
   }

   SetTeamSpawnPoints();
    UpdateMaxLives();
   InitialWave = (StartWave - 1); //update invasions initial wave in case any other mutators need it
    UpdateMonsterStats(); //update monster stats
    WaveNum = (StartWave - 1); //set WaveNum, this is very important, this controls which wave info is returned
    InvasionProGameReplicationInfo(GameReplicationInfo).WaveNumber = WaveNum;
    InvasionProGameReplicationInfo(GameReplicationInfo).BaseDifficulty = int(GameDifficulty);
    GameReplicationInfo.bNoTeamSkins = true;
    GameReplicationInfo.bForceNoPlayerLights = true;
    GameReplicationInfo.bNoTeamChanges = true;
    //update monsters to load so loading bar on the hud is correct
    InvasionProGameReplicationInfo(GameReplicationInfo).NumMonstersToLoad = class'InvasionProMonsterTable'.default.MonsterTable.Length;
   InvasionProGameReplicationInfo(GameReplicationInfo).bAerialView = bAerialView;
   InvasionProGameReplicationInfo(GameReplicationInfo).SpawnProtection = SpawnProtection;
   InvasionProGameReplicationInfo(GameReplicationInfo).bHideRadar = bHideRadar;
   InvasionProGameReplicationInfo(GameReplicationInfo).bHidePlayerList = bHidePlayerList;
   InvasionProGameReplicationInfo(GameReplicationInfo).bHideMonsterCount = bHideMonsterCount;
   InvasionProGameReplicationInfo(GameReplicationInfo).WaveCountDownColour = WaveCountDownColour;

   BossWaitTimer = BOSS_WAIT_TIMER_DEFAULT;
   BossTransitionTimer = BOSS_TRANSITION_TIMER_DEFAULT;

   for(i = 0; i < class'InvasionProConfigs'.default.Waves.Length; i++)
   {
       if(class'InvasionProConfigs'.default.Waves[i].MaxLives > 1)
       {
           InvasionProGameReplicationInfo(GameReplicationInfo).bAlwaysOneLife = false;
           break;
       }
   }

   //spawn and update monster gibsize/gibcount data
   IGI = Spawn(class'InvasionProMonsterReplicationInfo');
   for(i = 0; i < class'InvasionProMonsterTable'.default.MonsterTable.Length; i++)
   {
       IGI.AddMonsterInfo(i, class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterName, class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterClassName, class'InvasionProMonsterTable'.default.MonsterTable[i].NewGibSizeMultiplier, class'InvasionProMonsterTable'.default.MonsterTable[i].NewGibMultiplier);
       //intialize any broken monsters
       if(!class'InvasionProMonsterTable'.default.MonsterTable[i].bSetup)
       {
           M = class<Monster>(DynamicLoadObject(class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterClassName, class'Class',true));
           if(M != None)
           {
                class'InvasionProMonsterTable'.default.MonsterTable[i].NewHealth = M.default.Health;
                class'InvasionProMonsterTable'.default.MonsterTable[i].NewMaxHealth = M.default.HealthMax;
                class'InvasionProMonsterTable'.default.MonsterTable[i].NewGroundSpeed = M.default.GroundSpeed;
                class'InvasionProMonsterTable'.default.MonsterTable[i].NewAirSpeed = M.default.AirSpeed;
                class'InvasionProMonsterTable'.default.MonsterTable[i].NewWaterSpeed = M.default.WaterSpeed;
                class'InvasionProMonsterTable'.default.MonsterTable[i].NewJumpZ = M.default.JumpZ;
                class'InvasionProMonsterTable'.default.MonsterTable[i].NewScoreAward = M.default.ScoringValue;
                class'InvasionProMonsterTable'.default.MonsterTable[i].NewGibMultiplier = 1.0;
                class'InvasionProMonsterTable'.default.MonsterTable[i].NewGibSizeMultiplier = 1.0;
                class'InvasionProMonsterTable'.default.MonsterTable[i].DamageMultiplier = 1.0;
                class'InvasionProMonsterTable'.default.MonsterTable[i].bRandomHealth = false;
                class'InvasionProMonsterTable'.default.MonsterTable[i].bRandomSpeed = false;
                class'InvasionProMonsterTable'.default.MonsterTable[i].bRandomSize = false;
                class'InvasionProMonsterTable'.default.MonsterTable[i].NewDrawScale = M.default.DrawScale;
                class'InvasionProMonsterTable'.default.MonsterTable[i].NewCollisionHeight = M.default.CollisionHeight;
                class'InvasionProMonsterTable'.default.MonsterTable[i].NewCollisionRadius = M.default.CollisionRadius;
                class'InvasionProMonsterTable'.default.MonsterTable[i].NewPrePivot.X = M.default.PrePivot.X;
                class'InvasionProMonsterTable'.default.MonsterTable[i].NewPrePivot.Y = M.default.PrePivot.Y;
                class'InvasionProMonsterTable'.default.MonsterTable[i].NewPrePivot.Z = M.default.PrePivot.Z;
                class'InvasionProMonsterTable'.default.MonsterTable[i].bSetup = true;
           }
           else
               Log("Monster class" @ class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterClassName $ " (#" $ i $ ") in monster table does not resolve to a valid monster class!", 'InvasionPro');
       }
   }

   //intialize any broken bosses and update replication info for gibs
   for(i = 0; i < class'InvasionProConfigs'.default.Bosses.Length; i++)
   {
       IGI.AddBossInfo(i, class'InvasionProConfigs'.default.Bosses[i].BossMonsterName, class'InvasionProConfigs'.default.Bosses[i].BossGibSizeMultiplier, class'InvasionProConfigs'.default.Bosses[i].BossGibMultiplier);
       if(!class'InvasionProConfigs'.default.Bosses[i].bSetup)
       {
           M = class<Monster>(DynamicLoadObject(class'InvasionProConfigs'.default.Bosses[i].BossMonsterName, class'Class',true));
           if(M != None)
           {
                Divide(string(M.Class), ".", BossNameLeft, BossNameRight);
                class'InvasionProConfigs'.default.Bosses[i].BossHealth = M.default.Health;
                class'InvasionProConfigs'.default.Bosses[i].BossName = ("Boss (" $ BossNameRight) $ ")";
                class'InvasionProConfigs'.default.Bosses[i].BossScoreAward = M.default.ScoringValue;
                class'InvasionProConfigs'.default.Bosses[i].BossDamageMultiplier = 1.0;
                class'InvasionProConfigs'.default.Bosses[i].BossGibSizeMultiplier = 1.0;
                class'InvasionProConfigs'.default.Bosses[i].BossGibMultiplier = 1.0;
                class'InvasionProConfigs'.default.Bosses[i].BossGroundSpeed = M.default.GroundSpeed;
                class'InvasionProConfigs'.default.Bosses[i].BossAirSpeed = M.default.AirSpeed;
                class'InvasionProConfigs'.default.Bosses[i].BossWaterSpeed = M.default.WaterSpeed;
                class'InvasionProConfigs'.default.Bosses[i].BossAirSpeed = M.default.AirSpeed;
                class'InvasionProConfigs'.default.Bosses[i].BossJumpZ = M.default.JumpZ;
                class'InvasionProConfigs'.default.Bosses[i].NewDrawScale = M.default.DrawScale;
                class'InvasionProConfigs'.default.Bosses[i].NewCollisionHeight = M.default.CollisionHeight;
                class'InvasionProConfigs'.default.Bosses[i].NewCollisionRadius = M.default.CollisionRadius;
                class'InvasionProConfigs'.default.Bosses[i].NewPrePivot = M.default.PrePivot;
                class'InvasionProConfigs'.default.Bosses[i].bSetup = true;
           }
       }
   }

   class'InvasionProMonsterTable'.static.StaticSaveConfig();
   CollisionTestActor = Spawn(class'InvasionProCollisionTestActor');
}

//trying to make assault maps as open and playable as possible as invasion maps
//I know this wont fully work for all custom assault maps but the stock ones are now playable :)
//most of this is for the Convoy map
function DisableAssaultActors()
{
   local int i;
   local Actor A;

   foreach DynamicActors(class'Actor',A)
   {
       if(Trigger_ASRoundEnd(A) != None)
       {
           Trigger_ASRoundEnd(A).Tag = 'SomeCoolTag_Ini';
       }
       else if(Trigger_ASMessageTrigger(A) != None || LookTarget(A) != None)
       {
           A.Destroy();
       }
       else if(PhysicsVolume(A) != None)
       {
           if(A.Tag == 'DropshipExp3New')
           {
               A.Tag = 'None';
           }
       }
       else if(ScriptedTrigger(A) != None)
       {
           for ( i=0; i<ScriptedTrigger(A).Actions.Length; i++ )
           {
               if( ACTION_TriggerEvent(ScriptedTrigger(A).Actions[i]) != None)
               {
                   if(A.Tag == 'DropshipScript')
                   {
                       ACTION_TriggerEvent(ScriptedTrigger(A).Actions[i]).Event = 'SomeCoolEvent_Ini';
                   }
               }
           }
       }
       else if( DestroyableObjective_SM(A) != None )
       {
           if(DestroyableObjective_SM(A).Event == 'BlowUpCore')
           {
               DestroyableObjective_SM(A).Event = 'SomeCoolEvent_Ini';
           }

           DestroyableObjective_SM(A).DisableObjective(None);
           TriggerEvent(A.Event, A, None);
       }
       else if( ASVehicleFactory(A) != None)
       {
           ASVehicleFactory(A).bEnabled = false;
           ASVehicleFactory(A).bRespawnWhenDestroyed = false;
           ASVehicleFactory(A).MaxVehicleCount = 0;
           ASVehicleFactory(A).VehicleClass = None;
           ASVehicleFactory(A).ShutDown();
       }
       else if( SVehicleTrigger(A) != None )
       {
           SVehicleTrigger(A).bEnabled = false;
       }
       else if( PlayerSpawnManager(A) != None)
       {
           PlayerSpawnManager(A).bAllowTeleporting = false;
           PlayerSpawnManager(A).SetEnabled(false);
       }
       else if( HoldObjective(A) != None)
       {
           HoldObjective(A).DisableObjective(None);
           if(HoldObjective(A).MoverTag == 'None')
           {
               HoldObjective(A).MoverTag = 'SomeCoolTag_Ini';
           }
       }
       else if ( Mover(A) != None && Mover(A).InitialState != 'StandOpenTimed' && A.Tag != 'C4advanceMovers' && A.Tag != 'CollapsePipes')
       {
           if(A.Tag == 'Collapse' || (A.Tag == 'DefenseUpperGrate1' && Mover(A).EncroachDamage != 999) )
           {
               Mover(A).InitialState = 'None';
               A.Tag = 'None';
               Mover(A).Trigger(Self, None);
           }
           else
           {
               Mover(A).bTriggerOnceOnly = true;
               Mover(A).InitialState = 'TriggerControl';
               Mover(A).Trigger(Self, None);
           }
       }
   }
}

function ScoreObjective(PlayerReplicationInfo Scorer, float Score)
{
    if ( Scorer != None )
    {
        Scorer.Score += Score;
        ScoreEvent(Scorer,Score,"ObjectiveScore");
    }

    if ( GameRulesModifiers != None )
    {
        GameRulesModifiers.ScoreObjective(Scorer,Score);
   }

   if(Scorer != None)
   {
       CheckScore(Scorer);
   }
}

function PlayStartupMessage()
{
   if(CurrentMapPrefix ~= "AS")
   {
       DisableAssaultActors();
   }

   Super.PlayStartupMessage();
}

function UpdateMaxLives()
{
   MaxLives = class'InvasionProConfigs'.default.Waves[WaveID].MaxLives;
   GameReplicationInfo.MaxLives = MaxLives;
}

function PostBeginPlay()
{
   Super(xTeamGame).PostBeginPlay();

   if(CurrentMapPrefix ~= "AS")
   {
       DisableAssaultActors();
   }
}

function SetTeamSpawnPoints()
{
  local int PlayerNavCounter, MonsterNavCounter;
  local NavigationPoint N;
  local GameObjective GO;
  local bool bBlueSpawnEstablished, bRedSpawnEstablished; //so more than 1 GO isnt set

   PlayerNavCounter = 0;
   MonsterNavCounter = 0;
   bBlueSpawnEstablished = false;
   bRedSpawnEstablished = false;

   //first check for matching start tags and use them if found
   //if(MonsterStartTag != ""
   for(N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
   {
       if(String(N.Tag) ~= MonsterStartTag)
       {
           MonsterStartNavList.Insert(MonsterNavCounter,1);
           MonsterStartNavList[MonsterNavCounter] = N;
           MonsterNavCounter++;
           bUseMonsterStartTag = true;
       }
       else if(String(N.Tag) ~= PlayerStartTag)
       {
           PlayerStartNavList.Insert(PlayerNavCounter,1);
           PlayerStartNavList[PlayerNavCounter] = N;
           PlayerNavCounter++;
           bUsePlayerStartTag = true;
       }
   }

   //if no start tag found for monsters and this is a team map and bSpawnAtBases them assemble spawn points based on gameobjectives
   //need to check both seperately incase someone just placed specific nodes for monsters or vice versa and not both
   if(MonsterStartNavList.Length <= 0 && bSpawnAtBases && LevelIsTeamMap())
   {
       //assemble team start points as some gametypes do not need to have TeamNumber set correctly
       foreach DynamicActors(class'GameObjective',GO)
       {
           //checking for all types of navigation points as some maps done have playerstarts anywhere near objectives and some dont even have team numbers set! And further still some have red and blue in the same location!
           if(GameObjectiveTeam(GO) == 0 && !bBlueSpawnEstablished)
           {
               for(N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
               {
                   if(Door(N) == None && Teleporter(N) == None && InventorySpot(N) == None && LiftExit(N) == None && LiftCenter(N) == None && N.Region.Zone.LocationName != "In space" && FlyingPathNode(N) == None && VSize(N.Location - GO.Location) < TeamSpawnGameRadius)
                   {
                       MonsterStartNavList.Insert(MonsterNavCounter,1);
                       MonsterStartNavList[MonsterNavCounter] = N;
                       MonsterNavCounter++;
                       bBlueSpawnEstablished = true;
                   }
               }
           }
       }
   }

   //same for players as for monsters with team differences
   if(PlayerStartNavList.Length <= 0 && bSpawnAtBases && LevelIsTeamMap())
   {
       foreach DynamicActors(class'GameObjective',GO)
       {
           if(GameObjectiveTeam(GO) == 1 && !bRedSpawnEstablished)
           {
               //checking for all types of navigation points as some maps done have playerstarts anywhere near objectives and some dont even have team numbers set! And further still some have red and blue in the same location!
               for(N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
               {
                   if(Door(N) == None && Teleporter(N) == None && InventorySpot(N) == None && LiftExit(N) == None && LiftCenter(N) == None && N.Region.Zone.LocationName != "In space" && FlyingPathNode(N) == None && VSize(N.Location - GO.Location) < TeamSpawnGameRadius)
                   {
                       PlayerStartNavList.Insert(PlayerNavCounter,1);
                       PlayerStartNavList[PlayerNavCounter] = N;
                       PlayerNavCounter++;
                       bRedSpawnEstablished = true;
                   }
               }
           }
       }
   }

   //if no game objectives fall back to regular spawning
   if(MonsterStartNavList.Length <= 0)
   {
       for(N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
       {
           if(Door(N) == None && Teleporter(N) == None && InventorySpot(N) == None && LiftExit(N) == None && LiftCenter(N) == None && FlyingPathNode(N) == None && N.Region.Zone.LocationName != "In space")
           {
               MonsterStartNavList.Insert(MonsterNavCounter,1);
               MonsterStartNavList[MonsterNavCounter] = N;
               MonsterNavCounter++;
           }
       }
   }

   if(PlayerStartNavList.Length <= 0)
   {
       for(N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
       {
           if(PlayerStart(N) != None && N.Region.Zone.LocationName != "In space" && PlayerStart(N).TeamNumber == 1)
           {
               PlayerStartNavList.Insert(PlayerNavCounter,1);
               PlayerStartNavList[PlayerNavCounter] = N;
               PlayerNavCounter++;
           }
       }
   }

   //dm maps, maps with no playerstart team numbers set
   if(PlayerStartNavList.Length <= 0)
   {
       for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
       {
           if(PlayerStart(N) != None)
           {
               PlayerStartNavList.Insert(PlayerNavCounter,1);
               PlayerStartNavList[PlayerNavCounter] = N;
               PlayerNavCounter++;
           }
       }
   }
}

function byte GameObjectiveTeam(GameObjective GO)
{
   //red
   if( (xBombDelivery(GO) != None && xBombDelivery(GO).Team == 0) || //br
       (ONSPowerCoreRed(GO) != None) || //ons
       (xDomPoint(GO) != None && xDomPoint(GO).PointName ~= "A") || //dom
       (xRedFlagBase(Go) != None) ) //ctf
   {
       return 1;
   }

   if( (xBombDelivery(GO) != None && xBombDelivery(GO).Team == 1) ||
       (ONSPowerCoreBlue(GO) != None) ||
       (xDomPoint(GO) != None && xDomPoint(GO).PointName ~= "B") ||
       (xBlueFlagBase(Go) != None) )
   {
       return 0;
   }
   //blue

   return 255;
}

function bool CanSpectate( PlayerController Viewer, bool bOnlySpectator, actor ViewTarget )
{
   //make any monsters / bots / players spectatable. I thought it might be fun to spectate monsters
   //why the heck not! Might even be helpful in debugging stuck monsters
    if ( Controller(ViewTarget) != None && Controller(ViewTarget).Pawn != None)
   {
       return true;
   }

   return false;
}

function OverrideInitialBots()
{
   //why overrride bots?
}

function UpdatePlayerGRI()
{
   local Controller C;
   local int i, PlayerCounter;

   PlayerCounter = 0;

   for(i = 0; i < 32; i++)
   {
       InvasionProGameReplicationInfo(GameReplicationInfo).PlayerNames[i] = "";
       InvasionProGameReplicationInfo(GameReplicationInfo).PlayerLives[i] = 0;
   }

   for(C = Level.ControllerList; C != None; C = C.NextController )
   {
       if(C.PlayerReplicationInfo != None)
       {
           InvasionProGameReplicationInfo(GameReplicationInfo).PlayerNames[PlayerCounter] = C.PlayerReplicationInfo.PlayerName;
           InvasionProGameReplicationInfo(GameReplicationInfo).PlayerLives[PlayerCounter] = C.PlayerReplicationInfo.NumLives;
           PlayerCounter++;
       }
   }
}

function bool CompareControllers(Controller B, Controller C)
{
   if(B.class == C.class)
   {
       return true;
   }

   if((!B.IsA('FriendlyMonsterController') && MonsterController(B) != None && C.IsA('SMPNaliFighterController')) || (B.IsA('SMPNaliFighterController') && !C.IsA('FriendlyMonsterController') && MonsterController(C) != None) )
   {
       return true;
   }

   if((B.IsA('FriendlyMonsterController') && PlayerController(C) != None || (PlayerController(B) != None && C.IsA('FriendlyMonsterController'))))
   {
       return true;
   }

   return false;
}

function CalculateMonsterEarnings(Monster Earner, Controller Other)
{
   local int Earnings;

   Earnings = 1;

   if(Other != None && Other.PlayerReplicationInfo != None)
   {
       Earnings = Other.PlayerReplicationInfo.Score / Earner.ScoringValue;
   }

   if(Earnings < 10)
   {
       Earnings = 10;
       //monsters deserve at least 10 points per kill :)
   }

   MonsterTeamScore += Earnings;
}

function UpdatePlayerLives()
{
   local Controller C;

   for(C = Level.ControllerList; C != None; C = C.NextController)
   {
       //don't give friendly monsters more lifes
       if(C.PlayerReplicationInfo != None && MonsterController(C) == None)
       {
           C.PlayerReplicationInfo.NumLives = Maxlives;
       }
   }

   UpdatePlayerGRI();
}

function ScoreKill(Controller Killer, Controller Other)
{
   local PlayerReplicationInfo OtherPRI;
   local Controller C;
   local float KillScore;
   local bool bTeamEffort;

   bTeamEffort = false;
   //give game rules a chance to add anything;
   if(GameRulesModifiers != None && Killer != None)
   {
       GameRulesModifiers.ScoreKill(Killer, Other);
   }

   if(Other != None)
   {
       OtherPRI = Other.PlayerReplicationInfo;

       if(Other.Pawn != None)
       {
           if(MonsterIsBoss(Other.Pawn))
           {
               bTeamEffort = true;
           }
       }

       //players lose points for being killed, if killed wasnt a monster (must be player/bot?)
       if( MonsterController(Other) == None && Other.PlayerReplicationInfo!=None)
       {
           //if killer was a player or monster
           Other.PlayerReplicationInfo.Score -= 10;
           Other.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
           Other.PlayerReplicationInfo.Team.Score -= 10;
           Other.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
           ScoreEvent(Other.PlayerReplicationInfo, -10, "team_frag");
       }
   }

   if(Killer != None)
   {
       //if killer was a hostile monster
       if(MonsterController(Killer) != None && !Killer.IsA('FriendlyMonsterController'))
       {
           if(Monster(Killer.Pawn) != None && Other != None)
           {
               CalculateMonsterEarnings(Monster(Killer.Pawn), Other);
           }
       }

       if( InvasionProXPlayer(Killer) != None && Other != Killer)
       {
           InvasionProXPlayer(Killer).ClientPlayKillSound();
       }

       if ( LastKilledMonsterClass == None )
       {
           KillScore = 1;
       }
       else
       {
           KillScore = LastKilledMonsterScore;
       }

       if(bTeamEffort && bShareBossPoints)
       {
           if(Killer.PlayerReplicationInfo != None)
           {
               Killer.PlayerReplicationInfo.Team.Score += KillScore;
               Killer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
               Killer.PlayerReplicationInfo.Kills++;
           }

           KillScore = LastKilledMonsterScore / GetNumPlayers();
//         KillScore = UpdateTeamNecroScore(KillScore);
           bTeamEffort = false;

           for ( C = Level.ControllerList; C!=None; C=C.nextController )
           {
               if ( C.PlayerReplicationInfo != None )//bots and players
               {
                   C.PlayerReplicationInfo.Score += KillScore;
                   C.AwardAdrenaline(KillScore);
                   C.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
               }
           }
       }
       else if(MonsterController(Other) != None && !Other.IsA('FriendlyMonsterController'))
       {
           if(Killer.PlayerReplicationInfo != None)
           {
               Killer.PlayerReplicationInfo.Kills++;
               Killer.PlayerReplicationInfo.Score += KillScore;
               Killer.PlayerReplicationInfo.Team.Score += KillScore;
               Killer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
               Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
           }

           Killer.AwardAdrenaline(KillScore);
       }
   }

   if(Killer != None && Killer.PlayerReplicationInfo != None && Killer.PlayerReplicationInfo.Team != None)
   {
       TeamScoreEvent(Killer.PlayerReplicationInfo.Team.TeamIndex, 1, "tdm_frag");
   }
   else
   {
       TeamScoreEvent(0, 1, "tdm_frag");
   }

   CheckScore(None);
}

function bool CanEnterVehicle(Vehicle V, Pawn P)
{
   return BaseMutator.CanEnterVehicle(V, P);
}

//removed instigator skill for monsters to scale damage better
function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
    local int i, OriginalDamage, ScaleDamage;
    local float KillScore;
    local Armor FirstArmor, NextArmor;
   local InvasionProXPlayer PC;
   local bool bSameTeam;

   OriginalDamage = Damage;
    //spawn protection
    if ( (InvasionProxPawn(injured) != None) && (Level.TimeSeconds - InvasionProxPawn(injured).SpawnTime < SpawnProtection || injured.InGodMode()) )
    {
       Damage = 0;
   }

   //hitsounds and team boosting
   if ((bAllowHitSounds || bNoTeamBoost) && (instigatedBy != None) && injured!=None &&
           (InvasionProXPlayer(instigatedBy.Controller) != None) &&
           ((Class<WeaponDamageType>(DamageType) != None) ||
           (Class<VehicleDamageType>(DamageType) != None)))
   {
       PC = InvasionProXPlayer(instigatedBy.Controller);
       if (instigatedBy.IsPlayerPawn() && (injured != instigatedBy))
       {
           bSameTeam = (Level.Game.bTeamGame &&
           injured.GetTeamNum() == instigatedBy.GetTeamNum());

           if (bAllowHitSounds)
           {
               PC.ClientHitSound(Damage, !bSameTeam);
           }

           if (bSameTeam && bNoTeamBoost)
           {
               Momentum = vect(0, 0, 0);
           }
       }
   }

   if(instigatedby != None && instigatedBy.Controller != None)
   {
       if(injured != None && injured.Controller != None && PlayerController(injured.Controller)==None)
       {
           //monster on monster action + other on monster action
           //also accounts for monster-driven vehicles
           if ( (Monster(Injured)!=None || (Vehicle(Injured)!=None && Monster(Vehicle(Injured).Driver)!=None)) &&
                   (Monster(instigatedBy)!=None || Vehicle(InstigatedBy)!=None && Monster(Vehicle(InstigatedBy).Driver)!=None) &&
                   CompareControllers(Injured.Controller, instigatedBy.Controller))
           {
               Damage = 0;
           }
       }

       //players and nalis
       if( Monster(Injured) == None && MonsterController(instigatedBy.Controller) == None && !InstigatedBy.Controller.IsA('SMPNaliFighterController') )
       {
           if(ClassIsChildOf(DamageType, class'DamTypeRoadkill'))
           {
               Damage = 0;
           }
       }
   }
    //boss and vehicles
    //denying "gibbed" damage type for bosses in attempt to stop sentinels telefragging them
    if( Monster(Injured) != None && MonsterIsBoss(Monster(Injured)) && (ClassIsChildOf(DamageType, class'DamTypeRoadkill') || ClassIsChildOf(DamageType, class'Gibbed')))
    {
       Damage = 0;
   }

   //damage against players (and vehicles) by hostile monsters
   //so if the damge was done by a hostile monster
    if ( instigatedby != None && MonsterController(InstigatedBy.Controller) != None )
    {
       //friendly monster check also
       if(!InstigatedBy.Controller.isA('FriendlyMonsterController'))
       {
           //boss alterations
           if(Monster(InstigatedBy).bBoss || (Vehicle(InstigatedBy)!=None && Monster(Vehicle(InstigatedBy).Driver)!=None && Monster(Vehicle(InstigatedBy).Driver).bBoss))
           {
               Damage = Damage * GetBossDamage(Monster(InstigatedBy));
           }
           else
           {
               //else apply normal monster damage scale
               for(i=0;i<class'InvasionProMonsterTable'.default.MonsterTable.Length;i++)
               {
                   if( class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterClassName == string(Monster(InstigatedBy).Class) )
                   {
                       Damage = Damage * class'InvasionProMonsterTable'.default.MonsterTable[i].DamageMultiplier;
                       ScaleDamage = (WaveNum/100) * Damage;
                       Damage += ScaleDamage;
                   }
               }
           }

           MonsterTeamScore += (Damage/2);
           TotalDamage = TotalDamage + Damage;
           UpdateMonsterTypeStats(InstigatedBy.Class, 0, Damage, 0);
       }
       else if(InstigatedBy != None && Injured != None && InstigatedBy.Controller != None && InstigatedBy.Controller.PlayerReplicationInfo != None)
       {
           //give friendly monsters some score for damage
           //monster get 10% of damage done as points or killed health, whichever is lower
           //increase damage first then apply xp
           KillScore = FMin(Damage, injured.Health);
           KillScore = (KillScore/10);
           KillScore = FMax(KillScore,1);

           InstigatedBy.Controller.PlayerReplicationInfo.Score += KillScore;
       }
    }
    else
    {
       //controller check to see if this is a sentinel or some other automated vehicle
       if(Vehicle(Injured) != None && Vehicle(Injured).Driver == None && Injured.Controller==None)
       {
           Damage = 0;
       }
   }

    //bot damages now
    if ( Injured != None && InvasionBot(injured.Controller) != None )
    {
        if ( !InvasionBot(injured.controller).bDamagedMessage && (injured.Health - Damage < 50) )
       {
           InvasionBot(injured.controller).bDamagedMessage = true;
           if ( FRand() < 0.5 )
           {
               injured.Controller.SendMessage(None, 'OTHER', 4, 12, 'TEAM');
           }
           else
           {
               injured.Controller.SendMessage(None, 'OTHER', 13, 12, 'TEAM');
           }
       }
       if ( instigatedby != None && GameDifficulty <= 3 )
       {
           if ( injured.IsPlayerPawn() && (injured == instigatedby) && (Level.NetMode == NM_Standalone) )
           {
               Damage *= 0.5;
           }
       }
    }
   //same team
    if ( Injured != None && instigatedBy != None && instigatedBy != injured)
    {
       if ( (Injured.GetTeamNum() != 255) && (instigatedBy.GetTeamNum() != 255) )
       {
           if ( Injured.GetTeamNum() == instigatedBy.GetTeamNum() )
           {
               if ( class<WeaponDamageType>(DamageType) != None || class<VehicleDamageType>(DamageType) != None )
                   Momentum *= TeammateBoost;
               if ( (Bot(injured.Controller) != None) && (instigatedBy != None) )
                   Bot(Injured.Controller).YellAt(instigatedBy);
               else if ( (PlayerController(Injured.Controller) != None)
                   && Injured.Controller.AutoTaunt() )
                   Injured.Controller.SendMessage(instigatedBy.Controller.PlayerReplicationInfo, 'FRIENDLYFIRE', Rand(3), 5, 'TEAM');

               if ( FriendlyFireScale==0.0 || (Vehicle(injured) != None && Vehicle(injured).bNoFriendlyFire) )
               {
                   Damage = 0;
               }

               Damage *= FriendlyFireScale;
           }
           else if( !injured.IsHumanControlled() && (injured.Controller != None)
               && (injured.PlayerReplicationInfo != None) && (injured.PlayerReplicationInfo.HasFlag != None) )
               injured.Controller.SendMessage(None, 'OTHER', injured.Controller.GetMessageIndex('INJURED'), 15, 'TEAM');
       }
    }
   //then check if carrying armor
   if ( Injured != None && injured.Inventory != None && Damage > 0 )
   {
       FirstArmor = injured.inventory.PrioritizeArmor(Damage, DamageType, HitLocation);
       while( (FirstArmor != None) && (Damage > 0) )
       {
           NextArmor = FirstArmor.nextArmor;
           Damage = FirstArmor.ArmorAbsorbDamage(Damage, DamageType, HitLocation);
           FirstArmor = NextArmor;
        }
    }

   if ( GameRulesModifiers != None )
   {
       Damage = GameRulesModifiers.NetDamage( OriginalDamage, Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
   }

    return Damage;
}

function bool MonsterIsBoss(Pawn P)
{
   local Inventory Inv;

   if(P != None)
   {
       Inv = P.FindInventoryType(class'InvasionProMonsterIDInv');
       if(InvasionProMonsterIDInv(Inv) != None && InvasionProMonsterIDInv(Inv).bBoss)
       {
           return true;
       }
   }

   return false;
}

function float GetBossDamage(Monster M)
{
   local int i;
   local float DamageScale;
   local string MonsterName;

   MonsterName = "None";
   DamageScale = 1;

   for(i=0;i<class'InvasionProMonsterTable'.default.MonsterTable.Length;i++ )
   {
       if( class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterClassName == string(M.Class) )
       {
           MonsterName = class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterName;
           break;
       }
   }

   if(MonsterName != "None")
   {
       for(i=0;i<class'InvasionProConfigs'.default.Bosses.Length;i++ )
       {
           if( class'InvasionProConfigs'.default.Bosses[i].BossMonsterName == MonsterName )
           {
               DamageScale = class'InvasionProConfigs'.default.Bosses[i].BossDamageMultiplier;
               break;
           }
       }
   }

   return DamageScale;
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation)
{
   local PlayerReplicationInfo PRI;

    if ( GameRulesModifiers != None && GameRulesModifiers.PreventDeath(Killed,Killer, damageType,HitLocation))
    {
       return true;
   }

   if(Monster(Killed) != None)
   {
       if(MonsterIsBoss(Monster(Killed)))
       {
           PRI = GetBossReplicationInfo(Monster(Killed));
           if(PRI != None)
           {
               BroadcastLocalizedMessage(class'InvasionProBossMessage', 1,PRI,,Killed);
               PRI.Destroy();
           }
       }

       if(Killed.PlayerReplicationInfo != None)
       {
           if(Killed.PlayerReplicationInfo.RemoteRole!=ROLE_None)
               BroadcastLocalizedMessage(class'InvasionProMessage', 1,Monster(Killed).PlayerReplicationInfo);
           else if(InvasionProFriendlyMonsterReplicationInfo(Killed.PlayerReplicationInfo)!=None && InvasionProFriendlyMonsterReplicationInfo(Killed.PlayerReplicationInfo).PRI!=None)
               BroadcastLocalizedMessage(class'InvasionProMessage', 1, InvasionProFriendlyMonsterReplicationInfo(Killed.PlayerReplicationInfo).PRI);
           else
               BroadcastLocalizedMessage(class'InvasionProMessage', 1,,,Killed);
       }
   }

  return false;
}

function Killed( Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> DamageType )
{
    local TeamPlayerReplicationInfo TPRI;
    local PlayerReplicationInfo KilledPRI;

   if(Killed!=None && Killed.PlayerReplicationInfo!=None)
       KilledPRI=Killed.PlayerReplicationInfo;

#ifdef __DEBUG__
   if(KilledPRI == None)
       DebugMessage("Game",Killed$"'s"@KilledPawn@"killed by"@Killer@"with"@DamageType);
   else
       DebugMessage("Game",KilledPRI.PlayerName@Killed$"'s"@KilledPawn@"killed by"@Killer@"with"@DamageType);
#endif

   if(Killed==None || KilledPawn.Controller!=Killed || KilledPawn.IsA('DruidBlock') || KilledPawn.IsA('DruidExplosive'))
       return;

   if(MonsterController(Killed) == None && KilledPRI!=None)
   {
       KilledPRI.NumLives--;
       KilledPRI.Score -= 10;
       KilledPRI.Team.Score -= 10;
       KilledPRI.Team.NetUpdateTime = Level.TimeSeconds - 1;

       if (KilledPRI.NumLives <= 0 )
       {
           KilledPRI.bOutOfLives = true;
           if( KilledPRI.RemoteRole!=ROLE_None ) // Hack for RPG
               BroadcastLocalizedMessage(class'InvasionProMessage', 1, KilledPRI);
           else BroadcastLocalizedMessage(class'InvasionProMessage', 1,,,Killed.Pawn);
       }

       UpdatePlayerGRI();
   }

   if(Killed.bGodMode && Level.Netmode != NM_Standalone)
   {
       Killed.bGodMode = false;
   }

   if(MonsterController(Killed) != None)
   {
       HostileMonsterKilled(Killer, Killed, KilledPawn);

       if(Killer != None && Killer.bIsPlayer)
       {
           TPRI = TeamPlayerReplicationInfo(Killer.PlayerReplicationInfo);
           if ( TPRI != None )
           {
               TPRI.AddWeaponKill(DamageType);
           }
       }
   }

   if( MonsterController(Killer) != None )
   {
       TotalKills++;
       UpdateMonsterTypeStats(Killer.Pawn.Class, 0, 0, 1);
   }

  Super(DeathMatch).Killed(Killer,Killed,KilledPawn,DamageType);
  CheckScore(None);
}

function DiscardInventory( Pawn Other )
{
    Other.Weapon = None;
    Other.SelectedItem = None;
    while ( Other.Inventory != None )
        Other.Inventory.Destroy();
}

function HostileMonsterKilled(Controller Killer, Controller Killed, Pawn KilledPawn)
{
   NumHostileMonsters();
   if(InvasionProGameReplicationInfo(GameReplicationInfo) != None)
   {
       InvasionProGameReplicationInfo(GameReplicationInfo).RemoveFriendlyMonster(Monster(KilledPawn));
   }

   if(!bBossTime && Monster(KilledPawn).bBoss)
   {
       return;
   }

   LastKilledMonsterClass = class<Monster>(KilledPawn.class);
   LastKilledMonsterScore = Monster(KilledPawn).ScoringValue;

   if(!bIncludeSummons && WasMonsterSummoned(KilledPawn))
   {
       return;
   }

   NumKilledMonsters++;
}

function bool WasMonsterSummoned(Pawn P)
{
   local Inventory Inv;

   Inv = P.FindInventoryType(class'InvasionProMonsterIDInv');

   if(InvasionProMonsterIDInv(Inv) != None)
   {
       return InvasionProMonsterIDInv(Inv).bSummoned;
   }

   return false;
}

function BossKilled()
{
   bBossActive = false;
   NumKilledMonsters++;
   CheckEndBossWave();
}

function CheckEndBossWave()
{
   local Monster M;
   local bool bFoundBoss;

   if(WaveBossID.Length <= 0) //all bosses have spawned
   {
       foreach DynamicActors(class'Monster', M)
       {
           if(M != None && M.Health > 0)
           {
               if(MonsterIsBoss(M))
               {
                   //a boss is still in play
                   bFoundBoss = true;
                   bBossActive = true;
               }
           }
       }
   }
   else
   {
       //boss waiting to spawn
       bFoundBoss = true;
       BossWaitTimer = BOSS_WAIT_TIMER_DEFAULT;
       BossTransitionTimer = BOSS_TRANSITION_TIMER_DEFAULT;
   }

   if(!bFoundBoss)
   {
       InvProMut.NextMVPAnnounceTime = Level.TimeSeconds + 8f;

       bBossActive = false;
       bBossFinished = true;
       InvasionProGameReplicationInfo(GameReplicationInfo).bBossEncounter = false;
       bBossWave = false;
       bBossWaiting = false;
       BossWaitTimer = BOSS_WAIT_TIMER_DEFAULT;
       bBossTime = false;
       bInfiniteBossTime = false;
       if(bSpawnBossWithMonsters)
       {
           if(bAdvanceWaveWhenBossKilled)
           {
               bWaveInProgress = false;
               WaveCountDown = 20;
               WaveNum++;
           }
           if(bBossDeathKillsMonsters)
           {
               KillAllEnemyMonsters();
           }
//         return;
       }
//     WaveCountDown = 20;
//     WaveNum++;
   }
}

function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn)
{
}

function ForceNextWave()
{
   local FX_MonsterSpawn FX;

   KillAllEnemyMonsters();

   foreach DynamicActors(class'FX_MonsterSpawn', FX)
   {
       if(FX != None)
           FX.Destroy();
   }

   NewWave();
   ResetBosses();
   bWaveInProgress = false;
   WaveCountDown = 20;
   WaveNum++;
}

function KillAllEnemyMonsters()
{
   local Monster M;

   foreach DynamicActors(class'Monster', M)
   {
       if(M != None && M.Health > 0 && M.Controller != None)
       {
           if(PlayerController(M.Controller) == None && !M.Controller.IsA('FriendlyMonsterController'))
           {
               if(M.DrivenVehicle != None)
                   M.DrivenVehicle.KilledBy(M.DrivenVehicle);
               M.KilledBy(M);
           }
       }
   }
}

function NewWave()
{
   //update new wave info, moved to here so invasioncommands etc.. also reset this info from SetupWave
   bBossWave = false;
   bBossWaiting = false;
   BossWaitTimer = BOSS_WAIT_TIMER_DEFAULT;
   bBossTime = false;
   bSpawnBossWithMonsters = false;
   bAdvanceWaveWhenBossKilled = false;
   bBossDeathKillsMonsters = false;
   bBossActive = false;
   bBossFinished = false;
   bInfiniteBossTime = false;
   InvasionProGameReplicationInfo(GameReplicationInfo).bBossEncounter = false;
   OverTimeDamage = default.OverTimeDamage;
   WaveStartTime = Level.TimeSeconds;
   MonstersPerPlayerCurve = 0.0;
}

function UnrealTeamInfo GetBotTeam(optional int TeamBots)
{
    return Teams[0];
}

function byte PickTeam(byte num, Controller C)
{
   if(MonsterController(C) != None)
   {
       return 1;
   }
   else
   {
       return 0;
   }
}

function PlayEndOfMatchMessage()
{
    local controller C;
    local name EndSound;

    if ( WaveNum >= LastWave )
    {
        EndSound = EndGameSoundName[0];
   }
    else if ( WaveNum - (StartWave-1) == 0 )
    {
        EndSound = AltEndGameSoundName[1];
   }
    else
    {
        EndSound = InvasionEnd[Rand(6)];
   }

    for ( C = Level.ControllerList; C != None; C = C.NextController )
    {
        if ( PlayerController(C)!=None )
        {
            PlayerController(C).PlayRewardAnnouncement(EndSound,1,true);
       }
   }
}

function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
    local float Score, NextDist;
    local Controller OtherPlayer;

    if ( (Team == 0) || ((Player !=None) && Player.bIsPlayer) )
        return Super(xTeamGame).RatePlayerStart(N,Team,Player);

    if ( N.PhysicsVolume.bWaterVolume )
        return -10000000;

    //assess candidate
    if ( (SmallNavigationPoint(N) != None) && (PlayerStart(N) == None) )
        return -1;

    Score = 10000000;

    Score += 3000 * FRand(); //randomize

    for ( OtherPlayer=Level.ControllerList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextController)
        if ( (PlayerController(OtherPlayer) != None) && (OtherPlayer.Pawn != None) )
        {
            NextDist = VSize(OtherPlayer.Pawn.Location - N.Location);
            if ( NextDist < OtherPlayer.Pawn.CollisionRadius + OtherPlayer.Pawn.CollisionHeight )
                Score -= 1000000.0;
            else if ( NextDist > 5000 )
                Score -= 20000;
            else if ( NextDist < 3000 )
            {
                if ( (NextDist > 1200) && (Vector(OtherPlayer.Rotation) Dot (N.Location - OtherPlayer.Pawn.Location)) <= 0 )
                    Score = Score + 5000 - NextDist;
                else if ( FastTrace(N.Location, OtherPlayer.Pawn.Location) )
                    Score -= (10000.0 - NextDist);
                if ( (Location.Z > OtherPlayer.Pawn.Location.Z) && (NextDist > 1000) )
                    Score += 1000;
            }
        }
    return FMax(Score, 5);
}

function ReplenishWeapons(Pawn P)
{
    local Inventory Inv;

    for (Inv = P.Inventory; Inv != None; Inv = Inv.Inventory)
    {
        if (Weapon(Inv) != None && class'Util'.static.InArray(Inv.Class,SuperWeaponClasses) == -1)
        {
            Weapon(Inv).FillToInitialAmmo();
            Inv.NetUpdateTime = Level.TimeSeconds - 1;
        }
   }
}

function int GetNumPlayers()
{
   return NumPlayers + NumBots;
}

//get actual number of hostile monsters
function int NumHostileMonsters()
{
   local Actor A;
   local int i;

   foreach DynamicActors(class'Actor', A)
   {
       if((Monster(A) != None
       && Monster(A).Health > 0
       && Monster(A).Controller != None
       && PlayerController(Monster(A).Controller) == None
       && !Monster(A).Controller.isA('FriendlyMonsterController'))
       || (A != None && A.IsA('SpiderEggActor')))
       {
           i++;
       }
   }

   NumMonsters = i;
   return i;
}

function Actor GetMonsterTarget()
{
   local Controller C;

   for ( C = Level.ControllerList; C!=None; C=C.nextController )
   {
       if ( PlayerController(C)!=None && (C.Pawn != None) )
       {
           return C.Pawn;
       }
   }
}
//current target is the Actor in question, C is the controller of the monster that should attack or not
function bool ShouldMonsterAttack(Actor CurrentTarget, Controller C)
{
   if(CurrentTarget != None && C != None)
   {
       if( Pawn(CurrentTarget) != None && Pawn(CurrentTarget).Controller != None )
       {
           if( Pawn(CurrentTarget).Controller.IsA('AnimalController'))
           {
               return false;
           }
           else if( MonsterController(C)!=None )
           {
               if( PlayerController(Pawn(CurrentTarget).Controller)!=None || Pawn(CurrentTarget).Controller.IsA('FriendlyMonsterController'))
               {
                   return true;
               }
               else
               {
                   return false;
               }
           }
           else if(  C.IsA('FriendlyMonsterController') )
           {
               if( PlayerController(Pawn(CurrentTarget).Controller)!=None || Pawn(CurrentTarget).Controller.IsA('FriendlyMonsterController'))
               {
                   return false;
               }
               else
               {
                   return true;
               }
           }
       }
   }

   return false;
}

function UpdateMonsterTypeStats(class<Pawn> MClass, int AddSpawn, int AddDamage, int AddKills)
{
   local int i;
   local string MonsterTypeClass;

   MonsterTypeClass = String(MClass);
   for(i=0;i<class'InvasionProMonsterTable'.default.MonsterTable.Length;i++)
   {
       if(MonsterTypeClass ~= class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterClassName)
       {
           class'InvasionProMonsterTable'.default.MonsterTable[i].NumSpawns += AddSpawn;
           class'InvasionProMonsterTable'.default.MonsterTable[i].NumDamage += AddDamage;
           class'InvasionProMonsterTable'.default.MonsterTable[i].NumKills += AddKills;
       }
   }
}

function UpdateGRI()
{
    InvasionProGameReplicationInfo(GameReplicationInfo).CurrentMonstersNum = NumHostileMonsters();
    InvasionProGameReplicationInfo(GameReplicationInfo).MonsterTeamScore = MonsterTeamScore;
    InvasionProGameReplicationInfo(GameReplicationInfo).WaveNumber = WaveNum;
}

function bool PlayerCanRestart( PlayerController aPlayer )
{
    return true;
}

function float SpawnWait(AIController B)
{
    if ( B.PlayerReplicationInfo.bOutOfLives )
    {
        return 999;
   }

    if ( Level.NetMode == NM_Standalone )
    {
        if ( NumBots < 4 )
        {
            return 0;
       }

        return ( 0.5 * FMax(2,NumBots-4) * FRand() );
    }

    if ( bPlayersVsBots )
    {
        return 0;
   }

    return FRand();
}

function OverTime()
{
   local Controller C;
   local Pawn P;
   local Vehicle V;
   local bool bWasGodMode;
   local float OldDamageMult;

   if(OverTimeDamage <= 0)
   {
       return;
   }

   OverTimeDamage = FClamp(OverTimeDamage + FMax(OverTimeDamage * OverTimeDamageIncreaseFraction, 1),1,1000000);

   for ( C = Level.ControllerList; C != None; C = C.NextController )
   {
       if((PlayerController(C)!=None || Bot(C)!=None) && C.Pawn!=None)
       {
           bWasGodMode = C.bGodMode;
           C.bGodMode = False;

           P = C.Pawn;
           if(Vehicle(P)!=None && Vehicle(P).Driver!=None)
           {
               V = Vehicle(P);
               P = Vehicle(P).Driver;
               OldDamageMult = V.DriverDamageMult;
               V.DriverDamageMult = 1;
           }

           P.TakeDamage(OverTimeDamage, P, P.Location, Vect(0,0,0), class'InvasionProBossDamType');

           if(V!=None)
               V.DriverDamageMult = OldDamageMult;

           C.bGodMode = bWasGodMode;
       }
   }
}

function UpdateMonsterTimer()
{
   if ( NumHostileMonsters() < (1.5 * GetNumPlayers() ) )
   {
       NextMonsterTime = Level.TimeSeconds + 0.2;
   }
   else
   {
       NextMonsterTime = Level.TimeSeconds + 2;
   }
}

function bool ShouldEndBossWave()
{
   return false;
}

function bool ShouldAdvanceWave()
{
   if(bBossWave && bBossTime)
   {
       return ShouldEndBossWave();
   }

   if(bWaveTimeLimit && Level.TimeSeconds > WaveEndTime)
   {
       return true;
   }

   if(bWaveMonsterLimit && WaveMonsters >= WaveMaxMonsters && NumHostileMonsters() <= 0)
   {
       return true;
   }

   return false;
}

function bool ShouldSpawnAnotherMonster()
{
   if(bBossWave && !bBossFinished && !bAdvanceWaveWhenBossKilled && NumHostileMonsters() < MaxMonsters && (MaxMonstersPerPlayer == 0 || NumHostileMonsters() < MaxMonstersPerPlayer))
   {
       return true;
   }

   if(bWaveTimeLimit && Level.TimeSeconds > WaveEndTime)
   {
       return false;
   }

   if(bWaveMonsterLimit && WaveMonsters >= WaveMaxMonsters)
   {
       return false;
   }

   if(NumHostileMonsters() < MaxMonsters && (MaxMonstersPerPlayer == 0 || NumHostileMonsters() < MaxMonstersPerPlayer))
   {
       return true;
   }

   return false;
}

State MatchInProgress
{
    function Timer()
    {
           local Controller C;
           local GameRules G;

           Super(xTeamGame).Timer();

           if(InvProMut != None && InvProMut.Rules == None)
               InvProMut.AddGameRules();

           if(MonstersPerPlayerCurve > 0)
               MaxMonstersPerPlayer = Max(1, int((Loge(1.0 + float(GetNumPlayers())) * MonstersPerPlayerCurve) * float(MaxMonsters)));
           UpdateGRI();
           UpdatePlayerGRI();

           if(bBossActive)
           {
               if(!bInfiniteBossTime)
               {
                   if(BossTimeLimit <= 0)
                   {
                       InvasionProGameReplicationInfo(GameReplicationInfo).bOverTime = true;
                       OverTime();
                   }
                   else
                   {
                       BossTimeLimit -= 1;
                       InvasionProGameReplicationInfo(GameReplicationInfo).BossTimeLimit = BossTimeLimit;
                       InvasionProGameReplicationInfo(GameReplicationInfo).bOverTime = false;
                   }
               }
           }

           if(bWaveInProgress)
           {
               if(bBossWaiting)
               {
                   if(BossWarnStringCount>0)
                   {
                       BossWarnStringCount--;
                       for(C = Level.ControllerList; C != None; C = C.NextController)
                           if(PlayerController(C) != None)
                               PlayerController(C).ReceiveLocalizedMessage(class'LocalMessage_BossWarning', 0,,, GameReplicationInfo);
                   }
                   if(BossWaitTimer > 0)
                       BossWaitTimer--;
                   if(BossWaitTimer <= 0)
                   {
                       bBossTime = true;
                       bBossWaiting = false;
                   }
               }

               if(bBossTime && BossTransitionTimer > 0)
                   BossTransitionTimer--;

               if(!bBossTime || bSpawnBossWithMonsters)
               {
                   if(!ShouldAdvanceWave())
                   {
                       if(Level.TimeSeconds > NextMonsterTime)
                       {
                           if(!bBossActive && BossTransitionTimer <= 0)
                           {
                               FallbackTimer += 1.0;
                               if(!bIgnoreFallback && FallBackTimer > 60.0)
                               {
                                   bTryingFallbackBoss = true;
                               }

#ifdef __DEBUG__
                               DebugMessage("Boss", "Incrementing FallbackTimer to" @ FallbackTimer);
#endif

                               if(FallBackTimer > 90.0)
                               {
                                   //fallback failed also, but since we got monsters don't spawn a boss anyway
                                   WaveBossID.Remove(0,WaveBossID.Length);
                                   FallBackTimer = 0.0;
                                   return;
                               }
                           }

                           if(ShouldSpawnBoss())
                               AddBoss();
                           if(ShouldSpawnAnotherMonster())
                               AddMonster();
                           UpdateMonsterTimer();
                       }
                       if(bBossWave && !bBossTime && bSpawnBossWithMonsters && !bBossWaiting && Level.TimeSeconds >= WaveStartTime + float(5))
                       {
#ifdef __DEBUG__
                           DebugMessage("Boss", "Calling PrepareBoss because: bBossWave" @ bBossWave @ "bBossTime" @ bBossTime @ "bSpawnBossWithMonsters" @ bSpawnBossWithMonsters @ "bBossWaiting" @ bBossWaiting);                           PrepareBoss();
#endif
                           PrepareBoss();
                       }
                   }
                   else
                   {
                       if(bBossWave && NumMonsters<=0 && !bBossWaiting && !bBossTime)
                       {
                           PrepareBoss();
                       }
                       else if(!bBossWaiting) //else no more spawns via invasion, start culling monsters that are not in sight
                       {
                           if(bCullMonsters)
                               CullMonsters(true, true, false);
                           if(NumHostileMonsters() <= 0)
                           {
                               bWaveInProgress = false;
                               WaveCountDown = 20;
                               WaveNum++;
                           }
                       }
                   }
               }
               else
               {
                   if(!bBossActive)
                   {
                       FallbackTimer += 1.0;
                       if(!bIgnoreFallback && FallBackTimer > 60.0)
                       {
                           bTryingFallbackBoss = true;
                       }

#ifdef __DEBUG__
                       DebugMessage("Boss", "Incrementing FallbackTimer to" @ FallbackTimer);
#endif

                       if(FallBackTimer > 90.0)
                       {
                           //fallback failed also, skip wave
                           ForceNextWave();
                           FallBackTimer = 0.0;
                           return;
                       }
                   }
                   else
                   {
                       FallBackTimer = 0.0;
                   }

                   if(ShouldSpawnBoss())
                       AddBoss();
                   else if(ShouldSpawnAnotherMonster())
                       AddMonster();
               }
           }
           else if(bHaltWaveProgression)
               return;
           else if(NumHostileMonsters() <= 0 && !bBossWaiting ) //else countdown new wave
           {
               if(WaveNum == LastWave)
               {
                   EndGame(None,"Success");
                   return;
               }

               WaveCountDown--;
               if(WaveCountDown == 19)
               {
                   //take this fairly good chance to update stats
                   UpdateMonsterStats();
                   class'InvasionProMonsterTable'.static.StaticSaveConfig();

                   for(C = Level.ControllerList; C != None; C = C.NextController)
                   {
                       if(C.PlayerReplicationInfo != None)
                       {
                           C.PlayerReplicationInfo.bOutOfLives = false;
                           UpdatePlayerLives();
                           if ( C.Pawn != None )
                           {
                               ReplenishWeapons(C.Pawn);
                           }
                           else if ( !C.PlayerReplicationInfo.bOnlySpectator && (PlayerController(C) != None) )
                           {
                               C.GotoState('PlayerWaiting');
                           }
                       }
                   }
               }
               if ( WaveCountdown == 18 && WaveNum >= 1 )
               {
                   for ( G=GameRulesModifiers; G!=None; G=G.NextGameRules )
                   {
                       if(G!=None && G.IsA('RPGRules'))
                       {
                           G.SetPropertyText("bWaveEndExp","True");
                           G.Timer();
                           break;
                       }
                   }
               }
               if ( WaveCountDown == 13 )
               {
                   for ( C = Level.ControllerList; C != None; C = C.NextController )
                   {
                       if ( PlayerController(C) != None )
                       {
                           PlayerController(C).PlayStatusAnnouncement('Next_wave_in',1,true);
                           if ( (C.Pawn == None) && !C.PlayerReplicationInfo.bOnlySpectator )
                           {
                               PlayerController(C).SetViewTarget(C);
                           }
                       }
                       if ( C.PlayerReplicationInfo != None )
                       {
                           C.PlayerReplicationInfo.bOutOfLives = false;
                           UpdatePlayerLives();
                           if ( (C.Pawn == None) && !C.PlayerReplicationInfo.bOnlySpectator )
                           {
                               C.ServerReStartPlayer();
                           }
                       }
                   }
                   TriggerEvent(WaveTags[WaveNum], self, None); //for custom maps: sends out a trigger for the wave change and number ("Wave1, Wave2, etc)
               }
               else if ( (WaveCountDown > 1) && (WaveCountDown < 12) )
               {
                   BroadcastLocalizedMessage(class'InvasionProWaveCountDownMessage', WaveCountDown-1);
               }
               else if ( WaveCountDown <= 1 ) //new wave start
               {
                   bWaveInProgress = true;
                   SetUpWave(); //set new wave settings
                   for ( C = Level.ControllerList; C != None; C = C.NextController )
                   {
                       if ( PlayerController(C) != None )
                       {
                           PlayerController(C).LastPlaySpeech = 0;
                       }
                   }

                   CoordinateBots();
                   WaveNotification();
               }
           }
    }

    function BeginState()
    {
        Super(xTeamGame).BeginState();
        WaveNum = (StartWave-1);
        InvasionProGameReplicationInfo(GameReplicationInfo).WaveNumber = WaveNum;
    }
}

function CoordinateBots()
{
   local Bot B;
   local Controller C;
   local bool bOneMessage;

   for ( C = Level.ControllerList; C != None; C = C.NextController )
   {
       if ( Bot(C) != None )
       {
           B = Bot(C);

           InvasionBot(B).bDamagedMessage = false;
           B.bInitLifeMessage = false;
           if ( !bOneMessage && (FRand() < 0.65) )
           {
               bOneMessage = true;
               if ( (B.Squad.SquadLeader != None) && B.Squad.CloseToLeader(C.Pawn) )
               {
                   B.SendMessage(B.Squad.SquadLeader.PlayerReplicationInfo, 'OTHER', B.GetMessageIndex('INPOSITION'), 20, 'TEAM');
                   B.bInitLifeMessage = false;
               }
           }
       }
   }
}

function bool AddBot(optional string botName)
{
    local Bot NewBot;

    NewBot = SpawnBot(botName);
    if ( NewBot == None )
    {
        warn("Failed to spawn bot.");
        return false;
    }
    // broadcast a welcome message.
    BroadcastLocalizedMessage(GameMessageClass, 1, NewBot.PlayerReplicationInfo);

    NewBot.PlayerReplicationInfo.PlayerID = CurrentID++;
    NumBots++;
    if ( Level.NetMode == NM_Standalone )
    {
        RestartPlayer(NewBot);
   }
    else
    {
       NewBot.GotoState('Dead','MPStart');
       NewBot.PlayerReplicationInfo.bOutOfLives = true;
       NewBot.PlayerReplicationInfo.NumLives = 0;
   }

   UpdatePlayerGRI();
    return true;
}

function Bot SpawnBot(optional string botName)
{
    local Bot NewBot;
    local RosterEntry Chosen;
    local UnrealTeamInfo BotTeam;
    local array<xUtil.PlayerRecord> PlayerRecords;
    local xUtil.PlayerRecord PR;

    BotTeam = GetBotTeam();
    if ( bCustomBots && (class'DMRosterConfigured'.Default.Characters.Length > NumBots)  )
    {
        class'xUtil'.static.GetPlayerList(PlayerRecords);
        PR = class'xUtil'.static.FindPlayerRecord(class'DMRosterConfigured'.Default.Characters[NumBots]);
        Chosen = class'xRosterEntry'.Static.CreateRosterEntry(PR.RecordIndex);
    }

    if ( Chosen == None )
    {
        if ( SecondBot > 0 )
        {
            BotName = InvasionBotNames[SecondBot + 1];
            SecondBot++;
            if ( SecondBot > 6 )
                SecondBot = 0;
        }
        else
        {
            SecondBot = 1 + 2 * Rand(4);
            BotName = InvasionBotNames[SecondBot];
        }
        Chosen = class'xRosterEntry'.static.CreateRosterEntryCharacter(botName);
    }
    if (Chosen.PawnClass == None)
        Chosen.Init();
    NewBot = Spawn(class'InvasionProBot');

    if ( NewBot != None )
    {
        AdjustedDifficulty = AdjustedDifficulty + 2;
        InitializeBot(NewBot,BotTeam,Chosen);
        AdjustedDifficulty = AdjustedDifficulty - 2;
        NewBot.bInitLifeMessage = true;
    }
    return NewBot;
}

function bool MayBeTelefragged(Pawn Telefragger, Pawn Telefragged)
{
   local InvasionProMonsterIDInv Inv;

   if(Monster(Telefragged)!=None && PlayerController(Telefragged.Controller)==None)
   {
       Inv = InvasionProMonsterIDInv(Telefragged.FindInventoryType(class'InvasionProMonsterIDInv'));
       if(Inv!=None && Inv.bBoss)
           return false;
   }
   return true;
}

function CullMonsters(bool bSightCheck, bool bHostile, bool bFriend)
{
   local Controller C;

   //force all hostile monsters to suicide
   for ( C = Level.ControllerList; C != None; C = C.NextController )
   {
       if(C.Pawn != None && C.Pawn.Health > 0)
       {
           if(bHostile && MonsterController(C) != None && C.PlayerReplicationInfo == None)
           {
               if(bSightCheck)
               {
                   if(Level.TimeSeconds - MonsterController(C).LastSeenTime > 30 && !MonsterController(C).Pawn.PlayerCanSeeMe() )
                   {
                       C.Pawn.Health = 0;
                       C.Pawn.Died(None, class'Suicided', C.Pawn.Location );
                       //MonsterController(C).Pawn.KilledBy( MonsterController(C).Pawn );
                   }
               }
               else
               {
                   //MonsterController(C).Pawn.KilledBy( MonsterController(C).Pawn );
                   C.Pawn.Health = 0;
                   C.Pawn.Died(None, class'Suicided', C.Pawn.Location );
               }
           }
           else if(bFriend && PlayerController(C)==None && C.PlayerReplicationInfo != None)
           {
               if(bSightCheck)
               {
                   if(!C.Pawn.PlayerCanSeeMe() )
                   {
                       C.Pawn.Health = 0;
                       C.Pawn.Died(None, class'Suicided', C.Pawn.Location );
                       //C.Pawn.KilledBy( C.Pawn );
                   }
               }
               else
               {
                   C.Pawn.Health = 0;
                   C.Pawn.Died(None, class'Suicided', C.Pawn.Location );
                   //C.Pawn.KilledBy( C.Pawn );
               }
           }

           return;
       }
   }
}

function bool ShouldSpawnBoss()
{
    return (bBossTime ||
           ((bBossActive || BossTransitionTimer > 0) && bSpawnBossWithMonsters) &&
           (WaveBossID.Length <= 0 && bBossesSpawnTogether) || !bBossesSpawnTogether);
}

function AddMonster()
{
   SpawnMonster();
}

function AddBoss()
{
   local int i;

   if(bBossesSpawnTogether)
   {
       for(i = 0; i < WaveBossID.Length; i++)
       {
#ifdef __DEBUG__
           DebugMessage("Boss", "Calling SpawnBoss from bBossesSpawnTogether, normal boss");
#endif
           SpawnBoss(i);
       }
       if(WaveBossID.Length <= 0)
       {
           if(!bIgnoreFallback)
           {
               FallbackTimer = 0.0;
               bTryingFallbackBoss = true;
#ifdef __DEBUG__
               DebugMessage("Boss", "Calling SpawnBoss from bBossesSpawnTogether, WaveBossID.Length<=0, and !bIgnoreFallback");
#endif
               SpawnBoss(0);
           }
           else
           {
               CheckEndBossWave();
           }
       }
   }
   else
   {
       if(ShouldSummonBoss())
       {
           if(WaveBossID.Length > 0)
           {
               if(BossTransitionTimer <= 0)
               {
#ifdef __DEBUG__
                   DebugMessage("Boss", "Calling SpawnBoss from !bBossesSpawnTogether, ShouldSummonBoss(), WaveBossID.Length>0, and BossTransitionTimer<=0");
#endif
                   SpawnBoss(0);
               }
           }
           else
           {
               if(!bIgnoreFallback)
               {
                   FallbackTimer = 0.0;
                   bTryingFallbackBoss = true;
#ifdef __DEBUG__
                   DebugMessage("Boss", "Calling SpawnBoss from !bBossesSpawnTogether, ShouldSummonBoss(), WaveBossID.Length>0, and !bIgnoreFallback");
#endif
                   SpawnBoss(0);
               }
               else
               {
                   CheckEndBossWave();
               }
           }
       }
   }
   NumHostileMonsters();
}

function SpawnMonster()
{
    local NavigationPoint StartSpot; //spawn location
    local Pawn NewMonster; //the newly spawned monster
    local class<Monster> NewMonsterClass; //current monster to spawn
   local FX_MonsterSpawn BeamIn; //the beam in effect

   NewMonsterClass = WaveMonsterClass[Rand(WaveNumClasses)];
   if(NewMonsterClass != None)
   {
       StartSpot = FindPlayerStart(None, 0, string(NewMonsterClass));
       //if can't find a playerstart then stop.
       if(StartSpot == None)
       {
#ifdef __DEBUG__
           DebugMessage("Spawn", "Cannot find valid Navigation Point to spawn monster class" @ NewMonsterClass);
#endif
           Log("Cannot find valid Navigation Point to spawn monster class" @ NewMonsterClass, 'InvasionPro');
           return;
       }

       if(!bDoEffectSpawns)
       {
           NewMonster = Spawn(NewMonsterClass,,, StartSpot.Location+(NewMonsterClass.Default.CollisionHeight - StartSpot.CollisionHeight) * vect(0, 0, 1), StartSpot.Rotation);
           if (NewMonster == None)
           {
               NewMonsterClass = WaveMonsterClass[Rand(WaveNumClasses)];
               NewMonster = Spawn(NewMonsterClass,,, StartSpot.Location+(NewMonsterClass.Default.CollisionHeight - StartSpot.CollisionHeight) * vect(0, 0, 1), StartSpot.Rotation);
           }
       }
       else
       {
           BeamIn = Spawn(class'FX_MonsterSpawn',,, StartSpot.Location + (NewMonsterClass.Default.CollisionHeight - StartSpot.CollisionHeight) * vect(0, 0, 1), StartSpot.Rotation);
           BeamIn.StartSpot = StartSpot;
           BeamIn.MyPawnClass = NewMonsterClass;
           if(Level.NetMode == NM_Standalone)
               BeamIn.UpdateEffects(NewMonsterClass);
       }
   }
   if (NewMonster != None || BeamIn != None)
   {
       TotalSpawned++;
       WaveMonsters++;
       if(BeamIn != None)
           CurrentBeamIns++;
   }
   NumHostileMonsters();
}

function bool ShouldSummonBoss()
{
   local Monster M;

   foreach DynamicActors(class'Monster', M)
   {
       if(M != None && M.Health > 0)
       {
           if(MonsterIsBoss(M))
           {
               return false;
           }
       }
   }

   return true;
}

function ResetBosses()
{
   bBossWaiting = false;
   BossWaitTimer = BOSS_WAIT_TIMER_DEFAULT;
   BossTransitionTimer = BOSS_TRANSITION_TIMER_DEFAULT;
   bBossTime = false;
}

//to set up info in the GRI early so clients can receieve it in time for it to be displayed
function PreSetUpWave()
{
   WaveID = WaveTable[WaveNum];
   BossID = BossTable[WaveNum];
   InvasionProGameReplicationInfo(GameReplicationInfo).WaveDrawColour = class'InvasionProConfigs'.default.Waves[WaveNum].WaveDrawColour;
   InvasionProGameReplicationInfo(GameReplicationInfo).WaveName = class'InvasionProConfigs'.default.Waves[WaveNum].WaveName;
   InvasionProGameReplicationInfo(GameReplicationInfo).WaveSubName = class'InvasionProConfigs'.default.Waves[WaveNum].WaveSubName;
}

function SetUpWave()
{
   local int i; //to cycle through various monster lists
   local int h; //to cycle through sub lists such as monsterlist
   local string FallBackMonsterName; //short hand fallbackmonster, will be made into a full class in order to load
   local class<Monster> CurrentMonsterClass; //current monster class being loaded

   NewWave(); //update custom info incase wave was skipped
   UpdateMaxLives(); //update wave max lives
   UpdatePlayerLives();//update player lives and deaths

   bIgnoreFallback = false;
   FallbackTimer = 0;
   WaveMonsters = 0; //the number of monsters spawned so far, this should be 0 at this stage
   MaxMonsters = class'InvasionProConfigs'.default.Waves[WaveNum].MaxMonsters; //update new max monsters allowed (over ridden if bBalanceMonsters)
   WaveMaxMonsters = class'InvasionProConfigs'.default.Waves[WaveNum].WaveMaxMonsters; //update new wave max monsters (total monsters to spawn)
   MonstersPerPlayerCurve = class'InvasionProConfigs'.default.Waves[WaveNum].MonstersPerPlayerCurve;

   if(!bWaveTimeLimit && !bWaveMonsterLimit)
   {
       //default to wave time limit
       bWaveTimeLimit = True;
       class'InvasionProConfigs'.default.Waves[WaveNum].WaveDuration = 90;
   }

   WaveEndTime = Level.TimeSeconds + class'InvasionProConfigs'.default.Waves[WaveNum].WaveDuration; //update the new waves wave duration
   AdjustedDifficulty = GameDifficulty + class'InvasionProConfigs'.default.Waves[WaveNum].WaveDifficulty; //game difficulty setting, changes AI
   WaveNumClasses = 0; //set number of available monster classes to 0
   NumKilledMonsters = 0;
   bTryingFallbackBoss = false;
   ResetBosses();

   //set up monster list
   for(i = 0; i < __INVPRO_MAX_WAVE_MONSTERS__; i++)
   {
       //set to None each time, so we don't add the same monster when we shouldn't
       CurrentMonsterClass = None;

       for(h = 0; h < class'InvasionProMonsterTable'.default.MonsterTable.Length; h++)
       {
           //search for matching monster classes
           if(class'InvasionProConfigs'.default.Waves[WaveNum].Monsters[i] != "None" && class'InvasionProConfigs'.default.Waves[WaveNum].Monsters[i] ~= class'InvasionProMonsterTable'.default.MonsterTable[h].MonsterName)
           {
               CurrentMonsterClass = class<Monster>(DynamicLoadObject(class'InvasionProMonsterTable'.default.MonsterTable[h].MonsterClassName, class'Class', true));
           }
       }

       if(CurrentMonsterClass != None)
       {
           WaveMonsterClass[WaveNumClasses] = CurrentMonsterClass;
           WaveNumClasses++;
       }
   }
   //set up fallback monster
   FallBackMonsterName = class'InvasionProConfigs'.default.Waves[WaveNum].WaveFallbackMonster; //get fall back monster name
   if(FallBackMonsterName != "None")
   {
       for(i=0;i<class'InvasionProMonsterTable'.default.MonsterTable.Length;i++)
       {
           //search for matching fall back monster class
           if(FallBackMonsterName ~= class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterName)
           {
               FallBackMonster = class<Monster>(DynamicLoadObject(class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterClassName, class'Class',true));
           }
       }
   }
   else
   {
       FallBackMonster = default.FallBackMonster;
   }

   //set up current boss information
   if(BossID != -1)//is this a boss wave
   {
       if(class'InvasionProConfigs'.default.Waves[WaveID].bOverrideBoss)
       {
           BossTimeLimit = class'InvasionProConfigs'.default.WaveBossTable[WaveID].BossTimeLimit;
            bBossesSpawnTogether = class'InvasionProConfigs'.default.WaveBossTable[WaveID].bBossesSpawnTogether;
            bSpawnBossWithMonsters = class'InvasionProConfigs'.default.WaveBossTable[WaveID].bSpawnBossWithMonsters;
            bAdvanceWaveWhenBossKilled = class'InvasionProConfigs'.default.WaveBossTable[WaveID].bAdvanceWaveWhenBossKilled;
            bBossDeathKillsMonsters = class'InvasionProConfigs'.default.WaveBossTable[WaveID].bBossDeathKillsMonsters;
       }
       else
       {
            BossTimeLimit = float(class'InvasionProConfigs'.default.BossTable[BossID].BossTimeLimit);
            bBossesSpawnTogether = class'InvasionProConfigs'.default.BossTable[BossID].bBossesSpawnTogether;
            bSpawnBossWithMonsters = class'InvasionProConfigs'.default.BossTable[BossID].bSpawnBossWithMonsters;
            bAdvanceWaveWhenBossKilled = class'InvasionProConfigs'.default.BossTable[BossID].bAdvanceWaveWhenBossKilled;
            bBossDeathKillsMonsters = class'InvasionProConfigs'.default.BossTable[BossID].bBossDeathKillsMonsters;
       }

       bInfiniteBossTime = BossTimeLimit <= 0;

       if(bBossesSpawnTogether)
           BossTransitionTimer = 3;

       bBossWave = true;
       SetUpBosses();
   }
}

function SetUpBosses()
{
   local int i, x;
   local array<string> WaveBosses, WaveFallbackBosses;

    WaveBossID.Remove(0, WaveBossID.Length);
    if(BossID != -1)
    {
        if(class'InvasionProConfigs'.default.Waves[WaveID].bOverrideBoss)
        {
            if(class'InvasionProConfigs'.default.WaveBossTable[WaveID].WarningMessage != "")
            {
                InvasionProGameReplicationInfo(GameReplicationInfo).BossWarnString = class'InvasionProConfigs'.default.WaveBossTable[WaveID].WarningMessage;
            }
            if(class'InvasionProConfigs'.default.WaveBossTable[WaveID].WarningSound != "")
            {
                InvasionProGameReplicationInfo(GameReplicationInfo).BossWarnSound = class'InvasionProConfigs'.default.WaveBossTable[WaveID].WarningSound;
            }
            Split(class'InvasionProConfigs'.default.WaveBossTable[WaveID].Bosses, ",", WaveBosses);
            Split(class'InvasionProConfigs'.default.WaveBossTable[WaveID].FallbackBosses, ",", WaveFallbackBosses);
        }
        else
        {
            if(class'InvasionProConfigs'.default.BossTable[BossID].WarningMessage != "")
            {
                InvasionProGameReplicationInfo(GameReplicationInfo).BossWarnString = class'InvasionProConfigs'.default.BossTable[BossID].WarningMessage;
            }
            if(class'InvasionProConfigs'.default.BossTable[BossID].WarningSound != "")
            {
                InvasionProGameReplicationInfo(GameReplicationInfo).BossWarnSound = class'InvasionProConfigs'.default.BossTable[BossID].WarningSound;
            }
            Split(class'InvasionProConfigs'.default.BossTable[BossID].Bosses, ",", WaveBosses);
            Split(class'InvasionProConfigs'.default.BossTable[BossID].FallbackBosses, ",", WaveFallbackBosses);
        }
        if(WaveBosses.Length < WaveFallbackBosses.Length)
        {
            WaveBosses.Length = WaveFallbackBosses.Length;
        }
        else
        {
            if(WaveFallbackBosses.Length < WaveBosses.Length)
            {
                WaveFallbackBosses.Length = WaveBosses.Length;
            }
        }

       for(i = 0; i < WaveBosses.Length; i++)
        {
            if(WaveBosses[i] != "-1" && WaveBosses[i] != "")
            {
                x = WaveBossID.Length;
                WaveBossID.Length = x + 1;
                WaveBossID[x].BossID = int(WaveBosses[i]);
                if(WaveFallbackBosses[i] != "-1" && WaveFallbackBosses[i] != "")
                {
                    WaveBossID[x].FallbackBossID = int(WaveFallbackBosses[i]);
                }
                else
                {
                    WaveBossID[x].FallbackBossID = -1;
                }
                WaveBossID[x].SpawnID = i;
            }
        }
        if(class'InvasionProConfigs'.default.Waves[WaveID].bOverrideBoss)
        {
           for(i = 0; i < WaveBossID.Length; i++)
            {
                if(class'InvasionProConfigs'.default.Bosses[WaveBossID[i].BossID].SpawnMessage != "")
                {
                    InvasionProGameReplicationInfo(GameReplicationInfo).BossSpawnString[i] = class'InvasionProConfigs'.default.Bosses[WaveBossID[i].BossID].SpawnMessage;
                }
                if(class'InvasionProConfigs'.default.Bosses[WaveBossID[i].BossID].SpawnSound != "")
                {
                    InvasionProGameReplicationInfo(GameReplicationInfo).BossSpawnSound[i] = class'InvasionProConfigs'.default.Bosses[WaveBossID[i].BossID].SpawnSound;
                }
            }
        }
        else
        {
           for(i = 0; i < WaveBossID.Length; i++)
            {
                if(class'InvasionProConfigs'.default.Bosses[WaveBossID[i].BossID].SpawnMessage != "")
                {
                    InvasionProGameReplicationInfo(GameReplicationInfo).BossSpawnString[i] = class'InvasionProConfigs'.default.Bosses[WaveBossID[i].BossID].SpawnMessage;
                }
                if(class'InvasionProConfigs'.default.Bosses[WaveBossID[i].BossID].SpawnSound != "")
                {
                    InvasionProGameReplicationInfo(GameReplicationInfo).BossSpawnSound[i] = class'InvasionProConfigs'.default.Bosses[WaveBossID[i].BossID].SpawnSound;
                }
            }
        }
    }
}

function PrepareBoss()
{
    local Controller C;
    local Sound WarnSound;

    bBossWaiting = true;

    if(InvasionProGameReplicationInfo(GameReplicationInfo).BossWarnSound != "" && InvasionProGameReplicationInfo(GameReplicationInfo).BossWarnSound != "None")
    {
        WarnSound = Sound(DynamicLoadObject(InvasionProGameReplicationInfo(GameReplicationInfo).BossWarnSound, class'Sound', true));
    }
    if(InvasionProGameReplicationInfo(GameReplicationInfo).BossWarnString != "" || WarnSound != None)
    {
        BossWarnStringCount = 4;
       for(C = Level.ControllerList; C != None; C = C.NextController)
        {
            if(C != None && C.PlayerReplicationInfo != None && PlayerController(C) != none)
            {
                if(WarnSound != none)
                {
                    PlayerController(C).ClientReliablePlaySound(WarnSound);
                }
                if(InvasionProGameReplicationInfo(GameReplicationInfo).BossWarnString != "")
                {
                    PlayerController(C).ReceiveLocalizedMessage(class'LocalMessage_BossWarning',,,, GameReplicationInfo);
                }
            }
        }
    }
}

function SpawnBoss(int BossIndex)
{
   local class <Monster> BossClass;
   local int TempBossID, TempSpawnID, FallbackBossID, BossNum, i;
   local NavigationPoint StartSpot; //spawn location
   local Monster NewMonster; //the newly spawned monster
    local Controller C;
    local Sound SpawnSound;
    local Inventory Inv;
    local InvasionProBossReplicationInfo BRI;
    local string BossNameLeft, BossNameRight, BossName;
   local FX_MonsterSpawn BeamIn; //the beam in effect

#ifdef __DEBUG__
    DebugMessage("Boss", "SpawnBoss called with params:" @ string(BossIndex));
#endif

    TempBossID = WaveBossID[BossIndex].BossID;
    FallbackBossID = WaveBossID[BossIndex].FallbackBossID;
    TempSpawnID = WaveBossID[BossIndex].SpawnID;
    if(!bTryingFallbackBoss)
    {
        BossClass = GetBossClass(TempBossID, BossNum);
    }
    else
    {
        BossClass = GetBossClass(FallbackBossID, BossNum);
    }

   //spawn boss
   if(BossClass != None)
   {
     StartSpot = FindPlayerStart(None,0, string(BossClass));
       //if can't find a playerstart then stop.
       if ( StartSpot == None )
       {
#ifdef __DEBUG__
            DebugMessage("Boss", "Cannot find valid Navigation Point to spawn boss class" @ string(BossClass));
#endif
            Log("Cannot find valid Navigation Point to spawn Boss", 'InvasionPro');
           return;
       }

       if(!bDoEffectSpawns)
       {
           NewMonster = Spawn(BossClass,,,StartSpot.Location+(BossClass.Default.CollisionHeight - StartSpot.CollisionHeight) * vect(0,0,1),StartSpot.Rotation);
           if ( NewMonster ==  None )
               NewMonster = Spawn(BossClass,,,StartSpot.Location+(BossClass.Default.CollisionHeight - StartSpot.CollisionHeight) * vect(0,0,1),StartSpot.Rotation);
       }
       else
       {
           BeamIn = Spawn(class'FX_MonsterSpawn',,,StartSpot.Location+(BossClass.Default.CollisionHeight - StartSpot.CollisionHeight) * vect(0,0,1),StartSpot.Rotation);
           BeamIn.StartSpot = StartSpot;
           BeamIn.MyPawnClass = BossClass;
           BeamIn.bBoss = True;
           BeamIn.BossNum = BossNum;
           BeamIn.TempBossID = TempBossID;
           BeamIn.TempSpawnID = TempSpawnID;
       }
       if ( NewMonster != None )
       {
           //a boss has spawned, whether fallback or not, so no need to fallback again
           bIgnoreFallback = true;
           //boss spawned remove from wave boss ids
           if(bTryingFallbackBoss)
           {
               for(i = 0; i < WaveBossID.Length; i++)
               {
                   WaveBossID.Remove(i, 1);
               }
           }
           else
           {
               for(i = 0; i < WaveBossID.Length; i++)
               {
                   if(TempBossID == WaveBossID[i].BossID)
                   {
                       WaveBossID.Remove(i, 1);
                       break;
                   }
               }
           }

           BRI = Spawn(class'InvasionProBossReplicationInfo',NewMonster);
           if(BRI != None)
           {
               BRI.MyMonster = NewMonster;
               BRI.PlayerName = class'InvasionProConfigs'.default.Bosses[BossNum].BossName;
           }

           if(class'InvasionProConfigs'.default.Bosses[BossNum].SpawnSound != "" && class'InvasionProConfigs'.default.Bosses[BossNum].SpawnSound != "None")
               SpawnSound = Sound(DynamicLoadObject(class'InvasionProConfigs'.default.Bosses[BossNum].SpawnSound,class'Sound',True));

           if(InvasionProGameReplicationInfo(GameReplicationInfo).BossSpawnString[0]!="" || SpawnSound!=None)
           {
               for(C=Level.ControllerList; C!=None; C=C.NextController )
               {
                   if ((C != None && C.PlayerReplicationInfo != None) && (PlayerController(C)!=None || !C.PlayerReplicationInfo.bBot))
                   {
                       if(SpawnSound != None)
                           PlayerController(C).ClientReliablePlaySound(SpawnSound);
                       if(InvasionProGameReplicationInfo(GameReplicationInfo).BossSpawnString[0]!="")
                           PlayerController(C).ReceiveLocalizedMessage(class'LocalMessage_BossSpawn',BossNum,,,GameReplicationInfo);
                   }
               }
           }

           LastBossSpawnTime = Level.TimeSeconds;
           //InvasionProMutator(BaseMutator).ModifyMonster(NewMonster,false,true);
           bBossActive = true;
           if(class'InvasionProConfigs'.default.Bosses[BossNum].BossHealth <= 0)
           {
               NewMonster.Health = NewMonster.default.Health;
           }
           else
           {
               NewMonster.Health = class'InvasionProConfigs'.default.Bosses[BossNum].BossHealth;
           }

           InvasionProGameReplicationInfo(GameReplicationInfo).bBossEncounter = true;
           NewMonster.GroundSpeed = class'InvasionProConfigs'.default.Bosses[BossNum].BossGroundSpeed;
           NewMonster.AirSpeed = class'InvasionProConfigs'.default.Bosses[BossNum].BossAirSpeed;
           NewMonster.WaterSpeed = class'InvasionProConfigs'.default.Bosses[BossNum].BossWaterSpeed;
           NewMonster.JumpZ =  class'InvasionProConfigs'.default.Bosses[BossNum].BossJumpZ;
           NewMonster.HealthMax = NewMonster.Health;
           NewMonster.GibCountCalf *= class'InvasionProConfigs'.default.Bosses[BossNum].BossGibMultiplier;
           NewMonster.GibCountForearm *= class'InvasionProConfigs'.default.Bosses[BossNum].BossGibMultiplier;
           NewMonster.GibCountHead *= class'InvasionProConfigs'.default.Bosses[BossNum].BossGibMultiplier;
           NewMonster.GibCountTorso *= class'InvasionProConfigs'.default.Bosses[BossNum].BossGibMultiplier;
           NewMonster.GibCountUpperArm *= class'InvasionProConfigs'.default.Bosses[BossNum].BossGibMultiplier;
           NewMonster.ScoringValue = class'InvasionProConfigs'.default.Bosses[BossNum].BossScoreAward;
           NewMonster.SetLocation( NewMonster.Location + vect(0,0,1) * ( NewMonster.CollisionHeight * class'InvasionProConfigs'.default.Bosses[BossNum].NewDrawScale) );

           if(class'InvasionProConfigs'.default.Bosses[BossNum].NewDrawScale <= 0)
           {
               NewMonster.SetDrawScale(NewMonster.default.DrawScale);
           }
           else
           {
               NewMonster.SetDrawScale(class'InvasionProConfigs'.default.Bosses[BossNum].NewDrawScale);
           }

           if(class'InvasionProConfigs'.default.Bosses[BossNum].NewCollisionRadius <= 0 || class'InvasionProConfigs'.default.Bosses[BossNum].NewCollisionHeight <= 0)
           {
               NewMonster.SetCollisionSize(NewMonster.default.CollisionRadius,NewMonster.default.CollisionHeight);
           }
           else
           {
               NewMonster.SetCollisionSize(class'InvasionProConfigs'.default.Bosses[BossNum].NewCollisionRadius,class'InvasionProConfigs'.default.Bosses[BossNum].NewCollisionHeight);
           }

           NewMonster.Prepivot = class'InvasionProConfigs'.default.Bosses[BossNum].NewPrepivot;
           UpdateMonsterTypeStats(NewMonster.Class, 1, 0, 0);
           Inv = NewMonster.FindInventoryType(class'InvasionProMonsterIDInv');
           if(InvasionProMonsterIDInv(Inv) != None)
           {
               BossName = class'InvasionProConfigs'.default.Bosses[BossNum].BossName;
               if(BossName == "")
               {
                   Divide(String(NewMonster.Class),".",BossNameLeft,BossNameRight);
                   BossName = "Boss ("$BossNameRight$")";
               }

               InvasionProMonsterIDInv(Inv).MonsterName = BossName;
               InvasionProMonsterIDInv(Inv).bSummoned = false;
               InvasionProMonsterIDInv(Inv).bBoss = true;
               InvasionProMonsterIDInv(Inv).bFriendly = false;
           }
       }
       else if(BeamIn == None)
       {
           if(!bTryingFallbackBoss)
           {
               log("Wave "@WaveNum+1@"Boss failed to spawn: maybe too large."@" Boss ID "@TempBossID,'InvasionPro');
           }
           else
           {
               log("Wave "@WaveNum+1@" Fallback boss failed to spawn, check the monsters name and id settings are correct and match the wave boss ids.",'InvasionPro');
           }
       }
   }
   else
   {
        if(TempBossID != -1)
        {
            Log("Wave ID" @ string(WaveID + 1) @ "No boss found with ID" @ string(TempBossID) $ ", maybe the BossMonsterName or TempBossID is wrong?", 'InvasionPro');
        }
       //remove from wave boss ids
       for(i = 0; i < WaveBossID.Length; i++)
        {
            if(TempBossID == WaveBossID[i].BossID)
            {
                WaveBossID.Remove(i, 1);
            }
        }
   }
}

function class<Monster> GetBossClass(int ID, out int BossNum)
{
   local int i;
   local string TempBossName; //short boss name that will be made into a full class name in order to load
   local class <Monster> BossClass;

   if(ID == -1)
       return None;

   BossClass = None;
   TempBossName = class'InvasionProConfigs'.default.Bosses[Id].BossMonsterName;
   BossNum = ID;

   //if a boss was found
   if(TempBossName != "None")
   {
       //search monster list for matching monster
       for(i = 0; i < class'InvasionProMonsterTable'.default.MonsterTable.Length; i++)
       {
           //if boss name matchess
           if(TempBossName ~= class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterName)
           {
               //set the boss class!
               BossClass = class<Monster>(DynamicLoadObject(class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterClassName, class'Class',true));
               break;
           }
       }
   }

   return BossClass;
}

function DestroyBossReplicationInfo()
{
   local InvasionProBossReplicationInfo BRI;

   foreach DynamicActors(class'InvasionProBossReplicationInfo',BRI)
   {
       BRI.Destroy();
   }
}

function InvasionProBossReplicationInfo GetBossReplicationInfo(Monster M)
{
   local InvasionProBossReplicationInfo BRI;

   foreach DynamicActors(class'InvasionProBossReplicationInfo',BRI)
   {
       if(BRI.MyMonster == M)
       {
           return BRI;
       }
   }

   return None;
}

function WaveNotification()
{
   BroadcastLocalizedMessage(class'InvasionProWaveMessage', WaveNum,,,GameReplicationInfo);
}

static function FillPlayInfo(PlayInfo PI)
{
   local UT2K4Tab_MainSP Menu;

    Super(xTeamGame).FillPlayInfo(PI);

    PI.AddSetting(default.InvasionProGroup, "Waves", GetDisplayText("Waves"), 60, 1, "Custom", ";;"$default.WaveConfigMenu,,,);
    PI.AddSetting(default.InvasionProGroup, "Monsters", GetDisplayText("Monsters"), 60, 2, "Custom", ";;"$default.MonsterConfigMenu,,,);
    PI.AddSetting(default.InvasionProGroup, "Bosses", GetDisplayText("Bosses"), 60, 3, "Custom", ";;"$default.BossConfigMenu,,,);
    PI.AddSetting(default.InvasionProGroup, "MonsterStats", GetDisplayText("MonsterStats"), 60, 4, "Custom", ";;"$default.MonsterStatsConfigMenu,,,);
    PI.AddSetting(default.InvasionProGroup, "InvasionProSettings", GetDisplayText("InvasionProSettings"), 60, 0, "Custom", ";;"$default.InvasionProConfigMenu,,,);
   PI.AddSetting(default.InvasionProGroup ,"LastWave","Final Wave", 0, 7, "Text","6;"$default.StartWave+1$":999999",,False,True);
   PI.AddSetting(default.InvasionProGroup ,"StartWave","Initial Wave", 0, 6, "Text","6;0:"$default.LastWave-1,,False,True);
   PI.AddSetting(default.InvasionProGroup ,"bBalanceMonsters","Balance Monsters", 60, 12, "Check",,,False,True);
   PI.AddSetting(default.InvasionProGroup ,"bShareBossPoints","Share Boss Points", 0, 13, "Check",,,False,True);
   PI.AddSetting(default.InvasionProGroup ,"bPermitVehicles","Allow Vehicles", 0, 16, "Check",,,False,True);
   PI.AddSetting(default.InvasionProGroup ,"bPreloadMonsters","Preload Monsters", 0, 15, "Check",,,False,True);
   PI.AddSetting(default.InvasionProGroup ,"bSpawnAtBases","Spawn at Bases", 0, 14, "Check",,,False,True);
   PI.AddSetting(default.InvasionProGroup ,"bHideRadar","Hide Radar", 0, 34, "Check",,,False,True);
   PI.AddSetting(default.InvasionProGroup ,"bHidePlayerList","Hide Player List", 0, 33, "Check",,,False,True);
   PI.AddSetting(default.InvasionProGroup ,"bHideMonsterCount","Hide Monster Count", 0, 32, "Check",,,False,True);
   PI.AddSetting(default.InvasionProGroup ,"bIncludeSummons","Include Summoned Monsters", 0, 22, "Check",,,False,True);
   PI.AddSetting(default.InvasionProGroup ,"bWaveTimeLimit","Time Limit Ends Waves", 0, 17, "Check",,,False,True);
   PI.AddSetting(default.InvasionProGroup ,"bWaveMonsterLimit","Monster Limit Ends Waves", 0, 18, "Check",,,False,True);
   PI.AddSetting(default.InvasionProGroup ,"bAerialView","3rd Person Aiming", 0, 5, "Check",,,False,True);
   PI.AddSetting(default.InvasionProGroup ,"TeamSpawnGameRadius","Team Spawn Radius", 60, 14, "Text","6;0:999999",,False,True);
   PI.AddSetting(default.InvasionProGroup ,"WaveNameDuration","Wave Name Duration", 0, 18, "Text","6;0:999999",,False,True);
   PI.AddSetting(default.InvasionProGroup ,"MonsterSpawnDistance","Monster Spawn Distance", 60, 19, "Text","6;100:999999",,False,True);
   PI.AddSetting(default.InvasionProGroup ,"SpawnProtection","Spawn Protection Time", 60, 21, "Text","6;0:999999",,False,True);
   PI.AddSetting(default.InvasionProGroup ,"bCullMonsters","Cull Monsters", 0, 45, "Check",,,False,True);
   PI.AddSetting(default.InvasionProGroup ,"bDoEffectSpawns","Do Effect Spawns", 0, 46, "Check",,,False,True);
   PI.AddSetting(default.InvasionProGroup ,"bMonstersAlwaysRelevant","Monsters Always Relevant", 0, 47, "Check",,,False,True);
   PI.AddSetting(default.InvasionProGroup ,"bRateMonsterSpawns","Rate Monster Spawns", 0, 48, "Check",,,False,True);

    PI.PopClass();
   //destroy old maplistmanager and spawn new one
   foreach default.Class.AllObjects(class'UT2K4Tab_MainSP', Menu)
   {
       Menu.MapHandler.Destroy();
       Menu.MapHandler = Menu.PlayerOwner().Spawn(class'InvasionProMapListManager');
       Menu.InitMaps();
   }
}

static function string AssembleWebAdminFallbackMonster()
{
   local int i;
   local string MonsterList;

   MonsterList = "";

   for(i=0;i<class'InvasionProMonsterTable'.default.MonsterTable.Length;i++)
   {
       if(class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterName != "None")
       {
           MonsterList = MonsterList$class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterClassName$";"$class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterName$";";
       }
   }

   return MonsterList;
}

static event string GetDescriptionText(string PropName)
{
    switch (PropName)
    {
       case "Waves":           return default.InvasionDescText[0];
       case "Monsters":        return default.InvasionDescText[1];
       case "Bosses":  return default.InvasionDescText[2];
       case "MonsterStats":  return default.InvasionDescText[3];
       case "InvasionProSettings": return default.InvasionDescText[4];
       case "LastWave": return "The invasion ends after this wave.";
       case "StartWave": return "The invasion begins on this wave.";
       case "bBalanceMonsters": return "Check to scale monsters with players.";
       case "bShareBossPoints": return "Check to share boss points with the team.";
       case "bPermitVehicles": return "Check to allow vehicles.";
       case "bPreloadMonsters": return "Check to enable monster preloading.";
       case "bSpawnAtBases": return "Check to make players and monsters spawn at opposite bases in team based maps.";
       case "bHideRadar": return "Check to hide the radar from all player HUDs.";
       case "bHidePlayerList": return "Check to hide the player list from all player HUDs.";
       case "bHideMonsterCount": return "Check to hide the monster count from all player HUDs.";
       case "bIncludeSummons": return "Check to include monsters that are summoned by other monsters towards the monster limit.";
       case "bWaveTimeLimit": return "If checked, the wave duration ends the wave.";
       case "bWaveMonsterLimit": return "If checked the monster limit ends the wave.";
       case "bAerialView": return "Check to enable third person aiming.";
       case "TeamSpawnGameRadius": return "If base spawning is active this is the maximum spawn radius from the game team area.";
       case "WaveNameDuration": return "How long the wave title stays on the screen.";
       case "MonsterSpawnDistance": return "The maximum distance monsters spawn from players.";
       case "SpawnProtection": return "How long spawn protection lasts.";
       case "bCullMonsters": return "Whether monsters should be killed off automatically at the end of the wave.";
       case "bDoEffectSpawns": return "Whether monster spawning should use the TUR Invasion-X spawn effect.";
       case "bMonstersAlwaysRelevant": return "Whether monsters should have bAlwaysRelevant=True to force them to show up on the radar at all times.";
       case "bRateMonsterSpawns": return "Whether monster spawning should take into account distance from other players.";
    }

    return Super(xTeamGame).GetDescriptionText(PropName);
}

static event string GetDisplayText( string PropName )
{
    switch (PropName)
    {
       case "Waves": return default.InvasionPropText[0];
       case "Monsters": return default.InvasionPropText[1];
       case "Bosses": return default.InvasionPropText[2];
       case "MonsterStats": return default.InvasionPropText[3];
       case "InvasionProSettings": return default.InvasionPropText[4];
    }

    return Super(xTeamGame).GetDisplayText( PropName );
}

static event bool AcceptPlayInfoProperty(string PropName)
{
   if ( (PropName == "bBalanceTeams") || (PropName == "bPlayersBalanceTeams") || (PropName == "GoalScore") || (PropName == "TimeLimit") || (PropName == "SpawnProtectionTime") ||(PropName == "EndTimeDelay") )
   {
       return false;
   }

  return Super(xTeamGame).AcceptPlayInfoProperty(PropName);
}

//deny incompatible mutators :(
static function bool AllowMutator( string MutatorClassName )
{
   local string MutPackage, MutClass;

    if ( MutatorClassName ~= "XGame.MutRegen" )
        return false;

   if ( MutatorClassName ~= "SatoreMonsterPackv120.mutsatoreMonsterPack" )
        return false;

    if ( MutatorClassName ~= "SatoreMonsterPackv120.mutSMPMonsterConfig" )
        return false;

    if ( MutatorClassName == "MonsterManager_1_8.MutMonsterManager" )
        return false;

    if ( MutatorClassName == "MonsterDamageConfig.MutMonsterDamage" )
        return false;

    if ( MutatorClassName == "MonsterDamageConfigv2.MutMonsterDamage" )
        return false;

    if ( MutatorClassName == "DruidsMonsterMover102.MutMonsterMover" )
       return false;

    Divide(MutatorClassName, ".", MutPackage, MutClass);
    if(MutClass ~= "MutAerialView")
    {
       return false;
   }
   else if(MutClass ~= "MutBossWaves")
   {
       return false;
   }

    return Super(xTeamGame).AllowMutator(MutatorClassName);
}

function ChangeName(Controller Other, string S, bool bNameChange)
{
    local Controller APlayer,C, P;

    if ( S == "" )
        return;

    S = StripColor(s);  // Stip out color codes

    if (Other.PlayerReplicationInfo.playername~=S)
        return;

    S = Left(S,20);
    ReplaceText(S, " ", "_");
    ReplaceText(S, "|", "I");

    if ( bEpicNames && (Bot(Other) != None) )
    {
        if ( TotalEpic < 21 )
        {
            S = EpicNames[EpicOffset % 21];
            EpicOffset++;
            TotalEpic++;
        }
        else
        {
            S = NamePrefixes[NameNumber%10]$"CliffyB"$NameSuffixes[NameNumber%10];
            NameNumber++;
        }
    }

    for( APlayer=Level.ControllerList; APlayer!=None; APlayer=APlayer.nextController )
        if ( APlayer.bIsPlayer && (APlayer.PlayerReplicationInfo.playername~=S) )
        {
            if ( PlayerController(Other)!=None )
            {
                PlayerController(Other).ReceiveLocalizedMessage( GameMessageClass, 8 );
                return;
            }
            else
            {
                if ( Other.PlayerReplicationInfo.bIsFemale )
                {
                    S = FemaleBackupNames[FemaleBackupNameOffset%32];
                    FemaleBackupNameOffset++;
                }
                else
                {
                    S = MaleBackupNames[MaleBackupNameOffset%32];
                    MaleBackupNameOffset++;
                }
                for( P=Level.ControllerList; P!=None; P=P.nextController )
                    if ( P.bIsPlayer && (P.PlayerReplicationInfo.playername~=S) )
                    {
                        S = NamePrefixes[NameNumber%10]$S$NameSuffixes[NameNumber%10];
                        NameNumber++;
                        break;
                    }
                break;
            }
            S = NamePrefixes[NameNumber%10]$S$NameSuffixes[NameNumber%10];
            NameNumber++;
            break;
        }

    if( bNameChange )
        GameEvent("NameChange",s,Other.PlayerReplicationInfo);

    if ( S ~= "CliffyB" )
        bEpicNames = true;
    Other.PlayerReplicationInfo.SetPlayerName(S);
    // notify local players
    if  ( bNameChange )
        for ( C=Level.ControllerList; C!=None; C=C.NextController )
            if ( (PlayerController(C) != None) && (Viewport(PlayerController(C).Player) != None) )
                PlayerController(C).ReceiveLocalizedMessage( class'GameMessage', 2, Other.PlayerReplicationInfo );

   UpdatePlayerGRI();
}

function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
{
   local UnrealTeamInfo NewTeam;

   if ( PlayerController(Other)!=None && Other.PlayerReplicationInfo.bOnlySpectator )
   {
       Other.PlayerReplicationInfo.Team = None;
       return true;
   }
   NewTeam = Teams[0];
   Other.StartSpot = None;
   if ( Other.PlayerReplicationInfo.Team != None )
       Other.PlayerReplicationInfo.Team.RemoveFromTeam(Other);

   NewTeam.AddToTeam(Other);
   return true;
}

event PlayerController Login
(
    string Portal,
    string Options,
    out string Error
)
{
   local PlayerController PC;

   MaxLives = 0; // Hack!
   PC = Super.Login(Portal,Options,Error);
   MaxLives = 1;
   Level.Game.bWelcomePending = true;
   Return PC;
}

event PostLogin( PlayerController NewPlayer )
{
   //local Controller C;

   Super.PostLogin(NewPlayer);

   if(InvasionProXPlayer(NewPlayer) != None)
   {
       UpdatePlayerGRI();
       InvasionProXPlayer(NewPlayer).bLoadMeshes = bPreloadMonsters;
   }
}

function bool AllowBecomeActivePlayer(PlayerController P)
{
   if ( P==None || P.PlayerReplicationInfo == None || !P.PlayerReplicationInfo.bOnlySpectator )
       return false;
   if( AtCapacity(False) )
   {
       P.ClientMessage("You can't become an active player this time; server is at maximum capacity.");
       return false;
   }
   if( !GameReplicationInfo.bMatchHasBegun )
   {
       P.ClientMessage("You can't become an active player this time; match hasn't begun yet.");
       return false;
   }
   if( P.IsInState('GameEnded') )
   {
       P.ClientMessage("You can't become an active player at this time; game has ended.");
       return false;
   }
   if ( (Level.NetMode == NM_Standalone) && (NumBots > InitialBots) )
   {
       if(NumBots > InitialBots)
       {
           RemainingBots--;
       }
       bPlayerBecameActive = true;
   }

   P.PlayerReplicationInfo.bOutOfLives = True;
   P.PlayerReplicationInfo.NumLives = -1;
   return true;
}

function bool BecomeSpectator(PlayerController P)
{
   if ( (P.PlayerReplicationInfo == None) || P.PlayerReplicationInfo.bOnlySpectator )
       return false;
   if ( !Super.BecomeSpectator(P) )
    return false;

    if ( !bKillBots )
       RemainingBots++;
    if ( !NeedPlayers() || AddBot() )
       RemainingBots--;
    return true;
}

function RestartPlayer( Controller aPlayer )
{
   local NavigationPoint startSpot;
   local int TeamNum;
   local class<Pawn> DefaultPlayerClass;
   local Vehicle V, Best;
   local vector ViewDir;
   local float BestDist, Dist;
   local int iArray;

   iArray = class'Util'.static.InArray(aPlayer,RevivedPlayers);

   if(PlayerController(aPlayer)!=None
   && aPlayer.PlayerReplicationInfo!=None
   && (aPlayer.PlayerReplicationInfo.NumLives<0 || aPlayer.PlayerReplicationInfo.bOutOfLives ||
   (bWaveInProgress && !PlayerRestartAllowed(aPlayer) && iArray==-1)) )
   {
       aPlayer.PlayerReplicationInfo.bOutOfLives = True;
       aPlayer.GoToState('Spectating');
       Return;
   }
   else
   {
       if(InvasionProXPlayer(aPlayer) != None && !InvasionProXPlayer(aPlayer).bClientReady)
       {
           aPlayer.PlayerReplicationInfo.bOutOfLives = true;
           aPlayer.GotoState('PlayerWaiting');
           return;
       }
       else if(iArray>-1)
           RevivedPlayers.Remove(iArray,1);
   }

   if( bRestartLevel && Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
           return;

   if ( (aPlayer.PlayerReplicationInfo == None) || (aPlayer.PlayerReplicationInfo.Team == None) )
   {
       TeamNum = 255;
   }
   else
   {
       TeamNum = aPlayer.PlayerReplicationInfo.Team.TeamIndex;
   }

   if(MonsterController(aPlayer) != None)
   {
       TeamNum = 0;
   }
   else
   {
       TeamNum = 1;
   }

   startSpot = FindPlayerStart(aPlayer, TeamNum);
   if( startSpot == None )
   {
       log("Player start not found!",'InvasionPro');
       return;
   }

   if(aPlayer.PlayerReplicationInfo != None)
   {
       aPlayer.PlayerReplicationInfo.NumLives = Max(1,aPlayer.PlayerReplicationInfo.NumLives);
       aPlayer.PlayerReplicationInfo.bOutOfLives = false;
   }

   if (aPlayer.PreviousPawnClass!=None && aPlayer.PawnClass != aPlayer.PreviousPawnClass)
   {
       BaseMutator.PlayerChangedClass(aPlayer);
   }

   if ( aPlayer.PawnClass != None )
   {
       aPlayer.Pawn = Spawn(aPlayer.PawnClass,,,StartSpot.Location,StartSpot.Rotation);
   }

   if( aPlayer.Pawn==None )
   {
       DefaultPlayerClass = GetDefaultPlayerClass(aPlayer);
       aPlayer.Pawn = Spawn(DefaultPlayerClass,,,StartSpot.Location,StartSpot.Rotation);
   }

   if ( aPlayer.Pawn == None )
   {
       log("Player waiting to spawn at "$StartSpot$". Spawn point obstructed.",'InvasionPro');
       aPlayer.GotoState('Dead');
       if ( PlayerController(aPlayer) != None )
       {
           PlayerController(aPlayer).ClientGotoState('Dead','Begin');
       }
       return;
   }
   if ( PlayerController(aPlayer) != None )
   {
       PlayerController(aPlayer).TimeMargin = -0.1;
   }
   aPlayer.Pawn.Anchor = startSpot;
   aPlayer.Pawn.LastStartSpot = PlayerStart(startSpot);
   aPlayer.Pawn.LastStartTime = Level.TimeSeconds;
   aPlayer.PreviousPawnClass = aPlayer.Pawn.Class;

   aPlayer.Possess(aPlayer.Pawn);
   aPlayer.PawnClass = aPlayer.Pawn.Class;

   aPlayer.Pawn.PlayTeleportEffect(true, true);
   aPlayer.ClientSetRotation(aPlayer.Pawn.Rotation);
   AddDefaultInventory(aPlayer.Pawn);
   TriggerEvent( StartSpot.Event, StartSpot, aPlayer.Pawn);

   if ( bAllowVehicles && (Level.NetMode == NM_Standalone) && (PlayerController(aPlayer) != None) )
   {
       // tell bots not to get into nearby vehicles for a little while
       BestDist = 2000;
       ViewDir = vector(aPlayer.Pawn.Rotation);
       for ( V=VehicleList; V!=None; V=V.NextVehicle )
       {
           if ( V.bTeamLocked && (aPlayer.GetTeamNum() == V.Team) )
           {
               Dist = VSize(V.Location - aPlayer.Pawn.Location);
               if ( (ViewDir Dot (V.Location - aPlayer.Pawn.Location)) < 0 )
                   Dist *= 2;
               if ( Dist < BestDist )
               {
                   Best = V;
                   BestDist = Dist;
               }
           }
       }

       if ( Best != None )
           Best.PlayerStartTime = Level.TimeSeconds + 8;
   }

   UpdatePlayerGRI();
}

// check if all other players are out, true if players alive
function bool CheckMaxLives(PlayerReplicationInfo Scorer)
{
    local Controller C;

   for ( C=Level.ControllerList; C!=None; C=C.NextController )
   {
       if(C.PlayerReplicationInfo != None && C.PlayerReplicationInfo.NumLives >= 1
           && !C.PlayerReplicationInfo.bOutOfLives && !C.PlayerReplicationInfo.bOnlySpectator
           && (!C.IsA('FriendlyMonsterController') || C.GetPropertyText("bCountAsLivePlayer") ~= "true"))
       {
           return true;
       }
   }
}

function bool PlayerRestartAllowed(Controller C)
{
    return (Level.TimeSeconds - WaveStartTime < (1 - ((Loge(float((WaveNum - StartWave) + 1)) * 0.50) * (WaveEndTime - WaveStartTime))));
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
    local Controller C;
    local PlayerController Player;

    EndTime = Level.TimeSeconds + EndTimeDelay;

    if ( WaveNum >= LastWave )
    {
        GameReplicationInfo.Winner = Teams[0];
   }

    for ( C=Level.ControllerList; C!=None; C=C.NextController )
    {
           if(!C.IsA('FriendlyMonsterController'))
           {
               Player = PlayerController(C);
               if ( Player != None )
               {
                   if ( !Player.PlayerReplicationInfo.bOnlySpectator )
                   {
                       PlayWinMessage(Player, (Player.PlayerReplicationInfo.Team == GameReplicationInfo.Winner));
                   }
                   Player.ClientSetBehindView(true);
                   Player.ClientGameEnded();
               }

               C.GameHasEnded();
           }
    }

    if ( CurrentGameProfile != None )
    {
        CurrentGameProfile.bWonMatch = false;
   }

    return true;
}

function EndGame( PlayerReplicationInfo Winner, string Reason )
{
   local GameRules G;

   if(bWaitingToStartMatch || !GameReplicationInfo.bMatchHasBegun)
   {
       return;
   }

   if(!(Reason ~= "Success") && !(Reason ~= "Triggered"))
   {
       if(CheckMaxLives(Winner))
           return;
       else
           reason = "TimeLimit";
   }

   //check if game rules wants to end the game
   if ( (GameRulesModifiers != None) && !GameRulesModifiers.CheckEndGame(Winner, Reason) )
   {
       return;
   }

   if(Reason ~= "Success" || Reason ~= "Triggered")
   {
       for ( G=GameRulesModifiers; G!=None; G=G.NextGameRules )
       {
           if(G!=None && G.IsA('RPGRules'))
           {
               G.SetPropertyText("bWaveEndExp","True");
               break;
           }
       }
   }

   SetEndGame( Winner, Reason);
}

function SetEndGame( PlayerReplicationInfo Winner, string Reason )
{
   CheckEndGame(Winner, Reason);
   bGameEnded = true;
   TriggerEvent('EndGame', self, None);
   EndLogging(Reason);
   GotoState('MatchOver');
}

function CheckScore(PlayerReplicationInfo Scorer)
{
  if ( (GameRulesModifiers != None) && GameRulesModifiers.CheckScore(Scorer) )
       return;

   EndGame(Scorer,"TimeLimit");
}

function TweakSkill(Bot B)
{
   B.Skill = 9.0;
   B.Accuracy = 1.0;
   B.StrafingAbility = 1.0;
   B.ReactionTime = -1.0;
}

static function PrecacheGameTextures(LevelInfo myLevel)
{
   local class<Monster> p_M;
   local int i, n;

    class'xTeamGame'.static.PrecacheGameTextures(myLevel);
    myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.jBrute2');
    myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.jBrute1');
    myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.eKrall');
    myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.Skaarjw3');
    myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.Gasbag1');
    myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.Gasbag2');
    myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.Skaarjw2');
    myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.JManta1');
    myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.JFly1');
    myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.Skaarjw1');
    myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.JPupae1');
    myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.JWarlord1');
    myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.jkrall');
    myLevel.AddPrecacheMaterial(Material'InterfaceContent.HUD.SkinA');
    myLevel.AddPrecacheMaterial(Material'AS_FX_TX.AssaultRadar');

    if(default.bPreloadMonsters)
    {
       for(i = 0; i < class'InvasionProMonsterTable'.default.MonsterTable.Length; i++)
       {
           if(class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterClassName != "" && class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterClassName != "None")
           {
               p_M = class<Monster>(DynamicLoadObject(class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterClassName, class'class',true));
               if(p_M != None)
               {
                   for(n = 0; n < p_M.default.Skins.Length; n++)
                   {
                       myLevel.AddPrecacheMaterial(p_M.default.Skins[n]);
                   }
               }
           }
       }
   }
}
//make gametype appear under the invasion tab
function GetServerInfo (out ServerResponseLine ServerState)
{
   Super(xTeamGame).GetServerInfo(ServerState);
   ServerState.GameType = "Invasion";
}

function GetServerDetails( out ServerResponseLine ServerState )
{
    Super(xTeamGame).GetServerDetails(ServerState);
    AddServerDetail( ServerState, "InitialWave", StartWave );
    AddServerDetail( ServerState, "FinalWave", LastWave );
    AddServerDetail( ServerState, "Vehicles", bPermitVehicles );
    AddServerDetail( ServerState, "Third Person Aiming", bAerialView );
    AddServerDetail( ServerState, "Preload Monsters", bPreloadMonsters );
}


function bool LevelIsTeamMap()
{
   local array<string> CurrentLevelPrefix;

   CurrentLevelPrefix.Remove(0, CurrentLevelPrefix.Length);
   Split(string(Level), "-", CurrentLevelPrefix);
   if(CurrentLevelPrefix[0] != "" && CurrentLevelPrefix[0] != "None")
   {
       CurrentMapPrefix = CurrentLevelPrefix[0];
       if( CurrentMapPrefix ~= "ONS" || CurrentMapPrefix ~= "CTF" || CurrentMapPrefix ~= "DOM" || CurrentMapPrefix ~= "BR" || CurrentMapPrefix ~= "VCTF" || CurrentMapPrefix ~= CustomGameTypePrefix)
       {
           return true;
       }
   }

   return false;
}

function bool PlayerCanReallySeeMe(Actor A)
{
   local Controller C;
   local bool Result;

   Result = false;

   for ( C = Level.ControllerList; C!=None; C=C.NextController )
   {
       if(MonsterController(C) == None && C.Pawn != None && FastTrace( A.Location, C.Pawn.Location ))
       {
           Result = true;
       }
   }

   return Result;
}

//for monsters only so far/blue team
function NavigationPoint GetCollisionPlayerStart(Controller Player, byte inTeam, string IncomingName, int Switch)
{
   local array<NavigationPoint> MonsterSpawnLocs;
   local NavigationPoint BestStart;
   local int i, Counter;
   local class<Actor> A;
   local NavigationPoint N;
   local float BestRating, NodeRating;
   local bool bCanFly;

   BestStart = None;
   MonsterSpawnLocs.Remove(0, MonsterSpawnLocs.Length);
   if(InTeam == 0 && CollisionTestActor != None && IncomingName != "" && IncomingName != "None")
   {
       A = Class<Actor>(DynamicLoadObject(IncomingName,class'class',true));
       if(A != None)
       {
           if(A.default.Physics==PHYS_Flying || class<Pawn>(A).default.bCanFly)
               bCanFly=True;

           Counter = 0;
           CollisionTestActor.SetCollisionSize(A.default.CollisionRadius,A.default.CollisionHeight);
           CollisionTestActor.SetCollision(true,true,true);
           if(Switch == 0)
           {
               for ( N=Level.NavigationPointList; N != None; N=N.NextNavigationPoint )
               {
                   if(Door(N) == None && LiftExit(N) == None && LiftCenter(N) == None && InventorySpot(N) == None && (FlyingPathNode(N) == None || bCanFly) && N.Region.Zone.LocationName != "In space")
                   {
                       if(CollisionTestActor.SetLocation(N.Location+(A.default.CollisionHeight - N.CollisionHeight) * vect(0,0,1)) )
                       {
                           MonsterSpawnLocs.Insert(Counter,1);
                           MonsterSpawnLocs[Counter] = N;
                           Counter++;
                       }
                   }
               }
           }
           else if(Switch == 1)
           {
               for(i=0;i<MonsterStartNavList.Length;i++)
               {
                   if(MonsterStartNavList[i] != None && CollisionTestActor.SetLocation(MonsterStartNavList[i].Location+(A.default.CollisionHeight - MonsterStartNavList[i].CollisionHeight) * vect(0,0,1)) )
                   {
                       MonsterSpawnLocs.Insert(Counter,1);
                       MonsterSpawnLocs[Counter] = MonsterStartNavList[i];
                       Counter++;
                   }
               }
           }
           else if(Switch == 2)
           {
               for ( N=Level.NavigationPointList; N != None; N=N.NextNavigationPoint )
               {
                   if(Door(N) == None && LiftExit(N) == None && LiftCenter(N) == None && InventorySpot(N) == None && (FlyingPathNode(N) == None || bCanFly) && N.Region.Zone.LocationName != "In space" && (PlayerCanReallySeeMe(N) && !bDoEffectSpawns))
                   {
                       if(CollisionTestActor.SetLocation(N.Location+(A.default.CollisionHeight - N.CollisionHeight) * vect(0,0,1)) )
                       {
                           MonsterSpawnLocs.Insert(Counter,1);
                           MonsterSpawnLocs[Counter] = N;
                           Counter++;
                       }
                   }
               }
           }
       }
   }

   CollisionTestActor.SetCollision(false,false,false);

   if(!bRateMonsterSpawns)
       return MonsterSpawnLocs[Rand(MonsterSpawnLocs.Length+1)];

   if(MonsterSpawnLocs.Length > 0)
   {
       BestRating = 0;
       for(i=0;i<MonsterSpawnLocs.Length;i++)
       {
           NodeRating = GetMonsterStartRating(MonsterSpawnLocs[i]);
           if(NodeRating > BestRating)
           {
               BestRating = NodeRating;
               BestStart = MonsterSpawnLocs[i];
           }
       }
   }

   OldNode = BestStart;
   return BestStart;
}

function float GetMonsterStartRating(NavigationPoint NP)
{
   local float NodeRating;
   local Controller C;
   local float Dist, BestDist;

   NodeRating = 0;

   if(OldNode != None)
   {
       if(NP == OldNode)
       {
           return 0;
       }

       NodeRating = VSize(OldNode.Location - NP.Location);
   }
   else
   {
       NodeRating = 1000;
   }

   BestDist = 999999;
   Dist = 0;

   for ( C = Level.ControllerList; C!=None; C=C.NextController )
   {
       if ( C.Pawn != None && C.PlayerReplicationInfo != None)
       {
           if(!FastTrace(C.Pawn.Location + C.Pawn.BaseEyeHeight*Vect(0,0,0.5),NP.Location))
           {
               Dist = VSize(C.Pawn.Location - NP.Location);
               if(Dist < BestDist && Dist < MonsterSpawnDistance)
               {
                   BestDist = Dist;
               }
           }
           else
           {
               NodeRating = 0;
               break;
           }
       }
   }

   //if closest player is further than spawn distance decline this node
   if(!bSpawnAtBases && BestDist > MonsterSpawnDistance)
   {
       NodeRating = 0;
   }

   return NodeRating;
}

//over writing all inTeam and settings 1 for players and 0 for monsters
function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string IncomingName )
{
    local NavigationPoint BestStart; //N
   local class<Monster> M;

    // always pick StartSpot at start of match
    if ( (Player != None) && (Player.StartSpot != None) && (Level.NetMode == NM_Standalone)
      && (bWaitingToStartMatch || ((Player.PlayerReplicationInfo != None) && Player.PlayerReplicationInfo.bWaitingPlayer))  )
    {
        return Player.StartSpot;
    }

    //first assign correct team
   if( (Player != None && Player.PlayerReplicationInfo != None) || bWaitingToStartMatch || IncomingName ~= "Friendly") //should catch most players and possible friendly monsters
   {
       //players
       InTeam = 1;
   }
   else //monsters
   {
       InTeam = 0;
   }

#ifdef __DEBUG__
   DebugMessage("Spawn","FindPlayerStart called with params:"@Player@InTeam@IncomingName);
#endif

   //just let game rules overwrite if they wish
    if ( GameRulesModifiers != None )
    {
        BestStart = GameRulesModifiers.FindPlayerStart(Player,InTeam,IncomingName);
        if(BestStart != None)
       {
#ifdef __DEBUG__
           DebugMessage("Spawn","Found"@BestStart.Name@"with GameRules for class"@IncomingName);
#endif
           return BestStart;
       }
    }

   //best place to teleport stuck monsters to
    if(IncomingName ~= "Stuck")
    {
       if(Player != None && Player.Pawn != None)
       {
           IncomingName = string(Player.Pawn.Class);
       }
       BestStart = GetCollisionPlayerStart(Player,inTeam, IncomingName,2);
#ifdef __DEBUG__
       if(BestStart!=None)
           DebugMessage("Spawn","Found"@BestStart.Name@"with GetCollisionPlayerStart for stuck teleport for class"@IncomingName);
#endif
   }

   // start for monsters
   if( BestStart == None && InTeam == 0 && MonsterStartNavList.Length > 0)
   {
       if(Player != None && Player.Pawn != None && (IncomingName ~= "" || IncomingName ~= "None") )
       {
           IncomingName = string(Player.Pawn.Class);
       }

       //if start tags found use them, else if spawn at bases and base is found use it
       if( bUseMonsterStartTag || bSpawnAtBases && LevelIsTeamMap())
       {
           BestStart = GetCollisionPlayerStart(Player,inTeam, IncomingName,1);
#ifdef __DEBUG__
           if(BestStart!=None)
               DebugMessage("Spawn","Found"@BestStart.Name@"with GetCollisionPlayerStart for base spawn for class"@IncomingName);
#endif
       }
   }

   //start for players
   if( BestStart == None && InTeam == 1 && PlayerStartNavList.Length > 0)
   {
       BestStart = GetPlayerStart(Player, InTeam, IncomingName);
#ifdef __DEBUG__
       if(BestStart!=None)
           DebugMessage("Spawn","Found"@BestStart.Name@"with GetPlayerStart for base spawn for player");
#endif
   }

   if(BestStart == None && InTeam == 1)
   {
       //fallback to default spawning
       BestStart = Super.FindPlayerStart(Player,InTeam,IncomingName);
#ifdef __DEBUG__
       if(BestStart!=None)
           DebugMessage("Spawn","Found"@BestStart.Name@"with Super.FindPlayerStart for spawn for player");
#endif
   }

    /*
   //no team spawn point found
  if ( BestStart == None)
  {
    BestRating = -100000000;
    foreach AllActors( class 'NavigationPoint', N )
    {
           if(Door(N) == None && Teleporter(N) == None && LiftExit(N) == None && LiftCenter(N) == None && InventorySpot(N) == None && FlyingPathNode(N) == None && N.Region.Zone.LocationName != "In space")
           {
               NewRating = RatePlayerStart(N,0,Player);
               NewRating += 20 * FRand();
               if ( NewRating > BestRating )
               {
                   BestRating = NewRating;
                   BestStart = N;
               }
           }
    }
  }
  */
   if(BestStart == None)
   {
       M = class<Monster>(DynamicLoadObject(IncomingName,class'Class'));
       if(M!=None && (M.default.Physics==PHYS_Flying || M.default.bCanFly))
           return FlyingMonsterSpawnSpots[Rand(FlyingMonsterSpawnSpots.Length)];
       return MonsterSpawnSpots[Rand(MonsterSpawnSpots.Length)];
   }

  return BestStart;
}

function NavigationPoint GetPlayerStart(Controller Player, optional byte InTeam, optional string IncomingName, optional int Switch)
{
   local int i, TempNodeCounter;
   local array<NavigationPoint> TempNodes;
   local Actor A;
   local float BestDist, Dist;
   local Monster M;
   local NavigationPoint BestStart;

   TempNodeCounter = 0;
   BestDist = 0;
   TempNodes.Remove(0, TempNodes.Length);

   for(i=0;i<PlayerStartNavList.Length;i++)
   {
       PlayerStartNavList[i].Taken = false;

       foreach VisibleCollidingActors( class'Actor', A, 100, PlayerStartNavList[i].Location, false)
       {
           PlayerStartNavList[i].Taken = true;
       }
   }

   for(i=0;i<PlayerStartNavList.Length;i++)
   {
       if(!PlayerStartNavList[i].Taken)
       {
           TempNodes.Insert(TempNodeCounter,1);
           TempNodes[TempNodeCounter] = PlayerStartNavList[i];
           TempNodeCounter++;

           foreach DynamicActors(class'Monster',M)
           {
               if( M != None && M.Health > 0 )
               {
                   Dist = VSize ( PlayerStartNavList[i].Location - M.Location );
                   if(Dist > BestDist)
                   {
                       BestDist = Dist;
                       BestStart = PlayerStartNavList[i];
                   }
               }
           }
       }
   }

   if(BestStart == None)
   {
       BestStart = TempNodes[Rand(TempNodes.Length)];
   }

   return BestStart;
}

#ifdef __DEBUG__
function DebugMessage(string Type, string Msg)
{
    local Controller C;

    for(C = Level.ControllerList; C != None; C = C.NextController)
        if(PlayerController(C) != None)
            PlayerController(C).ClientMessage(Msg);
}
#endif

defaultproperties
{
    SuperWeaponClassNames(0)="XWeapons.Redeemer"
    SuperWeaponClassNames(1)="XWeapons.Painter"
    SuperWeaponClassNames(2)="OnslaughtFull.ONSPainter"
    AdditionalPreloads(0)="XWeapons.ShieldGun"
    AdditionalPreloads(1)="XWeapons.AssaultRifle"
    AdditionalPreloads(2)="XWeapons.BioRifle"
    AdditionalPreloads(3)="XWeapons.ShockRifle"
    AdditionalPreloads(4)="XWeapons.LinkGun"
    AdditionalPreloads(5)="XWeapons.Minigun"
    AdditionalPreloads(6)="XWeapons.FlakCannon"
    AdditionalPreloads(7)="XWeapons.RocketLauncher"
    AdditionalPreloads(8)="XWeapons.LightningGun"
    AdditionalPreloads(9)="XWeapons.Redeemer"
    AdditionalPreloads(10)="XWeapons.Painter"
    AdditionalPreloads(11)="Onslaught.ONSMineLayer"
    AdditionalPreloads(12)="Onslaught.ONSGrenadeLauncher"
    AdditionalPreloads(13)="Onslaught.ONSAVRiL"
    AdditionalPreloads(14)="OnslaughtFull.ONSPainter"
    AdditionalPreloads(15)="TURW.NyanRifle"
    AdditionalPreloads(16)="TURW.NyanRiflePickup"
    AdditionalPreloads(17)="TURW.EHRedeemerII"
    AdditionalPreloads(18)="TURW.EHRedeemerIIPickup"
    AdditionalPreloads(19)="TURW.CryoarithmeticEqualizer"
    AdditionalPreloads(20)="TURW.CryoarithmeticPickup"
    AdditionalPreloads(21)="TURW.MagicWand"
    AdditionalPreloads(22)="TURW.MagicWandPickup"
    AdditionalPreloads(23)="TURW.NecroGun"
    AdditionalPreloads(24)="TURW.NecroPickup"
    AdditionalPreloads(25)="TURW.Soar"
    AdditionalPreloads(26)="TURW.Parasite"
    AdditionalPreloads(27)="TURW.Crispe"
    AdditionalPreloads(28)="TURW.CFX"
    AdditionalPreloads(29)="TURW.Fyrian"
    AdditionalPreloads(30)="TURW.FireChucker"
    AdditionalPreloads(31)="TURW.PepperPot"
    AdditionalPreloads(32)="TURW.Helios"
    AdditionalPreloads(33)="TURW.Steorra"
    AdditionalPreloads(34)="TURW.PIC"
    AdditionalPreloads(35)="TURW.Disturber"
    AdditionalPreloads(36)="TURW.SoarPickup"
    AdditionalPreloads(37)="TURW.ParasitePickup"
    AdditionalPreloads(38)="TURW.CrispePickup"
    AdditionalPreloads(39)="TURW.CFXPickup"
    AdditionalPreloads(40)="TURW.FyrianPickup"
    AdditionalPreloads(41)="TURW.FireChuckerPickup"
    AdditionalPreloads(42)="TURW.PepperPotPickup"
    AdditionalPreloads(43)="TURW.HeliosPickup"
    AdditionalPreloads(44)="TURW.SteorraPickup"
    AdditionalPreloads(45)="TURW.PICPickup"
    AdditionalPreloads(46)="TURW.DisturberPickup"
    AdditionalPreloads(47)="TURW.BS69mg"
    AdditionalPreloads(48)="TURW.BS69pickup"
    AdditionalPreloads(49)="TURW.Flamethrower"
    AdditionalPreloads(50)="TURW.FlamethrowerPickup"
    AdditionalPreloads(51)="TURW.FlareLauncher"
    AdditionalPreloads(52)="TURW.FlareLauncherPickup"
    AdditionalPreloads(53)="TURW.GrenadeLauncher"
    AdditionalPreloads(54)="TURW.GrenadeLauncherPickup"
    AdditionalPreloads(55)="TURW.Howitzer"
    AdditionalPreloads(56)="TURW.HowitzerPickup"
    AdditionalPreloads(57)="TURW.HVAssaultRifle"
    AdditionalPreloads(58)="TURW.HVAssaultRiflePickup"
    AdditionalPreloads(59)="TURW.Kalashi"
    AdditionalPreloads(60)="TURW.KalashiPickup"
    AdditionalPreloads(61)="TURW.LaserRifle"
    AdditionalPreloads(62)="TURW.LaserRiflePickup"
    AdditionalPreloads(63)="TURW.MiniRocketLauncher"
    AdditionalPreloads(64)="TURW.MiniRocketLauncherPickup"
    AdditionalPreloads(65)="TURW.Pistol"
    AdditionalPreloads(66)="TURW.PistolPickup"
    AdditionalPreloads(67)="TURW.PTC"
    AdditionalPreloads(68)="TURW.PTCPickup"
    AdditionalPreloads(69)="TURW.Railgun"
    AdditionalPreloads(70)="TURW.RailgunPickup"
    AdditionalPreloads(71)="TURW.RazorBomb"
    AdditionalPreloads(72)="TURW.RazorBombPickup"
    AdditionalPreloads(73)="TURW.RiotShotgun"
    AdditionalPreloads(74)="TURW.Riotshotgunpickup"
    AdditionalPreloads(75)="TURW.Rustgrenade"
    AdditionalPreloads(76)="TURW.SingularityCannon"
    AdditionalPreloads(77)="TURW.SC_Pickup"
    AdditionalPreloads(78)="TURW.Shotgun"
    AdditionalPreloads(79)="TURW.ShotgunPickup"
    AdditionalPreloads(80)="TURW.SporeRifle"
    AdditionalPreloads(81)="TURW.SporeRiflePickup"
    AdditionalPreloads(82)="TURW.TurboLaser"
    AdditionalPreloads(83)="TURW.TurboLaserPickup"
    AdditionalPreloads(84)="TURW.Underslinger"
    AdditionalPreloads(85)="TURW.UnderSlingerPickup"
    AdditionalPreloads(86)="TURW.Volva"
    AdditionalPreloads(87)="TURW.VolvaPickup"
    AdditionalPreloads(88)="TURW.Widowmaker"
    AdditionalPreloads(89)="TURW.WidowmakerPickup"
    AdditionalPreloads(90)="TURW.Yichus"
    AdditionalPreloads(91)="TURW.YichusPickup"
    AdditionalPreloads(92)="TURW.MayhemAssaultRifle"
    AdditionalPreloads(93)="TURW.MayhemAssaultRiflePickup"
    AdditionalPreloads(94)="TURW.MayhemBioRifle"
    AdditionalPreloads(95)="TURW.MayhemBioRiflePickup"
    AdditionalPreloads(96)="TURW.MayhemFlakCannon"
    AdditionalPreloads(97)="TURW.MayhemFlakCannonPickup"
    AdditionalPreloads(98)="TURW.MayhemLinkGun"
    AdditionalPreloads(99)="TURW.MayhemLinkGunPickup"
    AdditionalPreloads(100)="TURW.MayhemMiniGun"
    AdditionalPreloads(101)="TURW.MayhemMiniGunPickup"
    AdditionalPreloads(102)="TURW.MayhemONSAVRiL"
    AdditionalPreloads(103)="TURW.MayhemONSAVRiLPickup"
    AdditionalPreloads(104)="TURW.MayhemONSGrenadeLauncher"
    AdditionalPreloads(105)="TURW.MayhemONSGrenadePickup"
    AdditionalPreloads(106)="TURW.MayhemONSMineLayer"
    AdditionalPreloads(107)="TURW.MayhemONSMineLayerPickup"
    AdditionalPreloads(108)="TURW.MayhemRocketLauncher"
    AdditionalPreloads(109)="TURW.MayhemRocketLauncherPickup"
    AdditionalPreloads(110)="TURW.MayhemShieldGun"
    AdditionalPreloads(111)="TURW.MayhemShieldGunPickup"
    AdditionalPreloads(112)="TURW.MayhemShockRifle"
    AdditionalPreloads(113)="TURW.MayhemShockRiflePickup"
    AdditionalPreloads(114)="TURW.MayhemSniperRifle"
    AdditionalPreloads(115)="TURW.MayhemSniperRiflePickup"
    AdditionalPreloads(116)="TURV.ONSArmadillo"
    AdditionalPreloads(117)="TURV.ONSAvrilMKII"
    AdditionalPreloads(118)="TURV.ONSAVRiLMKIIPickup"
    AdditionalPreloads(119)="TURV.ONSHurricaneTank"
    AdditionalPreloads(120)="TURV.ONSNexisMissileLauncher"
    AdditionalPreloads(121)="TURV.AP_LaserCannonPawn"
    AdditionalPreloads(122)="TURV.AP_MissileBattery"
    AdditionalPreloads(123)="TURV.Excalibur"
    AdditionalPreloads(124)="TURV.Excalibur_Robot"
    AdditionalPreloads(125)="TURV.Falcon"
    AdditionalPreloads(126)="TURV.HellbenderMKV"
    AdditionalPreloads(127)="TURV.Phantom"
    AdditionalPreloads(128)="TURV.Predator"
    AdditionalPreloads(129)="TURV.Reaper"
    AdditionalPreloads(130)="TURV.ScorpionMKV"
    AdditionalPreloads(131)="TURV.UTSpaceFighter"
    AdditionalPreloads(132)="TURV.UTSpaceFighterSkarj"
    AdditionalPreloads(133)="TURV.FH_Turret_FlareTurret"
    AdditionalPreloads(134)="TURV.FH_Turret_MiniRocket"
    AdditionalPreloads(135)="TURV.FH_Turret_Hoover"
    AdditionalPreloads(136)="TURV.RPG_BeamSentinel"
   WaveTags(0)=InvWave0
   WaveTags(1)=InvWave1
   WaveTags(2)=InvWave2
   WaveTags(3)=InvWave3
   WaveTags(4)=InvWave4
   WaveTags(5)=InvWave5
   WaveTags(6)=InvWave6
   WaveTags(7)=InvWave7
   WaveTags(8)=InvWave8
   WaveTags(9)=InvWave9
   WaveTags(10)=InvWave10
   WaveTags(11)=InvWave11
   WaveTags(12)=InvWave12
   WaveTags(13)=InvWave13
   WaveTags(14)=InvWave14
   WaveTags(15)=InvWave15
   WaveTags(16)=InvWave16
   WaveTags(17)=InvWave17
   WaveTags(18)=InvWave18
   WaveTags(19)=InvWave19
   WaveTags(20)=InvWave20
   bAllowHitSounds=True
   bCullMonsters=False
   bDoEffectSpawns=True
   bMonstersAlwaysRelevant=True
    bRateMonsterSpawns=False
    BossConfigMenu="TURInvPro.InvasionProBossConfig"
    MonsterStatsConfigMenu="TURInvPro.InvasionProMonsterStatsConfig"
    MonsterConfigMenu="TURInvPro.InvasionProMonsterConfig"
    InvasionProConfigMenu="TURInvPro.InvasionProMainMenu"
    InvasionProGroup="Invasion Pro"
    bPermitVehicles=True
   bBossFinished=True
    TotalSpawned=0
    TotalDamage=0
    TotalKills=0
    TotalGames=0
    LastWave=16
    StartWave=1
   OverTimeDamageIncreaseFraction=0.200000
    bShareBossPoints=True
    SpawnProtection=15
    bPreloadMonsters=True
    bAerialView=True
    TeamSpawnGameRadius=2000
    WaveNameDuration=3
    MonsterSpawnDistance=10000
    WaveCountDownColour=(G=255,R=255,A=255)
    VehicleLockedMessageColour=(B=255,G=150,R=100)
    bWaveTimeLimit=True
    FallbackMonster=Class'SkaarjPack.SkaarjPupae'
    WaveConfigMenu="TURInvPro.InvasionProWaveConfig"
    InvasionPropText(0)="Wave Configuration"
    InvasionPropText(1)="Invaders"
    InvasionPropText(2)="Boss Configuration"
    InvasionPropText(3)="Monster Stats"
    InvasionPropText(4)="Additional Settings"
    InvasionPropText(5)=""
    InvasionDescText(0)="Configure the properties for each wave."
    InvasionDescText(1)="Configure the monsters properties"
    InvasionDescText(2)="Configure the properties of any bosses."
    InvasionDescText(3)="View the stats of your monsters."
    InvasionDescText(4)="Configure more advanced settings of InvasionPro."
    InvasionDescText(5)=""
    bForceRespawn=True
    bAllowPlayerLights=True
    DefaultMaxLives=0
    LoginMenuClass="TURInvPro.InvasionProLoginMenu"
    bEnableStatLogging=True
    DefaultPlayerClassName="TURInvPro.InvasionProxPawn"
    ScoreBoardType="TURInvPro.InvasionProScoreboard"
    HUDType="TURInvPro.InvasionProHud"
    MapPrefix="DM,BR,CTF,AS,DOM,ONS,VCTF"
    BeaconName="INVPRO"
    GoalScore=0
    TimeLimit=0
    MutatorClass="TURInvPro.InvasionProMutator"
    PlayerControllerClassName="TURInvPro.InvasionProXPlayer"
    GameReplicationInfoClass=Class'TURInvPro.InvasionProGameReplicationInfo'
    GameName="TUR InvasionPro"
    Description="TUR InvasionPro gametype. Based on Invasion Pro v1.7."
    Acronym="INVPRO"
}
