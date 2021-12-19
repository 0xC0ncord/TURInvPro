//=============================================================================
// InvasionProBossListMenuOption.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProBossListMenuOption extends GUIMenuOption;

var(Option) InvasionProBossListItem MyItem;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    MyItem = InvasionProBossListItem(MyComponent);
}

defaultproperties
{
    ComponentClassName="TURInvPro.InvasionProBossListItem"
}
