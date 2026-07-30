#!/usr/bin/env python3
"""
Build CLDR emoji keyword JSON files for EmojiHelper.
Merges annotations + annotationsDerived into inverted index.
Uses TTS (primary name) priority for better emoji selection.
"""

import xml.etree.ElementTree as ET
import json
import sys
import os

SKIN_TONES = {"\U0001F3FB", "\U0001F3FC", "\U0001F3FD", "\U0001F3FE", "\U0001F3FF"}

# Manual overrides for common words where CLDR picks a non-intuitive emoji
OVERRIDES = {
    "en": {
        # Food & Grocery
        "tea": "☕", "coffee": "☕", "chicken": "🍗", "fish": "🐟",
        "rice": "🍚", "orange": "🍊", "pasta": "🍝", "sugar": "🍬",
        "fruit": "🍎", "vegetable": "🥬", "groceries": "🛒", "shopping": "🛒",
        # Daily
        "iron": "👔", "doctor": "🩺", "dentist": "🦷", "pharmacy": "💊",
        "clean": "🧹", "exercise": "🏋", "run": "🏃", "walk": "🚶",
        "baby": "👶", "game": "🎮", "pool": "🏊", "paint": "🎨",
        # Travel
        "car": "🚗", "flight": "✈️", "travel": "✈️", "vacation": "🏖️",
        "camp": "🏕",
        # Personal & Emotion
        "home": "🏠", "sport": "⚽", "market": "🛒", "food": "🍽",
        "heart": "❤️", "music": "🎵", "water": "💧", "flower": "💐",
        "fire": "🔥", "rain": "🌧", "sun": "☀️", "moon": "🌙",
        "star": "⭐", "tree": "🌳", "gift": "🎁", "party": "🎉",
        "love": "❤️", "kiss": "💋", "ring": "💍", "cake": "🎂",
        "wine": "🍷", "beer": "🍺",
    },
    "tr": {
        # Market / Yiyecek
        "çay": "☕", "kahve": "☕", "tavuk": "🍗", "balık": "🐟",
        "makarna": "🍝", "pirinç": "🍚", "portakal": "🍊", "mısır": "🌽",
        "un": "🌾", "bal": "🍯", "reçel": "🫙", "deterjan": "🧴",
        "meyve": "🍎", "dondurma": "🍦", "kek": "🍰", "alışveriş": "🛒",
        "salça": "🥫", "yoğurt": "🥛", "kaşar": "🧀", "sucuk": "🥩",
        "mercimek": "🫘", "bulgur": "🌾", "bisküvi": "🍪", "cips": "🥔",
        "kola": "🥤", "gazoz": "🥤", "mendil": "🧻",
        # Günlük
        "ütü": "👔", "doktor": "🩺", "koşu": "🏃", "kargo": "📦",
        "fatura": "🧾", "eczane": "💊", "kira": "🏠", "randevu": "📅",
        "tırnak": "💅", "egzersiz": "🏋", "yürüyüş": "🚶", "saç": "💇",
        "makyaj": "💄",
        # Seyahat
        "tatil": "🏖️", "benzin": "⛽", "şapka": "🧢", "deniz": "🏖",
        "havuz": "🏊", "kamp": "🏕",
        # Kişisel & Ev
        "çiçek": "💐", "boyama": "🎨", "lamba": "💡", "perde": "🪟",
        "halı": "🧹",
        # Genel
        "kalp": "❤️", "su": "💧", "ateş": "🔥", "spor": "⚽",
        "yemek": "🍽", "müzik": "🎵", "para": "💰", "bebek": "👶",
        "yağmur": "🌧", "güneş": "☀️", "ay": "🌙", "yıldız": "⭐",
        "ağaç": "🌳", "hediye": "🎁", "parti": "🎉", "aşk": "❤️",
        "öpücük": "💋", "yüzük": "💍", "pasta": "🎂", "şarap": "🍷",
        "bira": "🍺",
    }
}

def has_skin_tone(cp):
    return any(c in SKIN_TONES for c in cp)

def is_emoji_presentation(cp):
    if len(cp) == 0:
        return False
    first = ord(cp[0])
    if first < 0x2000:
        return False
    return True

def parse_xml(xml_path):
    """Parse CLDR XML, return (keywords: {emoji: [kw]}, tts: {emoji: name})"""
    tree = ET.parse(xml_path)
    root = tree.getroot()

    keywords = {}
    tts = {}

    for ann in root.iter("annotation"):
        cp = ann.get("cp", "")
        is_tts = ann.get("type", "") == "tts"

        if cp in SKIN_TONES or has_skin_tone(cp) or not is_emoji_presentation(cp):
            continue

        text = ann.text or ""

        if is_tts:
            tts[cp] = text.strip().lower()
        else:
            kws = [k.strip().lower() for k in text.split("|") if k.strip()]
            if cp in keywords:
                existing = set(keywords[cp])
                keywords[cp].extend(k for k in kws if k not in existing)
            else:
                keywords[cp] = kws

    return keywords, tts

def build_inverted_index(emoji_keywords, tts_map):
    """Build inverted index with TTS priority."""
    # Track: keyword -> [(emoji, is_tts_match)]
    single_candidates = {}  # word -> [(emoji, priority)]
    multi_candidates = {}   # phrase -> [(emoji, priority)]

    for emoji, keywords in emoji_keywords.items():
        tts_name = tts_map.get(emoji, "")
        tts_words = set(tts_name.split())

        for kw in keywords:
            words = kw.split()
            # Priority: 0 = exact TTS name match, 1 = TTS word match, 2 = regular keyword
            if kw == tts_name:
                priority = 0
            elif all(w in tts_words for w in words):
                priority = 1
            else:
                priority = 2

            if len(words) > 1:
                if kw not in multi_candidates:
                    multi_candidates[kw] = []
                multi_candidates[kw].append((emoji, priority))
                # Also index individual words
                for w in words:
                    if len(w) >= 2:
                        word_priority = 1 if w in tts_words else 2
                        if w not in single_candidates:
                            single_candidates[w] = []
                        single_candidates[w].append((emoji, word_priority))
            else:
                if len(kw) >= 2:
                    word_priority = 0 if kw == tts_name else (1 if kw in tts_words else 2)
                    if kw not in single_candidates:
                        single_candidates[kw] = []
                    single_candidates[kw].append((emoji, word_priority))

    # Pick best emoji per keyword (lowest priority number wins)
    single = {}
    for word, candidates in single_candidates.items():
        # Sort by priority, deduplicate
        seen = set()
        sorted_c = sorted(candidates, key=lambda x: x[1])
        best = None
        for emoji, pri in sorted_c:
            if emoji not in seen:
                seen.add(emoji)
                if best is None:
                    best = emoji
        if best:
            single[word] = best

    multi = {}
    for phrase, candidates in multi_candidates.items():
        seen = set()
        sorted_c = sorted(candidates, key=lambda x: x[1])
        best = None
        for emoji, pri in sorted_c:
            if emoji not in seen:
                seen.add(emoji)
                if best is None:
                    best = emoji
        if best:
            multi[phrase] = best

    return single, multi

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_dir = sys.argv[1] if len(sys.argv) > 1 else script_dir

    os.makedirs(output_dir, exist_ok=True)

    for lang in ["tr", "en"]:
        annotations_path = os.path.join(script_dir, f"annotations_{lang}.xml")
        derived_path = os.path.join(script_dir, f"derived_{lang}.xml")

        # Parse annotations
        ann_kw, ann_tts = parse_xml(annotations_path)
        der_kw, der_tts = parse_xml(derived_path)

        # Merge
        all_kw = dict(ann_kw)
        all_tts = dict(ann_tts)

        for emoji, kws in der_kw.items():
            if emoji in all_kw:
                existing = set(all_kw[emoji])
                all_kw[emoji].extend(k for k in kws if k not in existing)
            else:
                all_kw[emoji] = kws

        for emoji, name in der_tts.items():
            if emoji not in all_tts:
                all_tts[emoji] = name

        # Build index
        single, multi = build_inverted_index(all_kw, all_tts)

        # Apply manual overrides (single word only)
        overrides = OVERRIDES.get(lang, {})
        for word, emoji in overrides.items():
            single[word] = emoji

        output = {
            "multiWord": dict(sorted(multi.items())),
            "words": dict(sorted(single.items()))
        }

        out_path = os.path.join(output_dir, f"emoji_keywords_{lang}.json")
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(output, f, ensure_ascii=False, indent=2)

        print(f"{lang}: {len(output['words'])} words, {len(output['multiWord'])} multi-word -> {out_path}")
        print(f"  Size: {os.path.getsize(out_path) / 1024:.1f} KB")

if __name__ == "__main__":
    main()
