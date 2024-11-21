
entity void_thinker;

void trigger_void_touch()
{
	if(other.classname != "player")
	{
		if(other.flags & FL_MONSTER && other.health > 0)
		{
			dprint("void: killing ");
			dprint(other.classname);
			dprint("\n");
			Killed(other, self);
		}
		dprint("void: removing ");
		dprint(other.classname);
		dprint("\n");

		remove(other);
		return;
	}
	else if(!coop)
	{
		if(other.health > 0)
		{
			float dmg = skill * 4;
			if(dmg > other.health - 1) dmg = other.health - 1;
			if(dmg > 0)
			{
				T_Damage(other, world, self, dmg);
			}
			makevectors (void_thinker.mangle);
			vector org = void_thinker.oldorigin + 32 * v_forward;
		
			spawn_tfog (org);
			spawn_tdeath(void_thinker.oldorigin, other);
		
			setorigin (other, void_thinker.oldorigin);
			other.angles = void_thinker.mangle;
			other.fixangle = 1;		// turn this way immediately
			other.teleport_time = time + 0.7;
			other.velocity = v_forward * 100;
			if(!coop && !deathmatch)
			{
				FogPushSettingsFrom(other, void_thinker.oldenemy, 0);
			}
			other.flags = other.flags - other.flags & FL_ONGROUND;
		}
	}
	else
	{
		dprint("void: killing ");
		dprint(other.classname);
		dprint("\n");
		other.deathtype = "falling";
		Killed(other, self);
	}
}

float trigger_void_trace(vector pos, entity pl)
{
	traceline(pos + '0 0 1', pos + '0 0 -17', TRUE, pl);
	if(trace_fraction < 1.0 && trace_ent == world && trace_plane_normal.z > 0.71) return TRUE;
	return FALSE;
}

void trigger_void_think()
{
	entity pl = find(world, classname, "player");
	if(pl && pl.health > 0)
	{
		if(pl.flags & FL_ONGROUND && pl.groundentity == world)
		{
			vector pos = pl.absmin;
			if(trigger_void_trace(pos, pl))
			{
				pos.x+= pl.size.x;
				if(trigger_void_trace(pos, pl))
				{
					pos.y+= pl.size.y;
					if(trigger_void_trace(pos, pl))
					{
						pos.x-= pl.size.x;
						if(trigger_void_trace(pos, pl))
						{
							self.oldorigin = pl.origin;
							self.mangle = pl.angles;
							self.mangle_z = 0.0;
							self.oldenemy = fog_current;
						}				
					}						
				}
			}
		}
	}
	self.nextthink = time + 2;
}

void trigger_void_thinker_init()
{
	void_thinker.think = trigger_void_think;
	void_thinker.nextthink = time + 1;
	
	// Make sure safe spot is valid from spawn
	entity e = SelectSpawnPoint();
	void_thinker.oldorigin = e.origin;
	void_thinker.mangle = e.angles;
	void_thinker.mangle_z = 0.0;
	entity f = GetFogInfoEntity(e);
	void_thinker.oldenemy = f;
}

void trigger_void()
{
	if(!void_thinker)
	{
		void_thinker = spawn();
		void_thinker.classname = "void_thinker";
		// Defer initializing the thinker, the player spawn might not have spawned yet.
		void_thinker.think = trigger_void_thinker_init; 
		void_thinker.nextthink = time + 0.3;
	}

	self.touch = trigger_void_touch;
	InitTrigger();
}