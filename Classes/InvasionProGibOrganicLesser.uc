//=============================================================================
// InvasionProGibOrganicLesser.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProGibOrganicLesser extends Gib;

var() Vector Dir;

simulated function PostBeginPlay()
{
    SpinGib(0.06);
    Super.PostBeginPlay();
}

simulated function SpinGib(float SpinAmount)
{
    local Vector Direction, Dummy;
    local Rotator R;

    SpinAmount *= 32768.0;
    R = Rotation;

    R.Pitch += ( FRand() * 2.0 * SpinAmount ) - SpinAmount;
    R.Yaw += ( FRand() * 2.0 * SpinAmount ) - SpinAmount;
    R.Roll += ( FRand() * 2.0 * SpinAmount ) - SpinAmount;
    SetRotation(R);
    GetAxes( Rotation, Dummy, Dummy, Direction );
    Velocity = Velocity + Normal(Direction) * 512.0;
    LifeSpan = LifeSpan + 2 * FRand() - 1;
}

defaultproperties
{
     TrailClass=Class'XEffects.BloodJet'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'XEffects.GibOrganicHead'
     DrawScale=0.100000
     Skins(0)=Texture'XEffects.GibOrganicRed'
     CollisionRadius=6.000000
     CollisionHeight=5.000000
}
