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
- Exact drop tables, rarity odds, and hidden foil/variant value multipliers are
  not currently exposed through the safe Lua registry surface.

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

These estimates use the current `BaseEconomyBalance` formula against the
inventory dump in `GenMTG/docs/current-card-inventory.tsv`.

The full-pool average treats every card in a generation as equally likely, so it
overstates standard pack value when standard packs mostly produce commons and
uncommons. The common/uncommon estimate is the better working estimate for
standard pack anti-flip balance.

| Generation | Full-Pool 6-Card Avg | Full-Pool Cash ROI | Full-Pool Pack-Value ROI | Common/Uncommon 6-Card Avg | Common/Uncommon Cash ROI | Common/Uncommon Pack-Value ROI |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Gen 1 | 23.70 | +689.90% | +294.90% | 5.37 | +78.90% | -10.50% |
| Gen 2 | 25.27 | +321.10% | +110.60% | 7.30 | +21.70% | -39.10% |
| Gen 3 | 30.48 | +238.70% | +69.30% | 10.92 | +21.30% | -39.40% |
| Gen 4 | 37.73 | +214.40% | +57.20% | 12.30 | +2.50% | -48.80% |
| Gen 5 | 38.01 | +153.40% | +26.70% | 15.72 | +4.80% | -47.60% |
| Gen 6 | 40.93 | +127.40% | +13.70% | 16.80 | -6.70% | -53.30% |
| Gen 7 | 52.13 | +148.20% | +24.10% | 20.59 | -1.90% | -51.00% |

Compared with the fun-opening target, common/uncommon standard packs are now
close: Gen 1 is generous, Gen 2-5 are modestly profitable, and Gen 6-7 are just
under purchase cost before rare hits.

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

## Current Trait Values

Version `0.5.0` also registers a gentler global trait value table with
`RegisterTraitValueData`. This was learned from `_sample/3639546917`, which
uses the same safe registry function.

The sample mod uses this steeper trait curve:

| Trait | Sample Value |
| --- | ---: |
| Basic | 1 |
| Silver | 2 |
| Gold | 5 |
| Holographic | 10 |
| Shiny | 20 |
| Legendary | 35 |

`BaseEconomyBalance` now uses:

| Trait | Balanced Value |
| --- | ---: |
| Basic | 1.00 |
| Silver | 1.50 |
| Gold | 3.00 |
| Holographic | 6.00 |
| Shiny | 10.00 |
| Legendary | 18.00 |

This should make luxury and rare luxury packs less dominated by the top premium
frames while keeping premium pulls exciting. The mod intentionally does not call
`RegisterRarityValueData`, because rarity is already handled by the per-card
`CardValueMulti` curve. Stacking a global rarity table on top would be harder to
reason about and could overcorrect the economy.

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
`BaseEconomyBalance` tuning passes before `0.5.0`. Version `0.5.0` raises base
values and smooths trait multipliers for a more fun pack-opening experience, so
these samples are useful for understanding pack behavior but should be retested
before treating the ROI numbers as current.

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

With the current `0.5.0` value curve, standard packs made mostly from commons
and uncommons are expected to be close to purchase-cost break-even or modestly
profitable. They should still usually be below the sealed pack's 2x market
value.

This intentionally shifts the mod away from strict anti-flip balance and toward
fun pack opening. The player should usually feel like opening packs was worth
doing, while sealed packs still retain a meaningful market-value advantage.

Premium packs need fresh screenshots under `0.5.0`. The old screenshots showed
that luxury and rare luxury packs use hidden premium/foil multipliers, but the
exact current ROI changed when base values were raised and trait multipliers
were smoothed.
