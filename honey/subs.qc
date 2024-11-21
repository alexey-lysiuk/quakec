

void() SUB_Null = {};

void() SUB_Remove = {remove(self);};


/*
QuakeEd only writes a single float for angles (bad idea), so up and down are
just constant angles.
*/
void() SetMovedir =
{
	if (self.angles == '0 -1 0')
		self.movedir = '0 0 1';
	else if (self.angles == '0 -2 0')
		self.movedir = '0 0 -1';
	else
	{
		makevectors (self.angles);
		self.movedir = v_forward;
	}
	
	self.angles = '0 0 0';
}

/*
================
InitTrigger
================
*/
void() InitTrigger =
{
// trigger angles are used for one-way touches.  An angle of 0 is assumed
// to mean no restrictions, so use a yaw of 360 instead.
	if (self.angles != '0 0 0')
		SetMovedir ();
	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);	// set size and link into world
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
}

/*
=============
SUB_CalcMove

calculate self.velocity and self.nextthink to reach dest from
self.origin traveling at speed
===============
*/
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt =
{
local entity	stemp;
	stemp = self;
	self = ent;

	SUB_CalcMove (tdest, tspeed, func);
	self = stemp;
}

void(vector tdest, float tspeed, void() func) SUB_CalcMove =
{
local vector	vdestdelta;
local float		len, traveltime;

	if (!tspeed)
		objerror("No speed is defined!");

	self.think1 = func;
	self.finaldest = tdest;
	self.think = SUB_CalcMoveDone;

	if (tdest == self.origin)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}
		
// set destdelta to the vector needed to move
	vdestdelta = tdest - self.origin;
	
// calculate length of vector
	len = vlen (vdestdelta);
	
// divide by speed to get time to reach dest
	traveltime = len / tspeed;

	if (traveltime < 0.1)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}
	
	// set nextthink to trigger a think when dest is reached
//	if(self.movetype == MOVETYPE_PUSH)
		self.nextthink = self.ltime + traveltime;
//	else
//		self.nextthink = time + traveltime;

// scale the destdelta vector by the time spent traveling to get velocity
	self.velocity = vdestdelta * (1/traveltime);	// qcc won't take vec/float	
}

void(vector tdest, float traveltime, void() func) SUB_CalcMove_time =
{
local vector	vdestdelta;
local float		len;

	if (!traveltime)
		objerror("No time is defined!");

	self.think1 = func;
	self.finaldest = tdest;
	self.think = SUB_CalcMoveDone;

	if (tdest == self.origin)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + traveltime;
		return;
	}
		
// set destdelta to the vector needed to move
	vdestdelta = tdest - self.origin;
	
	// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;

// scale the destdelta vector by the time spent traveling to get velocity
	self.velocity = vdestdelta * (1/traveltime);	// qcc won't take vec/float	
}

/*
============
After moving, set origin to exact final destination
============
*/
void()  SUB_CalcMoveDone =
{
	setorigin(self, self.finaldest);
	self.velocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1)
		self.think1();
}


/*
=============
SUB_CalcAngleMove

calculate self.avelocity and self.nextthink to reach destangle from
self.angles rotating 

The calling function should make sure self.think is valid
===============
*/
void(entity ent, vector destangle, float tspeed, void() func) SUB_CalcAngleMoveEnt =
{
local entity		stemp;
	stemp = self;
	self = ent;
	SUB_CalcAngleMove (destangle, tspeed, func);
	self = stemp;
}

void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove =
{
local vector	destdelta;
local float		len, traveltime;

	if (!tspeed)
		objerror("No speed is defined!");
		
// set destdelta to the vector needed to move
	destdelta = destangle - self.angles;
	
// calculate length of vector
	len = vlen (destdelta);
	
// divide by speed to get time to reach dest
	traveltime = len / tspeed;

// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;

// scale the destdelta vector by the time spent traveling to get velocity
	self.avelocity = destdelta * (1 / traveltime);
	
	self.think1 = func;
	self.finalangle = destangle;
	self.think = SUB_CalcAngleMoveDone;
}

/*
============
After rotating, set angle to exact final angle
============
*/
void() SUB_CalcAngleMoveDone =
{
	self.angles = self.finalangle;
	self.avelocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1)
		self.think1();
}


//=============================================================================

.entity delayedThink;
void() DelayThink =
{
	activator = self.enemy;
	SUB_UseTargets ();
	self.owner.delayedThink = world;
	remove(self);
}

/*
==============================
SUB_UseTargets

the global "activator" should be set to the entity that initiated the firing.

If self.delay is set, a DelayedUse entity will be created that will actually
do the SUB_UseTargets after that many seconds have passed.

Centerprints any self.message to the activator.

Removes all entities with a targetname that match self.killtarget,
and removes them, so some events can remove other triggers.

Search for (string)targetname in all entities that
match (string)self.target and call their .use function

==============================
*/

void(entity but) button_disable;
void(entity targ, entity attacker) Killed;

void() SUB_UseTargets =
{
	local entity t, stemp, otemp, act;

//
// check for a delay
//
	if (self.delay)
	{
	// create a temp object to fire at a later time
		t = spawn();
		t.classname = "DelayedUse";
		t.nextthink = time + self.delay;
		t.think = DelayThink;
		t.enemy = activator;
		t.message = self.message;
		t.killtarget = self.killtarget;
		t.target = self.target;
		t.owner = self;
		self.delayedThink = t;
		return;
	}
	
	
//
// print the message
//
	if (activator.classname == "player" && self.message != "")
	{
		centerprint (activator, self.message);
		if (!self.noise)
			sound (activator, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
//		else
//			sound (activator, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	}

//
// kill the killtargets
//
	if (self.killtarget)
	{
		t = find (world, targetname, self.killtarget);
		while(t)
		{
			if(t.delayedThink) remove(t.delayedThink);
			if(t.classname == "func_button"){
				if(t.spawnflags & 1){ //Disableable button spawnflag
					button_disable(t);
				}else{
					remove(t);
				}
			}else if(t.classname == "func_door_secret"){
				//Honey hack to stop a secret door killed mid-move to play its noise endlessly
				//dprint("killed func_door_secret\n");
				if(t.velocity != '0 0 0')
					sound(t, CHAN_VOICE, t.noise3, 1, ATTN_NORM);
				remove(t);
			}else if(t.flags & FL_MONSTER && t.health > 0){
				Killed (t, activator);
			}else{
				remove (t);
			}
			t = find (t, targetname, self.killtarget);
		}
	}
	
//
// fire targets
//
	if (self.target)
	{
		act = activator;
		t = world;


		do{
			t = find (t, targetname, self.target);
			if (!t)
			{
				break;
			}
			stemp = self;
			otemp = other;
			self = t;
			other = stemp;
			if (self.use != SUB_Null)
			{
				if (self.use){
					self.use ();
				}
			}
			self = stemp;
			other = otemp;
			activator = act;
		} while ( 1 );
	}
	

}

void(entity e) SUB_Activate =
{
	entity tmp;
	tmp = self;
	self = e;
	SUB_UseTargets();
	self = tmp;
}


void(string t) SUB_Trigger=
{
	local float oldD;
	activator = self;
	self.target = t;
	oldD = self.delay;
	self.delay = 0;
	SUB_UseTargets();
	self.delay = oldD;
}

void(string t, string kt) SUB_KillTrigger=
{
	local float oldD;
	activator = self;
	self.target = t;
	self.killtarget = kt;
	oldD = self.delay;
	self.delay = 0;
	SUB_UseTargets();
	self.delay = oldD;
}

void(string t, float d) SUB_DelayTrigger=
{
	local float oldD;
	activator = self;
	self.target = t;
	oldD = self.delay;
	self.delay = d;
	SUB_UseTargets();
	self.delay = oldD;
}

void(string t, string kt, float d) SUB_DelayKillTrigger=
{
	local float oldD;
	activator = self;
	self.target = t;
	self.killtarget = kt;
	oldD = self.delay;
	self.delay = d;
	SUB_UseTargets();
	self.delay = oldD;
}

void() DelayCenterprint_think=
{
	centerprint (self.enemy, self.message);
	sound (self.enemy, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);	
}

void(entity to, string msg, float dly) SUB_DelayCenterprint=
{
	local entity t;
	if(dly){
		t = spawn();
		t.message = msg;
		t.enemy = to;
		t.think = DelayCenterprint_think;
		t.nextthink = time + dly;
		return;
	}
	centerprint (to, msg);
	sound (to, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);		
}

void(void() t, float d) SUB_DelayCall =
{
	self.think = t;
	self.nextthink = self.ltime + d;
}


/*

in nightmare mode, all attack_finished times become 0
some monsters refire twice automatically

*/

void(float normal) SUB_AttackFinished =
{
	self.cnt = 0;		// refire count for nightmare
	if (skill != 3)
		self.attack_finished = time + normal;
};

float (entity targ) visible;

void (void() thinkst) SUB_CheckRefire =
{
	if (skill != 3)
		return;
	if (self.cnt == 1)
		return;
	if (!visible (self.enemy))
		return;
	self.cnt = 1;
	self.think = thinkst;
}
