# Base Economy Balance

`BaseEconomyBalance` is a mod for [Card Shop Simulator Multiplayer](https://store.steampowered.com/app/3569500/Card_Shop_Simulator_Multiplayer/) that retunes base card values and premium trait multipliers so opening packs feels more rewarding without changing card art, names, rarity, stats, elements, or pack placement.

The mod is designed to work with the vanilla card pool and with visual replacement mods such as `GenMTG`.

![Base Economy Balance preview](preview.png)

## What It Changes

- Smooths base card value multipliers across gens 1-7.
- Smooths premium trait multipliers so luxury and rare luxury packs are less dominated by giant jackpot frames.
- Raises ordinary common/uncommon values enough that standard packs feel worth opening.
- Keeps rare, super rare, god, souvenir, and holiday cards meaningful as chase pulls.
- Preserves all existing card identity and gameplay data except `CardValueMulti` and the global trait value table.
- Uses only the safe card registry API: `GetCardDataAllID`, `GetCardData`, `RegisterCardData`, and `RegisterTraitValueData`.

## Balance Goal

The goal is fun pack opening:

- Standard packs should usually feel okay to open.
- Selling opened cards can make a bit extra versus purchase cost.
- Opened cards should usually remain below the sealed pack market value when sealed market value is 2x purchase cost.
- Luxury and rare luxury packs remain higher-variance, but premium trait multipliers are gentler than the sample/default curve.

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

This mod should be loaded alongside visual card replacement mods because it reads existing card records, changes `CardValueMulti`, applies a global trait value table, and registers the same card data back into the registry.

It applies once on init and again after a short delay so it can win over other init-time card registrations.

## Notes

The safe Lua registry surface does not expose pack drop tables, final card instance pricing, frame weights, or premium variant odds. The mod balances the editable base card value and the global trait value table.
