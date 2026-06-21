#!/usr/bin/env python3
"""Estimate pack EV for the current BaseEconomyBalance constants."""

from __future__ import annotations

import csv
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MODS = ROOT.parent
INVENTORY = MODS / "GenMTG" / "docs" / "current-card-inventory.tsv"

PACK_COSTS = {
    0: {"standard": 3, "luxury": 150, "rare_luxury": 1500},
    1: {"standard": 6, "luxury": 300, "rare_luxury": 1000},
    2: {"standard": 9, "luxury": 450, "rare_luxury": 4500},
    3: {"standard": 12, "luxury": 600, "rare_luxury": 6000},
    4: {"standard": 15, "luxury": 750, "rare_luxury": 7500},
    5: {"standard": 18, "luxury": 900, "rare_luxury": 9000},
    6: {"standard": 21, "luxury": 1050, "rare_luxury": 10500},
}

RARITY_NAMES = {
    0: "common",
    1: "uncommon",
    2: "rare",
    3: "super",
    4: "god",
}

RARITY_VALUES = {
    0: 0.30,
    1: 0.45,
    2: 1.70,
    3: 7.50,
    4: 35.00,
}

TRAIT_VALUES = {
    "basic": 1.00,
    "silver": 1.35,
    "gold": 2.20,
    "holographic": 3.60,
    "shiny": 5.50,
    "legendary": 9.00,
}

TRAIT_RATES = {
    0: {"basic": 0.82, "silver": 0.14, "gold": 0.035, "holographic": 0.005, "shiny": 0.0, "legendary": 0.0},
    1: {"basic": 0.68, "silver": 0.22, "gold": 0.08, "holographic": 0.018, "shiny": 0.002, "legendary": 0.0},
    2: {"basic": 0.45, "silver": 0.30, "gold": 0.17, "holographic": 0.06, "shiny": 0.018, "legendary": 0.002},
    3: {"basic": 0.30, "silver": 0.28, "gold": 0.22, "holographic": 0.14, "shiny": 0.05, "legendary": 0.01},
    4: {"basic": 0.16, "silver": 0.20, "gold": 0.27, "holographic": 0.22, "shiny": 0.11, "legendary": 0.04},
}

PACK_RATES = {
    "standard": {0: 0.95, 1: 0.04, 2: 0.009, 3: 0.001, 4: 0.0},
    "luxury": {0: 0.08, 1: 0.32, 2: 0.47, 3: 0.115, 4: 0.005},
    "rare_luxury": {0: 0.0, 1: 0.02, 2: 0.35, 3: 0.53, 4: 0.10},
}


def clamp(value: float, low: float, high: float) -> float:
    return max(low, min(high, value))


def round2(value: float) -> float:
    return int((value * 100) + 0.5) / 100


def scale_clamped(value: float, in_low: float, in_high: float, out_low: float, out_high: float) -> float:
    t = 0.0
    if in_high > in_low:
        t = (value - in_low) / (in_high - in_low)
    t = clamp(t, 0.0, 1.0)
    return out_low + ((out_high - out_low) * t)


def generation_index(card_id: int) -> int:
    if 1000 <= card_id < 8000:
        return int(clamp((card_id // 1000) - 1, 0, 6))
    return 0


def balanced_value(card_id: int, rarity: int, current: float) -> float:
    if 1314 <= card_id <= 1323:
        if rarity == 3:
            return 14.00
        t = clamp((card_id - 1314) / 7, 0, 1)
        return round2(8.00 + (4.00 * t))

    if 9000 <= card_id < 10000:
        if current >= 6:
            return 6.00
        return 3.00

    if rarity == 4 or card_id >= 100000:
        return 24.00

    gen = generation_index(card_id)

    if rarity == 0:
        return round2(scale_clamped(current, 0.85, 1.40, 0.45 + (0.08 * gen), 0.85 + (0.12 * gen)))
    if rarity == 1:
        return round2(scale_clamped(current, 0.84, 1.60, 0.90 + (0.14 * gen), 1.55 + (0.18 * gen)))
    if rarity == 2:
        return round2(scale_clamped(current, 0.94, 2.30, 3.25 + (0.28 * gen), 5.75 + (0.35 * gen)))
    if rarity == 3:
        return round2(scale_clamped(current, 1.00, 1.90, 8.50 + (0.40 * gen), 14.00 + (0.55 * gen)))

    return round2(current)


def weighted_average(weights: dict[int | str, float], values: dict[int | str, float]) -> float:
    total_weight = sum(weights.values())
    if total_weight <= 0:
        return 0.0
    return sum((weight / total_weight) * values[key] for key, weight in weights.items())


def load_cards() -> list[dict[str, float | int | str]]:
    cards = []
    with INVENTORY.open(newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f, delimiter="\t"):
            card_id = int(row["CardID"])
            rarity = int(row["Rarity"])
            gen = int(row["Gen"])
            current = float(row["CardValueMulti"])
            base = balanced_value(card_id, rarity, current)
            trait_ev = weighted_average(TRAIT_RATES[rarity], TRAIT_VALUES)
            final_ev = base * RARITY_VALUES[rarity] * trait_ev * (gen + 1)
            cards.append({
                "card_id": card_id,
                "gen": gen,
                "rarity": rarity,
                "base": base,
                "trait_ev": trait_ev,
                "final_ev": final_ev,
            })
    return cards


def main() -> None:
    cards = load_cards()
    by_gen_rarity: dict[int, dict[int, list[dict[str, float | int | str]]]] = defaultdict(lambda: defaultdict(list))
    for card in cards:
        by_gen_rarity[int(card["gen"])][int(card["rarity"])].append(card)

    print("# BaseEconomyBalance EV estimate")
    print()
    print("Uses documented formula: CardValueMulti * rarity value * trait value * generation multiplier.")
    print("Each pack opens 6 cards. Empty rarity buckets are skipped and pack weights are renormalized.")
    print()
    print("| Generation | Pack | EV | Cost ROI | Market ROI |")
    print("| --- | --- | ---: | ---: | ---: |")

    for gen in range(7):
        rarity_avg = {}
        for rarity, rarity_cards in by_gen_rarity[gen].items():
            rarity_avg[rarity] = sum(float(card["final_ev"]) for card in rarity_cards) / len(rarity_cards)

        for pack_name in ("standard", "luxury", "rare_luxury"):
            available_weights = {
                rarity: weight
                for rarity, weight in PACK_RATES[pack_name].items()
                if weight > 0 and rarity in rarity_avg
            }
            per_card = weighted_average(available_weights, rarity_avg)
            ev = per_card * 6
            cost = PACK_COSTS[gen][pack_name]
            cash_roi = ((ev / cost) - 1) * 100
            market_roi = ((ev / (cost * 2)) - 1) * 100
            label = pack_name.replace("_", " ").title()
            print(f"| Gen {gen + 1} | {label} | {ev:.2f} | {cash_roi:+.1f}% | {market_roi:+.1f}% |")


if __name__ == "__main__":
    main()
