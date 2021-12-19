//=============================================================================
// InvasionProPreloadInfo.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProPreloadInfo extends Info;

enum EPreloadStyle
{
    PS_All,
    PS_Reduced,
    PS_Disabled
};

var() int TotalCount;
var() int MonsterTableLength;
var() int Count;
var() int NumNow;
var() bool bStarted;
var() string LoadingNow;
var() string LoadingNext;
var() InvasionProPreloadInfo.EPreloadStyle PreloadStyle;

replication
{
    reliable if(Role == ROLE_Authority)
        ClientNotifyFinish, ClientPreloadObject,
        TotalCount;
}

function Init()
{
    if(InvasionPro(Level.Game) == none)
    {
        Destroy();
        return;
    }
    if(PreloadStyle == PS_All)
    {
        MonsterTableLength = class'InvasionProMonsterTable'.default.MonsterTable.Length;
    }
    else
    {
        MonsterTableLength = InvasionPro(Level.Game).ReducedPreloadList.Length;
    }
    TotalCount = MonsterTableLength + class'InvasionPro'.default.AdditionalPreloads.Length;
}

simulated function PostNetBeginPlay()
{
    if(Controller(Owner) != none)
    {
        InvasionProXPlayer(Owner).Preloader = self;
    }
}

function Timer()
{
    if(Owner == none)
    {
        Destroy();
    }
}

function SendServerAReplyFM(int Num)
{
}

simulated function ClientPreloadObject(int MNum, string SMName)
{
    local class<Actor> SMA;

    if(Level.NetMode == NM_DedicatedServer)
    {
        return;
    }
    if(!InvasionProHud(PlayerController(Owner).myHUD).bLoadingStarted)
    {
        InvasionProHud(PlayerController(Owner).myHUD).StartLoading();
    }
    if(MNum != NumNow)
    {
        if(MNum > NumNow)
        {
            SendServerAReplyFM(NumNow);
        }
        return;
    }
    if(LoadingNow == "")
    {
        LoadingNow = SMName;
        NumNow++;
        return;
    }
    LoadingNow = LoadingNext;
    LoadingNext = SMName;
    if(LoadingNow != "")
    {
        SMA = class<Actor>(DynamicLoadObject(LoadingNext, class'Class', true));
    }
    if(SMA != none)
    {
        AddToMemory(SMA);
    }
    NumNow++;
    LoadingNext = SMName;
}

simulated function AddToMemory(class<Actor> A)
{
}

simulated function ClientNotifyFinish()
{
    if(Level.NetMode == NM_DedicatedServer)
    {
        return;
    }
    if(InvasionProXPlayer(Owner) != none)
    {
        InvasionProXPlayer(Owner).bMeshesLoaded = true;
        InvasionProXPlayer(Owner).Preloader = none;
        InvasionProXPlayer(Owner).ReceiveLocalizedMessage(class'LocalMessage_PreloadComplete');
        Destroy();
    }
}

auto state Initializing
{
Begin:
    Sleep(5.0);
    Timer();
    SetTimer(4.0, true);
    GotoState('Replicating');
    stop;
}

state Replicating
{
    function SendServerAReplyFM(int Num)
    {
        Count = Clamp(Num, 0, TotalCount - 1);
        GotoState('Replicating', 'RetryDL');
    }

Begin:
    Sleep(5.0);
    Timer();
    Sleep(6.0);
    Timer();

   for(Count = 0; Count < TotalCount; Count++)
    {
RetryDL:

        Timer();
        if(Count < MonsterTableLength)
        {
            if(PreloadStyle == PS_All)
            {
                ClientPreloadObject(Count, class'InvasionProMonsterTable'.default.MonsterTable[Count].MonsterClassName);
            }
            else
            {
                ClientPreloadObject(Count, InvasionPro(Level.Game).ReducedPreloadList[Count]);
            }
        }
        else
        {
            ClientPreloadObject(Count, class'InvasionPro'.default.AdditionalPreloads[Count - MonsterTableLength]);
        }
        Sleep(0.20);
    }
    ClientNotifyFinish();
    Sleep(5.0);
    Destroy();
    SetTimer(4.0, true);
    GotoState('None');
    stop;
}

defaultproperties
{
    DrawType=DT_None
    bOnlyRelevantToOwner=true
    bAlwaysRelevant=true
    bSkipActorPropertyReplication=false
    RemoteRole=ROLE_SimulatedProxy
}
