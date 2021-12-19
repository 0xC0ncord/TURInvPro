//=============================================================================
// InvasionProxPawn.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProxPawn extends xPawn;

function DeactivateSpawnProtection()
{
   if(Controller != None && InvasionProXPlayer(Controller) != None && Level.TimeSeconds - SpawnTime < InvasionProGameReplicationInfo(InvasionProXPlayer(Controller).GameReplicationInfo).SpawnProtection)
   {
       return;
   }

    SpawnTime = -100000;
}

exec function NextItem()
{
   if(Inventory != None)
   {
       if (SelectedItem==None)
       {
           SelectedItem = Inventory.SelectNext();
           return;
       }

       if (SelectedItem.Inventory!=None)
       {
           SelectedItem = SelectedItem.Inventory.SelectNext();
       }
       else
       {
           SelectedItem = Inventory.SelectNext();
       }

       if ( SelectedItem == None )
       {
           SelectedItem = Inventory.SelectNext();
       }
   }
}

simulated exec function SetHud()
{
   MenuHud();
}

simulated exec function MenuHud()
{
   if(Controller != None)
   {
       InvasionProXPlayer(Controller).ClientOpenMenu("TURInvPro.InvasionProHudConfig");
   }
}

simulated function DrawHUD(Canvas Canvas);

//bot combos
function DoComboName( string ComboClassName )
{
    local class<Combo> ComboClass;

   if(Controller != None)
   {
       ComboClass = class<Combo>( DynamicLoadObject( ComboClassName, class'Class',true) );
       if ( ComboClass != None)
       {
           DoCombo( ComboClass );
       }
       else
       {
           log("Couldn't create combo "$ComboClassName,'InvasionPro');
       }
   }
}

function PlayDyingAnimation(class<DamageType> DamageType, vector HitLoc)
{
    local vector shotDir, hitLocRel, deathAngVel, shotStrength;
    local float maxDim;
    local string RagSkelName;
    local KarmaParamsSkel skelParams;
    local bool PlayersRagdoll;
    local PlayerController pc;

    if ( Level.NetMode != NM_DedicatedServer )
    {
        // Is this the local player's ragdoll?
        if(OldController != None)
            pc = PlayerController(OldController);
        if( pc != None && pc.ViewTarget == self )
            PlayersRagdoll = true;

        // In low physics detail, if we were not just controlling this pawn,
        // and it has not been rendered in 3 seconds, just destroy it.
        if( (Level.PhysicsDetailLevel != PDL_High) && !PlayersRagdoll && (Level.TimeSeconds - LastRenderTime > 3) )
        {
            Destroy();
            return;
        }

        // Try and obtain a rag-doll setup. Use optional 'override' one out of player record first, then use the species one.
        if( RagdollOverride != "")
            RagSkelName = RagdollOverride;
        else if(Species != None)
            RagSkelName = Species.static.GetRagSkelName( GetMeshName() );
        else
            Log("xPawn.PlayDying: No Species",'InvasionPro');

        // If we managed to find a name, try and make a rag-doll slot availbale.
        if( RagSkelName != "" )
        {
            KMakeRagdollAvailable();
        }

        if( KIsRagdollAvailable() && RagSkelName != "" )
        {
            skelParams = KarmaParamsSkel(KParams);
            skelParams.KSkeleton = RagSkelName;

            // Stop animation playing.
            StopAnimating(true);

            if( DamageType != None )
            {
                if ( DamageType.default.bLeaveBodyEffect )
                    TearOffMomentum = vect(0,0,0);

                if( DamageType.default.bKUseOwnDeathVel )
                {
                    RagDeathVel = DamageType.default.KDeathVel;
                    RagDeathUpKick = DamageType.default.KDeathUpKick;
                }
            }

            // Set the dude moving in direction he was shot in general
            shotDir = Normal(TearOffMomentum);
            shotStrength = RagDeathVel * shotDir;

            // Calculate angular velocity to impart, based on shot location.
            hitLocRel = TakeHitLocation - Location;

            // We scale the hit location out sideways a bit, to get more spin around Z.
            hitLocRel.X *= RagSpinScale;
            hitLocRel.Y *= RagSpinScale;

            // If the tear off momentum was very small for some reason, make up some angular velocity for the pawn
            if( VSize(TearOffMomentum) < 0.01 )
            {
                //Log("TearOffMomentum magnitude of Zero");
                deathAngVel = VRand() * 18000.0;
            }
            else
            {
                deathAngVel = RagInvInertia * (hitLocRel Cross shotStrength);
            }

            // Set initial angular and linear velocity for ragdoll.
            // Scale horizontal velocity for characters - they run really fast!
            if ( DamageType != None && DamageType.Default.bRubbery )
                skelParams.KStartLinVel = vect(0,0,0);
            if ( DamageType != None && Damagetype.default.bKUseTearOffMomentum )
                skelParams.KStartLinVel = TearOffMomentum + Velocity;
            else
            {
                skelParams.KStartLinVel.X = 0.6 * Velocity.X;
                skelParams.KStartLinVel.Y = 0.6 * Velocity.Y;
                skelParams.KStartLinVel.Z = 1.0 * Velocity.Z;
                    skelParams.KStartLinVel += shotStrength;
            }
            // If not moving downwards - give extra upward kick
            if( DamageType != None && !DamageType.default.bLeaveBodyEffect && !DamageType.Default.bRubbery && (Velocity.Z > -10) )
                skelParams.KStartLinVel.Z += RagDeathUpKick;

            if ( DamageType != None && DamageType.Default.bRubbery )
            {
                Velocity = vect(0,0,0);
                skelParams.KStartAngVel = vect(0,0,0);
            }
            else
            {
                skelParams.KStartAngVel = deathAngVel;

                // Set up deferred shot-bone impulse
                maxDim = Max(CollisionRadius, CollisionHeight);

                skelParams.KShotStart = TakeHitLocation - (1 * shotDir);
                skelParams.KShotEnd = TakeHitLocation + (2*maxDim*shotDir);
                skelParams.KShotStrength = RagShootStrength;
            }

            // If this damage type causes convulsions, turn them on here.
            if(DamageType != None && DamageType.default.bCauseConvulsions)
            {
                RagConvulseMaterial=DamageType.default.DamageOverlayMaterial;
                skelParams.bKDoConvulsions = true;
            }

            // Turn on Karma collision for ragdoll.
            KSetBlockKarma(true);

            // Set physics mode to ragdoll.
            // This doesn't actaully start it straight away, it's deferred to the first tick.
            SetPhysics(PHYS_KarmaRagdoll);

            // If viewing this ragdoll, set the flag to indicate that it is 'important'
            if( PlayersRagdoll )
                skelParams.bKImportantRagdoll = true;

           if(DamageType != None)
           {
               skelParams.bRubbery = DamageType.default.bRubbery;
               bRubbery = DamageType.default.bRubbery;
           }

            skelParams.KActorGravScale = RagGravScale;

            return;
        }
        // jag
    }

    // non-ragdoll death fallback
    Velocity += TearOffMomentum;
    BaseEyeHeight = Default.BaseEyeHeight;
    SetTwistLook(0, 0);
    SetInvisibility(0.0);
    PlayDirectionalDeath(HitLoc);
    SetPhysics(PHYS_Falling);
}

simulated function bool IsDriving()
{
   if(DrivenVehicle != None)
   {
       return true;
   }

   return false;
}

defaultproperties
{
}
