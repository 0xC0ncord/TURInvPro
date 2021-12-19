//=============================================================================
// InvasionProBossReplicationInfo.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProBossReplicationInfo extends PlayerReplicationInfo;

var() Monster MyMonster;

/*replication
{
    reliable if(Role == ROLE_Authority)
       MyMonster;
}*/

event PostBeginPlay()
{}

simulated event PostNetBeginPlay()
{
   /* local GameReplicationInfo GRI;

    if ( Level.GRI != None )
        Level.GRI.AddPRI(self);
    else
    {
        ForEach DynamicActors(class'GameReplicationInfo',GRI)
        {
            GRI.AddPRI(self);
            break;
        }
    }*/
}

simulated function bool NeedNetNotify()
{
    return false;
}

simulated event PostNetReceive()
{}

simulated function Destroyed()
{
   /*
    local GameReplicationInfo GRI;

    if ( Level.GRI != None )
        Level.GRI.RemovePRI(self);
    else
    {
        ForEach DynamicActors(class'GameReplicationInfo',GRI)
        {
            GRI.RemovePRI(self);
            break;
        }
    }

    if ( VoiceInfo == None )
        foreach DynamicActors( class'VoiceChatReplicationInfo', VoiceInfo )
            break;

    if ( VoiceInfo != None )
        VoiceInfo.RemoveVoiceChatter(Self);*/

    Super.Destroyed();
}

function SetCharacterVoice(string S)
{}

function SetCharacterName(string S)
{}

function Reset()
{}

simulated function string GetHumanReadableName()
{
    return PlayerName;
}

simulated function string GetLocationName()
{
    return Super.GetLocationName();
}

simulated function material GetPortrait()
{
    return None;
}

event UpdateCharacter();

function UpdatePlayerLocation()
{}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{}

event ClientNameChange()
{}

simulated function Timer()
{
    Destroy();
}

function SetPlayerName(string S)
{}

function SetWaitingPlayer(bool B)
{}

function SetChatPassword( string InPassword )
{}

function SetVoiceMemberMask( int NewMask )
{}

simulated function string GetCallSign()
{
    return Super.GetCallSign();
}

simulated event string GetNameCallSign()
{
    return Super.GetNameCallSign();
}

defaultproperties
{
     NumLives=1
     bIsSpectator=True
     bBot=True
}
