class InvasionProHudConfig extends GUICustomPropertyPage;

var() Automated GUIMultiOptionListBox currentScrollContainer;
var() Automated moSlider MonsterColorR;
var() Automated moSlider MonsterColorG;
var() Automated moSlider MonsterColorB;
var() Automated moSlider MonsterDotScale;
var() Automated moSlider PlayerColorR;
var() Automated moSlider PlayerColorG;
var() Automated moSlider PlayerColorB;
var() Automated moSlider FriendlyPlayerDotScale;
var() Automated moSlider OwnerColorR;
var() Automated moSlider OwnerColorG;
var() Automated moSlider OwnerColorB;
var() Automated moSlider OwnerDotScale;
var() Automated moSlider FriendlyMonsterColorR;
var() Automated moSlider FriendlyMonsterColorG;
var() Automated moSlider FriendlyMonsterColorB;
var() Automated moSlider FriendlyMonsterDotScale;
var() Automated moSlider MiscColorR;
var() Automated moSlider MiscColorG;
var() Automated moSlider MiscColorB;
var() Automated moSlider MiscDotScale;
var() Automated moSlider RadarColorR;
var() Automated moSlider RadarColorG;
var() Automated moSlider RadarColorB;
var() Automated moSlider RadarColorA;
var() Automated moSlider PulseColorR;
var() Automated moSlider PulseColorG;
var() Automated moSlider PulseColorB;
var() Automated moSlider PulseColorA;
var() Automated moSlider RadarScale;
var() Automated moSlider RadarPosX;
var() Automated moSlider RadarPosY;
var() Automated moSlider PlayerListY;
var() Automated GUILabel RadarPreviewLabel;
var() Automated GUILabel ColorUpdateLabel;

var() Automated GUILabel MonsterLabel;
var() Automated GUILabel FriendlyMonsterLabel;
var() Automated GUILabel PlayerLabel;
var() Automated GUILabel OwnerLabel;
var() Automated GUILabel MiscLabel;

var() Automated moCheckBox bHideRadar;
var() Automated moCheckBox bDisplayMonsterCounter;
var() Automated moCheckBox bNoRadarSound;
var() Automated moCheckBox bClassicRadar;
#ifeq ENABLE_TURINVX_RADAR 1
var() Automated moCheckBox bTURRadar;
#endif
var() Automated moCheckBox bRadarShowElevationAsDistance;
//var() Automated moCheckBox bDisplayNecroPool;
var() Automated moCheckBox bDisplayPlayerList;
var() Automated moCheckBox bSpecMonsters;
var() Automated moCheckBox bStartThirdPerson;
//var() Automated moCheckBox bDisplayMonsterHealthBars;
var() Automated moCheckBox bDisplayBossNames;
var() Automated moCheckBox bDisplayBossTimer;
var() Automated moCheckBox bAddFriendlyMonstersToPlayerList;
var() Automated moCheckBox bAddFriendlyMonstersToScoreboard;
var() Automated moComboBox RadarTexture;
var() Automated moComboBox PulseTexture;
var() Automated moComboBox OwnerIconTexture;
var() Automated moComboBox FriendlyPlayerIconTexture;
var() Automated moComboBox FriendlyMonsterIconTexture;
var() Automated moComboBox MonsterIconTexture;
var() Automated moComboBox MiscIconTexture;
var() Automated GUIImage PulseImage;
var() Automated GUIImage RadarImage;
var() Automated GUIImage MonsterIcon;
var() Automated GUIImage FriendlyPlayerIcon;
var() Automated GUIImage FriendlyMonsterIcon;
var() Automated GUIImage OwnerIcon;
var() Automated GUIImage MiscIcon;
var() array<string> RadarStyle;
var() array<string> PulseStyle;
var() float PulseWidth;
var() float PulseOffsetX, PulseOffsetY;
var() Automated moComboBox currentKillSound;
var() Automated moSlider KillSoundVolume;
var() Automated moComboBox currentEnemyHitSound;
var() Automated moComboBox currentFriendlyHitSound;
var() Automated moSlider HitSoundVolume;
var() Automated moSlider MaxHitSoundsPerSecond;
var() Automated moCheckBox bDynamicHitSounds;
var() InvasionProHud BaseHUD;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;
    local bool bTemp;
    local string PackageLeft, PackageRight, TestString;

    Super.InitComponent(MyController, MyOwner);

    BaseHUD = InvasionProHud(PlayerOwner().myHUD);

    sb_Main.Caption = "Hud Configuration";
    sb_Main.bScaleToParent = true;
    sb_Main.WinWidth=0.932639;
    sb_Main.WinHeight=0.930252;
    sb_Main.WinLeft=0.037070;
    sb_Main.WinTop=0.050586;

    t_WindowTitle.Caption = "InvasionPro";

    //resize ok/defaults button
    b_OK.WinWidth = default.b_OK.WinWidth;
    b_OK.WinHeight = default.b_OK.WinHeight;
    b_OK.WinLeft = default.b_OK.WinLeft;
    b_OK.WinTop = default.b_OK.WinTop;

    //resize save/close button
    b_Cancel.WinWidth = default.b_Cancel.WinWidth;
    b_Cancel.WinHeight = default.b_Cancel.WinHeight;
    b_Cancel.WinLeft = default.b_Cancel.WinLeft;
    b_Cancel.WinTop = default.b_Cancel.WinTop;

    i_FrameBG.ImageRenderStyle = MSTY_Translucent;

    if(ParentPage != None)
    {
        ParentPage.bRequire640x480 = False;
    }

    bTemp = Controller.bCurMenuInitialized;
    Controller.bCurMenuInitialized = False;

    currentScrollContainer.List.ColumnWidth = 0.995;

    bHideRadar = moCheckBox(currentScrollContainer.List.AddItem("XInterface.moCheckBox", ,"Hide Radar",true));
    bHideRadar.ToolTip.SetTip("Check this box to hide the radar if the server has it enabled.");
    bHideRadar.OnChange = InternalOnChange;

    bClassicRadar = moCheckBox(currentScrollContainer.List.AddItem("XInterface.moCheckBox", ,"Classic Radar",true));
    bClassicRadar.ToolTip.SetTip("Check this box to revert back to the original invasion radar.");
    bClassicRadar.OnChange = InternalOnChange;

#ifeq ENABLE_TURINVX_RADAR 1
    bTURRadar = moCheckBox(currentScrollContainer.List.AddItem("XInterface.moCheckBox", ,"TUR Invasion-X Radar",true));
    bTURRadar.ToolTip.SetTip("Check this box to revert back to the modified TUR Invasion-X radar.");
    bTURRadar.OnChange = InternalOnChange;
#endif

    bNoRadarSound = moCheckBox(currentScrollContainer.List.AddItem("XInterface.moCheckBox", ,"No Radar Sound",true));
    bNoRadarSound.ToolTip.SetTip("Check this box to turn off the radar sound.");

    bRadarShowElevationAsDistance = moCheckBox(currentScrollContainer.List.AddItem("XInterface.moCheckBox", ,"Show Elevation as Distance",true));
    bRadarShowElevationAsDistance.ToolTip.SetTip("If checked, elevation differences between yourself and other radar dots will be represented by moving them further away. If unchecked, entities that are above you will be displayed as larger dots and entities below you will be displayed as smaller dots.");

    RadarScale = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Radar Scale",true));
    RadarScale.Setup(0, 1, false);
    RadarScale.ToolTip.SetTip("How large the radar should be.");

    RadarPosX = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Radar Position X",true));
    RadarPosX.Setup(0, 1, false);
    RadarPosX.ToolTip.SetTip("Where the radar is positioned on the X axis.");
    RadarPosY = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Radar Position Y",true));
    RadarPosY.Setup(0, 1, false);
    RadarPosY.ToolTip.SetTip("Where the radar is positioned on the Y axis.");

    RadarTexture = moComboBox(currentScrollContainer.List.AddItem("XInterface.moComboBox", ,"Radar Style",true));
    RadarTexture.ToolTip.SetTip("Choose a radar style.");
    RadarTexture.bReadOnly = True;
    RadarTexture.OnChange = InternalOnChange;

    PulseTexture = moComboBox(currentScrollContainer.List.AddItem("XInterface.moComboBox", ,"Pulse Style",true));
    PulseTexture.ToolTip.SetTip("Choose a pulse style.");
    PulseTexture.bReadOnly = True;
    PulseTexture.OnChange = InternalOnChange;

    OwnerIconTexture = moComboBox(currentScrollContainer.List.AddItem("XInterface.moComboBox", ,"Owner Icon",true));
    OwnerIconTexture.ToolTip.SetTip("Choose an icon for the player.");
    OwnerIconTexture.bReadOnly = True;
    OwnerIconTexture.OnChange = InternalOnChange;

    FriendlyPlayerIconTexture = moComboBox(currentScrollContainer.List.AddItem("XInterface.moComboBox", ,"Player Icon",true));
    FriendlyPlayerIconTexture.ToolTip.SetTip("Choose an icon for other players.");
    FriendlyPlayerIconTexture.bReadOnly = True;
    FriendlyPlayerIconTexture.OnChange = InternalOnChange;

    FriendlyMonsterIconTexture = moComboBox(currentScrollContainer.List.AddItem("XInterface.moComboBox", ,"Friendly Icon",true));
    FriendlyMonsterIconTexture.ToolTip.SetTip("Choose an icon for friendly monsters.");
    FriendlyMonsterIconTexture.bReadOnly = True;
    FriendlyMonsterIconTexture.OnChange = InternalOnChange;

    MonsterIconTexture = moComboBox(currentScrollContainer.List.AddItem("XInterface.moComboBox", ,"Enemy Icon",true));
    MonsterIconTexture.ToolTip.SetTip("Choose an icon for enemies.");
    MonsterIconTexture.bReadOnly = True;
    MonsterIconTexture.OnChange = InternalOnChange;

    MiscIconTexture = moComboBox(currentScrollContainer.List.AddItem("XInterface.moComboBox", ,"Misc Icon",true));
    MiscIconTexture.ToolTip.SetTip("Choose an icon for miscellaneous entities.");
    MiscIconTexture.bReadOnly = True;
    MiscIconTexture.OnChange = InternalOnChange;

    RadarColorR = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Radar Red",true));
    RadarColorR.Setup(0, 255, true);
    RadarColorR.ToolTip.SetTip("How much Red the radar receives.");

    RadarColorG = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Radar Green",true));
    RadarColorG.Setup(0, 255, true);
    RadarColorG.ToolTip.SetTip("How much Green the radar receives.");

    RadarColorB = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Radar Blue",true));
    RadarColorB.Setup(0, 255, true);
    RadarColorB.ToolTip.SetTip("How much Blue the radar receives.");

    RadarColorA = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Radar Alpha",true));
    RadarColorA.Setup(0, 255, true);
    RadarColorA.ToolTip.SetTip("How much Alpha the radar receives.");

    PulseColorR = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Radar Pulse Red",true));
    PulseColorR.Setup(0, 255, true);
    PulseColorR.ToolTip.SetTip("How much Red the radar pulse receives.");

    PulseColorG = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Radar Pulse Green",true));
    PulseColorG.Setup(0, 255, true);
    PulseColorG.ToolTip.SetTip("How much Green the radar pulse receives.");

    PulseColorB = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Radar Pulse Blue",true));
    PulseColorB.Setup(0, 255, true);
    PulseColorB.ToolTip.SetTip("How much Blue the radar pulse receives.");

    PulseColorA = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Radar Pulse Alpha",true));
    PulseColorA.Setup(0, 255, true);
    PulseColorA.ToolTip.SetTip("How much Alpha the radar pulse receives.");

    OwnerDotScale = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Owner Beacon Scale",true));
    OwnerDotScale.Setup(0, 5, false);
    OwnerDotScale.ToolTip.SetTip("How large the owner beacon should be.");

    OwnerColorR = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Owner Beacon Red",true));
    OwnerColorR.Setup(0, 255, true);
    OwnerColorR.ToolTip.SetTip("How much Red the owner beacon receives.");

    OwnerColorG = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Owner Beacon Green",true));
    OwnerColorG.Setup(0, 255, true);
    OwnerColorG.ToolTip.SetTip("How much Green the owner beacon receives.");

    OwnerColorB = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Owner Beacon Blue",true));
    OwnerColorB.Setup(0, 255, true);
    OwnerColorB.ToolTip.SetTip("How much Blue the owner beacon receives.");

    FriendlyPlayerDotScale = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Player Beacon Scale",true));
    FriendlyPlayerDotScale.Setup(0, 5, false);
    FriendlyPlayerDotScale.ToolTip.SetTip("How large the player beacon should be.");

    PlayerColorR = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Player Beacon Red",true));
    PlayerColorR.Setup(0, 255, true);
    PlayerColorR.ToolTip.SetTip("How much Red the friendly player beacon receives.");

    PlayerColorG = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Player Beacon Green",true));
    PlayerColorG.Setup(0, 255, true);
    PlayerColorG.ToolTip.SetTip("How much Green the friendly player beacon receives.");

    PlayerColorB = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Player Beacon Blue",true));
    PlayerColorB.Setup(0, 255, true);
    PlayerColorB.ToolTip.SetTip("How much Blue the friendly player beacon receives.");

    FriendlyMonsterDotScale = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Friendly Beacon Scale",true));
    FriendlyMonsterDotScale.Setup(0, 5, false);
    FriendlyMonsterDotScale.ToolTip.SetTip("How large the friendly monster beacon should be.");

    FriendlyMonsterColorR = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Friendly Beacon Red",true));
    FriendlyMonsterColorR.Setup(0, 255, true);
    FriendlyMonsterColorR.ToolTip.SetTip("How much Red the friendly monster beacon receives.");

    FriendlyMonsterColorG = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Friendly Beacon Green",true));
    FriendlyMonsterColorG.Setup(0, 255, true);
    FriendlyMonsterColorG.ToolTip.SetTip("How much Green the friendly monster beacon receives.");

    FriendlyMonsterColorB = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Friendly Beacon Blue",true));
    FriendlyMonsterColorB.Setup(0, 255, true);
    FriendlyMonsterColorB.ToolTip.SetTip("How much Blue the friendly monster beacon receives.");

    MonsterDotScale = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Monster Beacon Scale",true));
    MonsterDotScale.Setup(0, 5, false);
    MonsterDotScale.ToolTip.SetTip("How large the enemy monster beacon should be.");

    MonsterColorR = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Monster Beacon Red",true));
    MonsterColorR.Setup(0, 255, true);
    MonsterColorR.ToolTip.SetTip("How much Red the enemy monster beacon receives.");

    MonsterColorG = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Monster Beacon Green",true));
    MonsterColorG.Setup(0, 255, true);
    MonsterColorG.ToolTip.SetTip("How much Green the enemy monster beacon receives.");

    MonsterColorB = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Monster Beacon Blue",true));
    MonsterColorB.Setup(0, 255, true);
    MonsterColorB.ToolTip.SetTip("How much Blue the enemy monster beacon receives.");

    MiscDotScale = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Misc Beacon Scale",true));
    MiscDotScale.Setup(0, 5, false);
    MiscDotScale.ToolTip.SetTip("How large the miscellaneous beacon should be.");

    MiscColorR = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Misc Beacon Red",true));
    MiscColorR.Setup(0, 255, true);
    MiscColorR.ToolTip.SetTip("How much Red the miscellaneous beacon receives.");

    MiscColorG = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Misc Beacon Green",true));
    MiscColorG.Setup(0, 255, true);
    MiscColorG.ToolTip.SetTip("How much Green the miscellaneous beacon receives.");

    MiscColorB = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Misc Beacon Blue",true));
    MiscColorB.Setup(0, 255, true);
    MiscColorB.ToolTip.SetTip("How much Blue the miscellaneous beacon receives.");

    bDisplayMonsterCounter = moCheckBox(currentScrollContainer.List.AddItem("XInterface.moCheckBox", ,"Display Monster Counter",true));
    bDisplayMonsterCounter.ToolTip.SetTip("Check this box to enable the monster counter.");
    bDisplayPlayerList = moCheckBox(currentScrollContainer.List.AddItem("XInterface.moCheckBox", ,"View Player List",true));
    bDisplayPlayerList.ToolTip.SetTip("Check this box to display the player list.");
    PlayerListY = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Player List Y",true));
    PlayerListY.Setup(0, 1, false);
    PlayerListY.ToolTip.SetTip("Where the player list is positioned on the Y axis.");
    bAddFriendlyMonstersToPlayerList = moCheckBox(currentScrollContainer.List.AddItem("XInterface.moCheckBox", ,"Add Friendly Monsters To List",true));
    bAddFriendlyMonstersToPlayerList.ToolTip.SetTip("Check this box to display friendly monsters on the player list.");
    bAddFriendlyMonstersToScoreboard = moCheckBox(currentScrollContainer.List.AddItem("XInterface.moCheckBox", ,"Add Friendly Monsters To Scoreboard",true));
    bAddFriendlyMonstersToScoreboard.ToolTip.SetTip("Check this box to display friendly monsters on the scoreboard.");

    bSpecMonsters = moCheckBox(currentScrollContainer.List.AddItem("XInterface.moCheckBox", ,"Spectate Monsters",true));
    bSpecMonsters.ToolTip.SetTip("Check this box to enable monster spectating.");
    bStartThirdPerson = moCheckBox(currentScrollContainer.List.AddItem("XInterface.moCheckBox", ,"Start Third Person",true));
    bStartThirdPerson.ToolTip.SetTip("Check this box to start in third person mode, if the server has it enabled.");

    bDisplayBossTimer = moCheckBox(currentScrollContainer.List.AddItem("XInterface.moCheckBox", ,"Display Boss Timer",true));
    bDisplayBossTimer.ToolTip.SetTip("Check this box to display the boss timer during boss waves.");
    bDisplayBossNames = moCheckBox(currentScrollContainer.List.AddItem("XInterface.moCheckBox", ,"Display Boss Names",true));
    bDisplayBossNames.ToolTip.SetTip("Check this box to display the boss names during boss waves.");

    currentKillSound = moComboBox(currentScrollContainer.List.AddItem("XInterface.moComboBox", ,"Kill Sound",true));
    currentKillSound.ToolTip.SetTip("Choose a sound to play when you kill a monster.");
    currentKillSound.bReadOnly = True;
    //currentKillSound.bVerticalLayout = True;
    currentKillSound.OnChange = InternalOnChange;
    currentKillSound.OnClickSound = CS_None;
    currentKillSound.OnClick = PlayMonsterKillSound;

    KillSoundVolume = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Kill Sound Volume",true));
    KillSoundVolume.Setup(0, 2, false);
    KillSoundVolume.ToolTip.SetTip("How loud the kill sounds should be.");

    currentEnemyHitSound = moComboBox(currentScrollContainer.List.AddItem("XInterface.moComboBox", ,"Enemy Hit Sound",true));
    currentEnemyHitSound.ToolTip.SetTip("Choose a sound to play when you deal damage to other enemies.");
    currentEnemyHitSound.bReadOnly = True;
    //currentEnemyHitSound.bVerticalLayout = True;
    currentEnemyHitSound.OnChange = InternalOnChange;
    currentEnemyHitSound.OnClickSound = CS_None;
    currentEnemyHitSound.OnClick = PlayEnemyHitSound;

    currentFriendlyHitSound = moComboBox(currentScrollContainer.List.AddItem("XInterface.moComboBox", ,"Friendly Hit Sound",true));
    currentFriendlyHitSound.ToolTip.SetTip("Choose a sound to play when you deal damage to other friendlies.");
    currentFriendlyHitSound.bReadOnly = True;
    //currentFriendlyHitSound.bVerticalLayout = True;
    currentFriendlyHitSound.OnChange = InternalOnChange;
    currentFriendlyHitSound.OnClickSound = CS_None;
    currentFriendlyHitSound.OnClick = PlayFriendlyHitSound;

    HitSoundVolume = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Hit Sound Volume",true));
    HitSoundVolume.Setup(0, 2, false);
    HitSoundVolume.ToolTip.SetTip("How loud the hit sounds should be.");

    MaxHitSoundsPerSecond = moSlider(currentScrollContainer.List.AddItem("XInterface.moSlider", ,"Max Hit Sounds Per Second",true));
    MaxHitSoundsPerSecond.Setup(5, 50, true);
    MaxHitSoundsPerSecond.ToolTip.SetTip("How many hit sounds should be allowed to play per second.");

    bDynamicHitSounds = moCheckBox(currentScrollContainer.List.AddItem("XInterface.moCheckBox", ,"Dynamic Hit Sounds",true));
    bDynamicHitSounds.ToolTip.SetTip("Checking this box will make the pitch of hit sounds vary depending on the damage you're dealing.");

    Controller.bCurMenuInitialized = bTemp;

    SetDefaultComponent(bHideRadar);
    SetDefaultComponent(bDisplayMonsterCounter);
    SetDefaultComponent(bNoRadarSound);
    SetDefaultComponent(bClassicRadar);
#ifeq ENABLE_TURINVX_RADAR 1
    SetDefaultComponent(bTURRadar);
#endif
    SetDefaultComponent(bRadarShowElevationAsDistance);
    SetDefaultComponent(bDisplayPlayerList);
    SetDefaultComponent(bSpecMonsters);
    SetDefaultComponent(bStartThirdPerson);
    SetDefaultComponent(bDisplayBossTimer);
    SetDefaultComponent(bDisplayBossNames);
    SetDefaultComponent(RadarTexture);
    SetDefaultComponent(PulseTexture);
    SetDefaultComponent(OwnerIconTexture);
    SetDefaultComponent(FriendlyPlayerIconTexture);
    SetDefaultComponent(FriendlyMonsterIconTexture);
    SetDefaultComponent(MonsterIconTexture);
    SetDefaultComponent(MiscIconTexture);
    SetDefaultComponent(RadarScale);
    SetDefaultComponent(RadarPosX);
    SetDefaultComponent(RadarPosY);
    SetDefaultComponent(currentKillSound);
    SetDefaultComponent(currentEnemyHitSound);
    SetDefaultComponent(currentFriendlyHitSound);
    SetDefaultComponent(KillSoundVolume);
    SetDefaultComponent(HitSoundVolume);
    SetDefaultComponent(MaxHitSoundsPerSecond);
    SetDefaultComponent(bDynamicHitSounds);
    SetDefaultComponent(PlayerListY);
    SetDefaultComponent(bAddFriendlyMonstersToPlayerList);
    SetDefaultComponent(bAddFriendlyMonstersToScoreboard);
    SetDefaultComponent(OwnerColorR);
    SetDefaultComponent(OwnerColorG);
    SetDefaultComponent(OwnerColorB);
    SetDefaultComponent(OwnerDotScale);
    SetDefaultComponent(PlayerColorR);
    SetDefaultComponent(PlayerColorG);
    SetDefaultComponent(PlayerColorB);
    SetDefaultComponent(FriendlyPlayerDotScale);
    SetDefaultComponent(FriendlyMonsterColorR);
    SetDefaultComponent(FriendlyMonsterColorG);
    SetDefaultComponent(FriendlyMonsterColorB);
    SetDefaultComponent(FriendlyMonsterDotScale);
    SetDefaultComponent(MonsterColorR);
    SetDefaultComponent(MonsterColorG);
    SetDefaultComponent(MonsterColorB);
    SetDefaultComponent(MonsterDotScale);
    SetDefaultComponent(MiscDotScale);
    SetDefaultComponent(MiscColorR);
    SetDefaultComponent(MiscColorG);
    SetDefaultComponent(MiscColorB);
    SetDefaultComponent(RadarColorR);
    SetDefaultComponent(RadarColorG);
    SetDefaultComponent(RadarColorB);
    SetDefaultComponent(RadarColorA);
    SetDefaultComponent(PulseColorR);
    SetDefaultComponent(PulseColorG);
    SetDefaultComponent(PulseColorB);
    SetDefaultComponent(PulseColorA);

    RadarScale.CaptionWidth = 1;
    RadarScale.ComponentWidth = 0.4;
    RadarPosX.CaptionWidth = 1;
    RadarPosX.ComponentWidth = 0.4;
    RadarPosY.CaptionWidth = 1;
    RadarPosY.ComponentWidth = 0.4;

    PlayerListY.CaptionWidth = 1;
    PlayerListY.ComponentWidth = 0.4;

    OwnerDotScale.CaptionWidth = 1;
    OwnerDotScale.ComponentWidth = 0.4;
    OwnerColorR.CaptionWidth = 1;
    OwnerColorR.ComponentWidth = 0.4;
    OwnerColorG.CaptionWidth = 1;
    OwnerColorG.ComponentWidth = 0.4;
    OwnerColorB.CaptionWidth = 1;
    OwnerColorB.ComponentWidth = 0.4;

    FriendlyPlayerDotScale.CaptionWidth = 1;
    FriendlyPlayerDotScale.ComponentWidth = 0.4;
    PlayerColorR.CaptionWidth = 1;
    PlayerColorR.ComponentWidth = 0.4;
    PlayerColorG.CaptionWidth = 1;
    PlayerColorG.ComponentWidth = 0.4;
    PlayerColorB.CaptionWidth = 1;
    PlayerColorB.ComponentWidth = 0.4;

    FriendlyMonsterDotScale.CaptionWidth = 1;
    FriendlyMonsterDotScale.ComponentWidth = 0.4;
    FriendlyMonsterColorR.CaptionWidth = 1;
    FriendlyMonsterColorR.ComponentWidth = 0.4;
    FriendlyMonsterColorG.CaptionWidth = 1;
    FriendlyMonsterColorG.ComponentWidth = 0.4;
    FriendlyMonsterColorB.CaptionWidth = 1;
    FriendlyMonsterColorB.ComponentWidth = 0.4;

    MonsterDotScale.CaptionWidth = 1;
    MonsterDotScale.ComponentWidth = 0.4;
    MonsterColorR.CaptionWidth = 1;
    MonsterColorR.ComponentWidth = 0.4;
    MonsterColorG.CaptionWidth = 1;
    MonsterColorG.ComponentWidth = 0.4;
    MonsterColorB.CaptionWidth = 1;
    MonsterColorB.ComponentWidth = 0.4;

    MiscDotScale.CaptionWidth = 1;
    MiscDotScale.ComponentWidth = 0.4;
    MiscColorR.CaptionWidth = 1;
    MiscColorR.ComponentWidth = 0.4;
    MiscColorG.CaptionWidth = 1;
    MiscColorG.ComponentWidth = 0.4;
    MiscColorB.CaptionWidth = 1;
    MiscColorB.ComponentWidth = 0.4;

    RadarColorR.CaptionWidth = 1;
    RadarColorR.ComponentWidth = 0.4;
    RadarColorG.CaptionWidth = 1;
    RadarColorG.ComponentWidth = 0.4;
    RadarColorB.CaptionWidth = 1;
    RadarColorB.ComponentWidth = 0.4;
    RadarColorA.CaptionWidth = 1;
    RadarColorA.ComponentWidth = 0.4;

    PulseColorR.CaptionWidth = 1;
    PulseColorR.ComponentWidth = 0.4;
    PulseColorG.CaptionWidth = 1;
    PulseColorG.ComponentWidth = 0.4;
    PulseColorB.CaptionWidth = 1;
    PulseColorB.ComponentWidth = 0.4;
    PulseColorA.CaptionWidth = 1;
    PulseColorA.ComponentWidth = 0.4;

    RadarTexture.CaptionWidth = 1;
    RadarTexture.ComponentWidth = 0.68;
    PulseTexture.CaptionWidth = 1;
    PulseTexture.ComponentWidth = 0.68;
    OwnerIconTexture.CaptionWidth = 1;
    OwnerIconTexture.ComponentWidth = 0.68;
    FriendlyPlayerIconTexture.CaptionWidth = 1;
    FriendlyPlayerIconTexture.ComponentWidth = 0.68;
    FriendlyMonsterIconTexture.CaptionWidth = 1;
    FriendlyMonsterIconTexture.ComponentWidth = 0.68;
    MonsterIconTexture.CaptionWidth = 1;
    MonsterIconTexture.ComponentWidth = 0.68;
    MiscIconTexture.CaptionWidth = 1;
    MiscIconTexture.ComponentWidth = 0.68;
    currentKillSound.CaptionWidth = 1;
    currentKillSound.ComponentWidth = 0.68;
    currentEnemyHitSound.CaptionWidth = 1;
    currentEnemyHitSound.ComponentWidth = 0.68;
    currentFriendlyHitSound.CaptionWidth = 1;
    currentFriendlyHitSound.ComponentWidth = 0.68;

    KillSoundVolume.CaptionWidth = 1;
    KillSoundVolume.ComponentWidth = 0.4;
    HitSoundVolume.CaptionWidth = 1;
    HitSoundVolume.ComponentWidth = 0.4;
    MaxHitSoundsPerSecond.CaptionWidth = 1;
    MaxHitSoundsPerSecond.ComponentWidth = 0.4;

    if(BaseHUD != None)
    {
        for(i=0;i<BaseHUD.EnemyKillSounds.Length;i++)
        {
            Divide(BaseHUD.EnemyKillSounds[i],".",PackageLeft, PackageRight);

            if(BaseHUD.EnemyKillSounds[i] ~= "None")
            {
                PackageRight = "None";
            }

            currentKillSound.AddItem(PackageRight);
        }

        currentKillSound.MyComboBox.Edit.FontScale = FNS_Small;
        currentKillSound.StandardHeight = 0.04;
        currentKillSound.MyComboBox.MaxVisibleItems = 4;

        for(i=0;i<BaseHUD.EnemyHitSounds.Length;i++)
        {
            Divide(BaseHUD.EnemyHitSounds[i],".",PackageLeft, PackageRight);

            if(BaseHUD.EnemyHitSounds[i] ~= "None")
            {
                PackageRight = "None";
            }

            currentEnemyHitSound.AddItem(PackageRight);
        }

        currentEnemyHitSound.MyComboBox.Edit.FontScale = FNS_Small;
        currentEnemyHitSound.StandardHeight = 0.04;
        currentEnemyHitSound.MyComboBox.MaxVisibleItems = 4;

        for(i=0;i<BaseHUD.FriendlyHitSounds.Length;i++)
        {
            Divide(BaseHUD.FriendlyHitSounds[i],".",PackageLeft, PackageRight);

            if(BaseHUD.FriendlyHitSounds[i] ~= "None")
            {
                PackageRight = "None";
            }

            CurrentFriendlyHitSound.AddItem(PackageRight);
        }

        CurrentFriendlyHitSound.MyComboBox.Edit.FontScale = FNS_Small;
        CurrentFriendlyHitSound.StandardHeight = 0.04;
        CurrentFriendlyHitSound.MyComboBox.MaxVisibleItems = 4;

        for(i=0;i<BaseHUD.RadarMaterials.Length;i++)
        {
            TestString = String(BaseHUD.RadarMaterials[i]);
            TestString = Repl(TestString, "'", "");
            if(!Divide(TestString,".",PackageLeft, PackageRight))
            {
                PackageRight = "None";
            }

            TestString = PackageRight;
            Divide(TestString,".",PackageLeft, PackageRight);
            RadarTexture.AddItem(PackageRight);
        }

        RadarTexture.MyComboBox.Edit.FontScale = FNS_Small;
        RadarTexture.StandardHeight = 0.04;

        for(i=0;i<BaseHUD.PulseMaterials.Length;i++)
        {
            TestString = String(BaseHUD.PulseMaterials[i]);
            TestString = Repl(TestString, "'", "");
            Divide(TestString,".",PackageLeft, PackageRight);

            if(!Divide(TestString,".",PackageLeft, PackageRight))
            {
                PackageRight = "None";
            }

            TestString = PackageRight;
            Divide(TestString,".",PackageLeft, PackageRight);
            PulseTexture.AddItem(PackageRight);
        }

        PulseTexture.MyComboBox.Edit.FontScale = FNS_Small;
        PulseTexture.StandardHeight = 0.04;

        for(i=0;i<BaseHUD.OwnerIconMaterials.Length;i++)
        {
            TestString = String(BaseHUD.OwnerIconMaterials[i]);
            TestString = Repl(TestString, "'", "");
            Divide(TestString,".",PackageLeft, PackageRight);

            if(!Divide(TestString,".",PackageLeft, PackageRight))
            {
                PackageRight = "None";
            }

            TestString = PackageRight;
            Divide(TestString,".",PackageLeft, PackageRight);
            OwnerIconTexture.AddItem(PackageRight);
        }

        OwnerIconTexture.MyComboBox.Edit.FontScale = FNS_Small;
        OwnerIconTexture.StandardHeight = 0.04;

        for(i=0;i<BaseHUD.FriendlyPlayerIconMaterials.Length;i++)
        {
            TestString = String(BaseHUD.FriendlyPlayerIconMaterials[i]);
            TestString = Repl(TestString, "'", "");
            Divide(TestString,".",PackageLeft, PackageRight);

            if(!Divide(TestString,".",PackageLeft, PackageRight))
            {
                PackageRight = "None";
            }

            TestString = PackageRight;
            Divide(TestString,".",PackageLeft, PackageRight);
            FriendlyPlayerIconTexture.AddItem(PackageRight);
        }

        FriendlyPlayerIconTexture.MyComboBox.Edit.FontScale = FNS_Small;
        FriendlyPlayerIconTexture.StandardHeight = 0.04;

        for(i=0;i<BaseHUD.FriendlyMonsterIconMaterials.Length;i++)
        {
            TestString = String(BaseHUD.FriendlyMonsterIconMaterials[i]);
            TestString = Repl(TestString, "'", "");
            Divide(TestString,".",PackageLeft, PackageRight);

            if(!Divide(TestString,".",PackageLeft, PackageRight))
            {
                PackageRight = "None";
            }

            TestString = PackageRight;
            Divide(TestString,".",PackageLeft, PackageRight);
            FriendlyMonsterIconTexture.AddItem(PackageRight);
        }

        FriendlyMonsterIconTexture.MyComboBox.Edit.FontScale = FNS_Small;
        FriendlyMonsterIconTexture.StandardHeight = 0.04;

        for(i=0;i<BaseHUD.MonsterIconMaterials.Length;i++)
        {
            TestString = String(BaseHUD.MonsterIconMaterials[i]);
            TestString = Repl(TestString, "'", "");
            Divide(TestString,".",PackageLeft, PackageRight);

            if(!Divide(TestString,".",PackageLeft, PackageRight))
            {
                PackageRight = "None";
            }

            TestString = PackageRight;
            Divide(TestString,".",PackageLeft, PackageRight);
            MonsterIconTexture.AddItem(PackageRight);
        }

        MonsterIconTexture.MyComboBox.Edit.FontScale = FNS_Small;
        MonsterIconTexture.StandardHeight = 0.04;

        for(i=0;i<BaseHUD.MiscIconMaterials.Length;i++)
        {
            TestString = String(BaseHUD.MiscIconMaterials[i]);
            TestString = Repl(TestString, "'", "");
            Divide(TestString,".",PackageLeft, PackageRight);

            if(!Divide(TestString,".",PackageLeft, PackageRight))
            {
                PackageRight = "None";
            }

            TestString = PackageRight;
            Divide(TestString,".",PackageLeft, PackageRight);
            MiscIconTexture.AddItem(PackageRight);
        }

        MiscIconTexture.MyComboBox.Edit.FontScale = FNS_Small;
        MiscIconTexture.StandardHeight = 0.04;
    }

    Initialize();
}

function SetDefaultComponent(GUIMenuOption PassedComponent)
{
    PassedComponent.CaptionWidth = 0.8;
    PassedComponent.ComponentWidth = 0.2;
    PassedComponent.ComponentJustification = TXTA_Right;
    PassedComponent.bStandardized = false;
    PassedComponent.bBoundToParent = False;
    PassedComponent.bScaleToParent = False;

    if(PassedComponent.MyLabel != None)
    {
        PassedComponent.MyLabel.TextAlign = TXTA_Left;
    }
}

//set current settings
function Initialize()
{
    local int ItemIndex;
    local string PackageLeft, PackageRight, TestString;

    if (BaseHUD != None )
    {
        RadarColorR.SetValue (BaseHUD.default.RadarColor.R);
        RadarColorG.SetValue (BaseHUD.default.RadarColor.G);
        RadarColorB.SetValue (BaseHUD.default.RadarColor.B);
        RadarColorA.SetValue (BaseHUD.default.RadarColor.A);

        RadarImage.Image = BaseHUD.default.RadarImage;
        PulseImage.Image = BaseHUD.default.PulseImage;
        OwnerIcon.Image = BaseHUD.default.OwnerIcon;
        FriendlyPlayerIcon.Image = BaseHUD.default.FriendlyPlayerIcon;
        FriendlyMonsterIcon.Image = BaseHUD.default.FriendlyMonsterIcon;
        MonsterIcon.Image = BaseHUD.default.MonsterIcon;
        MiscIcon.Image = BaseHUD.default.MiscIcon;

/*      OwnerIcon.WinHeight = OwnerIcon.default.WinHeight * BaseHUD.default.OwnerDotScale;
        OwnerIcon.WinWidth = OwnerIcon.default.WinWidth * BaseHUD.default.OwnerDotScale;
        FriendlyPlayerIcon.WinHeight = FriendlyPlayerIcon.default.WinHeight * BaseHUD.default.FriendlyPlayerDotScale;
        FriendlyPlayerIcon.WinWidth = FriendlyPlayerIcon.default.WinWidth * BaseHUD.default.FriendlyPlayerDotScale;
        FriendlyMonsterIcon.WinHeight = FriendlyMonsterIcon.default.WinHeight * BaseHUD.default.FriendlyMonsterDotScale;
        FriendlyMonsterIcon.WinWidth = FriendlyMonsterIcon.default.WinWidth * BaseHUD.default.FriendlyMonsterDotScale;
        MonsterIcon.WinHeight = MonsterIcon.default.WinHeight * BaseHUD.default.MonsterDotScale;
        MonsterIcon.WinWidth = MonsterIcon.default.WinWidth * BaseHUD.default.MonsterDotScale;
        MiscIcon.WinWidth = MiscIcon.default.WinWidth * BaseHUD.default.MiscDotScale;
        MiscIcon.WinWidth = MiscIcon.default.WinWidth * BaseHUD.default.MiscDotScale;*/

        RadarScale.SetValue(BaseHUD.default.RadarScale);
        RadarPosX.SetValue(BaseHUD.default.RadarPosX);
        RadarPosY.SetValue(BaseHUD.default.RadarPosY);

        PlayerListY.SetValue(BaseHUD.default.PlayerListPosY);

        PulseColorR.SetValue (BaseHUD.default.PulseColor.R);
        PulseColorG.SetValue (BaseHUD.default.PulseColor.G);
        PulseColorB.SetValue (BaseHUD.default.PulseColor.B);
        PulseColorA.SetValue (BaseHUD.default.PulseColor.A);

        MonsterDotScale.SetValue(BaseHUD.default.MonsterDotScale);
        MonsterColorR.SetValue(BaseHUD.default.MonsterColor.R);
        MonsterColorG.SetValue(BaseHUD.default.MonsterColor.G);
        MonsterColorB.SetValue(BaseHUD.default.MonsterColor.B);

        FriendlyPlayerDotScale.SetValue(BaseHUD.default.FriendlyPlayerDotScale);
        PlayerColorR.SetValue(BaseHUD.default.PlayerColor.R);
        PlayerColorG.SetValue(BaseHUD.default.PlayerColor.G);
        PlayerColorB.SetValue(BaseHUD.default.PlayerColor.B);

        FriendlyMonsterDotScale.SetValue(BaseHUD.default.FriendlyMonsterDotScale);
        FriendlyMonsterColorR.SetValue(BaseHUD.default.FriendlyMonsterColor.R);
        FriendlyMonsterColorG.SetValue(BaseHUD.default.FriendlyMonsterColor.G);
        FriendlyMonsterColorB.SetValue(BaseHUD.default.FriendlyMonsterColor.B);

        OwnerDotScale.SetValue(BaseHUD.default.OwnerDotScale);
        OwnerColorR.SetValue(BaseHUD.default.OwnerColor.R);
        OwnerColorG.SetValue(BaseHUD.default.OwnerColor.G);
        OwnerColorB.SetValue(BaseHUD.default.OwnerColor.B);

        MiscDotScale.SetValue(BaseHUD.default.MiscDotScale);
        MiscColorR.SetValue(BaseHUD.default.MiscColor.R);
        MiscColorG.SetValue(BaseHUD.default.MiscColor.G);
        MiscColorB.SetValue(BaseHUD.default.MiscColor.B);

        bHideRadar.SetComponentValue(BaseHUD.default.bHideRadar);

        bAddFriendlyMonstersToPlayerList.SetComponentValue(BaseHUD.default.bAddFriendlyMonstersToPlayerList);
        bAddFriendlyMonstersToScoreboard.SetComponentValue(BaseHUD.default.bAddFriendlyMonstersToScoreboard);
        bDisplayMonsterCounter.SetComponentValue(BaseHUD.default.bDisplayMonsterCounter);
        bNoRadarSound.SetComponentValue(BaseHUD.default.bNoRadarSound);
        bClassicRadar.SetComponentValue(BaseHUD.default.bClassicRadar);
#ifeq ENABLE_TURINVX_RADAR 1
        bTURRadar.SetComponentValue(BaseHUD.default.bTURRadar);
#endif
        bRadarShowElevationAsDistance.SetComponentValue(BaseHUD.default.bRadarShowElevationAsDistance);
        bDisplayPlayerList.SetComponentValue(BaseHUD.default.bDisplayPlayerList);

        bStartThirdPerson.SetComponentValue(BaseHUD.default.bStartThirdPerson);
        bSpecMonsters.SetComponentValue(BaseHUD.default.bSpecMonsters);

        bDisplayBossNames.SetComponentValue(BaseHUD.default.bDisplayBossNames);
        bDisplayBossTimer.SetComponentValue(BaseHUD.default.bDisplayBossTimer);

        bDynamicHitSounds.SetComponentValue(BaseHUD.default.bDynamicHitSounds);

        TestString = String(BaseHUD.default.RadarImage);
        TestString = Repl(TestString, "'", "");
        Divide(TestString,".",PackageLeft, PackageRight);
        TestString = PackageRight;
        Divide(TestString,".",PackageLeft, PackageRight);
        ItemIndex = RadarTexture.FindIndex(PackageRight, , ,);
        RadarTexture.SetIndex(ItemIndex);

        TestString = String(BaseHUD.default.PulseImage);
        TestString = Repl(TestString, "'", "");
        Divide(TestString,".",PackageLeft, PackageRight);
        TestString = PackageRight;
        Divide(TestString,".",PackageLeft, PackageRight);
        ItemIndex = PulseTexture.FindIndex(PackageRight, , ,);
        PulseTexture.SetIndex(ItemIndex);

        TestString = String(BaseHUD.default.OwnerIcon);
        TestString = Repl(TestString, "'", "");
        Divide(TestString,".",PackageLeft, PackageRight);
        TestString = PackageRight;
        Divide(TestString,".",PackageLeft, PackageRight);
        ItemIndex = OwnerIconTexture.FindIndex(PackageRight, , ,);
        OwnerIconTexture.SetIndex(ItemIndex);

        TestString = String(BaseHUD.default.FriendlyPlayerIcon);
        TestString = Repl(TestString, "'", "");
        Divide(TestString,".",PackageLeft, PackageRight);
        TestString = PackageRight;
        Divide(TestString,".",PackageLeft, PackageRight);
        ItemIndex = FriendlyPlayerIconTexture.FindIndex(PackageRight, , ,);
        FriendlyPlayerIconTexture.SetIndex(ItemIndex);

        TestString = String(BaseHUD.default.FriendlyMonsterIcon);
        TestString = Repl(TestString, "'", "");
        Divide(TestString,".",PackageLeft, PackageRight);
        TestString = PackageRight;
        Divide(TestString,".",PackageLeft, PackageRight);
        ItemIndex = FriendlyMonsterIconTexture.FindIndex(PackageRight, , ,);
        FriendlyMonsterIconTexture.SetIndex(ItemIndex);

        TestString = String(BaseHUD.default.MonsterIcon);
        TestString = Repl(TestString, "'", "");
        Divide(TestString,".",PackageLeft, PackageRight);
        TestString = PackageRight;
        Divide(TestString,".",PackageLeft, PackageRight);
        ItemIndex = MonsterIconTexture.FindIndex(PackageRight, , ,);
        MonsterIconTexture.SetIndex(ItemIndex);

        TestString = String(BaseHUD.default.MiscIcon);
        TestString = Repl(TestString, "'", "");
        Divide(TestString,".",PackageLeft, PackageRight);
        TestString = PackageRight;
        Divide(TestString,".",PackageLeft, PackageRight);
        ItemIndex = MiscIconTexture.FindIndex(PackageRight, , ,);
        MiscIconTexture.SetIndex(ItemIndex);

        if(!Divide(BaseHUD.CurrentKillSound,".",PackageLeft, PackageRight))
        {
            PackageRight = "None";
        }

        ItemIndex = currentKillSound.FindIndex(PackageRight, , ,);
        currentKillSound.SetIndex(ItemIndex);

        if(!Divide(BaseHUD.CurrentEnemyHitSound,".",PackageLeft, PackageRight))
        {
            PackageRight = "None";
        }

        ItemIndex = CurrentEnemyHitSound.FindIndex(PackageRight, , ,);
        CurrentEnemyHitSound.SetIndex(ItemIndex);

        if(!Divide(BaseHUD.CurrentFriendlyHitSound,".",PackageLeft, PackageRight))
        {
            PackageRight = "None";
        }

        ItemIndex = CurrentFriendlyHitSound.FindIndex(PackageRight, , ,);
        CurrentFriendlyHitSound.SetIndex(ItemIndex);

        KillSoundVolume.SetValue (BaseHUD.default.KillSoundVolume);
        HitSoundVolume.SetValue (BaseHUD.default.HitSoundVolume);
        MaxHitSoundsPerSecond.SetValue (BaseHUD.default.MaxHitSoundsPerSecond);
        bDynamicHitSounds.SetComponentValue(BaseHUD.default.bDynamicHitSounds);

        if(bHideRadar.IsChecked())
        {
            bClassicRadar.DisableMe();
#ifeq ENABLE_TURINVX_RADAR 1
            bTURRadar.DisableMe();
#endif
        }

#ifeq ENABLE_TURINVX_RADAR 1
        if(bClassicRadar.IsChecked())
            bTURRadar.DisableMe();

        if(bTURRadar.IsChecked())
            bClassicRadar.DisableMe();
#endif
    }
}

function SaveHud()
{
    ///local Color TempColor;

    if ( BaseHUD != None )
    {
        //TempColor.R = RadarColorR.GetValue();
        //TempColor.G = RadarColorG.GetValue();
        //TempColor.B = RadarColorB.GetValue();
        //TempColor.A = RadarColorA.GetValue();
        BaseHUD.default.bHideRadar = BaseHUD.bHideRadar;
        BaseHUD.default.bRadarShowElevationAsDistance = BaseHUD.bRadarShowElevationAsDistance;
        BaseHUD.default.CurrentKillSound = BaseHUD.EnemyKillSounds[GetKillSoundIndex()];
        BaseHUD.default.CurrentEnemyHitSound = BaseHUD.EnemyHitSounds[GetEnemyHitSoundIndex()];
        BaseHUD.default.CurrentFriendlyHitSound = BaseHUD.FriendlyHitSounds[GetFriendlyHitSoundIndex()];
        BaseHUD.default.bDynamicHitSounds = BaseHUD.bDynamicHitSounds;
        BaseHUD.default.KillSoundVolume = KillSoundVolume.GetValue();
        BaseHUD.default.HitSoundVolume = HitSoundVolume.GetValue();
        BaseHUD.default.RadarColor = BaseHUD.RadarColor;
        BaseHUD.default.PulseColor = BaseHUD.PulseColor;
        BaseHUD.default.MonsterColor = BaseHUD.MonsterColor;
        BaseHUD.default.PlayerColor = BaseHUD.PlayerColor;
        BaseHUD.default.OwnerColor = BaseHUD.OwnerColor;
        BaseHUD.default.MiscColor = BaseHUD.MiscColor;

        BaseHUD.default.RadarScale = BaseHUD.RadarScale;
        BaseHUD.default.RadarPosX = BaseHUD.RadarPosX;
        BaseHUD.default.RadarPosY = BaseHUD.RadarPosY;

        BaseHUD.default.PlayerListPosY = BaseHUD.PlayerListPosY;

        BaseHUD.default.OwnerDotScale = BaseHUD.OwnerDotScale;
        BaseHUD.default.FriendlyPlayerDotScale = BaseHUD.FriendlyPlayerDotScale;
        BaseHUD.default.FriendlyMonsterDotScale = BaseHUD.FriendlyMonsterDotScale;
        BaseHUD.default.MonsterDotScale = BaseHUD.MonsterDotScale;
        BaseHUD.default.MiscDotScale = BaseHUD.MiscDotScale;

        BaseHUD.default.bAddFriendlyMonstersToPlayerList = BaseHUD.bAddFriendlyMonstersToPlayerList;
        BaseHUD.default.bAddFriendlyMonstersToScoreboard = BaseHUD.bAddFriendlyMonstersToScoreboard;
        BaseHUD.default.bDisplayMonsterCounter = BaseHUD.bDisplayMonsterCounter;
        BaseHUD.default.bDisplayPlayerList = BaseHUD.bDisplayPlayerList;
        BaseHUD.default.bNoRadarSound = BaseHUD.bNoRadarSound;
        BaseHUD.default.bClassicRadar = BaseHUD.bClassicRadar;
#ifeq ENABLE_TURINVX_RADAR 1
        BaseHUD.default.bTURRadar = BaseHUD.bTURRadar;
#endif
        BaseHUD.default.bRadarShowElevationAsDistance = BaseHUD.bRadarShowElevationAsDistance;

        BaseHUD.default.bStartThirdPerson = BaseHUD.bStartThirdPerson;
        BaseHUD.default.bSpecMonsters = BaseHUD.bSpecMonsters;
        BaseHUD.default.bDisplayBossTimer = BaseHUD.bDisplayBossTimer;
        BaseHUD.default.bDisplayBossNames = BaseHUD.bDisplayBossNames;

        BaseHUD.default.RadarImage = BaseHUD.RadarImage;
        BaseHUD.default.PulseImage = BaseHUD.PulseImage;
        BaseHUD.default.OwnerIcon = BaseHUD.OwnerIcon;
        BaseHUD.default.FriendlyPlayerIcon = BaseHUD.FriendlyPlayerIcon;
        BaseHUD.default.FriendlyMonsterIcon = BaseHUD.FriendlyMonsterIcon;
        BaseHUD.default.MonsterIcon = BaseHUD.MonsterIcon;
        BaseHUD.default.MiscIcon = BaseHUD.MiscIcon;

        //set real-time values now
        BaseHUD.CurrentKillSound = BaseHUD.default.CurrentKillSound;
        BaseHUD.CurrentEnemyHitSound = BaseHUD.default.CurrentEnemyHitSound;
        BaseHUD.CurrentFriendlyHitSound = BaseHUD.default.CurrentFriendlyHitSound;
        BaseHUD.bDynamicHitSounds = BaseHUD.default.bDynamicHitSounds;
        BaseHUD.KillSoundVolume = BaseHUD.default.KillSoundVolume;
        BaseHUD.HitSoundVolume = BaseHUD.default.HitSoundVolume;
        BaseHUD.bStartThirdPerson = BaseHUD.default.bStartThirdPerson;

        BaseHUD.static.StaticSaveConfig();
        //class'InvasionProHud'.static.StaticSaveConfig();
    }
}

function int GetKillSoundIndex()
{
    local int i;
    local string PackageLeft, PackageRight;

    for(i=0;i<BaseHUD.EnemyKillSounds.Length;i++)
    {
        Divide(BaseHUD.EnemyKillSounds[i],".",PackageLeft, PackageRight);
        if( BaseHUD.EnemyKillSounds[i] ~= currentKillSound.GetText() || PackageRight ~= currentKillSound.GetText())
        {
            return i;
        }
    }

    return 0;
}

function int GetEnemyHitSoundIndex()
{
    local int i;
    local string PackageLeft, PackageRight;

    for(i=0;i<BaseHUD.EnemyHitSounds.Length;i++)
    {
        Divide(BaseHUD.EnemyHitSounds[i],".",PackageLeft, PackageRight);
        if( BaseHUD.EnemyHitSounds[i] ~= currentEnemyHitSound.GetText() || PackageRight ~= currentEnemyHitSound.GetText())
        {
            return i;
        }
    }

    return 0;
}

function int GetFriendlyHitSoundIndex()
{
    local int i;
    local string PackageLeft, PackageRight;

    for(i=0;i<BaseHUD.FriendlyHitSounds.Length;i++)
    {
        Divide(BaseHUD.FriendlyHitSounds[i],".",PackageLeft, PackageRight);
        if( BaseHUD.FriendlyHitSounds[i] ~= currentFriendlyHitSound.GetText() || PackageRight ~= currentFriendlyHitSound.GetText())
        {
            return i;
        }
    }

    return 0;
}

function int GetRadarImageIndex()
{
    local int i;
    local string PackageLeft, PackageRight, TestString;

    for(i=0;i<BaseHUD.RadarMaterials.Length;i++)
    {
        TestString = String(BaseHUD.RadarMaterials[i]);
        TestString = Repl(TestString, "'", "");
        Divide(TestString,".",PackageLeft, PackageRight);
        TestString = PackageRight;
        Divide(TestString,".",PackageLeft, PackageRight);
        if(PackageRight ~= RadarTexture.GetText())
        {
            return i;
        }
    }

    return 0;
}

function int GetPulseImageIndex()
{
    local int i;
    local string PackageLeft, PackageRight, TestString;

    for(i=0;i<BaseHUD.PulseMaterials.Length;i++)
    {
        TestString = String(BaseHUD.PulseMaterials[i]);
        TestString = Repl(TestString, "'", "");
        Divide(TestString,".",PackageLeft, PackageRight);
        TestString = PackageRight;
        Divide(TestString,".",PackageLeft, PackageRight);
        if(PackageRight ~= PulseTexture.GetText())
        {
            return i;
        }
    }

    return 0;
}

function int GetOwnerIconIndex()
{
    local int i;
    local string PackageLeft, PackageRight, TestString;

    for(i=0;i<BaseHUD.OwnerIconMaterials.Length;i++)
    {
        TestString = String(BaseHUD.OwnerIconMaterials[i]);
        TestString = Repl(TestString, "'", "");
        Divide(TestString,".",PackageLeft, PackageRight);
        TestString = PackageRight;
        Divide(TestString,".",PackageLeft, PackageRight);
        if(PackageRight ~= OwnerIconTexture.GetText())
        {
            return i;
        }
    }

    return 0;
}

function int GetFriendlyPlayerIconIndex()
{
    local int i;
    local string PackageLeft, PackageRight, TestString;

    for(i=0;i<BaseHUD.FriendlyPlayerIconMaterials.Length;i++)
    {
        TestString = String(BaseHUD.FriendlyPlayerIconMaterials[i]);
        TestString = Repl(TestString, "'", "");
        Divide(TestString,".",PackageLeft, PackageRight);
        TestString = PackageRight;
        Divide(TestString,".",PackageLeft, PackageRight);
        if(PackageRight ~= FriendlyPlayerIconTexture.GetText())
        {
            return i;
        }
    }

    return 0;
}

function int GetFriendlyMonsterIconIndex()
{
    local int i;
    local string PackageLeft, PackageRight, TestString;

    for(i=0;i<BaseHUD.FriendlyMonsterIconMaterials.Length;i++)
    {
        TestString = String(BaseHUD.FriendlyMonsterIconMaterials[i]);
        TestString = Repl(TestString, "'", "");
        Divide(TestString,".",PackageLeft, PackageRight);
        TestString = PackageRight;
        Divide(TestString,".",PackageLeft, PackageRight);
        if(PackageRight ~= FriendlyMonsterIconTexture.GetText())
        {
            return i;
        }
    }

    return 0;
}

function int GetMonsterIconIndex()
{
    local int i;
    local string PackageLeft, PackageRight, TestString;

    for(i=0;i<BaseHUD.MonsterIconMaterials.Length;i++)
    {
        TestString = String(BaseHUD.MonsterIconMaterials[i]);
        TestString = Repl(TestString, "'", "");
        Divide(TestString,".",PackageLeft, PackageRight);
        TestString = PackageRight;
        Divide(TestString,".",PackageLeft, PackageRight);
        if(PackageRight ~= MonsterIconTexture.GetText())
        {
            return i;
        }
    }

    return 0;
}

function int GetMiscIconIndex()
{
    local int i;
    local string PackageLeft, PackageRight, TestString;

    for(i=0;i<BaseHUD.MiscIconMaterials.Length;i++)
    {
        TestString = String(BaseHUD.MiscIconMaterials[i]);
        TestString = Repl(TestString, "'", "");
        Divide(TestString,".",PackageLeft, PackageRight);
        TestString = PackageRight;
        Divide(TestString,".",PackageLeft, PackageRight);
        if(PackageRight ~= MiscIconTexture.GetText())
        {
            return i;
        }
    }

    return 0;
}

function bool DefaultHud(GUIComponent Sender)
{
    RadarColorR.SetValue(0);
    RadarColorG.SetValue(150);
    RadarColorB.SetValue(100);
    RadarColorA.SetValue(255);

    PulseColorR.SetValue(50);
    PulseColorG.SetValue(160);
    PulseColorB.SetValue(215);
    PulseColorA.SetValue(255);

    MonsterDotScale.SetValue(1.0);
    MonsterColorR.SetValue(255);
    MonsterColorG.SetValue(255);
    MonsterColorB.SetValue(0);

    FriendlyPlayerDotScale.SetValue(1.0);
    PlayerColorR.SetValue(0);
    PlayerColorG.SetValue(255);
    PlayerColorB.SetValue(255);

    FriendlyMonsterDotScale.SetValue(1.0);
    FriendlyMonsterColorR.SetValue(0);
    FriendlyMonsterColorG.SetValue(255);
    FriendlyMonsterColorB.SetValue(255);

    OwnerDotScale.SetValue(1.0);
    OwnerColorR.SetValue(255);
    OwnerColorG.SetValue(255);
    OwnerColorB.SetValue(255);

    MiscDotScale.SetValue(1.0);
    MiscColorR.SetValue(255);
    MiscColorG.SetValue(255);
    MiscColorB.SetValue(255);

    RadarPosX.SetValue(0.912558);
    RadarPosY.SetValue(0.192209);
    RadarScale.SetValue(0.200000);

    PlayerListY.SetValue(0.120000);

    KillSoundVolume.SetValue(0.5);
    HitSoundVolume.SetValue(0.5);
    MaxHitSoundsPerSecond.SetValue(5);

    bHideRadar.SetComponentValue(False);
    bRadarShowElevationAsDistance.SetComponentValue(True);
    bAddFriendlyMonstersToPlayerList.SetComponentValue(False);
    bAddFriendlyMonstersToScoreboard.SetComponentValue(False);
    bNoRadarSound.SetComponentValue(False);
    bClassicRadar.SetComponentValue(False);
#ifeq ENABLE_TURINVX_RADAR 1
    bTURRadar.SetComponentValue(False);
#endif
    bDisplayMonsterCounter.SetComponentValue(True);
    bDisplayPlayerList.SetComponentValue(True);
    bSpecMonsters.SetComponentValue(True);
    bDisplayBossTimer.SetComponentValue(True);
    bDisplayBossNames.SetComponentValue(True);
    bDynamicHitSounds.SetComponentValue(True);

    RadarImage.Image = BaseHUD.default.RadarMaterials[1];
    PulseImage.Image = BaseHUD.default.PulseMaterials[1];
    OwnerIcon.Image = BaseHUD.default.OwnerIconMaterials[1];
    FriendlyPlayerIcon.Image = BaseHUD.default.FriendlyPlayerIconMaterials[1];
    FriendlyMonsterIcon.Image = BaseHUD.default.FriendlyMonsterIconMaterials[1];
    MonsterIcon.Image = BaseHUD.default.MonsterIconMaterials[1];
    MiscIcon.Image = BaseHUD.default.MiscIconMaterials[1];

/*  OwnerIcon.WinHeight = OwnerIcon.default.WinHeight;
    OwnerIcon.WinWidth = OwnerIcon.default.WinWidth;
    FriendlyPlayerIcon.WinHeight = FriendlyPlayerIcon.default.WinHeight;
    FriendlyPlayerIcon.WinWidth = FriendlyPlayerIcon.default.WinWidth;
    FriendlyMonsterIcon.WinHeight = FriendlyMonsterIcon.default.WinHeight;
    FriendlyMonsterIcon.WinWidth = FriendlyMonsterIcon.default.WinWidth;
    MonsterIcon.WinHeight = MonsterIcon.default.WinHeight;
    MonsterIcon.WinWidth = MonsterIcon.default.WinWidth;
    MiscIcon.WinWidth = MiscIcon.default.WinWidth;
    MiscIcon.WinWidth = MiscIcon.default.WinWidth;*/

    bStartThirdPerson.SetComponentValue(False);

    currentKillSound.SetIndex(0);
    currentEnemyHitSound.SetIndex(0);
    currentFriendlyHitSound.SetIndex(0);

    return true;
}

function bool InternalDraw(Canvas Canvas)
{
    local Color TempColor;

    if ( BaseHUD != None )
    {
        TempColor.R = RadarColorR.GetValue();
        TempColor.G = RadarColorG.GetValue();
        TempColor.B = RadarColorB.GetValue();
        TempColor.A = RadarColorA.GetValue();

        RadarImage.ImageColor = TempColor;
        BaseHUD.RadarImage = RadarImage.Image;
        BaseHUD.RadarColor = TempColor;

        TempColor.R = PulseColorR.GetValue();
        TempColor.G = PulseColorG.GetValue();
        TempColor.B = PulseColorB.GetValue();
        TempColor.A = PulseColorA.GetValue();

        PulseImage.ImageColor = TempColor;
        BaseHUD.PulseImage = PulseImage.Image;
        BaseHUD.PulseColor = TempColor;

        TempColor.R = MonsterColorR.GetValue();
        TempColor.G = MonsterColorG.GetValue();
        TempColor.B = MonsterColorB.GetValue();

        MonsterIcon.ImageColor = TempColor;
        BaseHUD.MonsterIcon = MonsterIcon.Image;
        BaseHUD.MonsterColor = TempColor;
        BaseHUD.MonsterDotScale = MonsterDotScale.GetValue();
//      MonsterIcon.WinHeight = MonsterIcon.default.WinHeight * MonsterDotScale.GetValue();
//      MonsterIcon.WinWidth = MonsterIcon.default.WinWidth * MonsterDotScale.GetValue();

        TempColor.R = PlayerColorR.GetValue();
        TempColor.G = PlayerColorG.GetValue();
        TempColor.B = PlayerColorB.GetValue();

        FriendlyPlayerIcon.ImageColor = TempColor;
        BaseHUD.FriendlyPlayerIcon = FriendlyPlayerIcon.Image;
        BaseHUD.PlayerColor = TempColor;
        BaseHUD.FriendlyPlayerDotScale = FriendlyPlayerDotScale.GetValue();
//      FriendlyPlayerIcon.WinHeight = FriendlyPlayerIcon.default.WinHeight * FriendlyPlayerDotScale.GetValue();
//      FriendlyPlayerIcon.WinWidth = FriendlyPlayerIcon.default.WinWidth * FriendlyPlayerDotScale.GetValue();

        TempColor.R = FriendlyMonsterColorR.GetValue();
        TempColor.G = FriendlyMonsterColorG.GetValue();
        TempColor.B = FriendlyMonsterColorB.GetValue();

        FriendlyMonsterIcon.ImageColor = TempColor;
        BaseHUD.FriendlyMonsterIcon = FriendlyMonsterIcon.Image;
        BaseHUD.FriendlyMonsterColor = TempColor;
        BaseHUD.FriendlyMonsterDotScale = FriendlyMonsterDotScale.GetValue();
//      FriendlyMonsterIcon.WinHeight = FriendlyMonsterIcon.default.WinHeight * FriendlyMonsterDotScale.GetValue();
//      FriendlyMonsterIcon.WinWidth = FriendlyMonsterIcon.default.WinWidth * FriendlyMonsterDotScale.GetValue();

        TempColor.R = OwnerColorR.GetValue();
        TempColor.G = OwnerColorG.GetValue();
        TempColor.B = OwnerColorB.GetValue();

        OwnerIcon.ImageColor = TempColor;
        BaseHUD.OwnerIcon = OwnerIcon.Image;
        BaseHUD.OwnerColor = TempColor;
        BaseHUD.OwnerDotScale = OwnerDotScale.GetValue();
//      OwnerIcon.WinHeight = OwnerIcon.default.WinHeight * OwnerDotScale.GetValue();
//      OwnerIcon.WinWidth = OwnerIcon.default.WinWidth * OwnerDotScale.GetValue();

        TempColor.R = MiscColorR.GetValue();
        TempColor.G = MiscColorG.GetValue();
        TempColor.B = MiscColorB.GetValue();

        MiscIcon.ImageColor = TempColor;
        BaseHUD.MiscIcon = MiscIcon.Image;
        BaseHUD.MiscColor = TempColor;
        BaseHUD.MiscDotScale = MiscDotScale.GetValue();
//      MiscIcon.WinHeight = MiscIcon.default.WinHeight * MiscDotScale.GetValue();
//      MiscIcon.WinWidth = MiscIcon.default.WinWidth * MiscDotScale.GetValue();

        BaseHUD.RadarScale = RadarScale.GetValue();
        BaseHUD.RadarPosX = RadarPosX.GetValue();
        BaseHUD.RadarPosY = RadarPosY.GetValue();

        BaseHUD.PlayerListPosY = PlayerListY.GetValue();

        BaseHUD.bHideRadar = bHideRadar.IsChecked();
        BaseHUD.bRadarShowElevationAsDistance = bRadarShowElevationAsDistance.IsChecked();
        BaseHUD.bAddFriendlyMonstersToPlayerList = bAddFriendlyMonstersToPlayerList.IsChecked();
        BaseHUD.bAddFriendlyMonstersToScoreboard = bAddFriendlyMonstersToScoreboard.IsChecked();
        BaseHUD.bDisplayMonsterCounter = bDisplayMonsterCounter.IsChecked();
        BaseHUD.bDisplayPlayerList = bDisplayPlayerList.IsChecked();
        BaseHUD.bNoRadarSound = bNoRadarSound.IsChecked();
        BaseHUD.bClassicRadar = bClassicRadar.IsChecked();
#ifeq ENABLE_TURINVX_RADAR 1
        BaseHUD.bTURRadar = bTURRadar.IsChecked();
#endif
        BaseHUD.bDynamicHitSounds = bDynamicHitSounds.IsChecked();

        BaseHUD.bStartThirdPerson = bStartThirdPerson.IsChecked();
        BaseHUD.bSpecMonsters = bSpecMonsters.IsChecked();
        BaseHUD.bDisplayBossTimer = bDisplayBossTimer.IsChecked();
        BaseHUD.bDisplayBossNames = bDisplayBossNames.IsChecked();
    }

    return true;
}

function InternalOnChange(GUIComponent Sender)
{
    if(Sender == bHideRadar)
    {
        if(bHideRadar.IsChecked())
        {
            bClassicRadar.DisableMe();
#ifeq ENABLE_TURINVX_RADAR 1
            bTURRadar.DisableMe();
#endif
        }
        else
        {
            bClassicRadar.EnableMe();
#ifeq ENABLE_TURINVX_RADAR 1
            bTURRadar.EnableMe();
#endif
        }
    }
#ifeq ENABLE_TURINVX_RADAR 1
    else if(Sender == bClassicRadar)
    {
        if(bClassicRadar.IsChecked())
        {
            bTURRadar.DisableMe();
        }
        else
        {
            bTURRadar.EnableMe();
        }
    }
    else if(Sender == bTURRadar)
    {
        if(bTURRadar.IsChecked())
        {
            bClassicRadar.DisableMe();
        }
        else
        {
            bClassicRadar.EnableMe();
        }
    }
#endif
    else if(Sender == RadarTexture)
    {
        RadarImage.Image = BaseHUD.RadarMaterials[GetRadarImageIndex()];
    }
    else if(Sender == PulseTexture)
    {
        PulseImage.Image = BaseHUD.PulseMaterials[GetPulseImageIndex()];
    }
    else if(Sender == OwnerIconTexture)
    {
        OwnerIcon.Image = BaseHUD.OwnerIconMaterials[GetOwnerIconIndex()];
    }
    else if(Sender == FriendlyPlayerIconTexture)
    {
        FriendlyPlayerIcon.Image = BaseHUD.FriendlyPlayerIconMaterials[GetFriendlyPlayerIconIndex()];
    }
    else if(Sender == FriendlyMonsterIconTexture)
    {
        FriendlyMonsterIcon.Image = BaseHUD.FriendlyMonsterIconMaterials[GetFriendlyMonsterIconIndex()];
    }
    else if(Sender == MonsterIconTexture)
    {
        MonsterIcon.Image = BaseHUD.MonsterIconMaterials[GetMonsterIconIndex()];
    }
    else if(Sender == MiscIconTexture)
    {
        MiscIcon.Image = BaseHUD.MiscIconMaterials[GetMiscIconIndex()];
    }

    SaveHud();
}

function bool InternalOnClick(GUIComponent Sender)
{
    SaveHud();
    Controller.CloseMenu();
    return true;
}

function bool PlayMonsterKillSound(GUIComponent Sender)
{
    local Sound SoundToPlay;

    if( currentKillSound.GetText() != "None" )
    {
        SoundToPlay = Sound(DynamicLoadObject(BaseHUD.EnemyKillSounds[GetKillSoundIndex()], class'Sound',true));
        PlayerOwner().PlaySound(SoundToPlay,,KillSoundVolume.GetValue(),true);
    }

    return true;
}

function bool PlayEnemyHitSound(GUIComponent Sender)
{
    local Sound SoundToPlay;

    if( currentEnemyHitSound.GetText() != "None" )
    {
        SoundToPlay = Sound(DynamicLoadObject(BaseHUD.EnemyHitSounds[GetEnemyHitSoundIndex()], class'Sound',true));
        PlayerOwner().PlaySound(SoundToPlay,,HitSoundVolume.GetValue(),true);
    }

    return true;
}

function bool PlayFriendlyHitSound(GUIComponent Sender)
{
    local Sound SoundToPlay;

    if( currentFriendlyHitSound.GetText() != "None" )
    {
        SoundToPlay = Sound(DynamicLoadObject(BaseHUD.FriendlyHitSounds[GetFriendlyHitSoundIndex()], class'Sound',true));
        PlayerOwner().PlaySound(SoundToPlay,,HitSoundVolume.GetValue(),true);
    }

    return true;
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
    if (currentScrollContainer == Sender)
    {
        if(currentScrollContainer.List != None)
        {
            currentScrollContainer.List.ColumnWidth = 0.45;
            currentScrollContainer.List.bVerticalLayout = true;
            currentScrollContainer.List.bHotTrack = true;
        }
    }

    Super.InternalOnCreateComponent(NewComp,Sender);
}

defaultproperties
{
     Begin Object Class=GUIMultiOptionListBox Name=MyRulesList
         bVisibleWhenEmpty=True
         OnCreateComponent=InvasionProHudConfig.InternalOnCreateComponent
         StyleName="ServerBrowserGrid"
         WinTop=0.100754
         WinLeft=0.438223
         WinWidth=0.519482
         WinHeight=0.827554
         bBoundToParent=True
         bScaleToParent=True
     End Object
     currentScrollContainer=GUIMultiOptionListBox'TURInvPro.InvasionProHudConfig.MyRulesList'

     Begin Object Class=GUILabel Name=cRadarPreviewLabel
         Caption="Radar Preview"
         TextAlign=TXTA_Center
         StyleName="ArrowLeft"
         WinTop=0.108102
         WinLeft=0.073798
         WinWidth=0.350654
         WinHeight=0.099198
         RenderWeight=0.200000
         bScaleToParent=True
     End Object
     RadarPreviewLabel=GUILabel'TURInvPro.InvasionProHudConfig.cRadarPreviewLabel'

     Begin Object Class=GUILabel Name=cColorUpdateLabel
         TextAlign=TXTA_Center
         FontScale=FNS_Small
         StyleName="ArrowLeft"
         WinTop=0.168767
         WinLeft=0.591485
         WinWidth=0.294370
         WinHeight=0.073585
         RenderWeight=0.200000
         OnDraw=InvasionProHudConfig.InternalDraw
     End Object
     ColorUpdateLabel=GUILabel'TURInvPro.InvasionProHudConfig.cColorUpdateLabel'

     Begin Object Class=GUILabel Name=cMonsterLabel
         Caption="Monster"
         FontScale=FNS_Small
         StyleName="ArrowLeft"
         WinTop=0.349254
         WinLeft=0.208636
         WinWidth=0.170098
         WinHeight=0.036698
         RenderWeight=0.200000
         bScaleToParent=True
     End Object
     MonsterLabel=GUILabel'TURInvPro.InvasionProHudConfig.cMonsterLabel'

        Begin Object Class=GUILabel Name=cFriendlyMonsterLabel
         Caption="Friendly Monster"
         FontScale=FNS_Small
         StyleName="ArrowLeft"
         WinTop=0.439789
         WinLeft=0.307015
         WinWidth=0.170098
         WinHeight=0.036698
         RenderWeight=0.200000
         bScaleToParent=True
     End Object
     FriendlyMonsterLabel=GUILabel'TURInvPro.InvasionProHudConfig.cFriendlyMonsterLabel'

     Begin Object Class=GUILabel Name=cPlayerLabel
         Caption="Friendly Player"
         FontScale=FNS_Small
         StyleName="ArrowLeft"
         WinTop=0.586301
         WinLeft=0.159532
         WinWidth=0.250654
         WinHeight=0.038087
         RenderWeight=0.200000
         bScaleToParent=True
     End Object
     PlayerLabel=GUILabel'TURInvPro.InvasionProHudConfig.cPlayerLabel'

     Begin Object Class=GUILabel Name=cOwnerLabel
         Caption="Owner"
         FontScale=FNS_Small
         StyleName="ArrowLeft"
         WinTop=0.502958
         WinLeft=0.262224
         WinWidth=0.156209
         WinHeight=0.043642
         RenderWeight=0.200000
         bScaleToParent=True
     End Object
     OwnerLabel=GUILabel'TURInvPro.InvasionProHudConfig.cOwnerLabel'

     Begin Object Class=GUILabel Name=cMiscLabel
         Caption="Misc/Other"
         FontScale=FNS_Small
         StyleName="ArrowLeft"
         WinTop=0.691460
         WinLeft=0.281705
         WinWidth=0.170098
         WinHeight=0.036698
         RenderWeight=0.200000
         bScaleToParent=True
     End Object
     MiscLabel=GUILabel'TURInvPro.InvasionProHudConfig.cMiscLabel'

     Begin Object Class=GUIImage Name=cPulseImage
         Image=TexRotator'TURInvPro.HUD.PulseRing02_Rot'
         ImageStyle=ISTY_Scaled
         WinTop=0.243467
         WinLeft=0.080373
         WinWidth=0.338142
         WinHeight=0.557261
         bScaleToParent=True
         bNeverFocus=True
     End Object
     PulseImage=GUIImage'TURInvPro.InvasionProHudConfig.cPulseImage'

     Begin Object Class=GUIImage Name=cRadarImage
         ImageStyle=ISTY_Scaled
         WinTop=0.264098
         WinLeft=0.081445
         WinWidth=0.334991
         WinHeight=0.513895
         bScaleToParent=True
         bNeverFocus=True
     End Object
     RadarImage=GUIImage'TURInvPro.InvasionProHudConfig.cRadarImage'

     Begin Object Class=GUIImage Name=cMonsterIcon
         Image=Texture'AW-2004Particles.Weapons.LargeSpot'
         ImageStyle=ISTY_Justified
         ImageRenderStyle=MSTY_Translucent
         WinTop=0.345163
         WinLeft=0.185152
         WinWidth=0.024618
         WinHeight=0.051487
         bScaleToParent=True
         bNeverFocus=True
     End Object
     MonsterIcon=GUIImage'TURInvPro.InvasionProHudConfig.cMonsterIcon'

     Begin Object Class=GUIImage Name=cFriendlyPlayerIcon
         Image=Texture'AW-2004Particles.Weapons.LargeSpot'
         ImageStyle=ISTY_Justified
         ImageRenderStyle=MSTY_Translucent
         WinTop=0.581973
         WinLeft=0.133883
         WinWidth=0.024618
         WinHeight=0.051487
         bScaleToParent=True
         bNeverFocus=True
     End Object
     FriendlyPlayerIcon=GUIImage'TURInvPro.InvasionProHudConfig.cFriendlyPlayerIcon'

        Begin Object Class=GUIImage Name=cFriendlyMonsterIcon
         Image=Texture'AW-2004Particles.Weapons.LargeSpot'
         ImageStyle=ISTY_Justified
         ImageRenderStyle=MSTY_Translucent
         WinTop=0.434588
         WinLeft=0.280082
         WinWidth=0.024618
         WinHeight=0.051487
         bScaleToParent=True
         bNeverFocus=True
     End Object
     FriendlyMonsterIcon=GUIImage'TURInvPro.InvasionProHudConfig.cFriendlyMonsterIcon'

     Begin Object Class=GUIImage Name=cOwnerIcon
         Image=Texture'AW-2004Particles.Weapons.LargeSpot'
         ImageStyle=ISTY_Justified
         ImageRenderStyle=MSTY_Translucent
         WinTop=0.499403
         WinLeft=0.233786
         WinWidth=0.031563
         WinHeight=0.044543
         bScaleToParent=True
         bNeverFocus=True
     End Object
     OwnerIcon=GUIImage'TURInvPro.InvasionProHudConfig.cOwnerIcon'

     Begin Object Class=GUIImage Name=cMiscIcon
         Image=Texture'AW-2004Particles.Weapons.LargeSpot'
         ImageStyle=ISTY_Justified
         ImageRenderStyle=MSTY_Translucent
         WinTop=0.687592
         WinLeft=0.254504
         WinWidth=0.024618
         WinHeight=0.051487
         bScaleToParent=True
         bNeverFocus=True
     End Object
     MiscIcon=GUIImage'TURInvPro.InvasionProHudConfig.cMiscIcon'

     Begin Object Class=AltSectionBackground Name=InternalFrameImage
         WinTop=0.075000
         WinLeft=0.040000
         WinWidth=0.675859
         WinHeight=0.550976
         bScaleToParent=True
         OnPreDraw=InternalFrameImage.InternalPreDraw
     End Object
     sb_Main=AltSectionBackground'TURInvPro.InvasionProHudConfig.InternalFrameImage'

     Begin Object Class=GUIButton Name=LockedCancelButton
         Caption="Default"
         Hint="Set the defaults for the hud"
         WinTop=0.926722
         WinLeft=0.201518
         WinWidth=0.124311
         WinHeight=0.043494
         TabOrder=32
         bBoundToParent=True
         bScaleToParent=True
         OnClick=InvasionProHudConfig.DefaultHud
         OnKeyEvent=LockedCancelButton.InternalOnKeyEvent
     End Object
     b_Cancel=GUIButton'TURInvPro.InvasionProHudConfig.LockedCancelButton'

     Begin Object Class=GUIButton Name=LockedOKButton
         Caption="Ok"
         Hint="Close"
         WinTop=0.927805
         WinLeft=0.091097
         WinWidth=0.105633
         WinHeight=0.043234
         TabOrder=31
         bBoundToParent=True
         bScaleToParent=True
         OnClick=InvasionProHudConfig.InternalOnClick
         OnKeyEvent=LockedOKButton.InternalOnKeyEvent
     End Object
     b_OK=GUIButton'TURInvPro.InvasionProHudConfig.LockedOKButton'

     RadarStyle(0)="Radar Style 01"
     RadarStyle(1)="Radar Style 02"
     RadarStyle(2)="Radar Style 03"
     RadarStyle(3)="Radar Style 04"
     RadarStyle(4)="Radar Style 05"
     RadarStyle(5)="Radar Style 06"
     RadarStyle(6)="Radar Style 07"
     RadarStyle(7)="Radar Style 08"
     RadarStyle(8)="Radar Style 09"
     RadarStyle(9)="Radar Style 10"
     PulseStyle(0)="Pulse Style 01"
     PulseStyle(1)="Pulse Style 02"
     PulseStyle(2)="Pulse Style 03"
     PulseStyle(3)="Pulse Style 04"
     PulseStyle(4)="Pulse Style 05"
     DefaultLeft=0.051126
     DefaultTop=0.027817
     DefaultWidth=0.900000
     DefaultHeight=0.900000
     bAllowedAsLast=True
     InactiveFadeColor=(A=0)
     WinTop=0.051109
     WinLeft=0.053726
     WinWidth=0.900000
     WinHeight=0.900000
     bScaleToParent=True
}
