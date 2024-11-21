
/*QUAKED info_null (0 0.5 0) (-4 -4 -4) (4 4 4)
Used as a positional target for spotlights, etc.
*/
void() info_null =
{
	remove(self);
};

/*QUAKED info_notnull (0 0.5 0) (-4 -4 -4) (4 4 4)
Used as a positional target for lightning.
*/
void() info_notnull =
{
};

//============================================================================

float START_OFF = 1;
float SWITCH_TO_FLICKER = 2;
float SWITCH_TO_FADE = 4;

void() light_fade_in =
{
	     if(self.cnt == 0)   lightstyle(self.style, "b");
	else if(self.cnt == 1)   lightstyle(self.style, "c");
	else if(self.cnt == 2)   lightstyle(self.style, "d");
	else if(self.cnt == 3)   lightstyle(self.style, "e");
	else if(self.cnt == 4)   lightstyle(self.style, "f");
	else if(self.cnt == 5)   lightstyle(self.style, "g");
	else if(self.cnt == 6)   lightstyle(self.style, "h");
	else if(self.cnt == 7)   lightstyle(self.style, "i");
	else if(self.cnt == 8)   lightstyle(self.style, "j");
	else if(self.cnt == 9)   lightstyle(self.style, "k");
	else if(self.cnt == 10)  lightstyle(self.style, "l");
	else if(self.cnt == 11){ lightstyle(self.style, "m");
							 return;
	     }
	self.cnt = self.cnt + 1;
	self.nextthink = time + self.waitmin;
}

void() light_fade_out=
{
	     if(self.cnt == 11)  lightstyle(self.style, "l");
	else if(self.cnt == 10)  lightstyle(self.style, "k");
	else if(self.cnt == 9)   lightstyle(self.style, "j");
	else if(self.cnt == 8)   lightstyle(self.style, "i");
	else if(self.cnt == 7)   lightstyle(self.style, "h");
	else if(self.cnt == 6)   lightstyle(self.style, "g");
	else if(self.cnt == 5)   lightstyle(self.style, "f");
	else if(self.cnt == 4)   lightstyle(self.style, "e");
	else if(self.cnt == 3)   lightstyle(self.style, "d");
	else if(self.cnt == 2)   lightstyle(self.style, "c");
	else if(self.cnt == 1)   lightstyle(self.style, "b");
	else if(self.cnt == 0) { lightstyle(self.style, "a");
							 return;
	     }
	self.cnt = self.cnt - 1;
	self.nextthink = time + self.waitmin;
}

void() light_use =
{
	if (self.spawnflags & START_OFF)
	{
		if(self.spawnflags & SWITCH_TO_FADE){
			self.think = light_fade_in;
			light_fade_in();
		}else{
			lightstyle(self.style, "m");
		}
		self.spawnflags = self.spawnflags - START_OFF;
	}
	else
	{
		if(self.spawnflags & SWITCH_TO_FLICKER)
			lightstyle(self.style, "cbaabktsdtbccbrtbklcdfbabcbacacbclkkquakeacbcbcbbklklc");
		else if(self.spawnflags & SWITCH_TO_FADE){
			self.think = light_fade_out;
			light_fade_out();
		}else
			lightstyle(self.style, "a");
		self.spawnflags = self.spawnflags + START_OFF;
	}
};

/*QUAKED light (0 1 0) (-8 -8 -8) (8 8 8) START_OFF SWITCH_TO_FLICKER SWITCH_TO_FADE
Non-displayed light.
Default light value is 300
Default style is 0
If targeted, it will toggle between on or off.
*/
void() light =
{
	local entity e;
	if (!self.targetname)
	{	// inert light
		remove(self);
		return;
	}
	if(!self.waitmin) self.waitmin = 0.1;
	
	
	if (self.style >= 32)
	{
		//make sure there only is ONE light per light style, dunno why :|
		e = find(world, targetname, self.targetname);
		while(e.classname != "light"){
			e = find(e, targetname, self.targetname);
		}
		if(e.style == self.style && e != self){
			remove(self);
			return;
		}
		
		self.use = light_use;
		if (self.spawnflags & START_OFF){
			lightstyle(self.style, "a");
			
		}else{
			lightstyle(self.style, "m");
			self.cnt = 11; //for fading
		}
	}
};

/*QUAKED light_fluoro (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Non-displayed light.
Default light value is 300
Default style is 0
If targeted, it will toggle between on or off.
Makes steady fluorescent humming sound
*/
void() light_fluoro =
{
	if (self.style >= 32)
	{
		self.use = light_use;
		if (self.spawnflags & START_OFF)
			lightstyle(self.style, "a");
		else
			lightstyle(self.style, "m");
	}
	
	precache_sound ("ambience/fl_hum1.wav");
	ambientsound (self.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_fluorospark (0 1 0) (-8 -8 -8) (8 8 8)
Non-displayed light.
Default light value is 300
Default style is 10
Makes sparking, broken fluorescent sound
*/
void() light_fluorospark =
{
	if (!self.style)
		self.style = 10;

	precache_sound ("ambience/buzz1.wav");
	ambientsound (self.origin, "ambience/buzz1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_globe (0 1 0) (-8 -8 -8) (8 8 8)
Sphere globe light.
Default light value is 300
Default style is 0
*/
void() light_globe =
{
	precache_model ("progs/s_light.spr");
	setmodel (self, "progs/s_light.spr");
	makestatic (self);
};

void() FireAmbient =
{
	precache_sound ("ambience/fire1.wav");
// attenuate fast
	ambientsound (self.origin, "ambience/fire1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_torch_small_walltorch (0 .5 0) (-10 -10 -20) (10 10 20)
Short wall torch
Default light value is 200
Default style is 0
*/
void() light_torch_small_walltorch =
{
	precache_model ("progs/flame.mdl");
	setmodel (self, "progs/flame.mdl");
	FireAmbient ();
	makestatic (self);
};

/*QUAKED light_flame_large_yellow (0 1 0) (-10 -10 -12) (12 12 18)
Large yellow flame ball
*/
void() light_flame_large_yellow =
{
	precache_model ("progs/flame2.mdl");
	setmodel (self, "progs/flame2.mdl");
	self.frame = 1;
	FireAmbient ();
	makestatic (self);
};

/*QUAKED light_flame_small_yellow (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Small yellow flame ball
*/
void() light_flame_small_yellow =
{
	precache_model ("progs/flame2.mdl");
	setmodel (self, "progs/flame2.mdl");
	FireAmbient ();
	makestatic (self);
};

/*QUAKED light_flame_small_white (0 1 0) (-10 -10 -40) (10 10 40) START_OFF
Small white flame ball
*/
void() light_flame_small_white =
{
	precache_model ("progs/flame2.mdl");
	setmodel (self, "progs/flame2.mdl");
	FireAmbient ();
	makestatic (self);
};

/*QUAKED light_candle (0 1 0) (-10 -10 -40) (10 10 40) START_OFF
White candle
*/
void() light_candle =
{
	precache_model ("progs/candle.mdl");
	setmodel (self, "progs/candle.mdl");
	makestatic (self);
};

void() model_candle_think = 
{ 
	self.frame = self.frame + 1; 
	if (self.frame > 3) 
		self.frame = 0; 
	self.nextthink = time + 0.1; 
}; 

void() model_candle = 
{ 

	precache_model ("progs/candle.mdl"); 

	setmodel (self, "progs/candle.mdl"); 

	//self.think = model_candle_think; 
	//self.nextthink = time + 0.1; 
};


//============================================================================


/*QUAKED misc_fireball (0 .5 .8) (-8 -8 -8) (8 8 8)
Lava Balls
*/

void() fire_fly;
void() fire_touch;
void() misc_fireball =
{
	
	precache_model ("progs/lavaball.mdl");
	self.classname = "fireball";
	self.nextthink = time + (random() * 5);
	self.think = fire_fly;
	if (!self.speed) self.speed = 1000;
};

void() fire_fly =
{
local entity	fireball;

	fireball = spawn();
	fireball.solid = SOLID_TRIGGER;
	fireball.movetype = MOVETYPE_TOSS;
	fireball.velocity = '0 0 1000';
	fireball.velocity_x = (random() * 100) - 50;
	fireball.velocity_y = (random() * 100) - 50;
	fireball.velocity_z = self.speed + (random() * 200);
	fireball.classname = "fireball";
	setmodel (fireball, "progs/lavaball.mdl");
	setsize (fireball, '0 0 0', '0 0 0');
	setorigin (fireball, self.origin);
	fireball.nextthink = time + 5;
	fireball.think = SUB_Remove;
	fireball.touch = fire_touch;
	
	self.nextthink = time + (random() * 5) + 3;
	self.think = fire_fly;
};


void() fire_touch =
{
	T_Damage (other, self, self, 20);
	remove(self);
};

//============================================================================


void() barrel_explode =
{
	self.takedamage = DAMAGE_NO;
	self.classname = "explo_box";
	// did say self.owner
	T_RadiusDamage (self, self, 160, world);
	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);
	particle (self.origin, '0 0 0', 75, 255);

	self.origin_z = self.origin_z + 32;
	BecomeExplosion ();
};



/*QUAKED misc_explobox (0 .5 .8) (0 0 0) (32 32 64)
TESTING THING
*/

void() misc_explobox =
{
	local float	oldz;
	
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	precache_model ("maps/b_explob.bsp");
	setmodel (self, "maps/b_explob.bsp");
	precache_sound ("weapons/r_exp3.wav");
	self.health = 20;
	self.th_die = barrel_explode;
	self.takedamage = DAMAGE_AIM;

	self.origin_z = self.origin_z + 2;
	oldz = self.origin_z;
	droptofloor();
	if (oldz - self.origin_z > 250)
	{
		dprint ("explobox fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
	}
};




/*QUAKED misc_explobox2 (0 .5 .8) (0 0 0) (32 32 64)
Smaller exploding box, REGISTERED ONLY
*/

void() misc_explobox2 =
{
	local float	oldz;
	
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	precache_model2 ("maps/b_exbox2.bsp");
	setmodel (self, "maps/b_exbox2.bsp");
	precache_sound ("weapons/r_exp3.wav");
	self.health = 20;
	self.th_die = barrel_explode;
	self.takedamage = DAMAGE_AIM;

	self.origin_z = self.origin_z + 2;
	oldz = self.origin_z;
	droptofloor();
	if (oldz - self.origin_z > 250)
	{
		dprint ("explobox fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
	}
};

//============================================================================

float SPAWNFLAG_SUPERSPIKE	= 1;
float SPAWNFLAG_LASER = 2;

void(vector org, vector vec) LaunchLaser;

void() spikeshooter_use =
{
	local entity newmis;
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		sound (self, CHAN_VOICE, "enforcer/enfire.wav", 1, ATTN_NORM);
		LaunchLaser (self.origin, self.movedir);
	}
	else
	{
		sound (self, CHAN_VOICE, "weapons/spike2.wav", 1, ATTN_NORM);
		newmis = launch_spike (self.origin, self.movedir);
		newmis.velocity = self.movedir * 500;
		if (self.spawnflags & SPAWNFLAG_SUPERSPIKE)
			newmis.touch = superspike_touch;
	}
};

void() shooter_think =
{
	local entity newmis;
	spikeshooter_use ();
	self.nextthink = time + self.wait;
};


/*QUAKED trap_spikeshooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
When triggered, fires a spike in the direction set in QuakeEd.
Laser is only for REGISTERED.
*/

void() trap_spikeshooter =
{
	SetMovedir ();
	self.use = spikeshooter_use;
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		precache_model2 ("progs/laser.mdl");
		
		precache_sound2 ("enforcer/enfire.wav");
		precache_sound2 ("enforcer/enfstop.wav");
	}
	else
		precache_sound ("weapons/spike2.wav");
};


/*QUAKED trap_shooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
Continuously fires spikes.
"wait" time between spike (1.0 default)
"nextthink" delay before firing first spike, so multiple shooters can be stagered.
*/
void() trap_shooter =
{
	trap_spikeshooter ();
	
	if (self.wait == 0)
		self.wait = 1;
	self.nextthink = self.nextthink + self.wait + self.ltime;
	self.think = shooter_think;
};



/*
===============================================================================


===============================================================================
*/


void() make_bubbles;
void() bubble_remove;
void() bubble_bob;


void() air_bubbles_use =
{
	self.state = 1 - self.state;
	
	if(self.state){ //switch them on
		make_bubbles();
	}else{ //switch them off
		self.nextthink = -1;
	}
}


/*QUAKED air_bubbles (0 .5 .8) (-8 -8 -8) (8 8 8)

testing air bubbles
*/

void() air_bubbles =

{

	if (deathmatch)
	{
		remove (self);
		return;
	}
	precache_model ("progs/s_bubble.spr");

	if(!self.speed) self.speed = 15;
	if(!self.count) self.count = 20;
	self.count = ceil(self.count);
	if(!self.waitmin) self.waitmin = 1;
	
	//cg: changed to make the bubbles toggleable
	self.use = air_bubbles_use;
	self.think = make_bubbles;
	self.state = self.state & 1;
	if(self.targetname == "" || self.state){
		self.nextthink = time + 1;
		self.state = 1;
	}
};

void() make_bubbles =
{
local entity	bubble;

	bubble = spawn();
	bubble.owner = self;
	setmodel (bubble, "progs/s_bubble.spr");
	setorigin (bubble, self.origin);
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 0';
	bubble.velocity_z = self.speed;
	bubble.nextthink = time +  0.5 * random();
	bubble.think = bubble_bob;
	bubble.touch = bubble_remove;
	bubble.classname = "bubble";
	bubble.frame = 0;
	bubble.cnt = 0;
	setsize (bubble, '-8 -8 -8', '8 8 8');
	self.nextthink = time + self.owner.waitmin + random();
	self.think = make_bubbles;
};

void() bubble_split =
{
local entity	bubble;
	bubble = spawn();
	bubble.owner = self.owner;
	setmodel (bubble, "progs/s_bubble.spr");
	setorigin (bubble, self.origin);
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = self.velocity;
	bubble.velocity_z = bubble.velocity_z * 0.9;
	bubble.alpha = self.alpha;
	bubble.nextthink = time + 0.5 * random();
	bubble.think = bubble_bob;
	bubble.touch = bubble_remove;
	bubble.classname = "bubble";
	bubble.frame = 1;
	self.frame = 1;
	self.cnt = bubble.cnt = self.owner.count * 0.5;
	setsize (bubble, '-8 -8 -8', '8 8 8');

	bubble_bob();
};

void() bubble_remove =
{
	if (other.classname == self.classname)
	{
//		dprint ("bump");
		return;
	}
	remove(self);
};

void() bubble_bob =
{
local float		rnd1, rnd2, rnd3;
local float		maxz, minz;
local vector	vtmp1, modi;

	self.cnt = self.cnt + 1;
	if (self.cnt == ceil(self.count * 0.2))
		bubble_split();
	if (self.cnt >= self.owner.count){
		remove(self);
	}

	rnd1 = self.velocity_x + (-10 + (random() * 20));
	rnd2 = self.velocity_y + (-10 + (random() * 20));
	rnd3 = self.velocity_z + 10 + random() * 10;

	if (rnd1 > 10)
		rnd1 = 5;
	if (rnd1 < -10)
		rnd1 = -5;
		
	if (rnd2 > 10)
		rnd2 = 5;
	if (rnd2 < -10)
		rnd2 = -5;

	if(self.owner.speed){
		maxz = self.owner.speed + 15;
		minz = self.owner.speed - 5;
	}else{
		maxz = 30;
		minz = 10;
	}
		
	if (rnd3 < minz)
		rnd3 = minz + 5;
	if (rnd3 > maxz)
		rnd3 = maxz - 5;
	
	self.velocity_x = rnd1;
	self.velocity_y = rnd2;
	self.velocity_z = rnd3;
		
	self.nextthink = time  + 0.5 * random();
	self.think = bubble_bob;
};

/*~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>
~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~*/

/*QUAKED viewthing (0 .5 .8) (-8 -8 -8) (8 8 8)

Just for the debugging level.  Don't use
*/

void() viewthing =

{
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	precache_model ("progs/player.mdl");
	setmodel (self, "progs/player.mdl");
};


/*
==============================================================================

SIMPLE BMODELS

==============================================================================
*/

void() func_wall_use =
{	// change to alternate textures
	self.frame = 1 - self.frame;
};

/*QUAKED func_wall (0 .5 .8) ?
This is just a solid wall if not inhibitted
*/
void() func_wall =
{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};

/*QUAKED func_illusionary (0 .5 .8) ?
A simple entity that looks solid but lets you walk through it.
*/
void() func_illusionary =

{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel (self, self.model);
	makestatic (self);
};

/*QUAKED func_episodegate (0 .5 .8) ? E1 E2 E3 E4
This bmodel will appear if the episode has allready been completed, so players can't reenter it.
*/
void() func_episodegate =

{
	if (!(serverflags & self.spawnflags))
		return;			// can still enter episode

	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};

/*QUAKED func_bossgate (0 .5 .8) ?
This bmodel appears unless players have all of the episode sigils.
*/
void() func_bossgate =

{
	if ( (serverflags & 15) == 15)
		return;		// all episodes completed
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};

//============================================================================
/*QUAKED ambient_suck_wind (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_suck_wind =
{
	precache_sound ("ambience/suck1.wav");
	ambientsound (self.origin, "ambience/suck1.wav", 1, ATTN_IDLE);
	SUB_Remove();
};

/*QUAKED ambient_drone (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_drone =
{
	precache_sound ("ambience/drone6.wav");
	ambientsound (self.origin, "ambience/drone6.wav", 0.5, ATTN_STATIC);
	SUB_Remove();
};

/*QUAKED ambient_flouro_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_flouro_buzz =
{
	precache_sound ("ambience/buzz1.wav");
	ambientsound (self.origin, "ambience/buzz1.wav", 1, ATTN_STATIC);
	SUB_Remove();
};
/*QUAKED ambient_drip (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_drip =
{
	precache_sound ("ambience/drip1.wav");
	ambientsound (self.origin, "ambience/drip1.wav", 0.5, ATTN_STATIC);
	SUB_Remove();
};
/*QUAKED ambient_comp_hum (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_comp_hum =
{
	precache_sound ("ambience/comp1.wav");
	ambientsound (self.origin, "ambience/comp1.wav", 1, ATTN_STATIC);
	SUB_Remove();
};
/*QUAKED ambient_thunder (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_thunder =
{
	precache_sound ("ambience/thunder1.wav");
	ambientsound (self.origin, "ambience/thunder1.wav", 0.5, ATTN_STATIC);
	SUB_Remove();
};
/*QUAKED ambient_light_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_light_buzz =
{
	precache_sound ("ambience/fl_hum1.wav");
	ambientsound (self.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
	SUB_Remove();
};
/*QUAKED ambient_swamp1 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_swamp1 =
{
	precache_sound ("ambience/swamp1.wav");
	ambientsound (self.origin, "ambience/swamp1.wav", 0.5, ATTN_STATIC);
	SUB_Remove();
};
/*QUAKED ambient_swamp2 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_swamp2 =
{
	precache_sound ("ambience/swamp2.wav");
	ambientsound (self.origin, "ambience/swamp2.wav", 0.5, ATTN_STATIC);
	SUB_Remove();
};


void() wow_whoa_plopp =
{
	precache_sound ("honey/blaahd.wav");
	ambientsound (self.origin, "honey/blaahd.wav", 1, ATTN_STATIC);
	SUB_Remove();
}

void() ambient_waterfall =
{
	precache_sound ("honey/q2watr.wav");
	ambientsound (self.origin, "honey/q2watr.wav", 1, ATTN_IDLE);
	SUB_Remove();
}

void() ambient_use =
{
	sound (self, CHAN_VOICE, self.noise, self.volume, self.delay);
	self.use = SUB_Null;
}

void() ambient_machine =
{
	self.noise = "honey/machine.wav";
	if(!self.volume) self.volume = 0.7;
	if(!self.delay) self.delay = ATTN_NORM;
	precache_sound (self.noise);
	self.use = ambient_use;
}

void() ambient_teleport =
{	
	precache_sound ("ambience/hum1.wav");
	ambientsound (self.origin, "ambience/hum1.wav",0.5 , ATTN_STATIC);
	SUB_Remove();
}


void() ambient_secret_think =
{
	local float rnd, rnd2;
	
	rnd = random();
	rnd2 = 0.5 + 0.5 * random();
	if(rnd < 0.25){
		sound (self, CHAN_AUTO, "honey/ting1.wav",rnd2 , 1.2);
		
	}else if(rnd < 0.5){
		sound (self, CHAN_AUTO, "honey/ting2.wav",rnd2 , 1.2);
		
	}else if(rnd < 0.75){
		sound (self, CHAN_AUTO, "honey/ting3.wav",rnd2 , 1.2);
		
	}else{
		sound (self, CHAN_AUTO, "honey/ting4.wav",rnd2 , 1.2);

	}
	
	rnd = 0.2 + 3 * random();
	self.think = ambient_secret_think;
	self.nextthink = time + rnd;
	
}

entity(vector org) ambient_secret_spawn =
{
	entity ambi, oself;
	ambi = spawn();
	setorigin(ambi, org);
	oself= self;
	self = ambi;
	ambient_secret_think();
	self = oself;
	return ambi;
}



//============================================================================


