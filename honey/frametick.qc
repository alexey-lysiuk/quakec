
entity frametick_head;
.entity frametick_next;

.void(float deltaTime) tick;

void RegisterFrameTickEntity(entity ent)
{
    if(!ent.tick)
    {
        entity oself = self;
        self = ent;
        objerror("Registered frame tick entity doesn't have tick function.\n");
        self = oself;
    }
    ent.frametick_next = frametick_head;
    frametick_head = ent;
}

void RemoveFrameTickEntity(entity rem)
{
    if(!rem.tick) return;

    if(rem == frametick_head){
        frametick_head = rem.frametick_next;
        rem.frametick_next = world;
        return;
    }

    entity ent = frametick_head;
    while(ent)
    {
        if(ent.frametick_next == rem)
        {
            ent.frametick_next = rem.frametick_next;
            rem.frametick_next = world;
            return;
        }
        ent = ent.frametick_next;
    }
}

void RunFrameTickEntities(float deltaTime)
{
    entity oself = self;
    entity ent = frametick_head;
    while(ent)
    {
        self = ent;
        ent = self.frametick_next;
        self.tick(deltaTime);
    }
    self = oself;
}
