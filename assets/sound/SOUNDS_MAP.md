# Sound map (MVP) - event -> file

All files are original, generated procedurally for this project (no third-party samples).
You can treat them as CC0 / free to use. Format: WAV, mono, 44.1 kHz, 16 bit.
Put the folder at `assets/audio/` and register it in `pubspec.yaml`.

| Event | File | Channel | Notes |
|---|---|---|---|
| Any tap | ui_tap_01.wav | sfx | 0.08 s |
| Button pressed | ui_button_01.wav | sfx | always the same |
| Menu open/close | ui_swoosh_01.wav | sfx | |
| Notification | ui_notification_01.wav | sfx | never loop |
| Action not allowed | ui_blocked_01.wav | sfx | neutral, not punitive |
| Quiz correct, 1st in a streak | quiz_correct_01.wav | sfx | C |
| Quiz correct, 2nd | quiz_correct_02.wav | sfx | D |
| Quiz correct, 3rd | quiz_correct_03.wav | sfx | E |
| Quiz correct, 4th | quiz_correct_04.wav | sfx | G |
| Quiz correct, 5th+ | quiz_correct_05.wav | sfx | A (keep playing this one after the 5th) |
| Quiz wrong | quiz_wrong_01.wav | sfx | soft, low; reset streak counter silently |
| Quiz timer tick | quiz_tick_01.wav | sfx | optional |
| Perfect-streak bonus | quiz_streak_bonus_01.wav | sfx | 1.6 s |
| Quiz finished | quiz_end_01.wav | sfx | |
| Waste picked up | sort_pickup_01.wav | sfx | |
| Waste in correct bin | sort_correct_01.wav | sfx | |
| Waste in wrong bin | sort_wrong_01.wav | sfx | soft "toc" |
| Waste dropped | sort_drop_01.wav | sfx | |
| Room cleaned | room_clean_01.wav | sfx | |
| Coins earned | coin_01.wav | sfx | the single "ching" used everywhere |
| XP bar fills | xp_pling_01.wav | sfx | |
| Big reward / coin shower | reward_coins_cascade_01.wav | sfx | |
| Chest opens | reward_chest_open_01.wav | sfx | |
| Level up | level_up_01.wav | sfx | most important sound, 2.4 s |
| Mission completed | quest_complete_01.wav | sfx | |
| Buy accessory | shop_buy_01.wav | sfx | |
| Pet happy | pet_happy_01.wav | pet | |
| Pet curious | pet_curious_01.wav | pet | |
| Pet sleepy | pet_sleepy_01.wav | pet | |
| Pet thankful (after reward/item) | pet_thanks_01.wav | pet | |
| Background music | music_loop_calm_01.wav | music | 12 s seamless loop, low volume |

## Rules for the code
- Three channels with separate volume: music, sfx, pet. One global mute.
- Lower the music volume ~0.5 s when level_up / chest / bonus plays (ducking).
- Optional: vary playback rate +/-4% on tap and coin sounds.
- A missing or failed sound must never crash the app (wrap playback in try/catch).
