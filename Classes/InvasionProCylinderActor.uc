//=============================================================================
// InvasionProCylinderActor.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProCylinderActor extends Actor placeable;

function Tick(float DeltaTime)
{
   if(Owner != None)
   {
       SetRotation(Owner.Rotation);
   }
}

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'TURInvPro.EditCylinderMesh'
     RemoteRole=ROLE_None
     Skins(0)=Texture'UCGeneric.SolidColours.Red'
     AmbientGlow=60
     bUnlit=True
     bHardAttach=True
}
