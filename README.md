#LilSparkysWorkshop

![Imgur](http://i.imgur.com/UXrROxl.jpg)

LilSparky's Workshop adds auction-derived pricing information for trade skills right into the trade skill recipe frame. Each skill is evaluated for material costs and potential value of the item created. These two numbers are listed next to each skill in an easy-to-read format.

##Supported Auction Scanners:

* Auctioneer
* AUX

##Trade Skill Interfaces Supported:

* AdvancedTradeSkillWindow
* Blizzard's Standard UI

##Optionally Requires:

* Informant
* Enchantrix 
(these mods will assist in identifying vendor sourced items, dont need them if you use AUX)

The Value column can be left clicked to cycle through the different valuation methods for the resultant item: Auction Value (a), Vendor Value (v), Disenchant Value (d) or the greatest of the three different values (the default). Any instance of an item Value being greater than the Cost to create it will have a highlighted Value entry. Optionally, the Value column can be displayed as a percentage of the Cost column.

The Cost column simply sums up the costs for each reagent and reports the total.

Tooltips for each column give more details about the price breakdowns LSW is considering.

##Changelog
v0.6

Updeted way to catch prices. Now it calculate all from AUX market value, not averedge. SO u need Scan daily price to get right prices.
You can do Right-Click on ingradient or item in ATSW while AUX open.
Also it will get crafted ingradient price, not AUX price, if  you can craft it.


>[!NOTE]
>**NOT WORKING w/ ATSW2**
>and NOT updated yet for 1.17.2 TWoW 
