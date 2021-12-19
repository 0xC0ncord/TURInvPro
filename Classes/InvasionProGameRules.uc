//=============================================================================
// InvasionProGameRules.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProGameRules extends GameRules;

var InvasionPro InvPro;

struct DamageStruct
{
  var PlayerReplicationInfo PRI;
  var int Damage;
};
var array<DamageStruct> DamageArray;

function int NetDamage(int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    local int i;
    local bool bFound;

    if(NextGameRules != None)
       Damage = NextGameRules.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

    if(!InvPro.bBossActive || Injured == instigatedBy
       || Injured == None || instigatedBy == None
       || Injured.Controller == None
       || instigatedBy.Controller == None
       || instigatedBy.PlayerReplicationInfo == None
       || Damage <= 0 || Injured.Health <= 0)
           return Damage;

    if(Monster(Injured) != None && InvPro.MonsterIsBoss(Monster(Injured)))
    {
       if(DamageArray.Length == 0)
       {
           DamageArray.Length = 1;
           if(InvasionProFriendlyMonsterReplicationInfo(InstigatedBy.PlayerReplicationInfo) == None)
               DamageArray[0].PRI = InstigatedBy.PlayerReplicationInfo;
           else
               DamageArray[0].PRI = InvasionProFriendlyMonsterReplicationInfo(InstigatedBy.PlayerReplicationInfo).PRI;
           DamageArray[0].Damage = Damage;
       }
   else
    {
        for(i = 0; i < DamageArray.Length; i++)
        {
           if((InvasionProFakeFriendlyMonsterReplicationInfo(DamageArray[i].PRI) == None && DamageArray[i].PRI == InstigatedBy.PlayerReplicationInfo)
           || InvasionProFakeFriendlyMonsterReplicationInfo(DamageArray[i].PRI) != None && InvasionProFakeFriendlyMonsterReplicationInfo(DamageArray[i].PRI).MyMonster == InstigatedBy)
           {
               bFound=true;
               DamageArray[i].Damage += Damage;
               break;
           }
       }
       if(!bFound)
       {
           i = DamageArray.Length;
           DamageArray.Length = i + 1;
           if(InvasionProFriendlyMonsterReplicationInfo(InstigatedBy.PlayerReplicationInfo)==None)
               DamageArray[0].PRI = InstigatedBy.PlayerReplicationInfo;
           else
               DamageArray[0].PRI = InvasionProFriendlyMonsterReplicationInfo(InstigatedBy.PlayerReplicationInfo).PRI;
           DamageArray[i].Damage=Damage;
       }
       }
   }

   return Damage;
}

defaultproperties
{
}
