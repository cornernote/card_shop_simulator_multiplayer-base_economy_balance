# Base Economy Balance

`BaseEconomyBalance` is a mod for [Card Shop Simulator Multiplayer](https://store.steampowered.com/app/3569500/Card_Shop_Simulator_Multiplayer/) that retunes base card values, pack rarity odds, rarity multipliers, and premium traits so opening packs feels more rewarding without changing card art, names, rarity, stats, elements, or pack placement.

The mod is designed to work with the vanilla card pool and with visual replacement mods such as `GenMTG`.

![Base Economy Balance preview](preview.png)

## What It Changes

- Smooths base card value multipliers across gens 1-7.
- Smooths pack rarity odds so premium packs are not pure miss-or-jackpot chaos.
- Smooths rarity multipliers so common-heavy standard packs are not constant misses.
- Smooths premium trait odds and multipliers so luxury and rare luxury packs are less dominated by giant jackpot frames.
- Raises ordinary common/uncommon values enough that standard packs feel worth opening.
- Keeps rare, super rare, god, souvenir, and holiday cards meaningful as chase pulls.
- Preserves all existing card identity and gameplay data except `CardValueMulti`, pack rarity odds, global rarity values, and global trait odds/values.
- Uses only sample-proven card registry APIs for card data, rarity values, trait values, rarity rates, and trait rates.

## Balance Goal

The goal is fun pack opening:

- Standard packs should feel okay to open without becoming a reliable money printer.
- Luxury packs should sit close to sealed-pack market value, sometimes above.
- Rare luxury packs should be the clear open-over-sell chase tier.
- Event packs such as Halloween should remain premium because they are drops, not ordinary shop purchases.
- The balance leaves room for free map cards, achievement rewards, limited shelf slots, and cat sales below market value.

## Current EV

Estimated `0.8.7` pack EV from `tools/economy_ev.py`:

| Generation | Standard EV | Standard Market ROI | Luxury EV | Luxury Market ROI | Rare Luxury EV | Rare Luxury Market ROI |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Gen 1 | 5.40 | -10.0% | 247.47 | +10.0% | 1889.39 | +5.0% |
| Gen 2 | 10.80 | -10.0% | 494.95 | +10.0% | 3959.39 | +10.0% |
| Gen 3 | 16.20 | -10.0% | 742.67 | +10.0% | 6211.96 | +15.0% |
| Gen 4 | 21.60 | -10.0% | 989.91 | +10.0% | 8639.16 | +20.0% |
| Gen 5 | 26.99 | -10.0% | 1237.13 | +10.0% | 11245.05 | +24.9% |
| Gen 6 | 32.39 | -10.0% | 1484.85 | +10.0% | 14038.67 | +30.0% |
| Gen 7 | 37.79 | -10.0% | 1732.97 | +10.0% | 17014.58 | +35.0% |

## Estimated Old EV

Estimated old/default EV using the documented vanilla booster weights, vanilla
rarity/trait multipliers, and the original registry `CardValueMulti` values:

| Generation | Standard EV | Standard Market ROI | Luxury EV | Luxury Market ROI | Rare Luxury EV | Rare Luxury Market ROI |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Gen 1 | 11.77 | +96.1% | 88.64 | -60.6% | 803.41 | -55.4% |
| Gen 2 | 23.34 | +94.5% | 179.10 | -60.2% | 1614.27 | -55.2% |
| Gen 3 | 38.57 | +114.3% | 290.83 | -56.9% | 2714.81 | -49.7% |
| Gen 4 | 52.84 | +120.2% | 389.02 | -56.8% | 3719.42 | -48.3% |
| Gen 5 | 67.06 | +123.5% | 494.35 | -56.1% | 4733.90 | -47.4% |
| Gen 6 | 75.11 | +108.6% | 577.27 | -57.2% | 5342.50 | -50.5% |
| Gen 7 | 95.89 | +128.3% | 736.01 | -53.3% | 7056.10 | -44.0% |

The old estimate explains the uneven feel: standard packs could mathematically
overperform sealed market value, while luxury and rare luxury packs were far
below sealed market value unless hidden premium/card-instance variance carried
the opening.

Special pool estimates, assuming 6 cards drawn evenly from the pool:

| Pool | 6-Card EV | Per Card EV |
| --- | ---: | ---: |
| God/divine | 24178.01 | 4029.67 |
| Holiday/Halloween | 21057.86 | 3509.64 |
| Souvenir/commemorative | 324.04 | 54.01 |

The current value curve is documented in:

```text
BaseEconomyBalance/docs/pack-economy-notes.md
```

## Install

Place the folder in the game's mods directory:

```text
CardShopSim/Mods/BaseEconomyBalance/main.lua
```

The mod applies automatically when the game loads mods.

## Compatibility

This mod should be loaded alongside visual card replacement mods because it reads existing card records, changes `CardValueMulti`, applies pack/rate/value tables, and registers the same card data back into the registry.

It applies once on init and again after a short delay so it can win over other init-time card registrations.

## Notes

The safe Lua registry surface does not expose getters for vanilla pack drop tables, final card instance pricing, frame weights, or premium variant odds. The mod sets balanced pack rarity rates, trait rates, rarity values, trait values, and editable base card values.
