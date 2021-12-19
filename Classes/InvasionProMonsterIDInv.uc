//=============================================================================
// InvasionProMonsterIDInv.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//================================================
//keeps track of monster controller, assigns targets, handles teleporting
//================================================
class InvasionProMonsterIDInv extends Inventory;

var() int MonsterHealth;
var() int MonsterHealthMax;
var() int NewMonsterHealthMax;
var() Monster MyMonster;
var() bool bBoss;
var() int VisibleEnemyTimer;
var() float LastVisibleEnemyTime;
var() bool bFriendly; //true for pets
var() bool bPlayerControlled;
var() string MonsterName;
var() bool bSummoned;

replication
{
    reliable if(Role==ROLE_Authority)
        MyMonster, bBoss, bFriendly, MonsterHealth, MonsterHealthMax, MonsterName, bSummoned;
}

function Destroyed()
{
   if(bBoss)
   {
       InvasionPro(Level.Game).BossKilled();
   }

   Super.Destroyed();
}

function PostBeginPlay()
{
   SetTimer(0.25, true);
}

function GiveTo(Pawn Other, optional Pickup Pickup)
{
   if( Monster(Other) != None)
   {
       MyMonster = Monster(Other);
       Super.GiveTo(Other);
   }
}

function Timer()
{
   local NavigationPoint N;
  local Vector OldLocation;

   if(MyMonster != None)
   {
    if(MyMonster.DrivenVehicle==None)
    {
         MonsterHealth = MyMonster.Health;
         MonsterHealthMax = MyMonster.HealthMax;
    }
    else
    {
         MonsterHealth = MyMonster.DrivenVehicle.Health;
         MonsterHealthMax = MyMonster.DrivenVehicle.HealthMax;
    }

       if(MonsterHealth > MyMonster.HealthMax)
       {
           NewMonsterHealthMax = MonsterHealth;
       }

       if(NewMonsterHealthMax > 0)
       {
           MonsterHealthMax = NewMonsterHealthMax;
       }

       if(bBoss)
       {
           if(MyMonster.Health <= 0)
           {
               Destroy();
               SetTimer(0.0,false);
               return;
           }
       }

    //don't teleport bosses, or pets around
       if(!bBoss && MyMonster.Controller != None && !MyMonster.Controller.IsA('FriendlyMonsterController'))
       {
           if(MyMonster.Controller.Target != None)
           {
               if(!MyMonster.Controller.LineOfSightTo(MyMonster.Controller.Target))
               {
                   VisibleEnemyTimer++;
               }
               else
               {
                   VisibleEnemyTimer = 0;
               }

               if(!InvasionPro(Level.Game).ShouldMonsterAttack(MyMonster.Controller.Target, MyMonster.Controller) )
               {
                   MyMonster.Controller.Target = InvasionPro(Level.Game).GetMonsterTarget();
               }
           }
           else if(InvasionPro(Level.Game).CheckMaxLives(None))
           {
               MyMonster.Controller.Target = InvasionPro(Level.Game).GetMonsterTarget();
           }

           if(VisibleEnemyTimer >= 90) //if havnt seen enemy for 45 seconds then attempt to teleport near enemy
           {
               N = Level.Game.FindPlayerStart(MyMonster.Controller,0,"Stuck");
               if(N != None)
               {
          OldLocation=MyMonster.Location;
                   if(MyMonster.SetLocation(N.Location+(MyMonster.CollisionHeight - N.CollisionHeight) * vect(0,0,1)))
                   {
            MyMonster.DoTranslocateOut(OldLocation);
            MyMonster.PlayTeleportEffect(false,false);
                       VisibleEnemyTimer = 0;
                   }
               }
           }
       }

       if(InvasionProFriendlyMonsterReplicationInfo(MyMonster.PlayerReplicationInfo) != None)
       {
           bBoss = false;
           bFriendly = true;
           InvasionProFriendlyMonsterReplicationInfo(MyMonster.PlayerReplicationInfo).MonsterHealth = MyMonster.Health;
           InvasionProFriendlyMonsterReplicationInfo(MyMonster.PlayerReplicationInfo).MonsterHealthMax = MyMonster.SuperHealthMax;
           InvasionProFriendlyMonsterReplicationInfo(MyMonster.PlayerReplicationInfo).MyMonster = MyMonster;
           InvasionProFriendlyMonsterReplicationInfo(MyMonster.PlayerReplicationInfo).UpdatePRI();
           MonsterName = InvasionProFriendlyMonsterReplicationInfo(MyMonster.PlayerReplicationInfo).PlayerName;
       }
       else
       {
           if(!bBoss)
           {
               bFriendly = false;
               MonsterName = "";
           }
       }

       MyMonster.bBoss = bBoss;
   }
}

defaultproperties
{
     ItemName="MonsterTag"
     bOnlyRelevantToOwner=False
     bAlwaysRelevant=True
     bReplicateInstigator=True
}
