# my-ptero-theme

Custom Pterodactyl Panel theme for XIAOCIA game hosting.
Accent: #5865F2 | Base: Pterodactyl v1.13.x

## Structure

```
my-ptero-theme/
├── assets/
│   ├── bg.jpg       ← background image (1920×1080 recommended)
│   └── logo.png     ← login page logo (transparent background)
├── Pterodactyl_XIAOCIA_Theme.css
├── index.tsx
├── install.sh
└── repair.sh
```

## Install

```sh
bash <(curl -s https://raw.githubusercontent.com/X14OC14/my-ptero-theme/main/install.sh)
```

## Customization

Edit `Pterodactyl_XIAOCIA_Theme.css` — all colors are CSS variables at the top of the file:

```css
:root {
  --accent:        #5865F2;
  --accent-dark:   #3c45a5;
  --accent-dim:    rgba(88, 101, 242, 0.20);
  --accent-border: rgba(88, 101, 242, 0.40);
  ...
}
```

Replace `assets/bg.jpg` and `assets/logo.svg` with your own files, then rebuild the panel.
