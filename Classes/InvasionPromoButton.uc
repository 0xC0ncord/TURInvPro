//=============================================================================
// InvasionPromoButton.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionPromoButton extends moButton;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super(GUIMenuOption).InitComponent(MyController, MyOwner);

    MyButton = GUIButton(MyComponent);
    //MyButton.OnClick = InternalOnClick;
    MyButton.Caption = ButtonCaption;
}

defaultproperties
{
}
