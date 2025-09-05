MagiskHide Props Config – Zeus v1.1

A fork of Didgeridoohan’s MagiskHide Props Config, updated and extended by Zeusofyork.



This module allows you to:

Change your device’s fingerprint to pass CTS/SafetyNet checks.

Set/reset MagiskHide-sensitive prop values.

Edit or add custom system properties.

Apply props only to specific apps (new Target Apps feature).

Use updated fingerprints including Pixel 8 Pro (Android 15) and Pixel 9 Pro (Android 15).

Run under Magisk, KernelSU, KSUNext, and APatch with universal BusyBox detection.

📦 Installation

Flash the ZIP in Magisk or KernelSU Manager.

Reboot your device.

Open a terminal app and run:

  su
  props

🖥️ Usage
Main Menu

1. Edit device fingerprint – choose from a list of certified fingerprints.

2. Force BASIC key attestation (deprecated, may not work on modern devices).

3. Target Apps – select which apps should receive spoofed props:

Select ALL apps (default).

Add Apps – pick installed packages by number.

Remove Apps – deselect from your current list.

4. Device simulation – set brand, model, build, release, etc.

5. Edit MagiskHide props – toggle sensitive props.

6. Add/edit custom props.

7. Delete prop values.

8. Script settings.

9. Collect logs.

Fingerprints

Scroll through the device list to select a certified fingerprint.

Newly added:

Pixel 8 Pro (Android 15)

Pixel 9 Pro (Android 15)


⚙️ Manual Configuration

The selected Target Apps are stored in /data/adb/modules/magiskhidepropsconf/targetapps.conf



Default content:


  ALL





(means spoofed props apply to all apps)

Example with specific apps only:

  com.google.android.gms
  com.example.bankapp
  com.game.studio


Edit this file manually with vi, nano, or adb pull/push.
One package name per line, no commas.





🛠️ Debugging

This build includes debug logging:

ui_print markers during install (install.sh) and menu execution.

Installer flow messages (BusyBox detection, Target Apps selection, resetprop calls).

🙏 Credits

Didgeridoohan – original MagiskHide Props Config.

Zeusofyork – Target Apps implementation, updated fingerprints, KSU/APatch support.










