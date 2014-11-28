local impUF = CreateFrame( "Frame", "ImprovUF", UIParent );

local combatLock = false;

local fadeTime = 0.5;

local classFrame;
local classIcon;
local classIconBorder;
local showClassIcon = true;

-- Player Frame
local pFrameX = -265;
local pFrameY = -150;
local pFrameScale = 1.45;
-- Target Frame
local tFrameX = 265;
local tFrameY = -150;
local tFrameScale = 1.45;
local tFrameHidden = true;

-- Party Frame
local parFrameX = 40;
local parFrameY = 125;
local parFrameScale = 1.6;

-- Focus Frame
local focFrameX = 300;
local focFrameY = -200;
local focFrameScale = 1.25;

-- Timer
local timer = CreateFrame("Frame");
local time = 0;
local delayLength = 1.5;
local startTimer = false;

local function SetUnitFrames()

	-- Hide Damage Spam
	PlayerHitIndicator:SetText(nil)
	PlayerHitIndicator.SetText = function() end

	PetHitIndicator:SetText(nil)
	PetHitIndicator.SetText = function() end

	-- Tweak Party Frame
	PartyMemberFrame1:ClearAllPoints();
	PartyMemberFrame1:SetScale( parFrameScale );
	PartyMemberFrame2:SetScale( parFrameScale );
	PartyMemberFrame3:SetScale( parFrameScale );
	PartyMemberFrame4:SetScale( parFrameScale );
	PartyMemberFrame1:SetPoint( "LEFT" , parFrameX, parFrameY );

	-- Tweak Player Frame
	PlayerFrame:ClearAllPoints();
	PlayerFrame:SetScale( pFrameScale );
	PlayerFrame:SetPoint( "CENTER", pFrameX, pFrameY );
	PlayerFrame:SetUserPlaced(true);

	-- Tweak Target Frame
	TargetFrame:ClearAllPoints();
	TargetFrame:SetScale( tFrameScale );
	TargetFrame:SetPoint( "CENTER", tFrameX, tFrameY );

	-- Tweak Focus Frame
	FocusFrame:ClearAllPoints();
	FocusFrame:SetScale( focFrameScale );
	FocusFrame:SetPoint( "TOPLEFT", focFrameX, focFrameY );

	-- Move Cast Bar
	CastingBarFrame:ClearAllPoints();
	CastingBarFrame:SetScale( 1.1 );
	CastingBarFrame:SetPoint("CENTER", 0, -175);
	CastingBarFrame.ClearAllPoints = function () end
	CastingBarFrame.SetPoint = function () end
	CastingBarFrame.SetScale = function () end

	for i=1, 5 do
        _G["ArenaPrepFrame"..i]:SetScale(1.5);      
        _G["ArenaPrepFrame"..i].SetScale = function () end
	end
	ArenaEnemyFrames:SetScale(1.5);
end

-- Handle Raid Stuff Seperately
local function SetRaidFrames()
	if( CompactRaidFrameManager:IsVisible() ) then
		local point, relativeTo, relativePoint, xOfs, yOfs = CompactRaidFrameManager:GetPoint()
        CompactRaidFrameManager:SetPoint(point, relativeTo, relativePoint, xOfs, -300)
	end

	CompactRaidFrameManagerToggleButton:HookScript("OnClick", function()
		if CompactRaidFrameManager:IsVisible() then  
		    local point, relativeTo, relativePoint, xOfs, yOfs = CompactRaidFrameManager:GetPoint()
		    CompactRaidFrameManager:SetPoint(point, relativeTo, relativePoint, xOfs, -300)
		end
	end);
end

local function UpdateClassIcon(class)

	if class == "WARRIOR" then
		classIcon:SetTexCoord( 0, .25, 0, .25 );
	elseif class == "MAGE" then
		classIcon:SetTexCoord( .25, .5,0, .25 );
	elseif class == "ROGUE" then
		classIcon:SetTexCoord( .5, .74,0, .25 );
	elseif class == "DRUID" then
		classIcon:SetTexCoord( .75, .98, 0, .25 );
	elseif class == "PALADIN" then
		classIcon:SetTexCoord( 0, .25, .5, .75 );
	elseif class == "DEATHKNIGHT" then
		classIcon:SetTexCoord( .25, .5, .5, .75);
	elseif class == "MONK" then
		classIcon:SetTexCoord( .5, .74, .5,.75);
	elseif class == "HUNTER" then
		classIcon:SetTexCoord( 0, .25, .25, .5 );
	elseif class == "SHAMAN" then
		classIcon:SetTexCoord( .25, .5, .25, .5 );
	elseif class == "PRIEST" then
		classIcon:SetTexCoord( .5, .74, .25, .5 );
	elseif class == "WARLOCK" then
		classIcon:SetTexCoord( .75, .98, .25, .5 );
	end

end

local function UF_HandleEvents( self, event, ... )

	if( event == "PLAYER_ENTERING_WORLD" ) then
		if( combatLock == false ) then
			SetUnitFrames();
			startTimer = true;
			--SetRaidFrames();
		end
	end

	if( event == "UNIT_EXITED_VEHICLE" or event == "UNIT_ENTERED_VEHICLE" ) then
		local isInVehicle = UnitControllingVehicle("player");
		if( isInVehicle == true ) then
			SetUnitFrames();
		end

		if ( UnitHasVehiclePlayerFrameUI("player") ) then
			SetUnitFrames();
		end

	end

	if ( event == "PLAYER_TARGET_CHANGED" ) then
		if( showClassIcon == true ) then
			local target = select( 2, UnitClass("target") );
			UpdateClassIcon( target );
		end
		
		if( combatLock == false ) then			
			-- Target Frame Smooth Fade
			if( UnitExists("target") ) then
				if( tFrameHidden == true ) then
					UIFrameFadeIn( TargetFrame, fadeTime, 0, 1 );
					tFrameHidden = false;
				end
			else
				UIFrameFadeOut( TargetFrame, fadeTime, 1, 0 );
				tFrameHidden = true;
			end
		end
	end

	if( event == "PLAYER_REGEN_DISABLED" ) then
		combatLock = true;
	end

	if( event == "PLAYER_REGEN_ENABLED" ) then
		combatLock = false;
	end

end

-- Hacky - Fixes Raid Frame Init Bug
local function Delay(self, elapsed)
	if( startTimer == true ) then
		time = time + elapsed;
		if( time >= delayLength ) then
			SetRaidFrames();
			timer:SetScript("OnUpdate", function() end );
			startTimer = false;
			time = 0;
		end
	end
end
timer:SetScript("OnUpdate", Delay );


local function UF_Init()
	impUF:SetScript( "OnEvent", UF_HandleEvents );
	LoadAddOn("Blizzard_ArenaUI");

	-- Create Frames
	if( showClassIcon == true ) then
		classFrame = CreateFrame("Frame", "ClassFrame", TargetFrame );
		classFrame:SetPoint( "CENTER", 110, 40);
		classFrame:SetSize( 40, 40 );
		classIcon = classFrame:CreateTexture( "ClassIcon" );
		classIcon:SetPoint( "CENTER" );
		classIcon:SetSize( 40, 40 );
		classIcon:SetTexture( "Interface\\TARGETINGFRAME\\UI-CLASSES-CIRCLES.BLP" );
		classIconBorder = classFrame:CreateTexture( "ClassIconBorder", "ARTWORK", nil, 1 );
		classIconBorder:SetPoint( "CENTER" , classIcon );
		classIconBorder:SetSize( 80, 80 );
		classIconBorder:SetTexture( "Interface\\UNITPOWERBARALT\\WowUI_Circular_Frame.blp" );
	end

	impUF:RegisterEvent( "PLAYER_LOGIN" );
	impUF:RegisterEvent( "PLAYER_ENTERING_WORLD" );
	impUF:RegisterEvent( "PLAYER_ENTERING_BATTLEGROUND")
	impUF:RegisterEvent( "PLAYER_TARGET_CHANGED" );
	impUF:RegisterEvent( "UNIT_EXITED_VEHICLE" );
	impUF:RegisterEvent( "UNIT_EXITING_VEHICLE" );
	impUF:RegisterEvent( "UNIT_ENTERED_VEHICLE" );
	impUF:RegisterEvent( "UNIT_ENTERING_VEHICLE");
	impUF:RegisterEvent( "UNIT_LOSES_VEHICLE_DATA" );
	impUF:RegisterEvent( "UNIT_GAINS_VEHICLE_DATA")
	impUF:RegisterEvent( "PLAYER_REGEN_DISABLED" );
	impUF:RegisterEvent( "PLAYER_REGEN_ENABLED" );
end

-- Run Initialisation
UF_Init();