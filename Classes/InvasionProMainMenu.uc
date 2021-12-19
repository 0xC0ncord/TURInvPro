//=============================================================================
// InvasionProMainMenu.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//==========================================================
//InvasionProMainMenu Copyright � Shaun Goeppinger 2012
//==========================================================
class InvasionProMainMenu extends GUICustomPropertyPage;

var() Automated GUIMultiOptionListBox currentScrollContainer;

var() Automated moEditBox currentMonsterStartTag;
var() Automated moEditBox currentPlayerStartTag;
var() Automated moEditBox currentCustomGameTypePrefix;
var() Automated moSlider currentWaveCountDownColourR;
var() Automated moSlider currentWaveCountDownColourG;
var() Automated moSlider currentWaveCountDownColourB;
var() Automated GUIListSpacer currentWaveCountDownColour;
var() color AuraLabelColor;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local bool bTemp;
    local GUIMenuOption MenuOption;

    Super.InitComponent(MyController, MyOwner);

    //resize main window
    sb_Main.Caption = "InvasionPro Configuration";
    sb_Main.bScaleToParent=true;
    sb_Main.WinWidth=0.948281;
    sb_Main.WinHeight=0.918939;
    sb_Main.WinLeft=0.025352;
    sb_Main.WinTop=0.045161;
    //sb_Main.ManageComponent(currentScrollContainer);

    t_WindowTitle.Caption = "";

    //resize ok/defaults button
    b_OK.WinWidth = default.b_OK.WinWidth;
    b_OK.WinHeight = default.b_OK.WinHeight;
    b_OK.WinLeft = default.b_OK.WinLeft;
    b_OK.WinTop = default.b_OK.WinTop;

    //resize save/close button
    b_Cancel.WinWidth = default.b_Cancel.WinWidth;
    b_Cancel.WinHeight = default.b_Cancel.WinHeight;
    b_Cancel.WinLeft = default.b_Cancel.WinLeft;
    b_Cancel.WinTop = default.b_Cancel.WinTop;

    bTemp = Controller.bCurMenuInitialized;
    Controller.bCurMenuInitialized = False;
    currentScrollContainer.List.ColumnWidth = 0.995;
    currentScrollContainer.List.NumColumns = 2;
    MenuOption = currentScrollContainer.List.AddItem( "XInterface.GUIListHeader",, "General" );
    currentScrollContainer.List.AddItem( "XInterface.GUIListHeader",, "" );
    if ( MenuOption != None )
    {
        MenuOption.bAutoSizeCaption = True;
        MenuOption.MyLabel.TextAlign = TXTA_Left;
        MenuOption.bStandardized = true;
    }

    currentMonsterStartTag = moEditBox(currentScrollContainer.List.AddItem("XInterface.moEditBox", ,"Monster Spawn Tag",true));
    currentMonsterStartTag.ToolTip.SetTip("Input the tag of the navigation points you wish monsters to spawn at (if the nodes exist within the map). Allows you to specify exactly where monsters should spawn.");
    currentPlayerStartTag = moEditBox(currentScrollContainer.List.AddItem("XInterface.moEditBox", ,"Player Spawn Tag",true));
    currentPlayerStartTag.ToolTip.SetTip("Input the tag of the navigation points you wish players to spawn at (if the nodes exist within the map). Allows you to specify exactly where players should spawn.");
    currentCustomGameTypePrefix = moEditBox(currentScrollContainer.List.AddItem("XInterface.moEditBox", ,"Custom Gametype Prefix",true));
    currentCustomGameTypePrefix.ToolTip.SetTip("Input the prefix for a custom gametype you want base spawning to work with.");
    currentScrollContainer.List.AddItem("XInterface.GUIListSpacer");

    currentWaveCountDownColour = GUIListSpacer(currentScrollContainer.List.AddItem("XInterface.GUIListSpacer", ,"Wave Countdown Color",true));
    currentWaveCountDownColour.CaptionWidth = 1;
    currentWaveCountDownColour.MyLabel.OnDraw = InternalDraw;
    currentWaveCountDownColour.MyLabel.Style = None;
    currentWaveCountDownColourR = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Red",true));
    currentWaveCountDownColourR.Setup(0, 255, true);
    currentWaveCountDownColourR.ToolTip.SetTip("How much Red for the wave count down color.");
    currentWaveCountDownColourG = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Green",true));
    currentWaveCountDownColourG.Setup(0, 255, true);
    currentWaveCountDownColourG.ToolTip.SetTip("How much Green for the wave count down color.");
    currentWaveCountDownColourB = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Blue",true));
    currentWaveCountDownColourB.Setup(0, 255, true);
    currentWaveCountDownColourB.ToolTip.SetTip("How much Blue for the wave count down color.");
    MenuOption = currentScrollContainer.List.AddItem( "XInterface.GUIListHeader",, "PET SETTINGS" );
    currentScrollContainer.List.AddItem( "XInterface.GUIListHeader",, "" );
    if ( MenuOption != None )
    {
        MenuOption.bAutoSizeCaption = True;
        MenuOption.MyLabel.TextAlign = TXTA_Left;
        MenuOption.bStandardized = true;
    }

    Controller.bCurMenuInitialized = bTemp;
    SetDefaultComponent(currentWaveCountDownColourR);
    SetDefaultComponent(currentWaveCountDownColourG);
    SetDefaultComponent(currentWaveCountDownColourB);
    SetDefaultComponent(currentMonsterStartTag);
    SetDefaultComponent(currentPlayerStartTag);
    SetDefaultComponent(currentCustomGameTypePrefix);
    currentWaveCountDownColourR.ComponentJustification = TXTA_Left;
    currentWaveCountDownColourR.ComponentWidth = 0.4;
    currentWaveCountDownColourR.CaptionWidth = 0.3;
    currentWaveCountDownColourG.ComponentJustification = TXTA_Left;
    currentWaveCountDownColourG.ComponentWidth = 0.4;
    currentWaveCountDownColourG.CaptionWidth = 0.3;
    currentWaveCountDownColourB.ComponentJustification = TXTA_Left;
    currentWaveCountDownColourB.ComponentWidth = 0.4;
    currentWaveCountDownColourB.CaptionWidth = 0.3;
    UpdateCurrentSettings();
}

function SetDefaultComponent(GUIMenuOption PassedComponent)
{
    PassedComponent.CaptionWidth = 0.8;
    PassedComponent.ComponentWidth = 0.2;
    PassedComponent.ComponentJustification = TXTA_Right;
    PassedComponent.bStandardized = false;
    PassedComponent.bBoundToParent = False;
    PassedComponent.bScaleToParent = False;

   if(PassedComponent.MyLabel != None)
   {
        PassedComponent.MyLabel.TextAlign = TXTA_Left;
   }
}

function bool InternalDraw(Canvas Canvas)
{
    local color TestColor;

    if(Canvas != None)
   {
        TestColor.R = currentWaveCountDownColourR.GetValue();
        TestColor.G = currentWaveCountDownColourG.GetValue();
        TestColor.B = currentWaveCountDownColourB.GetValue();
        TestColor.A = 255;
        currentWaveCountDownColour.MyLabel.TextColor = TestColor;
        currentWaveCountDownColour.MyLabel.FocusedTextColor = TestColor;
   }

   return false;
}

function bool InternalOnClick(GUIComponent Sender)
{
    Controller.CloseMenu(false);
    return true;
}

event Closed(GUIComponent Sender, bool bCancelled)
{
    Super.Closed(Sender, bCancelled);
}

function InternalOnChange(GUIComponent Sender)
{}

function UpdateCurrentSettings()
{
    currentMonsterStartTag.SetComponentValue(class'InvasionPro'.default.MonsterStartTag);
    currentPlayerStartTag.SetComponentValue(class'InvasionPro'.default.PlayerStartTag);
    currentCustomGameTypePrefix.SetComponentValue(class'InvasionPro'.default.CustomGameTypePrefix);
    currentWaveCountDownColourR.SetComponentValue(class'InvasionPro'.default.WaveCountDownColour.R);
    currentWaveCountDownColourG.SetComponentValue(class'InvasionPro'.default.WaveCountDownColour.G);
    currentWaveCountDownColourB.SetComponentValue(class'InvasionPro'.default.WaveCountDownColour.B);
}

function bool DefaultMenu(GUIComponent Sender)
{
    currentWaveCountDownColourR.SetComponentValue(255);
    currentWaveCountDownColourG.SetComponentValue(255);
    currentWaveCountDownColourB.SetComponentValue(0);

    return true;
}

function bool ExitMenu(GUIComponent Sender)
{
    class'InvasionPro'.default.MonsterStartTag = currentMonsterStartTag.GetText();
    class'InvasionPro'.default.PlayerStartTag = currentPlayerStartTag.GetText();
    class'InvasionPro'.default.CustomGameTypePrefix = currentCustomGameTypePrefix.GetText();
    class'InvasionPro'.default.WaveCountDownColour.R = currentWaveCountDownColourR.GetValue();
    class'InvasionPro'.default.WaveCountDownColour.G = currentWaveCountDownColourG.GetValue();
    class'InvasionPro'.default.WaveCountDownColour.B = currentWaveCountDownColourB.GetValue();

    class'InvasionPro'.static.StaticSaveConfig();
    class'InvasionProGameReplicationInfo'.static.StaticSaveConfig();

    Controller.CloseMenu(false);

    return true;
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
    if (GUIMenuOption(NewComp) != None)
    {
        GUIMenuOption(NewComp).CaptionWidth = 0.8;
        GUIMenuOption(NewComp).ComponentWidth = 0.2;
        GUIMenuOption(NewComp).ComponentJustification = TXTA_Right;
        GUIMenuOption(NewComp).bStandardized = True;
        GUIMenuOption(NewComp).bBoundToParent = False;
        GUIMenuOption(NewComp).bScaleToParent = False;
        GUIMenuOption(NewComp).bAutoSizeCaption = True;

        /*
        if (Sender ==  currentScrollContainer)
            currentScrollContainer.InternalOnCreateComponent(NewComp, Sender);
        */
    }

    if (currentScrollContainer == Sender)
    {
        if(currentScrollContainer.List != None)
        {
            currentScrollContainer.List.ColumnWidth = 0.45;
            currentScrollContainer.List.bVerticalLayout = true;
            currentScrollContainer.List.bHotTrack = true;
        }
    }

    Super.InternalOnCreateComponent(NewComp,Sender);
}

defaultproperties
{
    Begin Object Class=GUIMultiOptionListBox Name=MyRulesList
        NumColumns=2
        bVisibleWhenEmpty=True
        OnCreateComponent=InvasionProMainMenu.InternalOnCreateComponent
        WinTop=0.096008
        WinLeft=0.041440
        WinWidth=0.921549
        WinHeight=0.817127
        bBoundToParent=True
        bScaleToParent=True
    End Object
    currentScrollContainer=GUIMultiOptionListBox'TURInvPro.InvasionProMainMenu.MyRulesList'

    AuraLabelColor=(G=255,A=255)
    Begin Object Class=GUIButton Name=LockedCancelButton
        Caption="Ok"
        Hint="Close this menu."
        WinTop=0.909098
        WinLeft=0.747843
        WinWidth=0.171970
        WinHeight=0.048624
        TabOrder=1
        bBoundToParent=True
        bScaleToParent=True
        OnClick=InvasionProMainMenu.ExitMenu
        OnKeyEvent=LockedCancelButton.InternalOnKeyEvent
    End Object
    b_Cancel=GUIButton'TURInvPro.InvasionProMainMenu.LockedCancelButton'

    Begin Object Class=GUIButton Name=LockedOKButton
        Caption="Defaults"
        Hint="Set everything to default settings."
        WinTop=0.909835
        WinLeft=0.518299
        WinWidth=0.202528
        WinHeight=0.044743
        TabOrder=0
        bBoundToParent=True
        bScaleToParent=True
        OnClick=InvasionProMainMenu.DefaultMenu
        OnKeyEvent=LockedOKButton.InternalOnKeyEvent
    End Object
    b_OK=GUIButton'TURInvPro.InvasionProMainMenu.LockedOKButton'

    bRequire640x480=True
    WinTop=0.050000
    WinLeft=0.000000
    WinWidth=1.000000
    WinHeight=0.900000
    bScaleToParent=True
}
