// defs.qc

//===========================================================================
//  Lines used by hardcoded C code below.  The fields must be present,
//  unchanged, and in order.

// SOURCE FOR GLOBALVARS_T C STRUCTURE ======================================

// system globals -----------------------------------------------------------
entity      self;
entity      other;
entity      world;
float       time;
float       frametime;
float       force_retouch;
    // Force all entities to touch triggers next frame.  This is needed
    // because non-moving things don't normally scan for triggers, and when
    // a trigger is created (like a teleport trigger), it needs to catch
    // everything.  Decremented each frame, so set to 2 to guarantee
    // everything is touched
string      mapname;
float       deathmatch;
float       coop;
float       teamplay;
float       serverflags;    // propagated from level to level, used to
                            // keep track of completed episodes
float       total_secrets;
float       total_monsters;
float       found_secrets;      // number of secrets found
float       killed_monsters;    // number of monsters killed
// Spawnparms are used to encode information about clients across server
// level changes.
float       parm1, parm2, parm3, parm4, parm5, parm6, parm7, parm8, parm9, parm10, parm11, parm12, parm13, parm14, parm15, parm16;
// global variables set by built in functions -------------------------------
vector      v_forward, v_up, v_right;   // set by makevectors()
// set by traceline / tracebox ----------------------------------------------
float       trace_allsolid;
float       trace_startsolid;
float       trace_fraction;
vector      trace_endpos;
vector      trace_plane_normal;
float       trace_plane_dist;
entity      trace_ent;
float       trace_inopen;
float       trace_inwater;

entity      msg_entity;     // destination of single entity writes
// required prog functions --------------------------------------------------
void()      main;       // only for testing
void()      StartFrame;
void()      PlayerPreThink;
void()      PlayerPostThink;
void()      ClientKill;
void()      ClientConnect;
void()      PutClientInServer;      // call after setting the parm1... parms
void()      ClientDisconnect;
void()      SetNewParms;            // called when a client first connects to
                                    // a server. sets parms so they can be
                                    // saved off for restarts
void()      SetChangeParms;         // call to set parms for self so they can
                                    // be saved for a level transition
//================================================
void        end_sys_globals;        // flag for structure dumping
//================================================


// SOURCE FOR ENTVARS_T C STRUCTURE =========================================

// system fields (*** = do not set in prog code, maintained by C code)
.float      modelindex;         // *** model index in the precached list
.vector     absmin, absmax;     // *** origin + mins / maxs
.float      ltime;              // local time for entity
.float      movetype;
.float      solid;
.vector     origin;             // ***
.vector     oldorigin;          // ***
.vector     velocity;
.vector     angles;
.vector     avelocity;
.vector     punchangle;         // temp angle adjust from damage or recoil
.string     classname;          // spawn function
.string     model;
.float      frame;
.float      skin;
.float      effects;
.vector     mins, maxs;         // bounding box extents reletive to origin
.vector     size;               // maxs - mins
.void()     touch;
.void()     use;
.void()     think;
.void()     blocked;    // for doors or plats, called when can't push other
.float      nextthink;
.entity     groundentity;
// stats --------------------------------------------------------------------
.float      health;
.float      frags;
.float      weapon;         // one of the IT_SHOTGUN, etc flags
.string     weaponmodel;
.float      weaponframe;
.float      currentammo;
.float      ammo_shells, ammo_nails, ammo_rockets, ammo_cells;
.float      items;          // bit flags
.float      takedamage;
.entity     chain;
.float      deadflag;
.vector     view_ofs;       // add to origin to get eye point
.float      button0;        // fire
.float      button1;        // use
.float      button2;        // jump
.float      impulse;        // weapon changes
.float      fixangle;
.vector     v_angle;        // view / targeting angle for players
.float      idealpitch;     // calculated pitch angle for lookup up slopes
.string     netname;
.entity     enemy;
.float      flags;
.float      colormap;
.float      team;
.float      max_health;     // players maximum health is stored here
.float      teleport_time;  // don't back up
.float      armortype;      // save this fraction of incoming damage
.float      armorvalue;
.float      waterlevel;     // 0 = not in, 1 = feet, 2 = wast, 3 = eyes
.float      watertype;      // a contents value
.float      ideal_yaw;
.float      yaw_speed;
.entity     aiment;
.entity     goalentity;     // a movetarget or an enemy
.float      spawnflags;
.string     target;
.string     targetname;
// Damage is accumulated through a frame. and sent as one single
// message, so the super shotgun doesn't generate huge messages.
.float      dmg_take;
.float      dmg_save;
.entity     dmg_inflictor;
.entity     owner;          // who launched a missile
.vector     movedir;        // mostly for doors, but also used for waterjump
.string     message;        // trigger messages
.float      sounds;         // either a cd track number or sound number
.string     noise, noise1, noise2, noise3;  // contains names of wavs to play
//================================================
void        end_sys_fields;            // flag for structure dumping
//================================================


//===========================================================================
// builtin functions ========================================================
void(vector ang) makevectors        = #1;        // sets v_forward, etc globals
void(entity e, vector o) setorigin  = #2;
void(entity e, string m) setmodel   = #3;        // set movetype and solid first
void(entity e, vector min, vector max) setsize = #4;
void() break                        = #6;
float() random                      = #7;        // returns 0 - 1
// PM:  FrikBot
//void(entity e, float chan, string samp, float vol, float atten) sound = #8;
vector(vector v) normalize          = #9;
void(string e) error                = #10;
void(string e) objerror             = #11;
float(vector v) vlen                = #12;
float(vector v) vectoyaw            = #13;
entity() spawn                      = #14;
void(entity e) remove               = #15;
//---------------------------------------------------------------------------
// sets trace_* globals
// nomonsters can be:
// An entity will also be ignored for testing if forent == test,
// forent->owner == test, or test->owner == forent
// a forent of world is ignored
void(vector v1, vector v2, float nomonsters, entity forent) traceline = #16;    
//---------------------------------------------------------------------------
entity() checkclient                = #17;  // returns a client to look for
entity(entity start, .string fld, string match) find = #18;
string(string s) precache_sound     = #19;
string(string s) precache_model     = #20;
// PM:  FrikBot
//void(entity client, string s)stuffcmd = #21;
entity(vector org, float rad) findradius = #22;
void(string s) bprint               = #23;
// PM:  FrikBot
//void(entity client, string s) sprint = #24;
void(string s) dprint               = #25;
string(float f) ftos                = #26;
string(vector v) vtos               = #27;
void() coredump                     = #28;        // prints all edicts
void() traceon                      = #29;        // turns statment trace on
void() traceoff                     = #30;
void(entity e) eprint               = #31;        // prints an entire edict
float(float yaw, float dist) walkmove = #32;    // returns TRUE or FALSE
//- - - - - - - - -
// PM:  Removed parms from 'droptofloor'.  Why?
// 1) Other qc files do not have the parms.
// 2) FrikQCC complains about that, so either defs.qc or the other qc files
//  are wrong.  Removal of parms is the solution, with explaination below.
// 3) 'PF_droptofloor' in q1source does not have them.  In fact, it assumes
//  the entity passed is self.
//- - - - - - - - -
float() droptofloor                 = #34;        // TRUE if landed on floor
//- - - - - - - - -
void(float style, string value) lightstyle = #35;
float(float v) rint                 = #36;        // round to nearest int
float(float v) floor                = #37;        // largest integer <= v
float(float v) ceil                 = #38;        // smallest integer >= v
float(entity e) checkbottom         = #40;        // true if self is on ground
float(vector v) pointcontents       = #41;        // returns a CONTENT_*
float(float f) fabs                 = #43;
// PM:  FrikBot
//vector(entity e, float speed) aim   = #44;      // returns the shooting vector
float(string s) cvar                = #45;      // return cvar.value
void(string s) localcmd             = #46;      // put string into local que
entity(entity e) nextent            = #47;      // for looping through all ents
void(vector o, vector d, float color, float count) particle = #48;// start a particle effect
void() ChangeYaw                    = #49;      // turn towards self.ideal_yaw
                                                // at self.yaw_speed
vector(vector v) vectoangles        = #51;
// direct client message generation -----------------------------------------
/* PM:  Commented out for FBX
void(float to, float f) WriteByte    = #52;
void(float to, float f) WriteChar    = #53;
void(float to, float f) WriteShort   = #54;
void(float to, float f) WriteLong    = #55;
void(float to, float f) WriteCoord   = #56;
void(float to, float f) WriteAngle   = #57;
void(float to, string s) WriteString = #58;
void(float to, entity s) WriteEntity = #59;
*/
// --------------------------------------------------------------------------
void(float step) movetogoal         = #67;
string(string s) precache_file      = #68;      // no effect except for -copy
void(entity e) makestatic           = #69;
void(string s) changelevel          = #70;
void(string var, string val) cvar_set = #72;    // sets cvar.value
// PM:  FrikBot
//void(entity client, string s) centerprint = #73;    // sprint, but in middle
void(vector pos, string samp, float vol, float atten) ambientsound = #74;
string(string s) precache_model2    = #75;      // registered version only
string(string s) precache_sound2    = #76;      // registered version only
string(string s) precache_file2     = #77;      // registered version only
// PM:  FrikBot
//void(entity e) setspawnparms        = #78;      // set parm1... to the
                                                // values at level start
                                                // for coop respawn

//===========================/  END OF FILE  /===========================//
