#using scripts\codescripts\struct;

#using scripts\shared\callbacks_shared;
#using scripts\shared\math_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;

#using scripts\mp\_util;

#precache( "client_fx", "weapon/fx_equip_light_os" );
#namespace explosive_bolt;

REGISTER_SYSTEM( "explosive_bolt", &__init__, undefined )

function __init__()
{
	level._effect["crossbow_light"] = "weapon/fx_equip_light_os";
	
	callback::add_weapon_type( "explosive_bolt", &spawned );
}

function spawned( localClientNum )
{
	if ( self isGrenadeDud() ) 
		return; 
		
	self thread fx_think( localClientNum );
}

function fx_think( localClientNum )
{
	self notify( "light_disable" );

	self endon( "entityshutdown" );
	self endon( "light_disable" );

	self util::waittill_dobj( localClientNum );

	interval = 0.3;

	for( ;; )
	{
		self stop_light_fx( localClientNum );
		self start_light_fx( localClientNum );
		self fullscreen_fx( localClientNum );
		self PlaySound( localClientNum, "wpn_semtex_alert" );

		util::server_wait( localClientNum, interval, CLIENT_FRAME, "player_switch" );
		interval = math::clamp( ( interval / 1.2 ), 0.08, 0.3 );
	}
}

function start_light_fx( localClientNum )
{
	player = GetLocalPlayer( localClientNum );

	self.fx = PlayFxOnTag( localClientNum, level._effect["crossbow_light"], self, "tag_origin" );
}

function stop_light_fx( localClientNum )
{
	if ( isdefined( self.fx ) && self.fx != 0 )
	{
		StopFx( localClientNum, self.fx );
		self.fx = undefined;
	}
}

function fullscreen_fx( localClientNum )
{
	player = GetLocalPlayer( localClientNum );

	if ( isdefined( player ) )
	{
		if ( player GetInKillcam( localClientNum ) )
		{
			return;
		}
		else if ( player util::is_player_view_linked_to_entity( localClientNum ) )
		{
			return;
		}
	}

	if ( self util::friend_not_foe( localClientNum ) )
	{
		return;
	}

	parent = self GetParentEntity();

	if ( isdefined( parent ) && parent == player )
	{
		parent PlayRumbleOnEntity( localClientNum, "buzz_high" );

		// support for this has been removed with the .menu system
		/*
		if ( IsSplitscreen() )
		{
			AnimateUI( localClientNum, "sticky_grenade_overlay_ss"+localClientNum, "overlay", "pulse", 0 );

			if ( GetDvarint( "ui_hud_hardcore" ) == 0 )
			{
				AnimateUI( localClientNum, "stuck_ss"+localClientNum, "explosive_bolt", "pulse", 0 );
			}
		}
		else
		{
			AnimateUI( localClientNum, "sticky_grenade_overlay"+localClientNum, "overlay", "pulse", 0 );

			if ( GetDvarint( "ui_hud_hardcore" ) == 0 )
			{
				AnimateUI( localClientNum, "stuck"+localClientNum, "explosive_bolt", "pulse", 0 );
			}
		}
		*/
	}
}