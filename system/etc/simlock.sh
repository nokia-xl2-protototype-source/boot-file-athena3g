#!/system/bin/sh

/system/bin/am broadcast -a android.intent.action.SIM_STATE_CHANGED -e ss LOCKED -e reason PERSO