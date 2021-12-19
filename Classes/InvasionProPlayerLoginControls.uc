//=============================================================================
// InvasionProPlayerLoginControls.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProPlayerLoginControls extends UT2K4Tab_PlayerLoginControlsInvasion;

var() Automated GUIButton G_HUDButton;

function bool InternalOnPreDraw(Canvas C)
{
    local GameReplicationInfo GRI;

    GRI = GetGRI();
    if (InvasionProGameReplicationInfo(GRI) != None)
    {
        if (bInit)
            InitGRI();

        if ( bTeamGame )
        {
            if ( GRI.Teams[0] != None )
                sb_Red.Caption = RedTeam@string(int(GRI.Teams[0].Score));

            if ( GRI.Teams[1] != None )
                sb_Blue.Caption = BlueTeam@string(int(GRI.Teams[1].Score));

            if (PlayerOwner().PlayerReplicationInfo.Team != None)
            {
                if (PlayerOwner().PlayerReplicationInfo.Team.TeamIndex == 0)
                {
                    sb_Red.HeaderBase = texture'Display95';
                    sb_Blue.HeaderBase = sb_blue.default.headerbase;
                }
                else
                {
                    sb_Blue.HeaderBase = texture'Display95';
                    sb_Red.HeaderBase = sb_blue.default.headerbase;
                }
            }
        }

        SetButtonPositions(C);
        UpdatePlayerLists();

       if(EnableSpecJoinButton(GRI))
        {
            EnableComponent(b_Spec);
       }
       else
       {
           DisableComponent(b_Spec);
       }
    }

    return false;
}

function bool EnableSpecJoinButton(GameReplicationInfo GRI)
{
   if(b_Spec.Caption ~= SpectateButtonText)
   {
        if(PlayerOwner().myHUD == none || PlayerOwner().myHUD != none && !PlayerOwner().myHUD.IsInCinematic())
       {
           return true;
       }
   }
   else if(b_Spec.Caption ~= JoinGameButtonText)
   {
        if(GRI.bMatchHasBegun && !PlayerOwner().IsInState('GameEnded') && !PlayerOwner().myHUD.IsInCinematic())
       {
           return true;
       }
   }

   return false;
}

function bool InternalOnClick(GUIComponent Sender)
{
   if(Sender == G_HUDButton)
   {
       Controller.OpenMenu("TURInvPro.InvasionProHudConfig", "", "");
   }

   return true;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=HUDButton
         Caption="InvasionPro HUD"
         bAutoSize=True
         TabOrder=6
         OnClick=InvasionProPlayerLoginControls.InternalOnClick
         OnKeyEvent=HUDButton.InternalOnKeyEvent
     End Object
     G_HUDButton=GUIButton'TURInvPro.InvasionProPlayerLoginControls.HUDButton'

}
