//=============================================================================
// LocalMessage_PreloadComplete.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class LocalMessage_PreloadComplete extends LocalMessage;

static function color GetConsoleColor( PlayerReplicationInfo RelatedPRI_1 )
{
    return Default.DrawColor;
}

static function string GetString(
   optional int Switch,
   optional PlayerReplicationInfo RelatedPRI_1,
   optional PlayerReplicationInfo RelatedPRI_2,
   optional Object OptionalObject
   )
{
       return "Preloading complete!";
}

defaultproperties
{
     bIsSpecial=True
     DrawColor=(A=255,R=255,G=255,B=255)
     bIsConsoleMessage=False
     StackMode=2
     PosY=0.825000
     bFadeMessage=True
     FontSize=6
}
