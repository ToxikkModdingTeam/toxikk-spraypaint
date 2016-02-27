//================================================================
// SprayPaint.MutSprayPaint
// ----------------
// ...
// ----------------
// by Chatouille
//================================================================
class MutSprayPaint extends CRZMutator
	Config(SprayPaint);

CONST TAG_DIST = 150;

struct sTagDef {
	var String Mat;
	var float Width;
	var float Height;

	var Name DissolveParam;

	// instance params
	var MaterialInterface LoadedMat;
	var float Duration;

	structdefaultproperties
	{
		Width=128.0
		Height=128.0
		DissolveParam=DissolveAmount
	}
};
var config array<sTagDef> TagDefs;

var config float TagDuration;
var config float TagDelay;

var array<sTagDef> LoadedTags;


function PostBeginPlay()
{
	local int i;
	local MaterialInterface Mat;

	Super.PostBeginPlay();

	// generate test config
	if ( TagDefs.Length == 0 )
	{
		TagDefs.Length = 1;
		TagDefs[0].Mat = "RocketLauncher.Decals.MITV_WP_RocketLauncher_Impact_Decal";
		TagDuration = 120.0;
		TagDelay = 1.0;
		SaveConfig();
	}

	for ( i=0; i<TagDefs.Length; i++ )
	{
		Mat = MaterialInterface(DynamicLoadObject(TagDefs[i].Mat, class'MaterialInterface', true));
		if ( Mat != None )
		{
			LoadedTags.AddItem(TagDefs[i]);
			LoadedTags[LoadedTags.Length-1].LoadedMat = Mat;
			LoadedTags[LoadedTags.Length-1].Duration = TagDuration;
		}
		else
			`Log("[SprayPaint] Failed to load Material '" $ TagDefs[i].Mat $ "' - skipping");
	}
}


function Mutate(String Cmd, PlayerController PC)
{
	local int pick;

	if ( Cmd ~= "tag" && PC.Pawn != None )
	{
		pick = Rand(LoadedTags.Length);
		DoSprayPaint(PC, LoadedTags[pick]);
	}
}


function DoSprayPaint(PlayerController PC, sTagDef TagDef)
{
	local Vector Src, HitLocation, HitNormal;
	local Rotator Rot;
	local Actor HitActor;
	local SprayPaintActor TagActor;

	if ( PC.IsTimerActive('DummyFunction') )
		return;

	PC.GetActorEyesViewPoint(Src, Rot);
	HitActor = PC.Pawn.Trace(HitLocation, HitNormal, Src + TAG_DIST * Vector(Rot), Src, true);
	if ( HitActor == None || !HitActor.bWorldGeometry )
		return;

	TagActor = Spawn(class'SprayPaintActor',,, HitLocation, rotator(-HitNormal));
	TagActor.TagDef = TagDef;
	TagActor.bTerrain = (Terrain(HitActor) != None);

	// paint sound
	PC.Pawn.PlaySound(UTPawn(PC.Pawn).TeleportSound);

	PC.SetTimer(TagDelay, false, 'DummyFunction');  // this generates a warning log, so use an actual function
}


defaultproperties
{
}
