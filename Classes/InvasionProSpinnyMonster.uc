//=============================================================================
// InvasionProSpinnyMonster.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProSpinnyMonster extends Actor;

var() int SpinRate;

var() bool bPlayRandomAnims;
var() float AnimChangeInterval;
var() array<name> AnimNames;

var() float CurrentTime;
var() float NextAnimTime;
var() name currentAnim;
var() int RotateSpeed;

function Tick(float Delta)
{
    local rotator NewRot, R;

    NewRot = Rotation;
    NewRot.Yaw += Delta * SpinRate/Level.TimeDilation;
    SetRotation(NewRot);

    CurrentTime += Delta/Level.TimeDilation;

   R = Rotation;
   R.Yaw -= (RotateSpeed);
   SetRotation(r);
}

event AnimEnd( int Channel )
{
    Super.AnimEnd(Channel);
}

function PlayNextAnim()
{
    local name NewAnimName;
    local int i, AnimNumber;

    if(Mesh == None || AnimNames.Length == 0)
    {
        return;
   }

   //get current anim
   for(i=0;i<AnimNames.Length;i++)
   {
       if( currentAnim == AnimNames[i] )
       {
           AnimNumber = i;
       }
   }

    NewAnimName = AnimNames[AnimNumber];
    if(NewAnimName != '')
    {
       PlayAnim(NewAnimName, 1.0/Level.TimeDilation, 0.25/Level.TimeDilation);
       currentAnim = NewAnimName;
       NextAnimTime = CurrentTime + AnimChangeInterval;
   }
}

function PlayRandomAnim()
{
    local name NewAnimName;

    if(Mesh == None || AnimNames.Length == 0)
    {
        return;
   }

    NewAnimName = AnimNames[Rand(AnimNames.Length)];
    if(NewAnimName != '')
    {
       PlayAnim(NewAnimName, 1.0/Level.TimeDilation, 0.25/Level.TimeDilation);
       currentAnim = NewAnimName;
       NextAnimTime = CurrentTime + AnimChangeInterval;
   }
}

event GainedChild(Actor Other)
{
   if(Other.Class == class'InvasionProCylinderActor')
   {
       InvasionProCylinderActor(Other).SetBase(self);
   }

   Super.GainedChild(Other);
}

defaultproperties
{
     spinRate=20000
     AnimChangeInterval=3.000000
     AnimNames(0)="WalkF"
     DrawType=DT_StaticMesh
     bOnlyOwnerSee=True
     bOnlyDrawIfAttached=True
     RemoteRole=ROLE_None
     LODBias=100000.000000
     DrawScale=0.500000
     bUnlit=True
     bAlwaysTick=True
}
