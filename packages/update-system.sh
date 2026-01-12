# Save this as ~/update-system.sh
#!/bin/bash

echo "🔄 Starting system update..."
sudo pacman -Syu

echo ""
echo "🔍 Checking for configuration conflicts..."
pacnew_files=$(sudo find /etc -name "*.pacnew" 2>/dev/null)

if [ -n "$pacnew_files" ]; then
    echo "⚠️  Configuration files need review:"
    echo "$pacnew_files"
    echo ""
    echo "Run: sudo pacdiff"
    echo ""
    read -p "Review now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo DIFFPROG=vim pacdiff
    fi
else
    echo "✅ No configuration conflicts found"
fi

echo ""
echo "🧹 Checking for orphaned packages..."
orphans=$(pacman -Qtdq)
if [ -n "$orphans" ]; then
    echo "Found orphaned packages:"
    echo "$orphans"
    read -p "Remove them? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo pacman -Rns $(pacman -Qtdq)
    fi
else
    echo "✅ No orphaned packages"
fi

echo ""
echo "✅ Update complete!"
