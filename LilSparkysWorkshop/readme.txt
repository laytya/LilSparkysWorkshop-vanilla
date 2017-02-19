


LilSparky's Workshop

version 0.2
oct.11.2007


LilSparky's Workshop is a tradeskill addon designed to plug into the World of Warcraft trade skill and crafting frames
(also supports Slarti's Advanced Tradeskill Window mod).

Using data from the Auctioneer addon (and Enchantrix if available), LilSparky's Workshop will calculate how much
a crafted item might be worth (its value) and how much it costs to craft or enchant an item (its cost).
As an added convenience, the character level requirements for any crafter item are also displayed.


The data is layed out as follows:

Level  SkillName         Value   Cost


Level is pretty self explanatory.  Enchants item levels are not represented here, just player levels for items.

Cost is determined by iterating through the materials needed to create the item or enchant.  Auctioneer is used to
find market prices and vendor prices.  The better your auctioneer database, the more accurate the cost.
Note: The cost is considered to be what the materials would sell for on the open market should you decide to sell them rather than use them.

Value is determined by querying auctioneer for a market price and vendor price, then querying enchantrix (which
also queries auctioneer) for a disenchant value (if any).  The results are compared and an item's "fate" is determined --
basically, which of the three prices is highest.  The value has a single letter suffix to indicate the fate of the item:
'a' for auction, 'v' for vendor, 'd' for disenchanting.  Left clicking on the value column will cycle the displayed value
(best price, auction price, vendor price, disenchant price) should you wish to see any particular value.
Items worth more than their cost have the value hilighted.



Enjoy and happy crafting.

LilSparky of Lothar



version history:
v0.1 (initial release) - oct.09,2007

v0.2 - oct.11,2007
- fixed skill value computation (no longer reports inflated values)
- removed dependency on advanced tradeskill window
- fix bug where addon initialized prior to auctioneer loading
- now loads on demand
