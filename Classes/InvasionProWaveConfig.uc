//=============================================================================
// InvasionProWaveConfig.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProWaveConfig extends GUICustomPropertyPage;

var() int ActiveWave;
var() automated GUIButton b_Copy;
var() automated GUIButton b_Paste;
var() automated GUIButton b_Reset;
var() automated GUIButton b_Random;
var() automated GUIButton b_Default;
var() automated moCheckBox currentbOverrideBoss;
var() automated GUIButton b_EditBoss;
var() automated moFloatEdit currentWaveDifficulty;
var() automated moNumericEdit currentWave;
var() automated moNumericEdit currentWaveVariant;
var() automated moNumericEdit currentWaveDuration;
var() automated moNumericEdit currentWaveMaxMonsters;
var() automated moNumericEdit currentMaxMonsters;
var() automated moFloatEdit currentMonstersPerPlayerCurve;
var() automated moNumericEdit currentMaxLives;
var() automated moComboBox currentFallbackMonster;
var() automated moComboBox currentWaveMonster[$$__INVPRO_MAX_WAVE_MONSTERS__$$];
var() automated moEditBox currentWaveName;
var() automated moEditBox currentWaveSubName;
var() automated moSlider currentWaveColourR;
var() automated moSlider currentWaveColourG;
var() automated moSlider currentWaveColourB;
var() automated GUILabel currentWaveColour;
var() bool bUnsavedChanges;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i, H;

    Super.InitComponent(MyController, MyOwner);
    b_OK.WinWidth = default.b_OK.WinWidth;
    b_OK.WinHeight = default.b_OK.WinHeight;
    b_OK.WinLeft = default.b_OK.WinLeft;
    b_OK.WinTop = default.b_OK.WinTop;
    b_Cancel.WinWidth = default.b_Cancel.WinWidth;
    b_Cancel.WinHeight = default.b_Cancel.WinHeight;
    b_Cancel.WinLeft = default.b_Cancel.WinLeft;
    b_Cancel.WinTop = default.b_Cancel.WinTop;
    currentFallbackMonster.MyComboBox.MaxVisibleItems = 20;
    currentFallbackMonster.MyComboBox.Edit.FontScale = FNS_Small;
    currentFallbackMonster.StandardHeight = 0.030;
    sb_Main.Caption = "Wave Configuration";
    sb_Main.bScaleToParent = true;
    sb_Main.WinWidth = 0.9482810;
    sb_Main.WinHeight = 0.9189390;
    sb_Main.WinLeft = 0.0253520;
    sb_Main.WinTop = 0.0451610;
    t_WindowTitle.Caption = "InvasionPro: Wave Configuration";

   for(i = 0; i < class'InvasionProMonsterTable'.default.MonsterTable.Length; i++)
    {
        currentFallbackMonster.AddItem(class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterName);
    }

   for(i = 0; i < $$__INVPRO_MAX_WAVE_MONSTERS__$$; i++)
    {
        currentWaveMonster[i].StandardHeight = 0.040;
        currentWaveMonster[i].MyComboBox.MaxVisibleItems = 15;
    }

   for(i = 0; i < $$__INVPRO_MAX_WAVE_MONSTERS__$$; i++)
    {
       for(h = 0; h < class'InvasionProMonsterTable'.default.MonsterTable.Length; h++)
        {
            if(class'InvasionProMonsterTable'.default.MonsterTable[H].MonsterName != "")
            {
                currentWaveMonster[i].AddItem(class'InvasionProMonsterTable'.default.MonsterTable[h].MonsterName);
               continue;
            }
            currentWaveMonster[i].SetText("None");
        }
    }
    currentWave.SetValue(0);
    ActiveWave = currentWave.GetValue();
    RefreshWave();
}

function bool InternalDraw(Canvas Canvas)
{
    local Color TestColor;

    if(Canvas != none)
    {
        TestColor.R = currentWaveColourR.GetValue();
        TestColor.G = currentWaveColourG.GetValue();
        TestColor.B = currentWaveColourB.GetValue();
        TestColor.A = 255;
        currentWaveColour.TextColor = TestColor;
        currentWaveColour.FocusedTextColor = TestColor;
    }
    return false;
}

function bool ExitWave(GUIComponent Sender)
{
    if(bUnsavedChanges)
    {
        Controller.OpenMenu("TURInvPro.InvasionProWaveUnsavedConfirmationMenu");
        InvasionProWaveUnsavedConfirmationMenu(Controller.TopPage()).WaveConfigMenu = self;
        InvasionProWaveUnsavedConfirmationMenu(Controller.TopPage()).bCloseWaveConfig = true;
        InvasionProWaveUnsavedConfirmationMenu(Controller.TopPage()).Init();
        return false;
    }
    Controller.CloseMenu(false);
    return true;
}

function bool InternalOnClick(GUIComponent Sender)
{
    if(bUnsavedChanges)
    {
        Controller.OpenMenu("TURInvPro.InvasionProWaveUnsavedConfirmationMenu");
        InvasionProWaveUnsavedConfirmationMenu(Controller.TopPage()).WaveConfigMenu = self;
        InvasionProWaveUnsavedConfirmationMenu(Controller.TopPage()).bCloseWaveConfig = true;
        InvasionProWaveUnsavedConfirmationMenu(Controller.TopPage()).Init();
        return false;
    }
    Controller.CloseMenu(false);
    return true;
}

function InternalOnChange(GUIComponent Sender)
{
    if(Sender == currentbOverrideBoss)
    {
        if(currentbOverrideBoss.IsChecked())
        {
            b_EditBoss.EnableMe();
        }
        else
        {
            b_EditBoss.DisableMe();
        }
    }
    if(Sender != currentWave)
    {
        bUnsavedChanges = true;
    }
    else
    {
        if(bUnsavedChanges)
        {
            Controller.OpenMenu("TURInvPro.InvasionProWaveUnsavedConfirmationMenu");
            InvasionProWaveUnsavedConfirmationMenu(Controller.TopPage()).WaveConfigMenu = self;
            InvasionProWaveUnsavedConfirmationMenu(Controller.TopPage()).Init();
            return;
        }
        else
        {
            if(Sender == currentWave)
            {
                ActiveWave = currentWave.GetValue();
                RefreshWave();
                return;
            }
        }
    }
}

function DiscardChanges()
{
    ActiveWave = currentWave.GetValue();
    RefreshWave();
}

function bool ClearWave(GUIComponent Sender)
{
    local int i;

    ActiveWave = currentWave.GetValue();
   for(i = 0; i < $$__INVPRO_MAX_WAVE_MONSTERS__$$; i++)
    {
        currentWaveMonster[i].SetText("None");
    }
    return true;
}

function bool RandomWave(GUIComponent Sender)
{
    local int i;

    ActiveWave = currentWave.GetValue();

   for(i = 0; i < $$__INVPRO_MAX_WAVE_MONSTERS__$$; i++)
    {
        currentWaveMonster[i].SetText(RandomMonster());
    }
    return true;
}

function bool DefaultWave(GUIComponent Sender)
{
    local int i;

    ActiveWave = currentWave.GetValue();
    currentWaveName.SetText(class'InvasionProDefaultWaves'.default.Waves[ActiveWave].WaveName);
    currentWaveSubName.SetText(class'InvasionProDefaultWaves'.default.Waves[ActiveWave].WaveSubName);
    currentWaveVariant.SetComponentValue(string(class'InvasionProDefaultWaves'.default.Waves[ActiveWave].WaveVariant));
    currentWaveDuration.SetComponentValue(string(class'InvasionProDefaultWaves'.default.Waves[ActiveWave].WaveDuration));
    currentWaveDifficulty.SetComponentValue(string(class'InvasionProDefaultWaves'.default.Waves[ActiveWave].WaveDifficulty));
    currentWaveMaxMonsters.SetComponentValue(string(class'InvasionProDefaultWaves'.default.Waves[ActiveWave].WaveMaxMonsters));
    currentFallbackMonster.SetText(class'InvasionProDefaultWaves'.default.Waves[ActiveWave].WaveFallbackMonster);
    currentMaxLives.SetComponentValue(string(class'InvasionProDefaultWaves'.default.Waves[ActiveWave].MaxLives));
    currentWaveColourR.SetComponentValue(string(class'InvasionProDefaultWaves'.default.Waves[ActiveWave].WaveDrawColour.R));
    currentWaveColourG.SetComponentValue(string(class'InvasionProDefaultWaves'.default.Waves[ActiveWave].WaveDrawColour.G));
    currentWaveColourB.SetComponentValue(string(class'InvasionProDefaultWaves'.default.Waves[ActiveWave].WaveDrawColour.B));
    currentMaxMonsters.SetComponentValue(string(class'InvasionProDefaultWaves'.default.Waves[ActiveWave].MaxMonsters));
    currentMonstersPerPlayerCurve.SetComponentValue(string(class'InvasionProDefaultWaves'.default.Waves[ActiveWave].MonstersPerPlayerCurve));

   for(i = 0; i < $$__INVPRO_MAX_WAVE_MONSTERS__$$; i++)
    {
        if(class'InvasionProDefaultWaves'.default.Waves[ActiveWave].Monsters[i] != "")
        {
            currentWaveMonster[i].SetText(class'InvasionProDefaultWaves'.default.Waves[ActiveWave].Monsters[i]);
           continue;
        }
        currentWaveMonster[i].SetText("None");
    }
    return true;
}

function string RandomMonster()
{
    local string LuckyMonster;
    local int i;

    i = Max(1, Rand(class'InvasionProMonsterTable'.default.MonsterTable.Length));
    LuckyMonster = class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterName;
    return LuckyMonster;
}

function bool EditBoss(GUIComponent Sender)
{
    if(ActiveWave >= class'InvasionProConfigs'.default.WaveBossTable.Length)
    {
        class'InvasionProConfigs'.default.WaveBossTable.Length = ActiveWave + 1;
    }
    Controller.OpenMenu("TURInvPro.InvasionProBossConfig");
    InvasionProBossConfig(Controller.TopPage()).WaveID = ActiveWave;
    InvasionProBossConfig(Controller.TopPage()).Init();
    return true;
}

function bool SaveWave(GUIComponent Sender)
{
    local int i;

    ActiveWave = currentWave.GetValue();
    class'InvasionProConfigs'.default.Waves[ActiveWave].WaveName = currentWaveName.GetText();
    class'InvasionProConfigs'.default.Waves[ActiveWave].WaveSubName = currentWaveSubName.GetText();
    class'InvasionProConfigs'.default.Waves[ActiveWave].WaveVariant = currentWaveVariant.GetValue();
    class'InvasionProConfigs'.default.Waves[ActiveWave].WaveDuration = currentWaveDuration.GetValue();
    class'InvasionProConfigs'.default.Waves[ActiveWave].WaveDifficulty = currentWaveDifficulty.GetValue();
    class'InvasionProConfigs'.default.Waves[ActiveWave].WaveMaxMonsters = currentWaveMaxMonsters.GetValue();
    class'InvasionProConfigs'.default.Waves[ActiveWave].MaxMonsters = currentMaxMonsters.GetValue();
    class'InvasionProConfigs'.default.Waves[ActiveWave].MonstersPerPlayerCurve = currentMonstersPerPlayerCurve.GetValue();
    class'InvasionProConfigs'.default.Waves[ActiveWave].WaveFallbackMonster = currentFallbackMonster.GetText();
    class'InvasionProConfigs'.default.Waves[ActiveWave].MaxLives = currentMaxLives.GetValue();
    class'InvasionProConfigs'.default.Waves[ActiveWave].WaveDrawColour.R = currentWaveColourR.GetValue();
    class'InvasionProConfigs'.default.Waves[ActiveWave].WaveDrawColour.G = currentWaveColourG.GetValue();
    class'InvasionProConfigs'.default.Waves[ActiveWave].WaveDrawColour.B = currentWaveColourB.GetValue();
    class'InvasionProConfigs'.default.Waves[ActiveWave].WaveDrawColour.A = 255;
    class'InvasionProConfigs'.default.Waves[ActiveWave].bOverrideBoss = currentbOverrideBoss.IsChecked();

   for(i = 0; i < $$__INVPRO_MAX_WAVE_MONSTERS__$$; i++)
    {
        class'InvasionProConfigs'.default.Waves[ActiveWave].Monsters[i] = currentWaveMonster[i].GetText();
    }
    class'InvasionProConfigs'.static.StaticSaveConfig();
    bUnsavedChanges = false;
    return true;
}

function RefreshWave()
{
    local int i;

    ActiveWave = currentWave.GetValue();
    if(ActiveWave + 1 > class'InvasionProConfigs'.default.Waves.Length)
    {
        class'InvasionProConfigs'.default.Waves.Insert(class'InvasionProConfigs'.default.Waves.Length, 1);
        class'InvasionProConfigs'.static.StaticSaveConfig();
    }
    currentWaveName.SetText(class'InvasionProConfigs'.default.Waves[ActiveWave].WaveName);
    currentWaveSubName.SetText(class'InvasionProConfigs'.default.Waves[ActiveWave].WaveSubName);
    currentWaveVariant.SetComponentValue(string(class'InvasionProConfigs'.default.Waves[ActiveWave].WaveVariant));
    currentWaveDuration.SetComponentValue(string(class'InvasionProConfigs'.default.Waves[ActiveWave].WaveDuration));
    currentWaveDifficulty.SetComponentValue(string(class'InvasionProConfigs'.default.Waves[ActiveWave].WaveDifficulty));
    currentWaveMaxMonsters.SetComponentValue(string(class'InvasionProConfigs'.default.Waves[ActiveWave].WaveMaxMonsters));
    currentMaxMonsters.SetComponentValue(string(class'InvasionProConfigs'.default.Waves[ActiveWave].MaxMonsters));
    currentMonstersPerPlayerCurve.SetComponentValue(string(class'InvasionProConfigs'.default.Waves[ActiveWave].MonstersPerPlayerCurve));
    currentFallbackMonster.SetText(class'InvasionProConfigs'.default.Waves[ActiveWave].WaveFallbackMonster);
    currentMaxLives.SetComponentValue(string(class'InvasionProConfigs'.default.Waves[ActiveWave].MaxLives));
    currentWaveColourR.SetComponentValue(string(class'InvasionProConfigs'.default.Waves[ActiveWave].WaveDrawColour.R));
    currentWaveColourG.SetComponentValue(string(class'InvasionProConfigs'.default.Waves[ActiveWave].WaveDrawColour.G));
    currentWaveColourB.SetComponentValue(string(class'InvasionProConfigs'.default.Waves[ActiveWave].WaveDrawColour.B));
    currentbOverrideBoss.SetComponentValue(string(class'InvasionProConfigs'.default.Waves[ActiveWave].bOverrideBoss));

   for(i = 0; i < $$__INVPRO_MAX_WAVE_MONSTERS__$$; i++)
    {
        if(class'InvasionProConfigs'.default.Waves[ActiveWave].Monsters[i] != "")
        {
            currentWaveMonster[i].SetText(class'InvasionProConfigs'.default.Waves[ActiveWave].Monsters[i]);
           continue;
        }
        currentWaveMonster[i].SetText("None");
    }
    if(currentbOverrideBoss.IsChecked())
    {
        b_EditBoss.EnableMe();
    }
    else
    {
        b_EditBoss.DisableMe();
    }
    bUnsavedChanges = false;
}

function bool CopyWave(GUIComponent Sender)
{
    local int i;

    class'InvasionProCopyPaste'.default.ClipBoardWaveDrawColour.R = currentWaveColourR.GetValue();
    class'InvasionProCopyPaste'.default.ClipBoardWaveDrawColour.G = currentWaveColourG.GetValue();
    class'InvasionProCopyPaste'.default.ClipBoardWaveDrawColour.B = currentWaveColourB.GetValue();
    class'InvasionProCopyPaste'.default.ClipBoardWaveVariant = currentWaveVariant.GetValue();
    class'InvasionProCopyPaste'.default.ClipBoardWaveDuration = currentWaveDuration.GetValue();
    class'InvasionProCopyPaste'.default.ClipBoardWaveDifficulty = currentWaveDifficulty.GetValue();
    class'InvasionProCopyPaste'.default.ClipBoardWaveMaxMonsters = currentWaveMaxMonsters.GetValue();
    class'InvasionProCopyPaste'.default.ClipBoardMaxMonsters = currentMaxMonsters.GetValue();
    class'InvasionProCopyPaste'.default.ClipBoardMonstersPerPlayerCurve = currentMonstersPerPlayerCurve.GetValue();
    class'InvasionProCopyPaste'.default.ClipBoardMaxLives = currentMaxLives.GetValue();
    class'InvasionProCopyPaste'.default.ClipBoardWaveFallbackMonster = currentFallbackMonster.GetText();
    class'InvasionProCopyPaste'.default.ClipboardbOverrideBoss = currentbOverrideBoss.IsChecked();

   for(i = 0; i < $$__INVPRO_MAX_WAVE_MONSTERS__$$; i++)
    {
        class'InvasionProCopyPaste'.default.ClipBoardMonsters[i] = currentWaveMonster[i].GetText();
    }
    class'InvasionProCopyPaste'.static.StaticSaveConfig();
    return true;
}

function bool PasteWave(GUIComponent Sender)
{
    local int i;

    currentWaveVariant.SetComponentValue(string(class'InvasionProCopyPaste'.default.ClipBoardWaveVariant));
    currentWaveDuration.SetComponentValue(string(class'InvasionProCopyPaste'.default.ClipBoardWaveDuration));
    currentWaveDifficulty.SetComponentValue(string(class'InvasionProCopyPaste'.default.ClipBoardWaveDifficulty));
    currentWaveMaxMonsters.SetComponentValue(string(class'InvasionProCopyPaste'.default.ClipBoardWaveMaxMonsters));
    currentMaxMonsters.SetComponentValue(string(class'InvasionProCopyPaste'.default.ClipBoardMaxMonsters));
    currentMonstersPerPlayerCurve.SetComponentValue(string(class'InvasionProCopyPaste'.default.ClipBoardMonstersPerPlayerCurve));
    currentFallbackMonster.SetText(class'InvasionProCopyPaste'.default.ClipBoardWaveFallbackMonster);
    currentMaxLives.SetComponentValue(string(class'InvasionProCopyPaste'.default.ClipBoardMaxLives));
    currentWaveColourR.SetComponentValue(string(class'InvasionProCopyPaste'.default.ClipBoardWaveDrawColour.R));
    currentWaveColourG.SetComponentValue(string(class'InvasionProCopyPaste'.default.ClipBoardWaveDrawColour.G));
    currentWaveColourB.SetComponentValue(string(class'InvasionProCopyPaste'.default.ClipBoardWaveDrawColour.B));

   for(i = 0; i < $$__INVPRO_MAX_WAVE_MONSTERS__$$; i++)
    {
        currentWaveMonster[i].SetText(class'InvasionProCopyPaste'.default.ClipBoardMonsters[i]);
    }
    return true;
}

defaultproperties
{
    Begin Object Name=CopyButton class=GUIButton
        Caption="Copy"
        Hint="Copy the current wave settings to the clipboard, they can then be pasted onto another wave."
        WinTop=0.9101020
        WinLeft=0.4504890
        WinWidth=0.0967580
        WinHeight=0.0438010
        TabOrder=50
        bBoundToParent=true
        bScaleToParent=true
        OnClick=CopyWave
    End Object
    b_Copy=GUIButton'CopyButton'

    Begin Object Name=PasteButton class=GUIButton
        Caption="Paste"
        Hint="Paste the wave settings that are currently on the clipboard into the current wave."
        WinTop=0.9101020
        WinLeft=0.5542380
        WinWidth=0.0967580
        WinHeight=0.0438010
        TabOrder=51
        bBoundToParent=true
        bScaleToParent=true
        OnClick=PasteWave
    End Object
    b_Paste=GUIButton'PasteButton'

    Begin Object Name=ResetButton class=GUIButton
        Caption="Clear All"
        Hint="remove all wave monsters."
        WinTop=0.9101020
        WinLeft=0.3224830
        WinWidth=0.1217580
        WinHeight=0.0438010
        TabOrder=49
        bBoundToParent=true
        bScaleToParent=true
        OnClick=ClearWave
        OnChange=InternalOnChange
    End Object
    b_Reset=GUIButton'ResetButton'

    Begin Object Name=RandomButton class=GUIButton
        Caption="Random"
        Hint="random monsters will be chosen for the wave."
        WinTop=0.9101020
        WinLeft=0.1974890
        WinWidth=0.1217580
        WinHeight=0.0438010
        TabOrder=48
        bBoundToParent=true
        bScaleToParent=true
        OnClick=RandomWave
        OnChange=InternalOnChange
    End Object
    b_Random=GUIButton'RandomButton'

    Begin Object Name=LockedDefaultButton class=GUIButton
        Caption="Default"
        Hint="Set the default for this wave."
        WinTop=0.9101020
        WinLeft=0.0734270
        WinWidth=0.1217580
        WinHeight=0.0438010
        TabOrder=47
        bBoundToParent=true
        bScaleToParent=true
        OnClick=DefaultWave
        OnChange=InternalOnChange
    End Object
    b_Default=GUIButton'LockedDefaultButton'

    Begin Object Name=bOverrideBoss class=moCheckBox
        CaptionWidth=0.50
        Caption="Override Boss"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Toggles whether this wave should override the boss for the global boss table."
        WinTop=0.1075970
        WinLeft=0.3364510
        WinWidth=0.2337730
        WinHeight=0.0333330
        TabOrder=6
        bBoundToParent=true
        OnChange=InternalOnChange
    End Object
    currentbOverrideBoss=moCheckBox'bOverrideBoss'

    Begin Object Name=LockedEditBossButton class=GUIButton
        Caption="Edit Boss"
        Hint="Edit the boss entry for this wave."
        WinTop=0.1624580
        WinLeft=0.3364510
        WinWidth=0.2337730
        WinHeight=0.0438010
        TabOrder=47
        bBoundToParent=true
        bScaleToParent=true
        OnClick=EditBoss
        OnChange=InternalOnChange
    End Object
    b_EditBoss=GUIButton'LockedEditBossButton'

    Begin Object Name=WaveDifficulty class=moFloatEdit
        MinValue=0.0
        MaxValue=4.0
        Step=0.050
        CaptionWidth=1.0
        ComponentWidth=0.3050
        Caption="Wave Difficulty"
        OnCreateComponent=InternalOnCreateComponent
        Hint="How difficult this wave should be."
        WinTop=0.2737540
        WinLeft=0.0510840
        WinWidth=0.2774890
        WinHeight=0.0333330
        TabOrder=8
        bBoundToParent=true
        bScaleToParent=true
        OnChange=InternalOnChange
    End Object
    currentWaveDifficulty=moFloatEdit'WaveDifficulty'

    Begin Object Name=WaveNumber class=moNumericEdit
        MinValue=0
        MaxValue=999
        ComponentWidth=0.250
        Caption="Wave No"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select the wave you'd like to configure."
        WinTop=0.1075970
        WinLeft=0.0510840
        WinWidth=0.2774890
        WinHeight=0.0333330
        RenderWeight=0.70
        TabOrder=0
        bBoundToParent=true
        bScaleToParent=true
        OnChange=InternalOnChange
    End Object
    currentWave=moNumericEdit'WaveNumber'

    Begin Object Name=WaveVariant class=moNumericEdit
        MinValue=0
        MaxValue=1000
        CaptionWidth=1.0
        ComponentWidth=0.250
        Caption="Wave Variant"
        OnCreateComponent=InternalOnCreateComponent
        Hint="The wave number this wave can appear for when the wave table is generated at map startup. If zero, this wave is disabled."
        WinTop=0.1624580
        WinLeft=0.0510840
        WinWidth=0.2774890
        WinHeight=0.0333330
        RenderWeight=0.70
        TabOrder=12
        bBoundToParent=true
        bScaleToParent=true
        OnChange=InternalOnChange
    End Object
    currentWaveVariant=moNumericEdit'WaveVariant'

    Begin Object Name=WaveDuration class=moNumericEdit
        MinValue=1
        MaxValue=999
        CaptionWidth=1.0
        ComponentWidth=0.3050
        Caption="Wave Duration"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Roughly how long should each wave last (in seconds)."
        WinTop=0.2169520
        WinLeft=0.0510840
        WinWidth=0.2774890
        WinHeight=0.0333330
        RenderWeight=0.70
        TabOrder=7
        bBoundToParent=true
        bScaleToParent=true
        OnChange=InternalOnChange
    End Object
    currentWaveDuration=moNumericEdit'WaveDuration'

    Begin Object Name=WaveMaxMonsters class=moNumericEdit
        MinValue=1
        MaxValue=1000
        CaptionWidth=1.0
        ComponentWidth=0.190
        Caption="Wave Max Monsters"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Maximum number of monsters to spawn this wave."
        WinTop=0.2737540
        WinLeft=0.3364510
        WinWidth=0.2337730
        WinHeight=0.0333330
        RenderWeight=0.70
        TabOrder=12
        bBoundToParent=true
        bScaleToParent=true
        OnChange=InternalOnChange
    End Object
    currentWaveMaxMonsters=moNumericEdit'WaveMaxMonsters'

    Begin Object Name=MaxMonsters class=moNumericEdit
        MinValue=1
        MaxValue=100
        CaptionWidth=1.0
        ComponentWidth=0.3050
        Caption="Max Monsters"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Maximum amount of monsters that may be in the map at one time."
        WinTop=0.2169520
        WinLeft=0.3364510
        WinWidth=0.2337730
        WinHeight=0.0333330
        RenderWeight=0.70
        TabOrder=9
        bBoundToParent=true
        bScaleToParent=true
        OnChange=InternalOnChange
    End Object
    currentMaxMonsters=moNumericEdit'MaxMonsters'

    Begin Object Name=MonstersPerPlayerCurve class=moFloatEdit
        MinValue=0.0
        MaxValue=5.0
        Step=0.050
        CaptionWidth=1.0
        ComponentWidth=0.3050
        Caption="Monsters Per Player Curve"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Multiplier for the logarithmic curve to determine the max amount of monsters to spawn, given the number of active players. Set to zero to disable balancing monsters per player for this wave."
        WinTop=0.2737540
        WinLeft=0.5774330
        WinWidth=0.373480
        WinHeight=0.0333330
        RenderWeight=0.70
        TabOrder=9
        bBoundToParent=true
        bScaleToParent=true
        OnChange=InternalOnChange
    End Object
    currentMonstersPerPlayerCurve=moFloatEdit'MonstersPerPlayerCurve'

    Begin Object Name=MaxLives class=moNumericEdit
        MinValue=1
        MaxValue=999
        CaptionWidth=1.0
        ComponentWidth=0.190
        Caption="Max Lives"
        OnCreateComponent=InternalOnCreateComponent
        Hint="The number of lives player have on this wave."
        WinTop=0.3288970
        WinLeft=0.0510840
        WinWidth=0.2774890
        WinHeight=0.2337730
        RenderWeight=0.70
        TabOrder=13
        bBoundToParent=true
        bScaleToParent=true
        OnChange=InternalOnChange
    End Object
    currentMaxLives=moNumericEdit'MaxLives'

    Begin Object Name=FallbackMonster class=moComboBox
        bReadOnly=true
        CaptionWidth=0.250
        Caption="Fallback Monster"
        OnCreateComponent=InternalOnCreateComponent
        Hint="If monsters cannot spawn; this fallback monster can attempt to take their place."
        WinTop=0.2169520
        WinLeft=0.5769930
        WinWidth=0.373480
        WinHeight=0.0333330
        TabOrder=11
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentFallbackMonster=moComboBox'FallbackMonster'

    Begin Object Name=MonsterNum01 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.3642390
        WinLeft=0.0683880
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=17
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[0]=moComboBox'MonsterNum01'

    Begin Object Name=MonsterNum02 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.4105060
        WinLeft=0.0683880
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=18
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[1]=moComboBox'MonsterNum02'

    Begin Object Name=MonsterNum03 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.4567730
        WinLeft=0.0683880
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=19
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[2]=moComboBox'MonsterNum03'

    Begin Object Name=MonsterNum04 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.503040
        WinLeft=0.0683880
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=20
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[3]=moComboBox'MonsterNum04'

    Begin Object Name=MonsterNum05 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.5493070
        WinLeft=0.0683880
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=21
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[4]=moComboBox'MonsterNum05'

    Begin Object Name=MonsterNum06 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.5955740
        WinLeft=0.0683880
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=22
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[5]=moComboBox'MonsterNum06'

    Begin Object Name=MonsterNum07 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.6418410
        WinLeft=0.0683880
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=23
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[6]=moComboBox'MonsterNum07'

    Begin Object Name=MonsterNum08 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.6881080
        WinLeft=0.0683880
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=24
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[7]=moComboBox'MonsterNum08'

    Begin Object Name=MonsterNum09 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.7343750
        WinLeft=0.0683880
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=25
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[8]=moComboBox'MonsterNum09'

    Begin Object Name=MonsterNum10 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.7806420
        WinLeft=0.0683880
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=26
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[9]=moComboBox'MonsterNum10'

    Begin Object Name=MonsterNum11 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.3642390
        WinLeft=0.3822080
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=27
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[10]=moComboBox'MonsterNum11'

    Begin Object Name=MonsterNum12 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.4105060
        WinLeft=0.3822080
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=28
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[11]=moComboBox'MonsterNum12'

    Begin Object Name=MonsterNum13 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.4567730
        WinLeft=0.3822080
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=29
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[12]=moComboBox'MonsterNum13'

    Begin Object Name=MonsterNum14 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.503040
        WinLeft=0.3822080
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=30
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[13]=moComboBox'MonsterNum14'

    Begin Object Name=MonsterNum15 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.5493070
        WinLeft=0.3822080
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=31
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[14]=moComboBox'MonsterNum15'

    Begin Object Name=MonsterNum16 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.5955740
        WinLeft=0.3822080
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=32
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[15]=moComboBox'MonsterNum16'

    Begin Object Name=MonsterNum17 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.6418410
        WinLeft=0.3822080
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=33
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[16]=moComboBox'MonsterNum17'

    Begin Object Name=MonsterNum18 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.6881080
        WinLeft=0.3822080
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=34
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[17]=moComboBox'MonsterNum18'

    Begin Object Name=MonsterNum19 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.7343750
        WinLeft=0.3822080
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=35
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[18]=moComboBox'MonsterNum19'

    Begin Object Name=MonsterNum20 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.7806420
        WinLeft=0.3822080
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=36
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[19]=moComboBox'MonsterNum20'

    Begin Object Name=MonsterNum21 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.3642390
        WinLeft=0.7169320
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=37
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[20]=moComboBox'MonsterNum21'

    Begin Object Name=MonsterNum22 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.4105060
        WinLeft=0.7169320
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=38
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[21]=moComboBox'MonsterNum22'

    Begin Object Name=MonsterNum23 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.4567730
        WinLeft=0.7169320
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=39
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[22]=moComboBox'MonsterNum23'

    Begin Object Name=MonsterNum24 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.503040
        WinLeft=0.7169320
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=40
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[23]=moComboBox'MonsterNum24'

    Begin Object Name=MonsterNum25 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.5493070
        WinLeft=0.7169320
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=41
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[24]=moComboBox'MonsterNum25'

    Begin Object Name=MonsterNum26 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.5955740
        WinLeft=0.7169320
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=42
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[25]=moComboBox'MonsterNum26'

    Begin Object Name=MonsterNum27 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.6418410
        WinLeft=0.7169320
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=43
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[26]=moComboBox'MonsterNum27'

    Begin Object Name=MonsterNum28 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.6881080
        WinLeft=0.7169320
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=44
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[27]=moComboBox'MonsterNum28'

    Begin Object Name=MonsterNum29 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.7343750
        WinLeft=0.7169320
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=45
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[28]=moComboBox'MonsterNum29'

    Begin Object Name=MonsterNum30 class=moComboBox
        bReadOnly=true
        bVerticalLayout=true
        ComponentJustification=0
        OnCreateComponent=InternalOnCreateComponent
        Hint="Select a monster that may spawn on this wave."
        WinTop=0.7806420
        WinLeft=0.7169320
        WinWidth=0.2315660
        WinHeight=0.0485250
        TabOrder=46
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveMonster[29]=moComboBox'MonsterNum30'

    Begin Object Name=WaveName class=moEditBox
        CaptionWidth=1.0
        ComponentWidth=0.70
        Caption="Wave Name"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Input the desired name for this wave."
        WinTop=0.104180
        WinLeft=0.5764680
        WinWidth=0.373480
        WinHeight=0.0444440
        TabOrder=10
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveName=moEditBox'WaveName'

    Begin Object Name=WaveSubName class=moEditBox
        CaptionWidth=1.0
        ComponentWidth=0.70
        Caption="Wave Sub-Name"
        OnCreateComponent=InternalOnCreateComponent
        Hint="Input the desired sub-name for this wave."
        WinTop=0.1624580
        WinLeft=0.5764680
        WinWidth=0.373480
        WinHeight=0.0444440
        TabOrder=10
        bBoundToParent=true
        bScaleToParent=true
        StandardHeight=0.040
        OnChange=InternalOnChange
    End Object
    currentWaveSubName=moEditBox'WaveSubName'

    Begin Object Name=WaveColourR class=moSlider
        MaxValue=255.0
        bIntSlider=true
        SliderCaptionStyleName="TextLabel"
        ComponentWidth=0.850
        Caption="R"
        OnCreateComponent=InternalOnCreateComponent
        Hint="How much Red for the wave name color."
        WinTop=0.3331220
        WinLeft=0.5218840
        WinWidth=0.1280650
        WinHeight=0.0333330
        TabOrder=14
        bBoundToParent=true
        bScaleToParent=true
        OnChange=InternalOnChange
    End Object
    currentWaveColourR=moSlider'WaveColourR'

    Begin Object Name=WaveColourG class=moSlider
        MaxValue=255.0
        bIntSlider=true
        SliderCaptionStyleName="TextLabel"
        ComponentWidth=0.850
        Caption="G"
        OnCreateComponent=InternalOnCreateComponent
        Hint="How much Green for the wave name color."
        WinTop=0.3331220
        WinLeft=0.6711730
        WinWidth=0.1280650
        WinHeight=0.0333330
        TabOrder=15
        bBoundToParent=true
        bScaleToParent=true
        OnChange=InternalOnChange
    End Object
    currentWaveColourG=moSlider'WaveColourG'

    Begin Object Name=WaveColourB class=moSlider
        MaxValue=255.0
        bIntSlider=true
        SliderCaptionStyleName="TextLabel"
        ComponentWidth=0.850
        Caption="B"
        OnCreateComponent=InternalOnCreateComponent
        Hint="How much Blue for the wave name color."
        WinTop=0.3331220
        WinLeft=0.8216470
        WinWidth=0.1280650
        WinHeight=0.0333330
        TabOrder=16
        bBoundToParent=true
        bScaleToParent=true
        OnChange=InternalOnChange
    End Object
    currentWaveColourB=moSlider'WaveColourB'

    Begin Object Name=WaveColour class=GUILabel
        Caption="Wave Name Color"
        WinTop=0.3288970
        WinLeft=0.3364510
        WinWidth=0.1819760
        WinHeight=0.0370370
        OnDraw=InternalDraw
        OnChange=InternalOnChange
    End Object
    currentWaveColour=GUILabel'WaveColour'

    Begin Object Name=InternalFrameImage class=AltSectionBackground
        WinTop=0.0394390
        WinLeft=0.0409770
        WinWidth=0.9133230
        WinHeight=0.924130
        bScaleToParent=true
    End Object
    sb_Main=AltSectionBackground'InternalFrameImage'

    Begin Object Name=LockedCancelButton class=GUIButton
        Caption="Close"
        Hint="Close this window."
        WinTop=0.9101020
        WinLeft=0.803740
        WinWidth=0.1217580
        WinHeight=0.0438010
        TabOrder=53
        bBoundToParent=true
        bScaleToParent=true
        OnClick=ExitWave
        OnChange=InternalOnChange
    End Object
    b_Cancel=GUIButton'LockedCancelButton'

    Begin Object Name=LockedOKButton class=GUIButton
        Caption="Save Wave"
        Hint="Save the current wave."
        WinTop=0.9101020
        WinLeft=0.658740
        WinWidth=0.1417580
        WinHeight=0.0438010
        TabOrder=52
        bBoundToParent=true
        bScaleToParent=true
        OnClick=SaveWave
    End Object
    b_OK=GUIButton'LockedOKButton'

    DefaultLeft=0.0
    DefaultTop=0.0817490
    DefaultWidth=1.0
    DefaultHeight=0.90
    bRequire640x480=true
    WinTop=0.050
    WinLeft=0.0
    WinWidth=1.0
    WinHeight=0.90
    bScaleToParent=true
}
