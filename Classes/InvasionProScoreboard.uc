//=============================================================================
// InvasionProScoreboard.uc
// Copyright (C) 2021 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class InvasionProScoreboard extends ScoreBoardInvasion;

var() string MonsterTeamScoreString;
var() localized string LivesText;
var() array<PlayerReplicationInfo> PlayerList; //client sorted player list (no specs or anything else)
var() int PlayerCount; //constantly updated

simulated function InitGRI()
{
    GRI = xPlayer(Owner).GameReplicationInfo;
}

simulated event UpdateScoreBoard(Canvas Canvas)
{
//  local PlayerReplicationInfo OwnerPRI;
  local int i, x, FontReduction, NetXPos,HeaderOffsetY,HeadFoot, MessageFoot, PlayerBoxSizeY, BoxSpaceY, NameXPos, BoxTextOffsetY, ScoreXPos, DeathsXPos, BoxXPos, TitleYPos, BoxWidth;
  local float XL,YL, MaxScaling;
  local float deathsXL, scoreXL, netXL, MaxNamePos;
  local string playername[MAXPLAYERS];
  local bool bNameFontReduction;
  local Pawn P;
  local array<Pawn> PList;
  local bool bFound;

   if(Owner == None || GRI == None || GRI.Teams[0] == None || xPlayer(Owner) == None || xPlayer(Owner).PlayerReplicationInfo == None || GRI.PRIArray[0] == None || InvasionProHud(xPlayer(Owner).myHUD)==None)
   {
       return;
   }

  foreach DynamicActors(class'Pawn',P)
    if(Vehicle(P)!=None && P.PlayerReplicationInfo!=None && P.PlayerReplicationInfo.bBot && P.PlayerReplicationInfo.bIsSpectator)
      PList[PList.Length]=P;

   PlayerCount = 0;
   PlayerList.Remove(0, PlayerList.Length);
//  OwnerPRI = xPlayer(Owner).PlayerReplicationInfo;
   for (i=0; i<GRI.PRIArray.Length; i++)
   {
       if ( !GRI.PRIArray[i].bOnlySpectator || GRI.PRIArray[i].bWaitingPlayer )
       {
           if(!InvasionProHud(xPlayer(Owner).myHUD).bAddFriendlyMonstersToScoreboard && InvasionProFakeFriendlyMonsterReplicationInfo(GRI.PRIArray[i]) == None)
           {
        bFound=false;
        for(x=0; x<PList.Length; x++)
        {
          if(PList[x].PlayerReplicationInfo == GRI.PRIArray[i])
          {
            bFound=true;
            x=PList.Length;
          }
        }
        if(bFound)
          continue;

               PlayerList.Insert(PlayerCount,1);
               PlayerList[PlayerCount] = GRI.PRIArray[i];
               PlayerCount++;
           }
      else if(InvasionProHud(xPlayer(Owner).myHUD).bAddFriendlyMonstersToScoreboard && !InvasionProFakeFriendlyMonsterReplicationInfo(GRI.PRIArray[i]).bMinion)
      {
               PlayerList.Insert(PlayerCount,1);
               PlayerList[PlayerCount] = GRI.PRIArray[i];
               PlayerCount++;
      }
       }
   }

  //Select best font size and box size to fit as many players as possible on screen
  Canvas.Font = HUDClass.static.GetMediumFontFor(Canvas);
  Canvas.StrLen("Test", XL, YL);
  BoxSpaceY = 0.25 * YL;
  PlayerBoxSizeY = 1.5 * YL;
  HeadFoot = 7*YL;
  MessageFoot = 1.5 * HeadFoot;
  if ( PlayerCount > (Canvas.ClipY - 1.5 * HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) )
  {
      BoxSpaceY = 0.125 * YL;
      PlayerBoxSizeY = 1.25 * YL;
      if ( PlayerCount > (Canvas.ClipY - 1.5 * HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) )
      {
          if ( PlayerCount > (Canvas.ClipY - 1.5 * HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) )
              PlayerBoxSizeY = 1.125 * YL;
          if ( PlayerCount > (Canvas.ClipY - 1.5 * HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) )
          {
              FontReduction++;
              Canvas.Font = GetSmallerFontFor(Canvas,FontReduction);
              Canvas.StrLen("Test", XL, YL);
              BoxSpaceY = 0.125 * YL;
              PlayerBoxSizeY = 1.125 * YL;
              HeadFoot = 7*YL;
              if ( PlayerCount > (Canvas.ClipY - HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) )
              {
                  FontReduction++;
                  Canvas.Font = GetSmallerFontFor(Canvas,FontReduction);
                  Canvas.StrLen("Test", XL, YL);
                  BoxSpaceY = 0.125 * YL;
                  PlayerBoxSizeY = 1.125 * YL;
                  HeadFoot = 7*YL;
                  if ( (Canvas.ClipY >= 768) && (PlayerCount > (Canvas.ClipY - HeadFoot)/(PlayerBoxSizeY + BoxSpaceY)) )
                  {
                      FontReduction++;
                      Canvas.Font = GetSmallerFontFor(Canvas,FontReduction);
                      Canvas.StrLen("Test", XL, YL);
                      BoxSpaceY = 0.125 * YL;
                      PlayerBoxSizeY = 1.125 * YL;
                      HeadFoot = 7*YL;
                  }
              }
          }
      }
  }
  if ( Canvas.ClipX < 512 )
      PlayerCount = Min(PlayerCount, 1+(Canvas.ClipY - HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) );
  else
      PlayerCount = Min(PlayerCount, (Canvas.ClipY - HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) );

  if ( FontReduction > 2 )
      MaxScaling = 3;
  else
      MaxScaling = 2.125;
  PlayerBoxSizeY = FClamp((1+(Canvas.ClipY - 0.67 * MessageFoot))/PlayerCount - BoxSpaceY, PlayerBoxSizeY, MaxScaling * YL);

  bDisplayMessages = (PlayerCount <= (Canvas.ClipY - MessageFoot)/(PlayerBoxSizeY + BoxSpaceY));
  HeaderOffsetY = 5 * YL;
  BoxWidth = 0.9375 * Canvas.ClipX;
  BoxXPos = 0.5 * (Canvas.ClipX - BoxWidth);
  BoxWidth = Canvas.ClipX - 2*BoxXPos;
  NameXPos = BoxXPos + 0.0625 * BoxWidth;
  ScoreXPos = BoxXPos + 0.5 * BoxWidth;
  DeathsXPos = BoxXPos + 0.6875 * BoxWidth;
  NetXPos = BoxXPos + 0.8125 * BoxWidth;

  // draw background boxes
  Canvas.Style = ERenderStyle.STY_Alpha;
  Canvas.DrawColor = HUDClass.default.WhiteColor * 0.5;
  //HeaderOffsetY = HeaderOffsetY + TempOffset;
  for ( i=0; i<PlayerCount; i++ )
  {
      Canvas.SetPos(BoxXPos, HeaderOffsetY + (PlayerBoxSizeY + BoxSpaceY)*i);
      Canvas.DrawTileStretched( BoxMaterial, BoxWidth, PlayerBoxSizeY);
  }

  // draw team score box
  Canvas.StrLen(TeamScoreString$"    "$int(GRI.Teams[0].Score) @ " "$MonsterTeamScoreString$"    "$InvasionProGameReplicationInfo(GRI).MonsterTeamScore, ScoreXL, YL);///
  Canvas.DrawColor = HUDClass.Default.BlueColor;
  Canvas.SetPos(BoxXPos, HeaderOffsetY - 2.75*YL);
  Canvas.DrawTileStretched( BoxMaterial, ScoreXL+ 0.125 * BoxWidth, 1.25 * YL);

  // draw title
  Canvas.Style = ERenderStyle.STY_Normal;
  DrawTitle(Canvas, HeaderOffsetY, (PlayerCount+1)*(PlayerBoxSizeY + BoxSpaceY), PlayerBoxSizeY);

  // draw team score box
  Canvas.SetPos(NameXPos,HeaderOffsetY - 2.5*YL);
  Canvas.DrawText(TeamScoreString$"    "$int(GRI.Teams[0].Score)  @ " "$MonsterTeamScoreString$"    "$InvasionProGameReplicationInfo(GRI).MonsterTeamScore,true);

  // Draw headers
  TitleYPos = HeaderOffsetY - 1.25*YL;
  Canvas.StrLen(PointsText, ScoreXL, YL);
  Canvas.StrLen(DeathsText, DeathsXL, YL);

  Canvas.DrawColor = HUDClass.default.WhiteColor;
  Canvas.SetPos(NameXPos, TitleYPos);
  Canvas.DrawText(PlayerText,true);
  Canvas.SetPos(ScoreXPos - 0.5*ScoreXL, TitleYPos);
  Canvas.DrawText(PointsText,true);

   // Draw Lives
  Canvas.SetPos(DeathsXPos - 0.5*DeathsXL, TitleYPos);
   Canvas.DrawText(LivesText,true);

  // draw player names
  MaxNamePos = 0.9 * (ScoreXPos - NameXPos);
  for ( i=0; i<PlayerCount; i++ )
  {
      Playername[i] = PlayerList[i].PlayerName;
      Canvas.StrLen(playername[i], XL, YL);
      if ( XL > MaxNamePos )
      {
          bNameFontReduction = true;
          break;
      }
  }

  if ( bNameFontReduction )
  {
    Canvas.Font = GetSmallerFontFor(Canvas,FontReduction+1);
   }

    for ( i=0; i<PlayerCount; i++ )
    {
        Playername[i] = PlayerList[i].PlayerName;
        Canvas.StrLen(Playername[i], XL, YL);
        if ( XL > MaxNamePos )
        {
            Playername[i] = left(Playername[i], MaxNamePos/XL * len(PlayerName[i]));
           }
    }

    Canvas.Style = ERenderStyle.STY_Normal;
    Canvas.DrawColor = HUDClass.default.WhiteColor;
    Canvas.SetPos(0.5 * Canvas.ClipX, HeaderOffsetY + 4);///////////////4
    BoxTextOffsetY = HeaderOffsetY + 0.5 * (PlayerBoxSizeY - YL);

    Canvas.DrawColor = HUDClass.default.WhiteColor;
    for ( i=0; i<PlayerCount; i++ )
    {
       Canvas.SetPos(NameXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
       Canvas.DrawText(Playername[i],true);
   }

    if ( bNameFontReduction )
    {
        Canvas.Font = GetSmallerFontFor(Canvas,FontReduction);
   }

    // draw scores
    Canvas.DrawColor = HUDClass.default.WhiteColor;
    for ( i=0; i<PlayerCount; i++ )
    {
       Canvas.SetPos(ScoreXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
       Canvas.DrawText(int(PlayerList[i].Score),true);
   }

  // draw deaths/numlives
   Canvas.DrawColor = HUDClass.default.WhiteColor;

   for ( i=0; i<PlayerCount; i++ )
   {
       Canvas.SetPos(DeathsXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
       if ( PlayerList[i].bOutOfLives )
       {
           Canvas.DrawText(OutText,true);
       }
       else
       {
           //- numlives instead of deaths, numlives is now reset at start of wave
           //if always one life then don't bother drawing number of lives, only draw if out
           if(!InvasionProGameReplicationInfo(GRI).bAlwaysOneLife)
           {
               Canvas.DrawText(InvasionProGameReplicationInfo(GRI).GetNumLives(PlayerList[i]),true);
           }
       }
   }

  if ( Level.NetMode == NM_Standalone )
      return;

  Canvas.StrLen(NetText, NetXL, YL);
  Canvas.DrawColor = HUDClass.default.WhiteColor;
  Canvas.SetPos(NetXPos + 0.5*NetXL, TitleYPos);
  Canvas.DrawText(NetText,true);

  for ( i=0; i<PlayerList.Length; i++ )
  {
      PRIArray[i] = PlayerList[i];
  }

  DrawNetInfo(Canvas,FontReduction,HeaderOffsetY,PlayerBoxSizeY,BoxSpaceY,BoxTextOffsetY,-1,PlayerCount,NetXPos);
  DrawMatchID(Canvas,FontReduction);
}

function DrawTitle(Canvas Canvas, float HeaderOffsetY, float PlayerAreaY, float PlayerBoxSizeY)
{
    local string titlestring,scoreinfostring,RestartString;
    local float TitleXL,ScoreInfoXL,YL;

    if ( Canvas.ClipX < 512 )
        return;

    titlestring = SkillLevel[Clamp(InvasionProGameReplicationInfo(GRI).BaseDifficulty,0,7)]@GRI.GameName@WaveString@(InvasionProGameReplicationInfo(GRI).WaveNumber+1)$MapName$Level.Title;
    Canvas.StrLen(TitleString,TitleXL,YL);

    if ( GRI.MaxLives != 0 )
        ScoreInfoString = MaxLives@GRI.MaxLives;
    else if ( GRI.GoalScore != 0 )
        ScoreInfoString = FragLimit@GRI.GoalScore;
    if ( GRI.TimeLimit != 0 )
        ScoreInfoString = ScoreInfoString@spacer@TimeLimit$FormatTime(GRI.RemainingTime);
    else
        ScoreInfoString = ScoreInfoString@spacer@FooterText@FormatTime(GRI.ElapsedTime);

    Canvas.DrawColor = HUDClass.default.GoldColor;
    if ( UnrealPlayer(Owner).bDisplayLoser )
        ScoreInfoString = class'HUDBase'.default.YouveLostTheMatch;
    else if ( UnrealPlayer(Owner).bDisplayWinner )
        ScoreInfoString = class'HUDBase'.default.YouveWonTheMatch;
    else if ( PlayerController(Owner).IsDead() )
    {
        RestartString = Restart;
        if ( PlayerController(Owner).PlayerReplicationInfo.bOutOfLives )
            RestartString = OutFireText;
        if ( Canvas.ClipY - HeaderOffsetY - PlayerAreaY >= 2.5 * YL )
        {
            Canvas.StrLen(RestartString,ScoreInfoXL,YL);
            Canvas.SetPos(0.5*(Canvas.ClipX-ScoreInfoXL), Canvas.ClipY - 2.5 * YL);
            Canvas.DrawText(RestartString,true);
        }
        else
            ScoreInfoString = RestartString;
    }
    Canvas.StrLen(ScoreInfoString,ScoreInfoXL,YL);

    Canvas.SetPos(0.5*(Canvas.ClipX-TitleXL), ((HeaderOffsetY-PlayerBoxSizeY) - YL)*0.5 );
    Canvas.DrawText(TitleString,true);
    Canvas.SetPos(0.5*(Canvas.ClipX-ScoreInfoXL), Canvas.ClipY - 1.5 * YL);
    Canvas.DrawText(ScoreInfoString,true);
}

function DrawNetInfo(Canvas Canvas,int FontReduction,int HeaderOffsetY,int PlayerBoxSizeY,int BoxSpaceY,int BoxTextOffsetY,int OwnerOffset,int PlayerCount, int NetXPos)
{
   local float XL,YL;
   local int i;
   local bool bHaveHalfFont, bDrawFPH, bDrawPL;

   Canvas.DrawColor = HUDClass.default.CyanColor;
   Canvas.Font = GetSmallFontFor(Canvas.ClipX, FontReduction);
   Canvas.StrLen("Test", XL, YL);
   BoxTextOffsetY = HeaderOffsetY + 0.5*PlayerBoxSizeY;
   bHaveHalfFont = ( YL < 0.5 * PlayerBoxSizeY);
   // if game hasn't begun, draw ready or not ready
   if ( !GRI.bMatchHasBegun )
   {
       bDrawPL = PlayerBoxSizeY > 3 * YL;
       for ( i=0; i<PlayerCount; i++ )
       {
           if ( bDrawPL )
           {
               Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.5 * YL);
               Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
               Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5 * YL);
               Canvas.DrawText(PLText@PRIArray[i].PacketLoss,true);
               Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.5 * YL);
           }
           else if ( bHaveHalfFont )
           {
               Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - YL);
               Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
               Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
           }
           else
               Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5*YL);
           if ( PRIArray[i].bReadyToPlay )
               Canvas.DrawText(ReadyText,true);
           else
               Canvas.DrawText(NotReadyText,true);
       }
       return;
   }

   // draw time and ping
   if ( Canvas.ClipX < 512 )
       PingText = "";
   else
   {
       PingText = Default.PingText;
       bDrawFPH = PlayerBoxSizeY > 3 * YL;
       bDrawPL = PlayerBoxSizeY > 4 * YL;
   }
   if ( ((FPHTime == 0) || (!UnrealPlayer(Owner).bDisplayLoser && !UnrealPlayer(Owner).bDisplayWinner))
       && (GRI.ElapsedTime > 0) )
       FPHTime = GRI.ElapsedTime;

   for ( i=0; i<PlayerCount; i++ )
   {
       if( PRIArray[i].bAdmin )
           Canvas.DrawColor = HUDClass.default.RedColor;
       else Canvas.DrawColor = HUDClass.default.CyanColor;
       if ( bDrawPL )
       {
           Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.9 * YL);
           Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
           Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.9 * YL);
           Canvas.DrawText(PLText@PRIArray[i].PacketLoss,true);
           Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.1 * YL);
           Canvas.DrawText(FPH@Clamp(3600*PRIArray[i].Score/FMax(1,FPHTime - PRIArray[i].StartTime),-999,9999),true);
           Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 1.1 * YL);
           Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[i].StartTime)),true);
       }
       else if ( bDrawFPH )
       {
           Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.5 * YL);
           Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
           Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5 * YL);
           Canvas.DrawText(FPH@Clamp(3600*PRIArray[i].Score/FMax(1,FPHTime - PRIArray[i].StartTime),-999,9999),true);
           Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.5 * YL);
           Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[i].StartTime)),true);
       }
       else if ( bHaveHalfFont )
       {
           Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - YL);
           Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
           Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
           Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[i].StartTime)),true);
       }
       else
       {
           Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5*YL);
           Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
       }
   }
}

defaultproperties
{
     MonsterTeamScoreString="Monster Score"
     LivesText="LIVES"
}
