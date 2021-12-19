//=============================================================================
// InvasionProLoginMenu.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProLoginMenu extends UT2K4InvasionLoginMenu;

function AddPanels()
{
    Panels[0].ClassName = "TURInvPro.InvasionProPlayerLoginControls";
    Super(UT2K4PlayerLoginMenu).AddPanels();
}

defaultproperties
{
}
