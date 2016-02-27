//================================================================
// SprayPaint.SprayPaintActor
// ----------------
// ...
// ----------------
// by Chatouille
//================================================================
class SprayPaintActor extends Actor;

CONST TAG_THICKNESS = 50.0;

var sTagDef TagDef;
var bool bTerrain;

Replication
{
	if ( bNetInitial )
		TagDef, bTerrain;
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( WorldInfo.NetMode != NM_DedicatedServer )
		SetTimer(0.01, false, 'PostNetBeginPlay');
}

simulated function PostNetBeginPlay()
{
	SpawnDecal();
}

simulated function SpawnDecal()
{
	local MaterialInstanceTimeVarying MITV_Decal;

	// Mostly copy from CRZProjectile
	if ( MaterialInstanceTimeVarying(TagDef.LoadedMat) != None )
	{
		if ( bTerrain )
		{
			MITV_Decal = new(Self) class'MaterialInstanceTimeVarying';
			MITV_Decal.SetParent(TagDef.LoadedMat);
			WorldInfo.MyDecalManager.SpawnDecal(MITV_Decal, Location, Rotation, TagDef.Width, TagDef.Height, TAG_THICKNESS, false,,,,,,,, TagDef.Duration);
			MITV_Decal.SetScalarStartTime(TagDef.DissolveParam, TagDef.Duration);
		}
	}
	else
		WorldInfo.MyDecalManager.SpawnDecal(TagDef.LoadedMat, Location, Rotation, TagDef.Width, TagDef.Height, TAG_THICKNESS, true,,,,,,,, TagDef.Duration);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
	bNetTemporary=true
	LifeSpan=1.0
	NetPriority=1.0
	bHidden=true
	CollisionType=COLLIDE_CustomDefault
}
