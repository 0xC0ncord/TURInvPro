//=============================================================================
// InvasionProScriptedController.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProScriptedController extends ScriptedController;

function SetNewScript(ScriptedSequence NewScript)
{
    MyScript = NewScript;
    SequenceScript = NewScript;
    Focus = None;
    ClearScript();
    SetEnemyReaction(3);
    //SequenceScript.SetActions(self);
}

defaultproperties
{
}
