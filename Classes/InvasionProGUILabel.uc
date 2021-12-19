//=============================================================================
// InvasionProGUILabel.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProGUILabel extends GUILabel;

defaultproperties
{
     bAcceptsInput=True
     bCaptureMouse=True
     Begin Object Class=InvasionProGUIToolTip Name=MyToolTip
     End Object
     ToolTip=InvasionProGUIToolTip'TURInvPro.InvasionProGUILabel.MyToolTip'
}
