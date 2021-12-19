//=============================================================================
// InvasionProBossListItem.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProBossListItem extends GUIMultiComponent;

const EDIT_BUTTON_WIDTH = 60;
const COMP_SPR = 2;

var() automated GUIComboBox ComboBox;
var() automated GUIButton InsertButton;
var() automated GUIButton RemoveButton;
var() automated GUIButton EditButton;

function bool InternalOnPreDraw(Canvas C)
{
    local float AH, AW, At, AL;

    if(ComboBox == none || InsertButton == none || RemoveButton == none || EditButton == none)
    {
        return false;
    }
    AH = ActualHeight();
    AW = ActualWidth();
    At = ActualTop();
    AL = ActualLeft();
    if(InsertButton.bVisible && RemoveButton.bVisible)
    {
        ComboBox.WinHeight = AH;
        InsertButton.WinHeight = AH;
        RemoveButton.WinHeight = AH;
        EditButton.WinHeight = AH;
        ComboBox.WinWidth = ((AW - (AH * float(2))) - float(60)) - float(2 * 3);
        ComboBox.WinLeft = AL;
        InsertButton.WinWidth = AH;
        InsertButton.WinLeft = (AL + ComboBox.WinWidth) + float(2);
        RemoveButton.WinWidth = AH;
        RemoveButton.WinLeft = (InsertButton.WinLeft + AH) + float(2);
        EditButton.WinWidth = 60.0;
        EditButton.WinLeft = (RemoveButton.WinLeft + AH) + float(2);
        ComboBox.WinTop = At;
        InsertButton.WinTop = At;
        RemoveButton.WinTop = At;
        EditButton.WinTop = At;
    }
    else
    {
        ComboBox.WinHeight = AH;
        EditButton.WinHeight = AH;
        ComboBox.WinWidth = (AW - float(60)) - float(2);
        ComboBox.WinLeft = AL;
        EditButton.WinWidth = 60.0;
        EditButton.WinLeft = (AL + ComboBox.WinWidth) + float(2);
        ComboBox.WinTop = At;
        EditButton.WinTop = At;
    }
    return false;
}

defaultproperties
{
    Begin Object Name=ComboBox_ class=GUIComboBox
        bReadOnly=true
        TextStr="-- New Boss --"
        bNeverScale=true
    End Object
    ComboBox=GUIComboBox'ComboBox_'

    Begin Object Name=b_Insert class=GUIButton
        Caption="+"
        Hint="Insert another item above this one."
        bNeverScale=true
    End Object
    InsertButton=GUIButton'b_Insert'

    Begin Object Name=b_Remove class=GUIButton
        Caption="-"
        Hint="Remove this item from the list."
        bNeverScale=true
    End Object
    RemoveButton=GUIButton'b_Remove'

    Begin Object Name=b_Edit class=GUIButton
        Caption="Edit"
        Hint="Edit this item."
        bNeverScale=true
    End Object
    EditButton=GUIButton'b_Edit'

    OnPreDraw=InternalOnPreDraw
}
