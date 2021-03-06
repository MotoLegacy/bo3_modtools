#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\trigger_shared;
#using scripts\shared\util_shared;
#using scripts\shared\weapons\_weaponobjects;

#insert scripts\shared\shared.gsh;
#using scripts\shared\system_shared;

#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;

#insert scripts\zm\_zm_utility.gsh;

#namespace zm_placeable_mine;

REGISTER_SYSTEM_EX( "placeable_mine", undefined, &__main__, undefined )
	

function private __main__()
{
	if ( isdefined( level.placeable_mines ) )
	{
		level thread replenish_after_rounds();
	}
}

function private init_internal()
{
	if ( isdefined( level.placeable_mines ) )
	{
		return;
	}
	
	level.placeable_mines = [];
	
	level.placeable_mines_on_damage = &placeable_mine_damage;
	level.pickup_placeable_mine = &pickup_placeable_mine;
	level.pickup_placeable_mine_trigger_listener = &pickup_placeable_mine_trigger_listener;
	level.placeable_mine_planted_callbacks = [];
}

function get_first_available()
{
	if ( isdefined( level.placeable_mines ) && level.placeable_mines.size > 0 )
	{
		str_key = GetArrayKeys( level.placeable_mines )[0];
		return level.placeable_mines[str_key];
	}
	
	return level.weaponNone;
}

function add_mine_type( mine_name, str_retrieval_prompt )
{
	// Automatically initialize the placeable mine system when registering your first placeable mine.
	init_internal();
	
	weaponobjects::createRetrievableHint( mine_name, str_retrieval_prompt );
	level.placeable_mines[ mine_name ] = GetWeapon( mine_name );
	level.placeable_mine_planted_callbacks[mine_name] = [];
}

function add_weapon_to_mine_slot( mine_name )
{
	// Automatically initialize the placeable mine system when registering your first placeable mine.
	init_internal();
	
	//weaponobjects::createRetrievableHint( mine_name, str_retrieval_prompt );
	level.placeable_mines[ mine_name ] = GetWeapon( mine_name );
	level.placeable_mine_planted_callbacks[mine_name] = [];
	DEFAULT(level.placeable_mines_in_name_only,[]);
	level.placeable_mines_in_name_only[ mine_name ] = GetWeapon( mine_name );
}

function set_max_per_player( n_max_per_player )
{
	level.placeable_mines_max_per_player = n_max_per_player;
}

function add_planted_callback( fn_planted_cb, wpn_name )
{	
	ARRAY_ADD( level.placeable_mine_planted_callbacks[wpn_name], fn_planted_cb );
}

function private run_planted_callbacks( e_planter )
{
	foreach ( fn in level.placeable_mine_planted_callbacks[self.weapon.name] )
	{
		self thread [[fn]]( e_planter );
	}
}

function private safe_to_plant() 
{
	if ( isdefined( level.placeable_mines_max_per_player ) && self.owner.placeable_mines.size >= level.placeable_mines_max_per_player )
	{
		return false;
	}
	
	return true;
}

function private wait_and_detonate()
{
	wait 0.1;

	self detonate( self.owner );
}

function private mine_watch( wpn_type )
{
	self endon( "death" );
	self notify( "mine_watch" );
	self endon( "mine_watch" );

	while(1)
	{
		self waittill( "grenade_fire", mine, fired_weapon );
		if ( fired_weapon == wpn_type )
		{
			mine.owner = self;
			mine.team = self.team;
			mine.weapon = fired_weapon;

			self notify( "zmb_enable_" + fired_weapon.name + "_prompt" );

			if ( mine safe_to_plant() )
			{
				mine run_planted_callbacks( self );

				//stat tracking
				self zm_stats::increment_client_stat( fired_weapon.name + "_planted" );
				self zm_stats::increment_player_stat( fired_weapon.name + "_planted" );
			}
			else
			{
				mine thread wait_and_detonate();
			}
		}
	}
}

function is_true_placeable_mine( mine_name )
{
	if ( !isdefined(level.placeable_mines_in_name_only ) )
		return true; 
	if ( !isdefined(level.placeable_mines_in_name_only[ mine_name ] ) )
		return true; 
	return false;
}


function setup_for_player( wpn_type, ui_model = "hudItems.showDpadRight" )
{
	if ( !isdefined( self.placeable_mines ) )
	{
		self.placeable_mines = [];
	}
	
	if ( isdefined( self.last_placeable_mine_uimodel ) )
	{
		self clientfield::set_player_uimodel( self.last_placeable_mine_uimodel, 0 );
	}

	if ( is_true_placeable_mine( wpn_type.name ) )
	{
		self thread mine_watch( wpn_type );
	}

	self giveweapon( wpn_type );
	self zm_utility::set_player_placeable_mine( wpn_type );
	self setactionslot( 4, "weapon", wpn_type );
	startammo = wpn_type.startammo;
	if ( startammo )
	{
		self setweaponammostock( wpn_type, startammo );
	}
	
	if ( isdefined( ui_model ) )
	{
		self clientfield::set_player_uimodel( ui_model, 1 );
	}
	self.last_placeable_mine_uimodel = ui_model;
}

function disable_prompt_for_player( wpn_type )
{
	self notify( "zmb_disable_" + wpn_type.name + "_prompt" );
}

function disable_all_prompts_for_player()
{
	foreach( mine in level.placeable_mines )
	{
		self disable_prompt_for_player( mine );
	}
}

function private pickup_placeable_mine()
{
	player = self.owner;
	wpn_type = self.weapon;

	if( IS_DRINKING(player.is_drinking) )
		return;
	
	current_player_mine = player zm_utility::get_player_placeable_mine();
	
	// Holding a different weapon?  Take the old one and give them the new one.
	if ( current_player_mine != wpn_type )
	{
		player TakeWeapon( current_player_mine );
	}
	
	// If they laid them all down, you'll need to give them the weapon back.
	if ( !player HasWeapon( wpn_type ) )
	{
		player thread mine_watch( wpn_type );

		player giveweapon(wpn_type);
		player zm_utility::set_player_placeable_mine(wpn_type);
		player setactionslot(4,"weapon",wpn_type);
		player setweaponammoclip(wpn_type,0);
		player notify( "zmb_enable_" + wpn_type.name + "_prompt" );
	}
	else
	{
		clip_ammo = player GetWeaponAmmoClip( wpn_type );
		clip_max_ammo = wpn_type.clipSize;
		if ( clip_ammo >= clip_max_ammo )
		{
			self zm_utility::destroy_ent();
			player disable_prompt_for_player( wpn_type );
			return;
		}
	}
	
	self zm_utility::pick_up();

	clip_ammo = player GetWeaponAmmoClip( wpn_type );
	clip_max_ammo = wpn_type.clipSize;
	if ( clip_ammo >= clip_max_ammo )
	{
		player disable_prompt_for_player( wpn_type );
	}
	//stat tracking
	player zm_stats::increment_client_stat( wpn_type.name + "_pickedup" );
	player zm_stats::increment_player_stat( wpn_type.name + "_pickedup" );
}

function private pickup_placeable_mine_trigger_listener( trigger, player )
{
	self thread pickup_placeable_mine_trigger_listener_enable( trigger, player );
	self thread pickup_placeable_mine_trigger_listener_disable( trigger, player );
}

function private pickup_placeable_mine_trigger_listener_enable( trigger, player )
{
	self endon( "delete" );
	self endon( "death" );

	while ( true )
	{
		player util::waittill_any( "zmb_enable_" + self.weapon.name + "_prompt", "spawned_player" );
		
		if ( !isDefined( trigger ) )
		{
			return;
		}

		trigger TriggerEnable( true );
		trigger linkto( self );
	}
}

function private pickup_placeable_mine_trigger_listener_disable( trigger, player )
{
	self endon( "delete" );
	self endon( "death" );

	while ( true )
	{
		player waittill( "zmb_disable_" + self.weapon.name + "_prompt" );

		if ( !isDefined( trigger ) )
		{
			return;
		}

		trigger unlink();
		trigger TriggerEnable( false );
	}
}

function private placeable_mine_damage()
{
	self endon( "death" );

	self setcandamage(true);
	self.health = 100000;
	self.maxhealth = self.health;
	
	attacker = undefined;
	
	while(1)
	{
		self waittill("damage", amount, attacker);

		if ( !isdefined( self ) )	// something else killed it
		{
			return;
		}

		self.health = self.maxhealth;
		if ( !isplayer(attacker) )
			continue;

		if ( isdefined( self.owner ) && attacker == self.owner )
			continue;

		if( isDefined( attacker.pers ) && isDefined( attacker.pers["team"] ) && attacker.pers["team"] != level.zombie_team )
			continue;

		break;
	}
	
	if ( level.satchelexplodethisframe )
		wait .1 + randomfloat(.4);
	else
		wait .05;
	
	if (!isdefined(self))
		return;
	
	level.satchelexplodethisframe = true;
	
	thread reset_satchel_explode_this_frame();
	
	self detonate( attacker );
	// won't get here; got death notify.
}

function private reset_satchel_explode_this_frame()
{
	wait .05;
	level.satchelexplodethisframe = false;
}

function private replenish_after_rounds()
{
	while( true )
	{
		level waittill( "between_round_over" );
		
		if ( isdefined( level.func_custom_placeable_mine_round_replenish ) )
	    {
			[[ level.func_custom_placeable_mine_round_replenish ]]();
			continue;
		}
		
		if ( !level flag::exists( "teleporter_used" ) || !level flag::get( "teleporter_used" ) )
		{
			players = GetPlayers();
			for ( i = 0;i < players.size;i++ )
			{
				foreach( mine in level.placeable_mines )
				{
					if ( players[ i ] zm_utility::is_player_placeable_mine( mine ) &&
					     is_true_placeable_mine( mine.name ) )
					{
						players[ i ]  giveweapon( mine );
						players[ i ]  zm_utility::set_player_placeable_mine( mine );
						players[ i ]  setactionslot( 4, "weapon", mine );
						players[ i ]  setweaponammoclip( mine, 2 );
						break;
					}
				}
			}
		}
	}
}

function setup_watchers()		// self == player
{
	if ( isdefined( level.placeable_mines ) )
	{
		foreach( mine_type in level.placeable_mines )
		{
			watcher = self weaponobjects::createUseWeaponObjectWatcher( mine_type.name, self.team );
			watcher.onSpawnRetrieveTriggers = &on_spawn_retrieve_trigger;
			watcher.adjustTriggerOrigin = &adjust_trigger_origin;
			watcher.pickup = level.pickup_placeable_mine;
			watcher.pickup_trigger_listener = level.pickup_placeable_mine_trigger_listener;
			watcher.skip_weapon_object_damage = true;
			watcher.headIcon = false;
			watcher.watchForFire = true;
			watcher.onDetonateCallback = &placeable_mine_detonate;
			watcher.onDamage = level.placeable_mines_on_damage;
		}
	}
}

function private on_spawn_retrieve_trigger( watcher, player )
{
	self weaponobjects::onSpawnRetrievableWeaponObject( watcher, player );  // self == weapon (for example: the mine)
	if (isdefined(self.pickUpTrigger))
		self.pickUpTrigger SetHintLowPriority( false );
}

function private adjust_trigger_origin( origin )
{
	origin = origin + (0,0,20);
	return origin;
}

function private placeable_mine_detonate(attacker, weapon, target )
{
	if ( weapon.isEmp )
	{
		self delete();
		return;
	}
	
	if ( IsDefined( attacker ) )
	{
		self Detonate( attacker );
	}
	else if ( isdefined( self.owner ) && isplayer( self.owner ) )
	{	
		self Detonate( self.owner );
	}
	else
	{
		self Detonate();
	}
}

