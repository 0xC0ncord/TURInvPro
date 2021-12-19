//=============================================================================
// TURTransRecall.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

// Coded by .:..:
Class TURTransRecall extends TransRecall;

// Disable glitching
function bool AttemptTranslocation(vector dest, TransBeacon TransBeacon)
{
   local vector OldLocation;

   OldLocation = Instigator.Location;
   if ( !TranslocSucceeded(dest,TransBeacon) )
       return false;
   if ( Instigator.FastTrace(Instigator.Location,dest) && Instigator.FastTrace(dest,Instigator.Location) // Make sure player dont translocate through terrain
    && Instigator.FastTrace(Instigator.Location-vect(0,0,0.999)*Instigator.CollisionHeight,Instigator.Location) ) // Make sure player feet dont go through terrain
       return true;
   Instigator.SetLocation(OldLocation);
   return false;
}

// Disable boss telefragging
function Translocate()
{
   local TransBeacon TransBeacon;
   local Actor HitActor;
   local Vector HitNormal,HitLocation,dest,Vel2D;
   local Vector PrevLocation,Diff, NewDest;
   local xPawn XP;
   local controller C;
   local bool bFailedTransloc;
   local int EffectNum;
   local float DiffZ;


   if ( (Instigator == None) || (Translauncher(Weapon) == None) )
       return;
   TransBeacon = TransLauncher(Weapon).TransBeacon;

   // gib if the translocator is disrupted
   if ( TransBeacon.Disrupted() )
   {
       UnrealMPGameInfo(Level.Game).SpecialEvent(Instigator.PlayerReplicationInfo,"translocate_gib");
       bGibMe = true; // delay gib to avoid destroying player and weapons right away in the middle of all this
       return;
   }

   dest = TransBeacon.Location;
   if ( TransBeacon.Physics == PHYS_None )
       dest += vect(0,0,1) * Instigator.CollisionHeight;
   else dest += vect(0,0,0.5) * Instigator.CollisionHeight;
   HitActor = Weapon.Trace(HitLocation,HitNormal,dest,TransBeacon.Location,true);
   if ( HitActor != None )
       dest = TransBeacon.Location;

   TransBeacon.SetCollision(false, false, false);

   if (Instigator.PlayerReplicationInfo.HasFlag != None)
       Instigator.PlayerReplicationInfo.HasFlag.Drop(0.5 * Instigator.Velocity);

   PrevLocation = Instigator.Location;

   // verify won't telefrag teammate or recently spawned player
   for ( C=Level.ControllerList; C!=None; C=C.NextController )
       if ( (C.Pawn != None) && (C.Pawn != Instigator) )
       {
           Diff = Dest - C.Pawn.Location;
           DiffZ = Diff.Z;
           Diff.Z = 0;
           if ( (Abs(DiffZ) < C.Pawn.CollisionHeight + 2 * Instigator.CollisionHeight)
               && (VSize(Diff) < C.Pawn.CollisionRadius + Instigator.CollisionRadius + 8) )
           {
               if ( !MayTelefragThis(C.Pawn) || (C.SameTeamAs(Instigator.Controller) || (Level.TimeSeconds - C.Pawn.SpawnTime < DeathMatch(Level.Game).SpawnProtectionTime)) )
               {
                   bFailedTransloc = true;
                   break;
               }
               else
               {
                   if ( DiffZ > 1.5 * C.Pawn.CollisionHeight )
                   {
                       NewDest = Dest;
                       NewDest.Z += 0.7 * C.Pawn.CollisionHeight;
                   }
                   else
                       NewDest = Dest + 0.5 * C.Pawn.CollisionRadius * Normal(Diff);
                   if ( Weapon.FastTrace(NewDest ,dest) )
                       Dest = NewDest;
               }
           }
       }

   if ( !bFailedTransloc && AttemptTranslocation(dest,TransBeacon) )
   {
       TransLauncher(Weapon).ReduceAmmo();

       // spawn out
       XP = xPawn(Instigator);
       if( XP != None )
           XP.DoTranslocateOut(PrevLocation);

       // bound XY velocity to prevent cheats
       Vel2D = Instigator.Velocity;
       Vel2D.Z = 0;
       Vel2D = Normal(Vel2D) * FMin(Instigator.GroundSpeed,VSize(Vel2D));
       Vel2D.Z = Instigator.Velocity.Z;
       Instigator.Velocity = Vel2D;

       if ( Instigator.PlayerReplicationInfo.Team != None )
           EffectNum = Instigator.PlayerReplicationInfo.Team.TeamIndex;

       Instigator.SetOverlayMaterial( TransMaterials[EffectNum], 1.0, false );
       Instigator.PlayTeleportEffect( false, false);

       if ( !Instigator.PhysicsVolume.bWaterVolume )
       {
           if ( Bot(Instigator.Controller) != None )
           {
               Instigator.Velocity.X = 0;
               Instigator.Velocity.Y = 0;
               Instigator.Velocity.Z = -150;
               Instigator.Acceleration = vect(0,0,0);
           }
           Instigator.SetPhysics(PHYS_Falling);
       }
       if ( UnrealTeamInfo(Instigator.PlayerReplicationInfo.Team)!= None )
           UnrealTeamInfo(Instigator.PlayerReplicationInfo.Team).AI.CallForBall(Instigator);  // for bombing run
   }
   else if( PlayerController(Instigator.Controller) != None )
       PlayerController(Instigator.Controller).ClientPlaySound(TransFailedSound);

   TransBeacon.Destroy();
   TransLauncher(Weapon).TransBeacon = None;
   TransLauncher(Weapon).ViewPlayer();
}
function bool MayTelefragThis( Pawn Other )
{
   if( InvasionPro(Level.Game)!=None && !InvasionPro(Level.Game).MayBeTelefragged(Instigator,Other) )
       Return False;
   Return True;
}

defaultproperties
{
}
