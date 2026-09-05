import QtQuick
import qs.Commons

// Rounded, bordered surface shared by the OSD, notification toasts, launcher
// and power menu, so all four read as one system and pick up Style/Color
// changes (hyprctl rounding, matugen palette) identically.
Rectangle {
    radius: Style.cornerRadius
    color: Color.alpha(Color.background, 0.97)
    border.width: Math.max(1, Style.space(2))
    // Matches the first stop of Hyprland's active-window border gradient
    // (active_border_1 = primary), not the muted inactive-window color.
    border.color: Color.accent
}
