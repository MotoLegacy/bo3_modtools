#using scripts\shared\ai_shared;
#using scripts\shared\math_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\ai\archetype_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\ai\phalanx.gsh;
#insert scripts\shared\archetype_shared\archetype_shared.gsh;

#namespace Phalanx;

function private _AssignPhalanxStance( sentients, stance )
{
	assert( IsArray( sentients ) );
	
	foreach ( index, sentient in sentients )
	{
		if ( IsDefined( sentient) && IsAlive( sentient ) )
		{
			sentient ai::set_behavior_attribute( "phalanx_force_stance", stance );
		}
	}
}

function private _CreatePhalanxTier(
	phalanxType, tier, phalanxPosition, forward, maxTierSize, spawner = undefined )
{
	sentients = [];

	if ( !IsSpawner( spawner ) )
	{
		spawner = _GetPhalanxSpawner( tier );
	}
	
	positions = _GetPhalanxPositions( phalanxType, tier );
	angles = VectorToAngles( forward );

	foreach ( index, position in positions )
	{
		if ( index >= maxTierSize )
		{
			break;
		}
	
		orientedPos = _RotateVec( position, angles[1] - PHALANX_ROTATION_OFFSET );
	
		navMeshPosition = GetClosestPointOnNavMesh(
			phalanxPosition + orientedPos, PHALANX_NAVMESH_TOLERANCE );

		// Make sure the spawner can actually spawn a sentient.
		if ( !( spawner.spawnflags & SPAWNFLAG_ACTOR_SCRIPTINFINITESPAWN ) )
		{
			spawner.count++;
		}

		sentient = spawner spawner::spawn( true, "", navMeshPosition, angles );

		_InitializeSentient( sentient );
		
		// Wait till all sentients have been created.
		WAIT_SERVER_FRAME;
		
		sentients[ sentients.size ] = sentient;
	}
	
	return sentients;
}

// Caps the maximum damage the phalanx takes from a single explosive entity.
function private _DampenExplosiveDamage(
	inflictor, attacker, damage, flags, meansOfDamage, weapon, point, dir, hitLoc, offsetTime, boneIndex, modelIndex )
{
	entity = self;

	isExplosive = IsInArray(
		array(
			"MOD_GRENADE",
			"MOD_GRENADE_SPLASH",
			"MOD_PROJECTILE",
			"MOD_PROJECTILE_SPLASH",
			"MOD_EXPLOSIVE" ),
		meansOfDamage );
		
	if ( isExplosive && IsDefined( inflictor ) && IsDefined( inflictor.weapon ) )
	{
		weapon = inflictor.weapon;
		
		distanceToEntity = Distance( entity.origin, inflictor.origin );
	
		// Linear falloff from grenade distance.
		fractionDistance = 1;
		
		if ( weapon.explosionradius > 0 )
		{
			fractionDistance = ( weapon.explosionradius - distanceToEntity ) / weapon.explosionradius;
		}
		
		// This causes near exponential damage falloff since the original damage already considers radius at a near linear falloff.
		return Int( Max( damage * fractionDistance, 1 ) );
	}
	
	return damage;
}

function private _GetPhalanxPositions( phalanxType, tier )
{
	switch ( phalanxType )
	{
		case PHALANX_WEDGE:
			switch( tier )
			{
				case PHALANX_TIER_ONE:
					return PHALANX_WEDGE_TIER_ONE;
				case PHALANX_TIER_TWO:
					return PHALANX_WEDGE_TIER_TWO;
				case PHALANX_TIER_THREE:
					return PHALANX_WEDGE_TIER_THREE;
			}
			break;
		case PHALANX_REVERSE_WEDGE:
			switch( tier )
			{
				case PHALANX_TIER_ONE:
					return PHALANX_REVERSE_WEDGE_TIER_ONE;
				case PHALANX_TIER_TWO:
					return PHALANX_REVERSE_WEDGE_TIER_TWO;
				case PHALANX_TIER_THREE:
					return PHALANX_REVERSE_WEDGE_TIER_THREE;
			}
			break;
		case PHALANX_DIAGONAL_LEFT:
			switch( tier )
			{
				case PHALANX_TIER_ONE:
					return PHALANX_DIAGONAL_LEFT_TIER_ONE;
				case PHALANX_TIER_TWO:
					return PHALANX_DIAGONAL_LEFT_TIER_TWO;
				case PHALANX_TIER_THREE:
					return PHALANX_DIAGONAL_LEFT_TIER_THREE;
			}
			break;
		case PHALANX_DIAGONAL_RIGHT:
			switch( tier )
			{
				case PHALANX_TIER_ONE:
					return PHALANX_DIAGONAL_RIGHT_TIER_ONE;
				case PHALANX_TIER_TWO:
					return PHALANX_DIAGONAL_RIGHT_TIER_TWO;
				case PHALANX_TIER_THREE:
					return PHALANX_DIAGONAL_RIGHT_TIER_THREE;
			}
			break;
		case PHALANX_FORWARD:
			switch( tier )
			{
				case PHALANX_TIER_ONE:
					return PHALANX_FORWARD_TIER_ONE;
				case PHALANX_TIER_TWO:
					return PHALANX_FORWARD_TIER_TWO;
				case PHALANX_TIER_THREE:
					return PHALANX_FORWARD_TIER_THREE;
			}
			break;
		case PHALANX_COLUMN:
			switch( tier )
			{
				case PHALANX_TIER_ONE:
					return PHALANX_COLUMN_TIER_ONE;
				case PHALANX_TIER_TWO:
					return PHALANX_COLUMN_TIER_TWO;
				case PHALANX_TIER_THREE:
					return PHALANX_COLUMN_TIER_THREE;
			}
			break;
		case PHALANX_COLUMN_RIGHT:
			switch( tier )
			{
				case PHALANX_TIER_ONE:
					return PHALANX_COLUMN_RIGHT_TIER_ONE;
				case PHALANX_TIER_TWO:
					return PHALANX_COLUMN_RIGHT_TIER_TWO;
				case PHALANX_TIER_THREE:
					return PHALANX_COLUMN_RIGHT_TIER_THREE;
			}
			break;
		default:
			assert( "Unknown phalanx type \"" + phalanxType + "\"." );
	}
	
	assert( "Unknown phalanx tier \"" + tier + "\"." );
}

function private _GetPhalanxSpawner( tier )
{
	spawner = GetSpawnerArray( tier, "targetname" );
	
	assert( spawner.size >= 0,
		"No spawners for the phalanx system were found, make sure you include " +
		"the \"game/map_source/_prefabs/ai/robot_phalanx.map\" prefab within your " +
		"map to use the system." );
	assert( spawner.size == 1,
		"Too many spawners for the phalanx system were found, make sure you " +
		"don't include multiple copies of the " +
		"\"game/map_source/_prefabs/ai/robot_phalanx.map\" prefab in your map." );
	
	return spawner[0];
}

function private _HaltAdvance( sentients )
{
	assert( IsArray( sentients ) );
	
	foreach ( index, sentient in sentients )
	{
		if ( IsDefined( sentient ) && IsAlive( sentient ) && sentient HasPath() )
		{
			navMeshPosition = GetClosestPointOnNavMesh(
				sentient.origin, PHALANX_NAVMESH_TOLERANCE );
				
			sentient UsePosition( navMeshPosition );
			sentient ClearPath();
		}
	}
}

function private _HaltFire( sentients )
{
	assert( IsArray( sentients ) );
	
	foreach ( index, sentient in sentients )
	{
		if ( IsDefined( sentient ) && IsAlive( sentient ) )
		{
			sentient.ignoreall = true;
		}
	}
}

function _InitializeSentient( sentient )
{
	assert( IsActor( sentient ) );

	sentient ai::set_behavior_attribute( "phalanx", true );
	if ( sentient.archetype === "human" )
	{
		sentient.allowPain = false;
	}
	sentient SetAvoidanceMask( "avoid none" );
	
	if ( IS_ROBOT( sentient ) )
	{
		sentient ai::set_behavior_attribute( "move_mode", "marching" );
		sentient ai::set_behavior_attribute( "force_cover", true );
	}
	
	AiUtility::AddAIOverrideDamageCallback( sentient, &_DampenExplosiveDamage, true );
}

function private _MovePhalanxTier( sentients, phalanxType, tier, destination, forward )
{
	positions = _GetPhalanxPositions( phalanxType, tier );
	angles = VectorToAngles( forward );
	
	assert( sentients.size <= positions.size,
		"There must be enough positions for the phalanx tier to move to." );
	
	foreach ( index, sentient in sentients )
	{
		if ( IsDefined( sentient ) && IsAlive( sentient ) )
		{
			assert( IsVec( positions[ index ] ),
				"Must have a formation position for position(" + index + ") in tier " +
				tier + " of formation " + phalanxType );
			
			orientedPos = _RotateVec( positions[ index ], angles[1] - PHALANX_ROTATION_OFFSET );
		
			navMeshPosition = GetClosestPointOnNavMesh(
				destination + orientedPos, PHALANX_NAVMESH_TOLERANCE );
				
			sentient UsePosition( navMeshPosition );
		}
	}
}

function private _PruneDead( sentients )
{
	liveSentients = [];
	
	// Removes dead sentients and keeps living ones with the same array index.
	foreach ( index, sentient in sentients )
	{
		if ( IsDefined( sentient ) && IsAlive( sentient ) )
		{
			liveSentients[ index ] = sentient;
		}
	}
	
	return liveSentients;
}

function private _ReleaseSentient( sentient )
{
	if ( IsDefined( sentient ) && IsAlive( sentient ) )
	{
		sentient ClearUsePosition();
		sentient PathMode( "move delayed", true, RandomFloatRange( 0.5, 1 ) );
	
		sentient ai::set_behavior_attribute( "phalanx", false );
		
		// Wait a frame to make sure sentients's are released from the phalanx.
		WAIT_SERVER_FRAME;
		
		if ( sentient.archetype === "human" )
		{
			sentient.allowPain = true;
		}
		sentient SetAvoidanceMask( "avoid all" );
		
		AiUtility::RemoveAIOverrideDamageCallback( sentient, &_DampenExplosiveDamage );
		
		if ( IS_ROBOT( sentient ) )
		{
			sentient ai::set_behavior_attribute( "move_mode", "normal" );
			sentient ai::set_behavior_attribute( "force_cover", false );
		}
	}
}

function private _ReleaseSentients( sentients )
{
	foreach ( index, sentient in sentients )
	{
		_ResumeFire( sentient );
		_ReleaseSentient( sentient );
		
		// Release sentients slowly from their group.
		wait RandomFloatRange( 0.5, 5 );
	}
}

function private _ResumeFire( sentient )
{
	if ( IsDefined( sentient ) && IsAlive( sentient ) )
	{
		sentient.ignoreall = false;
	}
}

function private _ResumeFireSentients( sentients )
{
	assert( IsArray( sentients ) );
	
	foreach ( index, sentient in sentients )
	{
		_ResumeFire( sentient );
	}
}

function private _RotateVec( vector, angle )
{
	return ( vector[0] * Cos( angle ) - vector[1] * Sin( angle ),
		vector[0] * Sin( angle ) + vector[1] * Cos( angle ),
		vector[2] );
}

function private _UpdatePhalanxThread( phalanx )
{
	while ( [[ phalanx ]]->_UpdatePhalanx() )
	{
		wait PHALANX_UPDATE_RATE_SEC;
	}
}

class Phalanx
{
	// All tiers of sentients.
	var sentientTiers_;
	
	// Total starting sentients in the formation.
	var startSentientCount_;
	// Current count of all sentients in the formation.
	var currentSentientCount_;
	
	// Number of sentients that must die for the formation to scatter.
	var breakingPoint_;
	
	// Phalanx move positions
	var startPosition_;
	var endPosition_;
	
	// Phalanx type
	var phalanxType_;
	
	// Mark whether the formation has already been scattered.
	var scattered_;

	constructor()
	{
		sentientTiers_ = [];
		
		startSentientCount_ = 0;
		currentSentientCount_ = 0;
		breakingPoint_ = 0;
		
		scattered_ = false;
	}
	
	destructor()
	{
	}
	
	function private _UpdatePhalanx()
	{
		if ( scattered_ )
		{
			// Terminate the phalanx if someone else has already scattered the formation.
			return false;
		}
	
		currentSentientCount_ = 0;
	
		// Discard dead sentients from the phalanx.
		foreach ( name, tier in sentientTiers_ )
		{
			sentientTiers_[ name ] = Phalanx::_PruneDead( tier );
			
			currentSentientCount_ += sentientTiers_[ name ].size;
		}
		
		// Break up the phalanx if enough sentients died.
		if ( currentSentientCount_ <= ( startSentientCount_ - breakingPoint_ ) )
		{
			ScatterPhalanx();
			
			return false;
		}
		
		return true;
	}
	
	function HaltFire()
	{
		foreach ( name, tier in sentientTiers_ )
		{
			Phalanx::_HaltFire( tier );
		}
	}
	
	function HaltAdvance()
	{
		if ( !scattered_ )
		{
			foreach ( name, tier in sentientTiers_ )
			{
				Phalanx::_HaltAdvance( tier );
			}
		}
	}
	
	function Initialize(
		phalanxType,
		origin,
		destination,
		breakingPoint,
		maxTierSize = PHALANX_MAX_TIER_SIZE,
		tierOneSpawner = undefined,
		tierTwoSpawner = undefined,
		tierThreeSpawner = undefined )
	{
		assert( IsString( phalanxType ) );
		assert( IsInt( breakingPoint ) );
		assert( IsVec( origin ) );
		assert( IsVec( destination ) );
		
		tierSpawners = [];
		tierSpawners[ PHALANX_TIER_ONE ] = tierOneSpawner;
		tierSpawners[ PHALANX_TIER_TWO ] = tierTwoSpawner;
		tierSpawners[ PHALANX_TIER_THREE ] = tierThreeSpawner;
		
		maxTierSize = math::clamp( maxTierSize, PHALANX_MIN_TIER_SIZE, PHALANX_MAX_TIER_SIZE );
		
		forward = VectorNormalize( destination - origin );
	
		foreach ( tierName in PHALANX_TIERS )
		{
			sentientTiers_[ tierName ] = Phalanx::_CreatePhalanxTier(
				phalanxType, tierName, origin, forward, maxTierSize, tierSpawners[ tierName ] );
			
			startSentientCount_ += sentientTiers_[ tierName ].size;
		}

		// The first tier facing the enemy always crouches.
		Phalanx::_AssignPhalanxStance( sentientTiers_[ PHALANX_TIER_ONE ], "crouch" );
		
		// Assign phalanx positions to all sentient tiers.
		foreach ( name, tier in sentientTiers_ )
		{
			Phalanx::_MovePhalanxTier(
				sentientTiers_[ name ], phalanxType, name, destination, forward );
		}

		breakingPoint_ = breakingPoint;
		startPosition_ = origin;
		endPosition_ = destination;
		phalanxType_ = phalanxType;
		
		// Initiate the main update loop, a single thread that updates the phalanx.
		self thread Phalanx::_UpdatePhalanxThread( self );
	}
	
	function ResumeAdvance()
	{
		if ( !scattered_ )
		{
			Phalanx::_AssignPhalanxStance( sentientTiers_[ PHALANX_TIER_ONE ], "stand" );
			
			// TODO(David Young 10-21-14): Too hardcoded, waiting for animation to complete.
			wait 1;
		
			forward = VectorNormalize( endPosition_ - startPosition_ );
			
			Phalanx::_MovePhalanxTier(
				sentientTiers_[ PHALANX_TIER_ONE ], phalanxType_, PHALANX_TIER_ONE, endPosition_, forward );
			Phalanx::_MovePhalanxTier(
				sentientTiers_[ PHALANX_TIER_TWO ], phalanxType_, PHALANX_TIER_TWO, endPosition_, forward );
			Phalanx::_MovePhalanxTier(
				sentientTiers_[ PHALANX_TIER_THREE ], phalanxType_, PHALANX_TIER_THREE, endPosition_, forward );
				
			Phalanx::_AssignPhalanxStance( sentientTiers_[ PHALANX_TIER_ONE ], "crouch" );
		}
	}
	
	function ResumeFire()
	{
		Phalanx::_ResumeFireSentients( sentientTiers_[ PHALANX_TIER_ONE ] );
		Phalanx::_ResumeFireSentients( sentientTiers_[ PHALANX_TIER_TWO ] );
		Phalanx::_ResumeFireSentients( sentientTiers_[ PHALANX_TIER_THREE ] );
	}
	
	function ScatterPhalanx()
	{
		if ( !scattered_ )
		{
			scattered_ = true;
			
			Phalanx::_ReleaseSentients( sentientTiers_[ PHALANX_TIER_ONE ] );
			sentientTiers_[ PHALANX_TIER_ONE ] = [];
			
			Phalanx::_AssignPhalanxStance( sentientTiers_[ PHALANX_TIER_TWO ], "crouch" );
			
			// Settling time for the tier.
			wait RandomFloatRange( 5, 7 );
			
			Phalanx::_ReleaseSentients( sentientTiers_[ PHALANX_TIER_TWO ] );
			sentientTiers_[ PHALANX_TIER_TWO ] = [];
			
			Phalanx::_AssignPhalanxStance( sentientTiers_[ PHALANX_TIER_THREE ], "crouch" );
			
			// Settling time for the tier.
			wait RandomFloatRange( 5, 7 );
			
			Phalanx::_ReleaseSentients( sentientTiers_[ PHALANX_TIER_THREE ] );
			sentientTiers_[ PHALANX_TIER_THREE ] = [];
		}
	}
}