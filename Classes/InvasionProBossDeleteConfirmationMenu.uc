//=============================================================================
// InvasionProBossDeleteConfirmationMenu.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProBossDeleteConfirmationMenu extends FloatingWindow;

var InvasionProBossConfig BossConfigMenu;
var() automated GUISectionBackground sbConfirm;
var() automated GUIButton btYes;
var() automated GUIButton btNo;
var() automated GUILabel lblWarning;
var localized string WindowTitle;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.InitComponent(MyController, MyOwner);
    __OnClose__Delegate = MyOnClose;
    t_WindowTitle.SetCaption(WindowTitle);
}

function Init()
{
    lblWarning.Caption = "Are you sure you wish to delete this boss from the internal boss table? THIS ACTION CANNOT BE UNDONE!";
}

function bool InternalOnClick(GUIComponent Sender)
{
    if(Sender == btYes)
    {
        BossConfigMenu.ConfirmDeleteBoss();
        Controller.RemoveMenu(self);
    }
    else
    {
        Controller.CloseMenu(false);
    }
    return true;
}

function MyOnClose(optional bool bCanceled)
{
    BossConfigMenu = none;
    OnClose(bCanceled);
}

defaultproperties
{
    Begin Object Name=sbConfirm_ class=AltSectionBackground
        LeftPadding=0.0
        RightPadding=0.0
        WinTop=0.0973530
        WinLeft=0.0158750
        WinWidth=0.9687230
        WinHeight=0.6330040
    End Object
    sbConfirm=AltSectionBackground'sbConfirm_'

    Begin Object Name=YesButton class=GUIButton
        Caption="Yes"
        WinTop=0.7281910
        WinLeft=0.0157410
        WinWidth=0.482870
        WinHeight=0.1492590
        TabOrder=1
        OnClick=InternalOnClick
    End Object
    btYes=GUIButton'YesButton'

    Begin Object Name=NoButton class=GUIButton
        Caption="No"
        WinTop=0.7291620
        WinLeft=0.5046870
        WinWidth=0.482870
        WinHeight=0.1492590
        TabOrder=0
        OnClick=InternalOnClick
    End Object
    btNo=GUIButton'NoButton'

    Begin Object Name=DescConfirm class=GUILabel
        bMultiLine=true
        StyleName="NoBackground"
        WinTop=0.2143050
        WinLeft=0.0425920
        WinWidth=0.9150460
        WinHeight=0.3905090
    End Object
    lblWarning=GUILabel'DescConfirm'

    WindowTitle="Delete Boss"
    bResizeWidthAllowed=false
    bResizeHeightAllowed=false
    bMoveAllowed=false
    bPersistent=true
    bAllowedAsLast=true
    WinTop=0.1383330
    WinLeft=0.20
    WinWidth=0.60
    WinHeight=0.3747230
}
