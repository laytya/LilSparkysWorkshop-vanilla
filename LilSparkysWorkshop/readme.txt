


LilSparky's Workshop



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
updated by laytya at github


version history:
v0.1 (initial release) - oct.09,2007

v0.2 - oct.11,2007
- fixed skill value computation (no longer reports inflated values)
- removed dependency on advanced tradeskill window
- fix bug where addon initialized prior to auctioneer loading
- now loads on demand

v0.4 - mar.1,2017 (by laytya at github)
- ported from TBC version
- Added AUX support
- refactoring startup
- vendor and disenchantsupport from AUX

v0.4b - nov.29,2017 (by laytya at github)
- Fixed AUX support (actual on nov 29 2017)

v0.4c - jun.14,2018 (by laytya at github)
- fixed #2 (item sell price & vendoer value of reagents)

v0.4d - jun.18,2018 (by laytya at github)
- added some more item numbers to exlude from AH pricing

v0.5 - jul.13,2018 (by laytya at github)
- Reworked reagents cost calculation. if items reagent are craftible by same profession - reagent cost will be calculated by reagents of this reagent