//=============================================================================
// FX_MonsterSpawn.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class FX_MonsterSpawn extends Emitter;

var class<Pawn> MyPawnClass;
var NavigationPoint StartSpot;

var bool bBoss;
var int BossNum;
var int TempBossID;
var int TempSpawnID;

replication
{
   reliable if(Role==Role_Authority)
       MyPawnClass;
}

simulated function PostNetBeginPlay()
{
   if(Role == Role_Authority)
       SetTimer(2.0, false);
   else
       UpdateEffects(MyPawnClass);
}

function Timer()
{
   local Pawn M;
   local InvasionProBossReplicationInfo BRI;
   local Controller C;
   local Sound SpawnSound;
   local Inventory Inv;
   local string BossName,BossNameLeft,BossNameRight;
   local int i;
   local InvasionPro Game;

   Game = InvasionPro(Level.Game);
   if(Game == None)
       return;

#ifdef __DEBUG__
   if(Game.WaveBossID.Length > 0)
       Game.DebugMessage("Spawn", "FX_MonsterSpawn spawning: bBoss" @ bBoss @ "Game.WaveBossID[0].SpawnID" @ Game.WaveBossID[0].SpawnID @ "TempSpawnID" @ TempSpawnID);
   else
       Game.DebugMessage("Spawn", "FX_MonsterSpawn spawning: bBoss" @ bBoss @ "TempSpawnID" @ TempSpawnID);
#endif

    if((bBoss && Game.bBossActive && Game.WaveBossID.Length <= 0 && (Game.bBossesSpawnTogether || !Game.bBossesSpawnTogether)) || (Game.bBossFinished && Game.bAdvanceWaveWhenBossKilled))
   {
       Game.CurrentBeamIns--;
       return;
   }
   else if(bBoss && Game.WaveBossID[0].SpawnID != TempSpawnID)
   {
       Level.GetLocalPlayerController().ClientMessage("usual");
       Game.CurrentBeamIns--;
       return;
   }

   if(MyPawnClass != None)
   {
       M = Spawn(MyPawnClass,,, StartSpot.Location + (MyPawnClass.Default.CollisionHeight - StartSpot.CollisionHeight) * vect(0, 0, 1), StartSpot.Rotation);
       if(M != None)
       {
           if(bBoss)
           {
               //a boss has spawned, whether fallback or not, so no need to fallback again
               if(!Game.bIgnoreFallback)
                   Game.bIgnoreFallback = true;
               //boss spawned remove from wave boss ids
               if(Game.bTryingFallbackBoss)
               {
                   for(i = 0; i < Game.WaveBossID.Length; i++)
                   {
                       if(TempSpawnID == Game.WaveBossID[i].SpawnID)
                       {
                           Game.WaveBossID.Remove(i, 1);
                           break;
                       }
                   }
               }
               else
               {
                   for(i = 0;i < Game.WaveBossID.Length; i++)
                   {
                       if(TempBossID == Game.WaveBossID[i].BossID && TempSpawnID == Game.WaveBossID[i].SpawnID)
                       {
                           Game.WaveBossID.Remove(i, 1);
                           break;
                       }
                   }
               }

               BRI = Spawn(class'InvasionProBossReplicationInfo', M);
               if(BRI != None)
               {
                   BRI.MyMonster = Monster(M);
                   BRI.PlayerName = class'InvasionProConfigs'.default.Bosses[BossNum].BossName;
               }

               if(class'InvasionProConfigs'.default.Bosses[BossNum].SpawnSound != "" && class'InvasionProConfigs'.default.Bosses[BossNum].SpawnSound != "None")
                   SpawnSound = Sound(DynamicLoadObject(class'InvasionProConfigs'.default.Bosses[BossNum].SpawnSound, class'Sound', True));

               if(InvasionProGameReplicationInfo(Level.Game.GameReplicationInfo).BossSpawnString[0] != "" || SpawnSound != None)
               {
                   for(C = Level.ControllerList; C != None; C = C.NextController )
                   {
                       if(C != None && C.PlayerReplicationInfo != None && (PlayerController(C) != None || !C.PlayerReplicationInfo.bBot))
                       {
                           if(SpawnSound != None)
                               PlayerController(C).ClientReliablePlaySound(SpawnSound);
                           if(InvasionProGameReplicationInfo(Level.Game.GameReplicationInfo).BossSpawnString[0] != "")
                               PlayerController(C).ReceiveLocalizedMessage(class'LocalMessage_BossSpawn', BossNum,,, Level.Game.GameReplicationInfo);
                       }
                   }
               }

               Game.LastBossSpawnTime = Level.TimeSeconds;
               Game.bBossActive = true;
               if(class'InvasionProConfigs'.default.Bosses[BossNum].BossHealth <= 0)
                   M.Health = M.default.Health;
               else
                   M.Health = class'InvasionProConfigs'.default.Bosses[BossNum].BossHealth;

               InvasionProGameReplicationInfo(Level.Game.GameReplicationInfo).bBossEncounter = true;
               M.GroundSpeed = class'InvasionProConfigs'.default.Bosses[BossNum].BossGroundSpeed;
               M.AirSpeed = class'InvasionProConfigs'.default.Bosses[BossNum].BossAirSpeed;
               M.WaterSpeed = class'InvasionProConfigs'.default.Bosses[BossNum].BossWaterSpeed;
               M.JumpZ =  class'InvasionProConfigs'.default.Bosses[BossNum].BossJumpZ;
               M.HealthMax = M.Health;
               Monster(M).GibCountCalf *= class'InvasionProConfigs'.default.Bosses[BossNum].BossGibMultiplier;
               Monster(M).GibCountForearm *= class'InvasionProConfigs'.default.Bosses[BossNum].BossGibMultiplier;
               Monster(M).GibCountHead *= class'InvasionProConfigs'.default.Bosses[BossNum].BossGibMultiplier;
               Monster(M).GibCountTorso *= class'InvasionProConfigs'.default.Bosses[BossNum].BossGibMultiplier;
               Monster(M).GibCountUpperArm *= class'InvasionProConfigs'.default.Bosses[BossNum].BossGibMultiplier;
               Monster(M).ScoringValue = class'InvasionProConfigs'.default.Bosses[BossNum].BossScoreAward;
               M.SetLocation(M.Location + vect(0, 0, 1) * (M.CollisionHeight * class'InvasionProConfigs'.default.Bosses[BossNum].NewDrawScale));

               if(class'InvasionProConfigs'.default.Bosses[BossNum].NewDrawScale <= 0)
                   M.SetDrawScale(M.default.DrawScale);
               else
                   M.SetDrawScale(class'InvasionProConfigs'.default.Bosses[BossNum].NewDrawScale);

               if(class'InvasionProConfigs'.default.Bosses[BossNum].NewCollisionRadius <= 0 || class'InvasionProConfigs'.default.Bosses[BossNum].NewCollisionHeight <= 0)
                   M.SetCollisionSize(M.default.CollisionRadius, M.default.CollisionHeight);
               else
                   M.SetCollisionSize(class'InvasionProConfigs'.default.Bosses[BossNum].NewCollisionRadius, class'InvasionProConfigs'.default.Bosses[BossNum].NewCollisionHeight);

               M.Prepivot = class'InvasionProConfigs'.default.Bosses[BossNum].NewPrePivot;
               Game.UpdateMonsterTypeStats(M.Class, 1, 0, 0);
               Inv = M.FindInventoryType(class'InvasionProMonsterIDInv');
               if(InvasionProMonsterIDInv(Inv) != None)
               {
                   BossName = class'InvasionProConfigs'.default.Bosses[BossNum].BossName;
                   if(BossName ~= "")
                   {
                       Divide(String(M.Class), "." , BossNameLeft, BossNameRight);
                       BossName = "Boss (" $ BossNameRight $ ")";
                   }

                   InvasionProMonsterIDInv(Inv).MonsterName = BossName;
                   InvasionProMonsterIDInv(Inv).bSummoned = false;
                   InvasionProMonsterIDInv(Inv).bBoss = true;
                   InvasionProMonsterIDInv(Inv).bFriendly = false;
               }
           }
           else
           {
               Game.UpdateMonsterTypeStats(M.Class, 1, 0, 0);
               Inv = M.FindInventoryType(class'InvasionProMonsterIDInv');
               if(InvasionProMonsterIDInv(Inv) != None)
               {
                   InvasionProMonsterIDInv(Inv).bSummoned = false;
                   InvasionProMonsterIDInv(Inv).bBoss = false;
                   InvasionProMonsterIDInv(Inv).bFriendly = false;
               }
           }
       }
   }

   if(Game != None)
       Game.CurrentBeamIns--;
}

simulated function UpdateEffects(class<Pawn> Other)
{
   SetDrawScale(Other.default.CollisionRadius / CollisionRadius);

   //center initial flares
   Emitters[0].StartSizeRange.X.Min = 100 * (Other.default.CollisionRadius / 25);
   Emitters[0].StartSizeRange.X.Max = 100 * (Other.default.CollisionRadius / 25);
   Emitters[1].StartSizeRange.X.Min = 100 * (Other.default.CollisionRadius / 25);
   Emitters[1].StartSizeRange.X.Max = 100 * (Other.default.CollisionRadius / 25);

   //spinny thingy base
   Emitters[2].StartLocationOffset.Y = 64 * (Other.default.CollisionHeight / 44);
   Emitters[2].StartLocationOffset.Y = 64 * (Other.default.CollisionHeight / 44);
   Emitters[2].StartLocationPolarRange.Z.Min = 32 * (Other.default.CollisionRadius / 25);
   Emitters[2].StartLocationPolarRange.Z.Max = 32 * (Other.default.CollisionRadius / 25);
   Emitters[2].StartVelocityRange.Y.Min = -64 * (Other.default.CollisionHeight / 44);
   Emitters[2].StartVelocityRange.Y.Max = -64 * (Other.default.CollisionHeight / 44);

   //spinny thingy trail
   Emitters[3].MaxActiveParticles *= DrawScale;
   Emitters[3].Particles.Length = Emitters[3].MaxActiveParticles;

   //blue rising discs
   Emitters[4].StartLocationOffset.Z = -64 * (Other.default.CollisionHeight / 44);
   Emitters[4].StartLocationOffset.Z = -64 * (Other.default.CollisionHeight / 44);
   Emitters[4].StartSizeRange.X.Min = 40 * (Other.default.CollisionRadius / 25);
   Emitters[4].StartSizeRange.X.Max = 40 * (Other.default.CollisionRadius / 25);
   Emitters[4].StartVelocityRange.Z.Min = 64 * (Other.default.CollisionHeight / 44);
   Emitters[4].StartVelocityRange.Z.Max = 64 * (Other.default.CollisionHeight / 44);

   //spinny thingy trail
   Emitters[5].MaxActiveParticles *= DrawScale;
   Emitters[5].Particles.Length = Emitters[5].MaxActiveParticles;

   //flash teleport flares
   Emitters[6].StartSizeRange.X.Min = 100 * (Other.default.CollisionRadius / 25);
   Emitters[6].StartSizeRange.X.Max = 100 * (Other.default.CollisionRadius / 25);
   Emitters[7].StartSizeRange.X.Min = 100 * (Other.default.CollisionRadius / 25);
   Emitters[7].StartSizeRange.X.Max = 100 * (Other.default.CollisionRadius / 25);
   Emitters[8].StartSizeRange.X.Min = 100 * (Other.default.CollisionRadius / 25);
   Emitters[8].StartSizeRange.X.Max = 100 * (Other.default.CollisionRadius / 25);

   //flash teleport flash
   Emitters[9].StartSizeRange.X.Min = 100 * (Other.default.CollisionRadius / 25);
   Emitters[9].StartSizeRange.X.Max = 100 * (Other.default.CollisionRadius / 25);

   //the spiral blue trail
   Emitters[10].StartLocationOffset.X = 32 * (Other.default.CollisionRadius / 25);
   Emitters[10].StartLocationOffset.X = 32 * (Other.default.CollisionRadius / 25);
   Emitters[10].StartLocationOffset.Z = -64 * (Other.default.CollisionHeight / 44);
   Emitters[10].StartLocationOffset.Z = -64 * (Other.default.CollisionHeight / 44);
   Emitters[10].StartVelocityRange.Z.Min = 64 * (Other.default.CollisionHeight / 44);
   Emitters[10].StartVelocityRange.Z.Max = 64 * (Other.default.CollisionHeight / 44);
   Emitters[10].MaxActiveParticles *= DrawScale;
   Emitters[10].Particles.Length = Emitters[10].MaxActiveParticles;

   //teleport dust
   Emitters[11].MaxActiveParticles *= DrawScale;
   Emitters[11].Particles.Length = Emitters[11].MaxActiveParticles;
   Emitters[11].StartVelocityRadialRange.Min = -200 * (Other.default.CollisionRadius / 25);
   Emitters[11].StartVelocityRadialRange.Max = -200 * (Other.default.CollisionRadius / 25);

   if(Other.default.CollisionHeight < 44)
   {
       Emitters[2].StartSizeRange.X.Min = 5 * (Other.default.CollisionHeight / 44);
       Emitters[2].StartSizeRange.X.Max = 5 * (Other.default.CollisionHeight / 44);

       Emitters[3].StartSizeRange.X.Min = 5 * (Other.default.CollisionHeight / 44);
       Emitters[3].StartSizeRange.X.Max = 5 * (Other.default.CollisionHeight / 44);

//     Emitters[10].StartSizeRange.X.Min = 8 * (Other.default.CollisionHeight / 44);
//     Emitters[10].StartSizeRange.X.Max = 8 * (Other.default.CollisionHeight / 44);
   }

   Emitters[0].Disabled = False;
   Emitters[1].Disabled = False;
   Emitters[2].Disabled = False;
   Emitters[3].Disabled = False;
   Emitters[4].Disabled = False;
   Emitters[5].Disabled = False;
   Emitters[6].Disabled = False;
   Emitters[7].Disabled = False;
   Emitters[8].Disabled = False;
   Emitters[9].Disabled = False;
   Emitters[10].Disabled = False;
   Emitters[11].Disabled = False;
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter26
       Disabled=True
//     CoordinateSystem=PTCS_Relative
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        FadeOutStartTime=1.900000
        FadeInEndTime=0.250000
        MaxParticles=1
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.750000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        Sounds(0)=(Sound=Sound'TURInvPro.TeleStart',Radius=(Min=256.000000,Max=256.000000),Pitch=(Min=1.000000,Max=1.000000),Volume=(Min=255.000000,Max=255.000000),Probability=(Min=1.000000,Max=1.000000))
        SpawningSound=PTSC_LinearLocal
        SpawningSoundProbability=(Min=1.000000,Max=1.000000)
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.FlashFlare1'
        LifetimeRange=(Min=2.000000,Max=2.000000)
    End Object
    Emitters(0)=SpriteEmitter'FX_MonsterSpawn.SpriteEmitter26'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter27
       Disabled=True
//     CoordinateSystem=PTCS_Relative
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Opacity=0.500000
        FadeOutStartTime=1.900000
        FadeInEndTime=0.250000
        MaxParticles=1
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.750000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EmitterTextures.Flares.EFlareB2'
        LifetimeRange=(Min=2.000000,Max=2.000000)
    End Object
    Emitters(1)=SpriteEmitter'FX_MonsterSpawn.SpriteEmitter27'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter28
       Disabled=True
//     CoordinateSystem=PTCS_Relative
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UseRevolution=True
        UniformSize=True
        AutomaticInitialSpawning=False
        FadeOutStartTime=1.900000
        FadeInEndTime=0.100000
        MaxParticles=1
        StartLocationOffset=(Y=64.000000)
        StartLocationShape=PTLS_Polar
        StartLocationPolarRange=(Y=(Max=65536.000000),Z=(Min=32.000000,Max=32.000000))
        RevolutionsPerSecondRange=(Z=(Min=3.000000,Max=3.000000))
        UseRotationFrom=PTRS_Offset
        RotationOffset=(Roll=16384)
        StartSizeRange=(X=(Min=5.000000,Max=5.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EmitterTextures.Flares.EFlareB'
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(Y=(Min=-64.000000,Max=-64.000000))
    End Object
    Emitters(2)=SpriteEmitter'FX_MonsterSpawn.SpriteEmitter28'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter29
       Disabled=True
//     CoordinateSystem=PTCS_Relative
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        ColorScale(0)=(Color=(B=255,G=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,A=255))
        FadeOutStartTime=1.000000
        FadeInEndTime=0.100000
        MaxParticles=50
        AddLocationFromOtherEmitter=2
        StartSizeRange=(X=(Min=5.000000,Max=5.000000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'EpicParticles.Flares.Sharpstreaks'
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(Z=(Max=5.000000))
        VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000))
        VelocityScale(1)=(RelativeTime=1.000000,RelativeVelocity=(X=1.000000,Y=1.000000))
    End Object
    Emitters(3)=SpriteEmitter'FX_MonsterSpawn.SpriteEmitter29'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter30
       Disabled=True
//     CoordinateSystem=PTCS_Relative
        UseDirectionAs=PTDU_Normal
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        ColorScale(0)=(Color=(B=255,G=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255))
        FadeOutStartTime=1.750000
        FadeInEndTime=0.250000
        MaxParticles=5
        StartLocationOffset=(Z=-64.000000)
        StartSizeRange=(X=(Min=40.000000,Max=40.000000))
        Texture=Texture'XEffectMat.Shock.shock_ring_b'
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(Z=(Min=64.000000,Max=64.000000))
    End Object
    Emitters(4)=SpriteEmitter'FX_MonsterSpawn.SpriteEmitter30'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter31
       Disabled=True
//     CoordinateSystem=PTCS_Relative
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        Acceleration=(Z=-1.000000)
        ColorScale(0)=(Color=(B=255,G=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255))
        FadeOutStartTime=1.000000
        FadeInEndTime=0.100000
        MaxParticles=50
        AddLocationFromOtherEmitter=2
        StartSizeRange=(X=(Min=2.000000,Max=3.000000))
        Texture=Texture'XEffectMat.Shock.shock_sparkle'
        LifetimeRange=(Min=2.000000,Max=2.000000)
    End Object
    Emitters(5)=SpriteEmitter'FX_MonsterSpawn.SpriteEmitter31'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter18
       Disabled=True
//     CoordinateSystem=PTCS_Relative
        UseDirectionAs=PTDU_Up
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        ScaleSizeXByVelocity=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        FadeOutStartTime=0.300000
        FadeInEndTime=0.100000
        MaxParticles=1
        StartLocationOffset=(Z=24.000000)
        ScaleSizeByVelocityMultiplier=(X=16.000000)
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.BurnFlare1'
        LifetimeRange=(Min=0.400000,Max=0.400000)
        InitialDelayRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(Z=(Min=0.100000,Max=0.100000))
        VelocityScale(0)=(RelativeVelocity=(Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.500000)
        VelocityScale(2)=(RelativeTime=1.000000,RelativeVelocity=(Z=1.000000))
    End Object
    Emitters(6)=SpriteEmitter'FX_MonsterSpawn.SpriteEmitter18'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter19
       Disabled=True
//     CoordinateSystem=PTCS_Relative
        UseDirectionAs=PTDU_Up
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        ScaleSizeXByVelocity=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        FadeOutStartTime=0.300000
        FadeInEndTime=0.100000
        MaxParticles=1
        StartLocationOffset=(Z=-24.000000)
        ScaleSizeByVelocityMultiplier=(X=16.000000)
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.BurnFlare1'
        LifetimeRange=(Min=0.400000,Max=0.400000)
        InitialDelayRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(Z=(Min=-0.100000,Max=-0.100000))
        VelocityScale(0)=(RelativeVelocity=(Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.500000)
        VelocityScale(2)=(RelativeTime=1.000000,RelativeVelocity=(Z=1.000000))
    End Object
    Emitters(7)=SpriteEmitter'FX_MonsterSpawn.SpriteEmitter19'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter20
       Disabled=True
//     CoordinateSystem=PTCS_Relative
        UseDirectionAs=PTDU_Right
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        ScaleSizeXByVelocity=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        FadeOutStartTime=0.300000
        FadeInEndTime=0.100000
        MaxParticles=1
        ScaleSizeByVelocityMultiplier=(X=16.000000)
        Sounds(0)=(Sound=Sound'TURInvPro.TeleEnd',Radius=(Min=256.000000,Max=256.000000),Pitch=(Min=1.000000,Max=1.000000),Volume=(Min=255.000000,Max=255.000000),Probability=(Min=1.000000,Max=1.000000))
        SpawningSound=PTSC_LinearLocal
        SpawningSoundProbability=(Min=1.000000,Max=1.000000)
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.BurnFlare1'
        LifetimeRange=(Min=0.400000,Max=0.400000)
        InitialDelayRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(Z=(Min=0.100000,Max=0.100000))
        VelocityScale(1)=(RelativeTime=0.500000,RelativeVelocity=(Z=1.000000))
        VelocityScale(2)=(RelativeTime=1.000000)
    End Object
    Emitters(8)=SpriteEmitter'FX_MonsterSpawn.SpriteEmitter20'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter35
       Disabled=True
//     CoordinateSystem=PTCS_Relative
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Opacity=0.750000
        FadeOutStartTime=0.300000
        FadeInEndTime=0.100000
        MaxParticles=1
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.Sharpstreaks2'
        LifetimeRange=(Min=0.400000,Max=0.400000)
        InitialDelayRange=(Min=2.000000,Max=2.000000)
    End Object
    Emitters(9)=SpriteEmitter'FX_MonsterSpawn.SpriteEmitter35'

    Begin Object Class=TrailEmitter Name=TrailEmitter0
        Disabled=True
        TrailShadeType=PTTST_Linear
        MaxPointsPerTrail=60
        DistanceThreshold=4.000000
        UseCrossedSheets=True
        UseColorScale=True
        RespawnDeadParticles=False
        UseRevolution=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255))
        MaxParticles=20
        StartLocationOffset=(X=32.000000,Z=-64.000000)
        RevolutionsPerSecondRange=(Z=(Min=3.000000,Max=3.000000))
        StartSizeRange=(X=(Min=12.000000,Max=12.000000))
        InitialParticlesPerSecond=10.000000
        Texture=Texture'EpicParticles.Beams.WhiteStreak01aw'
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(Z=(Min=64.000000,Max=64.000000))
    End Object
    Emitters(10)=TrailEmitter'FX_MonsterSpawn.TrailEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter37
       Disabled=True
//     CoordinateSystem=PTCS_Relative
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        Acceleration=(Z=200.000000)
        ColorScale(0)=(Color=(B=255,G=200))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=200))
        Opacity=0.500000
        FadeOutStartTime=0.100000
        FadeInEndTime=0.100000
        MaxParticles=50
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=8.000000,Max=8.000000)
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=5.000000,Max=8.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'EpicParticles.Flares.FlickerFlare2'
        LifetimeRange=(Min=1.000000,Max=1.000000)
        InitialDelayRange=(Min=2.000000,Max=2.000000)
        StartVelocityRadialRange=(Min=-200.000000,Max=-200.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
        VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.400000,RelativeVelocity=(X=0.300000,Y=0.300000,Z=0.300000))
        VelocityScale(2)=(RelativeTime=1.000000,RelativeVelocity=(X=0.100000,Y=0.100000,Z=0.100000))
    End Object
    Emitters(11)=SpriteEmitter'FX_MonsterSpawn.SpriteEmitter37'

   AutoDestroy=True
   bNoDelete=False
   RemoteRole=Role_SimulatedProxy
   bNotOnDedServer=False
   bAlwaysRelevant=True //to avoid desync
   LifeSpan=4.000000
}
