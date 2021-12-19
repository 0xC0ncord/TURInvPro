//=============================================================================
// InvasionProMonsterConfig.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//==========================================================
//InvasionProMonsterConfig Copyright © Shaun Goeppinger 2012
//==========================================================
class InvasionProMonsterConfig extends GUICustomPropertyPage;

var() editinline editconst noexport InvasionProSpinnyMonster SpinnyDude;
var() vector SpinnyDudeOffset;
var() automated GUIButton b_DropTarget;
var() Automated moSlider currentModelFOV;
var() Automated GUILabel currentModelViewer;
var() int nfov;
var() bool bEditMode;
var() bool bValid;
var() bool bAnimPaused;
var() bool bSpinnyWireMode;
var() Name CurrentAnim;
var() name NameConversion;

var() editinline editconst noexport InvasionProCylinderActor MonsterCylinder;
var() Shader CylinderShader;
var() FinalBlend CylinderTexture;
var() class<Shader> ShaderClass;
var() class<FinalBlend> FinalBlendClass;

var() class<Monster> M;
var() int ActiveMonster;
var() int ActiveBioNumber;
//monster stats for bio information
var() string m_Name;
var() string m_health;
var() string m_score;
var() string m_groundspeed;
var() string m_airspeed;
var() string m_waterspeed;
var() string m_jumpZ;
var() string m_maxhealth;
var() string m_drawscale;
var() string m_col_h;
var() string m_col_r;
var() string m_PivotX;
var() string m_PivotY;
var() string m_PivotZ;
var() string m_kills;
var() string m_spawns;
var() string m_damage;
var() string m_descrip;

var() string AssembledInformation;

var() Automated GUIScrollTextBox  absoluteDefaults;

var() Automated GUILabel monsterPrePivotLabel;
var() Automated GUISectionBackground monsterBio;

var() Automated moNumericEdit currentHealth;
var() Automated moNumericEdit currentMaxHealth;
var() Automated moNumericEdit currentScoreAward;

var() Automated moSlider currentGroundSpeed;
var() Automated moSlider currentAirSpeed;
var() Automated moSlider currentWaterSpeed;
var() Automated moSlider currentJumpZ;
var() Automated moSlider currentGibMultiplier;
var() Automated moSlider currentGibSizeMultiplier;
var() Automated moSlider currentDamageMultiplier;
var() Automated moSlider currentModelRotation;

var() Automated moFloatEdit currentDrawScale;
var() Automated moFloatEdit currentCollisionHeight;
var() Automated moFloatEdit currentCollisionRadius;

var() Automated moFloatEdit currentPrePivotX;
var() Automated moFloatEdit currentPrePivotY;
var() Automated moFloatEdit currentPrePivotZ;

var() Automated moCheckBox currentbRandomHealth;
var() Automated moCheckBox currentbRandomSpeed;
var() Automated moCheckBox currentbRandomSize;

var() Automated moCheckBox currentbSetup;

var() Automated GUIButton b_Random; //set random monster
var() Automated GUIButton b_defaults; //set the defaults
var() Automated GUIButton b_EditMode;
var() Automated GUIButton b_WireMode;
var() Automated GUIButton b_Copy; //copy drawscale,collision height + radius, prepivot to the monster clipboard

var() Automated moComboBox currentMonster;
var() Automated moComboBox currentAnimList;

var() Automated GUIGFXButton b_UArrow;
var() Automated GUIGFXButton b_DArrow;
var() Automated GUIGFXButton b_LArrow;
var() Automated GUIGFXButton b_RArrow;
var() Automated GUIGFXButton b_CArrow;

var() Automated GUIGFXButton b_Play;
var() Automated GUIGFXButton b_Pause;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
   local rotator R;
   local int i;

   Super.InitComponent(MyController, MyOwner);

   //Spawn spinning character actor
   if ( SpinnyDude == None )
   {
       SpinnyDude = PlayerOwner().spawn(Class'TURInvPro.InvasionProSpinnyMonster');
   }

   if(SpinnyDude != None)
   {
       SpinnyDude.bPlayRandomAnims = false;
       SpinnyDude.SetDrawType(DT_Mesh);
       SpinnyDude.SetDrawScale(0.9);
       SpinnyDude.SpinRate = 0;
       SpinnyDude.AmbientGlow = SpinnyDude.default.AmbientGlow * 0.8;
       R.Yaw = 32768;
       R.Pitch = -1024;
       SpinnyDude.SetRotation(R+PlayerOwner().Rotation);
       SpinnyDude.bHidden = false;
   }

   if(MonsterCylinder == None)
   {
       MonsterCylinder = PlayerOwner().spawn(Class'TURInvPro.InvasionProCylinderActor',SpinnyDude);
       //alocate shader and set it up
       CylinderShader= Shader(PlayerOwner().Level.ObjectPool.AllocateObject(ShaderClass));
       CylinderShader.Diffuse=Texture'UCGeneric.SolidColours.Red';
       CylinderShader.Opacity = None;
       CylinderShader.Specular = None;
       CylinderShader.SpecularityMask = None;
       CylinderShader.SelfIllumination = None;
       CylinderShader.SelfIlluminationMask = None;
       CylinderShader.Detail = None;
       CylinderShader.DetailScale = 8.000000;
       CylinderShader.OutputBlending = OB_Normal;
       CylinderShader.TwoSided = false;
       CylinderShader.WireFrame = true;
       CylinderShader.PerformLightingOnSpecularPass = False;
       CylinderShader.ModulateSpecular2X = False;
       CylinderShader.FallbackMaterial = None;
       CylinderShader.SurfaceType = EST_Default;
       //alocate finalblend and set it up
       CylinderTexture = FinalBlend(PlayerOwner().Level.ObjectPool.AllocateObject(FinalBlendClass));
       CylinderTexture.FrameBufferBlending = FB_Translucent;
       CylinderTexture.ZWrite = True;
       CylinderTexture.ZTest = true;
       CylinderTexture.AlphaTest = False;
       CylinderTexture.TwoSided = True;
       CylinderTexture.AlphaRef = 0;
       CylinderTexture.Material = CylinderShader;
       CylinderTexture.FallbackMaterial = None;
       CylinderTexture.SurfaceType = EST_Default;

       MonsterCylinder.Skins[0] = CylinderTexture;
   }

   //window that binds the mesh/character
   b_DropTarget.WinWidth=0.283570;
   b_DropTarget.WinHeight=0.480464;
   b_DropTarget.WinLeft=0.663153;
   b_DropTarget.WinTop=0.151119;


   //resize main inside window


   sb_Main.Caption = "Monster Configuration";
   sb_Main.bScaleToParent=true;
   sb_Main.WinWidth=0.961562;
   sb_Main.WinHeight=0.928808;
   sb_Main.WinLeft=0.017539;
   sb_Main.WinTop=0.048823;

   t_WindowTitle.Caption = "InvasionPro: Monster Configuration";

   //resize ok/save button
   b_OK.WinWidth=0.202528;
   b_OK.WinHeight=0.044743;
   b_OK.WinLeft=0.043377;
   b_OK.WinTop=0.895495;

   //resize cancel/close button
   b_Cancel.WinWidth=0.171970;
   b_Cancel.WinHeight=0.048624;
   b_Cancel.WinLeft=0.787296;
   b_Cancel.WinTop=0.895495;

   b_Copy.FontScale = FNS_Small;

   //resize scrolling information window
   absoluteDefaults.MyScrollText.FontScale=FNS_Small;

   monsterBio.Managecomponent(absoluteDefaults);


   //set zoom/foz of character values to mid range
   //nFov = 60;
   //currentModelFOV.SetValue(1);
   currentModelFOV.SetValue(90);

   //set max visible monster list
   currentMonster.MyComboBox.MaxVisibleItems=20;

   currentAnimList.MyLabel.FontScale = FNS_Small;
   currentAnimList.MyComboBox.Edit.FontScale = FNS_Small;

   //update available monsters
   for(i=0;i<class'InvasionProMonsterTable'.default.MonsterTable.Length;i++)
   {
       currentMonster.AddItem(class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterName);
   }

   //update current monster and set edit mode
   bEditMode = false;
   UpdateMonster();

}

function UpdateMonster()
{
   local int i;

   m_Name = currentMonster.GetText();

   if(m_Name ~= "None")
   {
       bValid = false;
   }
   else
   {
       bValid = true;
   }

   SetAvailableConfigs();
   currentHealth.Setup(1, 999999, 1);

   if(bValid)
   {
       for(i=0;i<class'InvasionProMonsterTable'.default.MonsterTable.Length;i++)
       {
           if( class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterName ~= m_Name )
           {
               ActiveMonster = i;
               M = class<Monster>(DynamicLoadObject(class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterClassName, class'Class',true));
               break;
           }
       }
   }

   if(M == None)
   {
       bValid = false;
   }

   ActiveBioNumber = 0;
   for(i=0;i<class'InvasionProMonsterTable'.default.MonsterDescription.Length;i++)
   {
       if( class'InvasionProMonsterTable'.default.MonsterDescription[i].MonsterName ~= m_Name )
       {
           ActiveBioNumber = i;
           break;
       }
   }

   currentbSetup.SetComponentValue(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].bSetup);
   //initialize monster if not set up
   if( !currentbSetup.IsChecked() && bValid)
   {
       currentDamageMultiplier.SetValue(1);
       currentHealth.SetComponentValue(M.default.Health);
       currentMaxHealth.SetComponentValue(M.default.HealthMax);
       currentScoreAward.SetComponentValue(M.default.ScoringValue);
       currentGroundSpeed.SetComponentValue(M.default.GroundSpeed);
       currentAirSpeed.SetComponentValue(M.default.AirSpeed);
       currentWaterSpeed.SetComponentValue(M.default.WaterSpeed);
       currentJumpZ.SetComponentValue(M.default.JumpZ);
       currentGibMultiplier.SetValue(1.00);
       currentGibSizeMultiplier.SetValue(1.00);
       currentDrawScale.SetComponentValue(M.default.DrawScale);
       currentCollisionHeight.SetComponentValue(M.default.CollisionHeight);
       currentCollisionRadius.SetComponentValue(M.default.CollisionRadius);
       currentPrePivotX.SetComponentValue(M.default.PrePivot.X);
       currentPrePivotY.SetComponentValue(M.default.PrePivot.Y);
       currentPrePivotZ.SetComponentValue(M.default.PrePivot.Z);
       currentbRandomHealth.SetComponentValue(False);
       currentbRandomSpeed.SetComponentValue(False);
       currentbRandomSize.SetComponentValue(False);
       currentbSetup.SetComponentValue(true);

       //update edit cylinder

       SaveMonster(currentMonster);
   }
   else if(bValid)
   {
       currentDamageMultiplier.SetValue(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].DamageMultiplier);
       currentHealth.SetComponentValue(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewHealth);
       currentMaxHealth.SetComponentValue(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewMaxHealth);
       currentScoreAward.SetComponentValue(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewScoreAward);
       currentGroundSpeed.SetComponentValue(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewGroundSpeed);
       currentAirSpeed.SetComponentValue(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewAirSpeed);
       currentWaterSpeed.SetComponentValue(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewWaterSpeed);
       currentJumpZ.SetComponentValue(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewJumpZ);
       currentGibMultiplier.SetValue(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewGibMultiplier);
       currentGibSizeMultiplier.SetValue(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewGibSizeMultiplier);
       currentDrawScale.SetComponentValue(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewDrawScale);
       currentCollisionHeight.SetComponentValue(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewCollisionHeight);
       currentCollisionRadius.SetComponentValue(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewCollisionRadius);
       currentPrePivotX.SetComponentValue(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewPrePivot.X);
       currentPrePivotY.SetComponentValue(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewPrePivot.Y);
       currentPrePivotZ.SetComponentValue(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewPrePivot.Z);
       currentbRandomHealth.SetComponentValue(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].bRandomHealth);
       currentbRandomSpeed.SetComponentValue(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].bRandomSpeed);
       currentbRandomSize.SetComponentValue(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].bRandomSize);
   }

   if(M  != None)
   {
       //log(M.default.bUseCylinderCollision);
       if(M.default.bUseCylinderCollision == false)
       {
           b_EditMode.DisableMe();
       }
       else
       {
           b_EditMode.EnableMe();
       }

       m_health = string(M.default.Health);
       m_score = string(M.default.ScoringValue);
       m_groundspeed = string(M.default.GroundSpeed);
       m_airspeed = string(M.default.AirSpeed);
       m_waterspeed = string(M.default.WaterSpeed);
       m_jumpZ = string(M.default.JumpZ);
       m_maxhealth = string(M.default.HealthMax);
       m_drawscale = string(M.default.DrawScale);
       m_col_h = string(M.default.CollisionHeight);
       m_col_r = string(M.default.CollisionRadius);
       m_PivotX = string(M.default.PrePivot.X);
       m_PivotY = string(M.default.PrePivot.Y);
       m_PivotZ = string(M.default.PrePivot.Z);
       m_kills = string(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NumKills);
       m_spawns = string(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NumSpawns);
       m_damage = string(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NumDamage);
       UpdateScroll();
   }

   if(bValid)
   {
       currentAnimList.EnableMe();
       b_WireMode.EnableMe();
       UpDateCylinder();
       UpdateSpinnyDude();
   }
   else
   {
       ClearAllData();
   }
}

//update everything about the cylinder
function UpDateCylinder()
{
   local float ColHeight;
   local float ColRadius;
   local vector Piv;
   local vector DScale;
   //get information

   ColHeight = currentCollisionHeight.GetValue();
   ColRadius = currentCollisionRadius.GetValue();
   Piv.X = currentPrePivotX.GetValue();
   Piv.Y = currentPrePivotY.GetValue();
   Piv.Z = currentPrePivotZ.GetValue();

   DScale.X = ( (ColRadius / 10) * 0.4 );
   DScale.Y = DScale.X;
   DScale.Z = ( (ColHeight / 10) * 0.2275 );

   MonsterCylinder.PrePivot.X = Piv.X;
   MonsterCylinder.PrePivot.Y = Piv.Y;
   MonsterCylinder.PrePivot.Z = Piv.Z;

   MonsterCylinder.SetDrawScale3D(DScale);
}

function ClearAllData()
{
   b_DropTarget.Caption = "# Offline #";
   currentAnimList.ResetComponent();

   currentHealth.Setup(0, 0, 1);
   currentHealth.SetComponentValue(0);
   currentDamageMultiplier.SetValue(0);
   currentMaxHealth.SetComponentValue(0);
   currentScoreAward.SetComponentValue(0);
   currentGroundSpeed.SetComponentValue(0);
   currentAirSpeed.SetComponentValue(0);
   currentWaterSpeed.SetComponentValue(0);
   currentJumpZ.SetComponentValue(0);
   currentGibMultiplier.SetValue(0);
   currentGibSizeMultiplier.SetValue(0);
   currentDrawScale.SetComponentValue(0);
   currentCollisionHeight.SetComponentValue(0);
   currentCollisionRadius.SetComponentValue(0);
   currentPrePivotX.SetComponentValue(0);
   currentPrePivotY.SetComponentValue(0);
   currentPrePivotZ.SetComponentValue(0);
   currentbRandomHealth.SetComponentValue(False);
   currentbRandomSpeed.SetComponentValue(False);
   currentbRandomSize.SetComponentValue(False);
   currentbSetup.SetComponentValue(True);
   currentModelFOV.SetComponentValue(0);
   currentModelRotation.SetComponentValue(0);

   currentAnimList.DisableMe();
   currentModelRotation.DisableMe();
   b_Random.DisableMe();
   b_defaults.DisableMe();
   b_EditMode.DisableMe();
   b_WireMode.DisableMe();
   b_Copy.DisableMe();
   currentHealth.DisableMe();
   currentDamageMultiplier.DisableMe();
   currentMaxHealth.DisableMe();
   currentScoreAward.DisableMe();
   currentGroundSpeed.DisableMe();
   currentAirSpeed.DisableMe();
   currentWaterSpeed.DisableMe();
   currentJumpZ.DisableMe();
   currentGibMultiplier.DisableMe();
   currentGibSizeMultiplier.DisableMe();
   currentDrawScale.DisableMe();
   currentCollisionHeight.DisableMe();
   currentCollisionRadius.DisableMe();
   currentPrePivotX.DisableMe();
   currentPrePivotY.DisableMe();
   currentPrePivotZ.DisableMe();
   currentbRandomHealth.DisableMe();
   currentbRandomSpeed.DisableMe();
   currentbRandomSize.DisableMe();
   currentbSetup.DisableMe();
   currentModelFOV.DisableMe();

   b_OK.DisableMe();
   b_EditMode.DisableMe();
   b_WireMode.DisableMe();
}

function AssembleInfo()
{
   local string BioInfoPartA, BioInfoPartB, BioInfoPartC, BioInfoPartD;
   local string m_info;

   if(!bValid)
   {
       AssembledInformation = "     # No information #  ";
       return;
   }

   BioInfoPartA = "|"@"Name: "@m_Name@"|"@"|"@"Health: "@m_health@"|"@"MaxHealth: "@m_maxhealth@"|"@"ScoreAward: "@m_score@"|"@"Groundspeed: "@m_groundspeed@"|";
   BioInfoPartB = "Airspeed: "@m_airspeed@"|"@"Waterspeed: "@m_waterspeed@"|"@"JumpZ: "@m_jumpZ@"|"@"Drawscale:"@m_drawscale@"|";
   BioInfoPartC = "CollisionHeight: "@m_col_h@"|"@"CollisionRadius: "@m_col_r@"|"@"PrePivot.X : "@m_PivotX@"|"@"              .Y : "@m_PivotY@"|"@"              .Z : "@m_PivotZ@"|";
   BioInfoPartD = "Total Spawns: "@m_spawns@"|"@"Total Damage: "@m_damage@"|"@"Total Kills: "@m_kills@"||"@"      # Tactical Data #  "@"|"@"|"@class'InvasionProMonsterTable'.default.MonsterDescription[ActiveBioNumber].BioData;

   if(M.default.bUseCylinderCollision == false)
   {
       m_info = BioInfoPartA@BioInfoPartB@BioInfoPartD;
   }
   else
   {
       m_info = BioInfoPartA@BioInfoPartB@BioInfoPartC@BioInfoPartD;
   }

   AssembledInformation = m_info;
}

function UpdateScroll()
{
   AssembleInfo();
    absoluteDefaults.SetContent(AssembledInformation);
}

function bool RandomizeMonster(GUIComponent Sender)
{
   local int i;

   i = Max(100,Rand(1000));

   currentHealth.SetComponentValue( i );
   currentMaxHealth.SetComponentValue( i );
   i = Max(3,Rand(15));
   currentScoreAward.SetComponentValue( i );
   currentDamageMultiplier.SetComponentValue(fRand() * 10);
   currentGroundSpeed.SetComponentValue(fRand() * 1000);
   currentAirSpeed.SetComponentValue(fRand() * 1000);
   currentWaterSpeed.SetComponentValue(fRand() * 1000);
   currentJumpZ.SetComponentValue(fRand() * 1000);
   currentGibMultiplier.SetComponentValue(fRand() * 10);
   currentGibSizeMultiplier.SetComponentValue(fRand() * 10);

   return true;
}

function bool InternalOnClick(GUIComponent Sender)
{
   Controller.CloseMenu(false);
   return true;
}

function UpdateSpinnyDude()
{
    local Material MonsterSkin;
    local array<string> SkinList;
    local int i;

   if(bValid)
   {
       M = class<Monster>(DynamicLoadObject(class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].MonsterClassName, class'class',true));
   }

    if(M == None)
    {
       b_DropTarget.Caption = "# Offline #";
       return;
   }

   SpinnyDudeOffset.X = currentModelFOV.GetValue();
   SpinnyDude.SetDrawScale(currentDrawScale.GetValue());
   b_DropTarget.Caption = "";

   for(i=0;i<M.default.Skins.Length;i++)
   {
       SkinList.Insert(i,1);
       SkinList[i] = string(M.default.Skins[i]);
   }

   SpinnyDude.SetDrawType(M.default.DrawType);
   SpinnyDude.SetStaticMesh(M.default.StaticMesh);
   SpinnyDude.LinkMesh(M.default.Mesh);
   SpinnyDude.Texture = M.default.Texture;
   //Metal Skaarj & SMPMerc fix & any with none applied
   for(i=0;i<SkinList.Length;i++)
   {
       if(SkinList[i] ~= "None" || SkinList[i] ~= "")
       {
           SkinList[i] = "Engine.DefaultTexture";
       }

       MonsterSkin = Material(DynamicLoadObject(SkinList[i], class'Engine.Material',true));
       if(MonsterSkin == None)
           {
           Log("Could not load body material: " @ SkinList[i] @"for" @ M @ "mesh = " @ M.default.Mesh);
           }

           SpinnyDude.Skins[i] = MonsterSkin;
   }

   if(MonsterIs2D(M))
   {
       SpinnyDude.SetDrawType(DT_StaticMesh);
       SpinnyDude.SetStaticMesh(StaticMesh'TURInvPro.SpritePreviewMesh');
       SpinnyDude.Skins[0] = SpinnyDude.Texture;
       currentAnimList.DisableMe();
       b_Play.DisableMe();
       b_Pause.DisableMe();
   }
   else
   {
       currentAnimList.EnableMe();
       b_Play.EnableMe();
       b_Pause.EnableMe();
   }

    SetUpAnimation();
}

function bool MonsterIs2D(class<Monster> MClass)
{
   local string PackageLeft, PackageRight;

   Divide(string(MClass),".",PackageLeft, PackageRight);

   if(PackageLeft ~= "BloodMonstersv1" || PackageLeft ~= "DukeNukemMonstersv1"
   || PackageLeft ~= "HereticMonstersv1" || PackageLeft ~= "HexenMonstersv2"
   || PackageLeft ~= "HexenMonstersv1" || PackageLeft ~= "ShadowWarriorMonstersv1" || PackageLeft ~= "DoomPawns2k4")
   {
       return true;
   }

   return false;
}

//=======================================================================================================
//Animation functions
//=======================================================================================================
function PlayNewAnim()
{
   if(CurrentAnim != '')
   {
       if(bAnimPaused)
       {
           if( SpinnyDude.TweenAnim( CurrentAnim, 1.0, 0 ) )
           {
               SpinnyDude.LoopAnim(CurrentAnim,1.0/SpinnyDude.Level.TimeDilation,,0 );
           }
       }

       SpinnyDude.LoopAnim(CurrentAnim,1.0/SpinnyDude.Level.TimeDilation,,0 );
       bAnimPaused = false;
   }
}

function SetUpAnimation()
{
   local int i;
   local int AnimCount;

   AnimCount = currentAnimList.ItemCount();

   currentAnimList.RemoveItem(0, AnimCount);

   //try and get any accessable anims the monster may already provide
   FindMonsterAnimations();
   //add the configured anims
   for(i=0;i<class'InvasionProAnimationManager'.default.AnimNames.Length;i++)
   {
       ValidAnim(class'InvasionProAnimationManager'.default.AnimNames[i]);
       //check if mesh has the animation in the list
   }

   currentAnimList.MyComboBox.List.Sort();
}

function FindMonsterAnimations()
{
   local int i;

   for(i=0;i<4;i++)
   {
       ValidAnim(M.default.MovementAnims[i]);
       ValidAnim(M.default.CrouchAnims[i]);
       ValidAnim(M.default.AirAnims[i]);
       ValidAnim(M.default.TakeoffAnims[i]);
       ValidAnim(M.default.LandAnims[i]);
       ValidAnim(M.default.DodgeAnims[i]);
       ValidAnim(M.default.DoubleJumpAnims[i]);
       ValidAnim(M.default.WallDodgeAnims[i]);
       ValidAnim(M.default.WalkAnims[i]);
       ValidAnim(M.default.SwimAnims[i]);
   }

   ValidAnim(M.default.TakeoffStillAnim);
   ValidAnim(M.default.AirStillAnim);
   ValidAnim(M.default.CrouchTurnRightAnim);
   ValidAnim(M.default.CrouchTurnLeftAnim);
   ValidAnim(M.default.TurnLeftAnim);
   ValidAnim(M.default.TurnLeftAnim);
   ValidAnim(M.default.TurnRightAnim);
   ValidAnim(M.default.IdleRifleAnim);
   ValidAnim(M.default.IdleHeavyAnim);
   ValidAnim(M.default.IdleWeaponAnim);
   ValidAnim(M.default.FireHeavyBurstAnim);
   ValidAnim(M.default.FireHeavyRapidAnim);
   ValidAnim(M.default.FireRifleBurstAnim);
   ValidAnim(M.default.FireRifleRapidAnim);
   ValidAnim(M.default.IdleChatAnim);
   ValidAnim(M.default.IdleSwimAnim);
}

function ValidAnim(name vAnim)
{
   if(vAnim != '' && SpinnyDude.HasAnim(vAnim) && currentAnimList.Find(string(vAnim),false,false) == "" )
   {
       currentAnimList.AddItem( String(vAnim) );
   }
}

function bool AnimControls(GUIComponent Sender)
{
   local float AnimRate, AnimFrame;


   if(Sender == b_Play)
   {
       PlayNewAnim();
   }

   if(Sender == b_Pause)
   {
       if(CurrentAnim != '')
       {
           if(bAnimPaused)
           {
               return true;
           }

           SpinnyDude.GetAnimParams ( 0, CurrentAnim, AnimFrame, AnimRate );
           SpinnyDude.TweenAnim( CurrentAnim, 0, 0 );
           SpinnyDude.SetAnimFrame(AnimFrame, 0, 0);
           bAnimPaused = true;
       }
   }

   return true;
}

//=======================================================================================================
//GUI events
//=======================================================================================================

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
   MonsterCylinder.SetLocation(SpinnyDude.Location);
   canvas.DrawActorClipped(SpinnyDude, bSpinnyWireMode,  b_DropTarget.ActualLeft(), b_DropTarget.ActualTop(), b_DropTarget.ActualWidth(), b_DropTarget.ActualHeight(), true, nFov);
   canvas.DrawActorClipped(MonsterCylinder, false,  b_DropTarget.ActualLeft(), b_DropTarget.ActualTop(), b_DropTarget.ActualWidth(), b_DropTarget.ActualHeight(), false, nFov);

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
        SpinnyDude.bHidden = true;
   }

   if ( MonsterCylinder != None )
   {
       MonsterCylinder.bHidden = true;
   }
   //release materials back into the pool with ensured defaults
   if(CylinderTexture != None)
   {
       CylinderTexture.FrameBufferBlending = FB_Overwrite;
       CylinderTexture.ZWrite = True;
       CylinderTexture.ZTest = True;
       CylinderTexture.AlphaTest = False;
       CylinderTexture.TwoSided = False;
       CylinderTexture.AlphaRef = 0;
       CylinderTexture.Material = None;
       CylinderTexture.FallbackMaterial = None;
       CylinderTexture.SurfaceType = EST_Default;

       PlayerOwner().Level.ObjectPool.FreeObject(CylinderTexture);

       CylinderTexture = None;
   }

   if(CylinderShader != None)
   {
       CylinderShader.Diffuse = None;
       CylinderShader.Opacity = None;
       CylinderShader.Specular = None;
       CylinderShader.SpecularityMask = None;
       CylinderShader.SelfIllumination = None;
       CylinderShader.SelfIlluminationMask = None;
       CylinderShader.Detail = None;
       CylinderShader.DetailScale = 8.000000;
       CylinderShader.OutputBlending = OB_Normal;
       CylinderShader.TwoSided = false;
       CylinderShader.WireFrame = false;
       CylinderShader.PerformLightingOnSpecularPass = False;
       CylinderShader.ModulateSpecular2X = False;
       CylinderShader.FallbackMaterial = None;
       CylinderShader.SurfaceType = EST_Default;

       PlayerOwner().Level.ObjectPool.FreeObject(CylinderShader);

       CylinderShader = None;
   }
}

function bool RaceCapturedMouseMove(float deltaX, float deltaY)
{
    local rotator r;

   //SpinnyMonster.DrawDebugLine ( SpinnyMonster, vector LineEnd, byte R, byte G, byte B )
    r = SpinnyDude.Rotation;
    r.Yaw -= (256 * DeltaX);
    r.Pitch += (256 * DeltaY);
    SpinnyDude.SetRotation(r);
    //MonsterCylinder.SetRotation(SpinnyDude.Rotation);
    return true;
}

function InternalOnChange(GUIComponent Sender)
{
   if(Sender == currentModelFOV)
   {
       //nFov = currentModelFOV.GetValue();
       SpinnyDudeOffset.X = currentModelFOV.GetValue();
   }

   if(Sender == currentMonster)
   {
       UpdateMonster();
   }

   if(Sender == currentModelRotation)
   {
       SpinnyDude.RotateSpeed = currentModelRotation.GetValue();
   }

   if( Sender == currentCollisionHeight || Sender == currentCollisionRadius || Sender == currentPrePivotX || Sender == currentPrePivotY || Sender == currentPrePivotZ)
   {
       UpDateCylinder();
   }

   if( Sender == currentDrawScale)
   {
       SpinnyDude.SetDrawScale(currentDrawScale.GetValue());
   }

   if(Sender == currentAnimList)
   {
       CurrentAnim = StringToName( currentAnimList.GetText() );
       PlayNewAnim();
   }
}

function name StringToName(string str)
{
  SetPropertyText("NameConversion", str);
 // log("name conversion" @ NameConversion);
  return NameConversion;
}

function bool ToggleEditMode(GUIComponent Sender)
{
   if(Sender == b_EditMode)
   {
       bEditMode = !bEditMode;
       SetAvailableConfigs();
   }

   if(Sender == b_WireMode)
   {
       bSpinnyWireMode = !bSpinnyWireMode;
   }

   return true;
}

function SetAvailableConfigs()
{
   currentHealth.EnableMe();
   currentDamageMultiplier.EnableMe();
   currentMaxHealth.EnableMe();
   currentScoreAward.EnableMe();
   currentGroundSpeed.EnableMe();
   currentAirSpeed.EnableMe();
   currentWaterSpeed.EnableMe();
   currentJumpZ.EnableMe();
   currentGibMultiplier.EnableMe();
   currentGibSizeMultiplier.EnableMe();
   currentbRandomHealth.EnableMe();
   currentbRandomSpeed.EnableMe();
   currentbRandomSize.EnableMe();
   currentbSetup.EnableMe();
   currentModelFOV.EnableMe();
   currentModelRotation.EnableMe();
   b_Random.EnableMe();
   b_defaults.EnableMe();
   b_EditMode.EnableMe();
   b_WireMode.EnableMe();
   b_Copy.EnableMe();
   b_OK.EnableMe();

   currentModelFOV.SetValue(90);

   if(!bEditMode)
   {
       currentDrawScale.DisableMe();
       currentCollisionHeight.DisableMe();
       currentCollisionRadius.DisableMe();
       currentMonster.EnableMe();
       currentPrePivotX.DisableMe();
       currentPrePivotY.DisableMe();
       currentPrePivotZ.DisableMe();
       MonsterCylinder.SetDrawType(DT_None);

       return;
   }

   currentDrawScale.EnableMe();
   currentCollisionHeight.EnableMe();
   currentCollisionRadius.EnableMe();
   currentMonster.DisableMe();
   currentPrePivotX.EnableMe();
   currentPrePivotY.EnableMe();
   currentPrePivotZ.EnableMe();
   MonsterCylinder.SetDrawType(DT_StaticMesh);
}

function bool SetDefaultMonster(GUIComponent Sender)
{
   currentDamageMultiplier.SetValue(1);
   currentHealth.SetComponentValue(M.default.Health);
   currentMaxHealth.SetComponentValue(M.default.HealthMax);
   currentScoreAward.SetComponentValue(M.default.ScoringValue);
   currentGroundSpeed.SetComponentValue(M.default.GroundSpeed);
   currentAirSpeed.SetComponentValue(M.default.AirSpeed);
   currentWaterSpeed.SetComponentValue(M.default.WaterSpeed);
   currentJumpZ.SetComponentValue(M.default.JumpZ);
   currentGibMultiplier.SetValue(1.00);
   currentGibSizeMultiplier.SetValue(1.00);
   currentDrawScale.SetComponentValue(M.default.DrawScale);
   currentCollisionHeight.SetComponentValue(M.default.CollisionHeight);
   currentCollisionRadius.SetComponentValue(M.default.CollisionRadius);
   currentPrePivotX.SetComponentValue(M.default.PrePivot.X);
   currentPrePivotY.SetComponentValue(M.default.PrePivot.Y);
   currentPrePivotZ.SetComponentValue(M.default.PrePivot.Z);
   currentbRandomHealth.SetComponentValue(False);
   currentbRandomSpeed.SetComponentValue(False);
   currentbRandomSize.SetComponentValue(False);

   return true;
}

function bool SaveMonster(GUIComponent Sender)
{
   class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewHealth = currentHealth.GetValue();
   class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewMaxHealth = currentMaxHealth.GetValue();
   class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewGroundSpeed = currentGroundSpeed.GetValue();
   class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewAirSpeed = currentAirSpeed.GetValue();
   class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewWaterSpeed = currentWaterSpeed.GetValue();
   class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewJumpZ = currentJumpZ.GetValue();
   class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewScoreAward = currentScoreAward.GetValue();
   class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewGibMultiplier = currentGibMultiplier.GetValue();
   class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewGibSizeMultiplier = currentGibSizeMultiplier.GetValue();
   class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].DamageMultiplier = currentDamageMultiplier.GetValue();
   class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].bRandomHealth = currentbRandomHealth.IsChecked();
   class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].bRandomSpeed = currentbRandomSpeed.IsChecked();
   class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].bRandomSize = currentbRandomSize.IsChecked();

   if(bEditMode || !class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].bSetup)
   {
       class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewDrawScale = currentDrawScale.GetValue();
       class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewCollisionHeight = currentCollisionHeight.GetValue();
       class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewCollisionRadius = currentCollisionRadius.GetValue();
       class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewPrePivot.X = currentPrePivotX.GetValue();
       class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewPrePivot.Y = currentPrePivotY.GetValue();
       class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].NewPrePivot.Z = currentPrePivotZ.GetValue();
   }

   class'InvasionProMonsterTable'.default.MonsterTable[ActiveMonster].bSetup = true;

   class'InvasionProMonsterTable'.static.StaticSaveConfig();

   return true;
}

function bool ExitMonster(GUIComponent Sender)
{
   Controller.CloseMenu(false);

   return true;
}
//SpinnyDudeOffset=(X=70,Y=0,Z=0)
function bool PanView(GUIComponent Sender)
{
   local Rotator R;

   if(Sender == b_UArrow)
   {
       SpinnyDudeOffset.Z = (SpinnyDudeOffset.Z + 5);
   }

   if(Sender == b_DArrow)
   {
       SpinnyDudeOffset.Z = (SpinnyDudeOffset.Z - 5);
   }

   if(Sender == b_LArrow)
   {
       SpinnyDudeOffset.Y = (SpinnyDudeOffset.Y - 5);
   }

   if(Sender == b_RArrow)
   {
       SpinnyDudeOffset.Y = (SpinnyDudeOffset.Y + 5);
   }

   if(Sender == b_CArrow)
   {
       //reset pivot and rotations
       SpinnyDudeOffset.X = 70;
       SpinnyDudeOffset.Y = 0;
       SpinnyDudeOffset.Z = 0;
       R.Yaw = 32768;
       R.Pitch = -1024;
       SpinnyDude.SetRotation(R+PlayerOwner().Rotation);
       currentModelFOV.SetValue(65);
       //MonsterCylinder.SetRotation(SpinnyDude.Rotation);
   }

   return true;
}

function bool CopySize(GUIComponent Sender)
{
   class'InvasionProCopyPaste'.default.ClipBoardDrawScale = currentDrawScale.GetValue();
   class'InvasionProCopyPaste'.default.ClipBoardCollisionHeight = currentCollisionHeight.GetValue();
   class'InvasionProCopyPaste'.default.ClipBoardCollisionRadius = currentCollisionRadius.GetValue();
   class'InvasionProCopyPaste'.default.ClipBoardPrePivot.X = currentPrePivotX.GetValue();
   class'InvasionProCopyPaste'.default.ClipBoardPrePivot.Y = currentPrePivotY.GetValue();
   class'InvasionProCopyPaste'.default.ClipBoardPrePivot.Z = currentPrePivotZ.GetValue();

   class'InvasionProCopyPaste'.static.StaticSaveConfig();

   return true;
}

defaultproperties
{
     SpinnyDudeOffset=(X=70.000000)
     Begin Object Class=GUIButton Name=DropTarget
         bAutoShrink=False
         StyleName="NoBackground"
         WinTop=0.151119
         WinLeft=0.663153
         WinWidth=0.283570
         WinHeight=0.521870
         MouseCursorIndex=5
         bTabStop=False
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
         bDropTarget=True
         OnKeyEvent=DropTarget.InternalOnKeyEvent
         OnCapturedMouseMove=InvasionProMonsterConfig.RaceCapturedMouseMove
     End Object
     b_DropTarget=GUIButton'TURInvPro.InvasionProMonsterConfig.DropTarget'

     Begin Object Class=moSlider Name=ModelFOV
         MaxValue=1000.000000
         SliderCaptionStyleName="TextLabel"
         CaptionWidth=0.200000
         Caption="Zoom"
         OnCreateComponent=ModelFOV.InternalOnCreateComponent
         Hint="Zoom the monster in or out."
         WinTop=0.090465
         WinLeft=0.664232
         WinWidth=0.283725
         WinHeight=0.033333
         TabOrder=18
         bBoundToParent=True
         bScaleToParent=True
         OnChange=InvasionProMonsterConfig.InternalOnChange
     End Object
     currentModelFOV=moSlider'TURInvPro.InvasionProMonsterConfig.ModelFOV'

     Begin Object Class=GUILabel Name=ModelDrawer
         StyleName="TextLabel"
         WinTop=0.211205
         WinLeft=0.692450
         WinWidth=0.241218
         WinHeight=0.557467
         RenderWeight=0.200000
         OnDraw=InvasionProMonsterConfig.InternalDraw
     End Object
     currentModelViewer=GUILabel'TURInvPro.InvasionProMonsterConfig.ModelDrawer'

     Begin Object Class=GUIScrollTextBox Name=AMonsterDefaults
         CharDelay=0.002500
         EOLDelay=0.350000
         bVisibleWhenEmpty=True
         OnCreateComponent=AMonsterDefaults.InternalOnCreateComponent
         FontScale=FNS_Small
         WinTop=0.099197
         WinLeft=0.410429
         WinWidth=0.234578
         WinHeight=0.543850
         bScaleToParent=True
     End Object
     absoluteDefaults=GUIScrollTextBox'TURInvPro.InvasionProMonsterConfig.AMonsterDefaults'

     Begin Object Class=GUILabel Name=PivotLabel
         Caption="PrePivot"
         StyleName="TextLabel"
         WinTop=0.429753
         WinLeft=0.049493
         WinWidth=0.865933
         WinHeight=0.076911
         RenderWeight=0.200000
     End Object
     monsterPrePivotLabel=GUILabel'TURInvPro.InvasionProMonsterConfig.PivotLabel'

     Begin Object Class=GUISectionBackground Name=mBio
         bFillClient=True
         Caption="Biography"
         LeftPadding=0.020000
         RightPadding=0.020000
         TopPadding=0.020000
         BottomPadding=0.020000
         WinTop=0.098412
         WinLeft=0.399245
         WinWidth=0.254380
         WinHeight=0.481403
         OnPreDraw=mBio.InternalPreDraw
     End Object
     monsterBio=GUISectionBackground'TURInvPro.InvasionProMonsterConfig.mBio'

     Begin Object Class=moNumericEdit Name=cHealth
         MinValue=1
         MaxValue=999999
         CaptionWidth=0.400000
         ComponentWidth=0.350000
         Caption="Health: "
         OnCreateComponent=cHealth.InternalOnCreateComponent
         Hint="How much health this monster starts with."
         WinTop=0.167536
         WinLeft=0.047634
         WinWidth=0.338797
         WinHeight=0.033333
         RenderWeight=0.700000
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
     End Object
     currentHealth=moNumericEdit'TURInvPro.InvasionProMonsterConfig.cHealth'

     Begin Object Class=moNumericEdit Name=cMaxHealth
         MinValue=0
         MaxValue=999999
         CaptionWidth=0.400000
         ComponentWidth=0.350000
         Caption="Regen Health Max: "
         OnCreateComponent=cMaxHealth.InternalOnCreateComponent
         Hint="The limit of the monster regeneration for this monster, if active."
         WinTop=0.219076
         WinLeft=0.047634
         WinWidth=0.338797
         WinHeight=0.033333
         RenderWeight=0.700000
         TabOrder=2
         bBoundToParent=True
         bScaleToParent=True
     End Object
     currentMaxHealth=moNumericEdit'TURInvPro.InvasionProMonsterConfig.cMaxHealth'

     Begin Object Class=moNumericEdit Name=cScoreAward
         MinValue=0
         MaxValue=999999
         CaptionWidth=0.400000
         ComponentWidth=0.350000
         Caption="Score Award: "
         OnCreateComponent=cScoreAward.InternalOnCreateComponent
         Hint="How many points are gained for killing this monster."
         WinTop=0.266548
         WinLeft=0.047634
         WinWidth=0.338797
         WinHeight=0.033333
         RenderWeight=0.700000
         TabOrder=3
         bBoundToParent=True
         bScaleToParent=True
     End Object
     currentScoreAward=moNumericEdit'TURInvPro.InvasionProMonsterConfig.cScoreAward'

     Begin Object Class=moSlider Name=cGroundSpeed
         MaxValue=2000.000000
         SliderCaptionStyleName="TextLabel"
         CaptionWidth=0.200000
         ComponentWidth=0.700000
         Caption="Ground Speed: "
         OnCreateComponent=cGroundSpeed.InternalOnCreateComponent
         Hint="How fast this monster moves on the ground."
         WinTop=0.752704
         WinLeft=0.042776
         WinWidth=0.609379
         WinHeight=0.033333
         TabOrder=14
         bBoundToParent=True
         bScaleToParent=True
     End Object
     currentGroundSpeed=moSlider'TURInvPro.InvasionProMonsterConfig.cGroundSpeed'

     Begin Object Class=moSlider Name=cAirSpeed
         MaxValue=2000.000000
         SliderCaptionStyleName="TextLabel"
         CaptionWidth=0.200000
         ComponentWidth=0.700000
         Caption="Air Speed: "
         OnCreateComponent=cAirSpeed.InternalOnCreateComponent
         Hint="How fast this monster moves through the air."
         WinTop=0.787969
         WinLeft=0.042776
         WinWidth=0.609379
         WinHeight=0.033333
         TabOrder=15
         bBoundToParent=True
         bScaleToParent=True
     End Object
     currentAirSpeed=moSlider'TURInvPro.InvasionProMonsterConfig.cAirSpeed'

     Begin Object Class=moSlider Name=cWaterSpeed
         MaxValue=2000.000000
         SliderCaptionStyleName="TextLabel"
         CaptionWidth=0.200000
         ComponentWidth=0.700000
         Caption="Water Speed: "
         OnCreateComponent=cWaterSpeed.InternalOnCreateComponent
         Hint="How fast this monster moves through water."
         WinTop=0.820522
         WinLeft=0.041800
         WinWidth=0.609379
         WinHeight=0.033333
         TabOrder=16
         bBoundToParent=True
         bScaleToParent=True
     End Object
     currentWaterSpeed=moSlider'TURInvPro.InvasionProMonsterConfig.cWaterSpeed'

     Begin Object Class=moSlider Name=cJumpZ
         MaxValue=2000.000000
         SliderCaptionStyleName="TextLabel"
         CaptionWidth=0.200000
         ComponentWidth=0.700000
         Caption="JumpZ: "
         OnCreateComponent=cJumpZ.InternalOnCreateComponent
         Hint="How high this monster can jump."
         WinTop=0.854431
         WinLeft=0.041800
         WinWidth=0.609379
         WinHeight=0.033333
         TabOrder=17
         bBoundToParent=True
         bScaleToParent=True
     End Object
     currentJumpZ=moSlider'TURInvPro.InvasionProMonsterConfig.cJumpZ'

     Begin Object Class=moSlider Name=cGibMultiplier
         MaxValue=10.000000
         SliderCaptionStyleName="TextLabel"
         CaptionWidth=0.200000
         ComponentWidth=0.700000
         Caption="Gib Multiplier: "
         OnCreateComponent=cGibMultiplier.InternalOnCreateComponent
         Hint="This value multiplies the gib amounts."
         WinTop=0.682174
         WinLeft=0.041800
         WinWidth=0.609379
         WinHeight=0.033333
         TabOrder=12
         bBoundToParent=True
         bScaleToParent=True
     End Object
     currentGibMultiplier=moSlider'TURInvPro.InvasionProMonsterConfig.cGibMultiplier'

     Begin Object Class=moSlider Name=cGibSizeMultiplier
         MaxValue=10.000000
         SliderCaptionStyleName="TextLabel"
         CaptionWidth=0.200000
         ComponentWidth=0.700000
         Caption="GibSize Multiplier:"
         OnCreateComponent=cGibSizeMultiplier.InternalOnCreateComponent
         Hint="If the monster is gibbed, how big should the gibs be."
         WinTop=0.718796
         WinLeft=0.041800
         WinWidth=0.609379
         WinHeight=0.033333
         TabOrder=13
         bBoundToParent=True
         bScaleToParent=True
     End Object
     currentGibSizeMultiplier=moSlider'TURInvPro.InvasionProMonsterConfig.cGibSizeMultiplier'

     Begin Object Class=moSlider Name=cDamMultiplier
         MaxValue=10.000000
         SliderCaptionStyleName="TextLabel"
         CaptionWidth=0.200000
         ComponentWidth=0.700000
         Caption="Damage Scale: "
         OnCreateComponent=cDamMultiplier.InternalOnCreateComponent
         Hint="This value multiplies the damage output of this monster."
         WinTop=0.646909
         WinLeft=0.041800
         WinWidth=0.609379
         WinHeight=0.033333
         TabOrder=11
         bBoundToParent=True
         bScaleToParent=True
     End Object
     currentDamageMultiplier=moSlider'TURInvPro.InvasionProMonsterConfig.cDamMultiplier'

     Begin Object Class=moSlider Name=ModelRot
         MaxValue=100.000000
         SliderCaptionStyleName="TextLabel"
         CaptionWidth=0.200000
         Caption="Rotate Speed"
         OnCreateComponent=ModelRot.InternalOnCreateComponent
         Hint="Adjust the rotation speed."
         WinTop=0.120304
         WinLeft=0.664232
         WinWidth=0.283725
         WinHeight=0.033333
         TabOrder=19
         bBoundToParent=True
         bScaleToParent=True
         OnChange=InvasionProMonsterConfig.InternalOnChange
     End Object
     currentModelRotation=moSlider'TURInvPro.InvasionProMonsterConfig.ModelRot'

     Begin Object Class=moFloatEdit Name=cDrawScale
         MinValue=0.000001
         MaxValue=10.000000
         Step=0.050000
         CaptionWidth=0.400000
         ComponentWidth=0.350000
         Caption="Draw Scale: "
         OnCreateComponent=cDrawScale.InternalOnCreateComponent
         Hint="The draw scale of the monster."
         WinTop=0.311087
         WinLeft=0.047634
         WinWidth=0.338797
         WinHeight=0.033333
         TabOrder=4
         OnChange=InvasionProMonsterConfig.InternalOnChange
     End Object
     currentDrawScale=moFloatEdit'TURInvPro.InvasionProMonsterConfig.cDrawScale'

     Begin Object Class=moFloatEdit Name=cCollisionHeight
         MinValue=0.000000
         MaxValue=2000.000000
         Step=0.050000
         CaptionWidth=0.400000
         ComponentWidth=0.350000
         Caption="Collision Height: "
         OnCreateComponent=cCollisionHeight.InternalOnCreateComponent
         Hint="The collision height of the monster."
         WinTop=0.357474
         WinLeft=0.047634
         WinWidth=0.338797
         WinHeight=0.033333
         TabOrder=5
         OnChange=InvasionProMonsterConfig.InternalOnChange
     End Object
     currentCollisionHeight=moFloatEdit'TURInvPro.InvasionProMonsterConfig.cCollisionHeight'

     Begin Object Class=moFloatEdit Name=cCollisionRadius
         MinValue=0.000000
         MaxValue=2000.000000
         Step=0.050000
         CaptionWidth=0.400000
         ComponentWidth=0.350000
         Caption="Collision Radius: "
         OnCreateComponent=cCollisionRadius.InternalOnCreateComponent
         Hint="The collision radius of the monster."
         WinTop=0.405081
         WinLeft=0.047634
         WinWidth=0.338797
         WinHeight=0.033333
         TabOrder=6
         OnChange=InvasionProMonsterConfig.InternalOnChange
     End Object
     currentCollisionRadius=moFloatEdit'TURInvPro.InvasionProMonsterConfig.cCollisionRadius'

     Begin Object Class=moFloatEdit Name=cPrePivotX
         MinValue=-1000.000000
         MaxValue=1000.000000
         Step=0.050000
         CaptionWidth=0.400000
         ComponentWidth=0.470000
         Caption=".X "
         OnCreateComponent=cPrePivotX.InternalOnCreateComponent
         Hint="The Prepivot.X value of the monster."
         WinTop=0.455537
         WinLeft=0.134548
         WinWidth=0.252080
         WinHeight=0.033333
         TabOrder=7
         OnChange=InvasionProMonsterConfig.InternalOnChange
     End Object
     currentPrePivotX=moFloatEdit'TURInvPro.InvasionProMonsterConfig.cPrePivotX'

     Begin Object Class=moFloatEdit Name=cPrePivotY
         MinValue=-1000.000000
         MaxValue=1000.000000
         Step=0.050000
         CaptionWidth=0.400000
         ComponentWidth=0.470000
         Caption=".Y "
         OnCreateComponent=cPrePivotY.InternalOnCreateComponent
         Hint="The Prepivot.Y value of the monster."
         WinTop=0.500839
         WinLeft=0.134548
         WinWidth=0.252080
         WinHeight=0.033333
         TabOrder=8
         OnChange=InvasionProMonsterConfig.InternalOnChange
     End Object
     currentPrePivotY=moFloatEdit'TURInvPro.InvasionProMonsterConfig.cPrePivotY'

     Begin Object Class=moFloatEdit Name=cPrePivotZ
         MinValue=-1000.000000
         MaxValue=1000.000000
         Step=0.050000
         CaptionWidth=0.400000
         ComponentWidth=0.470000
         Caption=".Z "
         OnCreateComponent=cPrePivotZ.InternalOnCreateComponent
         Hint="The Prepivot.Z value of the monster."
         WinTop=0.544784
         WinLeft=0.134548
         WinWidth=0.252080
         WinHeight=0.033333
         TabOrder=9
         OnChange=InvasionProMonsterConfig.InternalOnChange
     End Object
     currentPrePivotZ=moFloatEdit'TURInvPro.InvasionProMonsterConfig.cPrePivotZ'

     Begin Object Class=moCheckBox Name=c_bRandomHealth
         CaptionWidth=0.200000
         Caption="Random Health: "
         OnCreateComponent=c_bRandomHealth.InternalOnCreateComponent
         Hint="Randomize this monsters health when it spawns? Regen Health Max will scale with the new health."
         WinTop=0.682174
         WinLeft=0.677023
         WinWidth=0.267203
         WinHeight=0.033333
         TabOrder=29
         bBoundToParent=True
     End Object
     currentbRandomHealth=moCheckBox'TURInvPro.InvasionProMonsterConfig.c_bRandomHealth'

     Begin Object Class=moCheckBox Name=c_bRandomSpeed
         CaptionWidth=0.200000
         Caption="Random Speed: "
         OnCreateComponent=c_bRandomSpeed.InternalOnCreateComponent
         Hint="Randomize the monsters speed when it spawns?"
         WinTop=0.768309
         WinLeft=0.677414
         WinWidth=0.267203
         WinHeight=0.033333
         TabOrder=31
         bBoundToParent=True
     End Object
     currentbRandomSpeed=moCheckBox'TURInvPro.InvasionProMonsterConfig.c_bRandomSpeed'

     Begin Object Class=moCheckBox Name=c_bRandomSize
         CaptionWidth=0.200000
         Caption="Random Size: "
         OnCreateComponent=c_bRandomSize.InternalOnCreateComponent
         Hint="Randomize the monsters size when it spawns?"
         WinTop=0.725583
         WinLeft=0.676438
         WinWidth=0.267984
         WinHeight=0.033333
         TabOrder=30
         bBoundToParent=True
     End Object
     currentbRandomSize=moCheckBox'TURInvPro.InvasionProMonsterConfig.c_bRandomSize'

     Begin Object Class=moCheckBox Name=c_bSetup
         bValueReadOnly=True
         CaptionWidth=0.200000
         Caption="Initialized: "
         OnCreateComponent=c_bSetup.InternalOnCreateComponent
         Hint="The monster is ready to join the invasion."
         WinTop=0.810432
         WinLeft=0.677023
         WinWidth=0.267203
         WinHeight=0.033333
         TabOrder=32
         bBoundToParent=True
     End Object
     currentbSetup=moCheckBox'TURInvPro.InvasionProMonsterConfig.c_bSetup'

     Begin Object Class=GUIButton Name=RandomButton
         Caption="Random"
         Hint="Randomize monster."
         WinTop=0.895495
         WinLeft=0.430957
         WinWidth=0.168153
         WinHeight=0.042743
         TabOrder=35
         bBoundToParent=True
         bScaleToParent=True
         OnClick=InvasionProMonsterConfig.RandomizeMonster
         OnKeyEvent=RandomButton.InternalOnKeyEvent
     End Object
     b_Random=GUIButton'TURInvPro.InvasionProMonsterConfig.RandomButton'

     Begin Object Class=GUIButton Name=DefaultButton
         Caption="Default"
         Hint="Set the defaults for the current monster."
         WinTop=0.895495
         WinLeft=0.608580
         WinWidth=0.169715
         WinHeight=0.044493
         TabOrder=36
         bBoundToParent=True
         bScaleToParent=True
         OnClick=InvasionProMonsterConfig.SetDefaultMonster
         OnKeyEvent=DefaultButton.InternalOnKeyEvent
     End Object
     b_Defaults=GUIButton'TURInvPro.InvasionProMonsterConfig.DefaultButton'

     Begin Object Class=GUIButton Name=EditButton
         Caption="Edit Mode"
         Hint="Activate edit mode to change size values."
         WinTop=0.895495
         WinLeft=0.254199
         WinWidth=0.168153
         WinHeight=0.040399
         TabOrder=34
         bBoundToParent=True
         bScaleToParent=True
         OnClick=InvasionProMonsterConfig.ToggleEditMode
         OnKeyEvent=EditButton.InternalOnKeyEvent
     End Object
     b_EditMode=GUIButton'TURInvPro.InvasionProMonsterConfig.EditButton'

     Begin Object Class=GUIButton Name=WireButton
         Caption="Wire Frame"
         FontScale=FNS_Small
         Hint="View the model in wire frame mode."
         WinTop=0.590327
         WinLeft=0.665484
         WinWidth=0.120059
         WinHeight=0.036493
         TabOrder=26
         bBoundToParent=True
         bScaleToParent=True
         OnClick=InvasionProMonsterConfig.ToggleEditMode
         OnKeyEvent=WireButton.InternalOnKeyEvent
     End Object
     b_WireMode=GUIButton'TURInvPro.InvasionProMonsterConfig.WireButton'

     Begin Object Class=GUIButton Name=CopyButton
         Caption="Copy"
         Hint="Copy the size properties of this monster to the monster clipboard."
         WinTop=0.593192
         WinLeft=0.042346
         WinWidth=0.135340
         WinHeight=0.035712
         TabOrder=10
         bBoundToParent=True
         bScaleToParent=True
         OnClick=InvasionProMonsterConfig.CopySize
         OnKeyEvent=CopyButton.InternalOnKeyEvent
     End Object
     b_Copy=GUIButton'TURInvPro.InvasionProMonsterConfig.CopyButton'

     Begin Object Class=moComboBox Name=cMonster
         bReadOnly=True
         ComponentJustification=TXTA_Left
         CaptionWidth=0.100000
         Caption="Species: "
         OnCreateComponent=cMonster.InternalOnCreateComponent
         Hint="Choose a monster to configure."
         WinTop=0.100243
         WinLeft=0.047217
         WinWidth=0.339162
         WinHeight=0.044444
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         StandardHeight=0.040000
         OnChange=InvasionProMonsterConfig.InternalOnChange
     End Object
     currentMonster=moComboBox'TURInvPro.InvasionProMonsterConfig.cMonster'

     Begin Object Class=moComboBox Name=c_animlist
         bReadOnly=True
         bVerticalLayout=True
         ComponentJustification=TXTA_Left
         CaptionWidth=0.300000
         ComponentWidth=0.250000
         Caption="Available Animations: "
         OnCreateComponent=c_animlist.InternalOnCreateComponent
         FontScale=FNS_Small
         Hint="choose an animation to play"
         WinTop=0.161930
         WinLeft=0.662671
         WinWidth=0.161036
         WinHeight=0.088889
         TabOrder=20
         bBoundToParent=True
         bScaleToParent=True
         StandardHeight=0.040000
         OnChange=InvasionProMonsterConfig.InternalOnChange
     End Object
     currentAnimList=moComboBox'TURInvPro.InvasionProMonsterConfig.c_animlist'

     Begin Object Class=GUIGFXButton Name=PanUp
         ImageIndex=7
         Graphic=Texture'TURInvPro.GUI.arrowUp_p'
         Position=ICP_Scaled
         StyleName="BindBox"
         Hint="Pan up."
         WinTop=0.153557
         WinLeft=0.908128
         WinWidth=0.018790
         WinHeight=0.015365
         RenderWeight=0.510000
         TabOrder=22
         bNeverFocus=True
         bRepeatClick=True
         OnClickSound=CS_Down
         OnClick=InvasionProMonsterConfig.PanView
         OnKeyEvent=PanUp.InternalOnKeyEvent
     End Object
     b_UArrow=GUIGFXButton'TURInvPro.InvasionProMonsterConfig.PanUp'

     Begin Object Class=GUIGFXButton Name=PanDown
         ImageIndex=7
         Graphic=Texture'TURInvPro.GUI.arrowDown_p'
         Position=ICP_Scaled
         StyleName="BindBox"
         Hint="Pan down."
         WinTop=0.199401
         WinLeft=0.908128
         WinWidth=0.018790
         WinHeight=0.015278
         RenderWeight=0.510000
         TabOrder=24
         bNeverFocus=True
         bRepeatClick=True
         OnClickSound=CS_Down
         OnClick=InvasionProMonsterConfig.PanView
         OnKeyEvent=PanDown.InternalOnKeyEvent
     End Object
     b_DArrow=GUIGFXButton'TURInvPro.InvasionProMonsterConfig.PanDown'

     Begin Object Class=GUIGFXButton Name=PanLeft
         ImageIndex=7
         Graphic=Texture'TURInvPro.arrowLeft_p'
         Position=ICP_Scaled
         StyleName="BindBox"
         Hint="Pan left."
         WinTop=0.172274
         WinLeft=0.892503
         WinWidth=0.014102
         WinHeight=0.023785
         RenderWeight=0.510000
         TabOrder=21
         bNeverFocus=True
         bRepeatClick=True
         OnClickSound=CS_Down
         OnClick=InvasionProMonsterConfig.PanView
         OnKeyEvent=PanLeft.InternalOnKeyEvent
     End Object
     b_LArrow=GUIGFXButton'TURInvPro.InvasionProMonsterConfig.PanLeft'

     Begin Object Class=GUIGFXButton Name=PanRight
         ImageIndex=7
         Graphic=Texture'TURInvPro.arrowRight_p'
         Position=ICP_Scaled
         StyleName="BindBox"
         Hint="Pan right."
         WinTop=0.171053
         WinLeft=0.928636
         WinWidth=0.014102
         WinHeight=0.023785
         RenderWeight=0.510000
         TabOrder=23
         bNeverFocus=True
         bRepeatClick=True
         OnClickSound=CS_Down
         OnClick=InvasionProMonsterConfig.PanView
         OnKeyEvent=PanRight.InternalOnKeyEvent
     End Object
     b_RArrow=GUIGFXButton'TURInvPro.InvasionProMonsterConfig.PanRight'

     Begin Object Class=GUIGFXButton Name=PanReset
         ImageIndex=7
         Graphic=Texture'TURInvPro.arrowHome_p'
         Position=ICP_Scaled
         StyleName="BindBox"
         Hint="Reset the view."
         WinTop=0.172139
         WinLeft=0.908128
         WinWidth=0.018790
         WinHeight=0.023785
         RenderWeight=0.510000
         TabOrder=25
         bNeverFocus=True
         bRepeatClick=True
         OnClickSound=CS_Down
         OnClick=InvasionProMonsterConfig.PanView
         OnKeyEvent=PanReset.InternalOnKeyEvent
     End Object
     b_CArrow=GUIGFXButton'TURInvPro.InvasionProMonsterConfig.PanReset'

     Begin Object Class=GUIGFXButton Name=Play
         ImageIndex=7
         Graphic=Texture'2K4Menus.MP3.Play'
         Position=ICP_Scaled
         StyleName="CharButton"
         Hint="Play Animation."
         WinTop=0.591652
         WinLeft=0.816602
         WinWidth=0.021290
         WinHeight=0.030958
         RenderWeight=0.510000
         TabOrder=28
         bNeverFocus=True
         bRepeatClick=True
         OnClickSound=CS_Down
         OnClick=InvasionProMonsterConfig.AnimControls
         OnKeyEvent=Play.InternalOnKeyEvent
     End Object
     b_Play=GUIGFXButton'TURInvPro.InvasionProMonsterConfig.Play'

     Begin Object Class=GUIGFXButton Name=Pause
         ImageIndex=7
         Graphic=Texture'2K4Menus.MP3.Pause'
         Position=ICP_Scaled
         StyleName="CharButton"
         Hint="Pause Animation."
         WinTop=0.589850
         WinLeft=0.788909
         WinWidth=0.022540
         WinHeight=0.035958
         RenderWeight=0.510000
         TabOrder=27
         bNeverFocus=True
         bRepeatClick=True
         OnClickSound=CS_Down
         OnClick=InvasionProMonsterConfig.AnimControls
         OnKeyEvent=Pause.InternalOnKeyEvent
     End Object
     b_Pause=GUIGFXButton'TURInvPro.InvasionProMonsterConfig.Pause'

     Begin Object Class=GUIButton Name=LockedCancelButton
         Caption="Close"
         Hint="Close this window and cancel unsaved changes."
         WinTop=0.895495
         WinLeft=0.787296
         WinWidth=0.171970
         WinHeight=0.048624
         TabOrder=37
         bBoundToParent=True
         bScaleToParent=True
         OnClick=InvasionProMonsterConfig.ExitMonster
         OnKeyEvent=LockedCancelButton.InternalOnKeyEvent
     End Object
     b_Cancel=GUIButton'TURInvPro.InvasionProMonsterConfig.LockedCancelButton'

     Begin Object Class=GUIButton Name=LockedOKButton
         Caption="Save Monster"
         Hint="Save the current monster."
         WinTop=0.895495
         WinLeft=0.043377
         WinWidth=0.202528
         WinHeight=0.044743
         TabOrder=33
         bBoundToParent=True
         bScaleToParent=True
         OnClick=InvasionProMonsterConfig.SaveMonster
         OnKeyEvent=LockedOKButton.InternalOnKeyEvent
     End Object
     b_OK=GUIButton'TURInvPro.InvasionProMonsterConfig.LockedOKButton'

     nfov=90
     ShaderClass=Class'TURInvPro.InvasionProCylinderShader'
     FinalBlendClass=Class'TURInvPro.InvasionProCylinderFinalBlend'
     bRequire640x480=True
     WinTop=0.000000
     WinLeft=0.000000
     WinWidth=1.000000
     WinHeight=1.000000
     bScaleToParent=True
}
