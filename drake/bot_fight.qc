/***********************************************
*                                              *
*             FrikBot Fight Code               *
*      "Because I ain't no Ghandi code"        *
*                                              *
***********************************************/

/*

This program is in the Public Domain. My crack legal
team would like to add:

RYAN "FRIKAC" SMITH IS PROVIDING THIS SOFTWARE "AS IS"
AND MAKES NO WARRANTY, EXPRESS OR IMPLIED, AS TO THE
ACCURACY, CAPABILITY, EFFICIENCY, MERCHANTABILITY, OR
FUNCTIONING OF THIS SOFTWARE AND/OR DOCUMENTATION. IN
NO EVENT WILL RYAN "FRIKAC" SMITH BE LIABLE FOR ANY
GENERAL, CONSEQUENTIAL, INDIRECT, INCIDENTAL,
EXEMPLARY, OR SPECIAL DAMAGES, EVEN IF RYAN "FRIKAC"
SMITH HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
DAMAGES, IRRESPECTIVE OF THE CAUSE OF SUCH DAMAGES. 

You accept this software on the condition that you
indemnify and hold harmless Ryan "FrikaC" Smith from
any and all liability or damages to third parties,
including attorney fees, court costs, and other
related costs and expenses, arising out of your use
of this software irrespective of the cause of said
liability. 

The export from the United States or the subsequent
reexport of this software is subject to compliance
with United States export control and munitions
control restrictions. You agree that in the event you
seek to export this software, you assume full
responsibility for obtaining all necessary export
licenses and approvals and for assuring compliance
with applicable reexport restrictions. 

Any reproduction of this software must contain
this notice in its entirety. 

*/

.entity avoid;

float(entity e) bot_size_player =
{
    local float sz;

    sz = e.health + e.armorvalue * e.armortype;
// PM:  Drake's weapon system.
    if (e.form_active)
        sz = sz + 40;       // Dragon form comparable to nailgun.
    else if (e.war & WARx_USES_SHELLS)
    {
        if (e.war & WAR_SHOTGUN)
            sz = sz + 10;
        else
            sz = sz + 50;   // Was 40.  Ssg was buffed to Q3 strength.
    }
    else if (e.war & WARx_USES_NAILS)
    {
        if (e.war & WAR_NAILGUN)
            sz = sz + 40;
        else
            sz = sz + 50;
    }
    else if (e.war & WARx_USES_ROCKETS)
    {
        if (e.war & WAR_GRENADE_LAUNCHER)
            sz = sz + 50;
        else if (e.war & WAR_CRUISE_MISSILE)
            sz = sz + 100;      // MIRVs is BFG.
//        else    // other rocket launchers, railgun.
//            sz = sz + 60;
    }
    else if (e.war & WARx_USES_CELLS)
    {
        if (e.war & WAR_MJOLNIR)
            sz = sz + 100;      // Used 40 for standard hammer.
        else if (e.war & WAR_BLASTER)
            sz = sz + 40;
        else
            sz = sz + 60;
    }
    else if (e.war & WAR_ZAPPER)
        sz = sz + 10;       // About on par with shotgun.
    else if (e.war & WAR_BURIZA)
        sz = sz + 100;      // Run for your lives!
    else
        sz = sz - 50;
// PM:  Artifacts
    if (e.super_damage_finished) // Quad
        sz = sz + 200;
    if (e.invincible_finished) // Invul
        sz = sz + 300;
    else if (e.cross_finished)   // Cross of Deflection (from Chapters/Quoth)
        sz = sz + 200;      // Cross is superceded by Pentagram.
    if (e.invisible_finished) // Invis
        sz = sz + 250;
    // Hip/Drake artifacts
    if (e.thorns_finished)  // Empathy Shields
        sz = sz + 200;
    if (e.mirror_finished)  // Reflect
        sz = sz + 250;
    if (e.tome_finished)    // Tome of Power
        sz = sz + 200;
/* Old code below ---------------------
    if (e.weapon == 32)
        sz = sz + 60;
    else if (e.weapon == 64)
        sz = sz + 60;
    else if (e.weapon == 16)
        sz = sz + 50;
    else if (e.weapon == 8)
        sz = sz + 50;
    else if (e.weapon == 4)
        sz = sz + 40;
    else if (e.weapon == 2)
        sz = sz + 40;
    else if (e.weapon == 1)
        sz = sz + 10;
    else if (e.weapon == 4096)
        sz = sz - 50;
    if (e.items & 4194304) // Quad
        sz = sz + 200;
    if (e.items & 1048576) // Invul
        sz = sz + 300;
    if (e.items & 524288) // Invis
        sz = sz + 250;
*/
    return sz;
};

void() bot_dodge_stuff =
{
    local entity foe;
    local float avdist, foesz, flen, tsz;
    local vector v;

    if (waypoint_mode > WM_LOADED)
        return;

    self.avoid = world;


    if (self.enemy)
    {
        v = self.origin - realorigin(self.enemy);

        foesz = bot_size_player(self.enemy);
        foesz = foesz + vlen(v) * 0.5;
    }
    else 
        foesz = 9999999;
    avdist = 256;

    foe = nextent(world);
    while(foe)
    {
        if (IsMissile (foe))  // PM:  Detects missiles, spikes, and more.
        {
            if (foe.owner != self)
            {
                flen = vlen(foe.origin - self.origin);
                if (flen < avdist)
                {
                    avdist = flen;
                    self.avoid = foe;
                }
            }
            else if ((foe.classname == "grenade") ||
            (foe.classname == "proximity_grenade"))
            {
                flen = vlen(foe.origin - self.origin);
                if (flen < avdist)
                {
                    avdist = flen;
                    self.avoid = foe;
                }
            }
        }
        foe = nextent(foe);
    }
/* Old code below ---------------------
    foe = find(world, classname, "grenade");
    while(foe)
    {
        flen = vlen(foe.origin - self.origin);
        if (flen < avdist)
        {
            avdist = flen;
            self.avoid = foe;
        }
        foe = find(foe, classname, "grenade");
    }
    if (!self.avoid)
    {
        foe = find(world, classname, "missile");
        while(foe)
        {
            if (foe.owner != self)
            {
                flen = vlen(foe.origin - self.origin);
                if (flen < avdist)
                {
                    avdist = flen;
                    self.avoid = foe;
                }
            }
            foe = find(foe, classname, "missile");
        }
        if (!self.avoid)
        {
            foe = find(world, classname, "spike");
            while(foe)
            {
                if (foe.owner != self)
                {
                    flen = vlen(foe.origin - self.origin);
                    if (flen < avdist)
                    {
                        avdist = flen;
                        self.avoid = foe;
                    }
                }
                foe = find(foe, classname, "spike");
            }
        }
    }
*/
    if (coop)
    {
        if (!self.enemy)
        {
            foe = findradius(self.origin, 9999);
            while(foe)
            {
                if(foe.flags & FL_MONSTER)
                {
                    if(foe.health > 0)
                    {
                        if (!Ally_Check (foe, self))  // PM:  Drake alignment check.
                        {
                            tsz = bot_size_player(foe) + vlen(foe.origin - self.origin) * 0.5;
                            if (tsz < foesz)
                            {
                                if (fisible(foe))
                                {
                                    self.enemy = foe;
                                    foesz = tsz;
                                }
                            }
                        }
                    }
                }
                foe = foe.chain;
            }
        }        
    }
    else
    {
        foe = player_head;
        while(foe)
        {
            if(foe != self)
            {
                if (foe.modelindex != 0)
                {
                    if (foe.health > 0)
                    {
//                        if (!(teamplay && self.team == foe.team))
                        if (!Ally_Check (foe, self))  // PM:  Drake alignment check.
                        {
                            tsz = bot_size_player(foe) + vlen(foe.origin - self.origin) * 0.5;
                            if (tsz < foesz)
                            {
                                if (fov(foe) || foe.b_sound > time || self.b_skill == 3)
                                {
                                    if (fisible(foe))
                                    {
                                        self.enemy = foe;
                                        foesz = tsz;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            foe = foe._next;
        }
    }
};




/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

weapon_range

_x "sweet spot range" - try to maintain this range if possible
_y minimum range bot can be to be effective (rl/gl) (move away)
_z maximum range bot can be to be effective (lg/axe) (move in)
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

vector(float wep) weapon_range =
{
// PM:  Drake's weapon system.
// PM:  So far, weapon_range called on behalf of self.
    if (self.form_active)
        return '180 0 512';

    if (wep & WARx_USES_SHELLS)
    {
        if (self.tome_finished)
            return '128 48 2000';   // Explosive shells with ToP.
        else
            return '128 0 2000';    // Bullets have max range of 2048, not 99999.
    }
    if (wep & WARx_USES_NAILS)
        return '180 0 3000';
    if (wep & WARx_USES_ROCKETS)
    {
        if (wep == WAR_CRUISE_MISSILE)
            return '180 64 3000';
//        if (wep == WAR_RAILGUN)
//            return '180 0 3000';
        return '180 48 3000';
    }
    if (wep & WARx_USES_CELLS)
    {
        if (wep == WAR_MJOLNIR)
        {
// FIXME:  Make sure z is fixed once I restrict throwing.
            if (self.ammo_cells >= COST_MJOLNIR)
                return '128 48 3000';   // Slam was z=320.  Now it's thrown.
            return '16 0 32';
        }
        if (wep & WARx_SHAFT)
            return '350 0 512';
        if (wep == WAR_PLASMA_GUN)
            return '180 48 3000';
        return '180 0 3000';    // Assume laser guns.
    }
    if (wep == WAR_BURIZA)
        return '180 0 3000';
    if (wep == WAR_ZAPPER)
    {
        if (self.tome_finished)
            return '128 0 2000';    // More range and totally safe.
        return '128 48 600';    // Full charge fires explosive shot.
    }
/* Old code below ---------------------
    if (wep == 4096) // IT_AXE
        return '48 0 64';
    else if (wep == 1) // IT_SHOTGUN
        return '128 0 99999';
    else if (wep == 2) // IT_SUPER_SHOTGUN
        return '128 0 99999';
    else if (wep == 4) // IT_NAILGUN
        return '180 0 3000';
    else if (wep == 8) // IT_SUPER_NAILGUN
        return '180 0 3000';
    else if (wep == 16) // IT_GRENADE_LAUNCHER
        return '180 48 3000';
    else if (wep == 32) // IT_ROCKET_LAUNCHER
        return '180 48 3000';
    else if (wep == 64) // IT_LIGHTNING
        return '350 0 512';
*/
    return '48 0 64';
};
/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

bot_weapon_switch

Pick a weapon based on range / ammo

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

void(float brange) bot_weapon_switch =
{
    local   float   it, flag, pulse;
    local   vector  v;

// PM:  Drake's weapon system.
//    if (self.form_active)
//        return;     // Switching weapons has no effect while morphed.
// Update:  Switch weapons anyway since it affects when to morph.

    it = self.arsenal & legalized;  //self.items & 127;

    pulse = 0;  // PM:  In case pulse isn't set later.
    while(it)
    {
// PM:  Weapons that can be toggled with an impulse should have a separate
// impulse to allow direct selection of the alternate weapon.  However,
// weapons that share an impulse where only the strongest is chosen, may
// use the same impulse, but make sure weaker weapons cannot be chosen.
//
// Note:  Old 1-8 impulses may toggle through multiple weapons.
// Use 21-28 for classic weapons, and 29-50 for more custom weapons.
        if ((self.ammo_super >= 1) && (it & WAR_BURIZA))
            {flag = WAR_BURIZA;  pulse = 48;}
        else if ((self.ammo_cells >= COST_MJOLNIR) && (it & WAR_MJOLNIR))
            {flag = WAR_MJOLNIR;  pulse = 31;}
        else if ((self.ammo_rockets >= COST_MIRV) && (it & WAR_CRUISE_MISSILE))
            {flag = WAR_CRUISE_MISSILE;  pulse = 37;}
        else if ((self.ammo_rockets >= 1) && (it & WAR_ROCKET_LAUNCHER))
            {flag = WAR_ROCKET_LAUNCHER;  pulse = 27;}
        else if ((self.ammo_rockets >= 1) && (it & WAR_SIDEWINDER))
            {flag = WAR_SIDEWINDER;  pulse = 36;}
        else if ((self.ammo_cells >= 1) && (it & WAR_LASER_CANNON))
            {flag = WAR_LASER_CANNON;  pulse = 35;}
        else if ((self.waterlevel > 1) && (self.ammo_cells >= 1) &&
        (it & WAR_CHAIN_LIGHTNING))
            {flag = WAR_CHAIN_LIGHTNING;  pulse = 28;}
        else if ((self.waterlevel > 1) && (self.ammo_cells >= 1) &&
        (it & WAR_THUNDERBOLT))
            {flag = WAR_THUNDERBOLT;  pulse = 28;}
        else if ((self.waterlevel > 1) && (self.ammo_cells >= 1) &&
        (it & WAR_PLASMA_GUN))
            {flag = WAR_PLASMA_GUN;  pulse = 38;}
        else if ((self.ammo_nails >= 1) && (it & WAR_SUPER_NAILGUN))
            {flag = WAR_SUPER_NAILGUN;  pulse = 25;}
        else if ((self.ammo_rockets >= 1) && (it & WAR_GRENADE_LAUNCHER))
            {flag = WAR_GRENADE_LAUNCHER;  pulse = 26;}
        else if ((self.ammo_cells >= 1) && (it & WAR_BLASTER))
            {flag = WAR_BLASTER;  pulse = 35;}
        else if ((self.ammo_shells >= 1) && (it & WAR_SUPER_SHOTGUN))
            {flag = WAR_SUPER_SHOTGUN;  pulse = 23;}
        else if ((self.ammo_nails >= 1) && (it & WAR_NAILGUN))
            {flag = WAR_NAILGUN;  pulse = 24;}
        else if ((self.ammo_shells >= 1) && (it & WAR_SHOTGUN))
            {flag = WAR_SHOTGUN;  pulse = 22;}
        else if (it & WAR_ZAPPER)
            {flag = WAR_ZAPPER;  pulse = 32;}
/* Old code below ---------------------
        if ((self.ammo_rockets >= 1) && (it & 32))
        {
            flag = 32;
            pulse = 7;
        }
        else if (self.waterlevel <= 1 && self.ammo_cells >= 1 && (it & 64))
        {
            flag = 64;
            pulse = 8;
        }
        else if(self.ammo_nails >= 2 && (it & 8))
        {
            flag = 8;
            pulse = 5;
        }
        else if ((self.ammo_rockets >= 1) && (it & 16))
        {
            flag = 16;
            pulse = 6;
        }
        else if(self.ammo_shells >= 2 && (it & 2))
        {
            flag = 2;
            pulse = 3;
        }
        else if(self.ammo_nails >= 1 && (it & 4))
        {
            flag = 4;
            pulse = 4;
        }
        else if(self.ammo_shells >= 1 && (it & 1))
        {
            flag = 1;
            pulse = 2;
        }
*/
        else
        {
            if (pulse)
                self.impulse = pulse;
            return;
        }

//- - - - - - - - -
// PM:  Some impulses toggle weapons, so disable impulse if weapon is
// the same.  This will prevent an accidental switch to a weaker weapon.
        if (flag == self.war)
            pulse = 0;
//- - - - - - - - -
        if (brange == -1)
        {
            if (pulse)
                self.impulse = pulse;
            return;
        }

        v = weapon_range(flag);
        if (brange < v_y || brange > v_z)
            it = it - flag;
        else
        {
            if (pulse)
                self.impulse = pulse;
            return;
        }
    }
};

void() bot_shoot = 
{
    // quick little function to stop making him shoot the wrong way ! Argh
    local float g;
    g = angcomp(self.v_angle_x, self.b_angle_x);
    if (fabs(g) > 30)
        return; // argh, too far away
    g = angcomp(self.v_angle_y, self.b_angle_y);
    if (fabs(g) > 30)
        return; // not again!
    self.button0 = TRUE;
};

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Bot_fight_style

This is the core of the bot's thinking when
attacking an enemy. 

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

void() bot_fight_style =
{
    local vector v, v1, v2, org;
    local float foedist, mysz, foesz;


    if (self.enemy.health <= 0)
    {
        self.enemy = world;
        return;
    }
    else if (!self.enemy.takedamage)
    {
        self.enemy = world;
        return;
    }
    else if (!fisible(self.enemy))
    {
        self.enemy = world;
        return;
    }

    org = realorigin(self.enemy);
    makevectors(self.v_angle);

    // decide if I should shoot

    foedist = vlen(org - self.origin);
    v = weapon_range(self.war);     // PM:  Drake replaces weapon with war.
    if (foedist > v_y && foedist < v_z)
    {
        traceline(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * v_z, FALSE, self);
        if (vlen(trace_endpos - (self.origin + self.view_ofs)) >= v_y)
        {
            // try to avoid shooting teammates
//            if (trace_ent.classname == "player")
//                if ((trace_ent.team == self.team && teamplay) || (coop))
//                    return;
// PM:  Drake's alignment stuff.
            if (Ally_Check (trace_ent, self))
                return;
            bot_shoot();
        }
    }
    else
        bot_weapon_switch(foedist);

    if (!(self.b_aiflags & (AI_PRECISION | AI_BLIND | AI_OBSTRUCTED)))
    {
        foesz = bot_size_player(self.enemy);
        mysz = bot_size_player(self) + 5;

        if (foesz > mysz)
        {
            if (teamplay)
            {
                if (random() < 0.02)
                {
                    bot_start_topic(5);
                    self.b_chattime = 1;
                }
            }
            
            return;
        }
        else if (mysz < 140)
            return;
        else if (self.avoid)
        {
            if (self.avoid.velocity)
                v = self.avoid.velocity;
            else
                v = normalize(self.avoid.origin - self.origin);
            v1_x = v_y * -1;
            v1_y = v_x;
            v2_x = v_y;
            v2_y = v_x * -1;
            foedist = vlen(self.avoid.origin - (self.origin + v1));
            if (foedist < vlen(self.avoid.origin - (self.origin + v2)))
                frik_walkmove(v2);
            else
                frik_walkmove(v1);
        }
        else if (!self.enemy.flags & FL_MONSTER)
        {
            if (foedist + 32 <  v_x)
                frik_walkmove(self.origin - org);
            else if (foedist - 32 >  v_x)
                frik_walkmove(org - self.origin);
            else if (self.wallhug)
                frik_walkmove(v_right);
            else
                frik_walkmove(v_right * -1);
        }
    }
    else
    {
        foesz = bot_size_player(self.enemy);
        mysz = bot_size_player(self) + 5;

        if (foesz > mysz)
            return;
        else if (mysz < 140)
            return;
        self.keys = self.keys & 960;
    }
};


