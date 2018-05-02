#using scripts\codescripts\struct;

#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\util_shared;

#using scripts\shared\abilities\_ability_player;
#using scripts\shared\abilities\_ability_util;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\abilities\_ability_util.gsh;
	
#using scripts\shared\system_shared;

REGISTER_SYSTEM( "gadget_forced_malfunction", &__init__, undefined )

function __init__()
{
	ability_player::register_gadget_activation_callbacks( GADGET_TYPE_FORCED_MALFUNCTION, &gadget_forced_malfunction_on, &gadget_forced_malfunction_off );
	ability_player::register_gadget_possession_callbacks( GADGET_TYPE_FORCED_MALFUNCTION, &gadget_forced_malfunction_on_give, &gadget_forced_malfunction_on_take );
	ability_player::register_gadget_flicker_callbacks( GADGET_TYPE_FORCED_MALFUNCTION, &gadget_forced_malfunction_on_flicker );
	ability_player::register_gadget_is_inuse_callbacks( GADGET_TYPE_FORCED_MALFUNCTION, &gadget_forced_malfunction_is_inuse );
	ability_player::register_gadget_is_flickering_callbacks( GADGET_TYPE_FORCED_MALFUNCTION, &gadget_forced_malfunction_is_flickering );
	ability_player::register_gadget_primed_callbacks( GADGET_TYPE_FORCED_MALFUNCTION, &gadget_forced_malfunction_is_primed );

	callback::on_connect( &gadget_forced_malfunction_on_connect );
}

function gadget_forced_malfunction_is_inuse( slot )
{
	// returns true when the gadget is on
	return self flagsys::get( "gadget_forced_malfunction_on" );
}

function gadget_forced_malfunction_is_flickering( slot )
{
	// returns true when the gadget is flickering
	if(isDefined(level.cybercom) && isDefined(level.cybercom.forced_malfunction))
	{
		return self [[level.cybercom.forced_malfunction._is_flickering]](slot);
	}
	return false;
}

function gadget_forced_malfunction_on_flicker( slot, weapon )
{
	// excuted when the gadget flickers
	if(isDefined(level.cybercom) && isDefined(level.cybercom.forced_malfunction))
	{
		self [[level.cybercom.forced_malfunction._on_flicker]](slot, weapon);
	}	
}

function gadget_forced_malfunction_on_give( slot, weapon )
{
	// executed when gadget is added to the players inventory
	if(isDefined(level.cybercom) && isDefined(level.cybercom.forced_malfunction))
	{
		self [[level.cybercom.forced_malfunction._on_give]](slot, weapon);
	}	
}

function gadget_forced_malfunction_on_take( slot, weapon )
{
	// executed when gadget is removed from the players inventory
	if(isDefined(level.cybercom) && isDefined(level.cybercom.forced_malfunction))
	{
		self [[level.cybercom.forced_malfunction._on_take]](slot, weapon);
	}	
}

//self is the player
function gadget_forced_malfunction_on_connect()
{
	// setup up stuff on player connect	
	if(isDefined(level.cybercom) && isDefined(level.cybercom.forced_malfunction))
	{
		self [[level.cybercom.forced_malfunction._on_connect]]();
	}	
}

function gadget_forced_malfunction_on( slot, weapon )
{
	// excecutes when the gadget is turned on
	self flagsys::set( "gadget_forced_malfunction_on" );
	if(isDefined(level.cybercom) && isDefined(level.cybercom.forced_malfunction))
	{
		self [[level.cybercom.forced_malfunction._on]](slot, weapon);
	}	
}

function gadget_forced_malfunction_off( slot, weapon )
{
	// excecutes when the gadget is turned off`
	self flagsys::clear( "gadget_forced_malfunction_on" );
	if(isDefined(level.cybercom) && isDefined(level.cybercom.forced_malfunction))
	{
		self [[level.cybercom.forced_malfunction._off]](slot, weapon);
	}	
}

function gadget_forced_malfunction_is_primed( slot, weapon )
{
	// excecutes when the gadget is turned off`
	if(isDefined(level.cybercom) && isDefined(level.cybercom.forced_malfunction))
	{
		self [[level.cybercom.forced_malfunction._is_primed]](slot, weapon);
	}
}