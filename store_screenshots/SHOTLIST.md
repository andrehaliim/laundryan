# Store screenshot shot list

Take each screenshot by hand, save it to `raw/<locale>/<name>.png`
(`.jpg` / `.webp` also fine), then run from the project root:

```
python store_screenshots/generate.py
```

Output: `framed/<locale>/<name>.png` (1080x1920) and
`framed/banner_<locale>.png` (1920x1080).

| File | Screen | Setup |
|---|---|---|
| 01_sessions | Sessions (home tab) | Light mode. 3–4 active sessions in different phases (Dropped, Washing, Ready for pickup). Scrolled to top. |
| 02_checklist | Pickup checklist | Open a "Ready for pickup" session, start verification. Some items ticked Returned, one marked Lost, one partial quantity. |
| 03_summary_whatsapp | Checklist summary | Finish a checklist with at least one Lost item so the WhatsApp / call buttons show. |
| 04_session_detail | Session detail | A session in the Washing phase: phase timeline, ready time and laundry contact visible. |
| 05_report_missing | Checklist mismatch sheet | During verification, tap "Report mismatch" on a missing item: Lost / Swapped choice and a short description filled in. |
| 06_wardrobe | Wardrobe tab | Grid with real-looking photos, a category filter visible, a few items "at the laundry". |
| 07_add_item | Add wardrobe item | Photo picked, category, quantity and a short note filled in. Keyboard closed. |
| 08_add_session | New session form | Laundry name, WhatsApp number, drop-off and ready time filled, reminder switch on. Scroll so the reminder is visible. |
| 09_categories | Manage categories | Default plus a few custom categories with their icons. |
| 10_sessions_dark | Sessions (home tab) | Same data as 01, Settings → Theme → Dark. |

Banner uses `02_checklist` (left), `01_sessions` (center) and
`06_wardrobe` (right).

## Capture tips

- Same device for every shot, portrait, no notifications, full battery
  or a clean status bar (Android demo mode:
  `adb shell settings put global sysui_demo_allowed 1`, then
  `adb shell am broadcast -a com.android.systemui.demo -e command enter`).
- Realistic demo data, no personal data (fake laundry names and phone
  numbers, your own clothing photos are fine if nothing personal shows).
- Switch the app language (Settings → Language) for each locale and save
  English shots to `raw/en/`, Indonesian shots to `raw/id/`.
- `config.json` assumes a 1080 px wide screenshot with a ~100 px status
  bar (`crop_top`). Adjust both if your device differs.
