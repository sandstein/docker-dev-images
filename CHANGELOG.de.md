# Änderungsprotokoll

Alle wichtigen Änderungen an den Images und am Build. Die Versionen sind die Release-Tags (`JJ.MM.TT[.n]`), die der
GitHub-Actions-Build auf [Docker Hub](https://hub.docker.com/u/sandstein) veröffentlicht.
Englische Fassung: [CHANGELOG.md](CHANGELOG.md).

## 26.11.23

### Neu
- PHP 8.6 (`php:cli-8.6`, `php:fpm-8.6`, die `-prod`-Varianten und `php-deploy:8.6`). Der Extension-Installer
  unterstützt auf 8.6 noch nicht alle Erweiterungen, deshalb fehlen vorerst: amqp, apcu, gnupg, grpc, imagick, imap,
  lzf, memcached, oauth, redis, xlswriter, xmlrpc, solr, sourceguardian und xdebug. `php:latest` bleibt auf 8.5.
- `skip` je PHP-Version in `docker-bake.hcl` und das Hilfsskript `install-php-extensions-except`, um Erweiterungen
  auszulassen, die eine Version noch nicht installieren kann.
- `sandstein/php-deploy:<version>` für 8.2 bis 8.6, bisher im separaten Repository `docker-deploy-images` gebaut.
  Basis ist jetzt `php:cli-<version>-prod`; die Images werden wie die anderen wöchentlich und für mehrere
  Architekturen gebaut: Benutzer `gitlab-runner` (UID/GID 999), Composer, Deployer, nodejs/npm aus Debian sowie nvm
  mit der Node-LTS, `memory_limit = -1` und `date.timezone = Europe/Berlin`.

### Geändert
- php-deploy: Die Images nutzen `php.ini-production` mit den beiden Einstellungen oben statt einer fast leeren
  `php.ini`. `display_errors` ist jetzt aus.
- php-deploy: Deployer ist je PHP-Version festgelegt: `^8`, für PHP 8.2 `^7` (Deployer 8 braucht PHP 8.3).
- GitHub Actions nutzen ihre Node-24-Versionen.

## 26.11.14.3

### Behoben
- Ein Tag-Push veröffentlicht die Images wieder.

## 26.11.14.2

### Geändert
- Der Build läuft nur noch für Tags, den wöchentlichen Zeitplan und manuelle Läufe, nicht mehr bei Branch-Pushes.

## 26.11.14.1

### Behoben
- Veröffentlichen: Der Push in die GHCR-Staging-Registry wird wiederholt. Er schlug fehl, wenn amd64 und arm64
  gleichzeitig ein neues Paket anlegten.

## 26.11.14

### Neu
- Multi-Arch-Images (amd64 und arm64), nativ auf GitHub Actions gebaut und auf Docker Hub zusammengeführt, nur wenn
  beide Architekturen dieselben Tags liefern. Ein wöchentlicher Build (sonntags 16:12 UTC) hält die Images aktuell.
- Tags `sandstein/php:<typ>-<version>-prod` ohne xdebug, xhprof und node, mit `php.ini-production`.

### Geändert
- Ein Katalog (`docker-bake.hcl`) enthält alle Versionen, dazu ein Dockerfile je Image-Familie. `bin/build.sh` baut
  mit `docker buildx bake`, setzt die Patch-Tags und prüft, dass jedes Image die Version aus seinem Namen enthält.
- `install-dev-tools` installiert die gemeinsamen Werkzeuge in jedem Image.

### Entfernt
- GitLab CI und seine Zeitpläne; GitHub Actions ist der einzige Build.
- Die Quellen der eingefrorenen EOL-Versionen (weiterhin unter dem Tag `26.11.13`).

## 26.11.13

### Behoben
- `php:fpm-8.5` wurde aus PHP 8.4 gebaut.
- Falsche Dockerfiles für elasticsearch 7.6/7.17/8.6 und node 12/14; elasticsearch 8.6 ist jetzt wirklich 8.6.2.
- `php:fpm-8.4` ließ sich nicht bauen, weil gmagick und imagick zusammen installiert wurden; PHP 8.2 bis 8.5 nutzen
  jetzt imagick.
- `modify-user-ids` kommt mit bereits vergebenen UIDs und vorhandenen Gruppen zurecht, ohne sie umzunummerieren.
- php-cli legt kein `VOLUME` mehr für das Home-Verzeichnis an (es erzeugte `~/.ssh` und `~/.config` mit root als
  Besitzer).

### Geändert
- node 22, 24 und 26 (LTS) auf Debian trixie ersetzen node 11 bis 18. ssh und selenium-side-runner nutzen Debian
  trixie.
- PHP-Images setzen `LANG=C.UTF-8`; der PHP-Extension-Installer ist auf eine Version festgelegt.
- `bin/build.sh` bricht bei Fehlern ab und unterstützt `NAMESPACE=test` für lokale Builds.

### Entfernt
- EOL-Versionen sind eingefroren, ihre Images bleiben auf Docker Hub: PHP 7.3 bis 8.1, MariaDB 10.x, MySQL 5.7 und
  8.0, elasticsearch, percona und solr.

## Vor 26.11.13

Siehe Git-Historie. Ältere Tags folgen einem anderen Schema (`23.03.25`, `17486-node-for-all`, …).
