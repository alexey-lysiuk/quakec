// PM:  Use this only for cutscene actors.  If you want Quake guys as
//  adversaries, use 'monster_ranger' instead.  Ideally, I should merge
//  the hostage and ranger into a single entity, but I can't be bothered
//  with that right now.
//
//  I ought to rewrite this, but changed only what was necessary.
//  There is a lot of legacy code here.

/* ---------------------------- */
/* |  An Actor for cut-scenes | */
/* ---------------------------- */
//
// running
//
$frame axrun1 axrun2 axrun3 axrun4 axrun5 axrun6

$frame rockrun1 rockrun2 rockrun3 rockrun4 rockrun5 rockrun6

//$frame sawrun1 sawrun2 sawrun3 sawrun4 sawrun5 sawrun6

//
// standing
//
$frame stand1 stand2 stand3 stand4 stand5

//$frame swstnd1 swstnd2 swstnd3 swstnd4 swstnd5

$frame axstnd1 axstnd2 axstnd3 axstnd4 axstnd5 axstnd6
$frame axstnd7 axstnd8 axstnd9 axstnd10 axstnd11 axstnd12


//
// pain
//
$frame axpain1 axpain2 axpain3 axpain4 axpain5 axpain6

$frame pain1 pain2 pain3 pain4 pain5 pain6

//$frame swpain1 swpain2 swpain3 swpain4 swpain5 swpain6

//
// death
//

$frame axdeth1 axdeth2 axdeth3 axdeth4 axdeth5 axdeth6
$frame axdeth7 axdeth8 axdeth9

//$frame swdeth1 swdeth2 swdeth3 swdeth4 swdeth5 swdeth6
//$frame swdeth7 swdeth8 swdeth9

$frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6 deatha7 deatha8
$frame deatha9 deatha10 deatha11

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9

$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
$frame deathc9 deathc10 deathc11 deathc12 deathc13 deathc14 deathc15

$frame deathd1 deathd2 deathd3 deathd4 deathd5 deathd6 deathd7
$frame deathd8 deathd9

$frame deathe1 deathe2 deathe3 deathe4 deathe5 deathe6 deathe7
$frame deathe8 deathe9

//
// attacks
//
$frame nailatt1 nailatt2

//$frame sawatt1 sawatt2

$frame light1 light2

$frame rockatt1 rockatt2 rockatt3 rockatt4 rockatt5 rockatt6

$frame shotatt1 shotatt2 shotatt3 shotatt4 shotatt5 shotatt6

$frame axatt1 axatt2 axatt3 axatt4 axatt5 axatt6

$frame axattb1 axattb2 axattb3 axattb4 axattb5 axattb6

$frame axattc1 axattc2 axattc3 axattc4 axattc5 axattc6

$frame axattd1 axattd2 axattd3 axattd4 axattd5 axattd6


//- - - - - - - - - - - - - -
void() misc_hostage;
void() ActorDie;
void() actor_run;
void() sf64_teledeath = {spawn_tdeath (self.origin, self.owner); remove(self);};

float HOSTAGE_DEAD = 1;

void() actor_pain1 =[ $pain1,  actor_pain2  ] {PainSound();};
void() actor_pain2 =[ $pain2,  actor_pain3  ] {};
void() actor_pain3 =[ $pain3,  actor_pain4  ] {};
void() actor_pain4 =[ $pain4,  actor_pain5  ] {};
void() actor_pain5 =[ $pain5,  actor_pain6  ] {};
void() actor_pain6 =[ $pain6,  actor_run    ]
{
    if (self.count == 1)
        if (self.enemy != world)
            ai_run(10);
};

void() actor_pain =
{
    if (self.pain_finished > time)
        return;

    ai_back (5);
    self.pain_finished = time + 0.7;
    actor_pain1 ();
};

void() actor_shot1 =[ $shotatt1,  actor_shot2  ] {self.effects = self.effects | EF_MUZZLEFLASH;};
void() actor_shot2 =[ $shotatt2,  actor_shot3  ] {};
void() actor_shot3 =[ $shotatt3,  actor_shot4  ] {};
void() actor_shot4 =[ $shotatt4,  actor_shot5  ] {};
void() actor_shot5 =[ $shotatt5,  actor_shot6  ] {};
void() actor_shot6 =[ $shotatt6,  actor_run    ] {};


void() Actor_use =
{
    if (self.spawnflags & HOSTAGE_DEAD)
    {
        self.takedamage = DAMAGE_AIM;
        self.enemy = checkclient();
        if (self.enemy)
            self.movetarget = self.goalentity = self.enemy;
        self.count = 1;
    }
    else
        self.pausetime = time;
};

void() GibActor =
{
// FIXME:  Debug messages in developer mode.
    self.frame = 0;
//    self.think = SUB_UseTargets;
// PM:  Removed third parm from Throw*.
    ThrowHead ("progs/h_player.mdl", self.health);
    ThrowGib ("progs/gib1.mdl", self.health);
    ThrowGib ("progs/gib2.mdl", self.health);
    ThrowGib ("progs/gib3.mdl", self.health);

    self.deadflag = DEAD_DEAD;

    if (damage_attacker.classname == "teledeath")
        sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
    else if (random() < 0.5)
        sound (self, CHAN_VOICE, "player/gib.wav", 1, ATTN_NONE);
    else
        sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NONE);
};

void() ActorDie =
{
    self.deadflag   = DEAD_DYING;
    self.solid      = SOLID_NOT;
    self.flags      = self.flags - (self.flags & FL_ONGROUND);
    self.movetype   = MOVETYPE_TOSS;
    if (self.velocity_z < 10)
        self.velocity_z = self.velocity_z + random()*300;

    if (self.health < -20)
        {self.frame = 0; GibActor (); return;}

    DeathSound();
    
    self.angles_x = 0;
    self.angles_z = 0;
    
// Axe code removed since it isn't used.

    local   float   i;

    i = 1 + floor(random()*5);
    if (i == 1)
        player_diea1();
    else if (i == 2)
        player_dieb1();
    else if (i == 3)
        player_diec1();
    else if (i == 4)
        player_died1();
    else
        player_diee1();
};

void() actor_stand1 =[ $stand1, actor_stand1 ]
{
    if (self.pausetime < time)
        {actor_run(); return;}

    if (self.walkframe >= 5)
        self.walkframe = 0;
    self.frame = $stand1 + self.walkframe;
    self.walkframe = self.walkframe + 1;    
};

void() actor_run =[ $rockrun1, actor_run ]
{
    if (self.dmg == 69)     // hack for zer1m2 scene
    {   // Freeze the actor shortly after falling into the (meat) trap.
        if (time > 55)
        {
            self.think = SUB_Null;
            self.nextthink = -1;
            self.pausetime = 999999;
            return;
        }
    }
    self.oldorigin = self.origin;

    if (self.count == 0 || self.enemy == world)
        movetogoal(self.speed);
    else
    {
        if (self.count == 1)
            self.enemy = checkclient();

        if (self.enemy)
        {
            if (self.enemy.health <= 0)
            {
                self.enemy = world;
                self.count = 0;
                //self.pausetime = 999999;
                self.goalentity = self.movetarget = self.oldenemy;
                self.think = actor_run;
                self.nextthink = time + 0.01;
                return;
            }
            self.movetarget = self.enemy;
            self.goalentity = self.enemy;
        }
        ai_run (self.speed);
    }
    
    if (self.count == 1)
        self.enemy = checkclient();

    if (self.walkframe == 6)
        self.walkframe = 0;
    self.frame = self.frame + self.walkframe;
    self.walkframe = self.walkframe + 1;
};


// Update 8/1/09:  Remove redundancy.
void() Actor_fire =
{
local vector dir;
local entity en;

    ai_face();

// fire somewhat behind the player, so a dodging player is harder to hit
    en = self.enemy;
    
    dir = en.origin - en.velocity*0.2;
    dir = normalize (dir - self.origin);

// Update 8/1/09:  Use modified Drake weapon functions.
// twas the night before release, and I needed a hack...
    if (world.model == "maps/zerend.bsp")
    {
        local   vector  org;

        makevectors (self.v_angle);
        org = self.origin + v_forward*8 + '0 0 16';
        sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NONE);
        Rocket_Launch (org, dir);
        newmis.velocity = dir * 800;
        newmis.touch = SUB_Remove;      // The Zerstorer cannot be harmed.
    }
    else
    {
        sound (self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);    
        FireBullets (8, dir, '0.1 0.1 0');
    }
    self.attack_finished = time + 1;
};
//- - - - - - - - -
void() Actor_attack =
{
    if (self.attack_finished <= time)
        if (random() < 0.85)
        {
            actor_shot1 ();
            Actor_fire ();
        }
};


void() actor_start =
{
    if (self.spawnflags & HOSTAGE_DEAD)
    {
        self.origin_z = self.origin_z + 1;    // raise off floor a bit
        droptofloor();
    
        if (!walkmove(0,0))
        {
            dprint ("walkmonster in wall at: ");
            dprint (vtos(self.origin));
            dprint ("\n");
        }

        if (self.target)
        {
            self.goalentity = self.movetarget = find(world, targetname, self.target);
            self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
            if (!self.movetarget)
            {
                dprint ("Actor can't find target at ");
                dprint (vtos(self.origin));
                dprint ("\n");
            }
        }
        else
            self.pausetime = 9999999;

        self.takedamage = DAMAGE_NO;
        //self.solid = SOLID_NOT;
        self.nextthink = time + 0.1;
        self.think = self.th_run;
    }
    else
    {
        if (self.target)
        {
            self.goalentity = self.movetarget = find(world, targetname, self.target);
            self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
            if (!self.movetarget)
            {
                dprint ("Actor can't find target at ");
                dprint (vtos(self.origin));
                dprint ("\n");
            }
        }
        else
            self.pausetime = 9999999;
        droptofloor ();
        actor_stand1 ();
    }
};

// sf64 start code
void() actor_sf64start =
{
    if (self.style)
    {
        local   vector  org;
        local   entity  teldeath;

        makevectors (self.angles);
        org = self.origin + 16 * v_forward;
        spawn_tfog (org);
        teldeath = spawn();
        teldeath.origin = org;
        teldeath.owner = self;

        teldeath.think = sf64_teledeath;
        teldeath.nextthink = time + 0.2;
    }

    self.use = Actor_use;

    self.solid = SOLID_SLIDEBOX;        
    self.movetype = MOVETYPE_STEP;    // They just stand on the ground

    setmodel (self, "progs/player.mdl");
    setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
    setorigin (self, self.origin);

    if (self.wait)
        self.pausetime = time + self.wait;

    self.nextthink = time + 0.1;
    self.think = actor_start;    
};

/*QUAKED misc_hostage (.5 .5 .5) (-8 -8 -8) (8 8 32)  ACTOR_DEAD x x x x x TRIGGER_SPAWN
This is an actor-robot whose behavior is fully scriptable.

"target"  Point it at the first 'actor_target' in the path.
"wait"  Specify how-long the actor will stand still before heading for 1st actor_target.
"speed"  How fast the actor runs.  Default == 10.

ACTOR_DEAD(1) makes the actor a non-living entity until triggered.  It will affect monster-count,
and will attack the player after it has been triggered.  (specially made for 'damned')

TRIGGER_SPAWN(64) causes the actor to not spawn until it is triggered.  If "style" is set
for the actor it will cause a teleport-splash when it spawns.
*/
void() misc_hostage =
{
    if (deathmatch || coop)
        {remove (self); return;}

    self.origin             = self.origin + '0 0 56';
    self.classname          = self.netname  = "actor";
    self.health             = 150;
    self.yaw_speed          = 30;
    self.count              = 0;
    self.takedamage         = DAMAGE_AIM;
    self.flags              = FL_MONSTER | FL_CLIENT;   // PM:  What?!
    self.waterlevel         = 0;
    self.show_hostile       = 0;
    self.attack_finished    = 0;
//    self.war                = WAR_ROCKET_LAUNCHER;
//    self.ammo_nails         = 200;
//    self.ammo_rockets       = 100;
//    self.currentammo        = 200;
    self.xfl = XFL_NO_SCAN;     // PM: Don't check for drowning or frying.

    if (self.spawnflags & HOSTAGE_DEAD)
        total_monsters = total_monsters + 1;

    if (self.wait)
        self.pausetime = time + self.wait;
    else
        self.pausetime = 9999999;

    self.walkframe  = 0;
    self.frame      = $stand1;

    if (!self.speed)
        self.speed = 10;

    self.th_stand   = actor_stand1;
    self.th_walk    = actor_run;
    self.th_run     = actor_run;
    self.th_missile = Actor_attack;
    self.th_melee   = Actor_attack;
    self.th_pain    = actor_pain;
    self.th_die     = ActorDie;

// PM:  Needed for expanded ai.
    self.th_move    = walkmove;
    self.th_goal    = movetogoal;

    if (self.spawnflags & 64)   //TRIGGER_SPAWN
    {
        self.use = actor_sf64start;
        return;
    }

    self.use = Actor_use;

    self.solid = SOLID_SLIDEBOX;        
    self.movetype = MOVETYPE_STEP;    // They just stand on the ground

    setmodel (self, "progs/player.mdl");
    setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
    setorigin (self, self.origin);

    self.nextthink = time + 0.1;
    self.think = actor_start;
};

/**************************************************/
// Sequencing routines
// ---------------------
void() ActorJump =
{
local vector vel;

    vel = self.origin - self.oldorigin;
    self.velocity = normalize(vel) * (self.speed * 10);

    if (self.waterlevel >= 2)
    {
        if (self.watertype == CONTENT_WATER)
            self.velocity_z = 100;
        else if (self.watertype == CONTENT_SLIME)
            self.velocity_z = 80;
        else
            self.velocity_z = 50;

// play swiming sound
        if (self.swim_flag < time)
        {
            self.swim_flag = time + 1;
            if (random() < 0.5)
                sound (self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
            else
                sound (self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
        }
        return;
    }

    sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
    self.flags = self.flags - FL_ONGROUND;
    setorigin(self, self.origin + '0 0 2');
    self.velocity_z = self.velocity_z + 270;
};

// Update 8/1/09:  Removed 'void(vector dir) actor_rocket'.

void() Actor_shoot =
{
    Actor_fire ();
    self.enemy = world;
};


void() t_actortarget =
{
local float    ACTOR_JUMP = 1;
local float ACTOR_SHOOT = 2;
local float ACTOR_ATTACK = 4;
local entity temp;

    if (self.volume > time)     // Replaced 'rad_time' with 'volume'.
        return;

    if (other.classname != "actor")
        return;
    if (other.count == 2)
        return;
    if (other.goalentity != self)
        return;
    /*dprint("t_actortarget - ");dprint(self.targetname);dprint("\n");*/
    self.volume = time + 2.5;

    other.goalentity = other.movetarget = find (world, targetname, self.target);

    other.ideal_yaw = vectoyaw(other.goalentity.origin - other.origin);

    if(self.speed)
        other.speed = self.speed;

    if (self.message)
    {
        //dprint("Using target!\n");
        self.target = self.message;
        SUB_UseTargets ();
    }

    if (self.dmg)
    {
        self.nextthink = time + 0.1;
        self.think = SUB_Remove;
    }

    if(self.spawnflags & ACTOR_JUMP)
    {
        //dprint("Actor jump!\n");
        temp = self;
        self = other;
        ActorJump();
        self = temp;
        return;
    }

    if (self.spawnflags & ACTOR_SHOOT)
    {
       //dprint("Actor shoot!\n");
       other.enemy = find(world, targetname, self.noise);
       temp = self;
       self = other;
       actor_shot1();
       Actor_shoot();
       if (!temp.targetname)
       { 
        self.pausetime = time + 999999;
        self.th_stand ();
        self = temp;
        return;
       }
       self = temp;
       return;
    }

    if (self.spawnflags & ACTOR_ATTACK)
    {
        //dprint("ACTOR_ATTACK\n");
        other.enemy = find(world, targetname, self.noise);
        while (!(other.enemy.flags & FL_MONSTER))
            other.enemy = find(other.enemy, targetname, self.noise);
        other.count = 2;
        other.oldenemy = other.goalentity;
        return;
    }

    if (self.wait)
    {
        //dprint("hostage waiting\n");
        self.volume = self.volume + self.wait;
        temp = self;
        self = other;
        self.pausetime = time + temp.wait;
        actor_stand1();
        self = temp;
        return;
    }    

    if (!other.movetarget)
    {
        temp = self;
        self = other;
        self.pausetime = time + 999999;
        self.th_stand ();
        self = temp;
        return;
    }
};

void() s_at =
{
    self.solid = SOLID_TRIGGER;
    self.touch = t_actortarget;
    setsize (self, '-8 -8 -12', '8 8 24');
};

/*QUAKED actor_target (.5 .5 .5) (-8 -8 -8) (8 8 8)  ACTOR_JUMP ACTOR_SHOOT ACTOR_ATTACK
Link an actor to these targets to control its behavior.

"target"  Point to the next one.
"wait"  Specify how-long the actor will stand still before heading for next actor_target.
"speed"  How fast the actor runs.  Default == 10.

ACTOR_JUMP(1)  The actor will jump when hitting this target, and continue to the next.
ACTOR_SHOOT(2)  The actor will aim at the entity targeted using the "noise" field, and
fire the shotgun at it once, then continue to the next target.
ACTOR_ATTACK(4)  The actor will get mad at this entity targeted using the "noise" and try 
and kill it.
*/
void() actor_target =
{
    if (!self.targetname)
        objerror ("actor_target: no targetname");
    self.nextthink = time + 0.1;
    self.think = s_at;
};


//===========================/  END OF FILE  /===========================//
