## Caméra, Enregistrement & Menu – Plan d’implémentation

1) Fonctionnalités demandées
- Lancer automatiquement l’enregistrement vidéo (caméra + micro) à la fin du compte à rebours.
- Caméra en vignette discrète ou en fond du prompteur, avec réglage d’opacité du texte pour voir l’orateur.
- Paramétrer : auto-start caméra, choix caméra/micro, opacité du prompt, affichage fond/vignette.
- Menu unique (hamburger) regroupant : Paramètres, Infos système, Liste des vidéos avec lecteur intégré.
- Bouton hamburger dans la toolbox (remplace Paramètres) et sur l’accueil près du sélecteur de langue.
- Fonctionnalités valables mobile + desktop.

2) Dépendances & services
- `video_player` pour la lecture des vidéos locales (intégrée au menu).
- Service d’inventaire des vidéos : `VideoLibraryService` (dossier local).
- À venir (enregistrement) : service de capture par plateforme (mobile : camera/record, desktop : webrtc ou équivalent).

3) Paramétrage (SettingsModel)
- `autoStartCamera` (bool) : démarrer la caméra/enregistrement au lancement du prompt.
- `cameraAsBackground` (bool) : afficher la caméra en fond.
- `promptOpacity` (double 0.2–1.0) : opacité du texte quand la caméra est en fond.
- `selectedCameraId`, `selectedMicId` (string) : device sélectionné.
- UI : switches + sliders + dropdowns (device list placeholders, en attendant détection réelle).

4) Menu (UI)
- Composant `AppMenuSheet` (Drawer/BottomSheet selon form factor).
- Sections :
  - Paramètres : bouton vers l’écran de settings.
  - Infos système : OS, résolution, version Flutter (basique).
  - Vidéos : liste du dossier Recordings, lecteur intégré via `video_player`.
- Bouton hamburger :
  - Toolbox : remplace l’icône Paramètres.
  - Accueil : placé près du sélecteur de langue.

5) Intégration prompt
- Au démarrage après compte à rebours : si `autoStartCamera` → appeler le service de capture (stub dans ce lot).
- Overlay caméra :
  - Mode fond : caméra en arrière-plan, texte avec opacité réglable.
  - Mode vignette : petite preview togglable.
- Enregistrement : stub pour l’instant (à brancher avec camera/webrtc ultérieurement), sans bloquer l’UI.

6) Étapes réalisées dans ce lot
- Ajout des champs settings (caméra/opacity).
- Menu hamburger + menu UI (paramètres, infos système, liste vidéos + lecteur).
- Bouton hamburger sur accueil et dans la toolbox.
- Lecture vidéo locale via `video_player`.

7) Étapes suivantes (à venir)
- Détection réelle des caméras/micros par plateforme.
- Implémentation capture/enregistrement (mobile : camera/record, desktop : webrtc) et stockage dans Recordings.
- Superposition réelle de la preview caméra (fond/vignette) dans le prompteur.
