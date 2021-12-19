//=============================================================================
// Util.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

/*
   class holding static utility functions
*/

class Util extends Object abstract;

static final function int InArray(Object x, array<Object> a)
{
   local int i;

   for(i = 0; i < a.Length; i++)
   {
       if(a[i] == x)
           return i;
   }

   return -1;
}

static final function bool MonsterIsBoss(Monster M)
{
   local InvasionProMonsterIDInv Inv;

   if(M==None)
       return false;

   Inv = InvasionProMonsterIDInv(M.FindInventoryType(class'InvasionProMonsterIDInv'));
   return (Inv!=None && Inv.bBoss);
}

defaultproperties
{
}
