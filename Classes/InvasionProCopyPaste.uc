//=============================================================================
// InvasionProCopyPaste.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProCopyPaste extends Object
    config(TURInvPro);

var() config float ClipBoardDrawScale;
var() config float ClipBoardCollisionHeight;
var() config float ClipBoardCollisionRadius;
var() config Vector ClipBoardPrePivot;
var() config Color ClipBoardWaveDrawColour;
var() config int ClipBoardWaveVariant;
var() config int ClipBoardWaveDuration;
var() config float ClipBoardWaveDifficulty;
var() config int ClipBoardWaveMaxMonsters;
var() config int ClipBoardMaxMonsters;
var() config float ClipBoardMonstersPerPlayerCurve;
var() config int ClipBoardMaxLives;
var() config string ClipBoardMonsters[$$__INVPRO_MAX_WAVE_MONSTERS__$$];
var() config string ClipBoardWaveFallbackMonster;
var() config bool ClipboardbOverrideBoss;

defaultproperties
{
}
