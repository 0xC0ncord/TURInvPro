//=============================================================================
// InvasionProMVPMessage.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProMVPMessage extends InvasionProBossMessage;

var localized string MVPMessage;

static function string GetString(optional int Switch,optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2,optional Object OptionalObject)
{
    if(Switch == 0 || RelatedPRI_1 == None)
        return "";

    return Repl(Repl(default.MVPMessage,"$1",RelatedPRI_1.PlayerName),"$2",Switch);
}

defaultproperties
{
    MVPMessage="$1 dealt $2 total damage to the boss(es) this wave."
    PosY=0.7000000
    FontSize=0
    Lifetime=5.000000
}
