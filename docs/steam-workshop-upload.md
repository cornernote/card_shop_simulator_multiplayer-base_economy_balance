# Steam Workshop Upload

This project can be published to Steam Workshop with SteamCMD from the local
uploader folder:

```text
C:\Program Files (x86)\Steam\steamapps\common\Card Shop Simulator Multiplayer\CardShopSim\Mods\_uploader
```

Current Workshop item:

- Workshop page: not published yet
- Published file ID: `0`
- App ID: `3569500`

After the first successful upload, SteamCMD should report the new published file
ID. Replace `publishedfileid "0"` in `BaseEconomyBalance\workshop.vdf` with that
ID before future updates.

## Files Used

The uploader folder contains the SteamCMD install:

```text
_uploader\steamcmd.exe
```

The Workshop VDF is kept in this repo:

```text
BaseEconomyBalance\workshop.vdf
```

SteamCMD can be downloaded from:

<https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip>

Reference upload docs:

<https://github.com/showtom-web/Card-Shop-Simulator-Multiplayer-mods/blob/main/README_EN.md#upload-to-steam-workshop>

`workshop.vdf` points SteamCMD at the mod folder and the Workshop preview image:

```text
"workshopitem"
{
    "appid"            "3569500"
    "publishedfileid"  "0"
    "contentfolder"    "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Card Shop Simulator Multiplayer\\CardShopSim\\Mods\\BaseEconomyBalance"
    "previewfile"      "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Card Shop Simulator Multiplayer\\CardShopSim\\Mods\\BaseEconomyBalance\\workshop.jpg"
    "visibility"       "0"
    "title"            "Base Economy Balance"
    "description"      "Retunes base card values so opening packs feels better without replacing card art, card names, rarity, stats, elements, or pack placement."
    "changenote"       "version 0.4.0"
}
```

## Before Uploading

1. Make sure the repo is committed and pushed.
2. Make sure `workshop.jpg` exists and is a square JPEG.
3. Make sure `workshop.txt` has the Steam wiki/BBCode description.
4. Make sure `workshop.vdf` points to the correct absolute `contentfolder` and
   `previewfile`.
5. If this is an update, make sure `publishedfileid` is the real Workshop item
   ID, not `0`.
6. Do not paste or commit Steam passwords, guard codes, or session files.

## Upload Command

Run this from PowerShell inside `_uploader`:

```powershell
.\steamcmd.exe +login <steam_username> <steam_password> +workshop_build_item ..\BaseEconomyBalance\workshop.vdf +quit
```

Steam Guard may ask for mobile confirmation. Confirm it in the Steam Mobile app,
then wait for SteamCMD to finish uploading.

## After Uploading

SteamCMD only sends the VDF description field during the build. For the full
formatted Workshop page text, paste the contents of:

```text
BaseEconomyBalance\workshop.txt
```

into the Steam Workshop description editor.

If this was the first upload, update `workshop.vdf` and this document with the
new Workshop page URL and published file ID, then commit the change.

Useful local logs after an upload attempt:

```text
_uploader\logs\stderr.txt
_uploader\logs\workshop_log.txt
_uploader\workshopbuilds\depot_build_3569500.log
```

