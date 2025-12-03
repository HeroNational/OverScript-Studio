## Menu & Media Hub – Plan de mise en œuvre

1) Objectif
- Ajouter un menu latéral/overlay qui regroupe : paramètres existants, infos système, liste des vidéos avec lecteur intégré.
- Remplacer le bouton « paramètres » de la toolbox par un bouton hamburger qui ouvre ce menu.
- Sur l’accueil, mettre le même bouton hamburger à côté du sélecteur de langue pour ouvrir le menu.

2) Contenu du menu
- Onglet/section Paramètres : réutiliser l’écran de paramètres existant (embed ou navigation interne).
- Onglet/section Infos système : afficher plateforme (OS, version Flutter), résolution fenêtre, GPU/CPU si dispo via `dart:io`/`platform` (données simples, sans permission).
- Onglet/section Vidéos : lister les fichiers vidéo présents dans un répertoire dédié de l’app (ex. Documents/OverScriptStudio/Recordings) et permettre la lecture intégrée (player dans le menu).

3) UI/UX
- Bouton hamburger dans la toolbox (remplace l’icône paramètres) qui ouvre une `SideSheet`/`Drawer` ou une page modale pleine largeur sur mobile.
- Bouton hamburger sur l’accueil (près du dropdown de langue) qui ouvre le même menu.
- Player vidéo simple (play/pause, position) dans la section Vidéos.

4) Technique
- Ajouter `video_player` comme dépendance pour la lecture.
- Créer un composant `AppMenu` (ConsumerWidget) avec trois sections (paramètres, infos système, vidéos).
- Ajouter un service léger pour récupérer la liste des vidéos dans un dossier (path_provider) et les lire.
- Gestion des permissions : non nécessaire pour la lecture locale (fichiers de l’app). Pas d’écriture/recording dans ce lot.

5) Étapes
- Intégrer la dépendance `video_player`.
- Ajouter le bouton hamburger (toolbox + accueil) qui ouvre le menu.
- Implémenter `AppMenu` avec les trois sections et le lecteur vidéo basique.
- Brancher la liste des vidéos sur un dossier local (sans création/écriture).

