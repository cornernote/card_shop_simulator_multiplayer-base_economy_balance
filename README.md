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

Estimated `0.8.5` pack EV from `tools/economy_ev.py`:

| Generation | Standard EV | Standard Market ROI | Luxury EV | Luxury Market ROI | Rare Luxury EV | Rare Luxury Market ROI |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Gen 1 | 5.08 | -15.3% | 189.87 | -15.6% | 2040.32 | +13.4% |
| Gen 2 | 11.70 | -2.5% | 388.39 | -13.7% | 4059.36 | +12.8% |
| Gen 3 | 20.83 | +15.7% | 647.00 | -4.1% | 6772.43 | +25.4% |
| Gen 4 | 20.01 | -16.6% | 893.08 | -0.8% | 9460.14 | +31.4% |
| Gen 5 | 27.79 | -7.4% | 1146.34 | +1.9% | 11852.91 | +31.7% |
| Gen 6 | 33.73 | -6.3% | 1331.67 | -1.4% | 13119.71 | +21.5% |
| Gen 7 | 41.71 | -0.7% | 1722.59 | +9.4% | 17018.90 | +35.1% |

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
