# Base Economy Balance

`BaseEconomyBalance` retunes base card values in Card Shop Simulator Multiplayer so opening packs feels more rewarding without changing card art, names, rarity, stats, elements, or pack placement.

The mod is designed to work with the vanilla card pool and with visual replacement mods such as `GenMTG`.

## What It Changes

- Smooths base card value multipliers across gens 1-7.
- Raises ordinary common/uncommon values enough that standard packs feel worth opening.
- Keeps rare, super rare, god, souvenir, and holiday cards meaningful as chase pulls.
- Preserves all existing card identity and gameplay data except `CardValueMulti`.
- Uses only the safe card registry API: `GetCardDataAllID`, `GetCardData`, and `RegisterCardData`.

## Balance Goal

The goal is fun pack opening:

- Standard packs should usually feel okay to open.
- Selling opened cards can make a bit extra versus purchase cost.
- Opened cards should usually remain below the sealed pack market value when sealed market value is 2x purchase cost.
- Luxury and rare luxury packs remain higher-variance because the game applies hidden premium/foil/frame multipliers.

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

This mod should be loaded alongside visual card replacement mods because it reads existing card records, changes only `CardValueMulti`, and registers the same card data back into the registry.

It applies once on init and again after a short delay so it can win over other init-time card registrations.

## Notes

The safe Lua registry surface does not expose pack drop tables, final card instance pricing, frame weights, or premium variant odds. The mod balances the editable base card value only.

