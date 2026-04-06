#!/usr/bin/env bash
# =============================================================================
# Theme: Deep Blue
# Variant: Dark
# Description: Deep blue theme matching wezterm + nvim palette
# =============================================================================

declare -gA THEME_COLORS=(
    # Status Bar
    [statusbar-bg]="#011423"
    [statusbar-fg]="#CBE0F0"

    # Session Indicator
    [session-bg]="#47A8BD"
    [session-fg]="#011423"
    [session-prefix-bg]="#2A6A7A"
    [session-copy-bg]="#65D1FF"

    # Windows — active uses same blue as pane border
    [window-active-base]="#0A64AC"
    [window-inactive-base]="#112638"

    # Pane Borders
    [pane-border-active]="#0A64AC"
    [pane-border-inactive]="#112638"

    # Health States
    [ok-base]="#143652"
    [good-base]="#47A8BD"
    [info-base]="#65D1FF"
    [warning-base]="#FFDA7B"
    [error-base]="#FF4A4A"
    [disabled-base]="#1E3A5F"

    # Messages
    [message-bg]="#011423"
    [message-fg]="#CBE0F0"
)
