//=============================================================================
// InvasionProAnimationManager.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProAnimationManager extends Object config(TURInvPro);

var() config array<name> AnimNames;

defaultproperties
{
     AnimNames(0)="WalkF"
     AnimNames(1)="RunF"
     AnimNames(2)="Idle"
     AnimNames(3)="Meditate"
     AnimNames(4)="Idle_Rest"
     AnimNames(5)="Crawl"
     AnimNames(6)="Jump"
     AnimNames(7)="JumpF"
     AnimNames(8)="Run"
     AnimNames(9)="Walk"
     AnimNames(10)="Swimmming"
     AnimNames(11)="Breath"
     AnimNames(12)="Waver"
     AnimNames(13)="TWalk001"
     AnimNames(14)="TFist"
     AnimNames(15)="Slither"
     AnimNames(16)="Sight"
     AnimNames(17)="SwimF"
     AnimNames(18)="Fly"
     AnimNames(19)="Walking"
     AnimNames(20)="Float"
     AnimNames(21)="Belch"
     AnimNames(22)="Laugh"
     AnimNames(23)="Twirl"
     AnimNames(24)="Sting"
     AnimNames(25)="Chew"
     AnimNames(26)="Swish"
     AnimNames(27)="Stretch"
     AnimNames(28)="gunfix"
     AnimNames(29)="Fighter"
     AnimNames(30)="Laugh"
     AnimNames(31)="FlyFire"
     AnimNames(32)="Munch"
     AnimNames(33)="JumpMid"
     AnimNames(34)="AssSmack"
     AnimNames(35)="ThroatCut"
     AnimNames(36)="Specific_1"
     AnimNames(37)="Gesture_Taunt01"
     AnimNames(38)="Gesture_Taunt02"
     AnimNames(39)="Gesture_Taunt03"
     AnimNames(40)="MeleeAttack"
     AnimNames(41)="MeleeAttack01"
     AnimNames(42)="MeleeAttack02"
     AnimNames(43)="RangedAttack"
     AnimNames(44)="RangedAttack01"
     AnimNames(45)="RangedAttack02"
     AnimNames(46)="Victory"
     AnimNames(47)="Roar"
     AnimNames(48)="Pain"
     AnimNames(49)="Crouch"
     AnimNames(50)="Jump_Mid"
     AnimNames(51)="JumpLand"
     AnimNames(52)="Jump_Land"
     AnimNames(53)="JumpStart"
     AnimNames(54)="Jump_Start"
     AnimNames(55)="Sight"
     AnimNames(56)="Attack1"
     AnimNames(57)="Attack2"
     AnimNames(58)="Attack3"
     AnimNames(59)="Summon"
     AnimNames(60)="FlapNormal"
     AnimNames(61)="Lunge"
     AnimNames(62)="Travel"
}
