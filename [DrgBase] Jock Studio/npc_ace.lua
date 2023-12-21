if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot_sprite" -- DO NOT TOUCH (obviously)

--Вся информация бота!--
ENT.PrintName = "Ace Anderson"
ENT.Category = "Jock Studio"

ENT.ModelScale = 1
ENT.CollisionBounds = Vector(13, 13, 72)
ENT.BloodColor = BLOOD_COLOR_RED

ENT.SpawnHealth = 999999

ENT.WalkSpeed = 520
ENT.RunSpeed = 720

ENT.OnDamageSounds = {}
ENT.OnDeathSounds = {""}
ENT.OnIdleSounds = {""}

ENT.PossessionEnabled = true
ENT.PossessionMovement = POSSESSION_MOVE_1DIR
ENT.PossessionViews = {
 {
 offset = Vector(0, 30, 20),
 distance = 140
 },
 {
 offset = Vector(7.5, 0, 0),
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
   self:PlaySpriteAnimAndWait("attack", 1, self.FaceEnemy)
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
 killicon.Add("ace", "ace/npc_ace_killicon", color_white)
 language.Add("ace", "Ace Anderson")

 local panicMusic = nil
 local MUSIC_CUTOFF_DISTANCE = 8192
 local MUSIC_PANIC_DISTANCE = 4096

 function ENT:Initialize()
     if not panicMusic then
         panicMusic = CreateSound(LocalPlayer(), "npc_ace/panic.mp3")
     end

     panicMusic:Play()
 end

 function ENT:Think()
     if panicMusic and panicMusic:IsPlaying() then
         local distance = LocalPlayer():GetPos():Distance(self:GetPos())
         if distance > MUSIC_CUTOFF_DISTANCE then
             panicMusic:Stop()
         elseif distance > MUSIC_PANIC_DISTANCE then
             panicMusic:ChangeVolume(1 - (distance - MUSIC_PANIC_DISTANCE) / (MUSIC_CUTOFF_DISTANCE - MUSIC_PANIC_DISTANCE), 0)
         else
             panicMusic:ChangeVolume(1, 0)
         end
     end
 end
 
 function ENT:OnRemove()
  if panicMusic and panicMusic:IsPlaying() then
      panicMusic:Stop()
  end
 end
 
 local DRAW_OFFSET = Vector(0, 0, 62) --Ширина и высота спрайта.

 local ace_material = Material("ace/npc_ace.png")
 function ENT:DrawTranslucent()
     render.SetMaterial(ace_material)

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

     render.DrawQuadEasy(pos, normal, 128, 128,
         color_white, 180)
 end
end


function ENT:CustomInitialize()
  self:SetDefaultRelationship(D_HT)
end

function ENT:OnMeleeAttack(enemy)
  self:EmitSound("npc_ace/damage.mp3")
  self:AttackForNpc()
  self:PlaySpriteAnimAndWait("attack", 1, self.FaceEnemy)
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
  self:PlaySpriteAnimAndWait("death", 0.5, self.FaceEnemy)
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