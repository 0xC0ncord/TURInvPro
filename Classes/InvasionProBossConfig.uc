//=============================================================================
// InvasionProBossConfig.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProBossConfig extends GUICustomPropertyPage
   dependson(InvasionProConfigs);

const DEFAULT_NEW_BOSS_STRING = "-- New Boss --";
const DEFAULT_NEW_FALLBACK_BOSS_STRING = "-- No Fallback Boss --";

var() array<InvasionProBossListMenuOption> BossListItems;
var() array<string> BossValues;
var() array<string> FallbackBossValues;
var() InvasionProConfigs.BossEntryInfo BossEntry;
var() int ActiveBossEntryID;
var() int WaveID;
var int EditIndex;
var bool bEditMode;
var bool bEditFallbacks;
var bool bIgnoreComponentChanges;
var bool bUnsavedBossChanges;
var bool bUnsavedListChanges;
var bool bUnsavedSettingsChanges;

var() automated AltSectionBackground sb_Settings;
var() automated moNumericEdit BossEntryID;
var() automated moNumericEdit BossWaveVariant;
var() automated moCheckBox bBossesSpawnTogether;
var() automated moCheckBox bSpawnBossWithMonsters;
var() automated moCheckBox bAdvanceWaveWhenBossKilled;
var() automated moCheckBox bBossDeathKillsMonsters;
var() automated moNumericEdit BossTimeLimit;
var() automated moEditBox BossWarnMessage;
var() automated moEditBox BossWarnSound;
var() automated GUIMultiOptionListBox BossList;
var() automated GUIMultiOptionListBox OptionList;
var() automated GUIButton b_Add;
var() automated GUIButton b_Fallback;
var() automated moEditBox currentBossID;
var() automated moCheckBox currentbSetup;
var() automated moComboBox currentBossMonsterName;
var() automated moEditBox currentBossName;
var() automated moEditBox currentSpawnMessage;
var() automated moEditBox currentSpawnSound;
var() automated moNumericEdit currentBossScoreAward;
var() automated moNumericEdit currentBossHealth;
var() automated moSlider currentGroundSpeed;
var() automated moSlider currentAirSpeed;
var() automated moSlider currentWaterSpeed;
var() automated moSlider currentJumpZ;
var() automated moSlider currentGibMultiplier;
var() automated moSlider currentGibSizeMultiplier;
var() automated moSlider currentBossDamageMultiplier;
var() automated moFloatEdit currentDrawScale;
var() automated moFloatEdit currentCollisionHeight;
var() automated moFloatEdit currentCollisionRadius;
var() automated moFloatEdit currentPrePivotX;
var() automated moFloatEdit currentPrePivotY;
var() automated moFloatEdit currentPrePivotZ;
var() automated GUIButton b_Default;
var() automated GUIButton b_Random;
var() automated GUIButton b_Delete;
var() automated GUIButton b_Save;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
   local int i;

    Super.InitComponent(MyController, MyOwner);

    BossList.List.ColumnWidth = 0.9950;
    OptionList.List.ColumnWidth = 0.9950;
    currentBossID = moEditBox(OptionList.List.AddItem("XInterface.moEditBox",, "Internal Boss ID", true));
    currentBossID.SetReadOnly(true);
    currentBossID.ToolTip.SetTip("The internal ID for this boss.");
    currentbSetup = moCheckBox(OptionList.List.AddItem("XInterface.moCheckBox",, "Initialized", true));
    currentbSetup.bValueReadOnly = true;
    currentbSetup.ToolTip.SetTip("The boss is ready to join the invasion.");
    currentBossMonsterName = moComboBox(OptionList.List.AddItem("XInterface.moComboBox",, "Species", true));
    currentBossMonsterName.ReadOnly(true);
    currentBossMonsterName.__OnChange__Delegate = BossOptionOnChange;
    currentBossMonsterName.ToolTip.SetTip("Choose a monster to be the boss.");
    currentBossName = moEditBox(OptionList.List.AddItem("XInterface.moEditBox",, "Boss Name", true));
    currentBossName.__OnChange__Delegate = BossOptionOnChange;
    currentBossName.ToolTip.SetTip("Input the desired name for this boss.");
    currentSpawnMessage = moEditBox(OptionList.List.AddItem("XInterface.moEditBox",, "Spawn Message", true));
    currentSpawnMessage.__OnChange__Delegate = BossOptionOnChange;
    currentSpawnMessage.ToolTip.SetTip("Input the message to be displayed when this boss spawns.");
    currentSpawnSound = moEditBox(OptionList.List.AddItem("XInterface.moEditBox",, "Spawn Sound", true));
    currentSpawnSound.__OnChange__Delegate = BossOptionOnChange;
    currentSpawnSound.ToolTip.SetTip("Input the sound to be played when this boss spawns.");
    currentBossScoreAward = moNumericEdit(OptionList.List.AddItem("XInterface.moNumericEdit",, "Score Value", true));
    currentBossScoreAward.__OnChange__Delegate = BossOptionOnChange;
    currentBossScoreAward.ToolTip.SetTip("The amount of points that are shared between the surviving players when this boss has been defeated.");
    currentBossHealth = moNumericEdit(OptionList.List.AddItem("XInterface.moNumericEdit",, "Health", true));
    currentBossHealth.Setup(0, 1000000000, int(true));
    currentBossHealth.__OnChange__Delegate = BossOptionOnChange;
    currentBossHealth.ToolTip.SetTip("How much health the boss should have.");
    currentGroundSpeed = moSlider(OptionList.List.AddItem("XInterface.moSlider",, "Ground Speed", true));
    currentGroundSpeed.Setup(0.0, 2000.0, true);
    currentGroundSpeed.__OnChange__Delegate = BossOptionOnChange;
    currentGroundSpeed.ToolTip.SetTip("How fast the boss can move on the ground.");
    currentAirSpeed = moSlider(OptionList.List.AddItem("XInterface.moSlider",, "Air Speed", true));
    currentAirSpeed.Setup(0.0, 2000.0, true);
    currentAirSpeed.__OnChange__Delegate = BossOptionOnChange;
    currentAirSpeed.ToolTip.SetTip("How fast the boss moves through the air.");
    currentWaterSpeed = moSlider(OptionList.List.AddItem("XInterface.moSlider",, "Water Speed", true));
    currentWaterSpeed.Setup(0.0, 2000.0, true);
    currentWaterSpeed.__OnChange__Delegate = BossOptionOnChange;
    currentWaterSpeed.ToolTip.SetTip("How fast the boss can move through water.");
    currentJumpZ = moSlider(OptionList.List.AddItem("XInterface.moSlider",, "JumpZ", true));
    currentJumpZ.Setup(0.0, 2000.0, true);
    currentJumpZ.__OnChange__Delegate = BossOptionOnChange;
    currentJumpZ.ToolTip.SetTip("How high the boss can jump.");
    currentGibMultiplier = moSlider(OptionList.List.AddItem("XInterface.moSlider",, "Gib Multiplier", true));
    currentGibMultiplier.Setup(0.0, 10.0, false);
    currentGibMultiplier.__OnChange__Delegate = BossOptionOnChange;
    currentGibMultiplier.ToolTip.SetTip("If the boss is gibbed, how gibby should the experience be.");
    currentGibSizeMultiplier = moSlider(OptionList.List.AddItem("XInterface.moSlider",, "Gib Size Multiplier", true));
    currentGibSizeMultiplier.Setup(0.0, 10.0, false);
    currentGibSizeMultiplier.__OnChange__Delegate = BossOptionOnChange;
    currentGibSizeMultiplier.ToolTip.SetTip("If the boss is gibbed, how big should the gibs be.");
    currentBossDamageMultiplier = moSlider(OptionList.List.AddItem("XInterface.moSlider",, "Damage Multiplier", true));
    currentBossDamageMultiplier.Setup(0.0, 10.0, false);
    currentBossDamageMultiplier.__OnChange__Delegate = BossOptionOnChange;
    currentBossDamageMultiplier.ToolTip.SetTip("This value will multiply the damage output of the boss.");
    currentDrawScale = moFloatEdit(OptionList.List.AddItem("XInterface.moFloatEdit",, "Draw Scale", true));
    currentDrawScale.MinValue = 0.0000010;
    currentDrawScale.MaxValue = 10.0;
    currentDrawScale.Step = 0.050;
    currentDrawScale.__OnChange__Delegate = BossOptionOnChange;
    currentDrawScale.ToolTip.SetTip("The draw scale of the boss.");
    currentCollisionHeight = moFloatEdit(OptionList.List.AddItem("XInterface.moFloatEdit",, "Collision Height", true));
    currentCollisionHeight.MinValue = 0.0;
    currentCollisionHeight.MaxValue = 2000.0;
    currentCollisionHeight.Step = 0.050;
    currentCollisionHeight.__OnChange__Delegate = BossOptionOnChange;
    currentCollisionHeight.ToolTip.SetTip("The collision height of the boss.");
    currentCollisionRadius = moFloatEdit(OptionList.List.AddItem("XInterface.moFloatEdit",, "Collision Radius", true));
    currentCollisionRadius.MinValue = 0.0;
    currentCollisionRadius.MaxValue = 2000.0;
    currentCollisionRadius.Step = 0.050;
    currentCollisionRadius.__OnChange__Delegate = BossOptionOnChange;
    currentCollisionRadius.ToolTip.SetTip("The collision radius of the boss.");
    currentPrePivotX = moFloatEdit(OptionList.List.AddItem("XInterface.moFloatEdit",, "PrePivot X", true));
    currentPrePivotX.MinValue = -1000.0;
    currentPrePivotX.MaxValue = 1000.0;
    currentPrePivotX.Step = 0.050;
    currentPrePivotX.__OnChange__Delegate = BossOptionOnChange;
    currentPrePivotX.ToolTip.SetTip("The PrePivot.X value of the boss.");
    currentPrePivotY = moFloatEdit(OptionList.List.AddItem("XInterface.moFloatEdit",, "PrePivot Y", true));
    currentPrePivotY.MinValue = -1000.0;
    currentPrePivotY.MaxValue = 1000.0;
    currentPrePivotY.Step = 0.050;
    currentPrePivotY.__OnChange__Delegate = BossOptionOnChange;
    currentPrePivotY.ToolTip.SetTip("The PrePivot.Y value of the boss.");
    currentPrePivotZ = moFloatEdit(OptionList.List.AddItem("XInterface.moFloatEdit",, "PrePivot Z", true));
    currentPrePivotZ.MinValue = -1000.0;
    currentPrePivotZ.MaxValue = 1000.0;
    currentPrePivotZ.Step = 0.050;
    currentPrePivotZ.__OnChange__Delegate = BossOptionOnChange;
    currentPrePivotZ.ToolTip.SetTip("The PrePivot.Z value of the boss.");
    SetDefaultOptionListComponent(currentBossID);
    SetDefaultOptionListComponent(currentbSetup);
    SetDefaultOptionListComponent(currentBossMonsterName);
    SetDefaultOptionListComponent(currentBossName);
    SetDefaultOptionListComponent(currentSpawnMessage);
    SetDefaultOptionListComponent(currentSpawnSound);
    SetDefaultOptionListComponent(currentBossScoreAward);
    SetDefaultOptionListComponent(currentBossHealth);
    SetDefaultOptionListComponent(currentGroundSpeed);
    SetDefaultOptionListComponent(currentAirSpeed);
    SetDefaultOptionListComponent(currentWaterSpeed);
    SetDefaultOptionListComponent(currentJumpZ);
    SetDefaultOptionListComponent(currentGibMultiplier);
    SetDefaultOptionListComponent(currentGibSizeMultiplier);
    SetDefaultOptionListComponent(currentBossDamageMultiplier);
    SetDefaultOptionListComponent(currentDrawScale);
    SetDefaultOptionListComponent(currentCollisionHeight);
    SetDefaultOptionListComponent(currentCollisionRadius);
    SetDefaultOptionListComponent(currentPrePivotX);
    SetDefaultOptionListComponent(currentPrePivotY);
    SetDefaultOptionListComponent(currentPrePivotZ);

   for(i = 0; i < class'InvasionProMonsterTable'.default.MonsterTable.Length; i++)
   {
       currentBossMonsterName.AddItem(class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterName);
   }

    SetDefaultBossOptions();
    currentBossID.DisableMe();
    currentbSetup.DisableMe();
    currentBossMonsterName.DisableMe();
    currentBossName.DisableMe();
    currentBossScoreAward.DisableMe();
    currentBossHealth.DisableMe();
    currentGroundSpeed.DisableMe();
    currentAirSpeed.DisableMe();
    currentWaterSpeed.DisableMe();
    currentJumpZ.DisableMe();
    currentGibMultiplier.DisableMe();
    currentGibSizeMultiplier.DisableMe();
    currentBossDamageMultiplier.DisableMe();
    currentDrawScale.DisableMe();
    currentCollisionHeight.DisableMe();
    currentCollisionRadius.DisableMe();
    currentPrePivotX.DisableMe();
    currentPrePivotY.DisableMe();
    currentPrePivotZ.DisableMe();
    currentSpawnMessage.DisableMe();
    currentSpawnSound.DisableMe();
    b_Default.DisableMe();
    b_Random.DisableMe();
    b_Delete.DisableMe();
    b_Save.DisableMe();
    RefreshBossEntry();
}

function SetDefaultBossListComponent(GUIMenuOption PassedComponent)
{
    PassedComponent.CaptionWidth = 0.10;
    PassedComponent.ComponentWidth = 0.90;
    PassedComponent.ComponentJustification = TXTA_Center;
    PassedComponent.bStandardized = false;
    PassedComponent.bBoundToParent = false;
    PassedComponent.bScaleToParent = false;
    if(PassedComponent.MyLabel != none)
    {
        PassedComponent.MyLabel.TextAlign = TXTA_Left;
    }
}

function SetDefaultOptionListComponent(GUIMenuOption PassedComponent)
{
    PassedComponent.CaptionWidth = 0.40;
    PassedComponent.ComponentWidth = 0.60;
    PassedComponent.ComponentJustification = TXTA_Center;
    PassedComponent.bStandardized = false;
    PassedComponent.bBoundToParent = false;
    PassedComponent.bScaleToParent = false;
    if(PassedComponent.MyLabel != none)
    {
        PassedComponent.MyLabel.TextAlign = TXTA_Left;
    }
}

function SetDefaultSettings()
{
    bBossesSpawnTogether.SetComponentValue(string(false));
    bSpawnBossWithMonsters.SetComponentValue(string(false));
    bAdvanceWaveWhenBossKilled.SetComponentValue(string(false));
    bBossDeathKillsMonsters.SetComponentValue(string(false));
    BossTimeLimit.SetComponentValue(string(180));
    BossWarnMessage.SetText("");
    BossWarnSound.SetText("");
}

function Init()
{
    if(WaveID > -1)
    {
        BossEntryID.DisableMe();
        BossWaveVariant.DisableMe();
    }
    RefreshBossEntry();
}

function RefreshBossEntry()
{
    local int i, X, Y;
    local array<string> Bosses, FallbackBosses;

    bIgnoreComponentChanges = true;
    BossList.List.Clear();
    BossListItems.Remove(0, BossListItems.Length);
    if(WaveID > -1)
    {
        BossEntry = class'InvasionProConfigs'.default.WaveBossTable[WaveID];
        bBossesSpawnTogether.SetComponentValue(string(BossEntry.bBossesSpawnTogether));
        bSpawnBossWithMonsters.SetComponentValue(string(BossEntry.bSpawnBossWithMonsters));
        bAdvanceWaveWhenBossKilled.SetComponentValue(string(BossEntry.bAdvanceWaveWhenBossKilled));
        bBossDeathKillsMonsters.SetComponentValue(string(BossEntry.bBossDeathKillsMonsters));
        BossTimeLimit.SetComponentValue(string(BossEntry.BossTimeLimit));
        BossWarnMessage.SetComponentValue(BossEntry.WarningMessage);
        BossWarnSound.SetComponentValue(BossEntry.WarningSound);
        Split(BossEntry.Bosses, ",", Bosses);
        Split(BossEntry.FallbackBosses, ",", FallbackBosses);
        if(Bosses.Length < FallbackBosses.Length)
        {
            Bosses.Length = FallbackBosses.Length;
        }
        else
        {
            if(FallbackBosses.Length < Bosses.Length)
            {
                FallbackBosses.Length = Bosses.Length;
            }
        }
       for(i = 0; i < Bosses.Length; i++)
        {
            X = BossListItems.Length;
            BossListItems.Length = X + 1;
            BossListItems[X] = InvasionProBossListMenuOption(BossList.List.AddItem(string(class'InvasionProBossListMenuOption'),, "#" $ string(X + 1)));
            BossListItems[X].MyItem.InsertButton.__OnClick__Delegate = InsertBoss;
            BossListItems[X].MyItem.RemoveButton.__OnClick__Delegate = RemoveBoss;
            BossListItems[X].MyItem.EditButton.__OnClick__Delegate = EditBoss;
            BossListItems[X].MyItem.ComboBox.__OnChange__Delegate = BossListItemOnChange;
            SetDefaultBossListComponent(BossListItems[X]);
            PopulateBossListItemComboBox(BossListItems[X]);
            if(!bEditFallbacks)
            {
                if(Bosses[i] != "-1")
                {
                    BossListItems[X].MyItem.ComboBox.SetText((Bosses[i] $ ":") @ class'InvasionProConfigs'.default.Bosses[int(Bosses[i])].BossName);
                    BossValues[X] = BossListItems[X].MyItem.ComboBox.GetText();
                }
                if(FallbackBosses[i] != "-1")
                {
                    FallbackBossValues[X] = (FallbackBosses[i] $ ":") @ class'InvasionProConfigs'.default.Bosses[int(FallbackBosses[i])].BossName;
                }
               continue;
            }
            if(Bosses[i] != "-1")
            {
                BossValues[X] = (Bosses[i] $ ":") @ class'InvasionProConfigs'.default.Bosses[int(Bosses[i])].BossName;
            }
            if(FallbackBosses[i] != "-1")
            {
                BossListItems[X].MyItem.ComboBox.SetText((FallbackBosses[i] $ ":") @ class'InvasionProConfigs'.default.Bosses[int(FallbackBosses[i])].BossName);
                FallbackBossValues[X] = BossListItems[X].MyItem.ComboBox.GetText();
            }
        }
    }
    else
    {
        i = BossEntryID.GetValue();
        if(i < class'InvasionProConfigs'.default.BossTable.Length)
        {
            BossEntry = class'InvasionProConfigs'.default.BossTable[BossEntryID.GetValue()];
            BossWaveVariant.SetValue(BossEntry.WaveVariant);
            bBossesSpawnTogether.SetComponentValue(string(BossEntry.bBossesSpawnTogether));
            bSpawnBossWithMonsters.SetComponentValue(string(BossEntry.bSpawnBossWithMonsters));
            bAdvanceWaveWhenBossKilled.SetComponentValue(string(BossEntry.bAdvanceWaveWhenBossKilled));
            bBossDeathKillsMonsters.SetComponentValue(string(BossEntry.bBossDeathKillsMonsters));
            BossTimeLimit.SetComponentValue(string(BossEntry.BossTimeLimit));
            BossWarnMessage.SetComponentValue(BossEntry.WarningMessage);
            BossWarnSound.SetComponentValue(BossEntry.WarningSound);
            Split(BossEntry.Bosses, ",", Bosses);
            Split(BossEntry.FallbackBosses, ",", FallbackBosses);
            if(FallbackBosses.Length < Bosses.Length)
            {
                FallbackBosses.Length = Bosses.Length;
            }
           for(y = 0; y < Bosses.Length; y++)
            {
                X = BossListItems.Length;
                BossListItems.Length = X + 1;
                BossListItems[X] = InvasionProBossListMenuOption(BossList.List.AddItem(string(class'InvasionProBossListMenuOption'),, "#" $ string(X + 1)));
                BossListItems[X].MyItem.InsertButton.__OnClick__Delegate = InsertBoss;
                BossListItems[X].MyItem.RemoveButton.__OnClick__Delegate = RemoveBoss;
                BossListItems[X].MyItem.EditButton.__OnClick__Delegate = EditBoss;
                BossListItems[X].MyItem.ComboBox.__OnChange__Delegate = BossListItemOnChange;
                SetDefaultBossListComponent(BossListItems[X]);
                PopulateBossListItemComboBox(BossListItems[X]);
                if(!bEditFallbacks)
                {
                    if(Bosses[Y] != "-1")
                    {
                        BossListItems[X].MyItem.ComboBox.SetText((Bosses[Y] $ ":") @ class'InvasionProConfigs'.default.Bosses[int(Bosses[Y])].BossName);
                        BossValues[X] = BossListItems[X].MyItem.ComboBox.GetText();
                    }
                    if(FallbackBosses[Y] != "-1")
                    {
                        FallbackBossValues[X] = (FallbackBosses[Y] $ ":") @ class'InvasionProConfigs'.default.Bosses[int(FallbackBosses[Y])].BossName;
                    }
                   continue;
                }
                if(Bosses[Y] != "-1")
                {
                    BossValues[X] = (Bosses[Y] $ ":") @ class'InvasionProConfigs'.default.Bosses[int(Bosses[Y])].BossName;
                }
                if(FallbackBosses[Y] != "-1")
                {
                    BossListItems[X].MyItem.ComboBox.SetText((FallbackBosses[Y] $ ":") @ class'InvasionProConfigs'.default.Bosses[int(FallbackBosses[Y])].BossName);
                    FallbackBossValues[X] = BossListItems[X].MyItem.ComboBox.GetText();
                }
            }
        }
        else
        {
            SetDefaultSettings();
        }
    }
    bIgnoreComponentChanges = false;
    bUnsavedBossChanges = false;
    bUnsavedSettingsChanges = false;
    bUnsavedListChanges = false;
}

function SetDefaultBossOptions()
{
    bIgnoreComponentChanges = true;
    currentBossID.SetComponentValue(string(0));
    currentBossMonsterName.SetText("None");
    currentBossName.SetText("");
    currentSpawnMessage.SetText("");
    currentSpawnSound.SetText("");
    currentBossHealth.SetComponentValue(string(100));
    currentBossScoreAward.SetComponentValue(string(10));
    currentBossDamageMultiplier.SetComponentValue(string(1.0));
    currentGroundSpeed.SetComponentValue(string(200.0));
    currentAirSpeed.SetComponentValue(string(200.0));
    currentWaterSpeed.SetComponentValue(string(200.0));
    currentJumpZ.SetComponentValue(string(80.0));
    currentGibMultiplier.SetComponentValue(string(1.0));
    currentGibSizeMultiplier.SetComponentValue(string(1.0));
    currentDrawScale.SetComponentValue(string(1.0));
    currentCollisionHeight.SetComponentValue(string(96.0));
    currentCollisionRadius.SetComponentValue(string(48.0));
    currentPrePivotX.SetComponentValue(string(0.0));
    currentPrePivotY.SetComponentValue(string(0.0));
    currentPrePivotZ.SetComponentValue(string(0.0));
    OptionList.MyScrollBar.UpdateGripPosition(0.0);
    bIgnoreComponentChanges = false;
}

function PopulateBossListItemComboBox(InvasionProBossListMenuOption PassedComponent, optional bool bSwitchingModes)
{
    local int i;

    if(!bSwitchingModes)
    {
        bIgnoreComponentChanges = true;
    }
    if(PassedComponent.MyItem.ComboBox.ItemCount() > 0)
    {
        PassedComponent.MyItem.ComboBox.Clear();
    }
    if(!bEditFallbacks)
    {
        PassedComponent.MyItem.ComboBox.AddItem(DEFAULT_NEW_BOSS_STRING);
    }
    else
    {
        PassedComponent.MyItem.ComboBox.AddItem(DEFAULT_NEW_FALLBACK_BOSS_STRING);
    }

   for(i = 1; i < class'InvasionProConfigs'.default.Bosses.Length; i++)
    {
        PassedComponent.MyItem.ComboBox.AddItem((string(i) $ ":") @ class'InvasionProConfigs'.default.Bosses[i].BossName);
    }
    if(!bSwitchingModes)
    {
        bIgnoreComponentChanges = false;
    }
}

function bool EditBoss(GUIComponent Sender)
{
    local int i;

   for(i = 0; i < BossListItems.Length; i++)
    {
        if(Sender == BossListItems[i].MyItem.EditButton)
           break;
    }
    EditIndex = i;
    if(bUnsavedBossChanges)
    {
        Controller.OpenMenu("TURInvPro.InvasionProBossUnsavedConfirmationMenu");
        InvasionProBossUnsavedConfirmationMenu(Controller.TopPage()).BossConfigMenu = self;
        InvasionProBossUnsavedConfirmationMenu(Controller.TopPage()).Init();
        return false;
    }
    ToggleEditMode();
    return true;
}

function ToggleEditMode()
{
    local int i;

    if(EditIndex < 0)
    {
        return;
    }
    bIgnoreComponentChanges = true;
    bEditMode = !bEditMode;
    if(bEditMode)
    {
        SetupBossOptions(BossListItems[EditIndex]);
        currentBossID.EnableMe();
        currentbSetup.EnableMe();
        currentBossMonsterName.EnableMe();
        currentBossName.EnableMe();
        currentSpawnMessage.EnableMe();
        currentSpawnSound.EnableMe();
        currentBossScoreAward.EnableMe();
        currentBossHealth.EnableMe();
        currentGroundSpeed.EnableMe();
        currentAirSpeed.EnableMe();
        currentWaterSpeed.EnableMe();
        currentJumpZ.EnableMe();
        currentGibMultiplier.EnableMe();
        currentGibSizeMultiplier.EnableMe();
        currentBossDamageMultiplier.EnableMe();
        currentDrawScale.EnableMe();
        currentCollisionHeight.EnableMe();
        currentCollisionRadius.EnableMe();
        currentPrePivotX.EnableMe();
        currentPrePivotY.EnableMe();
        currentPrePivotZ.EnableMe();
        b_Default.EnableMe();
        b_Random.EnableMe();
        b_Save.EnableMe();
        if(BossListItems[EditIndex].MyItem.ComboBox.GetText() != DEFAULT_NEW_BOSS_STRING)
        {
            b_Delete.EnableMe();
        }
        currentBossName.SetReadOnly(false);
        currentSpawnMessage.SetReadOnly(false);
        currentSpawnSound.SetReadOnly(false);
        currentBossScoreAward.SetReadOnly(false);
        currentBossHealth.SetReadOnly(false);
        currentGroundSpeed.SetReadOnly(false);
        currentAirSpeed.SetReadOnly(false);
        currentWaterSpeed.SetReadOnly(false);
        currentJumpZ.SetReadOnly(false);
        currentGibMultiplier.SetReadOnly(false);
        currentGibSizeMultiplier.SetReadOnly(false);
        currentBossDamageMultiplier.SetReadOnly(false);
        currentDrawScale.SetReadOnly(false);
        currentCollisionHeight.SetReadOnly(false);
        currentCollisionRadius.SetReadOnly(false);
        currentPrePivotX.SetReadOnly(false);
        currentPrePivotY.SetReadOnly(false);
        currentPrePivotZ.SetReadOnly(false);
       for(i = 0; i < BossListItems.Length; i++)
        {
            BossListItems[i].MyItem.ComboBox.DisableMe();
            BossListItems[i].MyItem.InsertButton.DisableMe();
            BossListItems[i].MyItem.RemoveButton.DisableMe();
            if(i != EditIndex)
            {
                BossListItems[i].DisableMe();
                BossListItems[i].MyItem.EditButton.DisableMe();
            }
        }
        if(!bEditFallbacks)
        {
            b_Add.DisableMe();
        }
        b_Fallback.DisableMe();
        if(WaveID == -1)
        {
            BossEntryID.DisableMe();
        }
    }
    else
    {
        SetDefaultBossOptions();
        currentBossID.DisableMe();
        currentbSetup.DisableMe();
        currentBossMonsterName.DisableMe();
        currentBossName.DisableMe();
        currentSpawnMessage.DisableMe();
        currentSpawnSound.DisableMe();
        currentBossScoreAward.DisableMe();
        currentBossHealth.DisableMe();
        currentGroundSpeed.DisableMe();
        currentAirSpeed.DisableMe();
        currentWaterSpeed.DisableMe();
        currentJumpZ.DisableMe();
        currentGibMultiplier.DisableMe();
        currentGibSizeMultiplier.DisableMe();
        currentBossDamageMultiplier.DisableMe();
        currentDrawScale.DisableMe();
        currentCollisionHeight.DisableMe();
        currentCollisionRadius.DisableMe();
        currentPrePivotX.DisableMe();
        currentPrePivotY.DisableMe();
        currentPrePivotZ.DisableMe();
        b_Default.DisableMe();
        b_Random.DisableMe();
        b_Delete.DisableMe();
        b_Save.DisableMe();
        currentBossName.SetReadOnly(true);
        currentSpawnMessage.SetReadOnly(true);
        currentSpawnSound.SetReadOnly(true);
        currentBossScoreAward.SetReadOnly(true);
        currentBossHealth.SetReadOnly(true);
        currentGroundSpeed.SetReadOnly(true);
        currentAirSpeed.SetReadOnly(true);
        currentWaterSpeed.SetReadOnly(true);
        currentJumpZ.SetReadOnly(true);
        currentGibMultiplier.SetReadOnly(true);
        currentGibSizeMultiplier.SetReadOnly(true);
        currentBossDamageMultiplier.SetReadOnly(true);
        currentDrawScale.SetReadOnly(true);
        currentCollisionHeight.SetReadOnly(true);
        currentCollisionRadius.SetReadOnly(true);
        currentPrePivotX.SetReadOnly(true);
        currentPrePivotY.SetReadOnly(true);
        currentPrePivotZ.SetReadOnly(true);
       for(i = 0; i < BossListItems.Length; i++)
        {
            BossListItems[i].MyItem.ComboBox.EnableMe();
            BossListItems[i].MyItem.InsertButton.EnableMe();
            BossListItems[i].MyItem.RemoveButton.EnableMe();
            if(i != EditIndex)
            {
                BossListItems[i].EnableMe();
                BossListItems[i].MyItem.EditButton.EnableMe();
            }
        }
        if(!bEditFallbacks)
        {
            b_Add.EnableMe();
        }
        b_Fallback.EnableMe();
        if(WaveID == -1)
        {
            BossEntryID.EnableMe();
        }
        EditIndex = -1;
    }
    OptionList.MyScrollBar.UpdateGripPosition(0.0);
    bUnsavedBossChanges = false;
    bIgnoreComponentChanges = false;
}

function SetupBossOptions(InvasionProBossListMenuOption Sender)
{
    local int i;
    local array<string> Parts;

    bIgnoreComponentChanges = true;
    if((Sender.MyItem.ComboBox.Get() != DEFAULT_NEW_BOSS_STRING) && Sender.MyItem.ComboBox.Get() != DEFAULT_NEW_FALLBACK_BOSS_STRING)
    {
        Split(Sender.MyItem.ComboBox.Get(), ":", Parts);
        i = int(Parts[0]);
        currentBossID.SetComponentValue(string(i));
        currentbSetup.SetComponentValue(string(class'InvasionProConfigs'.default.Bosses[i].bSetup));
        currentBossMonsterName.SetText(class'InvasionProConfigs'.default.Bosses[i].BossMonsterName, true);
        currentBossName.SetText(class'InvasionProConfigs'.default.Bosses[i].BossName);
        currentSpawnMessage.SetText(class'InvasionProConfigs'.default.Bosses[i].SpawnMessage);
        currentSpawnSound.SetText(class'InvasionProConfigs'.default.Bosses[i].SpawnSound);
        currentBossHealth.SetComponentValue(string(class'InvasionProConfigs'.default.Bosses[i].BossHealth));
        currentBossScoreAward.SetComponentValue(string(class'InvasionProConfigs'.default.Bosses[i].BossScoreAward));
        currentBossDamageMultiplier.SetComponentValue(string(class'InvasionProConfigs'.default.Bosses[i].BossDamageMultiplier));
        currentGroundSpeed.SetComponentValue(string(class'InvasionProConfigs'.default.Bosses[i].BossGroundSpeed));
        currentAirSpeed.SetComponentValue(string(class'InvasionProConfigs'.default.Bosses[i].BossAirSpeed));
        currentWaterSpeed.SetComponentValue(string(class'InvasionProConfigs'.default.Bosses[i].BossWaterSpeed));
        currentJumpZ.SetComponentValue(string(class'InvasionProConfigs'.default.Bosses[i].BossJumpZ));
        currentGibMultiplier.SetComponentValue(string(class'InvasionProConfigs'.default.Bosses[i].BossGibMultiplier));
        currentGibSizeMultiplier.SetComponentValue(string(class'InvasionProConfigs'.default.Bosses[i].BossGibSizeMultiplier));
        currentDrawScale.SetComponentValue(string(class'InvasionProConfigs'.default.Bosses[i].NewDrawScale));
        currentCollisionHeight.SetComponentValue(string(class'InvasionProConfigs'.default.Bosses[i].NewCollisionHeight));
        currentCollisionRadius.SetComponentValue(string(class'InvasionProConfigs'.default.Bosses[i].NewCollisionRadius));
        currentPrePivotX.SetComponentValue(string(class'InvasionProConfigs'.default.Bosses[i].NewPrePivot.X));
        currentPrePivotY.SetComponentValue(string(class'InvasionProConfigs'.default.Bosses[i].NewPrePivot.Y));
        currentPrePivotZ.SetComponentValue(string(class'InvasionProConfigs'.default.Bosses[i].NewPrePivot.Z));
    }
    else
    {
        currentBossID.SetComponentValue(string(-1));
        currentbSetup.SetComponentValue(string(false));
        currentBossMonsterName.SetText(class'InvasionProMonsterTable'.default.MonsterTable[0].MonsterName);
    }
    bIgnoreComponentChanges = false;
}

function bool AddBoss(GUIComponent Sender)
{
    local int i;

    i = BossListItems.Length;
    BossListItems.Length = i + 1;
    BossListItems[i] = InvasionProBossListMenuOption(BossList.List.AddItem(string(class'InvasionProBossListMenuOption'),, "#" $ string(i + 1)));
    BossListItems[i].MyItem.InsertButton.__OnClick__Delegate = InsertBoss;
    BossListItems[i].MyItem.RemoveButton.__OnClick__Delegate = RemoveBoss;
    BossListItems[i].MyItem.EditButton.__OnClick__Delegate = EditBoss;
    BossListItems[i].MyItem.ComboBox.__OnChange__Delegate = BossListItemOnChange;
    if(bEditFallbacks)
    {
        BossListItems[i].MyItem.InsertButton.SetVisibility(false);
        BossListItems[i].MyItem.RemoveButton.SetVisibility(false);
    }
    SetDefaultBossListComponent(BossListItems[i]);
    PopulateBossListItemComboBox(BossListItems[i]);
    BossValues[i] = BossListItems[i].MyItem.ComboBox.GetText();
    FallbackBossValues[i] = DEFAULT_NEW_FALLBACK_BOSS_STRING;
    if(!bUnsavedListChanges)
    {
        bUnsavedListChanges = true;
    }
    return true;
}

function bool InsertBoss(GUIComponent Sender)
{
    local int i;

   for(i = 0; i < BossListItems.Length; i++)
    {
        if(Sender == BossListItems[i].MyItem.InsertButton)
           break;
    }
    BossListItems.Insert(i, 1);
    BossListItems[i] = InvasionProBossListMenuOption(BossList.List.InsertItem(i, string(class'InvasionProBossListMenuOption'),, "#" $ string(i + 1)));
    BossListItems[i].MyItem.InsertButton.__OnClick__Delegate = InsertBoss;
    BossListItems[i].MyItem.RemoveButton.__OnClick__Delegate = RemoveBoss;
    BossListItems[i].MyItem.EditButton.__OnClick__Delegate = EditBoss;
    BossListItems[i].MyItem.ComboBox.__OnChange__Delegate = BossListItemOnChange;
    if(bEditFallbacks)
    {
        BossListItems[i].MyItem.InsertButton.SetVisibility(false);
        BossListItems[i].MyItem.RemoveButton.SetVisibility(false);
    }
    SetDefaultBossListComponent(BossListItems[i]);
    PopulateBossListItemComboBox(BossListItems[i]);
    BossValues[i] = BossListItems[i].MyItem.ComboBox.GetText();
    FallbackBossValues[i] = DEFAULT_NEW_FALLBACK_BOSS_STRING;
    if(!bUnsavedListChanges)
    {
        bUnsavedListChanges = true;
    }
    RefreshBossList();
    return true;
}

function bool RemoveBoss(GUIComponent Sender)
{
    local int i;

   for(i = 0; i < BossListItems.Length; i++)
    {
        if(Sender == BossListItems[i].MyItem.RemoveButton)
           break;
    }
    BossListItems.Remove(i, 1);
    BossList.List.RemoveItem(i);
    BossValues[i] = "";
    FallbackBossValues[i] = "";
    if(!bUnsavedListChanges)
    {
        bUnsavedListChanges = true;
    }
    RefreshBossList();
    return true;
}

function RefreshBossList()
{
    local int i;
    local string S;

    bIgnoreComponentChanges = true;
   for(i = 0; i < BossListItems.Length; i++)
    {
        S = "#" $ string(i + 1);
        if(BossListItems[i].Caption != S)
        {
            BossListItems[i].SetCaption(S);
        }
    }
    bIgnoreComponentChanges = false;
}

function bool EditFallbackBoss(GUIComponent Sender)
{
    local int i;

    bIgnoreComponentChanges = true;
    bEditFallbacks = !bEditFallbacks;
    if(bEditFallbacks)
    {
       for(i = 0; i < BossListItems.Length; i++)
        {
            BossValues[i] = BossListItems[i].MyItem.ComboBox.GetText();
            BossListItems[i].MyItem.ComboBox.Clear();
            PopulateBossListItemComboBox(BossListItems[i], true);
            BossListItems[i].MyItem.ComboBox.SetText(FallbackBossValues[i]);
            BossListItems[i].MyItem.InsertButton.SetVisibility(false);
            BossListItems[i].MyItem.RemoveButton.SetVisibility(false);
        }
        b_Add.DisableMe();
        b_Fallback.Caption = "Hide Fallbacks";
    }
    else
    {
       for(i = 0; i < BossListItems.Length; i++)
        {
            FallbackBossValues[i] = BossListItems[i].MyItem.ComboBox.GetText();
            BossListItems[i].MyItem.ComboBox.Clear();
            PopulateBossListItemComboBox(BossListItems[i], true);
            BossListItems[i].MyItem.ComboBox.SetText(BossValues[i]);
            BossListItems[i].MyItem.InsertButton.SetVisibility(true);
            BossListItems[i].MyItem.RemoveButton.SetVisibility(true);
        }
        b_Add.EnableMe();
        b_Fallback.Caption = "Show Fallbacks";
    }
    bIgnoreComponentChanges = false;
    return true;
}

function bool DefaultBoss(GUIComponent Sender)
{
    local class<Monster> MClass;
    local int OldBossHealth, OldBossScoreAward, OldBossDamageMultiplier, OldGroundSpeed, OldAirSpeed, OldWaterSpeed,
       OldJumpZ, OldGibMultiplier, OldGibSizeMultiplier;

    if(!bUnsavedBossChanges)
    {
        OldBossHealth = currentBossHealth.GetValue();
        OldBossScoreAward = currentBossHealth.GetValue();
        OldBossDamageMultiplier = int(currentBossDamageMultiplier.GetValue());
        OldGroundSpeed = int(currentGroundSpeed.GetValue());
        OldAirSpeed = int(currentAirSpeed.GetValue());
        OldWaterSpeed = int(currentWaterSpeed.GetValue());
        OldJumpZ = int(currentJumpZ.GetValue());
        OldGibMultiplier = int(currentGibMultiplier.GetValue());
        OldGibSizeMultiplier = int(currentGibSizeMultiplier.GetValue());
    }
    MClass = class<Monster>(DynamicLoadObject(class'InvasionProMonsterTable'.default.MonsterTable[currentBossMonsterName.MyComboBox.Index].MonsterClassName, class'Class'));
    currentBossName.SetText(("Boss (" $ currentBossMonsterName.GetText()) $ ")");
    currentBossHealth.SetComponentValue(string(MClass.default.Health));
    currentBossScoreAward.SetComponentValue(string(MClass.default.ScoringValue));
    currentGroundSpeed.SetComponentValue(string(MClass.default.GroundSpeed));
    currentAirSpeed.SetComponentValue(string(MClass.default.AirSpeed));
    currentWaterSpeed.SetComponentValue(string(MClass.default.WaterSpeed));
    currentJumpZ.SetComponentValue(string(MClass.default.JumpZ));
    currentDrawScale.SetComponentValue(string(MClass.default.DrawScale));
    currentCollisionHeight.SetComponentValue(string(MClass.default.CollisionHeight));
    currentCollisionRadius.SetComponentValue(string(MClass.default.CollisionRadius));
    currentPrePivotX.SetComponentValue(string(MClass.default.PrePivot.X));
    currentPrePivotY.SetComponentValue(string(MClass.default.PrePivot.Y));
    currentPrePivotZ.SetComponentValue(string(MClass.default.PrePivot.Z));
    if(!bUnsavedBossChanges && (
       OldBossHealth != currentBossHealth.GetValue() ||
       OldBossScoreAward != currentBossScoreAward.GetValue() ||
       OldBossDamageMultiplier != currentBossDamageMultiplier.GetValue() ||
       OldGroundSpeed != currentGroundSpeed.GetValue() ||
       OldAirSpeed != currentAirSpeed.GetValue() ||
       OldWaterSpeed != currentWaterSpeed.GetValue() ||
       OldJumpZ != currentJumpZ.GetValue() ||
       OldGibMultiplier != currentGibMultiplier.GetValue() ||
       OldGibSizeMultiplier != currentGibSizeMultiplier.GetValue()))
    {
        bUnsavedBossChanges = true;
    }
    return true;
}

function bool RandomBoss(GUIComponent Sender)
{
    local int i, OldBossHealth, OldBossScoreAward, OldBossDamageMultiplier, OldGroundSpeed, OldAirSpeed,
       OldWaterSpeed, OldJumpZ, OldGibMultiplier, OldGibSizeMultiplier;

    if(!bUnsavedBossChanges)
    {
        OldBossHealth = currentBossHealth.GetValue();
        OldBossScoreAward = currentBossHealth.GetValue();
        OldBossDamageMultiplier = int(currentBossDamageMultiplier.GetValue());
        OldGroundSpeed = int(currentGroundSpeed.GetValue());
        OldAirSpeed = int(currentAirSpeed.GetValue());
        OldWaterSpeed = int(currentWaterSpeed.GetValue());
        OldJumpZ = int(currentJumpZ.GetValue());
        OldGibMultiplier = int(currentGibMultiplier.GetValue());
        OldGibSizeMultiplier = int(currentGibSizeMultiplier.GetValue());
    }
    i = Max(100, Rand(1000));
    currentBossHealth.SetComponentValue(string(i));
    i = Max(10, Rand(200));
    currentBossScoreAward.SetComponentValue(string(i));
    currentBossDamageMultiplier.SetComponentValue(string(FRand() * float(10)));
    currentGroundSpeed.SetComponentValue(string(FRand() * float(1000)));
    currentAirSpeed.SetComponentValue(string(FRand() * float(1000)));
    currentWaterSpeed.SetComponentValue(string(FRand() * float(1000)));
    currentJumpZ.SetComponentValue(string(FRand() * float(1000)));
    currentGibMultiplier.SetComponentValue(string(FRand() * float(10)));
    currentGibSizeMultiplier.SetComponentValue(string(FRand() * float(10)));
    if(!bUnsavedBossChanges && (
       OldBossHealth != currentBossHealth.GetValue() ||
       OldBossScoreAward != currentBossScoreAward.GetValue() ||
       OldBossDamageMultiplier != currentBossDamageMultiplier.GetValue() ||
       OldGroundSpeed != currentGroundSpeed.GetValue() ||
       OldAirSpeed != currentAirSpeed.GetValue() ||
       OldWaterSpeed != currentWaterSpeed.GetValue() ||
       OldJumpZ != currentJumpZ.GetValue() ||
       OldGibMultiplier != currentGibMultiplier.GetValue() ||
       OldGibSizeMultiplier != currentGibSizeMultiplier.GetValue()))
    {
        bUnsavedBossChanges = true;
    }
    return true;
}

function bool DeleteBoss(GUIComponent Sender)
{
    if(int(currentBossID.GetText()) < class'InvasionProConfigs'.default.Bosses.Length)
    {
        Controller.OpenMenu("TURInvPro.InvasionProBossDeleteConfirmationMenu");
        InvasionProBossDeleteConfirmationMenu(Controller.TopPage()).BossConfigMenu = self;
        InvasionProBossDeleteConfirmationMenu(Controller.TopPage()).Init();
    }
    return true;
}

function ConfirmDeleteBoss()
{
    local int i;
    local string ThisBoss;

    ThisBoss = BossListItems[EditIndex].MyItem.ComboBox.GetText();
   for(i = 0; i < BossListItems.Length; i++)
    {
        if(BossListItems[i].MyItem.ComboBox.GetText() == ThisBoss)
        {
            BossListItems[i].MyItem.ComboBox.RemoveItem(BossListItems[i].MyItem.ComboBox.GetIndex(), 1);
        }
        if(BossValues[i] == ThisBoss)
        {
            BossValues[i] = BossListItems[i].MyItem.ComboBox.GetText();
        }
        if(FallbackBossValues[i] == ThisBoss)
        {
            FallbackBossValues[i] = BossListItems[i].MyItem.ComboBox.GetText();
        }
    }
    bUnsavedBossChanges = false;
    EditBoss(BossListItems[EditIndex]);
}

function BossOptionOnChange(GUIComponent Sender)
{
    if(bIgnoreComponentChanges)
    {
        return;
    }
    if(Sender == currentBossMonsterName && !currentbSetup.IsChecked())
    {
        DefaultBoss(Sender);
        bUnsavedBossChanges = false;
        currentBossID.SetComponentValue(string(class'InvasionProConfigs'.default.Bosses.Length));
        currentbSetup.SetComponentValue(string(true));
    }
    else
    {
        if(!bUnsavedBossChanges)
        {
            bUnsavedBossChanges = true;
        }
    }
}

function InternalOnChange(GUIComponent Sender)
{
    if(bIgnoreComponentChanges)
    {
        return;
    }
    if(!bUnsavedSettingsChanges && Sender != BossEntryID &&
       (
           Sender == BossWaveVariant ||
           Sender == bBossesSpawnTogether ||
           Sender == bSpawnBossWithMonsters ||
           Sender == bAdvanceWaveWhenBossKilled ||
           Sender == bBossDeathKillsMonsters ||
           Sender == BossWarnMessage ||
           Sender == BossWarnSound ||
           Sender == BossTimeLimit
       )
   )
    {
        bUnsavedSettingsChanges = true;
    }
    else
    {
        if(Sender == BossEntryID)
        {
            if((bUnsavedSettingsChanges || bUnsavedListChanges) || bUnsavedBossChanges)
            {
                Controller.OpenMenu("TURInvPro.InvasionProBossUnsavedConfirmationMenu");
                InvasionProBossUnsavedConfirmationMenu(Controller.TopPage()).BossConfigMenu = self;
                InvasionProBossUnsavedConfirmationMenu(Controller.TopPage()).bChangeEntries = true;
                InvasionProBossUnsavedConfirmationMenu(Controller.TopPage()).Init();
            }
            else
            {
                RefreshBossEntry();
                ActiveBossEntryID = BossEntryID.GetValue();
            }
        }
    }
}

function BossListItemOnChange(GUIComponent Sender)
{
    local int i;

    if(bIgnoreComponentChanges)
    {
        return;
    }

    i = -1;

   for(i = 0; i < BossListItems.Length; i++)
    {
        if(Sender == BossListItems[i].MyItem.ComboBox)
           break;
    }
    if(i == -1)
    {
        return;
    }
    if(bEditFallbacks)
    {
        FallbackBossValues[i] = GUIComboBox(Sender).GetText();
    }
    else
    {
        BossValues[i] = GUIComboBox(Sender).GetText();
    }
}

function DiscardChanges(bool bWantsToClose)
{
    if(bWantsToClose)
    {
        bUnsavedBossChanges = false;
        bUnsavedListChanges = false;
        bUnsavedSettingsChanges = false;
    }
    else
    {
        bUnsavedBossChanges = false;
    }
}

function bool SaveBoss(GUIComponent Sender)
{
    local int i, X;

    bUnsavedBossChanges = false;
    i = int(currentBossID.GetText());
    if(i >= class'InvasionProConfigs'.default.Bosses.Length)
    {
        class'InvasionProConfigs'.default.Bosses.Length = i + 1;
    }
    class'InvasionProConfigs'.default.Bosses[i].bSetup = currentbSetup.IsChecked();
    class'InvasionProConfigs'.default.Bosses[i].BossName = currentBossName.GetText();
    class'InvasionProConfigs'.default.Bosses[i].BossMonsterName = currentBossMonsterName.GetText();
    class'InvasionProConfigs'.default.Bosses[i].BossHealth = currentBossHealth.GetValue();
    class'InvasionProConfigs'.default.Bosses[i].BossScoreAward = currentBossScoreAward.GetValue();
    class'InvasionProConfigs'.default.Bosses[i].BossDamageMultiplier = currentBossDamageMultiplier.GetValue();
    class'InvasionProConfigs'.default.Bosses[i].BossGroundSpeed = currentGroundSpeed.GetValue();
    class'InvasionProConfigs'.default.Bosses[i].BossAirSpeed = currentAirSpeed.GetValue();
    class'InvasionProConfigs'.default.Bosses[i].BossWaterSpeed = currentWaterSpeed.GetValue();
    class'InvasionProConfigs'.default.Bosses[i].BossJumpZ = currentJumpZ.GetValue();
    class'InvasionProConfigs'.default.Bosses[i].BossGibMultiplier = currentGibMultiplier.GetValue();
    class'InvasionProConfigs'.default.Bosses[i].BossGibSizeMultiplier = currentGibSizeMultiplier.GetValue();
    class'InvasionProConfigs'.default.Bosses[i].NewDrawScale = currentDrawScale.GetValue();
    class'InvasionProConfigs'.default.Bosses[i].NewCollisionHeight = currentCollisionHeight.GetValue();
    class'InvasionProConfigs'.default.Bosses[i].NewCollisionRadius = currentCollisionRadius.GetValue();
    class'InvasionProConfigs'.default.Bosses[i].NewPrePivot.X = currentPrePivotX.GetValue();
    class'InvasionProConfigs'.default.Bosses[i].NewPrePivot.Y = currentPrePivotY.GetValue();
    class'InvasionProConfigs'.default.Bosses[i].NewPrePivot.Z = currentPrePivotZ.GetValue();
    class'InvasionProConfigs'.default.Bosses[i].SpawnMessage = currentSpawnMessage.GetText();
    class'InvasionProConfigs'.default.Bosses[i].SpawnSound = currentSpawnSound.GetText();
    class'InvasionProConfigs'.static.StaticSaveConfig();

   for(x = 0; x < BossListItems.Length; x++)
    {
        BossListItems[X].MyItem.ComboBox.AddItem(string(i) $ ":" @ class'InvasionProConfigs'.default.Bosses[i].BossName);
    }
    BossListItems[EditIndex].MyItem.ComboBox.SetIndex(i);
    if(b_Delete.MenuState == 4)
    {
        b_Delete.EnableMe();
    }
    return true;
}

function bool SaveSettings(GUIComponent Sender)
{
    local int i;
    local array<string> Parts;
    local string NewBosses, NewFallbackBosses;

    bUnsavedSettingsChanges = false;
    bUnsavedListChanges = false;
    if(WaveID > -1)
    {
        BossEntry.bBossesSpawnTogether = bBossesSpawnTogether.IsChecked();
        BossEntry.bSpawnBossWithMonsters = bSpawnBossWithMonsters.IsChecked();
        BossEntry.bAdvanceWaveWhenBossKilled = bAdvanceWaveWhenBossKilled.IsChecked();
        BossEntry.bBossDeathKillsMonsters = bBossDeathKillsMonsters.IsChecked();
        BossEntry.BossTimeLimit = BossTimeLimit.GetValue();
        BossEntry.WarningMessage = BossWarnMessage.GetText();
        BossEntry.WarningSound = BossWarnSound.GetText();

       for(i = 0; i < BossListItems.Length; i++)
        {
            if(NewBosses != "")
            {
                NewBosses $= ",";
            }
            Split(BossValues[i], ":", Parts);
            if(Parts[0] == DEFAULT_NEW_BOSS_STRING || Parts[0] == DEFAULT_NEW_FALLBACK_BOSS_STRING)
            {
                NewBosses $= "-1";
            }
            else
            {
                NewBosses $= Parts[0];
            }
            if(NewFallbackBosses != "")
            {
                NewFallbackBosses $= ",";
            }
            Split(FallbackBossValues[i], ":", Parts);
            if(Parts[0] == DEFAULT_NEW_BOSS_STRING || Parts[0] == DEFAULT_NEW_FALLBACK_BOSS_STRING)
            {
                NewFallbackBosses $= "-1";
               continue;
            }
            NewFallbackBosses $= Parts[0];
        }
        BossEntry.Bosses = NewBosses;
        BossEntry.FallbackBosses = NewFallbackBosses;
        class'InvasionProConfigs'.default.WaveBossTable[WaveID] = BossEntry;
    }
    else
    {
        if(ActiveBossEntryID >= class'InvasionProConfigs'.default.BossTable.Length)
        {
            class'InvasionProConfigs'.default.BossTable.Length = ActiveBossEntryID + 1;
        }
        BossEntry.WaveVariant = BossWaveVariant.GetValue();
        BossEntry.bBossesSpawnTogether = bBossesSpawnTogether.IsChecked();
        BossEntry.bSpawnBossWithMonsters = bSpawnBossWithMonsters.IsChecked();
        BossEntry.bAdvanceWaveWhenBossKilled = bAdvanceWaveWhenBossKilled.IsChecked();
        BossEntry.bBossDeathKillsMonsters = bBossDeathKillsMonsters.IsChecked();
        BossEntry.BossTimeLimit = BossTimeLimit.GetValue();
        BossEntry.WarningMessage = BossWarnMessage.GetText();
        BossEntry.WarningSound = BossWarnSound.GetText();

       for(i = 0; i < BossListItems.Length; i++)
        {
            if(NewBosses != "")
            {
                NewBosses $= ",";
            }
            Split(BossValues[i], ":", Parts);
            if(Parts[0] == DEFAULT_NEW_BOSS_STRING || Parts[0] == DEFAULT_NEW_FALLBACK_BOSS_STRING)
            {
                NewBosses $= "-1";
            }
            else
            {
                NewBosses $= Parts[0];
            }
            if(NewFallbackBosses != "")
            {
                NewFallbackBosses $= ",";
            }
            Split(FallbackBossValues[i], ":", Parts);
            if(Parts[0] == DEFAULT_NEW_BOSS_STRING || Parts[0] == DEFAULT_NEW_FALLBACK_BOSS_STRING)
            {
                NewFallbackBosses $= "-1";
               continue;
            }
            NewFallbackBosses $= Parts[0];
        }
        BossEntry.Bosses = NewBosses;
        BossEntry.FallbackBosses = NewFallbackBosses;
        class'InvasionProConfigs'.default.BossTable[ActiveBossEntryID] = BossEntry;
    }
    class'InvasionProConfigs'.static.StaticSaveConfig();
    return true;
}

function bool ExitBoss(GUIComponent Sender)
{
    if(bUnsavedBossChanges || bUnsavedListChanges || bUnsavedSettingsChanges)
    {
        Controller.OpenMenu("TURInvPro.InvasionProBossUnsavedConfirmationMenu");
        InvasionProBossUnsavedConfirmationMenu(Controller.TopPage()).BossConfigMenu = self;
        InvasionProBossUnsavedConfirmationMenu(Controller.TopPage()).bCloseBossConfig = true;
        InvasionProBossUnsavedConfirmationMenu(Controller.TopPage()).Init();
        return false;
    }
    Controller.CloseMenu(false);
    return true;
}

function bool InternalOnClick(GUIComponent Sender)
{
    return ExitBoss(Sender);
}

defaultproperties
{
    Begin Object Name=SettingsFrameImage class=AltSectionBackground
        WinTop=0.6663010
        WinLeft=0.0150
        WinWidth=0.970
        WinHeight=0.250
    End Object
    sb_Settings=SettingsFrameImage

    Begin Object Name=BossEntryID_ class=moNumericEdit
        MinValue=0
        MaxValue=99
        CaptionWidth=0.80
        Caption="Boss Wave ID"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select the boss entry you'd like to configure."
        WinTop=0.7105710
        WinLeft=0.0306250
        WinWidth=0.450
        WinHeight=0.560
        OnChange=InternalOnChange
    End Object
    BossEntryID=moNumericEdit'BossEntryID_'

    Begin Object Name=BossWaveVariant_ class=moNumericEdit
        MinValue=0
        MaxValue=99
        CaptionWidth=0.80
        Caption="Boss Wave Variant"
        OnCreateComponent=InternalOnCreateComponent
        Hint="What wave this boss entry can appear for."
        WinTop=0.7105710
        WinLeft=0.5042580
        WinWidth=0.4670
        WinHeight=0.560
        OnChange=InternalOnChange
    End Object
    BossWaveVariant=moNumericEdit'BossWaveVariant_'

    Begin Object Name=bBossesSpawnTogether_ class=moCheckBox
        Caption="Spawn Bosses Together"
        OnCreateComponent=InternalOnCreateComponent
        Hint="If there are multiple bosses, spawn them all simultaneously. Otherwise, spawn each boss one after the other."
        WinTop=0.7496330
        WinLeft=0.0306250
        WinWidth=0.450
        WinHeight=0.560
        OnChange=InternalOnChange
    End Object
    bBossesSpawnTogether=moCheckBox'bBossesSpawnTogether_'

    Begin Object Name=bSpawnBossWithMonsters_ class=moCheckBox
        Caption="Spawn Boss with Monsters"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Spawn the boss at the beginning of the wave alongside normal monsters. The wave is endless while the boss is still alive."
        WinTop=0.7886950
        WinLeft=0.0306250
        WinWidth=0.450
        WinHeight=0.560
        OnChange=InternalOnChange
    End Object
    bSpawnBossWithMonsters=moCheckBox'bSpawnBossWithMonsters_'

    Begin Object Name=bAdvanceWaveWhenBossKilled_ class=moCheckBox
        Caption="Advance Wave When Boss Killed"
        OnCreateComponent=InternalOnCreateComponent
        Hint="The boss' death signals the end of the wave."
        WinTop=0.8277570
        WinLeft=0.0306250
        WinWidth=0.450
        WinHeight=0.560
        OnChange=InternalOnChange
    End Object
    bAdvanceWaveWhenBossKilled=moCheckBox'bAdvanceWaveWhenBossKilled_'

    Begin Object Name=bBossDeathKillsMonsters_ class=moCheckBox
        Caption="Boss Death Kills Monsters"
        OnCreateComponent=InternalOnCreateComponent
        Hint="When the boss is killed, all other monsters are killed as well."
        WinTop=0.8668190
        WinLeft=0.0306250
        WinWidth=0.450
        WinHeight=0.560
        OnChange=InternalOnChange
    End Object
    bBossDeathKillsMonsters=moCheckBox'bBossDeathKillsMonsters_'

    Begin Object Name=BossTimeLimit_ class=moNumericEdit
        MinValue=0
        CaptionWidth=0.80
        Caption="Boss Time Limit"
        OnCreateComponent=InternalOnCreateComponent
        Hint="How long do players have to kill the boss before over time damage starts occuring."
        WinTop=0.7496330
        WinLeft=0.5042580
        WinWidth=0.4670
        WinHeight=0.560
        OnChange=InternalOnChange
    End Object
    BossTimeLimit=moNumericEdit'BossTimeLimit_'

    Begin Object Name=BossWarnMessage_ class=moEditBox
        CaptionWidth=0.350
        Caption="Warn Message"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Input the message to be displayed when this boss is about to be spawned."
        WinTop=0.7886950
        WinLeft=0.5042580
        WinWidth=0.4670
        WinHeight=0.560
        OnChange=InternalOnChange
    End Object
    BossWarnMessage=moEditBox'BossWarnMessage_'

    Begin Object Name=BossWarnSound_ class=moEditBox
        CaptionWidth=0.350
        Caption="Warn Sound"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Input the sound to be played when this boss is about to spawn."
        WinTop=0.8277570
        WinLeft=0.5042580
        WinWidth=0.4670
        WinHeight=0.560
        OnChange=InternalOnChange
    End Object
    BossWarnSound=moEditBox'BossWarnSound_'

    Begin Object Name=BossList_ class=GUIMultiOptionListBox
        bVisibleWhenEmpty=true
        OnCreateComponent=InternalOnCreateComponent
        StyleName="ServerBrowserGrid"
        WinTop=0.08250
        WinLeft=0.0250
        WinWidth=0.4540
        WinHeight=0.5318290
        bBoundToParent=true
        bScaleToParent=true
    End Object
    BossList=GUIMultiOptionListBox'BossList_'

    Begin Object Name=OptionList_ class=GUIMultiOptionListBox
        bVisibleWhenEmpty=true
        OnCreateComponent=InternalOnCreateComponent
        StyleName="ServerBrowserGrid"
        WinTop=0.0369790
        WinLeft=0.50
        WinWidth=0.48250
        WinHeight=0.5818290
        bBoundToParent=true
        bScaleToParent=true
    End Object
    OptionList=GUIMultiOptionListBox'OptionList_'

    Begin Object Name=LockedAddButton class=GUIButton
        Caption="Add"
        Hint="Add another boss to the list."
        WinTop=0.6154640
        WinLeft=0.080
        WinWidth=0.150
        WinHeight=0.050
        TabOrder=25
        bBoundToParent=true
        bScaleToParent=true
        OnClick=AddBoss
    End Object
    b_Add=GUIButton'LockedAddButton'

    Begin Object Name=LockedFallbackButton class=GUIButton
        Caption="Edit Fallbacks"
        Hint="Edit each boss' corresponding fallback boss."
        WinTop=0.6154640
        WinLeft=0.270
        WinWidth=0.150
        WinHeight=0.050
        TabOrder=25
        bBoundToParent=true
        bScaleToParent=true
        OnClick=EditFallbackBoss
    End Object
    b_Fallback=GUIButton'LockedFallbackButton'

    Begin Object Name=LockedDefaultButton class=GUIButton
        Caption="Default"
        Hint="Set the defaults for the current boss monster."
        WinTop=0.6154640
        WinLeft=0.50
        WinWidth=0.120
        WinHeight=0.050
        TabOrder=23
        bBoundToParent=true
        bScaleToParent=true
        OnClick=DefaultBoss
    End Object
    b_Default=GUIButton'LockedDefaultButton'

    Begin Object Name=LockedRandomButton class=GUIButton
        Caption="Random"
        Hint="Create a random boss."
        WinTop=0.6154640
        WinLeft=0.6219720
        WinWidth=0.120
        WinHeight=0.050
        TabOrder=23
        bBoundToParent=true
        bScaleToParent=true
        OnClick=RandomBoss
    End Object
    b_Random=GUIButton'LockedRandomButton'

    Begin Object Name=LockedDeleteButton class=GUIButton
        Caption="Delete Boss"
        Hint="Deletes the current boss."
        WinTop=0.6154640
        WinLeft=0.7435730
        WinWidth=0.120
        WinHeight=0.050
        TabOrder=23
        bBoundToParent=true
        bScaleToParent=true
        OnClick=DeleteBoss
    End Object
    b_Delete=GUIButton'LockedDeleteButton'

    Begin Object Name=LockedSaveButton class=GUIButton
        Caption="Save Boss"
        Hint="Save the current boss."
        WinTop=0.6154640
        WinLeft=0.864550
        WinWidth=0.120
        WinHeight=0.050
        TabOrder=23
        bBoundToParent=true
        bScaleToParent=true
        OnClick=SaveBoss
    End Object
    b_Save=GUIButton'LockedSaveButton'

    WaveID=-1
    Begin Object Name=InternalFrameImage class=AltSectionBackground
        WinTop=0.040
        WinLeft=0.0150
        WinWidth=0.4750
        WinHeight=0.560
    End Object
    sb_Main=AltSectionBackground'InternalFrameImage'

    Begin Object Name=LockedCancelButton class=GUIButton
        Caption="Close"
        Hint="Close this window and cancel unsaved changes."
        WinTop=0.93250
        WinLeft=0.7396670
        WinWidth=0.120
        WinHeight=0.050
        TabOrder=22
        bBoundToParent=true
        bScaleToParent=true
        OnClick=ExitBoss
    End Object
    b_Cancel=GUIButton'LockedCancelButton'

    Begin Object Name=LockedOKButton class=GUIButton
        Caption="Save"
        Hint="Save the settings for this boss entry."
        WinTop=0.93250
        WinLeft=0.8596670
        WinWidth=0.120
        WinHeight=0.050
        TabOrder=23
        bBoundToParent=true
        bScaleToParent=true
        OnClick=SaveSettings
    End Object
    b_OK=GUIButton'LockedOKButton'

    DefaultLeft=0.0
    DefaultTop=0.0289350
    DefaultWidth=1.0
    DefaultHeight=0.90
    bRequire640x480=true
    WinTop=0.050
    WinLeft=0.0
    WinWidth=1.0
    WinHeight=0.90
    bScaleToParent=true
}
