#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\vehicle_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\mp\killstreaks\_killstreaks.gsh;


#using_animtree ( "mp_emp_power_core" );

#precache( "client_fx", "killstreaks/fx_emp_core" );

#namespace emp;


#define EMP_UPDATE_DISTANCE_DELAY			0.1
#define EMP_UPDATE_DISTANCE_NO_EMP_DELAY	0.7

	
REGISTER_SYSTEM( "emp", &__init__, undefined )	

function __init__()
{
	clientfield::register( "scriptmover", "emp_turret_init", VERSION_SHIP, 1, "int", &emp_turret_init, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "vehicle", "emp_turret_deploy", VERSION_SHIP, 1, "int", &emp_turret_deploy_start, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	
	thread monitor_emp_killstreaks();
}

function monitor_emp_killstreaks()
{
	level endon( "disconnect" );
	
	if ( !isdefined( level.emp_killstreaks ) )
		level.emp_killstreaks = [];

	for(;;)
	{
		has_at_least_one_active_enemy_turret = false;
		ArrayRemoveValue( level.emp_killstreaks, undefined );
		local_players = GetLocalPlayers();
		
		foreach( local_player in local_players )
		{
			if ( local_player IsLocalPlayer() == false )
				continue; // Note: a player joining a game is not a local player until after spawning in (is this a bug?)

			closest_enemy_emp = emp::get_closest_enemy_emp_killstreak( local_player );
			
			if ( isdefined( closest_enemy_emp ) )
			{
				has_at_least_one_active_enemy_turret = true;
				
				localClientNum = local_player GetLocalClientNumber();
				update_distance_to_closest_emp( localClientNum, Distance( local_player.origin, closest_enemy_emp.origin ) );
			}
		}

		wait ( has_at_least_one_active_enemy_turret ? EMP_UPDATE_DISTANCE_DELAY : EMP_UPDATE_DISTANCE_NO_EMP_DELAY );
	}
}

function get_closest_enemy_emp_killstreak( local_player )
{	
	closest_emp = undefined;
	closest_emp_distance_squared = 99999999;

	foreach( emp in level.emp_killstreaks )
	{
		if ( emp.owner == local_player || emp.team == local_player.team )
			continue;

		distance_squared = DistanceSquared( local_player.origin, emp.origin );
		if ( distance_squared < closest_emp_distance_squared )
		{
			closest_emp = emp;
			closest_emp_distance_squared = distance_squared;
		}
	}
	
	return closest_emp;
}

function update_distance_to_closest_emp( localClientNum, new_value )
{
	if ( !isdefined( localClientNum ) )
		return;
		
	distance_to_closest_enemy_emp_ui_model = GetUIModel( GetUIModelForController( localClientNum ), "distanceToClosestEnemyEmpKillstreak" );

	if ( isdefined( distance_to_closest_enemy_emp_ui_model ) )
		SetUIModelValue( distance_to_closest_enemy_emp_ui_model, new_value );
	
	// /# IPrintLnBold( "Distance to Closest Enemy EMP: " + new_value ); #/
}

function emp_turret_init( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	self endon("entityshutdown");

	if ( !newVal )
		return;
	
	self UseAnimTree( #animtree );
	self SetAnimRestart( %o_turret_emp_core_deploy, 1.0, 0.0, 0.0 );
	self SetAnimTime( %o_turret_emp_core_deploy, 0.0 );
}

function cleanup_fx_on_shutdown( localClientNum, handle )
{
	self endon("kill_fx_cleanup");
	self waittill( "entityshutdown" );
	StopFx( localClientNum, handle );
}

function emp_turret_deploy_start( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	self endon("entityshutdown");

	self util::waittill_dobj( localClientNum );
	
	if ( !isdefined(self) )
		return;

	if ( newVal )
	{
		self thread emp_turret_deploy(localClientNum);
	}
	else
	{
		self notify("kill_fx_cleanup");
		if ( isdefined( self.fxHandle ) )
		{
				StopFx( localClientNum, self.fxHandle );
				self.fxHandle = undefined;
		}
	}
}

function emp_turret_deploy( localClientNum )
{
	self endon("entityshutdown");

	self UseAnimTree( #animtree );
	self SetAnimRestart( %o_turret_emp_core_deploy, 1.0, 0.0, 1.0 );
	length = GetAnimLength( %o_turret_emp_core_deploy );
	wait length * 0.75; 
	
	self UseAnimTree( #animtree );
	self SetAnim( %o_turret_emp_core_spin, 1.0 );
	self.fxHandle = PlayFxOnTag( localClientNum, "killstreaks/fx_emp_core", self, EMP_FX_TAG );
	
	self thread cleanup_fx_on_shutdown( localClientNum, self.fxHandle );
	
	wait length * 0.25;
	self SetAnim( %o_turret_emp_core_deploy, 0.0 ); // stop deploy anim
}