if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot_sprite" -- DO NOT TOUCH (obviously)

--Вся информация бота!--
ENT.PrintName = "Jacques/Жак"
ENT.Category = "Jock Studio"

ENT.ModelScale = 1
ENT.CollisionBounds = Vector(13, 13, 72)
ENT.BloodColor = BLOOD_COLOR_RED

ENT.SpawnHealth = 9999

ENT.WalkSpeed = 520
ENT.RunSpeed = 720

ENT.OnDamageSounds = {}
ENT.OnDeathSounds = {}
ENT.OnIdleSounds = {}

ENT.PossessionEnabled = true 
ENT.PossessionMovement = POSSESSION_MOVE_1DIR
ENT.PossessionViews = {
 {
 offset = Vector(0, 30, 29),
 distance = 140
 },
 {
 offset = Vector(8, 0, 63),
 distance = 0,
 eyepos = true 
 }
}
ENT.MaxYawRate = 200
ENT.PossessionBinds = {
 [IN_ATTACK] = {{
 coroutine = true,
 onkeydown = function(self)
   self:EmitSound("")
   self:AttackForNpc()
   self:PlaySpriteAnimAndWait("attack", 1, self.FjacquesEnemy)
 end
 }},
 [IN_JUMP] = {{
 coroutine = false,
 onkeydown = function(self)
   self:Jump(600)
 end
 }}
}

if CLIENT then
 language.Add("jacques", "jacques/Жак")

 local panicMusic = nil
 local MUSIC_CUTOFF_DISTANCE = 8192
 local MUSIC_PANIC_DISTANCE = 4096
 local number_of_Jacquess = 0  -- Declare and initialize a variable to track the number of jacques NPCs in the game. Be careful when replacing 'jacquess'.

 function ENT:Initialize() -- Уделите 1 час времени для повтора музыки. Я хотел убиться об стенку
  if not panicMusic then
      panicMusic = CreateSound(LocalPlayer(), "npc_jacques/panic.mp3", SND_LOOP)
      panicMusic:Play()
      panicMusic:ChangeVolume(1, 0.1)
  end
  number_of_Jacquess = number_of_Jacquess + 1 -- увеличиваем количество jacques
 end

 function ENT:Think()
     if panicMusic and not panicMusic:IsPlaying() and number_of_Jacquess > 0 then
         panicMusic:Play()
         panicMusic:ChangeVolume(1, 0.1)
     end

     if panicMusic and panicMusic:IsPlaying() then
         local playerPos = LocalPlayer():GetPos()
         local entityPos = self:GetPos()
         local distance = playerPos:Distance(entityPos)

         if distance < MUSIC_CUTOFF_DISTANCE then
             if distance > MUSIC_PANIC_DISTANCE then
                 local volume = 1 - ((distance - MUSIC_PANIC_DISTANCE) / (MUSIC_CUTOFF_DISTANCE - MUSIC_PANIC_DISTANCE))
                 panicMusic:ChangeVolume(volume, 0.1)
             else
                 panicMusic:ChangeVolume(1, 0.1)
             end
         end
     end
 end

 function ENT:OnRemove() -- уменьшение количества jacques и остановка музыки, когда объект удаляется
  number_of_Jacquess = number_of_Jacquess - 1
  if panicMusic and panicMusic:IsPlaying() and number_of_Jacquess == 0 then
      panicMusic:Stop()
      panicMusic = nil
  end
 end
 
 local DRAW_OFFSET = Vector(0, 0, 60.1) --Ширина и высота спрайта. Для Camp Buddy 62 а для Jock Studio 60.1

 local jacques_baby = Material("jacques/npc_jacques_baby.png")
 local jacques_hair = Material("jacques/npc_jacques_hair.png")
 local jacques_face = Material("jacques/npc_jacques_face.png")
 local jacques_glass = Material("jacques/npc_jacques_glass.png")
 local jacques_hand = Material("jacques/npc_jacques_hand.png")

 function ENT:DrawTranslucent()
     render.SetMaterial(jacques_baby)
     local pos = self:GetPos() + DRAW_OFFSET
     local normal = EyePos() - pos
     normal:Normalize()
     local xyNormal = Vector(normal.x, normal.y, 0)
     xyNormal:Normalize()

     local pitch = math.acos(math.Clamp(normal:Dot(xyNormal), -1, 1)) / 3
     local cos = math.cos(pitch)
     normal = Vector(
         xyNormal.x * cos,
         xyNormal.y * cos,
         math.sin(pitch)
     )
     render.DrawQuadEasy(pos, normal, 100, 130, color_white, 180) -- Для Camp Buddy 128 (Оба) а для Jock Studio 100, 130.

     render.SetMaterial(jacques_hair)
     render.DrawQuadEasy(pos, normal, 100, 130, color_white, 180)
     render.SetMaterial(jacques_face)
     render.DrawQuadEasy(pos, normal, 100, 130, color_white, 180)
     render.SetMaterial(jacques_glass)
     render.DrawQuadEasy(pos, normal, 100, 130, color_white, 180)
     render.SetMaterial(jacques_hand)
     render.DrawQuadEasy(pos, normal, 100, 130, color_white, 180)
 end
end

function ENT:CustomInitialize()
  self:SetDefaultRelationship(D_HT) -- Есть варианты D_HT, D_LI, D_NU, D_FR
end

function ENT:OnMeleeAttack(enemy)
  self:EmitSound("npc_jacques/damage.mp3")
  self:AttackForNpc()
  self:PlaySpriteAnimAndWait("attack", 1, self.FjacquesEnemy)
end

function ENT:OnReachedPatrol()
  self:PlaySpriteAnimAndWait("idle")
  self:Wait(math.random(3, 7))
  self:PlaySpriteAnimAndWait("idle")
end

function ENT:OnIdle()
  self:AddPatrolPos(self:RandomPos(1500))
end

function ENT:OnDeath(dmg, delay, hitgroup)
  self:PlaySpriteAnimAndWait("death", 0.5, self.FjacquesEnemy)
end

function ENT:OnNewEnemy() 
  self:EmitSound("")
end

function ENT:AttackForNpc()
  self:Attack({
      damage = 7,
      range = 100,
      type = DMG_SLASH,
      delay = 0,
      radius=600,
      force=Vector(800,100,100),
      viewpunch = Angle(20, math.random(-10, 10), 0),
  }, function(self, hit)
      if #hit > 0 then
          self:EmitSound("Zombie.AttackHit")
      else self:EmitSound("Zombie.AttackMiss") end
  end)
end

AddCSLuaFile()
DrGBase.AddNextbot(ENT)