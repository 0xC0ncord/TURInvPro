//=============================================================================
// InvasionProXPlayer.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProXPlayer extends xPlayer;

var() Sound KillSound;
var() bool bMeshesLoaded;
var() bool bLoadMeshes;
var() Sound RadarPulseSound;
var() float CrosshairMaxDistance;
var() float CrosshairSizeScale;
var() float CrosshairMinSize;
var() float CrosshairMaxSize;
var() bool bSpecMonsters;
var() bool bLoadingStarted;
var() InvasionProPreloadInfo Preloader;
var() float NextHitSoundTime;
var() bool bWaitingOnGrouping;
var() bool bWaitingEnemy;
var() int DelayedDamageTotal;
var() float WaitingOnGroupingTime;
var() bool bClientReady;

replication
{
    unreliable if(Role == ROLE_Authority)
        ClientHitSound, ClientPlayKillSound;

    reliable if(Role == ROLE_Authority && bNetInitial)
        bLoadMeshes;

    reliable if(Role < ROLE_Authority)
        ServerNotifyReady, SetSpecMonsters,
        StartPreloading, UpdatePlayerHealth,
        bMeshesLoaded, bSpecMonsters;
}

simulated function SetSpecMonsters(bool bSpec)
{
   bSpecMonsters = bSpec;
}

function ClientRestart(Pawn NewPawn)
{
   Super.ClientRestart(NewPawn);

   if(InvasionProHud(myHUD) != None && InvasionProHud(myHUD).bStartThirdPerson && AllowBehindView())
   {
       bBehindView = true;
       BehindView(bBehindView);

       if(InvasionProHud(myHUD).RadarSound != "" && InvasionProHud(myHUD).RadarSound != "None")
       {
           RadarPulseSound = Sound(DynamicLoadObject(InvasionProHud(myHUD).RadarSound, class'Sound',true));
           InvasionProHud(myHUD).PulseSound = RadarPulseSound;
       }
   }
}

function bool AllowBehindView()
{
   if(InvasionProHud(myHUD) != None)
   {
       return true;
   }

   return false;
}

function Possess(Pawn aPawn)
{
   if ( PlayerReplicationInfo.bOnlySpectator )
   {
       return;
   }

   Super.Possess(aPawn);
}

simulated function StartPreloading(InvasionProPreloadInfo.EPreloadStyle PreloadStyle)
{
   if(Role == ROLE_Authority || PreloadStyle == PS_Disabled)
       return;

    Preloader = Spawn(class'InvasionProPreloadInfo', self);
    Preloader.PreloadStyle = PreloadStyle;
    Preloader.Init();
}

function SpawnFakeCrosshair()
{
   if(Level.GetLocalPlayerController() != self)
   {
       return;
   }
}

function rotator AdjustAim(FireProperties FiredAmmunition, vector projStart, int aimerror)
{
    local vector FireDir, AimSpot, HitNormal, HitLocation, OldAim, AimOffset;
    local actor BestTarget;
    local float bestAim, bestDist, projspeed;
    local actor HitActor;
    local bool bNoZAdjust, bLeading;
    local rotator AimRot;

   if(Vehicle(Pawn) == None && (InvasionProGameReplicationInfo(GameReplicationInfo)==None || InvasionProGameReplicationInfo(GameReplicationInfo).bAerialView))
   {
       FireDir = vector(Rotation);
       if ( FiredAmmunition.bInstantHit )
       {
           HitActor = Trace(HitLocation, HitNormal, projStart + 10000 * FireDir, projStart, true);
       }
       else
       {
           HitActor = Trace(HitLocation, HitNormal, projStart + 4000 * FireDir, projStart, true);
       }

       if ( (HitActor != None) && HitActor.bProjTarget )
       {
           BestTarget = HitActor;
           bNoZAdjust = true;
           OldAim = HitLocation;
           BestDist = VSize(BestTarget.Location - Pawn.Location);
       }
       else
       {
           bestAim = 0.90;
           if ( (Level.NetMode == NM_Standalone) && bAimingHelp )
           {
               bestAim = 0.93;
               if ( FiredAmmunition.bInstantHit )
               {
                   bestAim = 0.97;
               }
               if ( FOVAngle < DefaultFOV - 8 )
               {
                   bestAim = 0.99;
               }
           }
           else if ( FiredAmmunition.bInstantHit )
           {
               bestAim = 1.0;
           }

           BestTarget = PickTarget(bestAim, bestDist, FireDir, projStart, FiredAmmunition.MaxRange);
           if ( BestTarget == None )
           {
               return Rotation;
           }
           OldAim = projStart + FireDir * bestDist;
       }
       InstantWarnTarget(BestTarget,FiredAmmunition,FireDir);
       ShotTarget = Pawn(BestTarget);
       if ( !bAimingHelp || (Level.NetMode != NM_Standalone) )
       {
           return Rotation;
       }

       if ( !FiredAmmunition.bInstantHit )
       {
           projspeed = FiredAmmunition.ProjectileClass.default.speed;
           BestDist = vsize(BestTarget.Location + BestTarget.Velocity * FMin(1, 0.02 + BestDist/projSpeed) - projStart);
           bLeading = true;
           FireDir = BestTarget.Location + BestTarget.Velocity * FMin(1, 0.02 + BestDist/projSpeed) - projStart;
           AimSpot = projStart + bestDist * Normal(FireDir);
           if ( FiredAmmunition.bTrySplash
               && ((BestTarget.Velocity != vect(0,0,0)) || (BestDist > 1500)) )
           {
               HitActor = Trace(HitLocation, HitNormal, AimSpot - BestTarget.CollisionHeight * vect(0,0,2), AimSpot, false);
               if ( (HitActor != None) && FastTrace(HitLocation + vect(0,0,4),projstart) )
               {
                   return rotator(HitLocation + vect(0,0,6) - projStart);
               }
           }
       }
       else
       {
           FireDir = BestTarget.Location - projStart;
           AimSpot = projStart + bestDist * Normal(FireDir);
       }
       AimOffset = AimSpot - OldAim;

       if ( bNoZAdjust || (bLeading && (Abs(AimOffset.Z) < BestTarget.CollisionHeight)) )
       {
           AimSpot.Z = OldAim.Z;
       }
       else if ( AimOffset.Z < 0 )
       {
           AimSpot.Z = BestTarget.Location.Z + 0.4 * BestTarget.CollisionHeight;
       }
       else
       {
           AimSpot.Z = BestTarget.Location.Z - 0.7 * BestTarget.CollisionHeight;
       }
       if ( !bLeading )
       {
           if ( !bNoZAdjust )
           {
               AimRot = rotator(AimSpot - projStart);
               if ( FOVAngle < DefaultFOV - 8 )
               {
                   AimRot.Yaw = AimRot.Yaw + 200 - Rand(400);
               }
               else
               {
                   AimRot.Yaw = AimRot.Yaw + 375 - Rand(750);
               }

               return AimRot;
           }
       }
       else if ( !FastTrace(projStart + 0.9 * bestDist * Normal(FireDir), projStart) )
       {
           FireDir = BestTarget.Location - projStart;
           AimSpot = projStart + bestDist * Normal(FireDir);
       }
       return rotator(AimSpot - projStart);
   }
   else
   {
       return Super.AdjustAim(FiredAmmunition, projStart, aimerror);
   }
}

event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation)
{
   local vector HitLocation, Hitnormal, EndTrace, StartTrace;
   local float Distance, CrosshairSizeDistance, CrosshairSize;

   Super.PlayerCalcView(ViewActor, CameraLocation, CameraRotation);

   if( (Vehicle(Pawn) != None) || ((InvasionProGameReplicationInfo(GameReplicationInfo) != None && !InvasionProGameReplicationInfo(GameReplicationInfo).bAerialView)) )
   {
       return;
   }

   if(bBehindView && Pawn != None && myHUD != None)
   {
       if(Trace(HitLocation, HitNormal, CameraLocation + (vect(0, 0, 65) >> CameraRotation), CameraLocation, false, vect(10, 10, 10)) != None)
       {
           CameraLocation += (HitLocation - CameraLocation) - (10 * normal(HitLocation - CameraLocation));
       }
       else
       {
           CameraLocation += vect(0,0,64) >> CameraRotation;
       }

       CalcBehindView(CameraLocation, CameraRotation, 0);

       StartTrace = Pawn.Location;
       StartTrace.Z += Pawn.BaseEyeHeight;
       EndTrace = StartTrace + vector(CameraRotation)*16384;

       if(Trace(HitLocation, HitNormal, EndTrace, StartTrace, true) == None)
       {
           HitLocation = EndTrace;
       }

       Distance = VSize(HitLocation - StartTrace);
       CrosshairSizeDistance = FMin(Distance, 10000);
       CrosshairSize = FMax(CrosshairSizeDistance/CrosshairSizeScale, CrosshairMinSize);
       CrosshairSize = FClamp(CrosshairSize, CrosshairMinSize, CrosshairMaxSize);
       InvasionProHud(myHUD).BehindViewCrosshairLocation = HitLocation - vector(CameraRotation)*FMax(CrosshairSizeDistance/CrosshairMaxDistance, CrosshairMaxDistance);
   }
}

simulated function ClientHideHealthPacks()
{
   local HealthCharger HC;

   foreach AllActors(class'HealthCharger', HC)
   {
       if(HC != None && HC.DrawType != DT_None)
       {
           HC.SetDrawType(DT_None);
       }
   }
}

simulated function ClientHideWeaponBases()
{
   local xWeaponBase xWB;

   foreach AllActors(class'xWeaponBase', xWB)
   {
       if(xWB != None && xWB.DrawType != DT_None)
       {
           xWB.SetDrawType(DT_None);
           xWB.SpiralEmitter = None;
           if(xWB.MyEmitter != None)
           {
               xWB.MyEmitter.Destroy();
           }
       }
   }
}

simulated function ClientHideSuperBases()
{
   local xPickUpBase xPB;

   foreach AllActors(class'xPickUpBase', xPB)
   {
       if(xPB != None && xPB.DrawType != DT_None)
       {
           if( HealthCharger(xPB)==None && xWeaponBase(xPB)==None )
           {
               xPB.SetDrawType(DT_None);

               xPB.SpiralEmitter = None;
               if(xPB.MyEmitter != None)
               {
                   xPB.MyEmitter.Destroy();
               }
           }
       }
   }
}

simulated function ClientPlayKillSound()
{
   if(ViewTarget!=None && InvasionProHUD(myHUD) != None && InvasionProHUD(myHUD).CurrentKillSound != "None" && InvasionProHUD(myHUD).CurrentKillSound != "")
   {
       KillSound = Sound(DynamicLoadObject(InvasionProHUD(myHUD).CurrentKillSound,class'Sound',false));
       if(KillSound != None)
       {
           ViewTarget.PlaySound(KillSound,,FClamp(InvasionProHUD(myHUD).KillSoundVolume,0,2));
       }
   }
}

function DoCombo( class<Combo> ComboClass )
{
   if (Adrenaline >= ComboClass.default.AdrenalineCost && !Pawn.InCurrentCombo() )
   {
       ServerDoCombo( ComboClass );
   }
}

function UpdatePlayerHealth(int Health, int HealthMax)
{
   if(Role == Role_Authority && InvasionProPlayerReplicationInfo(PlayerReplicationInfo) != None)
   {
       InvasionProPlayerReplicationInfo(PlayerReplicationInfo).PlayerHealth = Health;
       InvasionProPlayerReplicationInfo(PlayerReplicationInfo).PlayerHealthMax = HealthMax;
   }
}

event PlayerTick( float DeltaTime )
{
   if(InvasionProPlayerReplicationInfo(PlayerReplicationInfo) != None)
   {
       if(Pawn == None)
           UpdatePlayerHealth(0, 199);
       else
       {
           if(Vehicle(Pawn)!=None && Vehicle(Pawn).Driver!=None)
               UpdatePlayerHealth(Vehicle(Pawn).Driver.Health, Vehicle(Pawn).Driver.SuperHealthMax);
           else
               UpdatePlayerHealth(Pawn.Health, Pawn.SuperHealthMax);
       }
   }

    if((Role < ROLE_Authority) || Level.NetMode == NM_Standalone)
    {
        if(!bClientReady)
        {
            ServerNotifyReady();
        }
        if(!bLoadingStarted && !bMeshesLoaded && bLoadMeshes && InvasionProHud(myHUD) != None)
        {
            if(InvasionProHud(myHUD).PreloadStyle == PS_Disabled)
            {
                bLoadingStarted = true;
                bMeshesLoaded = true;
            }
            else
            {
                bLoadingStarted = true;
                StartPreloading(InvasionProHud(myHUD).PreloadStyle);
            }
        }
    }

   if ( bWaitingOnGrouping )
   {
       if ( Level.TimeSeconds > WaitingOnGroupingTime )
       {
           DelayedHitSound(DelayedDamageTotal,bWaitingEnemy);
           bWaitingOnGrouping = False;
           DelayedDamageTotal = 0;
       }
   }

   Super.PlayerTick(DeltaTime);
}

simulated function ServerNotifyReady()
{
    bClientReady = true;
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
    local VoicePack V;

    if ( (Sender == None) || (Sender.voicetype == None) || (Player == None) || (Player.Console == None) )
        return;

    V = Spawn(Sender.voicetype, self);
    if ( V != None )
        V.ClientInitialize(Sender, Recipient, messagetype, messageID);
}

//cancel hud/scoreboard changing unless extends invasionpro versions
//for custom huds/scoreboards try an overlay or extend Invasionprohud/invasionproscoreboard or ask ini for a possible update me@shaungoeppinger.com
simulated function ClientSetHUD(class<HUD> newHUDClass, class<Scoreboard> newScoringClass )
{
   local HUD NewHUD;

   if(newHUDClass != None)
   {
       if(ClassIsChildOf(newHUDClass, class'InvasionProHud') || InvasionPro(Level.Game)==None)
       {
           NewHUD = Spawn(newHUDClass, self);
           if (NewHUD == None)
           {
               log ("InvasionProXPlayer::ClientSetHUD(): Could not spawn a HUD of class "$newHUDClass, 'InvasionPro');
           }
           else
           {
               if ( myHUD != None )
               {
                   myHUD.Destroy();
               }

               myHUD = NewHUD;
           }
       }
   }

   if(newScoringClass != None)
   {
       if(ClassIsChildOf(newScoringClass, class'InvasionProScoreboard') || InvasionPro(Level.Game)==None)
       {
           if ( myHUD != None )
           {
               myHUD.SetScoreBoardClass( newScoringClass );
           }
       }
   }

   if( Level.Song != "" && Level.Song != "None" )
   {
       ClientSetInitialMusic( Level.Song, MTRAN_Fade );
   }
}

function ServerViewNextPlayer()
{
    local Controller C, Pick;
    local bool bFound, bRealSpec, bWasSpec;
   local TeamInfo RealTeam;

    bRealSpec = PlayerReplicationInfo.bOnlySpectator;
    bWasSpec = !bBehindView && (ViewTarget != Pawn) && (ViewTarget != self);
    PlayerReplicationInfo.bOnlySpectator = true;
    RealTeam = PlayerReplicationInfo.Team;

    // view next player
    for ( C=Level.ControllerList; C!=None; C=C.NextController )
    {
       if((MonsterController(C)==None && !C.IsA('SMPNaliFighterController')) || ((MonsterController(C)!=None || C.IsA('SMPNaliFighterController')) && bSpecMonsters))
       {
           if ( bRealSpec && (C.PlayerReplicationInfo != None) ) // hack fix for invasion spectating
           {
               PlayerReplicationInfo.Team = C.PlayerReplicationInfo.Team;
           }

           if ( Level.Game.CanSpectate(self,bRealSpec,C) )
           {
               if ( Pick == None )
               {
                   Pick = C;
               }
               if ( bFound )
               {
                   Pick = C;
                   break;
               }
               else
               {
                   bFound = ( (RealViewTarget == C) || (ViewTarget == C) );
               }
           }
       }
    }
    PlayerReplicationInfo.Team = RealTeam;
    SetViewTarget(Pick);
    ClientSetViewTarget(Pick);
    if ( (ViewTarget == self) || bWasSpec )
    {
        bBehindView = false;
   }
    else
    {
        bBehindView = true; //bChaseCam;
   }
    ClientSetBehindView(bBehindView);
    PlayerReplicationInfo.bOnlySpectator = bRealSpec;
}

function BecomeSpectator()
{
    if (Role < ROLE_Authority)
        return;

    if ( !Level.Game.BecomeSpectator(self) )
        return;

    if ( Pawn != None )
        Pawn.Died(self, class'DamageType', Pawn.Location);

    if ( PlayerReplicationInfo.Team != None )
        PlayerReplicationInfo.Team.RemoveFromTeam(self);
    PlayerReplicationInfo.Team = None;
    PlayerReplicationInfo.Score = 0;
    PlayerReplicationInfo.Deaths = 0;
    PlayerReplicationInfo.GoalsScored = 0;
    PlayerReplicationInfo.Kills = 0;
    PlayerReplicationInfo.NumLives = 0;
    ServerSpectate();
    BroadcastLocalizedMessage(Level.Game.GameMessageClass, 14, PlayerReplicationInfo);
    ClientBecameSpectator();
}

function ServerSpectate()
{
   Super.ServerSpectate();
   InvasionPro(Level.Game).UpdatePlayerGRI();
}

simulated function GroupDamageSound (int Damage, bool bEnemy)
{
   if(bWaitingOnGrouping && bWaitingEnemy!=bEnemy)
       return;
   bWaitingOnGrouping = True;
   bWaitingEnemy = bEnemy;
   DelayedDamageTotal += Damage;
   WaitingOnGroupingTime = Level.TimeSeconds + 0.03;
}

simulated function DelayedHitSound (int Damage, bool bEnemy)
{
   if ( bEnemy )
   {
       PlayEnemyHitSound(Damage);
   }
   else
   {
       PlayFriendlyHitSound(Damage);
   }
   DelayedDamageTotal = 0;
}

simulated function ClientHitSound(int Damage, bool bEnemy)
{
   if((InvasionProHud(myHUD).CurrentEnemyHitSound == "" && InvasionProHud(myHUD).CurrentFriendlyHitSound == "")|| Damage <= 0)
   {
       return;
   }

   if(Level.TimeSeconds < NextHitSoundTime)
   {
       GroupDamageSound(Damage,bEnemy);
       return;
   }

   if (bEnemy)
       PlayEnemyHitSound(Damage);
   else
       PlayFriendlyHitSound(Damage);
}

simulated function PlayEnemyHitSound(int Damage)
{
   local Sound HitSound;
   local float Pitch;

   if (ViewTarget != None)
   {
       HitSound = Sound(DynamicLoadObject(InvasionProHUD(myHUD).CurrentEnemyHitSound,class'Sound',false));
       if(InvasionProHUD(myHUD).bDynamicHitSounds)
           Pitch = (35.0 / Damage);
       else
           Pitch = 1.0;
       if(HitSound!=None)
           ViewTarget.PlaySound(HitSound, , FClamp(InvasionProHUD(myHUD).HitSoundVolume, 0, 2), , , Pitch);
   }
   NextHitSoundTime = Level.TimeSeconds + (1.0 / Clamp(InvasionProHud(myHUD).MaxHitSoundsPerSecond, 5, 50));
}

simulated function PlayFriendlyHitSound(int Damage)
{
   local Sound HitSound;
   local float Pitch;

   if (ViewTarget != None)
   {
       HitSound = Sound(DynamicLoadObject(InvasionProHUD(myHUD).CurrentFriendlyHitSound,class'Sound',false));
       Pitch = 1.0;
       if(HitSound!=None)
           ViewTarget.PlaySound(HitSound, , FClamp(InvasionProHUD(myHUD).HitSoundVolume, 0, 2), , , Pitch);
   }
   NextHitSoundTime = Level.TimeSeconds + (1.0 / Clamp(InvasionProHud(myHUD).MaxHitSoundsPerSecond, 5, 50));
}

event AddCameraEffect(CameraEffect NewEffect, optional bool RemoveExisting)
{
   if(!class'TURSettings'.default.bAllowMotionBlur && MotionBlur(NewEffect) != None)
       return;
   Super.AddCameraEffect(NewEffect,RemoveExisting);
}

defaultproperties
{
     CrosshairMaxDistance=16.000000
     CrosshairSizeScale=30.000000
     CrosshairMinSize=30.000000
     CrosshairMaxSize=335.000000
     bSpecMonsters=True
     PlayerReplicationInfoClass=Class'TURInvPro.InvasionProPlayerReplicationInfo'
     PawnClass=Class'TURInvPro.InvasionProxPawn'
}
