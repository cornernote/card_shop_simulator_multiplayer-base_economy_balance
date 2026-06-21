# Pack Economy Notes

This note captures the known base-game pack costs and the estimated return from
the current `BaseEconomyBalance` value curve.

## Known Pack Facts

- Each pack opens 6 cards.
- Pack product prices were read manually from the in-game shop/tablet.
- Pack market value depends on pack tier. Standard packs use 2x purchase cost,
  luxury uses 1.5x, and rare luxury uses 1.2x. Use market value as the baseline
  for pack-value ROI, and purchase cost as the baseline for player cash
  profit/loss.
- Gen 2 spell packs have no shop cost. Treat them as game-use items, not card
  sale packs, until proven otherwise.
- Observed standard packs mostly produce common and uncommon cards.
- The safe Lua registry surface exposes setters for drop tables and value
  multipliers, but not getters. Runtime probes cannot dump vanilla rates
  directly.
- The public modding guide documents the default booster weights, trait weights,
  rarity value multipliers, trait value multipliers, and card price formula.

## Known Pack Costs

| Generation | Standard Cost | Standard Market | Luxury Cost | Luxury Market | Rare Luxury Cost | Rare Luxury Market |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Gen 1 | 3 | 6 | 150 | 225 | 1500 | 1800 |
| Gen 2 | 6 | 12 | 300 | 450 | 3000 | 3600 |
| Gen 3 | 9 | 18 | 450 | 675 | 4500 | 5400 |
| Gen 4 | 12 | 24 | 600 | 900 | 6000 | 7200 |
| Gen 5 | 15 | 30 | 750 | 1125 | 7500 | 9000 |
| Gen 6 | 18 | 36 | 900 | 1350 | 9000 | 10800 |
| Gen 7 | 21 | 42 | 1050 | 1575 | 10500 | 12600 |

Known market value multipliers:

| Pack Tier | Market Multiplier | Verified Examples |
| --- | ---: | --- |
| Standard | 2.0x | Gen 1 standard cost 3, market 6 |
| Luxury | 1.5x | Gen 1 luxury 150 -> 225; Gen 7 luxury 1050 -> 1575 |
| Rare Luxury | 1.2x | Gen 1 rare luxury 1500 -> 1800; Gen 2 rare luxury 3000 -> 3600; Gen 7 rare luxury 10500 -> 12600 |

Verified in-game so far:

- Gen 1 standard: `3 -> 6`
- Gen 1 luxury: `150 -> 225`
- Gen 1 rare luxury: `1500 -> 1800`
- Gen 2 standard: `6 -> 12`
- Gen 2 luxury: `300 -> 450`
- Gen 2 rare luxury: `3000 -> 3600`
- Gen 7 luxury: `1050 -> 1575`
- Gen 7 rare luxury: `10500 -> 12600`

Pattern-filled pending checks:

- Gen 3-6 luxury market values are assumed at `1.5x`.
- Gen 3-6 rare luxury market values are assumed at `1.2x`.
- Gen 2 spell packs have no shop cost and are excluded from card-sale EV.

## Break-Even Per Card

Because each pack opens 6 cards, break-even per card is pack cost divided by 6.

| Generation | Standard | Luxury | Rare Luxury |
| --- | ---: | ---: | ---: |
| Gen 1 | 0.50 | 25.00 | 250.00 |
| Gen 2 | 1.00 | 50.00 | 500.00 |
| Gen 3 | 1.50 | 75.00 | 750.00 |
| Gen 4 | 2.00 | 100.00 | 1000.00 |
| Gen 5 | 2.50 | 125.00 | 1250.00 |
| Gen 6 | 3.00 | 150.00 | 1500.00 |
| Gen 7 | 3.50 | 175.00 | 1750.00 |

## Target ROI

The balance goal is not to make packs never profitable. The goal is that opening
packs feels fun, but buying packs just to immediately sell every card is not a
reliable money printer.

There are two useful ROI lenses:

- Pack-value ROI: total opened card value compared with pack market value.
- Cash ROI: total opened card value compared with the actual purchase cost.

Use pack-value ROI for tuning the intended pack economy. Use cash ROI to detect
whether opening packs is an easy money exploit.

For standard packs:

- Most common/uncommon packs should feel okay to open.
- Opening a pack and selling the cards can make a bit extra versus purchase
  cost.
- Opened value should usually remain below the sealed pack's market value.
- A rare or super-rare hit can push a pack into profit.

Working standard-pack ROI targets:

| Generation | Target Cash ROI | Equivalent Pack-Value ROI |
| --- | ---: | ---: |
| Gen 1 | +40% to +80% | -30% to -10% |
| Gen 2 | +10% to +35% | -45% to -32.5% |
| Gen 3 | +10% to +35% | -45% to -32.5% |
| Gen 4 | 0% to +30% | -50% to -35% |
| Gen 5 | 0% to +30% | -50% to -35% |
| Gen 6 | 0% to +30% | -50% to -35% |
| Gen 7 | 0% to +30% | -50% to -35% |

These standard-pack targets assume the player experience should reward opening
packs without making opened cards consistently beat the sealed pack market
value. Premium tiers use lower market multipliers, so their pack-value ROI needs
to be read against the tier-specific market multiplier.

For luxury and rare luxury packs, the ROI target is not yet set because their
value depends on pack-specific rarity, foil, or variant rules that are not
visible through the safe registry data.

Current working target for premium packs:

- Luxury packs should usually lose money unless they hit strong hidden premium
  variants.
- Rare luxury packs can behave like chase/lottery packs, where expected loss is
  acceptable if the rare hits are exciting.
- Do not raise normal card values to make luxury or rare luxury packs break
  even, because that would break shelf-sale balance.

## Current Balanced Value Estimate

The current model is no longer a simple card-value estimate. Version `0.8.1`
sets:

- per-card `CardValueMulti`
- global rarity values
- global trait values
- pack rarity rates
- trait rates by rarity

Because final opened-card price still has hidden game logic, the only reliable
balance check is pack-opening samples. The old spreadsheet-style estimates are
useful for direction, but not accurate enough to treat as current EV.

The current theoretical EV calculator is:

```bash
python3 BaseEconomyBalance/tools/economy_ev.py
```

It mirrors the mod constants from `main.lua` and reads
`GenMTG/docs/current-card-inventory.tsv`. Treat its output as a tuning guide,
then confirm with in-game pack samples.

The immediate test target for `0.8.4` is:

| Pack Type | Desired Feel |
| --- | --- |
| Standard | Cheap and common-heavy, but opened cards slightly beat sealed pack sale after normal selling friction |
| Luxury | Opened cards beat sealed pack sale enough to offset limited shelf slots and occasional cat sales |
| Rare Luxury | Premium chase tier, clearly better opened than sold sealed without replacing event/god packs |

The target is based on player liquidity, not pure market value. A sealed pack is
easy to sell, while opened cards compete for limited card-sale slots and overflow
cards may go to the cat at roughly `70-80%` of market value. Raw opened-card EV
therefore needs to sit above sealed-pack market value so the effective player
result still feels slightly better than selling the sealed pack.

The current theoretical EV estimate is:

| Generation | Standard EV | Luxury EV | Rare Luxury EV |
| --- | ---: | ---: | ---: |
| Gen 1 | 6.74 | 237.67 | 2550.41 |
| Gen 2 | 15.49 | 486.26 | 5074.13 |
| Gen 3 | 27.55 | 810.20 | 8465.59 |
| Gen 4 | 26.33 | 1117.90 | 11826.89 |
| Gen 5 | 36.55 | 1434.94 | 14816.23 |
| Gen 6 | 44.23 | 1667.25 | 16399.10 |
| Gen 7 | 54.64 | 2157.09 | 21275.05 |

Against purchase cost:

| Generation | Standard | Luxury | Rare Luxury |
| --- | ---: | ---: | ---: |
| Gen 1 | +124.6% | +58.4% | +70.0% |
| Gen 2 | +158.2% | +62.1% | +69.1% |
| Gen 3 | +206.1% | +80.0% | +88.1% |
| Gen 4 | +119.4% | +86.3% | +97.1% |
| Gen 5 | +143.7% | +91.3% | +97.5% |
| Gen 6 | +145.7% | +85.2% | +82.2% |
| Gen 7 | +160.2% | +105.4% | +102.6% |

Against sealed market value:

| Generation | Standard | Luxury | Rare Luxury |
| --- | ---: | ---: | ---: |
| Gen 1 | +12.3% | +5.6% | +41.7% |
| Gen 2 | +29.1% | +8.1% | +40.9% |
| Gen 3 | +53.0% | +20.0% | +56.8% |
| Gen 4 | +9.7% | +24.2% | +64.3% |
| Gen 5 | +21.8% | +27.5% | +64.6% |
| Gen 6 | +22.9% | +23.5% | +51.8% |
| Gen 7 | +30.1% | +37.0% | +68.8% |

Version `0.8.4` keeps the full-run observed rates as a baseline, then raises
normal card base values so opened cards beat sealed-pack market value before
selling friction. This compensates for limited sale slots and cat-discounted
overflow while keeping pack tiers distinct.

Version `0.8.4` keeps Holiday/Halloween cards in a premium event-drop tier.
These packs cannot be bought directly, so their EV should sit above Gen 7 rare
luxury while remaining slightly below divine/god packs.

Special pool EV estimates below assume a 6-card pack drawn evenly from that
special pool. They are not confirmed pack EV because the safe registry surface
does not expose special-pack draw tables or prices.

| Special Pool | Cards | 6-Card EV | Per Card EV |
| --- | ---: | ---: | ---: |
| God/divine | 4 | 26864.46 | 4477.41 |
| Holiday/Halloween | 10 | 23397.63 | 3899.60 |
| Souvenir/commemorative | 22 | 324.04 | 54.01 |
| Other 13xx special | 21 | 114.92 | 19.15 |

## Public Modding Guide Findings

Sources saved for later:

- Card Shop Simulator Multiplayer modding guide:
  <https://github.com/showtom-web/Card-Shop-Simulator-Multiplayer-mods/blob/main/README_EN.md>
- SteamDB announcement that mirrors/points at the mod creation guide:
  <https://steamdb.info/patchnotes/20928134/>
- Steam discussion pointing players to the GitHub guide:
  <https://steamcommunity.com/app/3569500/discussions/0/755050863145615479/>

The guide confirms that pack rarity rates and trait rates are weights. They do
not need to sum to `1.0`; larger weights mean higher relative chance.

The guide gives this final opened-card price formula:

```text
CardValueMulti * rarity value multiplier * trait value multiplier * generation value multiplier
```

The guide says generations 1-7 correspond to `1x` through `7x` in that formula.
In Lua card data, the `Gen` field itself is zero-based for normal generation
cards, so the generation value multiplier should be treated as `Gen + 1` only
for normal card IDs in the `1000-7999` range.

Special pack buckets use `Gen` values that do not mean price generations:

| Gen Field | Meaning |
| ---: | --- |
| 0-6 | Normal generations 1-7 |
| 9 | Souvenir/commemorative special pool |
| 10 | Holiday/Halloween special pool |

The Baijiaoling check confirms this. In-game market value for foil Baijiaoling
under `0.8.1` tuning was `945`, which matched:

```text
14 CardValueMulti * 7.5 SuperRare value * 9 Legendary/Foil value = 945
```

Under `0.8.4`, Halloween SuperRare cards use `900` CardValueMulti, so the same
foil check becomes:

```text
900 CardValueMulti * 7.5 SuperRare value * 9 Legendary/Foil value = 60750
```

If `Gen = 10` were a price multiplier, these values would be 11x higher, which
is not what the game shows. EV tooling should therefore use `1x` for special
pack buckets unless a future sample proves a different rule.

### Documented Vanilla Booster Weights

The guide's booster indexes line up with the sample mod and our current mapping:

- `0` = Standard
- `1` = Deluxe, which we map to the UI's lower premium/luxury pack
- `2` = Luxury, which we map to the UI's rare luxury pack

| Pack Index | UI Meaning | Common | Uncommon | Rare | Super Rare | God |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 0 | Standard | 0.894 | 0.010 | 0.005 | 0.001 | not listed |
| 1 | Luxury | 0.205 | 0.690 | 0.100 | 0.005 | not listed |
| 2 | Rare Luxury | 0.000 | 0.035 | 0.055 | 0.010 | not listed |

Because these are weights, the normalized Standard odds are about 98.24% common,
1.10% uncommon, 0.55% rare, and 0.11% super rare. That explains the repeated
"miss, miss, miss" feel from standard packs under vanilla-style rates.

### Documented Vanilla Trait Weights

| Rarity | Basic | Silver | Gold | Holographic | Shiny | Legendary |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Common | 0.700 | 0.100 | 0.100 | 0.070 | 0.029 | 0.001 |
| Uncommon | 0.400 | 0.250 | 0.220 | 0.100 | 0.037 | 0.003 |
| Rare | 0.080 | 0.200 | 0.300 | 0.210 | 0.140 | 0.070 |
| Super Rare | 0.000 | 0.000 | 0.000 | 0.350 | 0.350 | 0.300 |
| God | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 1.000 |

These weights make high-rarity cards heavily biased toward expensive traits.
That is exciting, but it also explains why premium pack value can feel like
either a disaster or a huge spike.

### Documented Vanilla Value Multipliers

| Rarity | Vanilla Multiplier |
| --- | ---: |
| Common | 0.10 |
| Uncommon | 0.50 |
| Rare | 2.00 |
| Super Rare | 10.00 |
| God | 500.00 |

| Trait | Vanilla Multiplier |
| --- | ---: |
| Basic | 1.00 |
| Silver | 2.00 |
| Gold | 5.00 |
| Holographic | 20.00 |
| Shiny | 50.00 |
| Legendary | 200.00 |

This is the missing piece behind the early pack-opening samples. Commons are
extremely cheap because vanilla multiplies common `CardValueMulti` by only
`0.10`, while legendary traits and god rarity can explode card values.

## Current Rarity Bands

The value curve is generation-aware. Early commons/uncommons are intentionally
cheap to prevent standard pack flipping, while rare and better cards remain
meaningful hits.

| Generation | Common Avg | Uncommon Avg | Rare Avg | Super Rare Avg |
| --- | ---: | ---: | ---: | ---: |
| Gen 1 | 1.07 | 1.66 | 4.01 | 9.05 |
| Gen 2 | 1.23 | 1.95 | 4.40 | 9.41 |
| Gen 3 | 1.47 | 2.34 | 4.83 | 10.91 |
| Gen 4 | 0.99 | 1.86 | 4.96 | 11.88 |
| Gen 5 | 1.11 | 1.91 | 5.44 | 12.36 |
| Gen 6 | 1.11 | 1.92 | 5.91 | 11.85 |
| Gen 7 | 1.17 | 2.05 | 6.54 | 13.57 |

## Current Drop Rates, Rarity Values, And Trait Values

Version `0.8.1` registers pack rarity rates, trait rates, global rarity values,
and global trait values. This was learned from two sample mods:

- `_sample/3639546917` uses `RegisterRarityValueData` and
  `RegisterTraitValueData`.
- `_sample/3681574688` uses `RegisterRarityData` and `RegisterTraitData`.

The sample proves we can set pack odds, but it does not expose getters for the
vanilla rates. Vanilla rates still need to be inferred from pack-opening samples.

### Pack Rarity Rates

`_sample/3681574688` uses booster indexes:

- `0` = Standard
- `1` = Deluxe/Luxury
- `2` = Luxury/Rare Luxury

The exact game naming differs between mods and UI labels, so the working mapping
for our notes is:

- Standard UI pack -> booster index `0`
- Luxury UI pack -> booster index `1`
- Rare luxury UI pack -> booster index `2`

`BaseEconomyBalance` now uses:

| Pack Tier | Common | Uncommon | Rare | Super Rare | God |
| --- | ---: | ---: | ---: | ---: | ---: |
| Standard | 0.958 | 0.037 | 0.005 | 0.000 | 0.000 |
| Luxury | 0.100 | 0.340 | 0.500 | 0.060 | 0.000 |
| Rare Luxury | 0.000 | 0.010 | 0.120 | 0.870 | 0.000 |

Standard packs remain mostly common/uncommon, with occasional rare hits. Luxury
and rare luxury packs are shifted away from pure low-rarity misses while keeping
rare luxury high variance. Version `0.8.4` keeps standard packs common-heavy
again so low-cost packs do not print money, pulls luxury's super rate down so
it stays below sealed market value, and pushes rare luxury toward SuperRare
pulls. A full-run capture across normal generation packs saw no god cards from
standard, luxury, or rare luxury packs, so the EV model no longer assumes a
normal-pack god chance.

### Rarity Values

The Gen 1 standard test after `0.5.0` showed pack totals of:

```text
0.49, 0.49, 0.49, 0.36, 0.38, 1.19, 0.27, 0.70
```

Average opened value was `0.55` on a `3.00` cost pack. That was far below the
fun-opening target and showed that commons were still being heavily discounted
by the game's global rarity table.

`BaseEconomyBalance` uses:

| Rarity | Balanced Value |
| --- | ---: |
| Common | 0.30 |
| Uncommon | 0.45 |
| Rare | 1.70 |
| Super Rare | 7.50 |
| God | 35.00 |

Commons are still above vanilla, but much lower than earlier tuning passes.
This keeps common-heavy standard packs playable without making them an obvious
cash exploit. Super rare and god values remain explicit so premium jackpot
values are less dependent on unknown vanilla defaults.

### Trait Values

`_sample/3681574688` also shows `RegisterTraitData(rarity, rates)`, which sets
the odds for premium frames/traits by rarity. The sample forces legendary frames
for every rarity. `BaseEconomyBalance` uses a smoother table instead:

| Rarity | Basic | Silver | Gold | Holographic | Shiny | Legendary |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Common | 0.820 | 0.140 | 0.035 | 0.005 | 0.000 | 0.000 |
| Uncommon | 0.680 | 0.220 | 0.080 | 0.018 | 0.002 | 0.000 |
| Rare | 0.450 | 0.300 | 0.170 | 0.060 | 0.018 | 0.002 |
| Super Rare | 0.300 | 0.280 | 0.220 | 0.140 | 0.050 | 0.010 |
| God | 0.160 | 0.200 | 0.270 | 0.220 | 0.110 | 0.040 |

This should make premium packs less binary by giving higher-rarity pulls a
healthier spread of good frames while keeping legendary frames uncommon.

The sample mod uses this steeper trait curve:

| Trait | Sample Value |
| --- | ---: |
| Basic | 1 |
| Silver | 2 |
| Gold | 5 |
| Holographic | 10 |
| Shiny | 20 |
| Legendary | 35 |

`BaseEconomyBalance` uses:

| Trait | Balanced Value |
| --- | ---: |
| Basic | 1.00 |
| Silver | 1.35 |
| Gold | 2.20 |
| Holographic | 3.60 |
| Shiny | 5.50 |
| Legendary | 9.00 |

This should make luxury and rare luxury packs less dominated by the top premium
frames while keeping premium pulls exciting.

## Opened-Card Value Mechanics

The registry value we can edit is `CardValueMulti`. It is not the whole final
opened-card price. Opened card instances apply additional frame/variant/stat
multipliers on top of the card's base value.

The clearest examples are from repeated Gen 1 cards in screenshots captured
before the `0.4.0` tuning pass:

| Card | Balanced Base At Screenshot Time | Observed Value | Implied Multiplier |
| --- | ---: | ---: | ---: |
| Kaqi Fox | 1.26 | 1.26 | 1x |
| Kaqi Fox | 1.26 | 12.60 | 10x |
| Kaqi Fox | 1.26 | 31.50 | 25x |
| Pan Xiaoda | 1.42 | 0.71 | 0.5x |
| Pan Xiaoda | 1.42 | 14.20 | 10x |
| Volcano Spider | 1.20 | 0.60 | 0.5x |
| Volcano Spider | 1.20 | 3.00 | 2.5x |
| Volcano Spider | 1.20 | 30.00 | 25x |
| White Batmon | 1.20 | 1.20 | 1x |
| White Batmon | 1.20 | 0.60 | 0.5x |
| Thunder Eagle | 1.20 | 0.60 | 0.5x |

This explains why tuning `CardValueMulti` affects premium packs: hidden
premium/foil/frame multipliers appear to scale from the same base value. Raising
base card values makes ordinary pulls better and also makes premium hits larger.

Some card instances also show changed attack/HP, and some premium cards have
very large multipliers that cannot be fully modeled from registry data alone.
The safe mod surface does not currently expose the pack drop table, card frame
weights, stat rolls, or final price formula.

## Observed Pack Samples

### Full Normal-Pack Run, `0.8.2`

Captured with `PackOpenProbe` on 2026-06-21. The run contains 16 packs of each
normal pack type for Gens 2-7, plus 16 Gen 1 standard packs, 16 Gen 1 luxury
packs, and 8 Gen 1 rare luxury packs. Gen 1 rare luxury is the only short
section in this capture.

Aggregate observed rarity mix:

| Pack Tier | Packs | Common | Uncommon | Rare | Super Rare | God |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Standard | 112 | 95.83% | 3.72% | 0.45% | 0.00% | 0.00% |
| Luxury | 112 | 8.48% | 31.10% | 47.17% | 13.24% | 0.00% |
| Rare Luxury | 104 | 0.00% | 3.37% | 38.78% | 57.85% | 0.00% |

Observed by generation and pack type:

| Gen | Pack | Packs | Common | Uncommon | Rare | Super Rare | God |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Gen 1 | Standard | 16 | 94.8% | 4.2% | 1.0% | 0.0% | 0.0% |
| Gen 1 | Luxury | 16 | 7.3% | 37.5% | 47.9% | 7.3% | 0.0% |
| Gen 1 | Rare Luxury | 8 | 0.0% | 4.2% | 35.4% | 60.4% | 0.0% |
| Gen 2 | Standard | 16 | 99.0% | 1.0% | 0.0% | 0.0% | 0.0% |
| Gen 2 | Luxury | 16 | 11.5% | 24.0% | 51.0% | 13.5% | 0.0% |
| Gen 2 | Rare Luxury | 16 | 0.0% | 5.2% | 44.8% | 50.0% | 0.0% |
| Gen 3 | Standard | 16 | 95.8% | 4.2% | 0.0% | 0.0% | 0.0% |
| Gen 3 | Luxury | 16 | 9.4% | 36.5% | 42.7% | 11.5% | 0.0% |
| Gen 3 | Rare Luxury | 16 | 0.0% | 4.2% | 40.6% | 55.2% | 0.0% |
| Gen 4 | Standard | 16 | 94.8% | 4.2% | 1.0% | 0.0% | 0.0% |
| Gen 4 | Luxury | 16 | 9.4% | 32.3% | 42.7% | 15.6% | 0.0% |
| Gen 4 | Rare Luxury | 16 | 0.0% | 3.1% | 36.5% | 60.4% | 0.0% |
| Gen 5 | Standard | 16 | 97.9% | 1.0% | 1.0% | 0.0% | 0.0% |
| Gen 5 | Luxury | 16 | 4.2% | 28.1% | 47.9% | 19.8% | 0.0% |
| Gen 5 | Rare Luxury | 16 | 0.0% | 1.0% | 41.7% | 57.3% | 0.0% |
| Gen 6 | Standard | 16 | 93.8% | 6.2% | 0.0% | 0.0% | 0.0% |
| Gen 6 | Luxury | 16 | 13.5% | 31.2% | 44.8% | 10.4% | 0.0% |
| Gen 6 | Rare Luxury | 16 | 0.0% | 5.2% | 32.3% | 62.5% | 0.0% |
| Gen 7 | Standard | 16 | 94.8% | 5.2% | 0.0% | 0.0% | 0.0% |
| Gen 7 | Luxury | 16 | 4.2% | 28.1% | 53.1% | 14.6% | 0.0% |
| Gen 7 | Rare Luxury | 16 | 0.0% | 1.0% | 38.5% | 60.4% | 0.0% |

Interpretation:

- Standard packs are correctly common-heavy and only rarely hit rare cards.
- Luxury packs are mostly uncommon/rare with a visible super-rare chance.
- Rare luxury packs are mostly rare/super rare and did not show normal-pack god
  cards in this run.
- The EV model should use the observed aggregate rates above until a larger
  capture proves different.

### Current `0.8.0` Samples

These samples were recorded after the `0.8.0` balance pass.

| Pack | Count | Cost | Average | EV Percent | Median | Profit Packs | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Gen 1 Standard | 16 | 3 | 2.38 | 79.3% | 0.90 | 2/16 | Most packs were 0.81-1.38, with two hits at 10.66 and 13.87. |
| Gen 1 Luxury | 16 | 150 | 178.18 | 118.8% | 144.34 | 7/16 | Close to target; one jackpot at 693.36 and a few bad misses. |
| Gen 1 Rare Luxury | 16 | 1500 | 905.74 | 60.4% | 812.26 | 1/16 | Much lower than predicted; rare luxury likely needs a targeted bump. |
| Gen 2 Standard | 16 | 6 | 2.20 | 36.7% | 2.02 | 0/16 | Too low; most packs were near 2.00. |
| Gen 2 Luxury | 16 | 300 | 294.26 | 98.1% | 188.00 | 5/16 | Close to target; average near cost and below 450 market. |
| Gen 2 Rare Luxury | 16 | 3000 | 1858.43 | 61.9% | 1395.87 | 4/16 | Corrected cost makes this a chase/loss pack, not overpowered. |

Interpretation:

- Gen 1 Standard is a little too harsh in observed play, but not wildly off.
- Gen 1 Luxury feels close: average is profitable, median is near cost, and the
  jackpot rate is not constant.
- Gen 1 Rare Luxury is too low in practice. The theoretical model predicted
  `1862.42`, but the observed average was `905.74`.
- Gen 2 Standard is too low in observed play.
- Gen 2 Luxury feels close.
- Gen 2 Rare Luxury is below cost after correcting the pack price to `3000`.

The observed premium-pack samples below were captured under earlier
`BaseEconomyBalance` tuning passes before `0.8.1`. Version `0.8.1` sets pack
rarity rates, trait rates, rarity values, trait values, and base values for a
more fun pack-opening experience, so these samples are useful for understanding
pack behavior but should be retested before treating the ROI numbers as current.

### Gen 1 Luxury

Observed from 4 screenshots. Pack cost is 150, market value is 225, and each
pack contains 6 cards.
These samples show hidden premium variants/foils can appear, but the pack is
still strongly negative EV at the current values.

| Sample | Total Card Value | Cash ROI | Pack-Value ROI |
| --- | ---: | ---: | ---: |
| 1 | 35.88 | -76.08% | -84.05% |
| 2 | 33.77 | -77.49% | -84.99% |
| 3 | 31.00 | -79.33% | -86.22% |
| 4 | 50.40 | -66.40% | -77.60% |
| Average | 37.76 | -74.83% | -83.22% |

Observed high-value pulls included premium/foil cards around 12.60, 14.20,
25.50, 30.00, and 31.50. Even with those hits, Gen 1 luxury did not approach
break-even in this small sample.

### Gen 7 Luxury

Observed from 4 screenshots. Pack cost is 1050, market value is 1575, and each
pack contains 6 cards.
These samples show Gen 7 luxury also has high-variance premium hits. It can
produce jackpot cards, but most observed packs still lost money.

| Sample | Total Card Value | Cash ROI | Pack-Value ROI |
| --- | ---: | ---: | ---: |
| 1 | 250.95 | -76.10% | -84.07% |
| 2 | 1978.97 | +88.47% | +25.65% |
| 3 | 298.21 | -71.60% | -81.07% |
| 4 | 896.08 | -14.66% | -43.11% |
| Average | 856.05 | -18.47% | -45.65% |

The average is below break-even in this tiny sample, but one 1960.00 pull
nearly doubled the pack by itself. This looks closer to a moderate lottery pack
than Gen 1 luxury did.

### Gen 1 Rare Luxury

Observed from 4 screenshots. Pack cost is 1500, market value is 1800, and each
pack contains 6 cards.
These samples show rare luxury behaves more like a high-variance chase pack:
some packs miss badly, while jackpot packs can beat the pack cost.

| Sample | Total Card Value | Cash ROI | Pack-Value ROI |
| --- | ---: | ---: | ---: |
| 1 | 3030.50 | +102.03% | +68.36% |
| 2 | 169.94 | -88.67% | -90.56% |
| 3 | 3163.60 | +110.91% | +75.76% |
| 4 | 569.80 | -62.01% | -68.34% |
| Average | 1733.46 | +15.56% | -3.70% |

The average is positive in this tiny sample, but it is driven by two jackpot
pulls worth 2750 each. Without those jackpot hits, the pack loses heavily. Treat
Gen 1 rare luxury as a lottery pack until there is a larger sample.

### Gen 7 Rare Luxury

Observed from 4 screenshots. Pack cost is 10500, market value is 12600, and each
pack contains 6 cards.
This tier is extremely high variance. Three samples were below cost, and one
large jackpot result made the average nearly break-even.

| Sample | Total Card Value | Cash ROI | Pack-Value ROI |
| --- | ---: | ---: | ---: |
| 1 | 8741.60 | -16.75% | -30.62% |
| 2 | 8705.20 | -17.09% | -30.91% |
| 3 | 616.70 | -94.13% | -95.11% |
| 4 | 22855.56 | +117.67% | +81.39% |
| Average | 10229.77 | -2.57% | -18.81% |

The average is close to break-even, but this is not a steady-value pack. The
observed 19250.00 pull is large enough to determine the whole sample. Treat Gen
7 rare luxury as a jackpot-driven chase pack rather than a normal ROI pack.

## Balance Interpretation

With the current `0.8.1` value curve and pack odds, standard packs made mostly from commons
and uncommons are expected to be close to purchase-cost break-even or modestly
profitable. They should still usually be below the sealed pack's tier-specific
market value.

This intentionally shifts the mod away from strict anti-flip balance and toward
fun pack opening. The player should usually feel like opening packs was worth
doing, while sealed packs still retain a meaningful market-value advantage.

All pack types need fresh samples under `0.8.1`. The old screenshots showed that
luxury and rare luxury packs use hidden premium/foil multipliers, but the exact
current ROI changed when base values, rarity values, trait values, pack rarity
rates, and trait rates were smoothed.
