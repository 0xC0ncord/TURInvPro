//=============================================================================
// InvasionProMonsterTable.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProMonsterTable extends Object config(TURInvPro);

struct MonsterNames
{
   var() bool bSetup;
   var() string MonsterName;
   var() string MonsterClassName;
   var() int NumSpawns;
   var() int NumDamage;
   var() int NumKills;
   var() int NewHealth;
   var() int NewMaxHealth;
   var() float NewGroundSpeed;
   var() float NewAirSpeed;
   var() float NewWaterSpeed;
   var() float NewJumpZ;
   var() int NewScoreAward;
   var() float NewGibMultiplier;
   var() float NewGibSizeMultiplier;
   var() float NewDrawScale;
   var() float NewCollisionHeight;
   var() float NewCollisionRadius;
   var() vector NewPrePivot;
   var() float DamageMultiplier;
   var() bool bRandomHealth;
   var() bool bRandomSpeed;
   var() bool bRandomSize;
};

var() config Array<MonsterNames> MonsterTable;

struct TacticalData
{
   var() string MonsterName;
   var() string BioData;
};

var() config Array<TacticalData> MonsterDescription;

defaultproperties
{
     MonsterTable(0)=(bSetup=True,MonsterName="None",MonsterClassName="None")
     MonsterTable(1)=(bSetup=True,MonsterName="[UT2] Skaarj Pupae",MonsterClassName="SkaarjPack.SkaarjPupae",NumSpawns=177,NumDamage=128,NumKills=15,NewHealth=60,NewMaxHealth=100,NewGroundSpeed=300.000000,NewAirSpeed=440.000000,NewWaterSpeed=300.000000,NewJumpZ=450.000000,NewScoreAward=1,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=12.000000,NewCollisionRadius=28.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(2)=(bSetup=True,MonsterName="[UT2] Razor Fly",MonsterClassName="SkaarjPack.Razorfly",NumSpawns=165,NumDamage=60,NumKills=7,NewHealth=35,NewMaxHealth=100,NewGroundSpeed=440.000000,NewAirSpeed=300.000000,NewWaterSpeed=220.000000,NewJumpZ=340.000000,NewScoreAward=1,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=11.000000,NewCollisionRadius=18.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(3)=(bSetup=True,MonsterName="[UT2] Manta",MonsterClassName="SkaarjPack.Manta",NumSpawns=134,NumDamage=260,NumKills=11,NewHealth=100,NewMaxHealth=100,NewGroundSpeed=440.000000,NewAirSpeed=400.000000,NewWaterSpeed=300.000000,NewJumpZ=340.000000,NewScoreAward=1,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=12.000000,NewCollisionRadius=25.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(4)=(bSetup=True,MonsterName="[UT2] Krall",MonsterClassName="SkaarjPack.Krall",NumSpawns=45,NumDamage=175,NumKills=6,NewHealth=100,NewMaxHealth=100,NewGroundSpeed=440.000000,NewAirSpeed=440.000000,NewWaterSpeed=220.000000,NewJumpZ=550.000000,NewScoreAward=2,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=44.000000,NewCollisionRadius=25.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(5)=(bSetup=True,MonsterName="[UT2] Elite Krall",MonsterClassName="SkaarjPack.EliteKrall",NewHealth=100,NewMaxHealth=100,NewGroundSpeed=440.000000,NewAirSpeed=440.000000,NewWaterSpeed=220.000000,NewJumpZ=550.000000,NewScoreAward=3,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=44.000000,NewCollisionRadius=25.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(6)=(bSetup=True,MonsterName="[UT2] Gasbag",MonsterClassName="SkaarjPack.Gasbag",NumSpawns=10,NumDamage=126,NewHealth=150,NewMaxHealth=100,NewGroundSpeed=440.000000,NewAirSpeed=330.000000,NewWaterSpeed=220.000000,NewJumpZ=340.000000,NewScoreAward=4,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=36.000000,NewCollisionRadius=47.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(7)=(bSetup=True,MonsterName="[UT2] Brute",MonsterClassName="SkaarjPack.Brute",NewHealth=220,NewMaxHealth=100,NewGroundSpeed=150.000000,NewAirSpeed=440.000000,NewWaterSpeed=100.000000,NewJumpZ=100.000000,NewScoreAward=5,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=52.000000,NewCollisionRadius=47.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(8)=(bSetup=True,MonsterName="[UT2] Skaarj",MonsterClassName="SkaarjPack.Skaarj",NewHealth=150,NewMaxHealth=100,NewGroundSpeed=440.000000,NewAirSpeed=440.000000,NewWaterSpeed=220.000000,NewJumpZ=550.000000,NewScoreAward=6,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=44.000000,NewCollisionRadius=25.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(9)=(bSetup=True,MonsterName="[UT2] Behemoth",MonsterClassName="SkaarjPack.Behemoth",NewHealth=260,NewMaxHealth=100,NewGroundSpeed=150.000000,NewAirSpeed=440.000000,NewWaterSpeed=100.000000,NewJumpZ=100.000000,NewScoreAward=6,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=52.000000,NewCollisionRadius=47.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(10)=(bSetup=True,MonsterName="[UT2] Ice Skaarj",MonsterClassName="SkaarjPack.IceSkaarj",NewHealth=150,NewMaxHealth=100,NewGroundSpeed=440.000000,NewAirSpeed=440.000000,NewWaterSpeed=220.000000,NewJumpZ=550.000000,NewScoreAward=6,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=44.000000,NewCollisionRadius=25.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(11)=(bSetup=True,MonsterName="[UT2] Fire Skaarj",MonsterClassName="SkaarjPack.FireSkaarj",NewHealth=150,NewMaxHealth=100,NewGroundSpeed=440.000000,NewAirSpeed=440.000000,NewWaterSpeed=220.000000,NewJumpZ=550.000000,NewScoreAward=7,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=44.000000,NewCollisionRadius=25.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(12)=(bSetup=True,MonsterName="[UT2] WarLord",MonsterClassName="SkaarjPack.WarLord",NewHealth=500,NewMaxHealth=100,NewGroundSpeed=400.000000,NewAirSpeed=500.000000,NewWaterSpeed=220.000000,NewJumpZ=340.000000,NewScoreAward=10,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=78.000000,NewCollisionRadius=47.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(13)=(bSetup=True,MonsterName="[SMP] Queen",MonsterClassName="satoreMonsterPackv120.SMPQueen",NewHealth=800,NewMaxHealth=100,NewGroundSpeed=600.000000,NewAirSpeed=440.000000,NewWaterSpeed=220.000000,NewJumpZ=800.000000,NewScoreAward=14,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=106.000000,NewCollisionRadius=90.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(14)=(bSetup=True,MonsterName="[SMP] Titan",MonsterClassName="satoreMonsterPackv120.SMPTitan",NewHealth=900,NewMaxHealth=100,NewGroundSpeed=500.000000,NewAirSpeed=440.000000,NewWaterSpeed=220.000000,NewScoreAward=16,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=115.000000,NewCollisionRadius=110.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(15)=(bSetup=True,MonsterName="[SMP] Stone Titan",MonsterClassName="satoreMonsterPackv120.SMPStoneTitan",NewHealth=900,NewMaxHealth=100,NewGroundSpeed=500.000000,NewAirSpeed=440.000000,NewWaterSpeed=220.000000,NewScoreAward=16,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=115.000000,NewCollisionRadius=110.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(16)=(bSetup=True,MonsterName="[SMP] Mercenary",MonsterClassName="satoreMonsterPackv120.SMPMercenary",NewHealth=180,NewMaxHealth=100,NewGroundSpeed=385.000000,NewAirSpeed=300.000000,NewWaterSpeed=220.000000,NewJumpZ=340.000000,NewScoreAward=7,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=48.000000,NewCollisionRadius=35.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(17)=(bSetup=True,MonsterName="[SMP] Elite Mercenary",MonsterClassName="satoreMonsterPackv120.SMPMercenaryElite",NewHealth=240,NewMaxHealth=100,NewGroundSpeed=385.000000,NewAirSpeed=300.000000,NewWaterSpeed=220.000000,NewJumpZ=340.000000,NewScoreAward=8,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=48.000000,NewCollisionRadius=35.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(18)=(bSetup=True,MonsterName="[SMP] Slith",MonsterClassName="satoreMonsterPackv120.SMPSlith",NewHealth=210,NewMaxHealth=100,NewGroundSpeed=370.000000,NewAirSpeed=440.000000,NewWaterSpeed=350.000000,NewJumpZ=120.000000,NewScoreAward=6,NewGibMultiplier=4.284186,NewGibSizeMultiplier=3.772992,NewDrawScale=1.000000,NewCollisionHeight=47.000000,NewCollisionRadius=48.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(19)=(bSetup=True,MonsterName="[SMP] Skaarj Trooper",MonsterClassName="satoreMonsterPackv120.SMPSkaarjTrooper",NewHealth=200,NewMaxHealth=100,NewGroundSpeed=440.000000,NewAirSpeed=440.000000,NewWaterSpeed=220.000000,NewJumpZ=550.000000,NewScoreAward=6,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=42.000000,NewCollisionRadius=25.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(20)=(bSetup=True,MonsterName="[SMP] Skaarj Sniper",MonsterClassName="satoreMonsterPackv120.SMPSkaarjSniper",NewHealth=200,NewMaxHealth=100,NewGroundSpeed=440.000000,NewAirSpeed=440.000000,NewWaterSpeed=220.000000,NewJumpZ=550.000000,NewScoreAward=6,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=42.000000,NewCollisionRadius=25.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(21)=(bSetup=True,MonsterName="[SMP] Giant Gasbag",MonsterClassName="satoreMonsterPackv120.SMPGiantGasbag",NewHealth=600,NewMaxHealth=100,NewGroundSpeed=440.000000,NewAirSpeed=330.000000,NewWaterSpeed=220.000000,NewJumpZ=340.000000,NewScoreAward=8,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=3.000000,NewCollisionHeight=90.000000,NewCollisionRadius=160.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(22)=(bSetup=True,MonsterName="[SMP] DevilFish",MonsterClassName="satoreMonsterPackv120.SMPDevilFish",NewHealth=70,NewMaxHealth=100,NewGroundSpeed=440.000000,NewAirSpeed=440.000000,NewWaterSpeed=250.000000,NewJumpZ=340.000000,NewScoreAward=1,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=20.000000,NewCollisionRadius=35.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(23)=(bSetup=True,MonsterName="[SMP] MetalSkaarj",MonsterClassName="satoreMonsterPackv120.SMPMetalSkaarj",NewHealth=150,NewMaxHealth=100,NewGroundSpeed=440.000000,NewAirSpeed=440.000000,NewWaterSpeed=220.000000,NewJumpZ=550.000000,NewScoreAward=7,NewGibMultiplier=2.166382,NewGibSizeMultiplier=4.016418,NewDrawScale=1.000000,NewCollisionHeight=44.000000,NewCollisionRadius=25.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(24)=(bSetup=True,MonsterName="[SMP] NaliFighter",MonsterClassName="satoreMonsterPackv120.SMPNaliFighter",NewHealth=70,NewMaxHealth=100,NewGroundSpeed=440.000000,NewAirSpeed=440.000000,NewWaterSpeed=220.000000,NewJumpZ=340.000000,NewScoreAward=3,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=44.000000,NewCollisionRadius=25.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(25)=(bSetup=True,MonsterName="[SMP] Nali",MonsterClassName="satoreMonsterPackv120.SMPNali",NewHealth=50,NewMaxHealth=100,NewGroundSpeed=440.000000,NewAirSpeed=440.000000,NewWaterSpeed=220.000000,NewJumpZ=340.000000,NewScoreAward=1,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=44.000000,NewCollisionRadius=25.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(26)=(bSetup=True,MonsterName="[SMP] Nali Cow",MonsterClassName="satoreMonsterPackv120.SMPNaliCow",NewHealth=80,NewMaxHealth=100,NewGroundSpeed=440.000000,NewAirSpeed=440.000000,NewWaterSpeed=220.000000,NewJumpZ=340.000000,NewScoreAward=1,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=35.000000,NewCollisionRadius=40.000000,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterTable(27)=(bSetup=True,MonsterName="[SMP] Nali Rabbit",MonsterClassName="satoreMonsterPackv120.SMPNaliRabbit",NewHealth=5,NewMaxHealth=100,NewGroundSpeed=400.000000,NewAirSpeed=440.000000,NewWaterSpeed=220.000000,NewJumpZ=200.000000,NewScoreAward=1,NewGibMultiplier=1.000000,NewGibSizeMultiplier=1.000000,NewDrawScale=1.000000,NewCollisionHeight=13.300000,NewCollisionRadius=18.299999,NewPrePivot=(Z=-5.000000),DamageMultiplier=1.000000)
     MonsterDescription(0)=(MonsterName="None",BioData="No Data Found")
     MonsterDescription(1)=(MonsterName="[UT2] Skaarj Pupae",BioData="The Pupae is a relatively slow moving monster. It causes minimal damage but due to its small size, is able to go where most other monsters cannot.")
     MonsterDescription(2)=(MonsterName="[UT2] Razor Fly",BioData="This flying monster is slow moving. The low damage this monster causes is not significant enough to be worth considered an immediate threat.")
     MonsterDescription(3)=(MonsterName="[UT2] Manta",BioData="This graceful flying monster moves at a medium speed. It is melee only.")
     MonsterDescription(4)=(MonsterName="[UT2] Krall",BioData="The primitive Krall have only melee attacks but they are very determined. Even losing legs wont stop them!")
     MonsterDescription(5)=(MonsterName="[UT2] Elite Krall",BioData="The elite version of the Krall carries a magic wand that it uses to shoot magic at its enemies.")
     MonsterDescription(6)=(MonsterName="[UT2] Gasbag",BioData="The Gasbag floats lazily around and although it does have melee attacks it prefers to attack from afar.")
     MonsterDescription(7)=(MonsterName="[UT2] Brute",BioData="The Brute is big, slow and mean. Its twin rocket launchers can cause massive damage in a short time.")
     MonsterDescription(8)=(MonsterName="[UT2] Skaarj",BioData="The Skaarj, the main infantry of all the monsters. They are agile and fast. However their magic can be reflected with the Shield Gun.")
     MonsterDescription(9)=(MonsterName="[UT2] Behemoth",BioData="The Behemoth is even bigger and badder and slower than the Brute.")
     MonsterDescription(10)=(MonsterName="[UT2] Ice Skaarj",BioData="The Ice Skaarj prefers a cold habitat and is slightly more dangerous than the normal Skaarj.")
     MonsterDescription(11)=(MonsterName="[UT2] Fire Skaarj",BioData="The Fire Skaarj prefers a warmer habitat and is even more dangerous than the Ice Skaarj.")
     MonsterDescription(12)=(MonsterName="[UT2] WarLord",BioData="The boss of all the other monsters, the Warlord is very dangerous, especially when roaming in packs. They have both ranged and melee attacks and can even fly.")
}
