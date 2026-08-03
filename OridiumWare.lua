-- [[ ORIDIUM WARE ]] --

local UserInputService  = game:GetService("UserInputService")
local Players           = game:GetService("Players")
local Lighting          = game:GetService("Lighting")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local TeleportService   = game:GetService("TeleportService")
local HttpService       = game:GetService("HttpService")
local lp                = Players.LocalPlayer

print("--- [ Oridium Ware Init ] ---")
print("User: "..lp.Name.." | ID: "..tostring(lp.UserId))
print("------------------------------")

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
   Name            = "Oridium Ware",
   LoadingTitle    = "Oridium Ware",
   LoadingSubtitle = "",
   Theme           = "Blue",
   ConfigurationSaving = { Enabled = false },
   KeySystem       = false,
})

task.wait(1)

local MainTab     = Window:CreateTab("Main Tab",       nil)
local MovementTab = Window:CreateTab("Movement",       nil)
local LightingTab = Window:CreateTab("Lighting & Map", nil)
local PshadeTab   = Window:CreateTab("Pshades Shader", nil)

-- ============================================================
-- UTILITIES
-- ============================================================

local function notify(t,c,d) Rayfield:Notify({Title=t,Content=c,Duration=d or 3}) end
local function safeDestroy(o) if o and o.Parent then pcall(function() o:Destroy() end) end end
local function cleanupByName(p,n)
   if not p then return end
   for _,v in ipairs(p:GetChildren()) do if v.Name==n then safeDestroy(v) end end
end
local function getChar()  return lp.Character end
local function getHRP()   local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()   local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function isR6()     local c=getChar() return c and not c:FindFirstChild("UpperTorso") end
local function setVelocity(hrp,vel)
   local ok=pcall(function() hrp.AssemblyLinearVelocity=vel end)
   if not ok then pcall(function() hrp.Velocity=vel end) end
end

-- Cyan / blue palette for custom UI
local P = {
   bg         = Color3.fromRGB(6,  14, 22),
   bgLight    = Color3.fromRGB(10, 22, 34),
   bgMid      = Color3.fromRGB(12, 28, 42),
   stroke     = Color3.fromRGB(20, 140, 200),
   accent     = Color3.fromRGB(0, 200, 255),
   accentSoft = Color3.fromRGB(0, 150, 210),
   text       = Color3.fromRGB(180, 230, 255),
   dim        = Color3.fromRGB(80, 140, 170),
   on         = Color3.fromRGB(0, 200, 255),
   off        = Color3.fromRGB(20, 50, 70),
   white      = Color3.fromRGB(230, 245, 255),
}

local function makeDraggable(f)
   local drag,ds,sp
   f.InputBegan:Connect(function(i)
       if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
           drag=true ds=i.Position sp=f.Position
           i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end)
       end
   end)
   UserInputService.InputChanged:Connect(function(i)
       if not drag then return end
       if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
           local d=i.Position-ds
           f.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
       end
   end)
end

local function makePill(parent,w,h,pos)
   local outer=Instance.new("Frame",parent)
   outer.Size=UDim2.new(0,w,0,h) outer.Position=pos
   outer.BackgroundColor3=P.bg outer.BackgroundTransparency=0 outer.BorderSizePixel=0 outer.Active=true
   Instance.new("UICorner",outer).CornerRadius=UDim.new(0,h)
   local stroke=Instance.new("UIStroke",outer) stroke.Color=P.accent stroke.Thickness=1 stroke.Transparency=0.45
   local shine=Instance.new("Frame",outer) shine.Size=UDim2.new(0.85,0,0,1) shine.Position=UDim2.new(0.075,0,0,2) shine.BackgroundColor3=P.accent shine.BackgroundTransparency=0.72 shine.BorderSizePixel=0
   Instance.new("UICorner",shine).CornerRadius=UDim.new(1,0)
   return outer,stroke
end

local function makePillLabel(parent,text,size,col,xAlign,pos,sz)
   local l=Instance.new("TextLabel",parent)
   l.Size=sz or UDim2.new(1,0,1,0) if pos then l.Position=pos end
   l.BackgroundTransparency=1 l.Text=text l.TextSize=size
   l.TextColor3=col l.Font=Enum.Font.GothamBold l.TextXAlignment=xAlign or Enum.TextXAlignment.Center
   return l
end

local function makeLabel(parent,text,size,col,xAlign,pos,sz) return makePillLabel(parent,text,size,col,xAlign,pos,sz) end

local function makeCard(sg,w,h)
   local card=Instance.new("Frame",sg)
   card.Size=UDim2.new(0,w,0,h) card.Position=UDim2.new(0.5,-w/2,0.5,-h/2)
   card.BackgroundColor3=P.bg card.BackgroundTransparency=0 card.BorderSizePixel=0 card.Active=true
   Instance.new("UICorner",card).CornerRadius=UDim.new(0,16)
   local cs=Instance.new("UIStroke",card) cs.Color=P.accent cs.Thickness=1 cs.Transparency=0.35
   local tg=Instance.new("Frame",card) tg.Size=UDim2.new(0.6,0,0,1) tg.Position=UDim2.new(0.2,0,0,0) tg.BackgroundColor3=P.accent tg.BackgroundTransparency=0.5 tg.BorderSizePixel=0
   Instance.new("UICorner",tg).CornerRadius=UDim.new(1,0)
   makeDraggable(card) return card
end

local function makeCardHeader(card,title,onClose)
   local bar=Instance.new("Frame",card) bar.Size=UDim2.new(1,0,0,40) bar.BackgroundColor3=P.bgMid bar.BorderSizePixel=0
   Instance.new("UICorner",bar).CornerRadius=UDim.new(0,16)
   local bf=Instance.new("Frame",bar) bf.Size=UDim2.new(1,0,0.5,0) bf.Position=UDim2.new(0,0,0.5,0) bf.BackgroundColor3=P.bgMid bf.BorderSizePixel=0
   local ab=Instance.new("Frame",bar) ab.Size=UDim2.new(0,3,0.55,0) ab.Position=UDim2.new(0,10,0.225,0) ab.BackgroundColor3=P.accent ab.BorderSizePixel=0
   Instance.new("UICorner",ab).CornerRadius=UDim.new(1,0)
   local tLbl=Instance.new("TextLabel",bar) tLbl.Size=UDim2.new(1,-50,1,0) tLbl.Position=UDim2.new(0,20,0,0) tLbl.BackgroundTransparency=1 tLbl.Text=title tLbl.TextColor3=P.white tLbl.TextSize=12 tLbl.Font=Enum.Font.GothamBold tLbl.TextXAlignment=Enum.TextXAlignment.Left
   local xBtn=Instance.new("TextButton",bar) xBtn.Size=UDim2.new(0,24,0,24) xBtn.Position=UDim2.new(1,-30,0.5,-12) xBtn.BackgroundColor3=P.accentSoft xBtn.BorderSizePixel=0 xBtn.Text="×" xBtn.TextColor3=P.white xBtn.TextSize=16 xBtn.Font=Enum.Font.GothamBold
   Instance.new("UICorner",xBtn).CornerRadius=UDim.new(1,0) xBtn.MouseButton1Click:Connect(onClose) return bar
end

local function makeScroll(parent,pos,size)
   local scroll=Instance.new("ScrollingFrame",parent) scroll.Size=size scroll.Position=pos scroll.BackgroundTransparency=1 scroll.BorderSizePixel=0
   scroll.ScrollBarThickness=2 scroll.ScrollBarImageColor3=P.accentSoft scroll.CanvasSize=UDim2.new(0,0,0,0) scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
   local ll=Instance.new("UIListLayout",scroll) ll.SortOrder=Enum.SortOrder.LayoutOrder ll.Padding=UDim.new(0,5)
   local pad=Instance.new("UIPadding",scroll) pad.PaddingLeft=UDim.new(0,6) pad.PaddingRight=UDim.new(0,6) pad.PaddingTop=UDim.new(0,6)
   return scroll
end

-- True only for world Parts (not characters / entities)
local function isWorldPart(inst)
   if not inst or not inst:IsA("BasePart") then return false end
   local model = inst:FindFirstAncestorOfClass("Model")
   if model then
      if model:FindFirstChildOfClass("Humanoid") then return false end
      if Players:GetPlayerFromCharacter(model) then return false end
   end
   return true
end

-- ============================================================
-- MAIN TAB
-- ============================================================

local deathAuraActive=false
MainTab:CreateButton({Name="Death Aura",Callback=function()
   local char=getChar() local torso=char and char:FindFirstChild("Torso")
   if not torso or not isR6() then notify("Error","R6 required.",3) return end
   if deathAuraActive then cleanupByName(torso,"VxvFog") deathAuraActive=false notify("Removed","Death Aura off.",3) return end
   cleanupByName(torso,"VxvFog")
   local s=Instance.new("ParticleEmitter") s.Name="VxvFog" s.Texture="rbxassetid://258128463"
   s.Color=ColorSequence.new(Color3.fromRGB(70,0,0))
   s.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0.5),NumberSequenceKeypoint.new(1,1)})
   s.Size=NumberSequence.new(2,5) s.Lifetime=NumberRange.new(0.7,1.2) s.Rate=18
   s.Speed=NumberRange.new(0) s.Rotation=NumberRange.new(0,360) s.Acceleration=Vector3.new(0,1.2,0) s.Parent=torso
   deathAuraActive=true notify("Applied","Death Aura ON. Tap again to remove.",3)
end})

MainTab:CreateButton({Name="Headless",Callback=function()
   local char=getChar() local head=char and char:FindFirstChild("Head")
   if not head then notify("Error","Head not found.",3) return end
   for _,v in ipairs(head:GetChildren()) do if v:IsA("SpecialMesh") or v:IsA("Decal") then safeDestroy(v) end end
   local m=Instance.new("SpecialMesh") m.MeshId="rbxassetid://1095708" m.Scale=Vector3.new(0,0,0) m.Parent=head
   notify("Applied","Headless on.",3)
end})

MainTab:CreateButton({Name="Korblox",Callback=function()
   local char=getChar() local rl=char and char:FindFirstChild("Right Leg")
   if not rl or not isR6() then notify("Error","R6 required.",3) return end
   rl.Transparency=1 cleanupByName(rl,"KorbloxPart")
   local kp=Instance.new("Part") kp.Name="KorbloxPart" kp.Size=Vector3.new(1,2,1) kp.CFrame=rl.CFrame kp.CanCollide=false kp.Transparency=0 kp.Parent=rl
   local m=Instance.new("SpecialMesh") m.MeshId="rbxassetid://101851696" m.TextureId="rbxassetid://101851254" m.Scale=Vector3.new(1.05,1.05,1.05) m.Parent=kp
   local w=Instance.new("WeldConstraint") w.Part0=rl w.Part1=kp w.Parent=kp
   notify("Success","Korblox on.",3)
end})

MainTab:CreateButton({Name="Remove Korblox",Callback=function()
   local char=getChar() local rl=char and char:FindFirstChild("Right Leg")
   if rl then cleanupByName(rl,"KorbloxPart") rl.Transparency=0 notify("Removed","Korblox off.",3) end
end})

-- ============================================================
-- MOVEMENT TAB
-- ============================================================

-- ── AUTO EDGE TRIMP (reworked) ────────────────────────────────
-- Only triggers on edge of a world Part (not players/entities).
-- Fixed upward launch: 230 studs.

local edgeActive=false local edgeConn=nil
MovementTab:CreateButton({Name="Auto Edge Trimp",Callback=function()
   if edgeActive then
      edgeActive=false
      if edgeConn then edgeConn:Disconnect() edgeConn=nil end
      notify("Edge Trimp","OFF.",2) return
   end
   edgeActive=true
   local lastTrimp=0
   local COOLDOWN=0.12
   local LAUNCH_UP=230
   local params=RaycastParams.new()

   edgeConn=RunService.Heartbeat:Connect(function()
      if not edgeActive then return end
      local hrp=getHRP() local hum=getHum() local char=getChar()
      if not hrp or not hum or not char then return end
      local state=hum:GetState()
      local inAir=state==Enum.HumanoidStateType.Freefall or state==Enum.HumanoidStateType.Jumping
      if not inAir then lastTrimp=0 return end
      if tick()-lastTrimp<COOLDOWN then return end

      params.FilterDescendantsInstances={char}
      params.FilterType=Enum.RaycastFilterType.Exclude

      local cf=hrp.CFrame local pos=hrp.Position
      local vel=hrp.Velocity
      local hSpeed=Vector3.new(vel.X,0,vel.Z).Magnitude
      local REACH=math.clamp(hSpeed*0.07+2.8, 2.8, 5.2)

      local dirs={
         cf.LookVector,-cf.LookVector,
         cf.RightVector,-cf.RightVector,
         (cf.LookVector+cf.RightVector).Unit,
         (cf.LookVector-cf.RightVector).Unit,
         (-cf.LookVector+cf.RightVector).Unit,
         (-cf.LookVector-cf.RightVector).Unit,
      }
      local offsets={
         Vector3.new(0,1.0,0), Vector3.new(0,0,0),
         Vector3.new(0,-1.3,0), Vector3.new(0,-2.7,0),
      }

      for _,offset in ipairs(offsets) do
         for _,dir in ipairs(dirs) do
            local hit=workspace:Raycast(pos+offset, dir*REACH, params)
            if hit and math.abs(hit.Normal.Y)<0.45 and isWorldPart(hit.Instance) then
               local awayDir=Vector3.new(hit.Normal.X,0,hit.Normal.Z)
               local awayKick=awayDir.Magnitude>0.05 and awayDir.Unit*18 or Vector3.zero
               setVelocity(hrp, Vector3.new(
                  vel.X*1.15 + awayKick.X,
                  LAUNCH_UP,
                  vel.Z*1.15 + awayKick.Z
               ))
               lastTrimp=tick()
               return
            end
         end
      end
   end)
   notify("Edge Trimp","ON — 230 stud launch on part edges only.",3)
end})

-- ── AUTO BOUNCE (higher) ──────────────────────────────────────

local bounceActive=false local bounceConn=nil local bounceHighlight=nil

local function highlightSlopePart(part)
   if bounceHighlight then safeDestroy(bounceHighlight) bounceHighlight=nil end
   if not part or not part.Parent then return end
   local sb=Instance.new("SelectionBox")
   sb.Adornee=part sb.Color3=P.accent
   sb.LineThickness=0.06 sb.SurfaceTransparency=0.65
   sb.SurfaceColor3=P.accent sb.Parent=workspace
   bounceHighlight=sb
   task.delay(0.35,function()
      if bounceHighlight==sb then safeDestroy(sb) bounceHighlight=nil end
   end)
end

MovementTab:CreateButton({Name="Auto Bounce",Callback=function()
   if bounceActive then
      bounceActive=false
      if bounceConn then bounceConn:Disconnect() bounceConn=nil end
      if bounceHighlight then safeDestroy(bounceHighlight) bounceHighlight=nil end
      notify("Auto Bounce","OFF.",2) return
   end
   bounceActive=true
   local lastBounce=0 local COOLDOWN=0.18
   local params=RaycastParams.new()

   bounceConn=RunService.Heartbeat:Connect(function()
      local hrp=getHRP() local hum=getHum() local char=getChar()
      if not hrp or not hum or not char then return end
      local vy=hrp.Velocity.Y
      if vy>-5 then return end
      if tick()-lastBounce<COOLDOWN then return end
      params.FilterDescendantsInstances={char}
      params.FilterType=Enum.RaycastFilterType.Exclude
      local rayLen=math.clamp(math.abs(vy)*0.16+4, 4, 14)
      local hit=workspace:Raycast(hrp.Position, Vector3.new(0,-rayLen,0), params)
      if hit and isWorldPart(hit.Instance) then
         local nY=hit.Normal.Y
         if nY>=0.15 and nY<=0.92 then
            highlightSlopePart(hit.Instance)
            local fallSpd=math.abs(vy)
            local LAUNCH_UP=math.clamp(95+fallSpd*0.95, 95, 200)
            local H_PRESERVE=math.clamp(1.08+fallSpd*0.005, 1.08, 1.35)
            local slopeDir=Vector3.new(hit.Normal.X,0,hit.Normal.Z)
            local slopeBoost=slopeDir.Magnitude>0.08
               and slopeDir.Unit*(fallSpd*0.30)
               or Vector3.zero
            hum.Jump=true
            setVelocity(hrp, Vector3.new(
               hrp.Velocity.X*H_PRESERVE + slopeBoost.X,
               LAUNCH_UP,
               hrp.Velocity.Z*H_PRESERVE + slopeBoost.Z
            ))
            lastBounce=tick()
         end
      end
   end)
   notify("Auto Bounce","ON — higher launch.",3)
end})

-- ── ORIDIUM WALK (wall walk) ──────────────────────────────────
-- Hold W + Space while against a wall → stick and walk on it.

local walkActive=false local walkConn=nil local walkJumpConn=nil
local walkStuck=false local walkNormal=Vector3.zero

MovementTab:CreateButton({Name="Oridium Walk",Callback=function()
   if walkActive then
      walkActive=false walkStuck=false
      if walkConn then walkConn:Disconnect() walkConn=nil end
      if walkJumpConn then walkJumpConn:Disconnect() walkJumpConn=nil end
      notify("Oridium Walk","OFF.",2) return
   end
   walkActive=true walkStuck=false

   local WALL_REACH=3.2
   local params=RaycastParams.new()

   walkConn=RunService.Heartbeat:Connect(function(dt)
      if not walkActive then return end
      local hrp=getHRP() local hum=getHum() local char=getChar()
      if not hrp or not hum or not char then return end

      local wHeld = UserInputService:IsKeyDown(Enum.KeyCode.W)
         or UserInputService:IsKeyDown(Enum.KeyCode.Up)
      local spaceHeld = UserInputService:IsKeyDown(Enum.KeyCode.Space)

      params.FilterDescendantsInstances={char}
      params.FilterType=Enum.RaycastFilterType.Exclude

      local pos=hrp.Position local cf=hrp.CFrame
      local dirs={
         cf.LookVector,-cf.LookVector,
         cf.RightVector,-cf.RightVector,
         (cf.LookVector+cf.RightVector).Unit,
         (cf.LookVector-cf.RightVector).Unit,
         (-cf.LookVector+cf.RightVector).Unit,
         (-cf.LookVector-cf.RightVector).Unit,
      }
      local vOffs={Vector3.new(0,1.0,0), Vector3.new(0,-0.3,0), Vector3.new(0,-1.6,0)}
      local foundNormal=nil
      for _,vo in ipairs(vOffs) do
         if foundNormal then break end
         for _,dir in ipairs(dirs) do
            local hit=workspace:Raycast(pos+vo, dir*WALL_REACH, params)
            if hit and math.abs(hit.Normal.Y)<0.40 and isWorldPart(hit.Instance) then
               foundNormal=hit.Normal break
            end
         end
      end

      if foundNormal and wHeld and spaceHeld then
         walkStuck=true
         walkNormal=foundNormal
         local vel=hrp.Velocity
         local awayDot=vel:Dot(foundNormal)
         local awayComp=foundNormal * math.max(awayDot, 0)
         local gravComp=196 * dt * 0.92
         local climb = 18
         local newVY=math.max(vel.Y + gravComp, climb)
         local stick=(-foundNormal) * 8 * dt
         local look=cf.LookVector
         local along=look - foundNormal * look:Dot(foundNormal)
         if along.Magnitude>0.05 then along=along.Unit*22 else along=Vector3.zero end
         setVelocity(hrp, Vector3.new(
            along.X - awayComp.X + stick.X,
            newVY,
            along.Z - awayComp.Z + stick.Z
         ))
      else
         walkStuck=false
      end
   end)
   notify("Oridium Walk","ON — hold W + Space on a wall to climb.",4)
end})

-- ── ORIDIUM JUMP (bhop / ramp boost) ──────────────────────────

local jumpActive=false
local jumpConns={}
local jumpHolding=false
local jumpAccel=0
local jumpMovementModule=nil
local jumpOriginalFriction=nil

local function jumpCleanup()
   for _,c in ipairs(jumpConns) do pcall(function() c:Disconnect() end) end
   jumpConns={}
   jumpHolding=false
   jumpAccel=0
   if jumpMovementModule and jumpOriginalFriction then
      pcall(function() jumpMovementModule.ApplyFriction=jumpOriginalFriction end)
   end
   jumpMovementModule=nil
   jumpOriginalFriction=nil
end

local function jumpApplyModule()
   if not jumpMovementModule or not jumpOriginalFriction then return end
   jumpMovementModule.ApplyFriction=function(self,friction)
      if jumpHolding and self.a==true then
         local boost=0.02
         local hrp=getHRP() local char=getChar()
         if hrp and char then
            local rp=RaycastParams.new()
            rp.FilterType=Enum.RaycastFilterType.Exclude
            rp.FilterDescendantsInstances={char}
            local ray=workspace:Raycast(hrp.Position,Vector3.new(0,-4,0),rp)
            if ray and isWorldPart(ray.Instance) then
               local angle=math.deg(math.acos(math.clamp(ray.Normal:Dot(Vector3.new(0,1,0)),-1,1)))
               if angle>5 and angle<60 then
                  local rampFactor=math.clamp(angle/60,0,1)
                  boost=boost+(0.16+(0.20-0.16)*rampFactor)
               end
            end
         end
         jumpAccel=math.clamp(jumpAccel+boost,0,0.1)
         local speed=0
         if hrp then speed=(hrp.Velocity*Vector3.new(1,0,1)).Magnitude end
         local smooth=jumpAccel*(speed/55)
         friction=friction-smooth
      else
         jumpAccel=math.clamp(jumpAccel-0.01,0,0.1)
      end
      return jumpOriginalFriction(self,friction)
   end
end

local function jumpWatchModule(char)
   local movement=char:FindFirstChild("Movement") or char:WaitForChild("Movement",3)
   if not movement then return end
   local ok,module=pcall(require,movement)
   if ok and module then
      jumpMovementModule=module
      if not jumpOriginalFriction then
         jumpOriginalFriction=module.ApplyFriction
      end
      jumpApplyModule()
   end
end

local function jumpSetupChar(char)
   local hum=char:WaitForChild("Humanoid",5)
   local root=char:WaitForChild("HumanoidRootPart",5)
   if not hum or not root then return end
   hum.UseJumpPower=true
   if hum.JumpPower<16 then hum.JumpPower=16 end
   jumpWatchModule(char)
end

MovementTab:CreateButton({Name="Oridium Jump",Callback=function()
   if jumpActive then
      jumpActive=false
      jumpCleanup()
      notify("Oridium Jump","OFF.",2)
      return
   end
   jumpActive=true
   jumpHolding=false
   jumpAccel=0

   table.insert(jumpConns, RunService.Heartbeat:Connect(function()
      if not jumpActive then return end
      local hum=getHum()
      if not hum then return end
      if jumpHolding
         and hum.FloorMaterial~=Enum.Material.Air
         and hum:GetState()~=Enum.HumanoidStateType.Dead then
         hum.Jump=true
      end
   end))

   table.insert(jumpConns, UserInputService.JumpRequest:Connect(function()
      if jumpActive then jumpHolding=true end
   end))

   table.insert(jumpConns, UserInputService.InputEnded:Connect(function(input)
      if input.UserInputType==Enum.UserInputType.Touch
         or input.KeyCode==Enum.KeyCode.Space then
         jumpHolding=false
      end
   end))

   table.insert(jumpConns, lp.CharacterAdded:Connect(function(char)
      if jumpActive then
         task.defer(function() jumpSetupChar(char) end)
      end
   end))

   if lp.Character then
      task.spawn(function() jumpSetupChar(lp.Character) end)
   end

   notify("Oridium Jump","ON — hold jump to bhop / ramp boost.",3)
end})

-- ============================================================
-- LIGHTING & MAP TAB
-- ============================================================

local LoadedMap=nil local selectedMapKey=nil
local mapLibrary={
   {label="Sab Map",        id="96439444595951"},
   {label="Large City",     id="7398643673"},
   {label="Gag Map",        id="105019154044298"},
   {label="Sword Fight",    id="360842238"},
   {label="Big Obby",       id="178911019"},
   {label="Parkour Obby",   id="134309960410545"},
   {label="Army Base",      id="100464227932615"},
   {label="Brookhaven Map", id="14985811598"},
   {label="Free Fire",      id="136952494452456"},
}
local mapLoaderGui=nil
LightingTab:CreateButton({Name="Open Map Loader",Callback=function()
   if mapLoaderGui then safeDestroy(mapLoaderGui) mapLoaderGui=nil return end
   local sg=Instance.new("ScreenGui") sg.Name="OwMapLoader" sg.ResetOnSpawn=false sg.IgnoreGuiInset=true sg.DisplayOrder=994 sg.Parent=lp.PlayerGui mapLoaderGui=sg
   local card=makeCard(sg,290,420) makeCardHeader(card,"  Map Loader",function() safeDestroy(sg) mapLoaderGui=nil end)
   local selF,_=makePill(card,268,26,UDim2.new(0.5,-134,0,48)) local selL=makeLabel(selF,"No map selected",9,P.dim)
   local loadF,loadStr=makePill(card,128,30,UDim2.new(0,11,0,82))
   local loadB=Instance.new("TextButton",loadF) loadB.Size=UDim2.new(1,0,1,0) loadB.BackgroundTransparency=1 loadB.Text="▶  Load" loadB.TextColor3=P.text loadB.TextSize=10 loadB.Font=Enum.Font.GothamBold
   local unloadF,_=makePill(card,128,30,UDim2.new(1,-139,0,82))
   local unloadB=Instance.new("TextButton",unloadF) unloadB.Size=UDim2.new(1,0,1,0) unloadB.BackgroundTransparency=1 unloadB.Text="✕  Unload" unloadB.TextColor3=P.dim unloadB.TextSize=10 unloadB.Font=Enum.Font.GothamBold
   loadB.MouseButton1Click:Connect(function()
       if not selectedMapKey then notify("Map Loader","Select a map first.",3) return end
       if LoadedMap then safeDestroy(LoadedMap) LoadedMap=nil end
       local ok,objs=pcall(function() return game:GetObjects("rbxassetid://"..selectedMapKey.id) end)
       if not ok or not objs or not objs[1] then notify("Error","Failed to load.",4) return end
       LoadedMap=objs[1] LoadedMap.Parent=workspace
       for _,p in ipairs(LoadedMap:GetDescendants()) do if p:IsA("BasePart") then p.Anchored=true p.CanCollide=true end end
       notify("Loaded",selectedMapKey.label.." — Anchored.",4) loadStr.Color=P.accent
   end)
   unloadB.MouseButton1Click:Connect(function()
       if LoadedMap then safeDestroy(LoadedMap) LoadedMap=nil notify("Unloaded","Map removed.",3) loadStr.Color=P.stroke
       else notify("No Map","Nothing loaded.",3) end
   end)
   local div=Instance.new("Frame",card) div.Size=UDim2.new(1,-20,0,1) div.Position=UDim2.new(0,10,0,120) div.BackgroundColor3=P.accent div.BackgroundTransparency=0.7 div.BorderSizePixel=0
   local scroll=makeScroll(card,UDim2.new(0,4,0,125),UDim2.new(1,-8,1,-129))
   local selectedRow=nil
   for i,mapDef in ipairs(mapLibrary) do
       local md=mapDef
       local row=Instance.new("Frame",scroll) row.Size=UDim2.new(1,0,0,46) row.BackgroundColor3=P.bgMid row.BorderSizePixel=0 row.LayoutOrder=i
       Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
       local rs=Instance.new("UIStroke",row) rs.Color=P.stroke rs.Thickness=0.8 rs.Transparency=0.65
       local numF=Instance.new("Frame",row) numF.Size=UDim2.new(0,30,0,30) numF.Position=UDim2.new(0,8,0.5,-15) numF.BackgroundColor3=P.accentSoft numF.BorderSizePixel=0
       Instance.new("UICorner",numF).CornerRadius=UDim.new(0,8) makeLabel(numF,tostring(i),11,P.white)
       makeLabel(row,md.label,11,P.text,Enum.TextXAlignment.Left,UDim2.new(0,46,0,5),UDim2.new(1,-56,0,22))
       makeLabel(row,"ID: "..md.id,8,P.dim,Enum.TextXAlignment.Left,UDim2.new(0,46,0,26),UDim2.new(1,-56,0,15))
       local rBtn=Instance.new("TextButton",row) rBtn.Size=UDim2.new(1,0,1,0) rBtn.BackgroundTransparency=1 rBtn.Text=""
       rBtn.MouseButton1Click:Connect(function()
           selectedMapKey=md selL.Text="▸  "..md.label selL.TextColor3=P.accent
           if selectedRow and selectedRow~=row then selectedRow.BackgroundColor3=P.bgMid local ors=selectedRow:FindFirstChildOfClass("UIStroke") if ors then ors.Color=P.stroke ors.Transparency=0.65 end end
           row.BackgroundColor3=Color3.fromRGB(10,40,55) rs.Color=P.accent rs.Transparency=0.1 selectedRow=row
       end)
       row.MouseEnter:Connect(function() if row~=selectedRow then row.BackgroundColor3=Color3.fromRGB(10,32,48) end end)
       row.MouseLeave:Connect(function() if row~=selectedRow then row.BackgroundColor3=P.bgMid end end)
   end
end})

LightingTab:CreateSlider({Name="Model Height",Range={-200,200},Increment=1,Suffix=" Studs",CurrentValue=0,Flag="HeightSlider",Callback=function(v)
   if not LoadedMap then return end
   if LoadedMap:IsA("Model") then local cf=LoadedMap:GetModelCFrame() LoadedMap:MoveTo(Vector3.new(cf.p.X,v,cf.p.Z))
   elseif LoadedMap:IsA("BasePart") then LoadedMap.Position=Vector3.new(LoadedMap.Position.X,v,LoadedMap.Position.Z) end
end})
LightingTab:CreateSlider({Name="Time of Day",Range={0,24},Increment=0.5,Suffix=" hrs",CurrentValue=14,Flag="TimeSlider",Callback=function(v) Lighting.ClockTime=v end})

local skyboxIdInput=""
LightingTab:CreateInput({Name="Skybox Asset ID",PlaceholderText="Enter skybox asset ID...",RemoveTextAfterFocusLost=false,Callback=function(val) skyboxIdInput=val end})
LightingTab:CreateButton({Name="Apply Skybox ID",Callback=function()
   local id=skyboxIdInput:match("^%s*(.-)%s*$")
   if id=="" then notify("Skybox","Enter an asset ID first.",3) return end
   for _,v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
   local sky=Instance.new("Sky",Lighting) local base="rbxassetid://"..id
   sky.SkyboxBk=base sky.SkyboxDn=base sky.SkyboxFt=base sky.SkyboxLf=base sky.SkyboxRt=base sky.SkyboxUp=base
   notify("Skybox Applied","ID: "..id,3)
end})
LightingTab:CreateButton({Name="Remove Skybox",Callback=function()
   local removed=false for _,v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() removed=true end end
   notify("Skybox",removed and "Removed." or "No skybox found.",3)
end})

-- ============================================================
-- PSHADES SHADER TAB
-- Loads PShade Ultimate (external). Own UI opens after load.
-- ============================================================

local pshadeLoaded=false
PshadeTab:CreateButton({Name="Load PShade Ultimate",Callback=function()
   if pshadeLoaded or _G.pshade then
      notify("PShade","Already loaded.",3)
      return
   end
   notify("PShade","Loading…",2)
   task.spawn(function()
      local ok,err=pcall(function()
         loadstring(game:HttpGet("https://raw.githubusercontent.com/randomstring0/pshade-ultimate/refs/heads/main/src/back.json"))()
      end)
      if ok then
         pshadeLoaded=true
         notify("PShade","Loaded. Use its UI to control shaders.",4)
      else
         notify("PShade","Load failed.",4)
         warn("[Oridium] PShade error:", err)
      end
   end)
end})

PshadeTab:CreateParagraph({Title="About",Content="Loads PShade Ultimate by @Im_patrick. Opens its own shader UI after load. Run once per session."})

-- [[ SIGNATURE ]] --
print("--- [ Oridium Ware ] ---")
