# Pack Economy Notes

This note captures the known base-game pack costs and the estimated return from
the current `BaseEconomyBalance` value curve.

## Known Pack Facts

- Each pack opens 6 cards.
- Pack product prices were read manually from the in-game shop/tablet.
- Pack market value is expected to be 2x the purchase cost. Use market value as
  the baseline for pack-value ROI, and purchase cost as the baseline for player
  cash profit/loss.
- Observed standard packs mostly produce common and uncommon cards.
- The safe Lua registry surface exposes setters for drop tables and value
  multipliers, but not getters. Runtime probes cannot dump vanilla rates
  directly.
- The public modding guide documents the default booster weights, trait weights,
  rarity value multipliers, trait value multipliers, and card price formula.

## Known Pack Costs

| Generation | Standard | Luxury | Rare Luxury |
| --- | ---: | ---: | ---: |
| Gen 1 | 3 | 150 | 1500 |
| Gen 2 | 6 | 300 | 1000 |
| Gen 3 | 9 | 450 | 4500 |
| Gen 4 | 12 | 600 | 6000 |
| Gen 5 | 15 | 750 | 7500 |
| Gen 6 | 18 | 900 | 9000 |
| Gen 7 | 21 | 1050 | 10500 |

## Break-Even Per Card

Because each pack opens 6 cards, break-even per card is pack cost divided by 6.

| Generation | Standard | Luxury | Rare Luxury |
| --- | ---: | ---: | ---: |
| Gen 1 | 0.50 | 25.00 | 250.00 |
| Gen 2 | 1.00 | 50.00 | 166.67 |
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

- Pack-value ROI: total opened card value compared with pack market value. Pack
  market value is 2x purchase cost.
- Cash ROI: total opened card value compared with the actual purchase cost.

Use pack-value ROI for tuning the intended pack economy. Use cash ROI to detect
whether opening packs is an easy money exploit.

For standard packs:

- Most common/uncommon packs should feel okay to open.
- Opening a pack and selling the cards can make a bit extra versus purchase
  cost.
- Opened value should usually remain below the sealed pack's 2x market value.
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

These targets assume the player experience should reward opening packs without
making opened cards consistently beat the sealed pack market value.

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

The current model is no longer a simple card-value estimate. Version `0.7.0`
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

The immediate test target for `0.7.0` is:

| Pack Type | Desired Feel |
| --- | --- |
| Standard | Usually around purchase cost to modestly profitable, still below sealed market value |
| Luxury | Fewer bad misses, often near cost, occasional strong profit |
| Rare Luxury | Still swingy, but less pure disaster-or-jackpot |

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
In Lua card data, the `Gen` field itself is zero-based, so the generation value
multiplier should be treated as `Gen + 1` for EV estimates.

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
| Gen 1 | 0.67 | 1.23 | 4.01 | 9.05 |
| Gen 2 | 0.99 | 1.79 | 5.01 | 10.17 |
| Gen 3 | 1.39 | 2.46 | 6.07 | 12.49 |
| Gen 4 | 1.78 | 3.19 | 6.79 | 14.30 |
| Gen 5 | 2.18 | 3.63 | 7.92 | 15.58 |
| Gen 6 | 2.38 | 4.00 | 9.05 | 15.77 |
| Gen 7 | 2.67 | 4.52 | 10.39 | 18.45 |

## Current Drop Rates, Rarity Values, And Trait Values

Version `0.7.0` registers pack rarity rates, trait rates, global rarity values,
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
| Standard | 0.720 | 0.230 | 0.045 | 0.005 | 0.000 |
| Luxury | 0.150 | 0.350 | 0.400 | 0.095 | 0.005 |
| Rare Luxury | 0.000 | 0.100 | 0.550 | 0.320 | 0.030 |

Standard packs remain mostly common/uncommon, with occasional rare hits. Luxury
and rare luxury packs are shifted away from pure low-rarity misses while keeping
rare luxury high variance.

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
| Common | 0.80 |
| Uncommon | 1.00 |
| Rare | 2.00 |
| Super Rare | 8.00 |
| God | 35.00 |

Commons are lifted the most because common-heavy standard packs were the main
source of constant misses. Super rare and god values are also made explicit so
premium jackpot values are less dependent on unknown vanilla defaults.

### Trait Values

`_sample/3681574688` also shows `RegisterTraitData(rarity, rates)`, which sets
the odds for premium frames/traits by rarity. The sample forces legendary frames
for every rarity. `BaseEconomyBalance` uses a smoother table instead:

| Rarity | Basic | Silver | Gold | Holographic | Shiny | Legendary |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Common | 0.760 | 0.180 | 0.050 | 0.010 | 0.000 | 0.000 |
| Uncommon | 0.600 | 0.250 | 0.100 | 0.040 | 0.010 | 0.000 |
| Rare | 0.350 | 0.300 | 0.200 | 0.100 | 0.040 | 0.010 |
| Super Rare | 0.200 | 0.250 | 0.250 | 0.180 | 0.090 | 0.030 |
| God | 0.100 | 0.150 | 0.250 | 0.250 | 0.150 | 0.100 |

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
| Silver | 1.50 |
| Gold | 3.00 |
| Holographic | 6.00 |
| Shiny | 10.00 |
| Legendary | 18.00 |

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

The observed premium-pack samples below were captured under earlier
`BaseEconomyBalance` tuning passes before `0.7.0`. Version `0.7.0` sets pack
rarity rates, trait rates, rarity values, trait values, and base values for a
more fun pack-opening experience, so these samples are useful for understanding
pack behavior but should be retested before treating the ROI numbers as current.

### Gen 1 Luxury

Observed from 4 screenshots. Pack cost is 150, market value is 300, and each
pack contains 6 cards.
These samples show hidden premium variants/foils can appear, but the pack is
still strongly negative EV at the current values.

| Sample | Total Card Value | Cash ROI | Pack-Value ROI |
| --- | ---: | ---: | ---: |
| 1 | 35.88 | -76.08% | -88.04% |
| 2 | 33.77 | -77.49% | -88.74% |
| 3 | 31.00 | -79.33% | -89.67% |
| 4 | 50.40 | -66.40% | -83.20% |
| Average | 37.76 | -74.83% | -87.41% |

Observed high-value pulls included premium/foil cards around 12.60, 14.20,
25.50, 30.00, and 31.50. Even with those hits, Gen 1 luxury did not approach
break-even in this small sample.

### Gen 7 Luxury

Observed from 4 screenshots. Pack cost is 1050, market value is 2100, and each
pack contains 6 cards.
These samples show Gen 7 luxury also has high-variance premium hits. It can
produce jackpot cards, but most observed packs still lost money.

| Sample | Total Card Value | Cash ROI | Pack-Value ROI |
| --- | ---: | ---: | ---: |
| 1 | 250.95 | -76.10% | -88.05% |
| 2 | 1978.97 | +88.47% | -5.76% |
| 3 | 298.21 | -71.60% | -85.80% |
| 4 | 896.08 | -14.66% | -57.33% |
| Average | 856.05 | -18.47% | -59.24% |

The average is below break-even in this tiny sample, but one 1960.00 pull
nearly doubled the pack by itself. This looks closer to a moderate lottery pack
than Gen 1 luxury did.

### Gen 1 Rare Luxury

Observed from 4 screenshots. Pack cost is 1500, market value is 3000, and each
pack contains 6 cards.
These samples show rare luxury behaves more like a high-variance chase pack:
some packs miss badly, while jackpot packs can beat the pack cost.

| Sample | Total Card Value | Cash ROI | Pack-Value ROI |
| --- | ---: | ---: | ---: |
| 1 | 3030.50 | +102.03% | +1.02% |
| 2 | 169.94 | -88.67% | -94.34% |
| 3 | 3163.60 | +110.91% | +5.45% |
| 4 | 569.80 | -62.01% | -81.01% |
| Average | 1733.46 | +15.56% | -42.22% |

The average is positive in this tiny sample, but it is driven by two jackpot
pulls worth 2750 each. Without those jackpot hits, the pack loses heavily. Treat
Gen 1 rare luxury as a lottery pack until there is a larger sample.

### Gen 7 Rare Luxury

Observed from 4 screenshots. Pack cost is 10500, market value is 21000, and each
pack contains 6 cards.
This tier is extremely high variance. Three samples were below cost, and one
large jackpot result made the average nearly break-even.

| Sample | Total Card Value | Cash ROI | Pack-Value ROI |
| --- | ---: | ---: | ---: |
| 1 | 8741.60 | -16.75% | -58.37% |
| 2 | 8705.20 | -17.09% | -58.55% |
| 3 | 616.70 | -94.13% | -97.06% |
| 4 | 22855.56 | +117.67% | +8.84% |
| Average | 10229.77 | -2.57% | -51.29% |

The average is close to break-even, but this is not a steady-value pack. The
observed 19250.00 pull is large enough to determine the whole sample. Treat Gen
7 rare luxury as a jackpot-driven chase pack rather than a normal ROI pack.

## Balance Interpretation

With the current `0.7.0` value curve and pack odds, standard packs made mostly from commons
and uncommons are expected to be close to purchase-cost break-even or modestly
profitable. They should still usually be below the sealed pack's 2x market
value.

This intentionally shifts the mod away from strict anti-flip balance and toward
fun pack opening. The player should usually feel like opening packs was worth
doing, while sealed packs still retain a meaningful market-value advantage.

All pack types need fresh samples under `0.7.0`. The old screenshots showed that
luxury and rare luxury packs use hidden premium/foil multipliers, but the exact
current ROI changed when base values, rarity values, trait values, pack rarity
rates, and trait rates were smoothed.
