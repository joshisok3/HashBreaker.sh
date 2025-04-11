#!/bin/bash

# === CONFIGURATION ===
HASH_FILE="NCLHASH1.txt"
HASH_MODE=23  # Skype hash mode

WORDLISTS=(
  "/path/to/crackstation.txt"
  "/path/to/hashkiller24.txt"
  "/path/to/cyclone.hashesorg.hashkiller.combined.txt"
  "/usr/share/wordlists/rockyou.txt"
)

RULES=(
  "rules/best64.rule"
  "rules/dive.rule"
)

echo "🔥 Welcome to Hashcat Solo Smasher 9000 🔥"
echo "🚨 Hash Mode: $HASH_MODE"
echo "📄 Target Hash File: $HASH_FILE"
echo ""

# === WORDLIST PASSES (no rules) ===
for WL in "${WORDLISTS[@]}"; do
    echo -e "\n🔍 Trying base wordlist: $WL"

    hashcat -a 0 -m $HASH_MODE "$HASH_FILE" "$WL" --potfile-disable --quiet
    if [[ $? -eq 0 ]]; then
        echo -e "\n✅ CRACKED with $WL (no rules):"
        hashcat -a 0 -m $HASH_MODE "$HASH_FILE" "$WL" --show
        exit 0
    fi
done

# === Ask Permission Before Rules ===
read -p $'\n⚠️  No hits from base wordlists. Run rule-based attack? (y/n): ' rules_reply
if [[ "$rules_reply" =~ ^[Yy]$ ]]; then
    for WL in "${WORDLISTS[@]}"; do
        for RULE in "${RULES[@]}"; do
            echo -e "\n🔁 Trying $WL with rule $RULE"
            hashcat -a 0 -m $HASH_MODE "$HASH_FILE" "$WL" -r "$RULE" --potfile-disable --quiet
            if [[ $? -eq 0 ]]; then
                echo -e "\n✅ CRACKED with $WL + $RULE:"
                hashcat -a 0 -m $HASH_MODE "$HASH_FILE" "$WL" -r "$RULE" --show
                exit 0
            fi
        done
    done
else
    echo "🛑 Skipping rules phase. You are a merciful god."
fi

# === Ask Permission Before Full Brute Mask ===
read -p $'\n☠️  Do you want to initiate full brute-force mask attack? (y/n): ' mask_reply
if [[ "$mask_reply" =~ ^[Yy]$ ]]; then
    echo -e "\n💥 Brace yourself. Running full ?a?a?a?a?a?a?a mask. This will take a while."

    hashcat -a 3 -m $HASH_MODE "$HASH_FILE" '?a?a?a?a?a?a?a' --potfile-disable --quiet
    if [[ $? -eq 0 ]]; then
        echo -e "\n✅ CRACKED via brute-force mask:"
        hashcat -a 3 -m $HASH_MODE "$HASH_FILE" '?a?a?a?a?a?a?a' --show
        exit 0
    else
        echo "❌ Brute-force mask did not succeed. Reality remains intact (barely)."
    fi
else
    echo "🙃 Skipping brute-force mask. Probably for the best."
fi

echo -e "\n🚪 All attempts complete. The hash remains unbroken—for now."

