//=============================================================================
// InvasionProNaliCowInv.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//---- this makes the cows stop attracting monsters to them
class InvasionProNaliCowInv extends Inventory;

var() Monster M;

function GiveTo(Pawn Other, optional Pickup Pickup)
{
   if( Monster(Other) != None)
   {
       M = Monster(Other);
       Super.GiveTo(Other);
   }
   else
   {
       destroy();
       return;
   }
}

simulated function Tick(float DeltaTime)
{
   super.Tick(DeltaTime);

   if(M != None && M.Health > 0)
   {
       M.SetTimer(0,false);
       M.Disable('Tick');

       if( M.Mesh == vertmesh'SkaarjPack_rc.NaliCow')
       {
           Disable('Tick');
           return;
       }

       if(M.Physics != PHYS_Falling)
       {
           M.Velocity.Z = 0;
       }

       if(VSize(M.Velocity) > 70  && M.Physics != PHYS_Falling)
       {
           M.DoJump(true);
       }
   }
}

defaultproperties
{
     ItemName="NaliRabbitTag"
     bOnlyRelevantToOwner=False
     bAlwaysRelevant=True
     bReplicateInstigator=True
}
