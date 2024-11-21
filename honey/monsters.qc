

/*
================
monster_use

Using a monster makes it angry at the current activator
================
*/
void() monster_use =
{
	if (self.enemy)
		return;
	if (self.health <= 0)
		return;
	if (activator.items & IT_INVISIBILITY)
		return;
	if (activator.flags & FL_NOTARGET)
		return;
	if (activator.classname != "player")
		return;

// delay reaction so if the monster is teleported, its sound is still
// heard
	self.enemy = activator;
	self.nextthink = time + 0.1;
	self.think = FoundTarget;
};

void() teleport_glitter =
{
	spawn_tdeath(self.origin, self);
	if(self.spawnflags & TRIGGER_SPAWN_TFOG)
	{
		spawn_tfog(self.origin);
	}
};

void() monster_add_to_counter =
{
	if (self.spawnflags & TRIGGER_SPAWN_MULTIPLE){
		if(self.cnt != -1){
				total_monsters = total_monsters + self.cnt + 1;
		}else{
			return;
			//Do nothing, we don't know how many will spawn, so the number will update when they actaully spawn.
		}
	}else{
		total_monsters = total_monsters + 1;
	}

}

/*
================
monster_remove_corpse

================
*/
void() monster_remove_corpse =
{
	//Screw this, just delete it, it's not visible.
	/*
	self.movetype = MOVETYPE_NOCLIP;
	self.velocity = '0 0 -18';
	self.think = SUB_Remove;
	self.nextthink = time + 2;
	*/
	SUB_Remove();
}

/*
================
monster_check_remove_corpse

================
*/
void() monster_check_remove_corpse =
{
	local entity player;
	
	if(!(self.spawnflags & REMOVE_CORPSE)) return;
	
	player = find (world, classname, "player");
	while (player)
	{
		if( canSee(player, self) ) {
			self.think = monster_check_remove_corpse;
			self.nextthink = time + 5;
			return;
		}
		player = find (player, classname, "player");
	}
	
	monster_remove_corpse();
	
	
}

/*
================
monster_death_use

When a monster dies, it fires all of its targets with the current
enemy as activator.
================
*/
void() monster_death_use =
{
	// fall to ground
	if (self.flags & FL_FLY)
		self.flags = self.flags - FL_FLY;
	if (self.flags & FL_SWIM)
		self.flags = self.flags - FL_SWIM;

	if (!self.target && !self.killtarget)
		return;

	activator = self.enemy;
	SUB_UseTargets ();
};


//============================================================================

void() walkmonster_start_go =
{
local string	stemp;

	self.origin_z = self.origin_z + 1;	// raise off floor a bit
	if(self.classname == "monster_tarbaby" && self.spawnflags & TBABY_HIPHOP){
		stemp = stemp;
	}else{
		droptofloor();
	}

	self.takedamage = DAMAGE_AIM;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 20;
	self.view_ofs = '0 0 25';
	self.use = monster_use;

	self.flags = self.flags | FL_MONSTER;

	if (self.target)
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		
/*		if (!self.movetarget)
		{
			dprint ("Monster can't find target (");
			dprint (self.target);
			dprint (") at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
*/
// this used to be an objerror
		if (self.movetarget.classname == "path_corner")
			self.th_walk ();
		else
			self.pausetime = 99999999;
			self.th_stand ();
	}
	else
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}
	if(self.spawnflags & TRIGGER_SPAWN_ANGRY){
		if (activator.items & IT_INVISIBILITY)
			return;
		if (activator.flags & FL_NOTARGET)
			return;
		self.enemy = activator;	
		self.nextthink = time + 0.1;
		self.think = FoundTarget;
	}else{
		self.enemy = world;
	}

};


void() walkmonster_start =
{
	//self.enemy = activator;	
// delay drop to floor to make sure all doors have been spawned
// spread think times so they don't all happen at same time
	self.nextthink = self.nextthink + random()*0.5;
	self.think = walkmonster_start_go;
	if (self.spawnflags & TRIGGER_SPAWN && !intermission_running)
	{
		WriteByte (MSG_ALL, SVC_UPDATESTAT); 
		WriteByte (MSG_ALL, 12); 
		WriteLong (MSG_ALL, total_monsters);
	}
	//InitTether();
};



void() flymonster_start_go =
{
	self.takedamage = DAMAGE_AIM;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;
	self.view_ofs = '0 0 25';
	self.use = monster_use;

	self.flags = self.flags | FL_FLY;
	self.flags = self.flags | FL_MONSTER;

	if (!walkmove(0,0))
	{
		dprint ("flymonster in wall at: ");
		dprint (vtos(self.origin));
		dprint ("\n");
	}

	if (self.target)
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
/*		
		if (!self.movetarget)
		{
			dprint ("Monster can't find target (");
			dprint (self.target);
			dprint (") at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
*/		

// this used to be an objerror
		if (self.movetarget.classname == "path_corner")
			self.th_walk ();
		else
			self.pausetime = 99999999;
			self.th_stand ();
	}
	else
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}
	if(self.spawnflags & TRIGGER_SPAWN_ANGRY){
		if (activator.items & IT_INVISIBILITY)
			return;
		if (activator.flags & FL_NOTARGET)
			return;
	
		//self.enemy = activator;	
		self.nextthink = time + 0.1;
		self.think = FoundTarget;
	}else{
		self.enemy = world;
	}
};

void() flymonster_start =
{
	self.enemy = activator;
// spread think times so they don't all happen at same time
	self.nextthink = self.nextthink + random()*0.5;
	self.think = flymonster_start_go;
	if (self.spawnflags & TRIGGER_SPAWN && !intermission_running)
	{
		WriteByte (MSG_ALL, SVC_UPDATESTAT); 
		WriteByte (MSG_ALL, 12); 
		WriteLong (MSG_ALL, total_monsters);
	}
	//InitTether();
};


void() swimmonster_start_go =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}

	self.takedamage = DAMAGE_AIM;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;
	self.view_ofs = '0 0 10';
	self.use = monster_use;

	self.flags = self.flags | FL_SWIM;
	self.flags = self.flags | FL_MONSTER;

	if (self.target)
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);

/*		if (!self.movetarget)
		{
			dprint ("Monster can't find target (");
			dprint (self.target);
			dprint (") at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
*/
// this used to be an objerror
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		self.th_walk ();
	}
	else
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}

	if(self.spawnflags & TRIGGER_SPAWN_ANGRY){
		if (activator.items & IT_INVISIBILITY)
			return;
		if (activator.flags & FL_NOTARGET)
			return;
	
		//self.enemy = activator;	
		self.nextthink = time + 0.1;
		self.think = FoundTarget;
	}else{
		self.enemy = world;
	}
};

void() swimmonster_start =
{
	self.enemy = activator;	
// spread think times so they don't all happen at same time
	self.nextthink = self.nextthink + random()*0.5;
	self.think = swimmonster_start_go;
	if (self.spawnflags & TRIGGER_SPAWN && !intermission_running)
	{
		WriteByte (MSG_ALL, SVC_UPDATESTAT); 
		WriteByte (MSG_ALL, 12); 
		WriteLong (MSG_ALL, total_monsters);
	}
	//InitTether();
};


