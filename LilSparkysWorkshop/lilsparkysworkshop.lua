-- LilSparky's Workshop -- Addon for Slarti's Advanced Tradeskill Window mod for WOW
-- Lilsparky of Lothar
-- Updated by laytya at github

local _G = getfenv(0)

ATSW_ShowWindow_ORIGINAL = nil;
TradeSkillFrame_Show_ORIGINAL = nil;
TradeSkillFrame_Update_ORIGINAL = nil;

---
LSW_VERSION = GetAddOnMetadata("LilSparkysWorkshop", "Version");

LSW_Mode = "TradeSkill";

LSW_AuctioneerHook = false;
local AUX = nil

LSW_TRADESKILL_INDEX_MAX = 8
LSW_CRAFT_INDEX_MAX = 8

LSW_MINIMUM_REAGENT_AUCTIONS = 10
LSW_MINIMUM_ITEM_AUCTIONS = 1

LSW_itemFateColor={};
LSW_itemFateColor["d"]="ff008000";
LSW_itemFateColor["a"]="ff809060";
LSW_itemFateColor["v"]="ff206080";
LSW_itemFateColor["?"]="ff800000";

LSW_globalSync = 1;
LSW_skillPriceCache={};

LSW_globalFate = 0;
LSW_globalFateMax = 2;

-- these could certainly be made language specific if needed
LSW_itemFateList={};
LSW_itemFateList[1]="a";		-- auction
LSW_itemFateList[2]="v";		-- vendor
LSW_itemFateList[3]="d";		-- disenchant

LSW_excludedItemId = {8925,3372,4342,3371,3713,4342,4289,4291,4340,2692,2678,2321,2320,4400,4399,2324,3857,4341,3466,14341,8343,18256,6217,6260,11291,4470,17034}
LSW_skillWidthNarrow = 223;
LSW_skillWidthWide = 243;

LSW_skillWidth = LSW_skillWidthWide;

local LSW_debugWin = 0

function LSW_Message( visible, ...)
	LSW_debugWin = 0
	local name, shown;
	for i=1, NUM_CHAT_WINDOWS do
		name,_,_,_,_,_,shown = GetChatWindowInfo(i);
		if (string.find(string.lower(name) ,"debug")) then LSW_debugWin = i; break; end
	end
	if (LSW_debugWin == 0) then 
		LSW_debugWin = DEFAULT_CHAT_FRAME
	else
		LSW_debugWin = getglobal("ChatFrame"..LSW_debugWin)
	end
	for i = 1,arg.n do
		if type(arg[i]) == "nil" then
			arg[i] = "(nil)";
		elseif type(arg[i]) == "boolean" and arg[i] then
			arg[i] = "(true)";
		elseif type(arg[i]) == "boolean" and not arg[i] then
			arg[i] = "(false)";
		end
	end

	if (visible) then
		LSW_debugWin:AddMessage("LSW: " .. table.concat (arg, " "), 0.5, 0.5, 1);
	end
end


function LSW_formatMoney(moneyString,dark)
	local money = tonumber(moneyString);
	local TEXT_NONE = "-- --"

	local GSC_GOLD="ffffd100"
	local GSC_SILVER="ffe6e6e6"
	local GSC_COPPER="ffc8602c"
	
	if (dark==1) then
		GSC_GOLD = "ff807000"
		GSC_SILVER = "ff808080"
		GSC_COPPER = "ff643016"
	end
	
	local g, s, c;
	local digits = 0
	
	g = math.floor(money/10000);
	s = math.mod(math.floor(money/100),100);
	c = math.mod(money,100);

	if (money > 0) then
		digits = math.floor(math.log10(money)+1)
	end
	
	if ( digits < 3 ) then
		gsc = string.format("   |c%s%2d|r",  GSC_COPPER, c);
	elseif ( digits < 5 ) then
		gsc = string.format("|c%s%2d|r |c%s%02d|r", GSC_SILVER, s, GSC_COPPER, c)
	elseif ( digits < 7 ) then
		gsc = string.format("|c%s%2d|r |c%s%02d|r", GSC_GOLD, g, GSC_SILVER, s)
	else
		gsc = string.format("|c%s%5d|r", GSC_GOLD, g);
	end

	return gsc
end


function LSW_GetTradeSkillInfo(index)
	local skillName, skillType, numAvailable, isExpanded;
	
	if (LSW_Mode == "ATSW") then
		skillName, craftSubSpellName, skillType, numAvailable, isExpanded = ATSW_GetTradeSkillInfo(index);
	elseif (LSW_Mode == "Craft") then
		skillName, craftSubSpellName, skillType, numAvailable, isExpanded = GetCraftInfo(index);
	else
		skillName, skillType, numAvailable, isExpanded = GetTradeSkillInfo(index);
	end
	
	return skillName, skillType, numAvailable, isExpanded;
end


function LSW_GetTradeSkillNumMade(index)
	if (LSW_Mode == "ATSW") then
		return ATSW_GetTradeSkillNumMade(index);
	elseif (LSW_Mode == "Craft") then
		return 1, 1
	else
		return GetTradeSkillNumMade(index);
	end	
end

function LSW_GetTradeSkillNumReagents(index)
	
	if (LSW_Mode == "ATSW") then
		return ATSW_GetTradeSkillNumReagents(index);
	elseif (LSW_Mode == "Craft") then
		return GetCraftNumReagents(index);
	else
		return GetTradeSkillNumReagents(index);
	end
end

function LSW_GetTradeSkillReagentInfo(index, reagentIndex)

	if (LSW_Mode == "ATSW") then
		return ATSW_GetTradeSkillReagentInfo(index, reagentIndex);
	elseif (LSW_Mode == "Craft") then
		return GetCraftReagentInfo(index, reagentIndex);
	else
		return GetTradeSkillReagentInfo(index, reagentIndex);
	end
end

function LSW_GetTradeSkillReagentItemLink(index, reagentIndex)
	
	if (LSW_Mode == "ATSW") then
		return ATSW_GetTradeSkillReagentItemLink(index, reagentIndex);
	elseif (LSW_Mode == "Craft") then
		return GetCraftReagentItemLink(index, reagentIndex);
	else
		return GetTradeSkillReagentItemLink(index, reagentIndex);
	end	
end

function LSW_GetTradeSkillItemLink(index)
	
	if (LSW_Mode == "ATSW") then
		return ATSW_GetTradeSkillItemLink(index)
	elseif (LSW_Mode == "Craft") then
		return GetCraftItemLink(index);
	else
		return GetTradeSkillItemLink(index);
	end	
end



function LSW_findItemID(link)
	if ( type(link) ~= 'string' ) then return end
	local i,j,itemID = string.find(link, "|Hitem:(%d+):");	
-- LSW_Message( true,"itemID - "..itemID);	
	return tonumber(itemID); 
end

function LSW_isInTable(tab, id)
	for k,v in ipairs(tab) do
		if (v == id) then
			return true;
		end
	end
	return false;
end


function LSW_itemPriceVendor(link)
	if ( type(link) ~= 'string' ) then return 0,0,true end
	local sell = 0
	local buy = 0
	local itemInfo = nil;
	
	if Auctioneer then
	local itemID = LSW_findItemID(link)
	if (itemID and itemID > 0) and (Informant) then
		itemInfo = Informant.GetItem(itemID)
	end
	end
	
	if AUX and not itemInfo then
		itemInfo = {};
		local item_id, suffix_id = AUX.info.parse_link(link)
		itemInfo.sell,itemInfo.buy  = AUX.info.merchant_info(item_id)
	end
	
	if (not itemInfo) then return 0, 0, true end

	buy = tonumber(itemInfo.buy) or 0
	sell = tonumber(itemInfo.sell) or 0

	return buy, sell, false
end

function LSW_itemPrice(link, minSeen)
	local sellPrice, failed = 0, false
	if AUX then
		sellPrice, failed = LSW_itemPriceAUX(link, minSeen) 
	end
	if failed and Auctioneer then
		sellPrice, failed = LSW_itemPriceAuctioneer(link, minSeen)
	end
	return sellPrice, failed
end

function LSW_itemPriceAuctioneer(link, minSeen) -- auctioneer version
	if (not Auctioneer or not link) then return 0, true; end

	if (not minSeen) then minSeen = 1 end;
	
-- LSW_Message( true,link);
	local itemKey
	if Auctioneer.ItemDB then
		itemKey = Auctioneer.ItemDB.CreateItemKeyFromLink(link);
	else
		local itemKeys = Auctioneer.Util.GetItems(link)
		itemKey = itemKeys[1] 
	end
	local itemTotals 
	if Auctioneer.HistoryDB then 
		itemTotals = Auctioneer.HistoryDB.GetItemTotals(itemKey);
	else
		itemTotals = {}
		itemTotals.buyOut,itemTotals.seenCount = Auctioneer.Statistic.GetHistMedian(itemKey)
	end

	local sellPrice = 0;
	
-- LSW_Message( true,itemTotals.seenCount.." seen");
	if (itemTotals and itemTotals.seenCount and itemTotals.seenCount < minSeen) then
--		sellPrice  = Auctioneer.Statistic.GetMarketPrice(itemKey, auctKey);
		sellPrice  = Auctioneer.Statistic.GetHSP(itemKey, nil,1);
	else
		return 0, true
	end
	
	
	return sellPrice, false;
end


function LSW_itemPriceAUX(link, minSeen) 
	local numSeen;
	if (not link) then return 0, true; end
	if (not minSeen) then minSeen = 1; end

	local item_id, suffix_id = AUX.info.parse_link(link)
	local item_key = (item_id or 0) .. ':' .. (suffix_id or 0)
    local value =  AUX.history.value(item_key)
				
	if (not value ) then
		return 0, true;
	end
	return value, false;
end
function LSW_IsReagentCraftable(ReagentItemID)
	for i=1,GetNumTradeSkills(),1 do
		local skillLink = GetTradeSkillItemLink(i)
		local name,_,_ = GetTradeSkillInfo(i)
		if skillLink and ReagentItemID == LSW_findItemID(skillLink) and (not string.find(name,"Transmute")) then
			return i
			end
		end
	return 0
	end
	
function LSW_ReagentsCost(skillID)
	
	local numReagents, buy, dummy, buystring;
	buystring = ""; buy = 0;
	numReagents = LSW_GetTradeSkillNumReagents(skillID);
	
	for i=1, numReagents, 1 do
		local reagentName, dummy, reagentCount = LSW_GetTradeSkillReagentInfo(skillID, i);
		local reagentLink = LSW_GetTradeSkillReagentItemLink(skillID, i);
		local reagentItemId = LSW_findItemID(reagentLink)
		
		local sellAtAuction;
		local buyFromVendor;
		local ahDataMissing;
		
		local reagentValue = 0;
		
		sellAtAuction, ahDataMissing = LSW_itemPrice(reagentLink, LSW_MININUM_REAGENT_AUCTIONS);
		buyFromVendor = LSW_itemPriceVendor(reagentLink);

-- calculate the cost of reagents.  if vendor price missing use ah data if it exists.
		reagentSkillID = LSW_IsReagentCraftable(reagentItemId)
		if reagentSkillID >0 then
			reagentValue = LSW_ReagentsCost(reagentSkillID)
	--		Sea.io.print("|"..reagentName.." => "..reagentValue.."|")
			buystring = buystring .. reagentValue .. "(C) + " 
		elseif (not ahDataMissing and not LSW_isInTable(LSW_excludedItemId, reagentItemId)) then
			reagentValue = sellAtAuction;
			buystring = buystring .. sellAtAuction .. "(A) + " 
		else
			reagentValue = buyFromVendor;
			buystring = buystring .. (buyFromVendor and (buyFromVendor .. "(V) + ")  or "0 +") 
		end

--LSW_Message( true,reagentLink.."  "..reagentValue);
	

		buy = buy + reagentValue * reagentCount;
	end
		
	return buy, buystring

end



function LSW_itemValuation(skillName, skillLink, skillID)

	if (LSW_skillPriceCache[skillName] == nil) then
		LSW_skillPriceCache[skillName]={}
		LSW_skillPriceCache[skillName].sync = 0
		LSW_skillPriceCache[skillName].valueAmount = {};
	else
		if (LSW_skillPriceCache[skillName].sync == LSW_globalSync) then
			if (LSW_globalFate==0) then
				return LSW_skillPriceCache[skillName].costAmount, LSW_skillPriceCache[skillName].valueAmount[LSW_globalFate], LSW_skillPriceCache[skillName].itemFate;
			else
				return LSW_skillPriceCache[skillName].costAmount, LSW_skillPriceCache[skillName].valueAmount[LSW_globalFate], LSW_itemFateList[LSW_globalFate];
			end
		end
	end
	
	local cache = LSW_skillPriceCache[skillName];
	cache.synce = LSW_globalSync;
	cache.valueAmount[1] = 0;
	cache.valueAmount[2] = 0;
	cache.valueAmount[3] = 0;
	
	local sell = 0;
	
	local buystring = "";
	local stacks = 1;
	local itemFate = "?"
	
	cache.costAmount, buystring = LSW_ReagentsCost(skillID)   -- costAmount = how much it would cost to purchase the reagents
	
--	Sea.io.print("|"..buystring.."|")
	local ItemId = LSW_findItemID(skillLink)
	if ( ItemId and GetItemInfo(ItemId)) then  -- items return info, enchants return nil
		local min,max;
		
		min, max = LSW_GetTradeSkillNumMade(skillID);
		
-- LSW_Message( true,skillName.."  "..min.." "..max);

		stacks = (min+max)/2;
	
		sell = LSW_itemPrice(skillLink, LSW_MINIUMUM_ITEM_AUCTIONS);
		cache.valueAmount[1] = sell * stacks;  -- valueAmount[1] = how much an item might auction for
	
		dummy, sell = LSW_itemPriceVendor(skillLink);
		
	--	Sea.io.printTable({dummy, sell})
		
		cache.valueAmount[2] = sell * stacks;  -- valueAmount[2] = how much an item would sell to a vendor for
		
		sell = 0;
		if (Enchantrix) then
			local sellinfo = Enchantrix.Storage.GetItemDisenchants(Enchantrix.Util.GetSigFromLink(skillLink)); -- auctioneer
			if type(sellinfo) == "table" and type(sellinfo.totals) == "table" then 
				sell = sellinfo.totals.hspValue
			end
		end
		if AUX and sell == 0 then
			local item_id, suffix_id = AUX.info.parse_link(skillLink)
			local item_info = AUX.info.item(item_id)
			if item_info then
				sell = AUX.disenchant.value(item_info.slot, item_info.quality, item_info.level)
			end
		end
	end
	
	if (sell) then
		cache.valueAmount[3] = sell * stacks;  -- valueAmount[3] = how much an item would sell for if de'd
	end
	
	
	if (cache.valueAmount[1] >= cache.valueAmount[2] and cache.valueAmount[1] >= cache.valueAmount[3]) then
		cache.valueAmount[0] = cache.valueAmount[1];
		cache.itemFate = LSW_itemFateList[1];
	else
		if (cache.valueAmount[2] >= cache.valueAmount[3] and cache.valueAmount[2] >= cache.valueAmount[1]) then
			cache.valueAmount[0] = cache.valueAmount[2];
			cache.itemFate = LSW_itemFateList[2];
		else
			cache.valueAmount[0] = cache.valueAmount[3];
			cache.itemFate = LSW_itemFateList[3];
		end
	end
	
	LSW_skillPriceCache[skillName].sync = LSW_globalSync;
				
	if (LSW_globalFate==0) then
		
		return LSW_skillPriceCache[skillName].costAmount, LSW_skillPriceCache[skillName].valueAmount[LSW_globalFate], LSW_skillPriceCache[skillName].itemFate, buystring;
	else
		return LSW_skillPriceCache[skillName].costAmount, LSW_skillPriceCache[skillName].valueAmount[LSW_globalFate], LSW_itemFateList[LSW_globalFate] , buystring;
	end
end



function LSW_SkillShow()
	if (LSW_Mode == "Craft") then
		if (GetCraftName() ~= "Enchanting") then
			return;
		end
	end
	
	
	this:SetWidth(LSW_skillWidth);
	
	local name = this:GetName();
	local itemLevel =nil
	local x;
	local id;
	
	local buttonLevel;
	local buttonCost;
	local buttonValue;
	
	if (LSW_Mode == "ATSW") then
		id = string.sub(name,10); -- ATSWSkill[id]
		
		buttonValue = getglobal("LSWTradeSkillValue"..id);
		buttonCost = getglobal("LSWTradeSkillCost"..id);
		buttonLevel = getglobal("LSWTradeSkillItemLevel"..id);
	elseif (LSW_Mode == "Craft") then
		id = string.sub(name,6); -- Craft[id]
		
		buttonLevel = getglobal("LSWCraftItemLevel"..id);
		buttonCost = getglobal("LSWCraftCost"..id);
		buttonValue = getglobal("LSWCraftValue"..id);
	else
		id = string.sub(name,16); -- TradeSkillSkill[id]
		
		buttonValue = getglobal("LSWTradeSkillValue"..id);
		buttonCost = getglobal("LSWTradeSkillCost"..id);
		buttonLevel = getglobal("LSWTradeSkillItemLevel"..id);
	end
	
	if (not buttonValue) then return; end
	
	
	local skillName;
	local skillLink;
	local skillType;
	local skillID;
	
	if (LSW_Mode == "ATSW") then
		local tradeSkillID=this:GetID();
		local listpos=ATSW_GetSkillListingPos(tradeSkillID);
	
		if(atsw_skilllisting[listpos]) then
			skillName = atsw_skilllisting[listpos].name;
			skillLink = atsw_skilllisting[listpos].link;
			skillType = atsw_skilllisting[listpos].type;
			skillID =   atsw_skilllisting[listpos].id;
		end
		
--		LSW_Message( true,"ATSW: "..skillName.." "..skillLink.." "..skillType.." "..skillID);

	else
		skillID=this:GetID();
		skillName, skillType = LSW_GetTradeSkillInfo(skillID);
		skillLink = LSW_GetTradeSkillItemLink(skillID);
	end
	--Sea.io.printTable({skillID,skillName, skillType,skillLink})
	
	if (skillName and skillType ~= "header") then						
		local costAmount, valueAmount, itemFate, buystring = LSW_itemValuation(skillName, skillLink, skillID);
	--	Sea.io.printTable({costAmount, valueAmount, itemFate})				
		local itemFateString = string.format("|c%s%s|r", LSW_itemFateColor[itemFate], itemFate);
						
		if (costAmount < valueAmount) then
			buttonValue:SetText(LSW_formatMoney(valueAmount,0)..itemFateString);
			buttonCost:SetText(LSW_formatMoney(costAmount,1).."  ");
		else
			buttonValue:SetText(LSW_formatMoney(valueAmount,1)..itemFateString);
			buttonCost:SetText(LSW_formatMoney(costAmount,1).."  ");
		end
		buttonCost.buystring = buystring;
		local ItemId = LSW_findItemID(skillLink)			
		if (ItemId and skillName and skillName ~= "") then
			--local _,_,skillItemId = string.find(skillLink, "^.*|Hitem:(%d*):.*%[.*%].*$");
			local _, _, _, il = GetItemInfo(ItemId);
			itemLevel = il
		--	Sea.io.printTable({ [skillLink]=itemLevel})
			if (itemLevel) and (itemLevel <= UnitLevel("player")) then
				buttonLevel:SetTextColor(.8,.8,.8);
			else
				buttonLevel:SetTextColor(1,.2,.2);
			end
		end
			
		if (itemLevel == 0) then
			itemLevel = "1"
		end
		
		if (itemLevel) then
			buttonLevel:SetText(itemLevel);
			buttonLevel:Show();
			buttonValue:Show();
		else
			buttonLevel:SetText("");
			buttonLevel:Hide();
		end
		
		buttonCost:Show();
	end
end


function LSW_SkillHide()
	local name = this:GetName();
	local id;
	
	local buttonLevel;
	local buttonCost;
	local buttonValue;
	
	if (LSW_Mode == "ATSW") then
		id = string.sub(name,10); -- ATSWSkill[id]
		
		buttonValue = getglobal("LSWTradeSkillValue"..id);
		buttonCost = getglobal("LSWTradeSkillCost"..id);
		buttonLevel = getglobal("LSWTradeSkillItemLevel"..id);
	elseif (LSW_Mode == "Craft") then
		id = string.sub(name,6); -- Craft[id]
		
		buttonLevel = getglobal("LSWCraftItemLevel"..id);
		buttonCost = getglobal("LSWCraftCost"..id);
		buttonValue = getglobal("LSWCraftValue"..id);
	else
		id = string.sub(name,16); -- TradeSkillSkill[id]
		
		buttonValue = getglobal("LSWTradeSkillValue"..id);
		buttonCost = getglobal("LSWTradeSkillCost"..id);
		buttonLevel = getglobal("LSWTradeSkillItemLevel"..id);
	end
	
	if (buttonCost) then buttonCost:Hide(); end
	if (buttonValue) then buttonValue:Hide(); end
	if (buttonLevel) then buttonLevel:Hide(); end
end


function LSW_ItemLevelButton_OnEnter()
	GameTooltip:SetOwner(this, "ANCHOR_NONE");
	GameTooltip:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -CONTAINER_OFFSET_X - 13, CONTAINER_OFFSET_Y);
	GameTooltip:SetText("Required level to use crafted item.");
	GameTooltip:Show();
end

function LSW_ItemLevelButton_OnLeave()
	GameTooltip:Hide();
end



function LSW_CostButton_OnEnter(button)
-- LSW_Message( true,"skill cost enter");
   	GameTooltip:SetOwner(this, "ANCHOR_NONE");
	GameTooltip:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -CONTAINER_OFFSET_X - 13, CONTAINER_OFFSET_Y);
	GameTooltip:SetText("Estimated cost to use skill. " .. (button.buystring or "---"));
	GameTooltip:Show();
end

function LSW_CostButton_OnLeave()
	GameTooltip:Hide();
end


-- click on the value and toggle the BEST/AUCTION/VENDOR/DE price consideration

function LSW_ValueButton_OnClick(button)
	
	--Sea.io.print(button,"onclick")
	if(button=="LeftButton") then
		LSW_globalFate = LSW_globalFate + 1;
		
		if (LSW_globalFate > LSW_globalFateMax) then
			LSW_globalFate = 0;
		end
		
		LSW_ValueButton_OnEnter()
		
		if (LSW_Mode == "ATSW") then
			ATSWFrame_Update();
		elseif (LSW_Mode == "Craft") then
			LSW_UpdateWindowCraft();
		else
			LSW_UpdateWindowStandard();
		end
	end
end

function LSW_ValueButton_OnEnter()
	GameTooltip:SetOwner(this, "ANCHOR_NONE");
	GameTooltip:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -CONTAINER_OFFSET_X - 13, CONTAINER_OFFSET_Y);
	
	if (LSW_globalFate == 0) then
		GameTooltip:SetText("Estimated value of crafted item(s).");
		GameTooltip:AddLine("Best price shown.");
		GameTooltip:AddLine("a = auction  v = vendor  d = disenchant");
	elseif (LSW_globalFate == 1) then
		GameTooltip:SetText("Estimated auction value of crafted item(s).");
	elseif (LSW_globalFate == 2) then
		GameTooltip:SetText("Vendor purchase price of crafted item(s).");
	else
		GameTooltip:SetText("Estimated disenchant value of crafted item(s).");
	end
	
	GameTooltip:Show();
end

function LSW_ValueButton_OnLeave()
	GameTooltip:Hide();
end


function LSW_ShowWindowATSW()
	LSW_globalSync = LSW_globalSync + 1;
	LSW_Mode = "ATSW";
	
	ATSW_ShowWindow_ORIGINAL();
	
	local scrollFrame = ATSWListScrollFrame;
	
	if (ATSWListScrollFrame:IsVisible()) then
		LSW_skillWidth = LSW_skillWidthNarrow;
	else
		LSW_skillWidth = LSW_skillWidthWide;
	end
	
	if ATSWFrameTitleTextLSW == nil then
	
		ATSWFrameTitleTextLSW = ATSWFrame:CreateFontString(nil, "OVERLAY")
		ATSWFrameTitleTextLSW:SetFontObject(GameFontNormal)
		--ATSWFrameTitleTextLSW:SetFont(ADDON.leveltext.font,ADDON.leveltext.size ,'OUTLINE',0,-1)
		ATSWFrameTitleTextLSW:SetWidth(100)
		ATSWFrameTitleTextLSW:SetHeight(14)
		ATSWFrameTitleTextLSW:SetTextColor(1,0.8,0)
		ATSWFrameTitleTextLSW:SetText("w/ LSW ".. LSW_VERSION)
		ATSWFrameTitleTextLSW:SetJustifyH('RIGHT')
		if Skinner and Skinner.db.profile.TradeSkill then
			ATSWFrameTitleTextLSW:SetPoint('TOPRIGHT',ATSWFrame, 'TOPRIGHT', -40, -8)
		else
			ATSWFrameTitleTextLSW:SetPoint('TOPRIGHT',ATSWFrame, 'TOPRIGHT', -70, -17)
		end
		ATSWFrameTitleTextLSW:Show()
	end
	
	ATSWFrame_Update();
		
end


function LSW_ShowWindowStandard()
	LSW_globalSync = LSW_globalSync + 1;
	LSW_Mode = "TradeSkill";
	
--	for i=1, LSW_CRAFT_INDEX_MAX, 1 do	
--		local buttonValue = getglobal("LSWTradeSkillValue"..i);
--		buttonValue:SetParent("TradeSkillFrame");
--		
--		local buttonCost = getglobal("LSWTradeSkillCost"..i);
--		buttonCost:SetParent("TradeSkillFrame");
--		
--		local buttonLevel = getglobal("LSWTradeSkillItemLevel"..i);
--		buttonLevel:SetParent("TradeSkillFrame");
--	end
	
	TradeSkillFrame_Show_ORIGINAL();

	if (TradeSkillListScrollFrame:IsVisible()) then
		LSW_skillWidth = LSW_skillWidthNarrow;
	else
		LSW_skillWidth = LSW_skillWidthWide;
	end
	
	TradeSkillFrame_Update();	
end



function LSW_UpdateWindowStandard()
	LSW_Mode = "TradeSkill";

	for i=1, LSW_TRADESKILL_INDEX_MAX, 1 do
		local tradeSkillButton = getglobal("TradeSkillSkill"..i);
		tradeSkillButton:Hide();
	end
	TradeSkillFrame_Update_ORIGINAL()
	local name = GetTradeSkillLine()
	TradeSkillFrameTitleText:SetText(name.." (LSW v0.2)");
end



function LSW_ShowWindowCraft()
	if (GetCraftName() ~= "Enchanting") then
		for i=1, LSW_CRAFT_INDEX_MAX, 1 do
			local craftButton = getglobal("Craft"..i);
			craftButton:SetTextFontObject("GameFontNormal");
			craftButton:SetHighlightFontObject("GameFontHighlight");
			craftButton:SetDisabledFontObject("GameFontDisable");
		end
		
		CraftFrame_Show_ORIGINAL();
--		CraftFrame_Update();
		return;
	else
		for i=1, LSW_CRAFT_INDEX_MAX, 1 do
			local craftButton = getglobal("Craft"..i);
			craftButton:SetTextFontObject("GameFontNormalSmall");
			craftButton:SetHighlightFontObject("GameFontHighlightSmall");
			craftButton:SetDisabledFontObject("GameFontDisableSmall");
		end

	end

	LSW_globalSync = LSW_globalSync + 1;
	LSW_Mode = "Craft";
	
--	for i=1, LSW_CRAFT_INDEX_MAX, 1 do
--		local buttonValue = getglobal("LSWCraftValue"..i);
--		buttonValue:SetParent("CraftFrame");
--		
--		local buttonCost = getglobal("LSWCraftCost"..i);
--		buttonCost:SetParent("CraftFrame");
--		
--		local buttonLevel = getglobal("LSWCraftItemLevel"..i);
--		buttonLevel:SetParent("CraftFrame");
--	end
	
	CraftFrame_Show_ORIGINAL();

	if (CraftListScrollFrame:IsVisible()) then
		LSW_skillWidth = LSW_skillWidthNarrow;
	else
		LSW_skillWidth = LSW_skillWidthWide;
	end
	CraftFrame_Update();
end



function LSW_UpdateWindowCraft()
	if (GetCraftName() ~= "Enchanting") then
		CraftFrame_Update_ORIGINAL();
		return;
	end
	
	LSW_Mode = "Craft";

	for i=1, LSW_CRAFT_INDEX_MAX, 1 do
		local craftButton = getglobal("Craft"..i);
		craftButton:Hide();
	end
	CraftFrame_Update_ORIGINAL()
	CraftFrameTitleText:SetText(GetCraftName().." (LSW v0.2)");
end


function LSW_ButtonInitATSW(i)
	local atswButton = getglobal("ATSWSkill"..i);
	atswButton:SetScript("OnShow", LSW_SkillShow);
	atswButton:SetScript("OnHide", LSW_SkillHide);	
	atswButton:SetTextFontObject("GameFontNormalSmall");
	atswButton:SetHighlightFontObject("GameFontHighlightSmall");
	atswButton:SetDisabledFontObject("GameFontDisableSmall");
	
	
	local buttonValue = getglobal("LSWTradeSkillValue"..i);
	buttonValue:SetParent("ATSWFrame");
	buttonValue:SetPoint("TOPLEFT","ATSWSkill"..i,"TOPRIGHT",5,0);
	buttonValue:SetText("00 00");
	buttonValue:SetWidth(30);
	buttonValue:Hide();
	
	
	local buttonCost = getglobal("LSWTradeSkillCost"..i);
	buttonCost:SetParent("ATSWFrame");
	buttonCost:SetPoint("TOPLEFT","LSWTradeSkillValue"..i,"TOPRIGHT",15,0);
	buttonCost:SetText("00 00");
	buttonCost:SetWidth(30);
	buttonCost:Hide();
	

	local buttonLevel = getglobal("LSWTradeSkillItemLevel"..i);
	buttonLevel:SetParent("ATSWFrame");
	buttonLevel:SetPoint("TOPLEFT","ATSWSkill"..i,"TOPLEFT",0,0);
	buttonLevel:SetText("");
	buttonLevel:Hide();
end


function LSW_ButtonInitStandard(i)
	local tradeSkillButton = getglobal("TradeSkillSkill"..i);
	tradeSkillButton:SetScript("OnShow", LSW_SkillShow);
	tradeSkillButton:SetScript("OnHide", LSW_SkillHide);	
	tradeSkillButton:SetTextFontObject("GameFontNormalSmall");
	tradeSkillButton:SetHighlightFontObject("GameFontHighlightSmall");
	tradeSkillButton:SetDisabledFontObject("GameFontDisableSmall");
	tradeSkillButton:SetWidth(LSW_skillWidth);
	
	local buttonValue = getglobal("LSWTradeSkillValue"..i);
	buttonValue:SetParent("TradeSkillFrame");
	buttonValue:SetPoint("TOPLEFT","TradeSkillSkill"..i,"TOPRIGHT",5,0);
	buttonValue:SetText("00 00");
	buttonValue:SetWidth(30);
	buttonValue:Hide();
	
	
	local buttonCost = getglobal("LSWTradeSkillCost"..i);
	buttonCost:SetParent("TradeSkillFrame");
	buttonCost:SetPoint("TOPLEFT","LSWTradeSkillValue"..i,"TOPRIGHT",15,0);
	buttonCost:SetText("00 00");
	buttonCost:SetWidth(30);
	buttonCost:Hide();
	

	local buttonLevel = getglobal("LSWTradeSkillItemLevel"..i);
	buttonLevel:SetParent("TradeSkillFrame");
	buttonLevel:SetPoint("TOPLEFT","TradeSkillSkill"..i,"TOPLEFT",0,0);
	buttonLevel:SetText("");
	
	
	
	local craftButton = getglobal("Craft"..i);
	craftButton:SetScript("OnShow", LSW_SkillShow);
	craftButton:SetScript("OnHide", LSW_SkillHide);	
	craftButton:SetTextFontObject("GameFontNormalSmall");
	craftButton:SetHighlightFontObject("GameFontHighlightSmall");
	craftButton:SetDisabledFontObject("GameFontDisableSmall");
	craftButton:SetWidth(LSW_skillWidth);
	
	local buttonValue = getglobal("LSWCraftValue"..i);
	buttonValue:SetParent("CraftFrame");
	buttonValue:SetPoint("TOPLEFT","Craft"..i,"TOPRIGHT",5,0);
	buttonValue:SetText("00 00");
	buttonValue:SetWidth(30);
	buttonValue:Hide();
	
	
	local buttonCost = getglobal("LSWCraftCost"..i);
	buttonCost:SetParent("CraftFrame");
	buttonCost:SetPoint("TOPLEFT","LSWCraftValue"..i,"TOPRIGHT",15,0);
	buttonCost:SetText("00 00");
	buttonCost:SetWidth(30);
	buttonCost:Hide();
	
	local buttonLevel = getglobal("LSWCraftItemLevel"..i);
	buttonLevel:SetParent("CraftFrame");
	buttonLevel:SetPoint("TOPLEFT","Craft"..i,"TOPLEFT",0,0);
	buttonLevel:SetText("");

end


function LSW_OnLoad()
	this:RegisterEvent("ADDON_LOADED");
end


function LSW_OnEvent()
	if (event == "ADDON_LOADED" and (arg1 == "LilSparkysWorkshop" or arg1 == "aux-addon" or arg1 == "Auctioneer" 
		or arg1 == "AdvancedTradeSkillWindow" or arg1 == "Enchantrix")) then
		LSW_Initialize(arg1);
	end
end


function LSW_Initialize(addon)
	if addon == "LilSparkysWorkshop" then
		LSW_Message( true,"LilSparky's Workshop " .. LSW_VERSION .. " loaded.");
	end
	
if (not AUX and (addon == "aux-addon" or _G.aux ~= nil))then
		AUX = {}
		AUX.history = require "aux.core.history"
		AUX.info = require 'aux.util.info'
		AUX.disenchant = require 'aux.core.disenchant'
		LSW_globalFateMax = 3
		LSW_Message( true,"LilSparky's Workshop: added AUX functions");		
		end
	if (not LSW_AuctioneerHook and (addon == "Auctioneer" or Auctioneer)) then
		LSW_Message( true,"LilSparky's Workshop: added Auctioneer (v"..Auctioneer.Version..") functions");		
		LSW_AuctioneerHook = true
	end
	if (LSW_globalFateMax == 2 and (addon == "Enchantrix" or Enchantrix)) then
		LSW_globalFateMax = 3
	end
	
	if (LSW_Mode ~= "ATSW" and (addon == "AdvancedTradeSkillWindow" or ATSW_ShowWindow)) then
                LSW_Mode = "ATSW"
		ATSW_ShowWindow_ORIGINAL = ATSW_ShowWindow;
		ATSW_ShowWindow = LSW_ShowWindowATSW;
			
		LSW_Message( true,"LilSparky's Workshop: plugging into AdvancedTradeSkillWindow.");
		
		LSW_TRADESKILL_INDEX_MAX = ATSW_TRADE_SKILLS_DISPLAYED;
		
		LSW_skillWidthNarrow = 223;
		LSW_skillWidthWide = 243;
		
		LSW_skillWidth = LSW_skillWidthNarrow;

		for i=1, LSW_TRADESKILL_INDEX_MAX, 1 do
			LSW_ButtonInitATSW(i);
		end
	end
	
	
end

local UFStartTime = time();
local UFInitialized;
local UpdateFrame;

function UFOverHookEvents()
	if(time() - UFStartTime > 5 and UFInitialized == nil) then
		LSW_PostInitialize()
    	UFStartTime = nil;
		UFInitialized = true;
		this:Hide();
      	this:SetScript("OnUpdate", nil);
      	this = nil;
   end
end

local UpdateFrame = CreateFrame("Frame", nil);
UpdateFrame:SetScript("OnUpdate",UFOverHookEvents);
UpdateFrame:RegisterEvent("OnUpdate");

function LSW_PostInitialize()
		
	if (not Auctioneer) and (not AUX) then
		LSW_Message( true,"ERROR: LilSparky's Workshop requires either Auctioneer or AUX to function properly.");
		return;
	end
	
	if LSW_globalFateMax == 2 then
		LSW_Message( true,"WARNING: LilSparky's Workshop needs Enchantrix or AUX to calculate disenchant values.");
		LSW_Message( true,"Addon will still work, but no disenchant values will be calculated.");
	end	
		
	if LSW_Mode ~= "ATSW" then
		LSW_Message( true,"LilSparky's Workshop: plugging into standard Tradeskill/Crafting frames.");

	-- more forced loading, but since i'm pluggin right into the system, i kind of need to
		if (not IsAddOnLoaded("Blizzard_TradeSkillUI")) then
			LoadAddOn("Blizzard_TradeSkillUI");
		end
		
		if (not IsAddOnLoaded("Blizzard_CraftUI")) then
			LoadAddOn("Blizzard_CraftUI");
		end
		
		
		TradeSkillFrame_Show_ORIGINAL = TradeSkillFrame_Show;
		TradeSkillFrame_Show = LSW_ShowWindowStandard;
				
		TradeSkillFrame_Update_ORIGINAL = TradeSkillFrame_Update;
		TradeSkillFrame_Update = LSW_UpdateWindowStandard;
		
		
		CraftFrame_Show_ORIGINAL = CraftFrame_Show;
		CraftFrame_Show = LSW_ShowWindowCraft;
		
		CraftFrame_Update_ORIGINAL = CraftFrame_Update;
		CraftFrame_Update = LSW_UpdateWindowCraft;

		
		LSW_TRADESKILL_INDEX_MAX = TRADE_SKILLS_DISPLAYED;
		LSW_CRAFT_INDEX_MAX = CRAFTS_DISPLAYED;
		
		LSW_skillWidthNarrow = 223;
		LSW_skillWidthWide = 243;
		
		LSW_skillWidth = LSW_skillWidthNarrow;
		
		for i=1, LSW_TRADESKILL_INDEX_MAX, 1 do
			LSW_ButtonInitStandard(i);
		end
	end
end
