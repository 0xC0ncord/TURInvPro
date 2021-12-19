//=============================================================================
// InvasionProHud.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProHud extends HudCTeamDeathMatch config(User);

#exec OBJLOAD FILE=2K4Menus.utx

enum ERadarDotType
{
    DT_Owner,
    DT_Friendly,
    DT_Enemy,
    DT_FriendlyMonster,
    DT_Other
};

struct RadarDotStruct
{
    var float X;
    var float Y;
    var Pawn Pawn;
    var InvasionProHud.ERadarDotType Type;
};

var() float RadarPulse;
var() config float RadarScale;
var() float LastDrawRadar;
var() float MinEnemyDist;
var() string MonsterScoretext;
var() float RadarSpecialOffsetX;
var() float RadarSpecialOffsetY;
var() config InvasionProPreloadInfo.EPreloadStyle PreloadStyle;
var() config bool bHideRadar;
var() config bool bAddFriendlyMonstersToPlayerList;
var() config bool bAddFriendlyMonstersToScoreboard;
var() config bool bDisplayBossTimer;
var() config bool bDisplayBossNames;
var() config Color MonsterColor;
var() config Color PlayerColor;
var() config Color RadarColor;
var() config Color OwnerColor;
var() config Color FriendlyMonsterColor;
var() config Color MiscColor;
var() config bool bDisplayMonsterCounter;
var() config bool bDisplayPlayerList;
var() config bool bClassicRadar;
#ifeq ENABLE_TURINVX_RADAR 1
var() config bool bTURRadar;
#endif
var() config bool bNoRadarSound;
var() config float RadarPosX;
var() config float RadarPosY;
var() config Color PulseColor;
var() config bool bStartThirdPerson;
var() config bool bSpecMonsters;
var() config array<string> EnemyKillSounds;
var() config string CurrentKillSound;
var() config string RadarSound;
var() Sound PulseSound;
var() config Material RadarImage;
var() config Material PulseImage;
var() array<Material> RadarMaterials;
var() array<Material> PulseMaterials;
var() array<Material> OwnerIconMaterials;
var() array<Material> FriendlyPlayerIconMaterials;
var() array<Material> FriendlyMonsterIconMaterials;
var() array<Material> MonsterIconMaterials;
var() array<Material> MiscIconMaterials;
var() config Material OwnerIcon;
var() config Material MonsterIcon;
var() config Material FriendlyPlayerIcon;
var() config Material FriendlyMonsterIcon;
var() config Material MiscIcon;
var() config bool bDrawPetInfo;
var() float RadarRange;
var() float ClassicRadarRange;
var() Color MonsterCounterColor;
var() config float OwnerDotScale;
var() config float FriendlyPlayerDotScale;
var() config float FriendlyMonsterDotScale;
var() config float MonsterDotScale;
var() config float MiscDotScale;
var() float DotUCoordinate;
var() float DotVCoordinate;
var() float DotULWidth;
var() float DotVLHeight;
var() bool bMeshesLoaded;
var() Font MonsterCounterFont;
var() Color LoadingContainerColor;
var() Color OrangeColor;
var() Color MonsterNumColor;
var() Color BossNameColor;
var() Material LoadingContainerImage;
var() Material LoadingContainerCompanionImage;
var() Material LoadingBarImage;
var() Material MonsterNumImage;
var() float LoadingBarSizeX;
var() float LoadingBarSpread;
var() Font LoadingFont;
var() Font PlayerFont;
var() SpriteWidget MonsterCountBackground;
var() SpriteWidget MonsterCountBackgroundDisc;
var() SpriteWidget MonsterCountImage;
var() NumericWidget MonsterCount;
var() NumericWidget BossTime;
var() SpriteWidget PlayerBackground;
var() float PlayerBackgroundSpacer;
var() float PlayerBackgroundAbsoluteY;
var() int PlayerFontScale;
var() float PlayerNameSpacer;
var() float PlayerFontYSize;
var() float PlayerFontXSize;
var() config float PlayerListPosY;
var() float PlayerListSpacerY;
var() bool bDrawLoading;
var() SpriteWidget BossBarBackground;
var() Material BossImage;
var() float testX;
var() float testY;
var() float TestX2;
var() float TestY2;
var() string PreloadingText;
var() Vector BehindViewCrosshairLocation;
var() float BehindViewCrosshairSize;
var() Color TestColor;
var() Color FriendlyMonsterNameColor;
var() Color HostileMonsterNameColor;
var() float MonsterNameOffset;
var() ERenderStyle TestStyle;
var() int MonsterNameFontScale;
var() float MonsterFontYSize;
var() float MonsterFontXSize;
var() int BossDrawPosition;
var() EDrawPivot TestPivot;
var() bool bLoadingStarted;
var() int EnemyCount;
var() config array<string> EnemyHitSounds;
var() config string CurrentEnemyHitSound;
var() config array<string> FriendlyHitSounds;
var() config string CurrentFriendlyHitSound;
var() config float HitSoundVolume;
var() config float KillSoundVolume;
var() config int MaxHitSoundsPerSecond;
var() config bool bDynamicHitSounds;
var() config bool bRadarShowElevationAsDistance;
var() array<RadarDotStruct> RadarDots;

var() float NumPreloadNow;
var() float TotalPreloadCount;

function DrawEnemyName(Canvas C)
{}

function DrawCustomBeacon(Canvas C, Pawn P, float ScreenLocX, float ScreenLocY)
{
   //only way to turn off native beacon code for friendly monsters
   //is to empty this function and set bScriptPostRender=true in the monster class?
   return;
}

function DisplayEnemyName(Canvas C, PlayerReplicationInfo PRI)
{
   if(PlayerOwner != None)
   {
       PlayerOwner.ReceiveLocalizedMessage(class'PlayerNameMessage', 0, PRI);
   }
}

//don't draw crosshair if in behindview and aerialview is active
simulated function DrawCrosshair (Canvas C)
{
   local float NormalScale;
    local int i, CurrentCrosshair;
    local float OldW, CurrentCrosshairScale,OldScale;
    local color CurrentCrosshairColor;
    local SpriteWidget CHtexture;

    if ( PawnOwner.bSpecialCrosshair )
    {
        PawnOwner.SpecialDrawCrosshair( C );
        return;
    }

    if (!bCrosshairShow)
    {
        return;

   }

    if ( bUseCustomWeaponCrosshairs && (PawnOwner != None) && (PawnOwner.Weapon != None) )
    {
        CurrentCrosshair = PawnOwner.Weapon.CustomCrosshair;
        if (CurrentCrosshair == -1 || CurrentCrosshair == Crosshairs.Length)
        {
            CurrentCrosshair = CrosshairStyle;
            CurrentCrosshairColor = CrosshairColor;
            CurrentCrosshairScale = CrosshairScale;
        }
        else
        {
            CurrentCrosshairColor = PawnOwner.Weapon.CustomCrosshairColor;
            CurrentCrosshairScale = PawnOwner.Weapon.CustomCrosshairScale;
            if ( PawnOwner.Weapon.CustomCrosshairTextureName != "" )
            {
                if ( PawnOwner.Weapon.CustomCrosshairTexture == None )
                {
                    PawnOwner.Weapon.CustomCrosshairTexture = Texture(DynamicLoadObject(PawnOwner.Weapon.CustomCrosshairTextureName,class'Texture'));
                    if ( PawnOwner.Weapon.CustomCrosshairTexture == None )
                    {
                        log(PawnOwner.Weapon$" custom crosshair texture not found!");
                        PawnOwner.Weapon.CustomCrosshairTextureName = "";
                    }
                }
                CHTexture = Crosshairs[0];
                CHTexture.WidgetTexture = PawnOwner.Weapon.CustomCrosshairTexture;
            }
        }
    }
    else
    {
        CurrentCrosshair = CrosshairStyle;
        CurrentCrosshairColor = CrosshairColor;
        CurrentCrosshairScale = CrosshairScale;
    }

    CurrentCrosshair = Clamp(CurrentCrosshair, 0, Crosshairs.Length - 1);

    NormalScale = Crosshairs[CurrentCrosshair].TextureScale;
    if ( CHTexture.WidgetTexture == None )
        CHTexture = Crosshairs[CurrentCrosshair];
    CHTexture.TextureScale *= 0.5 * CurrentCrosshairScale;

    for( i = 0; i < ArrayCount(CHTexture.Tints); i++ )
        CHTexture.Tints[i] = CurrentCrossHairColor;

    if ( LastPickupTime > Level.TimeSeconds - 0.4 )
    {
        if ( LastPickupTime > Level.TimeSeconds - 0.2 )
            CHTexture.TextureScale *= (1 + 5 * (Level.TimeSeconds - LastPickupTime));
        else
            CHTexture.TextureScale *= (1 + 5 * (LastPickupTime + 0.4 - Level.TimeSeconds));
    }
    OldScale = HudScale;
    HudScale=1;
    OldW = C.ColorModulate.W;
    C.ColorModulate.W = 1;

   if(PlayerOwner != None && PlayerOwner.Pawn != None)
   {
       if(Vehicle(PlayerOwner.Pawn) == None && InvasionProGameReplicationInfo(PlayerOwner.GameReplicationInfo) != None && InvasionProGameReplicationInfo(PlayerOwner.GameReplicationInfo).bAerialView && PlayerOwner.bBehindView)
       {
           DrawBehindViewCrosshair(C, CHTexture.WidgetTexture,CurrentCrosshairColor);
           HudScale=OldScale;
           DrawEnemyName(C);
           return;
       }
   }

    DrawSpriteWidget (C, CHTexture);
    C.ColorModulate.W = OldW;
    HudScale=OldScale;
    CHTexture.TextureScale = NormalScale;

    //DrawEnemyName(C);
}

simulated function DrawBehindViewCrosshair( Canvas C , Material BehindViewTexture, Color BehindViewColour)
{
    local int XPos, YPos;
    local vector ScreenPos;
    local vector X,Y,Z,Dir;
    local float RatioX, RatioY;
    local float tileX, tileY;
    local float Dist;

    local float SizeX;
    local float SizeY;

    SizeX = BehindViewCrosshairSize * 96.0;
    SizeY = BehindViewCrosshairSize * 96.0;


    ScreenPos = C.WorldToScreen( BehindViewCrosshairLocation );

    RatioX = C.SizeX / 640.0;
    RatioY = C.SizeY / 480.0;

    tileX = sizeX * RatioX;
    tileY = sizeY * RatioX;

    GetAxes(PlayerOwner.Rotation, X,Y,Z);
    Dir = BehindViewCrosshairLocation - PawnOwner.Location;
    Dist = VSize(Dir);
    Dir = Dir/Dist;

    if ( (Dir Dot X) > 0.6 ) // don't draw if it's behind the eye
    {
        XPos = ScreenPos.X;
        YPos = ScreenPos.Y;
        C.Style = ERenderStyle.STY_Additive;
        C.DrawColor = BehindViewColour;
        C.SetPos(XPos - tileX*0.5, YPos - tileY*0.5);
        if(BehindViewTexture != None)
        {
           C.DrawTile( BehindViewTexture, tileX, tileY, 0, 0, 64, 64);
       }
    }
}

simulated function ShowTeamScorePassA(Canvas C)
{
   local float RadarWidth, PulseWidth, PulseBrightness, CurRadarScale;

   if((PawnOwner == None && !PlayerOwner.IsSpectating())
   || InvasionProXPlayer(PlayerOwner) == None
   || InvasionProGameReplicationInfo(PlayerOwner.GameReplicationInfo)==None
   || InvasionProGameReplicationInfo(PlayerOwner.GameReplicationInfo).bHideRadar
   || bHideRadar)
   {
       return;
   }

   if(bClassicRadar)
   {
       PulseBrightness = FMax(0,(1 - 2*RadarPulse) * 255.0);
       RadarRange = ClassicRadarRange;

       CurRadarScale = RadarScale * HUDScale;
       RadarWidth = 0.5 * CurRadarScale * C.ClipX;
       PulseWidth = CurRadarScale * C.ClipX;
       C.DrawColor = RedColor;
       C.Style = ERenderStyle.STY_Translucent;

       C.DrawColor.R = PulseBrightness;
       C.SetPos(RadarPosX*C.ClipX - 0.5*PulseWidth,RadarPosY*C.ClipY+RadarWidth-0.5*PulseWidth);
       C.DrawTile( Material'InterfaceContent.SkinA', PulseWidth, PulseWidth, 0, 880, 142, 142);

       PulseWidth = RadarPulse * CurRadarScale * C.ClipX;
       C.DrawColor = RedColor;
       C.SetPos(RadarPosX*C.ClipX - 0.5*PulseWidth,RadarPosY*C.ClipY+RadarWidth-0.5*PulseWidth);
       C.DrawTile( Material'InterfaceContent.SkinA', PulseWidth, PulseWidth, 0, 880, 142, 142);

       C.Style = ERenderStyle.STY_Alpha;
       C.DrawColor = GetTeamColor( PlayerOwner.GetTeamNum() );
       C.SetPos(RadarPosX*C.ClipX - RadarWidth,RadarPosY*C.ClipY+RadarWidth);
       C.DrawTile( Material'AS_FX_TX.AssaultRadar', RadarWidth, RadarWidth, 0, 512, 512, -512);
       C.SetPos(RadarPosX*C.ClipX,RadarPosY*C.ClipY+RadarWidth);
       C.DrawTile( Material'AS_FX_TX.AssaultRadar', RadarWidth, RadarWidth, 512, 512, -512, -512);
       C.SetPos(RadarPosX*C.ClipX - RadarWidth,RadarPosY*C.ClipY);
       C.DrawTile( Material'AS_FX_TX.AssaultRadar', RadarWidth, RadarWidth, 0, 0, 512, 512);
       C.SetPos(RadarPosX*C.ClipX,RadarPosY*C.ClipY);
       C.DrawTile( Material'AS_FX_TX.AssaultRadar', RadarWidth, RadarWidth, 512, 0, -512, 512);
   }
#ifeq ENABLE_TURINVX_RADAR 1
   else if(bTURRadar)
   {
       PulseBrightness = FMax(0,(1 - 2*RadarPulse) * 255.0);
       RadarRange = ClassicRadarRange;
       CurRadarScale = RadarScale * HUDScale;
       RadarWidth = CurRadarScale * C.ClipX;
       C.Style = ERenderStyle.STY_Translucent;

       //draw the pulse circle
       PulseWidth = RadarPulse * CurRadarScale * C.ClipX;
       C.DrawColor.A=255;
       C.DrawColor.R=96;
       C.DrawColor.G=200;
       C.DrawColor.B=255;
       C.SetPos(RadarPosX*C.ClipX - 0.5*PulseWidth,RadarPosY*C.ClipY+RadarWidth-0.5*PulseWidth - (0.5*RadarWidth) - (-0.000167 * RadarWidth));
       C.DrawTile( Material'InterfaceContent.SkinA', PulseWidth, PulseWidth, 0, 880, 142, 142);

       //draw the outer fading ring
       PulseWidth = CurRadarScale * C.ClipX;
       C.DrawColor.R = 96.f * (PulseBrightness / 255.f);
       C.DrawColor.G = 200.f * (PulseBrightness / 255.f);
       C.DrawColor.B = 255.f * (PulseBrightness / 255.f);
       C.SetPos(RadarPosX*C.ClipX - 0.5*PulseWidth,RadarPosY*C.ClipY+RadarWidth-0.5*PulseWidth - (0.5*RadarWidth) - (-0.000167 * RadarWidth));
       C.DrawTile( Material'InterfaceContent.SkinA', PulseWidth, PulseWidth, 0, 880, 142, 142);

       //draw the single radar texture
       C.Style = ERenderStyle.STY_Alpha;
       C.DrawColor.A=255;
       C.DrawColor.R=96;
       C.DrawColor.G=200;
       C.DrawColor.B=255;
       C.SetPos(RadarPosX * C.ClipX - (0.5 * RadarWidth),RadarPosY*C.ClipY - (-0.000167 * RadarWidth));
       C.DrawTile( Material'TURInvXRadar', RadarWidth, RadarWidth, 2, 2, 512, 512);
       C.Style = ERenderStyle.STY_Normal;
   }
#endif //ENABLE_TURINVX_RADAR
   else
   {
       RadarRange = default.RadarRange;
       CurRadarScale = RadarScale * HUDScale;
       RadarWidth = 0.75 * CurRadarScale * C.ClipX;

       C.Reset();

       C.Style = ERenderStyle.STY_Alpha;

       if(RadarImage != None)
       {
           C.DrawColor = RadarColor;
           C.SetPos(RadarPosX * C.ClipX - (0.5 * RadarWidth),RadarPosY * C.ClipY - (-0.175 * RadarWidth));
           C.DrawTile( RadarImage, RadarWidth, RadarWidth, 2, 2, 512, 512);
       }
       if(PulseImage != None)
       {
           C.DrawColor = PulseColor;
           C.SetPos(RadarPosX * C.ClipX - (0.625 * RadarWidth),RadarPosY * C.ClipY - (-0.05 * RadarWidth));
           C.DrawTile( PulseImage, RadarWidth * 1.25, RadarWidth * 1.25, 2, 2, 512, 512);
       }
   }
}

simulated function ShowTeamScorePassC(Canvas C)
{
  local Pawn P;
  local float Dist, MaxDist, RadarWidth, Angle, DotSize, OffsetY, PulseBrightness, OffsetScale;
  local rotator Dir;
  local vector Start;
  local Material DrawMaterial;
   local InvasionProMonsterIDInv Inv;
   local vector End;
   local float SizeScale;

  LastDrawRadar = Level.TimeSeconds;
  RadarWidth = 0.5 * RadarScale * HUDScale * C.ClipX;
  if ( PawnOwner == None )
      Start = PlayerOwner.Location;
  else
      Start = PawnOwner.Location;

   if(InvasionProGameReplicationInfo(PlayerOwner.GameReplicationInfo) != None)
   {
       if(!bMeshesLoaded && bDrawLoading)
       {
           DrawLoading(C);
           C.Reset();
       }

       if(!InvasionProGameReplicationInfo(PlayerOwner.GameReplicationInfo).bHideMonsterCount && bDisplayMonsterCounter)
       {
           DrawMonsterCount(C);
           C.Reset();
       }

       if(!InvasionProGameReplicationInfo(PlayerOwner.GameReplicationInfo).bHidePlayerList && bDisplayPlayerList)
       {
           DrawPlayerNames(C);
           C.Reset();
       }

       if(InvasionProGameReplicationInfo(PlayerOwner.GameReplicationInfo).bBossEncounter && bDisplayBossTimer)
       {
           DrawBossTime(C);
           C.Reset();
       }

       if(bDisplayBossNames && InvasionProGameReplicationInfo(PlayerOwner.GameReplicationInfo).bBossEncounter)
       {
           BossDrawPosition = 1;
           DrawBossHealth(C);
           C.Reset();
       }

       if(InvasionProGameReplicationInfo(PlayerOwner.GameReplicationInfo).bHideRadar || bHideRadar)
       {
           return;
       }
   }

    MaxDist = 3000 * RadarPulse;
    OffsetY = RadarPosY + RadarWidth / C.ClipY;
    MinEnemyDist = 3000;
   EnemyCount = 0;

    foreach DynamicActors(class'Pawn', P)
    {
        if ( P != None && P.Health > 0 )
        {
           if(bRadarShowElevationAsDistance)
               Dist = VSize(Start - P.Location);
           else
           {
               End = P.Location;
               End.Z = Start.Z;
               Dist = VSize(Start - End);
           }

           if ( Dist < RadarRange )
           {
               if ( Dist < MaxDist )
               {
                   PulseBrightness = 255 - 255*Abs(Dist*0.00033 - RadarPulse);
               }
               else
               {
                   PulseBrightness = 255 - 255*Abs(Dist*0.00033 - RadarPulse - 5); //1
               }

               MinEnemyDist = FMin(MinEnemyDist, Dist);
               DrawMaterial = MonsterIcon;
               DotSize = 10;

               if(bRadarShowElevationAsDistance)
               {
                   Dir = rotator(P.Location - Start);
                   SizeScale = 1;
               }
               else
               {
                   Dir = rotator(End - Start);
                   SizeScale = P.Location.Z-Start.Z;
                   SizeScale/=6000;
                   if( SizeScale>0.5 )
                       SizeScale = 0.5;
                   else if( SizeScale<-0.5 )
                       SizeScale = -0.5;
                   SizeScale+=1;
               }

               //owner
               if(PawnOwner == P)
               {
                   C.DrawColor = OwnerColor;
                   DrawMaterial = OwnerIcon;
                   DotSize *= OwnerDotScale;
               }
               else if(Monster(P) != None && P.DrivenVehicle == None)
               {
                   foreach DynamicActors(class'InvasionProMonsterIDInv',Inv)
                   {
                       if(Inv.MyMonster == Monster(P))
                       {
                           //pets
                           if(Inv.bFriendly)
                           {
                               C.DrawColor = FriendlyMonsterColor;
                               DrawMaterial = FriendlyMonsterIcon;
                               DotSize *= FriendlyMonsterDotScale;
                           }
                           //morph monsters
                           else if(Inv.bPlayerControlled)
                           {
                               C.DrawColor = PlayerColor;
                               DrawMaterial = FriendlyPlayerIcon;
                               DotSize *= FriendlyPlayerDotScale;
                           }
                           //enemy monsters
                           else
                           {
                               C.DrawColor = MonsterColor;
                               EnemyCount++;
                               DotSize *= MonsterDotScale;
                           }
                           break;
                       }
                   }
               }
               //vehicles
               else if ( Vehicle(P) != None )
               {
                   //monster-driven vehicles
                   if(Monster(Vehicle(P).Driver)!=None)
                   {
                       C.DrawColor = MonsterColor;
                       EnemyCount++;
                       DotSize *= MonsterDotScale;
                   }
                   //player-driven vehicles
                   else if(Vehicle(P).Driver!=None)
                   {
                       C.DrawColor = PlayerColor;
                       DrawMaterial = FriendlyPlayerIcon;
                       DotSize *= FriendlyPlayerDotScale;
                   }
                   //vehicles without drivers
                   else
                   {
                       C.DrawColor = MiscColor;
                       DrawMaterial = MiscIcon;
                       DotSize *= MiscDotScale;
                   }
               }
               //blocks and barrels
               else if ( P.IsA('DruidBlock') || P.IsA('DruidExplosive') )
               {
                   C.DrawColor = MiscColor;
                   DrawMaterial = MiscIcon;
                   DotSize *= MiscDotScale;
               }
               //players
               else
               {
                   C.DrawColor = PlayerColor;
                   DrawMaterial = FriendlyPlayerIcon;
                   DotSize *= FriendlyPlayerDotScale;
               }

               C.Style = ERenderStyle.STY_Translucent;
               C.DrawColor.A = PulseBrightness;
               OffsetScale = RadarScale*Dist*0.000167;
               Angle = ((Dir.Yaw - PlayerOwner.Rotation.Yaw) & 65535) * 6.2832/65536;
               C.SetPos(RadarPosX * C.ClipX + OffsetScale * C.ClipX * HUDScale * sin(Angle) - 0.5*DotSize*SizeScale,
                   OffsetY * C.ClipY - OffsetScale * C.ClipX * HUDScale * cos(Angle) - 0.5*DotSize*SizeScale);
               if(DrawMaterial != None)
               {
                   C.DrawTile(DrawMaterial,DotSize*SizeScale, DotSize*SizeScale, DotUCoordinate, DotVCoordinate, DotULWidth, DotVLHeight);
               }
      }
    }
   }
   C.Reset();
}

simulated function DrawBossHealth(Canvas C)
{
   local InvasionProMonsterIDInv Inv;
   local Color FinalColor;
   local float HealthPercent;

   foreach DynamicActors(class'InvasionProMonsterIDInv',Inv)
   {
       if(Inv.bBoss)
       {
           HealthPercent = 1.00f * ( float(Inv.MonsterHealth)/float(Inv.MonsterHealthMax) );

           if(HealthPercent == 0.50)
           {
               FinalColor.R = 255;
               FinalColor.G = 255;
           }
           else if(HealthPercent > 0.50)
           {
               FinalColor.R = 255-(255*HealthPercent);
               FinalColor.G = 255;
           }
           else if(HealthPercent < 0.50)
           {
               FinalColor.R = 255;
               FinalColor.G = 255*HealthPercent;
           }

           C.Reset();
           C.Style = ERenderStyle.STY_Normal;
           C.Font = GetFontSizeIndex(C, 1);
           C.FontScaleX = 0.4;
           C.FontScaleY = 0.4;
           FinalColor.A = 255;
           C.DrawColor = FinalColor;
           C.DrawScreenText (Inv.MonsterName@" ("$Inv.MonsterHealth@"HP)", 0.5, 0.06 + (0.03 * BossDrawPosition) , DP_UpperMiddle);
           BossDrawPosition++;
       }
   }
}

simulated function DrawBossTime(Canvas C)
{
   if(!InvasionProGameReplicationInfo(PlayerOwner.GameReplicationInfo).bInfiniteBossTime)
   {
       C.Reset();
       C.Style = ERenderStyle.STY_Normal;
       //draw time limit
       if(!InvasionProGameReplicationInfo(PlayerOwner.GameReplicationInfo).bOverTime )
       {
           BossTime.Value = InvasionProGameReplicationInfo(PlayerOwner.GameReplicationInfo).BossTimeLimit;
           DrawNumericWidget( C, BossTime, DigitsBig);
           C.Font = GetFontSizeIndex(C, 1);
           C.FontScaleX = 0.55;
           C.FontScaleY = 0.55;
           C.DrawColor = BossTime.Tints[0];
           C.DrawScreenText ("Boss Time Limit", 0.5, 0.001 , DP_UpperMiddle);
       }
       else
       {
           C.Font = GetFontSizeIndex(C, 1);
           C.FontScaleX = 1;
           C.FontScaleY = 1;
           C.DrawColor = BossTime.Tints[0];
           C.DrawScreenText ("Overtime", 0.5, 0.0275 , DP_UpperMiddle);
       }
   }
}

simulated function DrawPlayerNames(Canvas C)
{
   local int i, x, FramePos;
   local string PlayerName;
   local float DrawOffset;
  local Pawn P;
  local array<Pawn> PList;
  local bool bFound;
   local GameReplicationInfo GRI;
   local PlayerReplicationInfo PRI;

   FramePos = 0;
   C.Reset();

   foreach DynamicActors(class'Pawn',P)
    if(Vehicle(P)!=None && P.PlayerReplicationInfo!=None && P.PlayerReplicationInfo.bBot && P.PlayerReplicationInfo.bIsSpectator)
      PList[PList.Length]=P;

   GRI = PlayerOwner.GameReplicationInfo;
   for(i=0;i<GRI.PRIArray.Length;i++)
   {
       PRI = GRI.PRIArray[i];
       if(PRI.StringUnknown != "Proxie")//dont draw proxies from chaos mod
       {
           PlayerName = PRI.PlayerName;

           //don't draw owners info or spectators info
           if(PRI != PlayerOwner.PlayerReplicationInfo && PlayerName != "WebAdmin" && !PRI.bOnlySpectator)
           {
               if(InvasionProFakeFriendlyMonsterReplicationInfo(PRI) == None || (bAddFriendlyMonstersToPlayerList && !InvasionProFakeFriendlyMonsterReplicationInfo(PRI).bMinion) )
               {
                   if(!bAddFriendlyMonstersToScoreboard && InvasionProFakeFriendlyMonsterReplicationInfo(PRI) == None)
                   {
               bFound=false;
               for(x=0; x<PList.Length; x++)
               {
                 if(PList[x].PlayerReplicationInfo == PRI)
                 {
                   bFound=true;
                   x=PList.Length;
                 }
               }
               if(bFound)
                 continue;
                   }

                   DrawOffset = HudScale * (PlayerListPosY + (PlayerListSpacerY * FramePos) );
                   //draw tiles
                   PlayerBackground.PosY = DrawOffset;
                   DrawSpriteWidget( C, PlayerBackground);
                   //draw names and health information
                   //health color and amount
                   //players/bots
                   C.Font = class'UT2MidGameFont'.static.GetMidGameFont( C.ClipX*0.5 * HUDScale );
                   C.DrawColor = WhiteColor;
                   C.Style = ERenderStyle.STY_Alpha;
                   if(InvasionProPlayerReplicationInfo(PRI) != None)
                   {
                       PlayerName = Left(PlayerName, 18);

                       C.DrawScreenText (PlayerName, HudScale * 0.005, DrawOffset + (HudScale * 0.02855), DP_UpperLeft);
                       C.DrawColor = GetDrawColor( PRI );
                       C.DrawScreenText (string(InvasionProPlayerReplicationInfo(PRI).PlayerHealth), HudScale * 0.14, DrawOffset + (HudScale * 0.02855), DP_UpperLeft);
                   }
                   else  if(InvasionProFakeFriendlyMonsterReplicationInfo(PRI) != None)//Monster's version of info
                   {
                       PlayerName = Repl( PlayerName, "SMP", "", false);
                       PlayerName = Repl( PlayerName, "SSP", "", false);
                       PlayerName = Left(PlayerName, 18);
                       C.DrawScreenText (PlayerName, HudScale * 0.005, DrawOffset + (HudScale * 0.02855), DP_UpperLeft);
                       C.DrawColor = GetMonsterDrawColor(PRI);
                       C.DrawScreenText (string(InvasionProFakeFriendlyMonsterReplicationInfo(PRI).MonsterHealth), HudScale * 0.14, DrawOffset + (HudScale * 0.02855), DP_UpperLeft);
                   }

                   FramePos++;
               }
           }
       }
   }
}

simulated function Pawn GetMonsterPawn(PlayerReplicationInfo PRI)
{
   local Pawn P;

   ForEach DynamicActors(class'Pawn', P)
   {
       if ( P != None && P.PlayerReplicationInfo == PRI )
       {
           return P;
       }
   }

   return None;
}

simulated function color GetMonsterDrawColor(PlayerReplicationInfo PRI)
{
   local Color FinalColor;
   local float HealthPercent;

   FinalColor.R = 0;
   FinalColor.G = 0;
   FinalColor.B = 0;
   FinalColor.A = 255;
   HealthPercent = 1.00f * ( InvasionProFakeFriendlyMonsterReplicationInfo(PRI).MonsterHealth/InvasionProFakeFriendlyMonsterReplicationInfo(PRI).MonsterHealthMax );

   if(HealthPercent == 0.50)
   {
       FinalColor.R = 255;
       FinalColor.G = 255;
   }
   else if(HealthPercent > 0.50)
   {
       FinalColor.R = 255-(255*HealthPercent);
       FinalColor.G = 255;
   }
   else if(HealthPercent < 0.50)
   {
       FinalColor.R = 255;
       FinalColor.G = 255*HealthPercent;
   }

   return FinalColor;
}

simulated function color GetDrawColor(PlayerReplicationInfo PRI)
{
   local Color FinalColor;
   local float HealthPercent;

   FinalColor.R = 0;
   FinalColor.G = 0;
   FinalColor.B = 0;
   FinalColor.A = 255;
   HealthPercent = 1.00f * ( float(InvasionProPlayerReplicationInfo(PRI).PlayerHealth)/float(InvasionProPlayerReplicationInfo(PRI).PlayerHealthMax) );

   if(HealthPercent == 0.50)
   {
       FinalColor.R = 255;
       FinalColor.G = 255;
   }
   else if(HealthPercent > 0.50)
   {
       FinalColor.R = 255-(255*HealthPercent);
       FinalColor.G = 255;
   }
   else if(HealthPercent < 0.50)
   {
       FinalColor.R = 255;
       FinalColor.G = 255*HealthPercent;
   }

   return FinalColor;
}

simulated function StartLoading()
{
   SetTimer(0.0175,true);
   bLoadingStarted = true;
}

simulated function Timer()
{
   Super.Timer();

// LoadingBarSpread = ( FClamp ( 0.625 / InvasionProGameReplicationInfo(PlayerOwner.GameReplicationInfo).NumMonstersToLoad, 0.001, 0.625 ) ) / 10;
   LoadingBarSpread = ( FClamp ( (0.625 / TotalPreloadCount), 0.001, 0.625 ) ) / 10;

   if(LoadingBarSizeX < 0.625)
   {
       LoadingBarSizeX = FClamp(LoadingBarSizeX + LoadingBarSpread, 0.0f, 0.625 * (NumPreloadNow/TotalPreloadCount));
   }
   else
   {
       SetTimer(0.0,false);
   }
}

simulated function DrawLoading(Canvas C)
{
   local string ProgressText;
   local float TextX,TextY;

   if(InvasionProXPlayer(PlayerOwner).Preloader==None)
       return;

   NumPreloadNow = InvasionProXPlayer(PlayerOwner).Preloader.NumNow;
   TotalPreloadCount = InvasionProXPlayer(PlayerOwner).Preloader.TotalCount;

   if(NumPreloadNow==0)
       ProgressText = "Initializing...";
   else
       ProgressText = int(NumPreloadNow)@"of"@int(TotalPreloadCount)@"(%"$int((NumPreloadNow/TotalPreloadCount)*100)$")";

   C.Font = GetFontSizeIndex(C, -5 + int(HudScale * 1.25));
   C.TextSize(ProgressText,TextX,TextY);

   //container
   C.Reset();
   C.Style = ERenderStyle.STY_Translucent;
   C.DrawColor = LoadingContainerColor;
   C.SetPos( 0.5 * C.ClipX - ((0.625 * C.ClipY)/2), 0.85 * C.ClipY - 1 );
   C.DrawTilePartialStretched(LoadingContainerImage, 0.625 * C.ClipY, TextY+1 );
   C.DrawColor = WhiteColor;
   C.SetPos( 0.5 * C.ClipX - ((0.625 * C.ClipY)/2), 0.85 * C.ClipY - 1 );
   C.DrawTilePartialStretched(LoadingContainerCompanionImage, 0.625 * C.ClipY, TextY+1 );
   C.DrawColor = WhiteColor;
   C.Font = GetFontSizeIndex(C, -3 + int(HudScale * 1.25));
   C.Style = ERenderStyle.STY_Normal;
   C.DrawScreenText (PreloadingText, 0.5, 0.8, DP_MiddleMiddle);
   if(NumPreloadNow>0)
       C.DrawScreenText (InvasionProXPlayer(PlayerOwner).Preloader.LoadingNext, 0.5, 0.825, DP_MiddleMiddle);

   //bar
   if(NumPreloadNow>0)
   {
       C.Reset();
       C.DrawColor = WhiteColor;
       C.SetPos( 0.5 * C.ClipX - ((LoadingBarSizeX * C.ClipY)/2), 0.85 * C.ClipY - 1 );
       C.DrawTilePartialStretched(LoadingBarImage, LoadingBarSizeX * C.ClipY, TextY );
   }

   //progress
   C.Reset();
   C.DrawColor = WhiteColor;
   C.Font = GetFontSizeIndex(C, -5 + int(HudScale * 1.25));
   C.DrawScreenText(ProgressText, 0.5, 0.85, DP_UpperMiddle);
}

simulated function DrawMonsterCount(Canvas C)
{
   DrawSpriteWidget( C, MonsterCountBackground);
   DrawSpriteWidget( C, MonsterCountBackgroundDisc);
   DrawSpriteWidget( C, MonsterCountImage);

   MonsterCount.Value = InvasionProGameReplicationInfo(PlayerOwner.GameReplicationInfo).CurrentMonstersNum;
   DrawNumericWidget( C, MonsterCount, DigitsBig);
}

simulated function Tick(float DeltaTime)
{
    if(InvasionProXPlayer(PlayerOwner) != None)
        InvasionProXPlayer(PlayerOwner).SetSpecMonsters(bSpecMonsters);

    Super.Tick(DeltaTime);

    RadarPulse = RadarPulse + 0.5 * DeltaTime;

#ifeq ENABLE_TURINVX_RADAR 1
    if(bTURRadar)
    {
        RadarPulse = RadarPulse + 0.5 * DeltaTime * FMax(1,EnemyCount * 0.3);
        if ( RadarPulse >= 1 )
        {
            if ( !bNoRadarSound && (Level.TimeSeconds - LastDrawRadar < 0.2) )
                PlayerOwner.ClientPlaySound(Sound'RadarBeep_Old',true,FMin(1.0,300/MinEnemyDist));
            RadarPulse = RadarPulse - 1;
        }
    }
    else if ( RadarPulse >= 1 )
#else
    if(RadarPulse >= 1)
#endif //ENABLE_TURINVX_RADAR
    {
        if ( !bNoRadarSound && (Level.TimeSeconds - LastDrawRadar < 0.2) )
        {
            if(PulseSound != None)
            {
                PlayerOwner.ClientPlaySound(PulseSound,true,50);
            }
        }
        RadarPulse = RadarPulse - 1;
    }
}

simulated function DrawSpectatingHud(Canvas C)
{
    local string InfoString;
    local plane OldModulate;
    local float xl,yl,Full, Height, Top, TextTop, MedH, SmallH,Scale;

    if(PlayerOwner == None)
           return;

    if(!bMeshesLoaded && bDrawLoading)
    {
        DrawLoading(C);
    }

    // Hack for tutorials.
    bIsCinematic = IsInCinematic();

    DisplayLocalMessages(C);

    if ( bIsCinematic )
        return;

    ShowTeamScorePassA(C);
    ShowTeamScorePassC(C);

   if (InvasionProGameReplicationInfo(PlayerOwner.GameReplicationInfo) != None)
   {
       if(bDisplayMonsterCounter)
       {
           DrawMonsterCount(C);
       }

       if(bDisplayPlayerList)
       {
           DrawPlayerNames(C);
       }
   }

    OldModulate = C.ColorModulate;

    C.Font = GetMediumFontFor(C);
    C.StrLen("W",xl,MedH);
    Height = MedH;
    C.Font = GetConsoleFont(C);
    C.StrLen("W",xl,SmallH);
    Height += SmallH;

    Full = Height;
    Top  = C.ClipY-8-Full;

    Scale = (Full+16)/128;

    // I like Yellow

    C.ColorModulate.X=255;
    C.ColorModulate.Y=255;
    C.ColorModulate.Z=0;
    C.ColorModulate.W=255;

    // Draw Border

    C.SetPos(0,Top);
    C.SetDrawColor(255,255,255,255);
    C.DrawTileStretched(material'InterfaceContent.SquareBoxA',C.ClipX,Full);
    C.ColorModulate.Z=255;

    TextTop = Top + 4;

    C.SetPos(0,Top-8);
    C.Style=5;
    C.DrawTile(material'LMSLogoSmall',256*Scale,128*Scale,0,0,256,128);
    C.Style=1;
    if ( UnrealPlayer(Owner).bDisplayWinner ||  UnrealPlayer(Owner).bDisplayLoser )
    {
        if ( UnrealPlayer(Owner).bDisplayWinner )
            InfoString = YouveWonTheMatch;
        else
        {
            if ( PlayerReplicationInfo(PlayerOwner.GameReplicationInfo.Winner) != None )
                InfoString = WonMatchPrefix$PlayerReplicationInfo(PlayerOwner.GameReplicationInfo.Winner).PlayerName$WonMatchPostFix;
            else
                InfoString = YouveLostTheMatch;
        }

        C.SetDrawColor(255,255,255,255);
        C.Font = GetMediumFontFor(C);
        C.StrLen(InfoString,XL,YL);
        C.SetPos( (C.ClipX/2) - (XL/2), Top + (Full/2) - (YL/2));
        C.DrawText(InfoString,false);
    }
    else if ( Pawn(PlayerOwner.ViewTarget) != None && Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo != None )
    {
        // Draw View Target info

        C.SetDrawColor(32,255,32,255);

        if ( C.ClipX < 640 )
            SmallH = 0;
        else
        {
            // Draw "Now Viewing"

            C.SetPos((256*Scale*0.75),TextTop);
            C.DrawText(NowViewing,false);

            // Draw "Score"

            InfoString = GetScoreText();
            C.StrLen(InfoString,Xl,Yl);
            C.SetPos(C.ClipX-5-XL,TextTop);
            C.DrawText(InfoString);
        }

        // Draw Player Name

        C.SetDrawColor(255,255,0,255);
        C.Font = GetMediumFontFor(C);
        C.SetPos((256*Scale*0.75),TextTop+SmallH);
        C.DrawText(Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo.PlayerName,false);

        // Draw Score

        InfoString = GetScoreValue(Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo);
        C.StrLen(InfoString,xl,yl);
        C.SetPos(C.ClipX-5-XL,TextTop+SmallH);
        C.DrawText(InfoString,false);

        // Draw Tag Line

        C.Font = GetConsoleFont(C);
        InfoString = GetScoreTagLine();
        C.StrLen(InfoString,xl,yl);
        C.SetPos( (C.ClipX/2) - (XL/2),Top-3-YL);
        C.DrawText(InfoString);
    }
    else if(Monster(PlayerOwner.ViewTarget) != None)
    {
       // Draw View Target info

       C.SetDrawColor(32,255,32,255);

       if ( C.ClipX < 640 )
           SmallH = 0;
       else
       {
           // Draw "Now Viewing"
           C.SetPos((256*Scale*0.75),TextTop);
           C.DrawText(NowViewing,false);

           // Draw "Monster Team Score"

           InfoString = MonsterScoretext;
           C.StrLen(InfoString,Xl,Yl);
           C.SetPos(C.ClipX-5-XL,TextTop);
           C.DrawText(InfoString);
       }

       // Draw Monster Name

       C.SetDrawColor(255,255,0,255);
       C.Font = GetMediumFontFor(C);
       C.SetPos((256*Scale*0.75),TextTop+SmallH);
       C.DrawText(Monster(PlayerOwner.ViewTarget).Name,false);

       // Draw Monster Score

       InfoString = ""$(InvasionProGameReplicationInfo(PlayerOwner.GameReplicationInfo).MonsterTeamScore);
       C.StrLen(InfoString,xl,yl);
       C.SetPos(C.ClipX-5-XL,TextTop+SmallH);
       C.DrawText(InfoString,false);

       // Draw Tag Line

       C.Font = GetConsoleFont(C);
       InfoString = GetScoreTagLine();
       C.StrLen(InfoString,xl,yl);
       C.SetPos( (C.ClipX/2) - (XL/2),Top-3-YL);
        C.DrawText(InfoString);
   }
    else
    {
        InfoString = GetInfoString();

        // Draw
        C.SetDrawColor(255,255,255,255);
        C.Font = GetMediumFontFor(C);
        C.StrLen(InfoString,XL,YL);
        C.SetPos( (C.ClipX/2) - (XL/2), Top + (Full/2) - (YL/2));
        C.DrawText(InfoString,false);
    }

    C.ColorModulate = OldModulate;
}

simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional String CriticalString)
{
   if( Message == None || PlayerOwner == None)
       return;

   Super.LocalizedMessage(Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString);
}

function DisplayHit(vector HitDir, int Damage, class<DamageType> damageType)
{
   local int i;
   local vector X,Y,Z;
   local byte Ignore[4];
   local rotator LookDir;
   local float NewDamageTime,Forward,Left;

   if(PawnOwner != None)
   {
       LookDir = PawnOwner.Rotation;
           LookDir.Pitch = 0;
   }
       else
       {
       LookDir.Yaw = 0;
       LookDir.Roll = 0;
       LookDir.Pitch = 0;
   }

    GetAxes(LookDir, X,Y,Z);
    HitDir.Z = 0;
    HitDir = Normal(HitDir);

    Forward = HitDir Dot X;
    Left = HitDir Dot Y;

    if ( Forward > 0 )
    {
        if ( Forward > 0.7 )
            Emphasized[0] = 1;
        Ignore[1] = 1;
    }
    else
    {
        if ( Forward < -0.7 )
            Emphasized[1] = 1;
        Ignore[0] = 1;
    }
    if ( Left > 0 )
    {
        if ( Left > 0.7 )
            Emphasized[3] = 1;
        Ignore[2] = 1;
    }
    else
    {
        if ( Left < -0.7 )
            Emphasized[2] = 1;
        Ignore[3] = 1;
    }

    NewDamageTime = 5 * Clamp(Damage,20,30);
    for ( i=0; i<4; i++ )
        if ( Ignore[i] != 1 )
        {
            DamageFlash[i].R = 255;
            DamageTime[i] = NewDamageTime;
        }
}

simulated function DrawMessage( Canvas C, int i, float PosX, float PosY, out float DX, out float DY )
{
   local float FadeValue;
   local float ScreenX, ScreenY;

   //Draw color
   if(ClassIsChildOf (LocalMessages[i].Message, class'InvasionProWaveMessage'))
   {
       LocalMessages[i].DrawColor = InvasionProGameReplicationInfo(PlayerOwner.GameReplicationInfo).WaveDrawColour;
   }
   else if(ClassIsChildOf (LocalMessages[i].Message, class'InvasionProWaveCountDownMessage'))
   {
       LocalMessages[i].DrawColor = InvasionProGameReplicationInfo(PlayerOwner.GameReplicationInfo).WaveCountDownColour;
   }

    if ( !LocalMessages[i].Message.default.bFadeMessage )
    {
        C.DrawColor = LocalMessages[i].DrawColor;
   }
    else
    {
        FadeValue = (LocalMessages[i].EndOfLife - Level.TimeSeconds);
        C.DrawColor = LocalMessages[i].DrawColor;
        C.DrawColor.A = LocalMessages[i].DrawColor.A * (FadeValue/LocalMessages[i].LifeTime);
    }

    C.Font = LocalMessages[i].StringFont;
    GetScreenCoords( PosX, PosY, ScreenX, ScreenY, LocalMessages[i], C );
    C.SetPos( ScreenX, ScreenY );
    DX = LocalMessages[i].DX / C.ClipX;
    DY = LocalMessages[i].DY / C.ClipY;

    if ( LocalMessages[i].Message.default.bComplexString )
    {
        LocalMessages[i].Message.static.RenderComplexMessage( C, LocalMessages[i].DX, LocalMessages[i].DY,
            LocalMessages[i].StringMessage, LocalMessages[i].Switch, LocalMessages[i].RelatedPRI,
            LocalMessages[i].RelatedPRI2, LocalMessages[i].OptionalObject );
    }
    else
    {
        C.DrawTextClipped( LocalMessages[i].StringMessage, false );
    }

    LocalMessages[i].Drawn = true;
}

defaultproperties
{
   EnemyHitSounds(0)="None"
   EnemyHitSounds(1)="TURInvPro.HitSound01"
   EnemyHitSounds(2)="TURInvPro.HitSound02"
   EnemyHitSounds(3)="TURInvPro.HitSound03"
   EnemyHitSounds(4)="TURInvPro.HitSound04"
   EnemyHitSounds(5)="TURInvPro.HitSound05"
   EnemyHitSounds(6)="TURInvPro.HitSound06"
   EnemyHitSounds(7)="TURInvPro.HitSound07"
   FriendlyHitSounds(0)="None"
   FriendlyHitSounds(1)="TURInvPro.HitSound01"
   FriendlyHitSounds(2)="TURInvPro.HitSound02"
   FriendlyHitSounds(3)="TURInvPro.HitSound03"
   FriendlyHitSounds(4)="TURInvPro.HitSound04"
   FriendlyHitSounds(5)="TURInvPro.HitSound05"
   FriendlyHitSounds(6)="TURInvPro.HitSound06"
   FriendlyHitSounds(7)="TURInvPro.HitSound07"
   CurrentEnemyHitSound="None"
   CurrentFriendlyHitSound="None"
   MaxHitSoundsPerSecond=5
   bDynamicHitSounds=True
   HitSoundVolume=0.500000
   KillSoundVolume=0.500000
    RadarScale=0.200000
    MonsterScoretext="Monster Team Score"
    RadarSpecialOffsetX=0.621000
    RadarSpecialOffsetY=0.010000
    bDisplayBossTimer=True
    bDisplayBossNames=True
    MonsterColor=(G=255,R=255,A=255)
    PlayerColor=(B=255,G=255,A=255)
    RadarColor=(B=100,G=150,A=255)
    OwnerColor=(B=255,G=255,R=255,A=255)
    FriendlyMonsterColor=(B=255,G=255,A=255)
    MiscColor=(R=125,B=125,G=125,A=255)
    bDisplayMonsterCounter=True
    bDisplayPlayerList=True
    RadarPosX=0.912558
    RadarPosY=0.192209
    PulseColor=(B=215,G=160,R=50,A=255)
    bSpecMonsters=True
    EnemyKillSounds(0)="None"
    EnemyKillSounds(1)="TURInvPro.KillSound01"
    EnemyKillSounds(2)="TURInvPro.KillSound02"
    EnemyKillSounds(3)="TURInvPro.KillSound03"
    EnemyKillSounds(4)="TURInvPro.KillSound04"
    EnemyKillSounds(5)="TURInvPro.KillSound05"
    CurrentKillSound="None"
    RadarSound="SkaarjPack_rc.RadarPulseSound.RadarPulseSound"
    RadarImage=Texture'TURInvPro.HUD.NewRadar01'
    PulseImage=Shader'TURInvPro.HUD.PulseRing01_Shader'
    RadarMaterials(1)=Texture'TURInvPro.HUD.NewRadar01'
    RadarMaterials(2)=Texture'TURInvPro.HUD.NewRadar02'
    RadarMaterials(3)=Texture'TURInvPro.HUD.NewRadar03'
    RadarMaterials(4)=Texture'TURInvPro.HUD.NewRadar04'
    RadarMaterials(5)=Texture'TURInvPro.HUD.NewRadar05'
    RadarMaterials(6)=Texture'TURInvPro.HUD.NewRadar06'
    RadarMaterials(7)=Texture'TURInvPro.HUD.NewRadar07'
    RadarMaterials(8)=Texture'TURInvPro.HUD.NewRadar08'
    RadarMaterials(9)=Texture'TURInvPro.HUD.NewRadar09'
    RadarMaterials(10)=Texture'TURInvPro.HUD.NewRadar10'
    PulseMaterials(1)=Shader'TURInvPro.HUD.PulseRing01_Shader'
    PulseMaterials(2)=TexRotator'TURInvPro.HUD.PulseRing02_Rot'
    PulseMaterials(3)=TexRotator'TURInvPro.HUD.PulseRing03_Rot'
    PulseMaterials(4)=TexRotator'TURInvPro.HUD.PulseRing04_Rot'
    PulseMaterials(5)=TexRotator'TURInvPro.HUD.PulseRing05_Rot'
    OwnerIconMaterials(1)=Texture'TURInvPro.Radar_Dot'
   OwnerIconMaterials(2)=Texture'TURInvPro.Radar_Dot_Heart'
   FriendlyPlayerIconMaterials(1)=Texture'TURInvPro.Radar_Dot'
   FriendlyPlayerIconMaterials(2)=Texture'TURInvPro.Radar_Dot_Heart'
   FriendlyMonsterIconMaterials(1)=Texture'TURInvPro.Radar_Dot'
   FriendlyMonsterIconMaterials(2)=Texture'TURInvPro.Radar_Dot_Heart'
   MonsterIconMaterials(1)=Texture'TURInvPro.Radar_Dot'
   MonsterIconMaterials(2)=Texture'TURInvPro.Radar_Dot_Heart'
   MiscIconMaterials(1)=Texture'TURInvPro.Radar_Dot'
   MiscIconMaterials(2)=Texture'TURInvPro.Radar_Dot_Heart'
    OwnerIcon=Texture'TURInvPro.Radar_Dot'
    MonsterIcon=Texture'TURInvPro.Radar_Dot'
    FriendlyPlayerIcon=Texture'TURInvPro.Radar_Dot'
    FriendlyMonsterIcon=Texture'TURInvPro.Radar_Dot'
    MiscIcon=Texture'TURInvPro.Radar_Dot'
    bDrawPetInfo=True
    RadarRange=2200.000000
    ClassicRadarRange=3000.000000
    MonsterCounterColor=(G=255,R=255)
   OwnerDotScale=1.000000
   FriendlyPlayerDotScale=1.000000
   FriendlyMonsterDotScale=1.000000
   MonsterDotScale=1.000000
   MiscDotScale=1.000000
    DotULWidth=128.000000
    DotVLHeight=128.000000
    MonsterCounterFont=Font'2k4Fonts.Verdana24'
    LoadingContainerColor=(B=255,G=255,R=255)
    OrangeColor=(G=128,R=255,A=255)
    MonsterNumColor=(G=192,R=255,A=255)
    BossNameColor=(B=10,G=187,R=245,A=255)
    LoadingContainerImage=Texture'2K4Menus.NewControls.ComboTickWatched'
    LoadingContainerCompanionImage=Shader'XGameShaders.BRShaders.BombIconBS'
    LoadingBarImage=Texture'2K4Menus.NewControls.GradientButtonFocused'
    LoadingBarSizeX=0.001000
    LoadingFont=Font'2k4Fonts.Verdana24'
    PlayerFont=Font'UT2003Fonts.FontMedium'
    MonsterCountBackground=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=168,Y1=211,X2=334,Y2=255),TextureScale=0.530000,OffsetX=40,OffsetY=8,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(A=255),Tints[1]=(A=255))
    MonsterCountBackgroundDisc=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=119,Y1=258,X2=173,Y2=313),TextureScale=0.530000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
    MonsterCountImage=(WidgetTexture=Texture'TURInvPro.HUD.MonsterCountImage',RenderStyle=STY_Alpha,TextureCoords=(Y1=258,X2=64,Y2=313),TextureScale=0.350000,OffsetX=6,OffsetY=10,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=11,G=216,R=244,A=255),Tints[1]=(B=11,G=216,R=244,A=255))
    MonsterCount=(RenderStyle=STY_Alpha,TextureScale=0.390000,OffsetX=80,OffsetY=20,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
    BossTime=(RenderStyle=STY_Alpha,DrawPivot=DP_UpperMiddle,MinDigitCount=5,TextureScale=0.500000,PosX=0.500000,OffsetY=30,Tints[0]=(R=255,A=255),Tints[1]=(R=255,A=255),bPadWithZeroes=1) //OffsetX=540
    PlayerBackground=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=168,Y1=211,X2=334,Y2=255),TextureScale=0.500000,OffsetX=10,ScaleMode=SM_Up,Scale=0.500000,Tints[0]=(B=255,G=255,R=255,A=75),Tints[1]=(B=255,G=255,R=255,A=255))
    PlayerBackgroundSpacer=0.550000
    PlayerBackgroundAbsoluteY=110.000000
    PlayerFontScale=-2
    PlayerNameSpacer=0.000452
    PlayerFontYSize=0.750000
    PlayerFontXSize=0.750000
    PlayerListPosY=0.120000
    PlayerListSpacerY=0.025000
    bDrawLoading=True
    BossBarBackground=(WidgetTexture=Texture'TURInvPro.HUD.Background_bar01',RenderStyle=STY_Alpha,TextureCoords=(X2=256,Y2=22),TextureScale=1.000000,OffsetX=256,OffsetY=3,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(A=255),Tints[1]=(A=255))
    BossImage=Texture'2K4Menus.Controls.checkBoxBall_w'
    testX=0.500000
    testY=0.080000
    TestX2=0.600000
    TestY2=0.500000
    PreloadingText="Preloading"
    BehindViewCrosshairSize=0.250000
    TestColor=(G=255,A=255)
    FriendlyMonsterNameColor=(B=255,G=255,A=255)
    HostileMonsterNameColor=(R=255,A=255)
    MonsterNameOffset=12.000000
    bDrawTimer=False
    WaitingToSpawn="Press [Fire] to join the Invasion!"
    YouveLostTheMatch="The Invasion Continues"
}
