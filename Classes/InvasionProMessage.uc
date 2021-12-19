//=============================================================================
// InvasionProMessage.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProMessage extends CriticalEventPlus;

var(Message) localized string OutMessage;
var() string FriendlyOutMessage;

static function string GetString(optional int Switch,optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2,optional Object OptionalObject)
{
    local string FinalName;
    local array<String> MonsterName;

    switch (Switch)
    {
        case 1:
            if(RelatedPRI_1 != None)
            {
                return RelatedPRI_1.PlayerName@default.OutMessage;
            }
            else if(Monster(OptionalObject) != None)
            {
                Split(String(Monster(OptionalObject).Class), ".", MonsterName);
                if(MonsterName.Length > 1 && MonsterName[1] != "" && MonsterName[1] != "None")
                {
                    FinalName = MonsterName[1];
                    if(InStr(FinalName,"SMP")!=-1)
                        ReplaceText( FinalName, "SMP", "");
                    else if(InStr(FinalName,"SSP")!=-1)
                        ReplaceText( FinalName, "SSP", "");
                    else if(InStr(FinalName,"MorphMonster_")!=-1)
                        ReplaceText( FinalName, "MorphMonster_", "");
                    else if(InStr(FinalName,"Conjurer_")!=-1)
                        ReplaceText( FinalName, "Conjurer_", "");
                }
                else
                {
                    FinalName = "Monster";
                }
                return FinalName@default.OutMessage;
            }
            else
            {
                return default.FriendlyOutMessage;
            }
            break;
        default:
            break;
    }
}

defaultproperties
{
    OutMessage="is OUT!"
    FriendlyOutMessage="Friendly Monster is OUT!"
    StackMode=SM_Down
    PosY=0.650000
}
