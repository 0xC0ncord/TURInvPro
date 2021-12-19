//=============================================================================
// InvasionProMetalGibOrganicTorso.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProMetalGibOrganicTorso extends GibOrganicGreenTorso;

simulated function PostBeginPlay()
{
   local Monster M;
   local InvasionProMonsterReplicationInfo IGI;
   local int i;
   local InvasionProMetalGibOrganicLesser Gibble;
   local float NewDrawScale;

   if(Instigator != None)
   {
       M = Monster(Instigator);
       foreach DynamicActors(class'InvasionProMonsterReplicationInfo', IGI)
       {
           NewDrawScale = DrawScale * IGI.GetGibSize(string(M.Class),M.bBoss);
           for(i=0;i<IGI.GetGibCount(string(M.Class),M.bBoss);i++)
           {
               Gibble = Spawn(class'InvasionProMetalGibOrganicLesser',Self,,Location,Rotation);
               if(Gibble != None)
               {
                   Gibble.SetDrawScale(NewDrawScale);
                   Gibble.SetStaticMesh(StaticMesh);
               }
           }
       }
   }

   Super.PostBeginPlay();
}

defaultproperties
{
    GibGroupClass=Class'TURInvPro.InvasionProMetalGibGroupClass'
    TrailClass=None
    HitSounds(0)=None
    HitSounds(1)=None
    bHidden=True
    CollisionRadius=0.000000
    CollisionHeight=0.000000
}
