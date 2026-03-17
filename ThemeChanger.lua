local shared=odh_shared_plugins
local Players=game:GetService("Players")
local LP=Players.LocalPlayer
local section=shared.AddSection("THEME CHANGER")

local function brightness(c)
	return math.clamp(math.max(c.R,c.G,c.B)^0.5,0.55,1)
end

local function isBlackOrWhite(c)
	local maxv=math.max(c.R,c.G,c.B)
	local minv=math.min(c.R,c.G,c.B)
	if maxv<=0.05 or minv>=0.95 then return true end
	return math.abs(c.R-c.G)<0.01 and math.abs(c.G-c.B)<0.01 and math.abs(c.R-c.B)<0.01
end

local function gradientTheme(c,r1,g1,b1,r2,g2,b2)
	local b=brightness(c)
	local t=math.clamp((b-0.55)/0.45,0,1)
	return Color3.new(r1+(r2-r1)*t,g1+(g2-g1)*t,b1+(b2-b1)*t)
end

local THEMES={
	Red={toTheme=function(c)local b=brightness(c)return Color3.new(b,b*0.08,b*0.08)end},
	Crimson={toTheme=function(c)local b=brightness(c)return Color3.new(b,b*0.12,b*0.05)end},
	Orange={toTheme=function(c)local b=brightness(c)return Color3.new(b,b*0.45,b*0.08)end},
	Amber={toTheme=function(c)local b=brightness(c)return Color3.new(b,b*0.65,b*0.15)end},
	Yellow={toTheme=function(c)local b=brightness(c)return Color3.new(b,b*0.85,b*0.12)end},
	Lime={toTheme=function(c)local b=brightness(c)return Color3.new(b*0.25,b,b*0.08)end},
	Green={toTheme=function(c)local b=brightness(c)return Color3.new(b*0.12,b,b*0.18)end},
	Emerald={toTheme=function(c)local b=brightness(c)return Color3.new(b*0.08,b,b*0.35)end},
	Cyan={toTheme=function(c)local b=brightness(c)return Color3.new(b*0.15,b,b*0.9)end},
	Aqua={toTheme=function(c)local b=brightness(c)return Color3.new(b*0.1,b*0.85,b)end},
	Blue={toTheme=function(c)local b=brightness(c)return Color3.new(b*0.08,b*0.12,b)end},
	Indigo={toTheme=function(c)local b=brightness(c)return Color3.new(b*0.25,b*0.08,b*0.95)end},
	Purple={toTheme=function(c)local b=brightness(c)return Color3.new(b*0.55,b*0.12,b)end},
	Magenta={toTheme=function(c)local b=brightness(c)return Color3.new(b,b*0.08,b*0.75)end},
	Pink={toTheme=function(c)local b=brightness(c)return Color3.new(b,b*0.25,b*0.65)end},
	HotPink={toTheme=function(c)local b=brightness(c)return Color3.new(b*0.98,b*0.15,b*0.75)end},
	Sunset={toTheme=function(c)return gradientTheme(c,0.85,0.05,0.05,1.0,0.55,0.05)end},
	Dusk={toTheme=function(c)return gradientTheme(c,0.45,0.02,0.75,1.0,0.20,0.55)end},
	Dawn={toTheme=function(c)return gradientTheme(c,0.95,0.35,0.55,1.0,0.90,0.45)end},
	Ocean={toTheme=function(c)return gradientTheme(c,0.02,0.05,0.55,0.05,0.85,1.0)end},
	DeepSea={toTheme=function(c)return gradientTheme(c,0.01,0.25,0.40,0.05,0.85,0.60)end},
	Aurora={toTheme=function(c)return gradientTheme(c,0.05,0.75,0.35,0.30,0.90,1.0)end},
	NorthernLights={toTheme=function(c)return gradientTheme(c,0.02,0.65,0.75,0.65,0.10,0.95)end},
	Galaxy={toTheme=function(c)return gradientTheme(c,0.30,0.02,0.55,0.10,0.20,1.0)end},
	Nebula={toTheme=function(c)return gradientTheme(c,0.20,0.05,0.80,0.95,0.05,0.65)end},
	Neon={toTheme=function(c)return gradientTheme(c,0.05,1.0,0.20,0.0,0.95,0.85)end},
	NeonPink={toTheme=function(c)return gradientTheme(c,1.0,0.05,0.50,0.70,0.0,1.0)end},
	NeonBlue={toTheme=function(c)return gradientTheme(c,0.05,0.10,0.95,0.10,0.90,1.0)end},
	Lava={toTheme=function(c)return gradientTheme(c,0.60,0.01,0.01,1.0,0.40,0.02)end},
	Volcano={toTheme=function(c)return gradientTheme(c,0.50,0.02,0.02,0.95,0.50,0.05)end},
	Forest={toTheme=function(c)return gradientTheme(c,0.05,0.25,0.05,0.15,0.85,0.15)end},
	Jungle={toTheme=function(c)return gradientTheme(c,0.03,0.35,0.08,0.35,0.95,0.05)end},
	Candy={toTheme=function(c)return gradientTheme(c,0.98,0.45,0.70,0.75,0.35,0.98)end},
	Cotton={toTheme=function(c)return gradientTheme(c,0.98,0.60,0.80,0.55,0.80,0.98)end},
	Peach={toTheme=function(c)return gradientTheme(c,0.98,0.50,0.20,0.98,0.60,0.75)end},
	Mint={toTheme=function(c)return gradientTheme(c,0.35,0.90,0.55,0.40,0.98,0.85)end},
	Lavender={toTheme=function(c)return gradientTheme(c,0.65,0.40,0.90,0.55,0.65,0.98)end},
	Gold={toTheme=function(c)return gradientTheme(c,0.70,0.45,0.02,1.0,0.82,0.10)end},
	Bronze={toTheme=function(c)return gradientTheme(c,0.55,0.28,0.04,0.85,0.55,0.20)end},
	Silver={toTheme=function(c)return gradientTheme(c,0.35,0.38,0.45,0.75,0.80,0.90)end},
	Ice={toTheme=function(c)return gradientTheme(c,0.45,0.75,0.95,0.85,0.95,1.0)end},
	Frost={toTheme=function(c)return gradientTheme(c,0.55,0.80,0.95,0.90,0.98,1.0)end},
	Infrared={toTheme=function(c)return gradientTheme(c,0.40,0.01,0.08,1.0,0.08,0.12)end},
	Ultraviolet={toTheme=function(c)return gradientTheme(c,0.15,0.00,0.35,0.70,0.05,1.0)end},
	Synthwave={toTheme=function(c)return gradientTheme(c,0.25,0.02,0.50,1.0,0.10,0.65)end},
	Retrowave={toTheme=function(c)return gradientTheme(c,0.02,0.04,0.40,0.05,0.85,0.95)end},
	Holographic={toTheme=function(c)return gradientTheme(c,0.20,0.85,0.95,0.98,0.30,0.85)end},
	Sakura={toTheme=function(c)return gradientTheme(c,0.98,0.55,0.70,1.0,0.82,0.88)end},
	Autumn={toTheme=function(c)return gradientTheme(c,0.55,0.18,0.02,0.95,0.60,0.05)end},
	Coffee={toTheme=function(c)return gradientTheme(c,0.30,0.12,0.02,0.72,0.42,0.15)end},
	Poison={toTheme=function(c)return gradientTheme(c,0.25,0.65,0.02,0.75,0.95,0.05)end},
	Blood={toTheme=function(c)return gradientTheme(c,0.35,0.00,0.00,0.90,0.05,0.05)end},
	Amethyst={toTheme=function(c)return gradientTheme(c,0.35,0.05,0.55,0.75,0.20,0.98)end},
	Sapphire={toTheme=function(c)return gradientTheme(c,0.04,0.04,0.45,0.10,0.25,0.90)end},
	Ruby={toTheme=function(c)return gradientTheme(c,0.45,0.01,0.12,0.95,0.05,0.20)end},
	Topaz={toTheme=function(c)return gradientTheme(c,0.80,0.50,0.02,1.0,0.80,0.15)end},
	Jade={toTheme=function(c)return gradientTheme(c,0.02,0.35,0.22,0.08,0.80,0.45)end},
	Rose={toTheme=function(c)return gradientTheme(c,0.70,0.05,0.28,0.98,0.40,0.55)end},
}

local function hsvToRgb(h,s,v)
	local i=math.floor(h*6)local f=h*6-i local p=v*(1-s)local q=v*(1-f*s)local t2=v*(1-(1-f)*s)
	local r,g,b local m=i%6
	if m==0 then r,g,b=v,t2,p elseif m==1 then r,g,b=q,v,p elseif m==2 then r,g,b=p,v,t2 elseif m==3 then r,g,b=p,q,v elseif m==4 then r,g,b=t2,p,v else r,g,b=v,p,q end
	return r,g,b
end

local function makeAnimated(period,keypoints)
	return{animated=true,period=period,toTheme=function(c,animT)
		local b=brightness(c)local n=#keypoints
		local pos=(animT%period)/period*n
		local idx=math.floor(pos)local frac=pos-idx
		local k1=keypoints[(idx%n)+1]local k2=keypoints[((idx+1)%n)+1]
		return Color3.new((k1[1]+(k2[1]-k1[1])*frac)*b,(k1[2]+(k2[2]-k1[2])*frac)*b,(k1[3]+(k2[3]-k1[3])*frac)*b)
	end}
end

local function makeRainbow(period,sat,val)
	return{animated=true,period=period,toTheme=function(c,animT)
		local b=brightness(c)local r,g,bv=hsvToRgb((animT%period)/period,sat,val)
		return Color3.new(r*b,g*b,bv*b)
	end}
end

local ANIMATED_THEMES={
	Rainbow=makeRainbow(4,1,1),
	RainbowSoft=makeRainbow(5,0.55,1),
	RainbowFast=makeRainbow(1.5,1,1),
	FireCycle=makeAnimated(5,{{1,0.05,0.02},{1,0.45,0.02},{1,0.85,0.05},{1,0.45,0.02}}),
	OceanCycle=makeAnimated(6,{{0.05,0.08,0.80},{0.05,0.90,1.0},{0.05,0.75,0.55},{0.05,0.08,0.80}}),
	AuroraCycle=makeAnimated(8,{{0.05,0.85,0.30},{0.10,0.90,1.0},{0.60,0.10,0.95},{0.95,0.15,0.70},{0.05,0.85,0.30}}),
	NeonCycle=makeAnimated(4,{{1.0,0.05,0.55},{0.05,0.95,1.0},{0.10,1.0,0.20},{0.70,0.05,1.0}}),
	SunriseCycle=makeAnimated(7,{{0.30,0.02,0.50},{0.85,0.05,0.10},{1.0,0.40,0.05},{1.0,0.85,0.10}}),
	GalaxyCycle=makeAnimated(6,{{0.05,0.08,0.70},{0.45,0.05,0.90},{0.95,0.05,0.70},{0.20,0.05,0.85}}),
	PastelCycle=makeAnimated(6,{{0.98,0.55,0.72},{0.70,0.50,0.98},{0.45,0.95,0.75},{0.98,0.72,0.50}}),
	IceFire=makeAnimated(5,{{0.20,0.55,1.0},{0.75,0.90,1.0},{1.0,0.08,0.05},{1.0,0.50,0.05}}),
	PulseRed=makeAnimated(2,{{0.35,0.02,0.02},{1.0,0.08,0.08},{0.35,0.02,0.02}}),
	PulseCyan=makeAnimated(2,{{0.02,0.35,0.45},{0.05,1.0,0.95},{0.02,0.35,0.45}}),
	PurpleGold=makeAnimated(4,{{0.55,0.05,0.95},{0.80,0.55,0.05},{0.55,0.05,0.95}}),
}

for k,v in pairs(ANIMATED_THEMES)do THEMES[k]=v end

local selectedTheme="Red"
local appliedTheme=nil
local themeEnabled=false
local animRunning=false
local animThread=nil

local baseColor=setmetatable({},{__mode="k"})
local baseGradient=setmetatable({},{__mode="k"})
local currentColors={}

local transitionStart=0
local transitionDuration=0.45

local VALID_ROOT={["\009\001"]=true,Maximize=true,["@notificationcontainer.elia"]=true,["@ripple.elia"]=true,["привязываемая кнопка"]=true,["@bubbles.elia"]=true,["застрелить убийцу"]=true,["информация о сервере"]=true}
local SELF={Maximize=false}

local function lerpColor(c1,c2,t)
	return Color3.new(c1.R+(c2.R-c1.R)*t,c1.G+(c2.G-c1.G)*t,c1.B+(c2.B-c1.B)*t)
end

local function applyAll(theme,animT,forceInstant)
	local t=forceInstant and 1 or math.clamp((os.clock()-transitionStart)/transitionDuration,0,1)
	
	for o,base in pairs(baseColor)do
		if o and o.Parent and not isBlackOrWhite(base)then
			local target=theme.toTheme(base,animT or 0)
			local current=currentColors[o] or base
			local newColor=(t>=1)and target or lerpColor(current,target,t)
			o.BackgroundColor3=newColor
			if t>=1 then currentColors[o]=target end
		end
	end
	
	for g,src in pairs(baseGradient)do
		if g and g.Parent and src and src.Keypoints then
			local keys={}
			for _,kp in ipairs(src.Keypoints)do
				local baseC=kp.Value
				if isBlackOrWhite(baseC)then
					table.insert(keys,ColorSequenceKeypoint.new(kp.Time,baseC))
				else
					local target=theme.toTheme(baseC,animT or 0)
					local current=currentColors[g]and currentColors[g][kp.Time]or baseC
					local newC=(t>=1)and target or lerpColor(current,target,t)
					table.insert(keys,ColorSequenceKeypoint.new(kp.Time,newC))
					if t>=1 then
						if not currentColors[g]then currentColors[g]={}end
						currentColors[g][kp.Time]=newC
					end
				end
			end
			g.Color=ColorSequence.new(keys)
		end
	end
end

local function stopAnimLoop()
	animRunning=false
	if animThread then
		task.cancel(animThread)
		animThread=nil
	end
end

local function startAnimLoop(theme)
	stopAnimLoop()
	animRunning=true
	animThread=task.spawn(function()
		while animRunning do
			applyAll(theme,os.clock())
			task.wait(0.016)
		end
	end)
end

local function watch(obj)
	if obj:IsA("GuiObject")then
		if not baseColor[obj]then baseColor[obj]=obj.BackgroundColor3 end
	elseif obj:IsA("UIGradient")then
		if not baseGradient[obj]then baseGradient[obj]=obj.Color end
	end
end

local function processRoot(root)
	if SELF[root.Name]~=false then watch(root)end
	for _,d in ipairs(root:GetDescendants())do watch(d)end
	root.DescendantAdded:Connect(watch)
end

local function scan(service)
	for _,obj in ipairs(service:GetDescendants())do
		if VALID_ROOT[obj.Name]then processRoot(obj)end
	end
end

scan(game.CoreGui)
scan(LP:WaitForChild("PlayerGui"))

local themeNames={
	"Red","Crimson","Orange","Amber","Yellow","Lime","Green","Emerald",
	"Cyan","Aqua","Blue","Indigo","Purple","Magenta","Pink","HotPink",
	"Sunset","Dusk","Dawn","Ocean","DeepSea","Aurora","NorthernLights",
	"Galaxy","Nebula","Neon","NeonPink","NeonBlue","Lava","Volcano",
	"Forest","Jungle","Candy","Cotton","Peach","Mint","Lavender",
	"Gold","Bronze","Silver","Ice","Frost","Infrared","Ultraviolet",
	"Synthwave","Retrowave","Holographic","Sakura","Autumn","Coffee",
	"Poison","Blood","Amethyst","Sapphire","Ruby","Topaz","Jade","Rose",
	"Rainbow","RainbowSoft","RainbowFast","FireCycle","OceanCycle",
	"AuroraCycle","NeonCycle","SunriseCycle","GalaxyCycle","PastelCycle",
	"IceFire","PulseRed","PulseCyan","PurpleGold",
}

section:AddDropdown("Theme",themeNames,function(v)selectedTheme=v end)

section:AddButton("Apply Theme",function()
	stopAnimLoop()
	appliedTheme=selectedTheme
	themeEnabled=true
	local theme=THEMES[appliedTheme]
	transitionStart=os.clock()
	
	if theme and theme.animated then
		startAnimLoop(theme)
	else
		task.spawn(function()
			local startTime=os.clock()
			repeat
				applyAll(theme)
				task.wait(0.016)
			until (os.clock()-startTime)>=transitionDuration+0.05
			applyAll(theme,0,true)
		end)
	end
end)

section:AddButton("Apply Default Theme",function()
	stopAnimLoop()
	themeEnabled=false
	appliedTheme=nil
	transitionStart=0
	
	for o,c in pairs(baseColor)do
		if o and o.Parent then 
			o.BackgroundColor3=c 
			currentColors[o]=nil
		end
	end
	for g,seq in pairs(baseGradient)do
		if g and g.Parent then 
			g.Color=seq 
		end
	end
end)
