//=============================================================================
// InvasionProMonsterStatsConfig.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProMonsterStatsConfig extends GUICustomPropertyPage;

var() Automated GUILabel currentTotalSpawned;
var() Automated GUILabel currentTotalDamage;
var() Automated GUILabel currentTotalKills;
var() Automated GUILabel currentTotalGames;

var() Automated GUILabel currentBestMonster;
var() Automated GUILabel currentWorstMonster;
var() Automated GUILabel currentCommonMonster;
var() Automated GUILabel currentRareMonster;

var() Automated GUILabel BestestMonster;

var() Automated moSlider currentModelFOV;

var() Automated GUILabel currentModelViewer;

var() editinline editconst noexport InvasionProSpinnyMonster SpinnyDude;
var() vector SpinnyDudeOffset;
var() automated GUIButton b_DropTarget;
var() int nfov;
var() class<Monster> M;

var() array<Name> AnimList;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
   local rotator R;

   Super.InitComponent(MyController, MyOwner);

  // Spawn spinning character actor
   if ( SpinnyDude == None )
   {
       SpinnyDude = PlayerOwner().spawn(Class'TURInvPro.InvasionProSpinnyMonster');
   }

   SpinnyDude.bPlayRandomAnims = false;
   SpinnyDude.SetDrawScale(0.9);
    SpinnyDude.SpinRate = 0;
    SpinnyDude.AmbientGlow = SpinnyDude.default.AmbientGlow * 0.8;
   R.Yaw = 32768;
   R.Pitch = -1024;
   SpinnyDude.SetRotation(R+PlayerOwner().Rotation);
    SpinnyDude.bHidden = false;

   b_DropTarget.WinWidth=0.284351;
   b_DropTarget.WinHeight=0.577338;
   b_DropTarget.WinLeft=0.649481;
   b_DropTarget.WinTop=0.153832;

   sb_Main.Caption = "Monster Stats";

   t_WindowTitle.Caption = "InvasionPro: Monster Stats";

   b_OK.WinWidth=0.251747;
   b_OK.WinHeight=0.065055;
   b_OK.WinLeft=0.078533;
   b_OK.WinTop=0.792278;

   b_Cancel.WinWidth=0.171970;
   b_Cancel.WinHeight=0.048624;
   b_Cancel.WinLeft=0.377140;
   b_Cancel.WinTop=0.799679;

   nFov = 60;
   currentModelFOV.SetValue(60);

   currentTotalDamage.WinHeight=0.128806;
   currentTotalDamage.WinLeft=0.070000;
   currentTotalDamage.WinTop=0.213688;

   InitializeStats();
}

function InitializeStats()
{
   local array<string> ClassParts;

   Split(class'InvasionPro'.default.BestMonster, ".", ClassParts );
   if(ClassParts[1] != "")
       currentBestMonster.Caption = "Best Monster: "@ClassParts[1];
   Split(class'InvasionPro'.default.WorstMonster, ".", ClassParts );
   if(ClassParts[1] != "")
       currentWorstMonster.Caption = "Worst Monster: "@ClassParts[1];
   Split(class'InvasionPro'.default.CommonMonster, ".", ClassParts );
   if(ClassParts[1] != "")
       currentCommonMonster.Caption = "Common Monster: "@ClassParts[1];
   Split(class'InvasionPro'.default.RareMonster, ".", ClassParts );
   if(ClassParts[1] != "")
       currentRareMonster.Caption = "Rarest Monster: "@ClassParts[1];
   currentTotalSpawned.Caption = "Total Monsters Spawned: "@class'InvasionPro'.default.TotalSpawned;
   currentTotalDamage.Caption = "Total Monster Damage: "@class'InvasionPro'.default.TotalDamage;
   currentTotalKills.Caption = "Total Monster Kills: "@class'InvasionPro'.default.TotalKills;
   currentTotalGames.Caption = "Total Games Played: "@class'InvasionPro'.default.TotalGames;

   UpdateSpinnyDude();

   //logspinnydude();

}

function bool InternalOnClick(GUIComponent Sender)
{
   if ( SpinnyDude != None )
   {
       SpinnyDude.SetDrawType(DT_StaticMesh);
       SpinnyDude.bHidden = true;
   }

   Controller.CloseMenu(false);
   return true;
}

function bool ResetStats(GUIComponent Sender)
{
   local int i;

   class'InvasionPro'.default.TotalGames = 0;
   class'InvasionPro'.default.TotalSpawned = 0;
   class'InvasionPro'.default.TotalDamage = 0;
   class'InvasionPro'.default.TotalKills = 0;
   class'InvasionPro'.default.BestMonster = "None";
   class'InvasionPro'.default.WorstMonster = "None";
   class'InvasionPro'.default.CommonMonster = "None";
   class'InvasionPro'.default.RareMonster = "None";

   for(i=0;i<class'InvasionProMonsterTable'.default.MonsterTable.Length;i++)
   {
       class'InvasionProMonsterTable'.default.MonsterTable[i].NumSpawns = 0;
       class'InvasionProMonsterTable'.default.MonsterTable[i].NumDamage = 0;
       class'InvasionProMonsterTable'.default.MonsterTable[i].NumKills = 0;
   }

   class'InvasionProMonsterTable'.static.StaticSaveConfig();
   class'InvasionPro'.static.StaticSaveConfig();

   InitializeStats();

   return true;
}

function UpdateSpinnyDude()
{
    local Material BodySkin, HeadSkin;
    local string BodySkinName, HeadSkinName;

    M = class<Monster>(DynamicLoadObject(class'InvasionPro'.default.BestMonster, class'class',true));

    if(M == None)
    {
       SpinnyDude.SetDrawType(DT_StaticMesh);
       b_DropTarget.Caption = "# Offline #";
       return;
   }
   //log(animationset(m.default.mesh).defaultanimation);
    BodySkinName = string(M.default.Skins[0]);
    HeadSkinName = string(M.default.Skins[1]);

    BodySkin = Material(DynamicLoadObject(BodySkinName, class'Engine.Material',true));
    if(BodySkin == None)
    {
        Log("Could not load body material: " @ BodySkinName);
        return;
    }

    HeadSkin = Material(DynamicLoadObject(HeadSkinName, class'Engine.Material',true));
    if(HeadSkin == None)
    {
        Log("Could not load head material: " @ HeadSkinName);
        return;
    }
    SpinnyDude.SetDrawType(DT_Mesh);
    SpinnyDude.LinkMesh(M.default.Mesh);
    SpinnyDude.Skins[0] = BodySkin;
    SpinnyDude.Skins[1] = HeadSkin;
    SetUpAnimation();
}

function SetUpAnimation()
{
   local int i, NumAnim;
   local int AnimCount;

   NumAnim = AnimList.Length;
   AnimList.Remove(NumAnim, NumAnim);

   for(i=0;i<class'InvasionProAnimationManager'.default.AnimNames.Length;i++)
   {
       if( SpinnyDude.HasAnim(class'InvasionProAnimationManager'.default.AnimNames[i]) )
       {
           AnimList.Insert(AnimCount, 1);
           AnimList[AnimCount] = class'InvasionProAnimationManager'.default.AnimNames[i];
           AnimCount++;
       }
   }

   SpinnyDude.LoopAnim(AnimList[0],1.0/SpinnyDude.Level.TimeDilation );
}

function bool InternalDraw(Canvas canvas)
{
    local vector CamPos, X, Y, Z;
    local rotator CamRot;
    local float   oOrgX, oOrgY;
    local float   oClipX, oClipY;

   oOrgX = Canvas.OrgX;
   oOrgY = Canvas.OrgY;
   oClipX = Canvas.ClipX;
   oClipY = Canvas.ClipY;

   Canvas.OrgX = b_DropTarget.ActualLeft();
   Canvas.OrgY = b_DropTarget.ActualTop();
   Canvas.ClipX = b_DropTarget.ActualWidth();
   Canvas.ClipY = b_DropTarget.ActualHeight();

   canvas.GetCameraLocation(CamPos, CamRot);
   GetAxes(CamRot, X, Y, Z);

   SpinnyDude.SetLocation(CamPos + (SpinnyDudeOffset.X * X) + (SpinnyDudeOffset.Y * Y) + (SpinnyDudeOffset.Z * Z));
   canvas.DrawActorClipped(SpinnyDude, false,  b_DropTarget.ActualLeft(), b_DropTarget.ActualTop(), b_DropTarget.ActualWidth(), b_DropTarget.ActualHeight(), true, nFov);

   Canvas.OrgX = oOrgX;
   Canvas.OrgY = oOrgY;
   Canvas.ClipX = oClipX;
   Canvas.ClipY = oClipY;

    return true;
}

event Closed(GUIComponent Sender, bool bCancelled)
{
    Super.Closed(Sender, bCancelled);

    if ( SpinnyDude != None )
    {
       SpinnyDude.SetDrawType(DT_StaticMesh);
        SpinnyDude.bHidden = true;
   }
}

function bool RaceCapturedMouseMove(float deltaX, float deltaY)
{
    local rotator r;

    r = SpinnyDude.Rotation;
    r.Yaw -= (256 * DeltaX);
    r.Pitch += (256 * DeltaY);
    SpinnyDude.SetRotation(r);
    return true;
}

function InternalOnChange(GUIComponent Sender)
{
   if(Sender == currentModelFOV)
   {
       SpinnyDudeOffset.X = currentModelFOV.GetValue();
   }
}

defaultproperties
{
     Begin Object Class=GUILabel Name=TotalSpawned
         Caption="Total Monsters Spawned: "
         StyleName="TextLabel"
         WinTop=0.205144
         WinLeft=0.070000
         WinWidth=0.865933
         WinHeight=0.056068
         RenderWeight=0.200000
         TabOrder=0
     End Object
     currentTotalSpawned=GUILabel'TURInvPro.InvasionProMonsterStatsConfig.TotalSpawned'

     Begin Object Class=GUILabel Name=TotalDamage
         Caption="Total Monster Damage: "
         StyleName="TextLabel"
         WinTop=0.213688
         WinLeft=0.070000
         WinWidth=0.865933
         WinHeight=0.056068
         RenderWeight=0.200000
         TabOrder=3
     End Object
     currentTotalDamage=GUILabel'TURInvPro.InvasionProMonsterStatsConfig.TotalDamage'

     Begin Object Class=GUILabel Name=TotalKills
         Caption="Total Monster Kills: "
         StyleName="TextLabel"
         WinTop=0.328435
         WinLeft=0.070000
         WinWidth=0.865933
         WinHeight=0.056068
         RenderWeight=0.200000
         TabOrder=2
     End Object
     currentTotalKills=GUILabel'TURInvPro.InvasionProMonsterStatsConfig.TotalKills'

     Begin Object Class=GUILabel Name=TotalGames
         Caption="Total Games: "
         StyleName="TextLabel"
         WinTop=0.142888
         WinLeft=0.070000
         WinWidth=0.865933
         WinHeight=0.056068
         RenderWeight=0.200000
         TabOrder=1
     End Object
     currentTotalGames=GUILabel'TURInvPro.InvasionProMonsterStatsConfig.TotalGames'

     Begin Object Class=GUILabel Name=BestMonster
         Caption="Best Monster: "
         StyleName="TextLabel"
         WinTop=0.389470
         WinLeft=0.070000
         WinWidth=0.865933
         WinHeight=0.056068
         RenderWeight=0.200000
         TabOrder=4
     End Object
     CurrentBestMonster=GUILabel'TURInvPro.InvasionProMonsterStatsConfig.BestMonster'

     Begin Object Class=GUILabel Name=WorstMonster
         Caption="Worst Monster: "
         StyleName="TextLabel"
         WinTop=0.451726
         WinLeft=0.070000
         WinWidth=0.865933
         WinHeight=0.056068
         RenderWeight=0.200000
         TabOrder=5
     End Object
     CurrentWorstMonster=GUILabel'TURInvPro.InvasionProMonsterStatsConfig.WorstMonster'

     Begin Object Class=GUILabel Name=CommonMonster
         Caption="Common Monster: "
         StyleName="TextLabel"
         WinTop=0.513982
         WinLeft=0.070000
         WinWidth=0.865933
         WinHeight=0.056068
         RenderWeight=0.200000
         TabOrder=6
     End Object
     CurrentCommonMonster=GUILabel'TURInvPro.InvasionProMonsterStatsConfig.CommonMonster'

     Begin Object Class=GUILabel Name=RareMonster
         Caption="Rarest Monster: "
         StyleName="TextLabel"
         WinTop=0.577458
         WinLeft=0.070000
         WinWidth=0.865933
         WinHeight=0.056068
         RenderWeight=0.200000
         TabOrder=7
     End Object
     CurrentRareMonster=GUILabel'TURInvPro.InvasionProMonsterStatsConfig.RareMonster'

     Begin Object Class=GUILabel Name=Plaque
         Caption="Current Best Monster"
         StyleName="AltComboButton"
         WinTop=0.793645
         WinLeft=0.653816
         WinWidth=0.278505
         WinHeight=0.056785
         RenderWeight=0.200000
         TabOrder=1
     End Object
     BestestMonster=GUILabel'TURInvPro.InvasionProMonsterStatsConfig.Plaque'

     Begin Object Class=moSlider Name=ModelFOV
         MaxValue=1000.000000
         SliderCaptionStyleName="TextLabel"
         CaptionWidth=0.200000
         Caption="Zoom"
         OnCreateComponent=ModelFOV.InternalOnCreateComponent
         Hint="zoom the monster in or out"
         WinTop=0.744219
         WinLeft=0.649584
         WinWidth=0.283725
         WinHeight=0.045471
         TabOrder=13
         bBoundToParent=True
         bScaleToParent=True
         OnChange=InvasionProMonsterStatsConfig.InternalOnChange
     End Object
     currentModelFOV=moSlider'TURInvPro.InvasionProMonsterStatsConfig.ModelFOV'

     Begin Object Class=GUILabel Name=ModelDrawer
         StyleName="TextLabel"
         WinTop=0.211205
         WinLeft=0.692450
         WinWidth=0.241218
         WinHeight=0.557467
         RenderWeight=0.200000
         TabOrder=1
         OnDraw=InvasionProMonsterStatsConfig.InternalDraw
     End Object
     currentModelViewer=GUILabel'TURInvPro.InvasionProMonsterStatsConfig.ModelDrawer'

     SpinnyDudeOffset=(X=70.000000)
     Begin Object Class=GUIButton Name=DropTarget
         bAutoShrink=False
         StyleName="NoBackground"
         WinTop=0.153832
         WinLeft=0.649481
         WinWidth=0.284351
         WinHeight=0.577338
         MouseCursorIndex=5
         bTabStop=False
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
         bDropTarget=True
         OnKeyEvent=DropTarget.InternalOnKeyEvent
         OnCapturedMouseMove=InvasionProMonsterStatsConfig.RaceCapturedMouseMove
     End Object
     b_DropTarget=GUIButton'TURInvPro.InvasionProMonsterStatsConfig.DropTarget'

     nfov=30
     Begin Object Class=GUIButton Name=LockedCancelButton
         Caption="Reset"
         Hint="Reset your monster stats"
         WinTop=0.799679
         WinLeft=0.377140
         WinWidth=0.171970
         WinHeight=0.048624
         TabOrder=9
         bBoundToParent=True
         bScaleToParent=True
         OnClick=InvasionProMonsterStatsConfig.ResetStats
         OnKeyEvent=LockedCancelButton.InternalOnKeyEvent
     End Object
     b_Cancel=GUIButton'TURInvPro.InvasionProMonsterStatsConfig.LockedCancelButton'

     Begin Object Class=GUIButton Name=LockedOKButton
         Caption="Ok"
         Hint="Close this window"
         WinTop=0.792278
         WinLeft=0.078533
         WinWidth=0.251747
         WinHeight=0.065055
         TabOrder=8
         bBoundToParent=True
         bScaleToParent=True
         OnClick=InvasionProMonsterStatsConfig.InternalOnClick
         OnKeyEvent=LockedOKButton.InternalOnKeyEvent
     End Object
     b_OK=GUIButton'TURInvPro.InvasionProMonsterStatsConfig.LockedOKButton'

     bRequire640x480=True
     WinTop=0.078000
     WinLeft=0.010000
     WinWidth=0.724674
     WinHeight=0.659765
     bScaleToParent=True
}
