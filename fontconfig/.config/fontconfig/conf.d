<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>

  <!-- Preferred Sans (UI font) -->
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Inter</family>
      <family>Noto Sans</family>
      <family>Liberation Sans</family>
    </prefer>
  </alias>

  <!-- Preferred Monospace (terminal + code) -->
  <alias>
    <family>monospace</family>
    <prefer>
      <family>JetBrains Mono</family>
      <family>Fira Code</family>
      <family>Source Code Pro</family>
    </prefer>
  </alias>

  <!-- Emoji fallback -->
  <alias>
    <family>emoji</family>
    <prefer>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>

  <!-- General fallback (so missing glyphs don’t show squares) -->
  <alias>
    <family>serif</family>
    <prefer>
      <family>Noto Serif</family>
      <family>DejaVu Serif</family>
    </prefer>
  </alias>

</fontconfig>

