//=============================================================================
// InvasionProWaveUnsavedConfirmationMenu.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProWaveUnsavedConfirmationMenu extends FloatingWindow;

var InvasionProWaveConfig WaveConfigMenu;

var automated GUISectionBackground sbConfirm;
var automated GUIButton btYes, btNo;
var automated GUILabel lblWarning;

var localized string WindowTitle;

var bool bCloseWaveConfig;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
   Super.InitComponent(MyController, MyOwner);

   OnClose=MyOnClose;

   t_WindowTitle.SetCaption(WindowTitle);
}

function Init()
{
   lblWarning.Caption = "This wave has unsaved changes! Are you sure you want to discard them?";
}

function bool InternalOnClick(GUIComponent Sender)
{
   local GUIController OldController;

   if (Sender == btYes)
   {
       WaveConfigMenu.DiscardChanges();

       if(bCloseWaveConfig)
       {
           OldController = Controller;
           Controller.CloseMenu(false);
           OldController.CloseMenu(false);
       }
       else
           Controller.CloseMenu(false);
   }
   else
   {
       WaveConfigMenu.currentWave.SetValue(WaveConfigMenu.ActiveWave);
       Controller.CloseMenu(false);
   }

   return true;
}

function MyOnClose(optional bool bCanceled)
{
   WaveConfigMenu = None;
   Super.OnClose(bCanceled);
}

defaultproperties
{
     Begin Object Class=AltSectionBackground Name=sbConfirm_
         LeftPadding=0.000000
         RightPadding=0.000000
         WinTop=0.097353
         WinLeft=0.015875
         WinWidth=0.968723
         WinHeight=0.633004
         OnPreDraw=sbConfirm_.InternalPreDraw
     End Object
     sbConfirm=AltSectionBackground'TURInvPro.InvasionProWaveUnsavedConfirmationMenu.sbConfirm_'

     Begin Object Class=GUIButton Name=YesButton
         Caption="Yes"
         WinTop=0.728191
         WinLeft=0.015741
         WinWidth=0.482870
         WinHeight=0.149259
         TabOrder=1
         OnClick=InvasionProWaveUnsavedConfirmationMenu.InternalOnClick
         OnKeyEvent=YesButton.InternalOnKeyEvent
     End Object
     btYes=GUIButton'TURInvPro.InvasionProWaveUnsavedConfirmationMenu.YesButton'

     Begin Object Class=GUIButton Name=NoButton
         Caption="No"
         WinTop=0.729162
         WinLeft=0.504687
         WinWidth=0.482870
         WinHeight=0.149259
         TabOrder=0
         OnClick=InvasionProWaveUnsavedConfirmationMenu.InternalOnClick
         OnKeyEvent=NoButton.InternalOnKeyEvent
     End Object
     btNo=GUIButton'TURInvPro.InvasionProWaveUnsavedConfirmationMenu.NoButton'

     Begin Object Class=GUILabel Name=DescConfirm
         bMultiLine=True
         StyleName="NoBackground"
         WinTop=0.214305
         WinLeft=0.042592
         WinWidth=0.915046
         WinHeight=0.390509
     End Object
     lblWarning=GUILabel'TURInvPro.InvasionProWaveUnsavedConfirmationMenu.DescConfirm'

     WindowTitle="Unsaved Changes"
     bResizeWidthAllowed=False
     bResizeHeightAllowed=False
     bMoveAllowed=False
     bPersistent=True
     bAllowedAsLast=True
     WinTop=0.138333
     WinLeft=0.200000
     WinWidth=0.600000
     WinHeight=0.374723
}
