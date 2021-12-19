//=============================================================================
// InvasionProFriendlyMonsterReplicationInfo.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProFriendlyMonsterReplicationInfo extends PlayerReplicationInfo;

var() int MonsterHealth;
var() int MonsterHealthMax;
var() InvasionProFakeFriendlyMonsterReplicationInfo PRI;
var() Monster MyMonster;
var() bool bMinion;

/*replication
{
    reliable if(Role == ROLE_Authority)
       MonsterHealth, MonsterHealthMax;
}*/

simulated event PostNetReceive()
{}

event PostBeginPlay()
{
    if ( Role < ROLE_Authority )
        return;
    if (AIController(Owner) != None)
        bBot = true;
    StartTime = Level.Game.GameReplicationInfo.ElapsedTime;
}

simulated function UpdatePrecacheMaterials()
{}

simulated event UpdateCharacter()
{}

simulated function SetCharacterName(string S)
{}

simulated event PostNetBeginPlay()
{}

function SetPRI()
{
   PRI = Spawn(class'InvasionProFakeFriendlyMonsterReplicationInfo');

   if(PRI != None)
   {
       UpdatePRI();
   }
}

function UpdatePRI()
{
   if(PRI != None)
   {
       PRI.PlayerName = PlayerName;
       PRI.bIsSpectator = bIsSpectator;
       PRI.bBot = bBot;
       PRI.NumLives = NumLives;
       PRI.MonsterHealth = MonsterHealth;
       PRI.MonsterHealthMax = MonsterHealthMax;
       PRI.Score = Score;
       PRI.MyMonster = MyMonster;
       PRI.bMinion = bMinion;

       if(Team != None)
       {
           PRI.Team = Team;
           PRI.Team.Score = Team.Score;
       }
   }
}

simulated function Destroyed()
{
   if(PRI != None)
   {
       PRI.Destroy();
   }

    Super(ReplicationInfo).Destroyed();
}

defaultproperties
{
     NumLives=1
     CharacterName="Monster"
     bIsSpectator=True
     bBot=True
     bWelcomed=True
     RemoteRole=ROLE_None
}
