//=============================================================================
// InvasionProMonsterReplicationInfo.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProMonsterReplicationInfo extends ReplicationInfo;

var() string MonsterClassName[$$__INVPRO_MAX_MONSTER_TABLE_LEN__$$];
var() string MonsterName[$$__INVPRO_MAX_MONSTER_TABLE_LEN__$$];
var() float MonsterGibSize[$$__INVPRO_MAX_MONSTER_TABLE_LEN__$$];
var() int MonsterGibCount[$$__INVPRO_MAX_MONSTER_TABLE_LEN__$$];

var() string BossMonsterName[$$__INVPRO_MAX_MONSTER_TABLE_LEN__$$];
var() float BossMonsterGibSize[$$__INVPRO_MAX_MONSTER_TABLE_LEN__$$];
var() float BossMonsterGibCount[$$__INVPRO_MAX_MONSTER_TABLE_LEN__$$];

replication
{
    reliable if(Role == ROLE_Authority)
       MonsterClassName, MonsterGibSize, MonsterGibCount, MonsterName, BossMonsterName, BossMonsterGibSize, BossMonsterGibCount;
}

simulated function AddMonsterInfo(int Pos, string MName, string MClassName, float MSize, float MCount)
{
   MonsterName[Pos] = MName;
   MonsterClassName[Pos] = MClassName;
   MonsterGibSize[Pos] = MSize;
   MonsterGibCount[Pos] = Round(MCount);
}

simulated function AddBossInfo(int Pos, string BName, float BSize, float BCount)
{
   BossMonsterName[Pos] = BName;
   BossMonsterGibSize[Pos] = BSize;
   BossMonsterGibCount[Pos] = Round(BCount);
}

simulated function string GetMonsterClassName(int Pos)
{
   return MonsterClassName[Pos];
}

simulated function float GetGibSize(string MClass, bool bBoss)
{
   local int i;
   local string MonsterMatch;

   if(bBoss)
   {
       for(i = 0; i < $$__INVPRO_MAX_MONSTER_TABLE_LEN__$$; i++)
       {
           if(MonsterClassName[i] ~= MClass)
           {
               MonsterMatch = MonsterName[i];
               break;
           }
       }

       for(i = 0; i < $$__INVPRO_MAX_MONSTER_TABLE_LEN__$$; i++)
       {
           if(BossMonsterName[i] ~= MonsterMatch)
           {
               return BossMonsterGibSize[i];
           }
       }
   }

   for(i = 0; i < $$__INVPRO_MAX_MONSTER_TABLE_LEN__$$; i++)
   {
       if(MonsterClassName[i] ~= MClass)
       {
           return MonsterGibSize[i];
       }
   }

   return 1.00;
}

simulated function int GetGibCount(string MClass, bool bBoss)
{
   local int i;
   local string MonsterMatch;

   if(bBoss)
   {
       for(i = 0; i < $$__INVPRO_MAX_MONSTER_TABLE_LEN__$$; i++)
       {
           if(MonsterClassName[i] ~= MClass)
           {
               MonsterMatch = MonsterName[i];
               break;
           }
       }

       for(i = 0; i < $$__INVPRO_MAX_MONSTER_TABLE_LEN__$$; i++)
       {
           if(BossMonsterName[i] ~= MonsterMatch)
           {
               return BossMonsterGibCount[i];
           }
       }
   }

   for(i = 0; i < $$__INVPRO_MAX_MONSTER_TABLE_LEN__$$; i++)
   {
       if(MonsterClassName[i] ~= MClass)
       {
           return MonsterGibCount[i];
       }
   }

   return 1;
}

simulated function int GetLength()
{
   local int i;

   for(i = 0; i < $$__INVPRO_MAX_MONSTER_TABLE_LEN__$$; i++)
   {
       if(MonsterClassName[i] ~= "")
       {
           return i;
       }
   }

   return 1;
}

defaultproperties
{
}
