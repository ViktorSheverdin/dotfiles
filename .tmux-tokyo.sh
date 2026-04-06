#!/usr/bin/env bash
declare -gA THEME_COLORS=(
    # Status bar — matches wezterm background for seamless blend
    [statusbar-bg]="#011423"
    [statusbar-fg]="#CBE0F0"

    # Session — muted blue-teal accent
    [session-bg]="#47A8BD"
    [session-fg]="#011423"
    # Session prefix — darker version when prefix is pressed
    [session-prefix-bg]="#2A6A7A"

    # Active window — deep saturated blue (from nvim search highlight)
    [window-active-base]="#0A64AC"
    # Inactive window — barely-there dark blue (from lualine background)
    [window-inactive-base]="#112638"

    # Health states — blue-forward with consistent accents
    [ok-base]="#143652"
    [info-base]="#65D1FF"
    [warning-base]="#FFDA7B"
    [error-base]="#FF4A4A"
)
