# nixfiles

Configuration personnelle pour deux machines :

- `macbook-benjamin` : macOS Apple Silicon, géré par nix-darwin, Home Manager
  et Homebrew ;
- `homelab` : Firebat MN56 en NixOS `x86_64-linux`, serveur sans interface
  graphique.

Le système de base, le moteur de conteneurs Docker, Home Assistant et la stack
Grimmory sont configurés. Pangolin/Newt et Paperless-ngx seront ajoutés
progressivement.

## Organisation

```text
.
├── flake.nix
├── hosts/
│   ├── macbook/
│   └── homelab/
├── modules/
│   ├── home/       # configuration de l'utilisateur, partagée si utile
│   ├── darwin/     # système macOS et Homebrew
│   └── nixos/      # système NixOS et moteur de conteneurs du serveur
├── services/       # définitions Compose versionnées des applications
└── config/         # fichiers de configuration déployés par Home Manager
```

Les imports sont volontairement explicites. Il n'y a ni `flake-parts`, ni
auto-découverte, ni package personnalisé pour garder le chemin d'évaluation
facile à suivre.

## Ce qui est partagé

- Git et l'identité Git ;
- Zsh, ses plugins et le prompt Spaceship ;
- les conventions Home Manager.

Les outils de développement ne sont installés que sur le Mac. Nix installe
`mise`, puis mise fournit les versions épinglées suivantes :

- Node.js `26.5.0` ;
- pnpm `11.11.0` ;
- Rust `1.96.1` ;
- .NET `8.0.420`.

## Installation du Mac

### 1. Prérequis

Faire une sauvegarde avant la première activation. Installer ensuite Lix, qui
est compatible avec nix-darwin et dispose d'un désinstalleur :

```bash
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

Ouvrir un nouveau terminal puis vérifier :

```bash
nix --version
```

Homebrew existe déjà sur ce Mac. `nix-homebrew.autoMigrate` adoptera
l'installation `/opt/homebrew` à la première activation.

### 2. Évaluer sans appliquer

Depuis ce dépôt :

```bash
nix flake check --all-systems --no-build
nix build .#darwinConfigurations.macbook-benjamin.system
```

### 3. Première activation

```bash
sudo nix run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  switch --flake .#macbook-benjamin
```

Les activations suivantes utilisent simplement :

```bash
sudo darwin-rebuild switch --flake .#macbook-benjamin
```

Home Manager sauvegarde un fichier existant en `*.hm-backup` lorsqu'il doit en
prendre possession. Vérifier ces sauvegardes avant de les supprimer.

### 4. Installer les runtimes mise

```bash
mise install
mise list
```

Berkeley Mono reste une installation manuelle depuis la copie licenciée de la
police. Bitwarden, Logi Options+, QWERTY-fr et certaines autres applications
peuvent également demander des permissions macOS lors du premier lancement.
Après la première activation, redémarrer macOS pour charger QWERTY-fr. Il sera
ensuite sélectionné automatiquement. Raycast démarre à l'ouverture de session
et utilise `Cmd + Espace`, à la place du raccourci Spotlight correspondant.

Les anciennes formules Homebrew `git`, `gh`, `just`, `mise` et `duti` ne sont
pas supprimées automatiquement pendant cette première
migration. Après validation des versions Nix, elles pourront être retirées et
`homebrew.onActivation.cleanup` pourra passer de `none` à `check`.

`thefuck` reste géré par Homebrew : il a été retiré de Nixpkgs 26.05 faute de
maintenance compatible avec les versions récentes de Python.

## Installation du Firebat

L'installation remplace Windows. Sauvegarder auparavant les données, la clé de
récupération BitLocker éventuelle et les informations nécessaires à une
réinstallation de Windows.

1. Démarrer l'ISO minimale NixOS 26.05 en mode UEFI.
2. Préparer une partition EFI FAT32 portant le label `boot` et une partition
   ext4 portant le label `nixos`.
3. Monter la racine sous `/mnt` et l'EFI sous `/mnt/boot`.
4. Copier ce dépôt sous `/mnt/etc/nixos`.
5. Comparer le résultat de `nixos-generate-config --root /mnt` avec
   `hosts/homelab/hardware-configuration.nix`, notamment les modules initrd et
   les identifiants réseau.
6. Installer puis définir le mot de passe initial de `benjamin` :

```bash
sudo nixos-install --flake /mnt/etc/nixos#homelab
sudo nixos-enter --root /mnt -c 'passwd benjamin'
```

Le serveur utilise Ethernet et DHCP. Il autorise temporairement SSH par mot de
passe uniquement sur le réseau local. Avant toute exposition supplémentaire,
ajouter la clé publique Bitwarden dans `users.users.benjamin.openssh.authorizedKeys`
et passer `PasswordAuthentication` à `false`.

### Conteneurs

NixOS installe Docker avec le plugin Compose, démarre le démon au boot et crée
`/srv/containers` pour les fichiers Compose et les données persistantes. Le
compte `benjamin` appartient au groupe `docker` ; cet accès est équivalent à un
accès root et doit rester réservé au compte administrateur.

Après la première activation, fermer puis rouvrir la session SSH afin de
charger le nouveau groupe, puis vérifier le socle :

```bash
systemctl is-active docker
docker version
docker compose version
ls -ld /srv/containers
docker run --rm hello-world
```

Le nettoyage hebdomadaire ne concerne que les ressources Docker inutilisées
depuis plus de sept jours. Les volumes ne sont jamais supprimés automatiquement.
Les futures applications utiliseront des réseaux Docker privés et ne publieront
pas de ports sur toutes les interfaces sans décision explicite.

### Home Assistant

Home Assistant Container est démarré automatiquement par systemd. Son image est
épinglée et sa configuration persistante se trouve dans
`/srv/containers/home-assistant/config`. Le port `8123` n'est pas ouvert dans le
pare-feu NixOS.

Après avoir récupéré les changements et reconstruit le serveur :

```bash
sudo nixos-rebuild switch --flake .#homelab
systemctl status compose-home-assistant --no-pager
docker compose --file /etc/homelab/home-assistant/compose.yaml ps
docker compose --file /etc/homelab/home-assistant/compose.yaml logs --tail 100
```

Depuis le Mac, créer un tunnel SSH en laissant cette commande ouverte :

```bash
ssh -L 8123:127.0.0.1:8123 benjamin@ADRESSE_IP_DU_HOMELAB
```

Ouvrir ensuite <http://localhost:8123> pour terminer l'assistant de première
configuration. Le tunnel SSH est temporaire ; Pangolin/Newt fournira ensuite
l'accès permanent sans ouvrir de port entrant sur le routeur.

### Grimmory

Grimmory est déployé avec MariaDB dans une stack séparée. L'image Grimmory est
épinglée en `v3.3.3`, les données sont conservées dans
`/srv/containers/grimmory` et l'application écoute uniquement sur
`127.0.0.1:6060`.

Après la reconstruction NixOS, préparer le fichier de secrets sur le serveur :

```bash
sudo cp /etc/homelab/grimmory/grimmory.env.example \
  /var/lib/homelab/grimmory/grimmory.env
sudoedit /var/lib/homelab/grimmory/grimmory.env
sudo chmod 600 /var/lib/homelab/grimmory/grimmory.env
sudo systemctl start compose-grimmory
```

Remplacer les deux valeurs `CHANGE_ME` par des mots de passe longs et uniques.
Vérifier ensuite :

```bash
systemctl status compose-grimmory --no-pager
docker compose --env-file /var/lib/homelab/grimmory/grimmory.env \
  --file /etc/homelab/grimmory/compose.yaml ps
docker compose --env-file /var/lib/homelab/grimmory/grimmory.env \
  --file /etc/homelab/grimmory/compose.yaml logs --tail 100
```

Depuis le Mac, utiliser un second tunnel SSH :

```bash
ssh -N -L 6060:127.0.0.1:6060 benjamin@192.168.64.3
```

Ouvrir ensuite <http://localhost:6060>. La documentation officielle de Grimmory
décrit les répertoires `data`, `books`, `bookdrop` et MariaDB utilisés par cette
stack.

## Utilisation courante

```bash
just check
just build-mac
just switch-mac
just build-homelab
just switch-homelab
```

Mettre à jour les entrées épinglées, contrôler le diff puis reconstruire :

```bash
just update
git diff flake.lock
just check
```

Sur NixOS, un rollback ponctuel peut être appliqué avec :

```bash
sudo nixos-rebuild switch --rollback
```

Les générations NixOS restent aussi sélectionnables dans le menu systemd-boot.
