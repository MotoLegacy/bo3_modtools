#using scripts\codescripts\struct;

#using scripts\shared\callbacks_shared;
#using scripts\shared\music_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;

#using scripts\zm\gametypes\_globallogic_utils;

#using scripts\zm\_util;

#namespace globallogic_audio;

REGISTER_SYSTEM( "globallogic_audio", &__init__, undefined )

function __init__()
{	
	callback::on_start_gametype( &init );
}

function init()
{
		game["music"]["defeat"] = "mus_defeat";
		game["music"]["victory_spectator"] = "mus_defeat";
		game["music"]["winning"] = "mus_time_running_out_winning";
		game["music"]["losing"] = "mus_time_running_out_losing";
		game["music"]["match_end"] = "mus_match_end";
		game["music"]["victory_tie"] = "mus_defeat";
		
		game["music"]["suspense"] = [];
		game["music"]["suspense"][game["music"]["suspense"].size] = "mus_suspense_01";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mus_suspense_02";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mus_suspense_03";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mus_suspense_04";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mus_suspense_05";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mus_suspense_06";

		game["dialog"]["mission_success"] = "mission_success";
		game["dialog"]["mission_failure"] = "mission_fail";
		game["dialog"]["mission_draw"] = "draw";

		game["dialog"]["round_success"] = "encourage_win";
		game["dialog"]["round_failure"] = "encourage_lost";
		game["dialog"]["round_draw"] = "draw";
		
		// status
		game["dialog"]["timesup"] = "timesup";
		game["dialog"]["winning"] = "winning";
		game["dialog"]["losing"] = "losing";
		game["dialog"]["min_draw"] = "min_draw";
		game["dialog"]["lead_lost"] = "lead_lost";
		game["dialog"]["lead_tied"] = "tied";
		game["dialog"]["lead_taken"] = "lead_taken";
		game["dialog"]["last_alive"] = "lastalive";

		game["dialog"]["boost"] = "generic_boost";

		if ( !isdefined( game["dialog"]["offense_obj"] ) )
			game["dialog"]["offense_obj"] = "generic_boost";
		if ( !isdefined( game["dialog"]["defense_obj"] ) )
			game["dialog"]["defense_obj"] = "generic_boost";
		
		game["dialog"]["hardcore"] = "hardcore";
		game["dialog"]["oldschool"] = "oldschool";
		game["dialog"]["highspeed"] = "highspeed";
		game["dialog"]["tactical"] = "tactical";

		game["dialog"]["challenge"] = "challengecomplete";
		game["dialog"]["promotion"] = "promotion";

		game["dialog"]["bomb_acquired"] = "sd_bomb_taken";
		game["dialog"]["bomb_taken"] = "sd_bomb_taken_taken";
		game["dialog"]["bomb_lost"] = "sd_bomb_drop";
		game["dialog"]["bomb_defused"] = "sd_bomb_defused";
		game["dialog"]["bomb_planted"] = "sd_bomb_planted";

		game["dialog"]["obj_taken"] = "securedobj";
		game["dialog"]["obj_lost"] = "lostobj";

		game["dialog"]["obj_defend"] = "defend_start";
		game["dialog"]["obj_destroy"] = "destroy_start";
		game["dialog"]["obj_capture"] = "capture_obj";
		game["dialog"]["objs_capture"] = "capture_objs";

		game["dialog"]["hq_located"] = "hq_located";
		game["dialog"]["hq_enemy_captured"] = "hq_capture";
		game["dialog"]["hq_enemy_destroyed"] = "hq_defend";
		game["dialog"]["hq_secured"] = "hq_secured";
		game["dialog"]["hq_offline"] = "hq_offline";
		game["dialog"]["hq_online"] = "hq_online";
		
		game["dialog"]["koth_located"] = "koth_located";
		game["dialog"]["koth_captured"] = "koth_captured";
		game["dialog"]["koth_lost"] = "koth_lost";
		game["dialog"]["koth_secured"] = "koth_secured";
		game["dialog"]["koth_contested"] = "koth_contest";
		game["dialog"]["koth_offline"] = "koth_offline";
		game["dialog"]["koth_online"] = "koth_online";


		game["dialog"]["move_to_new"] = "new_positions";

		game["dialog"]["attack"] = "attack";
		game["dialog"]["defend"] = "defend";
		game["dialog"]["offense"] = "offense";
		game["dialog"]["defense"] = "defense";

		game["dialog"]["halftime"] = "halftime";
		game["dialog"]["overtime"] = "overtime";
		game["dialog"]["side_switch"] = "switchingsides";

		game["dialog"]["flag_taken"] = "ourflag";
		game["dialog"]["flag_dropped"] = "ourflag_drop";
		game["dialog"]["flag_returned"] = "ourflag_return";
		game["dialog"]["flag_captured"] = "ourflag_capt";
		game["dialog"]["enemy_flag_taken"] = "enemyflag";
		game["dialog"]["enemy_flag_dropped"] = "enemyflag_drop";
		game["dialog"]["enemy_flag_returned"] = "enemyflag_return";
		game["dialog"]["enemy_flag_captured"] = "enemyflag_capt";

		/*game["dialog"]["capturing_a"] = "dom_capturing_a";
		game["dialog"]["capturing_b"] = "dom_capturing_b";
		game["dialog"]["capturing_c"] = "dom_capturing_c";
		game["dialog"]["capturing_d"] = "dom_capturing_d";
		game["dialog"]["capturing_e"] = "dom_capturing_e";
		game["dialog"]["capturing_f"] = "dom_capturing_f";
		game["dialog"]["captured_a"] = "dom_capture_a";
		game["dialog"]["captured_b"] = "dom_capture_b";
		game["dialog"]["captured_c"] = "dom_capture_c";
		game["dialog"]["captured_d"] = "dom_capture_d";
		game["dialog"]["captured_e"] = "dom_capture_e";
		game["dialog"]["captured_f"] = "dom_capture_f";*/

		game["dialog"]["securing_a"] = "dom_securing_a";
		game["dialog"]["securing_b"] = "dom_securing_b";
		game["dialog"]["securing_c"] = "dom_securing_c";
		game["dialog"]["securing_d"] = "dom_securing_d";
		game["dialog"]["securing_e"] = "dom_securing_e";
		game["dialog"]["securing_f"] = "dom_securing_f";
		game["dialog"]["secured_a"] = "dom_secured_a";
		game["dialog"]["secured_b"] = "dom_secured_b";
		game["dialog"]["secured_c"] = "dom_secured_c";
		game["dialog"]["secured_d"] = "dom_secured_d";
		game["dialog"]["secured_e"] = "dom_secured_e";
		game["dialog"]["secured_f"] = "dom_secured_f";

		game["dialog"]["losing_a"] = "dom_losing_a";
		game["dialog"]["losing_b"] = "dom_losing_b";
		game["dialog"]["losing_c"] = "dom_losing_c";
		game["dialog"]["losing_d"] = "dom_losing_d";
		game["dialog"]["losing_e"] = "dom_losing_e";
		game["dialog"]["losing_f"] = "dom_losing_f";
		game["dialog"]["lost_a"] = "dom_lost_a";
		game["dialog"]["lost_b"] = "dom_lost_b";
		game["dialog"]["lost_c"] = "dom_lost_c";
		game["dialog"]["lost_d"] = "dom_lost_d";
		game["dialog"]["lost_e"] = "dom_lost_e";
		game["dialog"]["lost_f"] = "dom_lost_f";

		/*game["dialog"]["enemy_taking_a"] = "enemy_take_a";
		game["dialog"]["enemy_taking_b"] = "enemy_take_b";
		game["dialog"]["enemy_taking_c"] = "enemy_take_c";
		game["dialog"]["enemy_taking_d"] = "enemy_take_d";
		game["dialog"]["enemy_taking_e"] = "enemy_take_e";
		game["dialog"]["enemy_taking_f"] = "enemy_take_f";
		game["dialog"]["enemy_has_a"] = "enemy_has_a";
		game["dialog"]["enemy_has_b"] = "enemy_has_b";
		game["dialog"]["enemy_has_c"] = "enemy_has_c";
		game["dialog"]["enemy_has_d"] = "enemy_has_d";
		game["dialog"]["enemy_has_e"] = "enemy_has_e";
		game["dialog"]["enemy_has_f"] = "enemy_has_f";*/

		//War
		game["dialog"]["secure_flag"] = "secure_flag";
		game["dialog"]["securing_flag"] = "securing_flag";
		game["dialog"]["losing_flag"] = "losing_flag";
		game["dialog"]["lost_flag"] = "lost_flag";
		game["dialog"]["oneflag_enemy"] = "oneflag_enemy";
		game["dialog"]["oneflag_friendly"] = "oneflag_friendly";

		game["dialog"]["lost_all"] = "dom_lock_theytake";
		game["dialog"]["secure_all"] = "dom_lock_wetake";

		//squads
		game["dialog"]["squad_move"] = "squad_move";
		game["dialog"]["squad_30sec"] = "squad_30sec";
		game["dialog"]["squad_winning"] = "squad_onemin_vic";
		game["dialog"]["squad_losing"] = "squad_onemin_loss";
		game["dialog"]["squad_down"] = "squad_down";
		game["dialog"]["squad_bomb"] = "squad_bomb";
		game["dialog"]["squad_plant"] = "squad_plant";
		game["dialog"]["squad_take"] = "squad_takeobj";

		//Player kicked
		game["dialog"]["kicked"] = "player_kicked";

		//Equipment and turret destroyed lines
		game["dialog"]["sentry_destroyed"] = "dest_sentry";
		game["dialog"]["sentry_hacked"] = "kls_turret_hacked";
		game["dialog"]["microwave_destroyed"] = "dest_microwave";
		game["dialog"]["microwave_hacked"] = "kls_microwave_hacked";
		game["dialog"]["sam_destroyed"] = "dest_sam";
		game["dialog"]["tact_destroyed"] = "dest_tact";
		game["dialog"]["equipment_destroyed"] = "dest_equip";
		game["dialog"]["hacked_equip"] = "hacked_equip";
		game["dialog"]["uav_destroyed"] = "kls_u2_destroyed";
		game["dialog"]["cuav_destroyed"] = "kls_cu2_destroyed";
		
		level.dialogGroups = [];
		
		//level thread suspenseMusic();
		level thread post_match_snapshot_watcher();
}

function registerDialogGroup( group, skipIfCurrentlyPlayingGroup )
{
	if ( !isdefined( level.dialogGroups ) )	
	{
		level.dialogGroups = [];
	}
	else if ( isdefined(level.dialogGroup[group]) )
	{
		util::error( "registerDialogGroup:  Dialog group " + group + " already registered." );
		return;
	}
	
	level.dialogGroup[group] = SpawnStruct();
	level.dialogGroup[group].group = group;
	level.dialogGroup[group].skipIfCurrentlyPlayingGroup = skipIfCurrentlyPlayingGroup;
	level.dialogGroup[group].currentCount = 0;
}

function sndStartMusicSystem()
{
	self endon( "disconnect" );
	
	if ( game["state"] == "postgame" )
		// if the games over do not change music state
		return;
	if ( !isdefined(level.nextMusicState) )
	{	
		//wait 25;
		self.pers["music"].currentState = "UNDERSCORE";		
		//self thread globallogic_audio::set_music_on_player( "UNDERSCORE", true );		
		self thread suspenseMusic(); 
	}
}	

function suspenseMusicForPlayer()
{
	self endon("disconnect");
	
//	self thread set_music_on_player( "SILENT", false );		
	
//	wait (1);
	
	self thread set_music_on_player( "UNDERSCORE", false );
}

function suspenseMusic( random )
{
	level endon ( "game_ended" );
	level endon ( "match_ending_soon" );
	self endon( "disconnect" );

	//wait 35;
	
	while (1)
	{	
		wait( randomintrange( 25, 60 ) );

		if ( !isdefined( self.pers["music"].inque ) )	
		{
			// ensure that false is default
			self.pers["music"].inque = false;
		}	

		if ( self.pers["music"].inque )
		{
			continue;
		}
			
		if ( !isdefined( self.pers["music"].currentState ) )	
		{
			// ensure that false is default
			self.pers["music"].currentState = "SILENT";
		}	
		
		//self.underscoreChance  = 100;
		if( RandomInt( 100 ) < self.underscoreChance && self.pers["music"].currentState != "ACTION" && self.pers["music"].currentState != "TIME_OUT" )
		{
			self thread suspenseMusicForPlayer(); 
			self.underscoreChance = self.underscoreChance - 20;
		}
	}
}

function leaderDialogForOtherTeams( dialog, skip_team, squad_dialog )
{
	foreach( team in level.teams )
	{
		if ( team != skip_team )
		{
			leaderDialog( dialog, team, undefined, undefined, squad_dialog );
		}
	}
}

function announceRoundWinner( winner, delay )
{
	if ( delay > 0 )
		wait delay;

	if ( !isdefined( winner ) || isPlayer( winner ) )
		return;

	if ( isdefined( level.teams[ winner ] ) )
	{
		//thread util::playSoundOnPlayers( "mus_round_win"+"_"+level.teamPostfix[winner] );
		//thread util::playSoundOnPlayers( "mus_round_loss"+"_"+level.teamPostfix[team] );
		leaderDialog( "round_success", winner );
		leaderDialogForOtherTeams( "round_failure", winner );
	}
	else
	{
		foreach ( team in level.teams )
		{
			thread util::playSoundOnPlayers( "mus_round_draw"+"_"+level.teamPostfix[team] );
		}
		leaderDialog( "round_draw" );
	}
}


function announceGameWinner( winner, delay )
{
	if ( delay > 0 )
		wait delay;

	if ( !isdefined( winner ) || isPlayer( winner ) )
		return;

	if ( isdefined( level.teams[ winner ] ) )
	{
		leaderDialog( "mission_success", winner );
		leaderDialogForOtherTeams( "mission_failure", winner );
	}
	else
	{
		leaderDialog( "mission_draw" );
	}
}


function doFlameAudio()
{
	self endon("disconnect");
	waittillframeend;
	
	if (!isdefined ( self.lastFlameHurtAudio ) )
		self.lastFlameHurtAudio = 0;
		
	currentTime = gettime();
	
	if ( self.lastFlameHurtAudio + level.fire_audio_repeat_duration + RandomInt( level.fire_audio_random_max_duration ) < currentTime )
	{
		self playLocalSound("vox_pain_small");
		self.lastFlameHurtAudio = currentTime;
	} 
}


function leaderDialog( dialog, team, group, excludeList, squadDialog )
{
	assert( isdefined( level.players ) );
		
	if ( level.splitscreen )
		return;
		
	if ( level.wagerMatch )
		return;
		
	if ( !isdefined( team ) )
	{
		dialogs = [];
		foreach ( team in level.teams )
		{
			dialogs[team] = dialog;
		}
		leaderDialogAllTeams( dialogs, group, excludeList );
		return;
	}
	
	if ( level.splitscreen )
	{
		if ( level.players.size )
			level.players[0] leaderDialogOnPlayer( dialog, group );
		return;
	}
	
	
	if ( isdefined( excludeList ) )
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ( (isdefined( player.pers["team"] ) && (player.pers["team"] == team )) && !globallogic_utils::isExcluded( player, excludeList ) )
				player leaderDialogOnPlayer( dialog, group );
		}
	}
	else
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ( isdefined( player.pers["team"] ) && (player.pers["team"] == team ) )
				player leaderDialogOnPlayer( dialog, group );
		}
	}
}

function leaderDialogAllTeams( dialogs, group, excludeList )
{
	assert( isdefined( level.players ) );
	
	if ( level.splitscreen )
		return;

	if ( level.splitscreen )
	{
		if ( level.players.size )
			level.players[0] leaderDialogOnPlayer( dialogs[level.players[0].team], group );
		return;
	}

	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		team = player.pers["team"];
		
		if ( !isdefined( team ) )
			continue;
		
		if ( !isdefined( dialogs[team] ) )
			continue;
			
		if ( isdefined( excludeList ) && globallogic_utils::isExcluded( player, excludeList ) )
			continue;
		
		player leaderDialogOnPlayer( dialogs[team], group );
	}
}

function flushDialog()
{
	foreach( player in level.players )
	{
		player flushDialogOnPlayer();
	}
}

function flushDialogOnPlayer()
{
	self.leaderDialogGroups = [];
	self.leaderDialogQueue = [];
	self.leaderDialogActive = false;
	self.currentLeaderDialogGroup = "";
}


function flushGroupDialog( group )
{
	foreach( player in level.players )
	{
		 player flushGroupDialogOnPlayer( group );
	}
}

function flushGroupDialogOnPlayer( group )
{
	self.leaderDialogGroups[group] = undefined;
	
	foreach( key, dialog in self.leaderDialogQueue )
	{
		if ( dialog == group )
			self.leaderDialogQueue[key] = undefined;
	}
}

function addGroupDialogToPlayer( dialog, group )
{
	if ( !isdefined( level.dialogGroup[group]) )
	{
		util::error( "leaderDialogOnPlayer:  Dialog group " + group + " is not registered" );
		return false;
	}
	
	addToQueue = false;
	
	if ( !isdefined( self.leaderDialogGroups[group] ) )
	{
		addToQueue = true;
	}

	if ( !level.dialogGroup[group].skipIfCurrentlyPlayingGroup )
	{
		// we will skip if we are actually playing this VO already, unless almost at the end
		if ( self.currentLeaderDialog == dialog && 	self.currentLeaderDialogTime + 2000 > GetTime() )
		{
			// if we are currentlyPlaying this dialog then we dont want any of the groups dialogs to play
			self.leaderDialogGroups[group] = undefined;
			
			foreach ( key, leader_dialog in self.leaderDialogQueue)
			{
				if ( leader_dialog == group )
				{
					for ( i = key + 1; i < self.leaderDialogQueue.size; i++ )
						self.leaderDialogQueue[i-1] = self.leaderDialogQueue[i];
					self.leaderDialogQueue[i-1] = undefined;
					break;
				}
			}
	
			return false;
		}
		
	}
	else
	{
		// ignore the message if one from the same group is already playing
		if ( self.currentLeaderDialogGroup == group )
		{
			return false;
		}
	}
	
	self.leaderDialogGroups[group] = dialog;
	
	return addToQueue;
}

function testDialogQueue(group)
{
}

function leaderDialogOnPlayer( dialog, group )
{
	team = self.pers["team"];

	if ( level.splitscreen )
		return;
	
	if ( !isdefined( team ) )
		return;
	
	if ( !isdefined( level.teams[team] ) )
		return;
	
	if ( isdefined( group ) )
	{
		// exit because the "group" dialog call is already in the queue
		if ( !addGroupDialogToPlayer( dialog, group ) )
		{
			self testDialogQueue(group);
			return;
		}
			
		dialog = group;		
	}

	if ( !self.leaderDialogActive )
		self thread playLeaderDialogOnPlayer( dialog );
	else
		self.leaderDialogQueue[self.leaderDialogQueue.size] = dialog;
}

function waitForSound( sound, extraTime )
{
	if (!isdefined(extraTime) )
	{
		// allow the announcer to take a breath
		extraTime = 0.1;
	}
	
	time = soundgetplaybacktime( sound );	
	
	if ( time < 0 )
		wait( 3.0 + extraTime );
	else
		wait( time * 0.001 + extraTime );
}

function playLeaderDialogOnPlayer( dialog )
{
	if( isdefined(level.allowAnnouncer) && !level.allowAnnouncer )
		return;

	team = self.pers[ "team" ];

	self endon ( "disconnect" );
	
	self.leaderDialogActive = true;
	if ( isdefined( self.leaderDialogGroups[dialog] ) )
	{
		group = dialog;
		dialog = self.leaderDialogGroups[group];
		self.leaderDialogGroups[group] = undefined;
		self.currentLeaderDialogGroup = group;
		self testDialogQueue(group);
	}

	if ( level.wagerMatch || !isdefined(game["voice"]) )
		faction = "vox_wm_";
	else
		faction = game["voice"][team];
		
	sound_name = faction+game["dialog"][dialog];
	
	if( level.allowAnnouncer )
	{
		self playLocalSound( sound_name );
		self.currentLeaderDialog = dialog;
		self.currentLeaderDialogTime = GetTime();
	}

	waitForSound( sound_name );
	
	self.leaderDialogActive = false;
	self.currentLeaderDialogGroup = "";
	self.currentLeaderDialog = "";

	if ( self.leaderDialogQueue.size > 0 )
	{
		nextDialog = self.leaderDialogQueue[0];
		
		for ( i = 1; i < self.leaderDialogQueue.size; i++ )
			self.leaderDialogQueue[i-1] = self.leaderDialogQueue[i];
		self.leaderDialogQueue[i-1] = undefined;
		if ( isdefined( self.leaderDialogGroups[dialog] ) )
			self testDialogQueue(dialog);
			
		self thread playLeaderDialogOnPlayer( nextDialog );
	}
}

function isTeamWinning( checkTeam )
{
	score = game["teamScores"][checkTeam];
	
	foreach ( team in level.teams )
	{
		if ( team != checkTeam )
		{
			if ( game["teamScores"][team] >= score )
				return false;
		}
	}
	
	return true;
}

function announceTeamIsWinning()
{
	foreach ( team in level.teams )
	{
		if ( isTeamWinning( team ) )
		{
			leaderDialog( "winning", team, undefined, undefined, "squad_winning" );
			leaderDialogForOtherTeams( "losing", team, "squad_losing" );
			return true;
		}
	}
	
	return false;
}

function musicController()
{
	level endon ( "game_ended" );
	
	level thread musicTimesOut();
	
	level waittill ( "match_ending_soon" );

	if ( util::isLastRound() || util::isOneRound() )
	{	
		if ( !level.splitScreen )
		{
			if( level.teamBased )
			{
				if( !announceTeamIsWinning() )
				{
					leaderDialog( "min_draw" );
				}
			}
			
			level waittill ( "match_ending_very_soon" );
			
			foreach ( team in level.teams )
			{
				leaderDialog( "timesup", team, undefined, undefined , "squad_30sec" );
			}
		}
	}
	else
	{
		level waittill ( "match_ending_vox" );

		leaderDialog( "timesup" );
	}
}

function musicTimesOut()
{
    level endon( "game_ended" );
    
    level waittill ( "match_ending_very_soon" );
    
 // removed action music replaced with ending soon for more consistant messaging. CDC
 //   if( !isdefined( level.playingActionMusic ) )
  //      level.playingActionMusic = false;

	//IPrintLnBold( "30 SECS LEFT: Time Out Music State" ); 
	
//	if( !level.playingActionMusic )
    thread globallogic_audio::set_music_on_team( "TIME_OUT", "both" , true, false );
}

function actionMusicSet()
{
    level endon( "game_ended" );
    level.playingActionMusic = true;
    wait(45);
    level.playingActionMusic = false;
}

function play_2d_on_team( alias, team )
{
	assert( isdefined( level.players ) );
	
	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if ( isdefined( player.pers["team"] ) && (player.pers["team"] == team ) )
		{
			player playLocalSound( alias );
		}	
	}
}

function set_music_on_team( state, team, save_state, return_state, wait_time )
{
	if( SessionModeIsZombiesGame() )
		return;
		
	// Assert if there are no players
	assert( isdefined( level.players ) );
	
	if ( !isdefined( team ) )	
	{
		team = "both";
	}
	if ( !isdefined( save_state ) )	
	{
		save_sate = false;
	}
	if ( !isdefined( return_state ) )	
	{
		return_state = false;
	}	
	if ( !isdefined( wait_time ) )	
	{
		wait_time = 0;
	}
		
	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if ( team == "both" )
		{
			// if no team is set or team is set to "both" set same state for all players
			player thread set_music_on_player ( state, save_state, return_state, wait_time );			
		}	
		else if ( isdefined( player.pers["team"] ) && (player.pers["team"] == team ) )
		{
			player thread set_music_on_player ( state, save_state, return_state, wait_time );
		}
	}
}
function set_music_on_player( state, save_state, return_state, wait_time )
{
	//self is player
	self endon( "disconnect" );
	
	if( SessionModeIsZombiesGame() )
		return;
	
	assert( isplayer (self) );
	
	if ( !isdefined( save_state ) )	
	{
		save_state = false;
	}
	if ( !isdefined( return_state ) )	
	{
		return_state = false;
	}	
	if ( !isdefined( wait_time ) )	
	{
		wait_time = 0;
	}	
		if ( !isdefined( state ) )	
	{
		state = "UNDERSCORE";
	}	
	music::setmusicstate( state, self );
	
	if ( isdefined ( self.pers["music"].currentState ) && save_state  )
	{
		//If we want to save the sate we set return state to current state 
		self.pers["music"].returnState = state; 			
	}
	
	// Set previous state to the current active state
	self.pers["music"].previousState = self.pers["music"].currentState;
	
	self.pers["music"].currentState = state;
	if ( isdefined ( self.pers["music"].returnState ) && return_state )
	{
		self set_next_music_state ( self.pers["music"].returnState, wait_time);
	}
		
}
function return_music_state_player( wait_time )
{
	if ( !isdefined( wait_time ) )	
	{
		wait_time = 0;
	}	
	
	self set_next_music_state ( self.pers["music"].returnState, wait_time);
}
function return_music_state_team( team, wait_time )
{
	if ( !isdefined( wait_time ) )	
	{
		wait_time = 0;
	}	
	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if ( team == "both" )
		{
			// if no team is set or team is set to "both" set same state for all players
			player thread set_next_music_state ( self.pers["music"].returnState, wait_time);
		}	
		else if ( isdefined( player.pers["team"] ) && (player.pers["team"] == team ) )
		{
			player thread set_next_music_state ( self.pers["music"].returnState, wait_time);
		}
	}	

}		
function set_next_music_state ( nextstate, wait_time )
{
	// self is player
	// set next state to latest in the que
	
	self endon( "disconnect" );
	
	self.pers["music"].nextstate = nextstate;	
	if ( !isdefined( self.pers["music"].inque ) )	
	{
		// ensure that false is default
		self.pers["music"].inque = false;
	}	
	if ( self.pers["music"].inque )
	{
		// if we have a que waiting and another happens we do not change states yet
		return;
		//Debug Print CDC

	}
	else
	{			
		// set que to true while we wait
		self.pers["music"].inque = true;	
		
		// wait time from state call default is 0
		if ( wait_time )
		{
			wait wait_time;
		}
		// Set the most current music state 
		self set_music_on_player ( self.pers["music"].nextstate, false );
		
		// remove the que return
		self.pers["music"].inque = false;	
	}
}
function getRoundSwitchDialog( switchType )
{
	switch( switchType )
	{
		case "halftime":
			return "halftime";
		case "overtime":
			return "overtime";
		default:
			return "side_switch";
	}
}
//Eckert - does a 2 stage sound fade out during and after AAR
function post_match_snapshot_watcher()
{
	level waittill ( "game_ended" );	
	level util::clientNotify( "pm" );
	level waittill ( "sfade" );
	level util::clientNotify( "pmf" );
}
