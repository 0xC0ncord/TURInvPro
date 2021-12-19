//=============================================================================
// InvasionProWaveMessage.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProWaveMessage extends CriticalEventPlus;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
   if (InvasionProGameReplicationInfo(OptionalObject) != None)
   {
       return InvasionProGameReplicationInfo(OptionalObject).WaveName;
   }
}

defaultproperties
{
     bIsConsoleMessage=False
     Lifetime=2
     DrawColor=(R=0,G=0,B=255,A=255)
     StackMode=SM_Down
     PosY=0.150000
     FontSize=5
}
