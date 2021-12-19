//=============================================================================
// InvasionProGameReplicationInfo.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProGameReplicationInfo extends GameReplicationInfo config(TURInvPro);

var() int MonsterTeamScore;
var() int CurrentMonstersNum;
var() byte WaveNumber, BaseDifficulty;
var() int NumMonstersToLoad;
var() bool bBossEncounter;
var() bool bAerialView;
var() bool bOverTime;
var() bool bInfiniteBossTime;
var() bool bHideRadar;
var() bool bHidePlayerList;
var() bool bHideMonsterCount;
var() float SpawnProtection;
var() string MonsterKillSound;
var() float BossTimeLimit;
var() Color WaveDrawColour;
var() string WaveName;
var() string WaveSubName;
var() Color WaveCountDownColour;
var() string BossWarnString;
var() string BossWarnSound;
var() string BossSpawnString[16];
var() string BossSpawnSound[16];

//replicate NumLives
var() string PlayerNames[32];
var() int Playerlives[32];
var() Monster FriendlyMonsters[32]; //list of friendly monsters
var() bool bAlwaysOneLife;

replication
{
    reliable if(Role == ROLE_Authority)
        BossSpawnString, BossTimeLimit,
        BossWarnString, CurrentMonstersNum,
        MonsterTeamScore, PlayerNames,
        Playerlives, WaveCountDownColour,
        WaveDrawColour, WaveName,
        WaveSubName, bBossEncounter,
        bOverTime;

    reliable if(bNetInitial && Role == ROLE_Authority)
        BaseDifficulty, NumMonstersToLoad,
        SpawnProtection;

    reliable if(Role == ROLE_Authority)
        FriendlyMonsters, MonsterKillSound,
        WaveNumber, bInfiniteBossTime;

    reliable if(bNetInitial && Role == ROLE_Authority)
        bAlwaysOneLife;

    reliable if(bNetInitial && Role == ROLE_Authority)
        bAerialView, bHideMonsterCount,
        bHidePlayerList, bHideRadar;
}

simulated function int GetNumLives(PlayerReplicationInfo PRI)
{
   local int i;

   if(PRI != None)
   {
       for(i = 0; i <32; i++)
       {
           if(PRI.PlayerName ~= PlayerNames[i])
           {
               return Playerlives[i];
           }
       }
   }
}

simulated function AddPRI(PlayerReplicationInfo PRI)
{
    local byte NewVoiceID;
    local int i;

   if(PRI == None)
   {
       return;
   }

    if ( Level.NetMode == NM_ListenServer || Level.NetMode == NM_DedicatedServer )
    {
        for (i = 0; i < PRIArray.Length; i++)
        {
            if ( PRIArray[i].VoiceID == NewVoiceID )
            {
                i = -1;
                NewVoiceID++;
                continue;
            }
        }

        if ( NewVoiceID >= 32 )
            NewVoiceID = 0;

        PRI.VoiceID = NewVoiceID;
    }

    PRIArray[PRIArray.Length] = PRI;
}

simulated function RemovePRI(PlayerReplicationInfo PRI)
{
    local int i;

    for (i=0; i<PRIArray.Length; i++)
    {
        if (PRIArray[i] == PRI)
        {
            PRIArray.Remove(i,1);
            return;
        }
    }
}

simulated function AddFriendlyMonster(Monster M)
{
   local int i;

   for(i=0;i<32;i++)
   {
       if(FriendlyMonsters[i] == None)
       {
           FriendlyMonsters[i] = M;
           break;
       }
   }
}

simulated function RemoveFriendlyMonster(Monster M)
{
   local int i;

   for(i=0;i<32;i++)
   {
       if(FriendlyMonsters[i] == M)
       {
           FriendlyMonsters[i] = None;
           break;
       }
   }
}

defaultproperties
{
     MonsterKillSound="None"
     WaveDrawColour=(R=255,A=255)
     WaveCountDownColour=(G=255,R=255,A=255)
}
