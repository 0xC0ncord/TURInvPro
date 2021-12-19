//=============================================================================
// InvasionProBot.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProBot extends InvasionBot;

function ExecuteWhatToDoNext()
{
    bHasFired = false;
    GoalString = "WhatToDoNext at "$Level.TimeSeconds;
    if ( Pawn == None )
    {
        warn(GetHumanReadableName()$" WhatToDoNext with no pawn");
        return;
    }
/*    else if ( (Pawn.Weapon == None) && (Vehicle(Pawn) == None) )
    {
       //removed pointless log warning
   }*/

    if ( Enemy == None )
    {
        if ( Level.Game.TooManyBots(self) )
        {
            if ( Pawn != None )
            {
                if ( (Vehicle(Pawn) != None) && (Vehicle(Pawn).Driver != None) )
                    Vehicle(Pawn).Driver.KilledBy(Vehicle(Pawn).Driver);
                else
                {
                    Pawn.Health = 0;
                    Pawn.Died( self, class'Suicided', Pawn.Location );
                }
            }
            Destroy();
            return;
        }
        BlockedPath = None;
        bFrustrated = false;
        if (Target == None || (Pawn(Target) != None && Pawn(Target).Health <= 0))
            StopFiring();
    }

    if ( ScriptingOverridesAI() && ShouldPerformScript() )
        return;
    if (Pawn.Physics == PHYS_None)
        Pawn.SetMovementPhysics();
    if ( (Pawn.Physics == PHYS_Falling) && DoWaitForLanding() )
        return;
    if ( (StartleActor != None) && !StartleActor.bDeleteMe && (VSize(StartleActor.Location - Pawn.Location) < StartleActor.CollisionRadius)  )
    {
        Startle(StartleActor);
        return;
    }
    bIgnoreEnemyChange = true;
    if ( (Enemy != None) && ((Enemy.Health <= 0) || (Enemy.Controller == None)) )
        LoseEnemy();
    if ( Enemy == None )
        Squad.FindNewEnemyFor(self,false);
    else if ( !Squad.MustKeepEnemy(Enemy) && !EnemyVisible() )
    {
        // decide if should lose enemy
        if ( Squad.IsDefending(self) )
        {
            if ( LostContact(4) )
                LoseEnemy();
        }
        else if ( LostContact(7) )
            LoseEnemy();
    }
    bIgnoreEnemyChange = false;
    if ( AssignSquadResponsibility() )
    {
        // might have gotten out of vehicle and been killed
        if ( Pawn == None )
            return;
        SwitchToBestWeapon();
        return;
    }
    if ( ShouldPerformScript() )
        return;
    if ( Enemy != None )
        ChooseAttackMode();
    else
    {
        GoalString = "WhatToDoNext Wander or Camp at "$Level.TimeSeconds;
        WanderOrCamp(true);
    }
    SwitchToBestWeapon();
}

function ChooseAttackMode()
{
    local float EnemyStrength, WeaponRating, RetreatThreshold;

    GoalString = " ChooseAttackMode last seen "$(Level.TimeSeconds - LastSeenTime);
    // should I run away?
    if ( (Squad == None) || (Enemy == None) || (Pawn == None) || (Pawn.Weapon == None))
    {
       return;
   }

    EnemyStrength = RelativeStrength(Enemy);

    if ( Vehicle(Pawn) != None )
    {
        VehicleFightEnemy(true, EnemyStrength);
        return;
    }
    if ( !bFrustrated && !Squad.MustKeepEnemy(Enemy) )
    {
        RetreatThreshold = Aggressiveness;
        if ( Pawn.Weapon.CurrentRating > 0.5 )
            RetreatThreshold = RetreatThreshold + 0.35 - skill * 0.05;
        if ( EnemyStrength > RetreatThreshold )
        {
            GoalString = "Retreat";
            if ( (PlayerReplicationInfo.Team != None) && (FRand() < 0.05) )
                SendMessage(None, 'Other', GetMessageIndex('INJURED'), 15, 'TEAM');
            DoRetreat();
            return;
        }
    }
    if ( (Squad.PriorityObjective(self) == 0) && (Skill + Tactics > 2) && ((EnemyStrength > -0.3) || (Pawn.Weapon.AIRating < 0.5)) )
    {
        if ( Pawn.Weapon.AIRating < 0.5 )
        {
            if ( EnemyStrength > 0.3 )
                WeaponRating = 0;
            else
                WeaponRating = Pawn.Weapon.CurrentRating/2000;
        }
        else if ( EnemyStrength > 0.3 )
            WeaponRating = Pawn.Weapon.CurrentRating/2000;
        else
            WeaponRating = Pawn.Weapon.CurrentRating/1000;

        // fallback to better pickup?
        if ( FindInventoryGoal(WeaponRating) )
        {
            if ( InventorySpot(RouteGoal) == None )
            {
                GoalString = "fallback - inventory goal is not pickup but "$RouteGoal;
           }
            else if(InventorySpot(RouteGoal).markedItem != None)
            {
                GoalString = "Fallback to better pickup "$InventorySpot(RouteGoal).markedItem$" hidden "$InventorySpot(RouteGoal).markedItem.bHidden;
           }
           else
           {
               GoalString = "Fallback NO MarkedItem";
           }

            GotoState('FallBack');
            return;
        }
    }
    GoalString = "ChooseAttackMode FightEnemy";
    FightEnemy(true, EnemyStrength);
}

//fixed access none
function bool NeedWeapon()
{
    local inventory Inv;

    if ( Pawn == None || Vehicle(Pawn) != None )
    {
        return false;
   }

    if ( Pawn.Weapon != None && Pawn.Weapon.AIRating > 0.5 )
    {
        return ( !Pawn.Weapon.HasAmmo() );
   }

    // see if have some other good weapon, currently not in use
    for ( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
    {
        if ( (Weapon(Inv) != None) && (Weapon(Inv).AIRating > 0.5) && Weapon(Inv).HasAmmo() )
        {
            return false;
       }
   }

    return true;
}

function SetPawnClass(string inClass, string inCharacter)
{
   if ( inClass != "" )
   {
       inClass = Level.Game.DefaultPlayerClassName;
   }

   Super.SetPawnClass(inClass, inCharacter);
}

function TryCombo(string ComboName)
{
    if ( !Pawn.InCurrentCombo() && !NeedsAdrenaline() )
    {
        if ( ComboName ~= "Random" )
        {
            ComboName = ComboNames[Rand(ArrayCount(ComboNames))];
       }
       else
       {
           ComboName = Level.Game.NewRecommendCombo(ComboName, self);
       }

        Pawn.DoComboName(ComboName);
    }
}

event SeeMonster(Pawn Seen)
{
    local Pawn CurrentEnemy;

    CurrentEnemy = Enemy;

    if ( !Seen.bAmbientCreature )
        SeePlayer(Seen);

    if ( Enemy != None )
    {
        if (  CurrentEnemy == None )
        {
            if ( InvasionSquad(Squad).IncomingWave != InvasionPro(Level.Game).WaveNum )
            {
                SendMessage(None, 'OTHER', 14, 12, 'TEAM');
                InvasionSquad(Squad).IncomingWave = InvasionPro(Level.Game).WaveNum;
            }
        }
        else if ( (CurrentEnemy != Enemy) && (Pawn.Health < 80) && LineOfSightTo(CurrentEnemy) )
        {
            if ( InvasionSquad(Squad).bHeavyAttack )
                SendMessage(None, 'OTHER', 21, 12, 'TEAM');
            else
                SendMessage(None, 'OTHER', 22, 12, 'TEAM');
            InvasionSquad(Squad).bHeavyAttack = !InvasionSquad(Squad).bHeavyAttack;
        }
    }
}

function float RelativeStrength(Pawn Other)
{
    local float compare;
    local int adjustedOther;

    if ( Pawn == None || Other == None)
    {
        return 0;
    }

    adjustedOther = 0.5 * (Other.health + Other.Default.Health);
    compare = 0.01 * float(adjustedOther - Pawn.health);
    compare = compare - Pawn.AdjustedStrength() + Other.AdjustedStrength();

    if ( Pawn.Weapon != None )
    {
        compare -= 0.5 * Pawn.DamageScaling * Pawn.Weapon.CurrentRating;
        if ( Pawn.Weapon.AIRating < 0.5 )
        {
            compare += 0.3;
            if ( (Other.Weapon != None) && (Other.Weapon.AIRating > 0.5) )
                compare += 0.3;
        }
    }
    if ( Other.Weapon != None )
        compare += 0.5 * Other.DamageScaling * Other.Weapon.AIRating;

    if ( Other.Location.Z > Pawn.Location.Z + TACTICALHEIGHTADVANTAGE )
        compare += 0.2;
    else if ( Pawn.Location.Z > Other.Location.Z + TACTICALHEIGHTADVANTAGE )
        compare -= 0.15;

    return Pawn.ModifyThreat(compare, Other);
}

event Tick( float DeltaTime )
{
   if(Pawn != None && InvasionProPlayerReplicationInfo(PlayerReplicationInfo) != None)
   {
       InvasionProPlayerReplicationInfo(PlayerReplicationInfo).PlayerHealth = Pawn.Health;
       InvasionProPlayerReplicationInfo(PlayerReplicationInfo).PlayerHealthMax = Pawn.SuperHealthMax;
       /*if(xPawn(Pawn) != None)
       {
           if(xPawn(Pawn).CurrentCombo != None)
           {
               if(xPawn(Pawn).CurrentCombo.class == class'xGame.ComboDefensive')
               {
                   InvasionProPlayerReplicationInfo(PlayerReplicationInfo).IconNumber = 1;
               }
               else if(xPawn(Pawn).CurrentCombo.class == class'xGame.ComboSpeed')
               {
                   InvasionProPlayerReplicationInfo(PlayerReplicationInfo).IconNumber = 2;
               }
               else if(xPawn(Pawn).CurrentCombo.class == class'xGame.ComboBerserk')
               {
                   InvasionProPlayerReplicationInfo(PlayerReplicationInfo).IconNumber = 3;
               }
               else if(xPawn(Pawn).CurrentCombo.class == class'xGame.ComboInvis')
               {
                   InvasionProPlayerReplicationInfo(PlayerReplicationInfo).IconNumber = 4;
               }
               else if(xPawn(Pawn).CurrentCombo.class == class'BonusPack.ComboCrate')
               {
                   InvasionProPlayerReplicationInfo(PlayerReplicationInfo).IconNumber = 5;
               }
               else if(xPawn(Pawn).CurrentCombo.class == class'BonusPack.ComboMiniMe')
               {
                   InvasionProPlayerReplicationInfo(PlayerReplicationInfo).IconNumber = 6;
               }
               else
               {
                   InvasionProPlayerReplicationInfo(PlayerReplicationInfo).IconNumber = 7;
               }
           }
           else
           {
               InvasionProPlayerReplicationInfo(PlayerReplicationInfo).IconNumber = 0;
           }
       }*/
   }
   else
   {
       InvasionProPlayerReplicationInfo(PlayerReplicationInfo).PlayerHealth = 0;
       //InvasionProPlayerReplicationInfo(PlayerReplicationInfo).IconNumber = 0;
   }

    Super.Tick(DeltaTime);
}

state TacticalMove
{
ignores SeePlayer, HearNoise;

    function bool IsStrafing()
    {
        return true;
    }

    function SetFall()
    {
        Pawn.Acceleration = vect(0,0,0);
        Destination = Pawn.Location;
        Global.SetFall();
    }

    function bool NotifyHitWall(vector HitNormal, actor Wall)
    {
        local Vehicle V;

        if ( Vehicle(Wall) != None && Vehicle(Pawn) == None )
        {
            if ( Wall == RouteGoal || (Vehicle(RouteGoal) != None && Wall == Vehicle(RouteGoal).GetVehicleBase()) )
            {
                V = Vehicle(Wall).FindEntryVehicle(Pawn);
                if ( V != None )
                {
                    V.UsedBy(Pawn);
                    if (Vehicle(Pawn) != None)
                    {
                        Squad.BotEnteredVehicle(self);
                        WhatToDoNext(55);
                    }
                }
                return true;
            }
            return false;
        }
        if (Pawn.Physics == PHYS_Falling)
        {
            NotifyFallingHitWall(HitNormal, Wall);
            return false;
        }
        if ( Enemy == None )
        {
            WhatToDoNext(18);
            return false;
        }
        if ( bChangeDir || (FRand() < 0.5)
            || (((Enemy.Location - Pawn.Location) Dot HitNormal) < 0) )
        {
            Focus = Enemy;
            WhatToDoNext(19);
        }
        else
        {
            bChangeDir = true;
            Destination = Pawn.Location - HitNormal * FRand() * 500;
        }
        return true;
    }

    function Timer()
    {
        enable('NotifyBump');
        Target = Enemy;
        if ( (Enemy != None) && !bNotifyApex )
            TimedFireWeaponAtEnemy();
        else
            SetCombatTimer();
    }

    function EnemyNotVisible()
    {
        StopFiring();
        if ( enemy != None && aggressiveness > relativestrength(enemy) )
        {
            if ( FastTrace(Enemy.Location, LastSeeingPos) )
                GotoState('TacticalMove','RecoverEnemy');
            else
                WhatToDoNext(20);
        }
        else
        {
           WhatToDoNext(20);
       }

        Disable('EnemyNotVisible');
    }

    function PawnIsInPain(PhysicsVolume PainVolume)
    {
        Destination = Pawn.Location - MINSTRAFEDIST * Normal(Pawn.Velocity);
    }

    function ChangeStrafe()
    {
        local vector Dir;

        Dir = Vector(Pawn.Rotation);
        Destination = Destination +  2 * (Pawn.Location - Destination + Dir * ((Destination - Pawn.Location) Dot Dir));
    }

    /* PickDestination()
    Choose a destination for the tactical move, based on aggressiveness and the tactical
    situation. Make sure destination is reachable
    */
    function PickDestination()
    {
        local vector pickdir, enemydir, enemyPart, Y, LookDir;
        local float strafeSize;
        local bool bFollowingPlayer;

        if ( Pawn == None )
        {
            warn(self$" Tactical move pick destination with no pawn");
            return;
        }
        bChangeDir = false;
        if ( Pawn.PhysicsVolume.bWaterVolume && !Pawn.bCanSwim && Pawn.bCanFly)
        {
            Destination = Pawn.Location + 75 * (VRand() + vect(0,0,1));
            Destination.Z += 100;
            return;
        }

        enemydir = Normal(Enemy.Location - Pawn.Location);
        Y = (enemydir Cross vect(0,0,1));
        if ( Pawn.Physics == PHYS_Walking )
        {
            Y.Z = 0;
            enemydir.Z = 0;
        }
        else
            enemydir.Z = FMax(0,enemydir.Z);

        bFollowingPlayer = ( (PlayerController(Squad.SquadLeader) != None) && (Squad.SquadLeader.Pawn != None)
                            && (VSize(Pawn.Location - Squad.SquadLeader.Pawn.Location) < 1600) );

        strafeSize = FClamp(((2 * Aggression + 1) * FRand() - 0.65),-0.7,0.7);
        if ( Squad.MustKeepEnemy(Enemy) )
            strafeSize = FMax(0.4 * FRand() - 0.2,strafeSize);

        enemyPart = enemydir * strafeSize;
        strafeSize = FMax(0.0, 1 - Abs(strafeSize));
        pickdir = strafeSize * Y;
        if ( bStrafeDir )
            pickdir *= -1;
        if ( bFollowingPlayer )
        {
            // try not to get in front of squad leader
            LookDir = vector(Squad.SquadLeader.Rotation);
            if ( (LookDir dot (Pawn.Location + (enemypart + pickdir)*MINSTRAFEDIST - Squad.SquadLeader.Pawn.Location))
                > FMax(0,(LookDir dot (Pawn.Location + (enemypart - pickdir)*MINSTRAFEDIST - Squad.SquadLeader.Pawn.Location))) )
            {
                bStrafeDir = !bStrafeDir;
                pickdir *= -1;
            }

        }

        bStrafeDir = !bStrafeDir;

        if ( EngageDirection(enemyPart + pickdir, false) )
            return;

        if ( EngageDirection(enemyPart - pickdir,false) )
            return;

        bForcedDirection = true;
        StartTacticalTime = Level.TimeSeconds;
        EngageDirection(EnemyPart + PickDir, true);
    }

    function bool EngageDirection(vector StrafeDir, bool bForced)
    {
        local actor HitActor;
        local vector HitLocation, collspec, MinDest, HitNormal;
        local bool bWantJump;

        // successfully engage direction if can trace out and down
        MinDest = Pawn.Location + MINSTRAFEDIST * StrafeDir;
        if ( !bForced )
        {
            collSpec = Pawn.GetCollisionExtent();
            collSpec.Z = FMax(6, Pawn.CollisionHeight - MAXSTEPHEIGHT);

            bWantJump = (Vehicle(Pawn) == None) && (Pawn.Physics != PHYS_Falling) && ((FRand() < 0.05 * Skill + 0.6 * Jumpiness) || (Pawn.Weapon.SplashJump() && ProficientWithWeapon()))
                && (Enemy.Location.Z - Enemy.CollisionHeight <= Pawn.Location.Z + MAXSTEPHEIGHT - Pawn.CollisionHeight)
                && !NeedToTurn(Enemy.Location);

            HitActor = Trace(HitLocation, HitNormal, MinDest, Pawn.Location, false, collSpec);
            if ( (HitActor != None) && (!bWantJump || !Pawn.bCanWallDodge) )
                return false;

            if ( Pawn.Physics == PHYS_Walking )
            {
                collSpec.X = FMin(14, 0.5 * Pawn.CollisionRadius);
                collSpec.Y = collSpec.X;
                HitActor = Trace(HitLocation, HitNormal, minDest - (3 * MAXSTEPHEIGHT) * vect(0,0,1), minDest, false, collSpec);
                if ( HitActor == None )
                {
                    HitNormal = -1 * StrafeDir;
                    return false;
                }
            }

            if ( bWantJump )
            {
                if ( Pawn.Weapon.SplashJump() )
                    StopFiring();
                    bNotifyApex = true;
                    bTacticalDoubleJump = true;

                // try jump move
                bPlannedJump = true;
                DodgeLandZ = Pawn.Location.Z;
                bInDodgeMove = true;
                Pawn.SetPhysics(PHYS_Falling);
                Pawn.Velocity = SuggestFallVelocity(MinDest, Pawn.Location, 1.5*Pawn.JumpZ, Pawn.GroundSpeed);
                Pawn.Velocity.Z = Pawn.JumpZ;
                Pawn.Acceleration = vect(0,0,0);
                if ( Pawn.bCanWallDodge && (Skill + 2*Jumpiness > 3 + 3*FRand()) )
                    bNotifyFallingHitWall = true;
                Destination = MinDest;
                return true;
            }
        }
        Destination = MinDest + StrafeDir * (0.5 * MINSTRAFEDIST
                                            + FMin(VSize(Enemy.Location - Pawn.Location), MINSTRAFEDIST * (FRand() + FRand())));
        return true;
    }

    event NotifyJumpApex()
    {
        if ( bTacticalDoubleJump && !bPendingDoubleJump && (FRand() < 0.4) && (Skill > 2 + 5 * FRand()) )
        {
            bTacticalDoubleJump = false;
            bNotifyApex = true;
            bPendingDoubleJump = true;
        }
        else if ( Pawn.CanAttack(Enemy) )
            TimedFireWeaponAtEnemy();
        Global.NotifyJumpApex();
    }

    function BeginState()
    {
        bForcedDirection = false;
        if ( Skill < 4 )
            Pawn.MaxDesiredSpeed = 0.4 + 0.08 * skill;
        MinHitWall += 0.15;
        Pawn.bAvoidLedges = true;
        Pawn.bStopAtLedges = true;
        Pawn.bCanJump = false;
        bAdjustFromWalls = false;
        Pawn.bWantsToCrouch = Squad.CautiousAdvance(self);
    }

    function EndState()
    {
        if ( !bPendingDoubleJump )
            bNotifyApex = false;
        bAdjustFromWalls = true;
        if ( Pawn == None )
            return;
        SetMaxDesiredSpeed();
        Pawn.bAvoidLedges = false;
        Pawn.bStopAtLedges = false;
        MinHitWall -= 0.15;
        if (Pawn.JumpZ > 0)
            Pawn.bCanJump = true;
    }

TacticalTick:
    Sleep(0.02);
Begin:
    if ( Enemy == None )
    {
        sleep(0.01);
        Goto('FinishedStrafe');
    }
    if (Pawn.Physics == PHYS_Falling)
    {
        Focus = Enemy;
        Destination = Enemy.Location;
        WaitForLanding();
    }
    if ( Enemy == None )
        Goto('FinishedStrafe');
    PickDestination();

DoMove:
    if ( (Pawn.Weapon != None) && Pawn.Weapon.FocusOnLeader(false) )
        MoveTo(Destination, Focus);
    else if ( !Pawn.bCanStrafe )
    {
        StopFiring();
        MoveTo(Destination);
    }
    else
    {
DoStrafeMove:
        MoveTo(Destination, Enemy);
    }
    if ( bForcedDirection && (Level.TimeSeconds - StartTacticalTime < 0.2) )
    {
        if ( !Pawn.HasWeapon() || Skill > 2 + 3 * FRand() )
        {
            bMustCharge = true;
            WhatToDoNext(51);
        }
        GoalString = "RangedAttack from failed tactical";
        DoRangedAttackOn(Enemy);
    }
    if ( (Enemy == None) || EnemyVisible() || !FastTrace(Enemy.Location, LastSeeingPos) || (Pawn.Weapon != None && Pawn.Weapon.bMeleeWeapon) )
        Goto('FinishedStrafe');

RecoverEnemy:
    GoalString = "Recover Enemy";
    HidingSpot = Pawn.Location;
    StopFiring();
    Sleep(0.1 + 0.2 * FRand());
    Destination = LastSeeingPos + 4 * Pawn.CollisionRadius * Normal(LastSeeingPos - Pawn.Location);
    MoveTo(Destination, Enemy);

    if ( FireWeaponAt(Enemy) )
    {
        Pawn.Acceleration = vect(0,0,0);
        if ( (Pawn.Weapon != None) && Pawn.Weapon.SplashDamage() )
        {
            StopFiring();
            Sleep(0.05);
        }
        else
            Sleep(0.1 + 0.3 * FRand() + 0.06 * (7 - FMin(7,Skill)));
        if ( (FRand() + 0.3 > Aggression) )
        {
            Enable('EnemyNotVisible');
            Destination = HidingSpot + 4 * Pawn.CollisionRadius * Normal(HidingSpot - Pawn.Location);
            Goto('DoMove');
        }
    }
FinishedStrafe:
    WhatToDoNext(21);
    if ( bSoaking )
        SoakStop("STUCK IN TACTICAL MOVE!");
}

state Dead
{
ignores SeePlayer, EnemyNotVisible, HearNoise, ReceiveWarning, NotifyLanded, NotifyPhysicsVolumeChange,
        NotifyHeadVolumeChange,NotifyLanded,NotifyHitWall,NotifyBump;

    event DelayedWarning() {}

    function DoRangedAttackOn(Actor A)
    {
    }

    function WhatToDoNext(byte CallingByte)
    {
        //log(self$" WhatToDoNext while dead CALLED BY "$CallingByte);
    }

    function Celebrate()
    {
        //log(self$" Celebrate while dead");
    }

    function bool SetRouteToGoal(Actor A)
    {
        //log(self$" SetRouteToGoal while dead");
       return true;
    }

    function SetAttractionState()
    {
       // log(self$" SetAttractionState while dead");
    }

    function EnemyChanged(bool bNewEnemyVisible)
    {
        //log(self$" EnemyChanged while dead");
    }

    function WanderOrCamp(bool bMayCrouch)
    {
        //log(self$" WanderOrCamp while dead");
    }

    function Timer() {}

    function BeginState()
    {
        if ( Level.Game.TooManyBots(self) )
        {
            Destroy();
            return;
        }
        if ( (GoalScript != None) && (HoldSpot(GoalScript) == None) )
            FreeScript();
        if ( NavigationPoint(MoveTarget) != None )
            NavigationPoint(MoveTarget).FearCost = 2 * NavigationPoint(MoveTarget).FearCost + 600;
        Enemy = None;
        StopFiring();
        FormerVehicle = None;
        bFrustrated = false;
        BlockedPath = None;
        bInitLifeMessage = false;
        bPlannedJump = false;
        bInDodgeMove = false;
        bReachedGatherPoint = false;
        bFinalStretch = false;
        bWasNearObjective = false;
        bPreparingMove = false;
        bEnemyEngaged = false;
        bPursuingFlag = false;
        bHasSuperWeapon = false;
        RouteGoal = None;
        MoveTarget = None;
    }

Begin:
    if ( Level.Game.bGameEnded )
    {
        GotoState('GameEnded');
   }

    Sleep(0.2);

TryAgain:
    if ( UnrealMPGameInfo(Level.Game) == None )
    {
        Destroy();
   }
    else
    {
        Sleep(0.25 + UnrealMPGameInfo(Level.Game).SpawnWait(self));
        LastRespawnTime = Level.TimeSeconds;
        Level.Game.ReStartPlayer(self);
        Goto('TryAgain');
    }

MPStart:
    Sleep(0.75 + FRand());
    Level.Game.ReStartPlayer(self);
    Goto('TryAgain');
}

defaultproperties
{
     PlayerReplicationInfoClass=Class'TURInvPro.InvasionProPlayerReplicationInfo'
}
