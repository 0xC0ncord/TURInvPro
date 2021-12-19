//=============================================================================
// InvasionProMutator.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProMutator extends DMMutator HideDropDown CacheExempt;

var() int WaveNameDuration;

var InvasionProGameRules Rules;
var float NextMVPAnnounceTime;

replication
{
   reliable if(bNetInitial && Role==Role_Authority)
       WaveNameDuration;
}

simulated function PostBeginPlay()
{
   Super.PostBeginPlay();

   if(Role == Role_Authority)
   {
       WaveNameDuration = InvasionPro(Level.Game).WaveNameDuration;
       InvasionPro(Level.Game).InvProMut=Self;
   }

   SetTimer(0.5,true);
}

function AddGameRules()
{
   Rules = Spawn(class'InvasionProGameRules');
   Rules.InvPro = InvasionPro(Level.Game);
   Rules.NextGameRules = Level.Game.GameRulesModifiers;
   Level.Game.GameRulesModifiers = Rules;
}

simulated function Timer()
{
   local InvasionProMonsterReplicationInfo MI;
   local int i;
   local Class<Monster> MonsterClass;
   local string MonsterName;

   foreach DynamicActors(class'InvasionProMonsterReplicationInfo', MI)
   {
       for(i=0;i<MI.GetLength();i++)
       {
           MonsterName = MI.GetMonsterClassName(i);
           if(MonsterName != "None")
           {
               MonsterClass = class<Monster>(DynamicLoadObject(MonsterName,class'class',true));
               if(MonsterClass != None)
               {
                   if(MonsterClass.default.Mesh == vertmesh'SkaarjPack_rc.GasbagM')
                   {
                       MonsterClass.default.WalkAnims[0] = 'Float';
                       MonsterClass.default.WalkAnims[1] = 'Float';
                       MonsterClass.default.WalkAnims[2] = 'Float';
                       MonsterClass.default.WalkAnims[3] = 'Float';
                   }
                   else if(MonsterClass.default.Mesh == vertmesh'SkaarjPack_rc.Skaarjw')
                   {
                       MonsterClass.default.DodgeAnims[1] = 'DodgeF';
                   }
                   else if(string(MonsterClass.default.Mesh) ~= "satoreMonsterPackMeshes.Titan1")
                   {
                       MonsterClass.default.DoubleJumpAnims[0] = '';
                       MonsterClass.default.DoubleJumpAnims[1] = '';
                       MonsterClass.default.DoubleJumpAnims[2] = '';
                       MonsterClass.default.DoubleJumpAnims[3] = '';
                       MonsterClass.default.DodgeAnims[0] = '';
                       MonsterClass.default.DodgeAnims[1] = '';
                       MonsterClass.default.DodgeAnims[2] = '';
                       MonsterClass.default.DodgeAnims[3] = '';
                       MonsterClass.default.AirAnims[0] = '';
                       MonsterClass.default.AirAnims[1] = '';
                       MonsterClass.default.AirAnims[2] = '';
                       MonsterClass.default.AirAnims[3] = '';
                       MonsterClass.default.TakeoffAnims[0] = '';
                       MonsterClass.default.TakeoffAnims[1] = '';
                       MonsterClass.default.TakeoffAnims[2] = '';
                       MonsterClass.default.TakeoffAnims[3] = '';
                   }

                   if(MonsterClass.default.GibGroupClass == class'XEffects.xPawnGibGroup')
                   {
                       MonsterClass.default.GibGroupClass = Class'TURInvPro.InvasionProGibGroupClass';
                   }
                   else if(MonsterClass.default.GibGroupClass == class'XEffects.xBotGibGroup')
                   {
                       MonsterClass.default.GibGroupClass = Class'TURInvPro.InvasionProMetalGibGroupClass';
                   }
                   else if(MonsterClass.default.GibGroupClass == class'XEffects.xAlienGibGroup')
                   {
                       MonsterClass.default.GibGroupClass = Class'TURInvPro.InvasionProAlienGibGroupClass';
                   }
                   //custom gib groups not accounted for yet, such as AlienMonsterPack
                   //not many of those custom groups around anyway
               }
           }
       }

       class'InvasionProWaveMessage'.default.LifeTime = WaveNameDuration;
       SetTimer(0.0,false);
   }
}

function UpdateMonster(Monster M, int ID)
{
   local int RandValue;
   local int fRandValue;

   if(M.IsA('SMPNaliCow') )
   {
       M.Disable('Tick');
   }

   if( class'InvasionProMonsterTable'.default.MonsterTable[ID].bRandomHealth )
   {
       RandValue = Max(100,Rand(1000));

       M.Health = RandValue;
       M.HealthMax = RandValue;
   }
   else
   {
       M.Health = class'InvasionProMonsterTable'.default.MonsterTable[ID].NewHealth;
       M.HealthMax = class'InvasionProMonsterTable'.default.MonsterTable[ID].NewMaxHealth;
   }

   if( class'InvasionProMonsterTable'.default.MonsterTable[ID].bRandomSpeed )
   {
       RandValue = Max(200,Rand(1000));

       M.GroundSpeed = RandValue;
       M.AirSpeed = RandValue;
       M.WaterSpeed = RandValue;
       M.JumpZ = RandValue;
   }
   else
   {
       M.GroundSpeed = class'InvasionProMonsterTable'.default.MonsterTable[ID].NewGroundSpeed;
       M.AirSpeed = class'InvasionProMonsterTable'.default.MonsterTable[ID].NewAirSpeed;
       M.WaterSpeed = class'InvasionProMonsterTable'.default.MonsterTable[ID].NewWaterSpeed;
       M.JumpZ =class'InvasionProMonsterTable'.default.MonsterTable[ID].NewJumpZ;
   }

   if( class'InvasionProMonsterTable'.default.MonsterTable[ID].bRandomSize )
   {
       fRandValue = Rand( (5.0 * 1000) - (0.2 * 1000) ) ;
       fRandValue /= 1000;
       fRandValue += 0.2;

       if(fRandValue < 1)
       {
           fRandValue = 1;
       }
       M.SetLocation( M.Location + vect(0,0,1) * ( M.CollisionHeight * fRandValue) );
       M.SetDrawScale(M.Drawscale * fRandValue);
       M.SetCollisionSize( M.CollisionRadius * fRandValue, M.CollisionHeight * fRandValue );
       M.Prepivot.X = M.Prepivot.X * fRandValue;
       M.Prepivot.Y = M.Prepivot.Y * fRandValue;
       M.Prepivot.Z = M.Prepivot.Z * fRandValue;
   }
   else
   {
       M.SetLocation( M.Location + vect(0,0,1) * ( M.CollisionHeight * class'InvasionProMonsterTable'.default.MonsterTable[ID].NewDrawScale) );
       M.SetDrawScale(class'InvasionProMonsterTable'.default.MonsterTable[ID].NewDrawScale);
       M.SetCollisionSize(class'InvasionProMonsterTable'.default.MonsterTable[ID].NewCollisionRadius,class'InvasionProMonsterTable'.default.MonsterTable[ID].NewCollisionHeight);
       M.Prepivot = class'InvasionProMonsterTable'.default.MonsterTable[ID].NewPrepivot;
   }

   /*
   M.GibCountCalf *= class'InvasionProMonsterTable'.default.MonsterTable[ID].NewGibMultiplier;
   M.GibCountForearm *= class'InvasionProMonsterTable'.default.MonsterTable[ID].NewGibMultiplier;
   M.GibCountHead *= class'InvasionProMonsterTable'.default.MonsterTable[ID].NewGibMultiplier;
   M.GibCountTorso *= class'InvasionProMonsterTable'.default.MonsterTable[ID].NewGibMultiplier;
   M.GibCountUpperArm *= class'InvasionProMonsterTable'.default.MonsterTable[ID].NewGibMultiplier;
   */

   M.ScoringValue = class'InvasionProMonsterTable'.default.MonsterTable[ID].NewScoreAward;
}

function float GetGibSize(Monster M)
{
   local int i;
   local string MonsterName;
   local float GibSize;

   GibSize = 1.0;
   MonsterName = "None";

   for(i=0;i<class'InvasionProMonsterTable'.default.MonsterTable.Length;i++ )
   {
       if( class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterClassName ~= string(M.Class) )
       {
           MonsterName = class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterName;
           break;
       }
   }

   if(MonsterName != "None")
   {
       for(i=0;i<class'InvasionProConfigs'.default.Bosses.Length;i++ )
       {
           if( class'InvasionProConfigs'.default.Bosses[i].BossMonsterName ~= MonsterName )
           {
               GibSize = class'InvasionProConfigs'.default.Bosses[i].BossGibSizeMultiplier;
               break;
           }
       }
   }

   return GibSize;
}

function ModifyMonster(Pawn P, bool bFriendly, bool bBoss)
{
   local InvasionProMonsterIDInv NewInv;
   local Inventory Inv;

   if(P != None)
   {
       if(InvasionPro(Level.Game).bMonstersAlwaysRelevant)
           P.bAlwaysRelevant = true;
       if(P.Controller!=None && P.Controller.IsA('DumpMonsAI'))
           P.Controller.SetPropertyText("bActLikeInv","True");
       Inv = P.FindInventoryType(class'InvasionProMonsterIDInv');
       if(Inv != None)
       {
           return;
       }

       NewInv = Spawn(class'InvasionProMonsterIDInv', P);
       if(NewInv != None)
       {
           NewInv.GiveTo(P);
           NewInv.bBoss = bBoss;
           NewInv.bFriendly = bFriendly;
           NewInv.bSummoned = true;
           if(PlayerController(P.Controller) != None || P.IsA('MorphMonster'))
               NewInv.bPlayerControlled = True;
       }
   }
}

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
    local int i;

    bSuperRelevant = 0;

    if(Controller(Other) != None && Other.iSA('ProxyController'))
    {
        Controller(Other).PlayerReplicationInfo = None;
        Controller(Other).PlayerReplicationInfo = Spawn(Class'InvasionProProxyReplicationInfo', Other,, vect(0.00, 0.00, 0.00), rot(0, 0, 0));
    }

    if(Monster(Other) != None)
    {
        if(!Other.IsA('MorphMonster'))
        {
            ModifyMonster(Monster(Other),false,false);
            for( i=0;i<class'InvasionProMonsterTable'.default.MonsterTable.Length;i++ )
            {
                if( class'InvasionProMonsterTable'.default.MonsterTable[i].MonsterClassName ~= string(Other.Class) )
                {
                    UpdateMonster(Monster(Other), i);
                    break;
                }
            }

            if(GasBag(Other) != None)
            {
                GasBag(Other).AddVelocity(vect(0,0,50));
            }

            /*
            if(Other.Instigator != None && Monster(Other.Instigator) != None)
            {
                if(FriendlyMonsterController(Monster(Other.Instigator).Controller) != None && FriendlyMonsterController(Monster(Other.Instigator).Controller).Master != None)
                {
                    //friendly monster summoned another monster? give it a friendly controller
                    if(Monster(Other).Controller != None)
                    {
                        Monster(Other).Controller.Destroy();
                    }

                    FMC = Spawn(class'TURInvPro.FriendlyMonsterController');
                    if(FMC  != None)
                    {
                        FMC.Possess(Monster(Other));
                        FMC.SetMaster(FriendlyMonsterController(Monster(Other.Instigator).Controller));
                        FMC.CreateFriendlyMonsterReplicationInfo();
                    }
                }
            }
            */
        }
        else
            ModifyMonster(Monster(Other),false,false);
    }

    if ( Pawn(Other) != None )
    {
        Pawn(Other).bAutoActivate = true;
    }
    else if ( GameObjective(Other) != None )
    {
        Other.bHidden = true;
        GameObjective(Other).bDisabled = true;
        Other.SetCollision(false,false,false);
    }
    else if (GameObject(Other) != None)
    {
        if(CTFFlag(Other) != None)
        {
            Other.bHidden = true;
            Other.SetCollision(false,false,false);
            CTFFlag(Other).bDisabled = true;
        }
        else
        {
            return false;
        }
    }
    else if(xBombDeliveryHole(Other) != None)//it's this that kills players who jump in bombing run holes
    {
        return false;
    }

    return true;
}

//might not work with petcontroller just yet
function Tick(float DeltaTime)
{
   local Actor A;
   local InvasionProFriendlyMonsterReplicationInfo PRI;
   local Inventory Inv;
   local int i,x,BestDamage;

   if(NextMVPAnnounceTime!=0f && Level.TimeSeconds>=NextMVPAnnounceTime)
  {
    NextMVPAnnounceTime=0f;

   for(i=0; i<Rules.DamageArray.Length; i++)
   {
       if(Rules.DamageArray[i].Damage>BestDamage)
       {
           x=i;
           BestDamage=Rules.DamageArray[i].Damage;
       }
   }
   BroadcastLocalizedMessage(class'InvasionProMVPMessage', BestDamage,Rules.DamageArray[x].PRI);

   Rules.DamageArray.Remove(0,Rules.DamageArray.Length);
  }

   foreach DynamicActors(class'Actor',A)
   {
       if(Vehicle(A) != None && Monster(Vehicle(A).Driver)==None)
       {
           Vehicle(A).bTeamLocked = false;
           Vehicle(A).bNoFriendlyFire = true;
           Vehicle(A).Team = 0;
       }
       else if(Monster(A) != None && Monster(A).Controller != None && Monster(A).PlayerReplicationInfo != None && InvasionProFriendlyMonsterReplicationInfo(Monster(A).PlayerReplicationInfo) == None)
       {
           if(PlayerController(Monster(A).Controller)==None)
           {
               PRI = Spawn(class'InvasionProFriendlyMonsterReplicationInfo');
               if(PRI != None)
               {
                   PRI.PlayerName = Monster(A).PlayerReplicationInfo.PlayerName;
                   PRI.Team = Monster(A).PlayerReplicationInfo.Team;
                   PRI.SetPRI();
                   Monster(A).PlayerReplicationInfo.Destroy();
                   Monster(A).PlayerReplicationInfo = PRI;
                   Monster(A).Controller.PlayerReplicationInfo = PRI;
                   InvasionPro(Level.Game).UpdatePlayerGRI();
                   if(InvasionProGameReplicationInfo(Level.Game.GameReplicationInfo) != None)
                   {
                       InvasionProGameReplicationInfo(Level.Game.GameReplicationInfo).AddFriendlyMonster(Monster(A));
                   }
               }
           }

           Inv = Monster(A).FindInventoryType(class'InvasionProMonsterIDInv');

           if(InvasionProMonsterIDInv(Inv) != None)
           {
               if(PlayerController(Monster(A).Controller)==None)
                   InvasionProMonsterIDInv(Inv).bFriendly = true;
               else
                   InvasionProMonsterIDInv(Inv).bPlayerControlled = true;
           }
       }
   }
}

simulated function Mutate(string MutateString, PlayerController Sender)
{
   local array<string> Parts;

   Split(MutateString," ",Parts);

   if(Level.Netmode == NM_Standalone || Sender.PlayerReplicationInfo.bAdmin)
   {
       if(Parts[0] ~= "nextwave")
       {
           InvasionPro(Level.Game).ForceNextWave();
           Broadcast("Admin forcing next wave.");
       }
       else if(Parts[0] ~= "endwave")
       {
           InvasionPro(Level.Game).WaveEndTime = 0;
           Broadcast("Admin forcing wave end.");
       }
   }

   Super.Mutate(MutateString, Sender);
}

function Broadcast(string Message)
{
   local Pawn P;

   foreach DynamicActors(class'Pawn', P)
   {
       if (Monster(P) == None || (P!=None && PlayerController(P.Controller)!=None))
       {
           P.ClientMessage(Message);
       }
   }
}

defaultproperties
{
    WaveNameDuration=3
    bAlwaysRelevant=True
    bNetTemporary=True
    RemoteRole=ROLE_SimulatedProxy
}
