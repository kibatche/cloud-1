# cloud-1 - Ansible

- [cloud-1 - Ansible](#cloud-1---ansible)
  - [Documentations](#documentations)
  - [Concepts](#concepts)
    - [`Control-node`](#control-node)
    - [`Managed nodes`](#managed-nodes)
    - [`Inventory`](#inventory)
    - [`Playbooks`](#playbooks)
    - [`Modules`](#modules)
    - [`Plugins`](#plugins)
  - [Bonnes pratiques et tips](#bonnes-pratiques-et-tips)
  - [Le fichier de configuration](#le-fichier-de-configuration)
    - [Le fichier `ansible.cfg`](#le-fichier-ansiblecfg)
    - [Le cli `ansible-config`](#le-cli-ansible-config)
  - [Le cli `ansible`](#le-cli-ansible)
    - [Introduction](#introduction)
    - [Quelques options a connaitre](#quelques-options-a-connaitre)
    - [Les modules](#les-modules)
  - [L'`inventory`](#linventory)
    - [Qu'est-ce que c'est ?](#quest-ce-que-cest-)
    - [Le fichier d'inventaire](#le-fichier-dinventaire)
    - [Hierarchisation d'un projet ansible](#hierarchisation-dun-projet-ansible)
  - [Le `playbook`](#le-playbook)
    - [Quelques options](#quelques-options)
    - [Exemple d'un simple playbook avec le module debug](#exemple-dun-simple-playbook-avec-le-module-debug)
  - [Le module `file`](#le-module-file)
    - [Exemple d'utilisation du module file](#exemple-dutilisation-du-module-file)
  - [Le module `user`](#le-module-user)
    - [Quelques options utiles du module `user`](#quelques-options-utiles-du-module-user)
    - [Quelques exemple de l'utilisation du module `user`](#quelques-exemple-de-lutilisation-du-module-user)
  - [Les `register` et le module `stat`](#les-register-et-le-module-stat)
    - [Les options utiles du module `stat`](#les-options-utiles-du-module-stat)
    - [Exemple d'utilisation du module `stat` avec un `register`](#exemple-dutilisation-du-module-stat-avec-un-register)
    - [Quelques notes a propos des `registers`](#quelques-notes-a-propos-des-registers)
  - [Les boucles : `with_items` et boucles `loop`](#les-boucles--with_items-et-boucles-loop)
    - [Les boucles `with_<lookup_name>`](#les-boucles-with_lookup_name)
    - [Exemples d'utilisation des boucles `with_`](#exemples-dutilisation-des-boucles-with_)
    - [Acces a des elements de l'`inventory`](#acces-a-des-elements-de-linventory)
  - [Le module `apt`](#le-module-apt)
    - [Quelques options utiles du module `apt`](#quelques-options-utiles-du-module-apt)
    - [exemple de l'utilisation du module `apt`](#exemple-de-lutilisation-du-module-apt)
    - [Redemarrage du serveur grace au module `reboot`](#redemarrage-du-serveur-grace-au-module-reboot)
  - [Gestion des cles SSH avec les modules `ansible.posix.authorized_key` et `community.crypto.openssh_keypair`](#gestion-des-cles-ssh-avec-les-modules-ansibleposixauthorized_key-et-communitycryptoopenssh_keypair)
    - [Quelques options utiles du modules `openssh_keypair`](#quelques-options-utiles-du-modules-openssh_keypair)
    - [Exemple d'utilisation du module `openssh_keypair`](#exemple-dutilisation-du-module-openssh_keypair)
    - [Quelques options utiles du module `authorized_key`](#quelques-options-utiles-du-module-authorized_key)
    - [Exemple d'utilisation du module `authorized_key`](#exemple-dutilisation-du-module-authorized_key)
  - [`delegate_to`, `run_once`, `local`, `local_action`](#delegate_to-run_once-local-local_action)
    - [Exemple de delegation](#exemple-de-delegation)
    - [Exemple d'une `local_action`](#exemple-dune-local_action)
    - [Exemple de `run_once`](#exemple-de-run_once)

## Documentations

Le site officiel de ansible : [lien](https://docs.ansible.com/)

Les videos tres completes de xavki sur youtube : [lien](https://www.youtube.com/watch?v=8Hb-i9lXdXA&list=PLn6POgpklwWoCpLKOSw3mXCqbRocnhrh-&index=1)

## Concepts

### `Control-node`

La machine sur laquelle est installee le cli ansible (`ansible-playbook`, `ansible`, `ansible-vault`). Cela peut etre n'importe quel ordinateur avec les specifications necessaires.

### `Managed nodes`

On parle aussi de `hosts`. Ce sont les machines cibles, comme un serveur par exemple, qui vont etre gerees par ansible.

Ansible n'est normalement pas installe sur ces machines, sauf cas specifiques et deconseilles.

### `Inventory`

Une liste de `managed nodes` provisionnes par l'intermediaire d'une ou plusieurs `inventory sources`. L'inventaire peut servir a specifier differentes informations sur differents nodes, par exemple l'adresse IP. Il peut etre egalement utilise pour assigne des groupes, aui permet aussi bien de selectionner des nodes dans les `plays` que de gerer l'assignement des variables au sein des blocs (bulk assignement, a checker ce que c'est exactement).

Les fichiers sources des `inventory` peut aussi etre denomme par `hostfile`.

### `Playbooks`

Ils contiennent les `Plays`, qui sont les unites basiques des executions operees par ansible. C'est aussi bien une notion abstraite d'execution que la description des fichiers sur lesquelles `ansible-playbook` opere.

Les `playbooks` sont ecrits en YAML afin de faciliter leur lecture.

- `Plays` : c'est le contexte principal d'execution d'ansible. C'est objet `playbook` lie les `managed nodes` aux taches definies. Un `Play` contient les variables, les roles et une liste ordonnee de tahce, et peut etre execute repetitivement. Il consiste en une sorte de bloucle implicite sur les hotes lies ainsi que les taches, tout en definissant comment iterer sur ces donnees.
  - `Roles` : Une distribution limitees de contenu Ansible reutilisables (taches, gestionnaires (handler), variables, plugins, templates et fichiers) a utiliser au sein d'un `Play`. Pour utiliser uyne ressource d'un role, ce dernier doit etre importe.
  - `Tasks` : La deifnition d'une action a appliquer sur un hote gere. Il est possible d'executer une seule tache par l'intermediaire d'un commande cree pour en utilisant `ansible` ou `ansible-console`.
  - `Handlers` : Une forme specifique de `task`, qui ne s'execute qu'une fois notifiee par une tache precedente qui a eu pour resultat un changement de statut (`changed status`).

### `Modules`

Le code ou les binaires que ansible copie ou execute au sein des `managed nodes` - au besoin - afin d'accomplir une action specifique deifnie au sein d'une `Task`.

### `Plugins`

Morceaux de code qui etendent les capacites d'Ansible. 

## Bonnes pratiques et tips

- Generer une cle ssh avec un mot de passe (voir si c'est genant pour le travail de ansible)
- Dans le fichier `authorized_keys` on peut egalement rajouter un `from="10.12.10.*,192.168.1.1",no-X11-forwarding ssh-rsa {key...}`. Cela permet de n'autoriser que les connexion avec cette cle que depuis l'adresse ou le host name specifie (serveur de rebond) et de ne pas relayer l'affichage graphique.
- **Il est conseille** de creer une cle SSH avec un mot de passe et d'utiliser un agent pour se connecter sans besoin de mot de passe (a repeter probablement a chque lancement de la `control node`) :

```bash
# generation
➜  ~ ssh-keygen 
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/user/.ssh/id_ed25519): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/user/.ssh/id_ed25519
Your public key has been saved in /home/user/.ssh/id_ed25519.pub
<SNIP>
# deploiement de l'agent
➜  ~ eval `ssh-agent`
Agent pid 4559;
# creation de l'identite et ajout au pool de gestion de l'agent
➜  ~ ssh-add 
Enter passphrase for /home/user/.ssh/id_ed25519: 
Identity added: /home/user/.ssh/id_ed25519 (user@cloud1)
```

- Pour effacer l'identite de l'agent : `ssh-add -D`

- On peut configurer l'hote sur lequel on se connecte avec SSH pour se faciliter la vie. On peut par exemple faire en sorte de juste ecrire `ssh cloud-1` Exemple :

```bash
touch ~/.ssh/config
chmod 600 ~/.ssh/config
vim ~/.ssh/config

Host cloud-1
    Hostname chbd-cloud1.duckdns.org
    User root
    Port 22
    LogLevel INFO
    ForwardAgent yes #sert a ce connecter en mode ssh cloud-1
    AddKeysToAgent yes
    ForwardX11 no
```

- On peut tester la connexion a un serveur distant et la presence d'un interpreteur python accepte via la commande : `ansible -i "cloud-1," all -m ping`. Ici on se connecte au serveur cloud1.duckdns.org et fait un ping dessus ainsi qu'une decouverte de l'interpreteur installe. Le flag `-i` correspond a l'option `--inventory` qui specifie l'hote a tester (voir ci-dessus).

## Le fichier de configuration

On peut configurer ansible soit :

- *via* le cli `ansible-config`
- soit *via* l fichier ansible.cfg

### Le fichier `ansible.cfg`

On peut mettre le fichier de configuration dans:

- `ansible.cfg` (dans le dossier courant)
- `~/.ansible.cfg` (dans le /home)
- `/etc/ansible/ansible.cfg` (dans le dossier dedie aux configuration `/etc`)

La prise en compte des fichiers se fait dans de haut en bas. Le haut etant prioritaire sur le bas.

> [!WARNING]
> Si le fichier `ansible.cfg` est dans un dossier scriptible par tout le monde, ansible ne le prendra pas en compte car n'importe qui serait en mesure de mettre son propre fichier de configuration, et ainsi executer des commandes malicieuse sur le ou les serveur(s) gere(s) par ansible. Il faut donc mettre en place des droits appropries, par exemple en ne permettant qu'aux personne faisant parties d'un de pouvoir ecrire dans le dossier ou se trouve la configuration.

### Le cli `ansible-config`

On peut generer une configuration par defaut complete (avec prise en compte des ;odules installes) avec la commande suivante :

```bash
ansible-config init --disabled -t all > ansible.cfg
```

Cela est un bon point de depart pour customiser le comportement de ansible. Cependant, il faut faire attention ou place le fichier, comme vu a la section [Le fichier ansible.cfg](#le-fichier-ansiblecfg).

## Le cli `ansible`

### Introduction

Il est peu utilise. `ansible-playbook` est beaucoup plus utilise.

Sert a faire :

- des tests (type ping)
- des tests sur l'inventaire
- jouer des taches (meme si pas specialement fait pour)
- et d'autres options similaire a la commande `ansible-playbook`

### Quelques options a connaitre

- `-u` : utilisateur distant utilise
- `-b` : passer les commandes en mode elevaton de privilege (sudo)
- `-k`, `--ask-pass` : demande de mot de passe SSH
- `-K`, `--ask-become-pass` : mot de passe pour elevation de privilege
- `-C`, `--check` : pour faire un dry run (ne fait aucun changement et permet de constater les differences si elles existent)
- `-D`, `--diff` : imprimer les differences sur le terminal
- `--key-file` : specifier la cle ssh privee
- `-e`, `--extra-var` : definir des variables
- `--ask-vault-pass` : demander le mot de passe du vault (coffre de mot de passe)
- `--vault-password-file` : fichier de deverouillage du vault
- `-f`, `--fork` : permet d'augmenter les threads pour la parallelisation
- `-vvv` : activer le mode verbeux pour le debug

### Les modules

Les modules servent a executer des morceaux de code. Il en existe de tres nombreux, dont on peut retrouver les principaux sur ce [lien](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/).

Le modules prennent souvent un argument de type "var=value". On peut egalement ecrire les modules directement au sein des playbooks.

Quelques modules :

- `command` : permet d'executer une commande sur le serveur gere. [Lien de la doc](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/command_module.html)

```bash
ansible -i "cloud-1," all -m command -a id
```

- `shell` : permet d'executer des commandes a la maniere du shell bash, avec pipes, tests (`||`, `&&`). [Lien de la doc](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/shell_module.html)

```bash
ansible -i "cloud-1," all -m shell -a "cat test.txt | grep whatever"
```

- `apt` : permet d'utiliser le programme apt afin de mettre a jour les paquets. [Lien de la doc](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html)

```bash
# met a jour le cache
ansible -i "cloud-1," all -m apt -a "update_cache=yes"
# installe les mises a jour. Options possibles  : yes/safe, full, no
ansible -i "cloud-1," all -m apt -a "upgrade=yes"
```

> [!TIP]
> Si l'utilisateur distant n'est pas root, il faut utiliser les options `-b -K` qui permettent l'elevation de privileges. **Il faut obligatoirement que python soit installe sur la machine distante.**
> Sinon faire : `ansible -i "cloud-1," all -m raw -a "apt install python3"` et ensuite utiliser le module `apt` ou tout autre module souhaite (qui fonctionnent tous avec python hormis le module `raw`)

- `copy` : ce module sert a copier des fichiers. Il existe de nombreuses options de copie. [Lien vers la doc](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html)

```bash
ansible -i "cloud-1," all -m copy -a "src:monfichier dest:le_chemin_de_destination"
```

- `fetch` : permet de telecharger un fichier present sur la machine distante. [Lien vers la doc](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/fetch_module.html#ansible-collections-ansible-builtin-fetch-module)

```bash
ansible -i "cloud-1," all -m copy -a "src:/chemin/vers/fichier/distant dest:le_chemin_de_destination"
```

- `setup` : permet de retrouver toutes les informations collectees par ansible (les *gather facts*) sur le serveur distant. Peut avoir des filtres. [Lien vers la doc](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/setup_module.html#ansible-collections-ansible-builtin-setup-module)

```bash
ansible -i "cloud-1," all -m setup
```

## L'`inventory`

### Qu'est-ce que c'est ?

C'est l'inventaire des machines et des variables qui les definissent. C'est central dans ansible.

Il decrit l'infrastructure : les serveurs, le typage de ces serveurs (webserver, serveur relay etc.).

Il y a deux types d'instance :

- hosts
- groups

Il existe plusieurs formats pour l'`inventory` :

- ini : format plat (deconseille)
- yaml : pour ecrire
- json : pour traiter les donnees (deconseille pour ecrire)

Il est possible d'utiliser des patterns pour faciliter la nomenclature.

*In fine* l'inventory c'est :

- le fichier d'inventaire
- le repertoire group_vars
- le repertoire host_vars

### Le fichier d'inventaire

Le groupe racine est `all`. Il suit la nomenclature des yaml.

Il y a un ordre hierarchique des variables.

Il y a 4 familles de variables :

- celles de configuration
- celles de la ligne de commande
- celles des playbooks
- celles des roles

Il y a 22 variables en tout, classees ci-dessous par precedence (celle en haut est hierarchiquement plus faible que celle tout en bas):

- Command-line values (for example, -u my_user, these are not variables)
- Role defaults (as defined in Role directory structure)
- Inventory file or script group vars
- Inventory group_vars/all
- Playbook group_vars/all
- Inventory group_vars/*
- Playbook group_vars/*
- Inventory file or script host vars
- Inventory host_vars/*
- Playbook host_vars/*
- Host facts and cached set_facts
- Play vars
- Play vars_prompt
- Play vars_files
- Role vars (as defined in Role directory structure)
- Block vars (for tasks in block only)
- Task vars (for the task only)
- include_vars
- Registered vars and set_facts
- Role (and include_role) params
- include params
- Extra vars (for example, -e "user=my_user")(always win precedence)

[Lien vers la documentation.](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html)

### Hierarchisation d'un projet ansible

On peut appliquer la hierarchie suivante :

```bash
.
└── recette
    ├── 00_inventory.yml
    ├── ansible.cfg
    ├── group_vars
    │   ├── all.yml
    │   ├── dbserver
    │   │   ├── variables.yml
    │   │   └── vault.yml
    │   └── webserver
    │       ├── variables.yml
    │       └── vault.yml
    └── host_vars
        └── scaleway-cloud-1
            ├── variables.yml
            └── vault.ym
```

> [!NOTE]
> Cette hierarchie est la a titre d'exemple et il faut adapter selon le projet que l'on fait.

> [!TIP]
> Le fait de ranger les fichiers et dossiers dans un super dossier de type `recette`, `prod` etc permet de facilement lancer telle ou telle tache selon ce qu'on souhaite avec `ansible -i prod` par exemple pour lancer les commandes de production.

## Le `playbook`

[Lien vers la doc.](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html#ansible-playbooks)

Le playbook sert a plusieurs choses, mais principalement :

- a declencher les actions a realiser
- a articuler l'inventory - cad les machines gerees (managed nodes) - avec les roles, cad les actions a executer
- a executer des tasks. **C'est une mauvaise pratique a eviter**
- inclure des variables. **C'est une mauvaise pratique a eviter**
- specifier un utilisateur particulier et sa maniere d'interagir avec les tasks

La commande utilisee pour les `playbooks` est `ansible-playbooks`.

### Quelques options

- `-i` : sert  specifier l'inventory
- `-l` : limit, sert a specifier un ou des groupe.s ou serveurs, ou encore un pattern (c'est une sorte de filtre sur `l'inventory`)
- `-u` : user, specifie l'utilisateur
- `-b` : elevation de privilege (sudo)
- `-K` : pour le mot de passe de sudo
- `-C` : permet un dry run
- `-D` : diff, permet d'afficher les differences avant-apres une `tasks`
- `--ask-vault` : affiche un prompt pour le mot de passe du vault
- `--syntax-check` : permet de verifier la syntaxe du fichier playbook
- `--vault-password-file` : permet de specifier le fichier de mot de passe pour le vault
- `-e` : permet de surcharger ou creer n'importe quelle variable
- `-f` : fork, pour augmenter ou abaisser le nombre de threads
- `-t` : permet de filtrer sur les tags
- `--flush-cache` : ne pas utiliser le cache pour executer
- `--step` : permet d'executer une tache a la fois
- `--start-at-task` : commencer a une tache specifique
- `--list-tags` : liste les tags
- `--list-task` : liste les taches qui vont etre executees

### Exemple d'un simple playbook avec le module debug

Voici un playbook possible :

```yaml
- name: Playbook de test ftw
  hosts: scaleway_srv
  remote_user: root
  tasks:
    - name: "Un debug"
      ansible.builtin.debug:
        msg: "{{ var1 }}"
```

> [!NOTE]
> Ce playbook ne respecte pas les bonnes pratiques, car il execute une tache. Il est ici a titre d'exemple.

Et voici un inventory tres simple :

```yaml
scaleway_srv:
  hosts:
    cloud-1:
# peut etre rajouter une vm pour la suite, comme ca il y aurait le multiple server. Ne pas oublier de rajouter le hostnme dans /etc/hosts
# exemple : IP machine = cloud2.local
vm_srv:
  hosts:
    cloud-2:
```

L'arbre des fichiers est le suivant :

```bash
.
├── README.md
└── recette
    ├── ansible.cfg
    ├── inventory
    │   └── 00_inventory.yml
    └── playbook
        └── playbook.yml
```

On peut executer le playbook avec la commande suivante :

```bash
➜  cloud-1 git:(main) ansible-playbook -i recette/inventory recette/playbook/playbook.simple.yml -e "var1=yoyo"      

PLAY [Playbook de test ftw] ******************************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************************
ok: [cloud-1]

TASK [Un debug] ******************************************************************************************************************************************************************************************
ok: [cloud-1] => {
    "msg": "yoyo"
}

PLAY RECAP ***********************************************************************************************************************************************************************************************
cloud-1                    : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

## Le module `file`

[Lien vers la doc.](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html)

Ce module gere les fichiers et les repertoire avec de nombreuses options.

Notamment, il sert a :

- Définir les attributs des fichiers, répertoires ou liens symboliques et leurs cibles.
- Supprimer des fichiers, des liens symboliques ou des répertoires.

De nombreux autres modules prennent les mêmes options que le module `ansible.builtin.file`, notamment `ansible.builtin.copy`, `ansible.builtin.template` et `ansible.builtin.assemble`.

Quelques options utiles tout le temps :

- `mode` : agit comme `chmod`, avec la meme nomenclature (i.e, `mode: '0644'`). Il est egalement possible d'utiliser celle ci : `mode: u+rw,g-wx,o-rwx`, ou on definit les acces selon le user, le groupe et le reste du monde.
- `owner` : determine le proprietaire du fichier. `owner: monutilisateur`
- `group` : determine le groupe du fichier. `group: monutilisateur`
- `path` (obligatoire) : chemin du fichier a gerer
- `recurse` : Peut etre `true` ou `false`. Change de facon recursive les attributs specifies sur le contenu du dossier choisi. Ne fonctionne que quand `state` est configure a `directory`
- `state` : En l'absence de ce paramètre, les répertoires seront supprimés de manière récursive et les fichiers ou liens symboliques seront dissociés. Dans le cas d'un répertoire, si `diff` est déclaré, les fichiers et dossiers supprimés seront répertoriés sous `path_contents`. Notez que le parametre `absent` n'entraînera pas l'échec de `ansible.builtin.file` si le chemin n'existe pas, car l'état n'a pas changé.
  - Si `directory`, tous les sous-répertoires intermédiaires seront créés s'ils n'existent pas avec les permissions fournies.
  - Si `file`, sans autre option, renvoie l'état actuel du chemin.
  - Si `file`, même avec d'autres options (telles que `mode`), le fichier sera modifié s'il existe, mais ne sera **PAS** créé s'il n'existe pas. Définissez sur `touch` ou utilisez le module `ansible.builtin.copy` ou `ansible.builtin.template` si vous souhaitez créer le fichier s'il n'existe pas.
  - Si `hard`, le lien physique sera créé ou modifié.
  - Si `link`, le lien symbolique sera créé ou modifié.
  - Si `touch`, un fichier vide sera créé si le fichier n'existe pas, tandis qu'un fichier ou un répertoire existant recevra des heures d'accès et de modification mises à jour (similaire au fonctionnement de `touch` à partir de la ligne de commande).
  - La valeur par défaut est l'état actuel du fichier s'il existe, le répertoire si `recurse=true`, ou l'option `file` dans le cas contraire.
  - Choix :
    - `absent`
    - `directory`
    - `file`
    - `hard`
    - `link`
    - `touch`

### Exemple d'utilisation du module file

> [!NOTE]
> Ce `playbook` ne respecte pas les bonnes pratiques, car il execute une tache. Il est ici a titre d'exemple.

Voici le `playbook` :

```yaml
- name: Playbook pour tester le module file
  hosts: scaleway_srv
  remote_user: root
  tasks:
    - name: "Un debug"
      ansible.builtin.file:
        mode: '644'
        path: '/tmp/dossier_de_test'
        owner: root
        group: root
        state: directory
```

Voici l'`inventory` :

```yaml
scaleway_srv:
  hosts:
    cloud-1:
vm_srv:
  hosts:
    cloud-2:
```

On peut lancer la commande suivante :

```bash
ansible-playbook -i recette/inventory recette/playbook/playbook.module.file.yml

PLAY [Playbook pour tester le module file] ***************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************************
ok: [cloud-1]

TASK [Un debug] ******************************************************************************************************************************************************************************************
ok: [cloud-1]

PLAY RECAP ***********************************************************************************************************************************************************************************************
cloud-1                    : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

Avec la commade suivante, on peut tester l'existence du dossier `dossier_de_test` :

```bash
ansible -i "cloud-1," all -m command -a "stat /tmp/dossier_de_test" 
cloud-1 | CHANGED | rc=0 >>
  File: /tmp/dossier_de_test
  Size: 4096            Blocks: 8          IO Block: 4096   directory
Device: fc01h/64513d    Inode: 288934      Links: 2
Access: (0644/drw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2025-09-11 11:54:30.980112315 +0000
Modify: 2025-09-11 11:45:56.844328020 +0000
Change: 2025-09-11 11:45:56.844328020 +0000
 Birth: 2025-09-11 11:45:56.844328020 +0000
```

Nous voyons que le dossier a bien ete cree avec les bons droits (droits `rwx` pour l'owner et `r` pour le groupeainsi que le reste du monde).

Voici le meme `playbook` avec la suppression du dossier tout juste cree et verification de sa presence :

```yaml
- name: Playbook pour tester le module file
  hosts: scaleway_srv
  remote_user: root
  tasks:
    - name: "Creation du dossier dossier_de_test"
      ansible.builtin.file:
        mode: '644'
        path: '/tmp/dossier_de_test'
        owner: root
        group: root
        state: directory
    - name: "Verification de l'existence du dossier 'dossier_de_test'"
      ansible.builtin.command: "stat '/tmp/dossier_de_test'"
      register: stat_output # permet de recup le retour
      changed_when: false # determine quand un etat a change -> https://ansible.readthedocs.io/projects/lint/rules/no-changed-when/
    - name: "Suppression du dossier dossier_de_test"
      ansible.builtin.file:
        path: '/tmp/dossier_de_test'
        state: absent
    - name: "Verification de l'absence du dossier 'dossier_de_test'"
      ansible.builtin.command: "stat '/tmp/dossier_de_test'"
      register: stat_output # permet de recup le retour par exemple avec debug stat_output.stdout_lines stat_output.stderr_lines
      changed_when: false # determine quand un etat a change -> https://ansible.readthedocs.io/projects/lint/rules/no-changed-when/
```

On lance la commande suivante :

```bash
ansible-playbook -i recette/inventory recette/playbook/playbook.module.file.yml

PLAY [Playbook pour tester le module file] ***************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************************
Thursday 11 September 2025  14:27:36 +0200 (0:00:00.005)       0:00:00.005 **** 
Thursday 11 September 2025  14:27:36 +0200 (0:00:00.004)       0:00:00.004 **** 
ok: [cloud-1]

TASK [Creation du dossier dossier_de_test] ***************************************************************************************************************************************************************
Thursday 11 September 2025  14:27:38 +0200 (0:00:01.961)       0:00:01.966 **** 
Thursday 11 September 2025  14:27:38 +0200 (0:00:01.961)       0:00:01.966 **** 
changed: [cloud-1]

TASK [Verification de l'existence du dossier 'dossier_de_test'] ******************************************************************************************************************************************
Thursday 11 September 2025  14:27:38 +0200 (0:00:00.426)       0:00:02.393 **** 
Thursday 11 September 2025  14:27:38 +0200 (0:00:00.426)       0:00:02.393 **** 
ok: [cloud-1]

TASK [Suppression du dossier dossier_de_test] ************************************************************************************************************************************************************
Thursday 11 September 2025  14:27:39 +0200 (0:00:00.405)       0:00:02.799 **** 
Thursday 11 September 2025  14:27:39 +0200 (0:00:00.406)       0:00:02.799 **** 
changed: [cloud-1]

TASK [Verification de l'absence du dossier 'dossier_de_test'] ********************************************************************************************************************************************
Thursday 11 September 2025  14:27:39 +0200 (0:00:00.380)       0:00:03.180 **** 
Thursday 11 September 2025  14:27:39 +0200 (0:00:00.380)       0:00:03.180 **** 
fatal: [cloud-1]: FAILED! => {
    "changed": false,
    "cmd": [
        "stat",
        "/tmp/dossier_de_test"
    ],
    "delta": "0:00:00.003073",
    "end": "2025-09-11 12:27:39.778541",
    "rc": 1,
    "start": "2025-09-11 12:27:39.775468"
}

STDERR:

stat: cannot statx '/tmp/dossier_de_test': No such file or directory


MSG:

non-zero return code
```

On constate que la commande `stat` n'a pas fonctionne. Cela veut dire que le dossier a bien ete supprime.

Voici un exemple complet venant du site d'ansible :

```yaml
- name: Change file ownership, group and permissions
  ansible.builtin.file:
    path: /etc/foo.conf
    owner: foo
    group: foo
    mode: '0644'

- name: Give insecure permissions to an existing file
  ansible.builtin.file:
    path: /work
    owner: root
    group: root
    mode: '1777'

- name: Create a symbolic link
  ansible.builtin.file:
    src: /file/to/link/to
    dest: /path/to/symlink
    owner: foo
    group: foo
    state: link

- name: Create two hard links
  ansible.builtin.file:
    src: '/tmp/{{ item.src }}'
    dest: '{{ item.dest }}'
    state: hard
  loop:
    - { src: x, dest: y }
    - { src: z, dest: k }

- name: Touch a file, using symbolic modes to set the permissions (equivalent to 0644)
  ansible.builtin.file:
    path: /etc/foo.conf
    state: touch
    mode: u=rw,g=r,o=r

- name: Touch the same file, but add/remove some permissions
  ansible.builtin.file:
    path: /etc/foo.conf
    state: touch
    mode: u+rw,g-wx,o-rwx

- name: Touch again the same file, but do not change times this makes the task idempotent
  ansible.builtin.file:
    path: /etc/foo.conf
    state: touch
    mode: u+rw,g-wx,o-rwx
    modification_time: preserve
    access_time: preserve

- name: Create a directory if it does not exist
  ansible.builtin.file:
    path: /etc/some_directory
    state: directory
    mode: '0755'

- name: Update modification and access time of given file
  ansible.builtin.file:
    path: /etc/some_file
    state: file
    modification_time: now
    access_time: now

- name: Set access time based on seconds from epoch value
  ansible.builtin.file:
    path: /etc/another_file
    state: file
    access_time: '{{ "%Y%m%d%H%M.%S" | strftime(stat_var.stat.atime) }}'

- name: Recursively change ownership of a directory
  ansible.builtin.file:
    path: /etc/foo
    state: directory
    recurse: yes
    owner: foo
    group: foo

- name: Remove file (delete file)
  ansible.builtin.file:
    path: /etc/foo.txt
    state: absent

- name: Recursively remove directory
  ansible.builtin.file:
    path: /etc/foo
    state: absent
```

## Le module `user`

[Lien vers la doc.](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/user_module.html#ansible-builtin-user-module-manage-user-accounts)

Le module `user` permet de creer des utilisateurs et de les gerer.

### Quelques options utiles du module `user`

- `append` : Si `true`, ajoute l'utilisateur dans les groupes specifies par `groups`, si `false`, ajoute l'utilisateur specifie dans `groups`, tout en le retirant de tous les autres groupes.
- `create_home` : `true` ou `false`. Cree ou non un home pour l'utilisateur en question.
- `force` : `true` ou `false`. Cela n'affecte que `state=absent`, cela force la suppression de l'utilisateur et des répertoires associés sur les plateformes prises en charge. Le comportement est identique à celui de `userdel --force`. Lorsqu'il est utilisé avec `generate_ssh_key=yes`, cela force le remplacement d'une clé existante.
- `generate_ssh_key` : genere une cle ssh pour l'utilisateur. Sans l'option `force`, ne **REMPLACE PAS** une cle precedement generee.
- `group` : le groupe primaire du user
- `groups` : tout autre groupe auquel on souhaite ajoute le user en question. Par defaut, l'utilisateur est retire des autres groupes non mentionne (hormis le groupe primaire). On peut configurer `append` pour modifier ce comportement.
- `home` : configure le home (path)
- `name` : nom de l'utilisateur a creer ou modifier ou supprimer.
- `password` : mot de passe de l'utilisateur si fourni. **On doit mettre le hash**. Le module vault nous permettra de mieux gerer cet aspect pour ne pas mettre demot de passe en dur.
- `remove` : Ne fonctionne qu'avec `state=absent`. Tente de supprimer les dossiers appartenent a l'utilisateur en cas de suppression de ce dernier.
- `state` : Specifie si un compte devrait exister ou non, permettant de determiner une action si le resultat est different de ce qui est assume.
- `shell` : Option qui permet de configurer le shell. Pour les compte systeme, on peut mettre /usr/bin/false si cela est accepte. Le comportement par defaut de cette option depend de la commande utilisee en sous main.
- `system` : determine si un compte est un compte systeme ou non (uid < 1000).
- `umask` : met en place le umask par defaut de lutilisateur. Ne foncitonne que sur linux.

### Quelques exemple de l'utilisation du module `user`

Voici un YAML simple :

```yaml
- name: "Exemple de creation - modification - suppression d'un utilisateur"
  hosts: scaleway_srv
  tasks:
    - name: "Ajout d'un utilisateur 'wordpress_user'"
      ansible.builtin.user:
        name: 'wordpress_user'
        state: present
        groups: 'sudo'
        system: true
        create_home: false
        password: "{{ 'password' | password_hash('sha512') }}" # ne JAMAIS faire ca IRL
      register: create_user_output # permet de recup le retour
    - name: "Test d'existence du user 'wordpress_user'"
      ansible.builtin.debug:
        var: create_user_output
```

Et le resultat :

```bash
ansible-playbook -i recette/inventory recette/playbook/playbook.module.user.yml

<SNIP>
TASK [Test d'existence du user 'wordpress_user'] *********************************************************************************************************************************************************
Thursday 11 September 2025  15:53:59 +0200 (0:00:00.626)       0:00:04.226 **** 
Thursday 11 September 2025  15:53:59 +0200 (0:00:00.626)       0:00:04.226 **** 
ok: [cloud-1] => {
    "create_user_output": {
        "append": false,
        "changed": true,
        "comment": "",
        "failed": false,
        "group": 998,
        "groups": "sudo",
        "home": "/home/wordpress_user",
        "move_home": false,
        "name": "wordpress_user",
        "password": "NOT_LOGGING_PASSWORD",
        "shell": "/bin/sh",
        "state": "present",
        "uid": 998
    }
}
```

Et voici le meme yaml, mais pour lquel on supprime l'utilisateur par la suite :

```yaml
- name: "Exemple de creation - modification - suppression d'un utilisateur"
  hosts: scaleway_srv
  tasks:
    - name: "Ajout d'un utilisateur 'wordpress_user'"
      ansible.builtin.user:
        name: 'wordpress_user'
        state: present
        groups: 'sudo'
        system: true
        create_home: false
        password: "{{ 'password' | password_hash('sha512') }}" # ne JAMAIS faire ca IRL
      register: create_user_output # permet de recup le retour
    - name: "Test d'existence du user 'wordpress_user'"
      ansible.builtin.debug:
        var: create_user_output
    - name: "Suppression d'un utilisateur 'wordpress_user'"
      ansible.builtin.user:
        name: 'wordpress_user'
        state: absent
        system: true
        remove: true
        force: true
      register: delete_user_output # permet de recup le retour
    - name: "Test d'existence du user 'wordpress_user'"
      ansible.builtin.debug:
        var: delete_user_output
```

Resulat, l'utilisateur est bien supprime :

```bash
ansible-playbook -i recette/inventory recette/playbook/playbook.module.user.yml

<SNIP>
TASK [Test d'existence du user 'wordpress_user'] *********************************************************************************************************************************************************
Thursday 11 September 2025  16:01:02 +0200 (0:00:00.663)       0:00:12.743 **** 
Thursday 11 September 2025  16:01:02 +0200 (0:00:00.663)       0:00:12.743 **** 
ok: [cloud-1] => {
    "create_user_output": {
        "append": false,
        "changed": true,
        "comment": "",
        "failed": false,
        "group": 998,
        "groups": "sudo",
        "home": "/home/wordpress_user",
        "move_home": false,
        "name": "wordpress_user",
        "password": "NOT_LOGGING_PASSWORD",
        "shell": "/bin/sh",
        "state": "present",
        "uid": 998
    }
}

TASK [Suppression d'un utilisateur 'wordpress_user'] *****************************************************************************************************************************************************
Thursday 11 September 2025  16:01:02 +0200 (0:00:00.024)       0:00:12.767 **** 
Thursday 11 September 2025  16:01:02 +0200 (0:00:00.024)       0:00:12.767 **** 
changed: [cloud-1]

TASK [Test d'existence du user 'wordpress_user'] *********************************************************************************************************************************************************
Thursday 11 September 2025  16:01:03 +0200 (0:00:00.615)       0:00:13.383 **** 
Thursday 11 September 2025  16:01:03 +0200 (0:00:00.615)       0:00:13.383 **** 
ok: [cloud-1] => {
    "delete_user_output": {
        "changed": true,
        "failed": false,
        "force": true,
        "name": "wordpress_user",
        "remove": true,
        "state": "absent",
        "stderr": "userdel: wordpress_user mail spool (/var/mail/wordpress_user) not found\nuserdel: wordpress_user home directory (/home/wordpress_user) not found\n",
        "stderr_lines": [
            "userdel: wordpress_user mail spool (/var/mail/wordpress_user) not found",
            "userdel: wordpress_user home directory (/home/wordpress_user) not found"
        ]
    }
}
```

## Les `register` et le module `stat`

[Lien vers le doc du module stat](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/stat_module.html)
[Lien vers la doc des registers](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#registering-variables)

Le module stat est un module qui agit comme la commande `stat` sur linux.

Un `register` permet de recuperer sous une variable l'output et d'autres donnees d'une `task` donnee.

### Les options utiles du module `stat`

- `path` : le chemin du fichier qu'on souhaite tester
- `follow` : suivre ou non les symlinks
- `get_checksum` : retourner ou non le checksum (`true` / `false`)
- `get_mime` : retourner ou non le mime type (`true` / `false`)

### Exemple d'utilisation du module `stat` avec un `register`

Voici un fichier YAML tres simple qui cree puis supprime un fichier, tout en permettant de voir l'effectivite de ces actions.

```yaml
- name: Playbook pour tester le module file
  hosts: scaleway_srv
  remote_user: root
  tasks:
    - name: "Creation du fichier 'fichiertest'"
      ansible.builtin.file:
        mode: '644'
        path: '/tmp/fichiertest'
        owner: root
        group: root
        state: touch
    - name: "Verification de l'existence du fichier 'fichiertest'"
      ansible.builtin.stat:
        path: "/tmp/fichiertest"
      register: stat_output # permet de recup le retour
    - name: Debug de stat
      ansible.builtin.debug:
        var: stat_output
    - name: "Suppression du fichier 'fichiertest'"
      ansible.builtin.file:
        path: '/tmp/fichiertest'
        state: absent
    - name: "Verification de l'absence du fichier 'fichiertest'"
      ansible.builtin.stat:
        path: "/tmp/fichiertest"
      register: stat_delete_output # permet de recup le retour
    - name: Debug de stat
      ansible.builtin.debug:
        var: stat_delete_output
```

Resultat, on constate bien la presence et enfin l'absence du fichier :

```bash
TASK [Debug de stat] *************************************************************************************************************************************************************************************
Thursday 11 September 2025  16:32:28 +0200 (0:00:00.473)       0:00:02.218 **** 
Thursday 11 September 2025  16:32:28 +0200 (0:00:00.473)       0:00:02.218 **** 
ok: [cloud-1] => {
    "stat_output": {
        "changed": false,
        "failed": false,
        "stat": {
            "atime": 1757601148.1103199,
            "attr_flags": "e",
            "attributes": [
                "extents"
            ],
            "block_size": 4096,
            "blocks": 0,
            "charset": "binary",
            "checksum": "da39a3ee5e6b4b0d3255bfef95601890afd80709",
            "ctime": 1757601148.1103199,
            "dev": 64513,
            "device_type": 0,
            "executable": false,
            "exists": true,
            "gid": 0,
            "gr_name": "root",
            "inode": 12410,
            "isblk": false,
            "ischr": false,
            "isdir": false,
            "isfifo": false,
            "isgid": false,
            "islnk": false,
            "isreg": true,
            "issock": false,
            "isuid": false,
            "mimetype": "inode/x-empty",
            "mode": "0644",
            "mtime": 1757601148.1103199,
            "nlink": 1,
            "path": "/tmp/fichiertest",
            "pw_name": "root",
            "readable": true,
            "rgrp": true,
            "roth": true,
            "rusr": true,
            "size": 0,
            "uid": 0,
            "version": "1346125600",
            "wgrp": false,
            "woth": false,
            "writeable": true,
            "wusr": true,
            "xgrp": false,
            "xoth": false,
            "xusr": false
        }
    }
}

TASK [Suppression du fichier 'fichiertest'] **************************************************************************************************************************************************************
Thursday 11 September 2025  16:32:28 +0200 (0:00:00.030)       0:00:02.249 **** 
Thursday 11 September 2025  16:32:28 +0200 (0:00:00.030)       0:00:02.249 **** 
changed: [cloud-1]

TASK [Verification de l'absence du fichier 'fichiertest'] ************************************************************************************************************************************************
Thursday 11 September 2025  16:32:29 +0200 (0:00:00.341)       0:00:02.590 **** 
Thursday 11 September 2025  16:32:29 +0200 (0:00:00.341)       0:00:02.590 **** 
ok: [cloud-1]

TASK [Debug de stat] *************************************************************************************************************************************************************************************
Thursday 11 September 2025  16:32:29 +0200 (0:00:00.376)       0:00:02.967 **** 
Thursday 11 September 2025  16:32:29 +0200 (0:00:00.377)       0:00:02.967 **** 
ok: [cloud-1] => {
    "stat_delete_output": {
        "changed": false,
        "failed": false,
        "stat": {
            "exists": false
        }
    }
}
```

### Quelques notes a propos des `registers`

On peut recuperer les cles et les valeurs d'une variable.

Par exemple pour `stat`, nous constatons dans le debug que :

```json
"stat": {
            "exists": false
        }
```

On peut acc2der a cette donnee -et tout autre donnee qui peut exister, ainsi dans le module debug :

```YAML
ansible.builtin.debug:
  msg: "Le fichier existe ? Resultat : {{ monregister.stat.exists }}"
```

Et cela nous retournera ou non la presence du fichier :

```bash
<SNIP>
ok: [cloud-1] => {}

MSG:

Le fichier existe ? Resultat : False
<SNIP>
```

On peut aussi rajouter des conditions grace a cela :

```yaml
ansible.builtin.file:
  path: /tmp/test
  state: touch
when: monregister.stat.exists == True
```

Ainsi le fichier test ne sera cree que si le retour du module `stat` sur un fichier/dossier donne retourne `true` pour la cle `exists`.

## Les boucles : `with_items` et boucles `loop`

[Lien vers la doc concernant les items](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/items_lookup.html)

[Lien vers la doc concernant les differents types de boucle](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_loops.html)

[Lien vers la doc concernant les lookups](https://docs.ansible.com/ansible/latest/plugins/lookup.html)

> [!NOTE]
> [La video de xavki](https://www.youtube.com/watch?v=Iyw_s61sDmU&list=PLn6POgpklwWoCpLKOSw3mXCqbRocnhrh-&index=18) concernant les boucles ne semble pas parler de la nouvelle facon de faire des boucles, qui offre une maniere plus fine de les controler. Cependant, les `with_<lookup_name>` sont toujours d'actualite et, a l'heure d'ecrire ce doument (09-2025), n'est pas prevue pour etre depreciee par les devs d'ansible.

Nous allons aborder ici les deux facons de faire.

### Les boucles `with_<lookup_name>`

La liste des boucles `with_` :

- `with_item` : boucle a partir de liste de dictionnaire
- `with_nested` : boucle sur des listes de liste
- `with_dict` : boucle sur les dictionnaires
- `with_fileglob` : boucle sur des fichiers avec pattern glob (ie, `*.txt`).Non recursif
- `with_filetree` : boucle sur une arborescence avec pattern selon des criteres
- `with_together` : boucle sur deux listes croisees en parallele
- `with_sequence` : boucle avec un interval etc.
- `with_random_choice` : boucle avec un element tire au sort dans une liste
- `with_first_found` : choisit remier element de la liste
- `with_lines` : parcourt chaque ligne d'un programme
- `with_inventory_hostname` : parcourt l'inventaire

### Exemples d'utilisation des boucles `with_`

Voici un yaml qui cree et supprime des dossiers avec with_items :

```yaml
- name: Boucle with_item
  hosts: scaleway_srv
  remote_user: root
  tasks:
    - name: "Creation de repertoire"
      ansible.builtin.file:
        state: directory
        recurse: true
        path: "/tmp/{{ item }}"
      with_items:
        - test1
        - test2
        - test3
    - name: "Stat sur les dossiers crees"
      ansible.builtin.stat:
        path: "/tmp/{{ item }}"
      with_items:
        - test1
        - test2
        - test3
      register: __directory_loop_creation
    - name: "Debug du stat"
      ansible.builtin.debug:
        var: __directory_loop_creation
    - name: "Suppression de repertoire"
      ansible.builtin.file:
        state: absent
        path: "/tmp/{{ item }}"
      with_items:
        - test1
        - test2
        - test3
    - name: "Stat sur les dossiers supprimes"
      ansible.builtin.stat:
        path: "/tmp/{{ item }}"
      with_items:
        - test1
        - test2
        - test3
      register: __directory_loop_deletion
    - name: "Debug du stat"
      ansible.builtin.debug:
        var: __directory_loop_deletion
```

Nous pouvons remplacer le `with_items` avec la nomenclature suivante, plus concise :

```yaml
    - name: With_items -> loop
      ansible.builtin.file:
        state: directory
        recurse: true
        path: "/tmp/{{ item }}"
      loop: "{{ ['test1', 'test2', 'test3'] | flatten(levels=1) }}"
```

Avec ce remplacement, nous pouvons constater sur le serveur que les dossiers ont ete crees correctement :

```bash
root@cloud-1-chbadad-team-6899317:~# ll /tmp
total 64
<SNIP>
drwxr-xr-x  2 root root 4096 Sep 12 09:41 test1/
drwxr-xr-x  2 root root 4096 Sep 12 09:41 test2/
drwxr-xr-x  2 root root 4096 Sep 12 09:41 test3/
```

Ci dessous, un autre exemple avec un system de cle/valeur :

```yaml
    - name: "Creation de repertoire avec cle:valeur"
      ansible.builtin.file:
        state: directory
        recurse: true
        path: "/tmp/{{ item.dir }}/{{ item.file }}"
      with_items:
        - { dir1: "dir", dir2: "subdir1" }
        - { dir1: "dir", dir2: "subdir2" }
        - { dir1: "dir", dir2: "subdir3" }
```

Cela creera un dossier `dir` avec les sous-dossiers `subdirX`.

On peut egalement mettre ce dictionnaire au sein du `group_vars`, par exemple dans `inventory/group_vars/all.yaml` :

```yml
directory_list:
- { dir1: "test", dir2: "subdir1" }
- { dir1: "test", dir2: "subdir2" }
- { dir1: "test", dir2: "subdir3" }
```

Et dans le `playbook` :

```yml
    - name: "Creation de repertoire avec cle:valeur"
      ansible.builtin.file:
        state: directory
        recurse: true
        path: "/tmp/{{ item.dir1 }}/{{ item.dir2 }}"
      with_items: "{{ directory_list }}"
```

Ou encore :

```yml
    - name: "Creation de repertoire avec cle:valeur"
      ansible.builtin.file:
        state: directory
        recurse: true
        path: "/tmp/{{ item.dir1 }}/{{ item.dir2 }}"
      loop: "{{ directory_list }}"
```

Resultat :

```bash
root@cloud-1-chbadad-team-6899317:/tmp# ls -la ./test/
total 20
drwxr-xr-x  5 root root 4096 Sep 12 10:53 .
drwxrwxrwt 17 root root 4096 Sep 12 10:53 ..
drwxr-xr-x  2 root root 4096 Sep 12 10:53 subdir1
drwxr-xr-x  2 root root 4096 Sep 12 10:53 subdir2
drwxr-xr-x  2 root root 4096 Sep 12 10:53 subdir3
```

### Acces a des elements de l'`inventory`

On peut acceder au element de l'`inventory` via les cle/valeur :

```yaml
- name: "Creation de repertoire avec cle:valeur de l'inventory"
  ansible.builtin.file:
    state: directory
    recurse: true
    path: "/tmp/{{ item }}"
  loop: "{{ groups['all'] }}"
```

Cela creera des dossier aux noms des hosts specifie dans l'inventaire.

## Le module `apt`

[Lien vers la doc.](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html)

Le module `apt` est le gestionnaire de paquet agnostique de ansible. Cependant il tentera d'utiliser aptitude sur les machines.

### Quelques options utiles du module `apt`

- `update_cache` : `true` ou `false`. Met a jour le cache avant installation.
- `deb` : installer un pquet deb, local ou remote si le chemin contient `://` (ie, `https://`)
- `autoremove` : permet de supprimer les dependance inutilisees.
- `autoclean` : permet de supprimer les donnees des paquets ne pouvant plus etre installes.
- `cache_valid_time` : duree du cache en secondes.
- `name`, `package`, `pkg` : le nom d'un paquet a installer
- `upgrade` : Si `yes` ou `safe`, exécute une mise à niveau sécurisée d'aptitude. Si `full` exécute une mise à niveau complète d'aptitude. Si `dist` exécute une mise à niveau dist avec apt-get. Remarque : Cette commande ne met pas à niveau un paquet spécifique. Utilisez state=latest pour cela.
- `state` : Indique l'état souhaité du paquet. `latest` garantit l'installation de la dernière version. `build-dep` garantit l'installation des dépendances de build du paquet. `fixed` tente de corriger un système comportant des dépendances défectueuses. Choix :
  - `absent`
  - `build-dep`
  - `latest`
  - `present` ← (par défaut)
  - `fixed`

### exemple de l'utilisation du module `apt`

Pour ajouter `docker` :



```yml
- name: Install apache httpd (state=present is optional)
  ansible.builtin.apt:
    name: apache2
    state: present

- name: Update repositories cache and install "foo" package
  ansible.builtin.apt:
    name: foo
    update_cache: yes

- name: Remove "foo" package
  ansible.builtin.apt:
    name: foo
    state: absent

- name: Install the package "foo"
  ansible.builtin.apt:
    name: foo

- name: Install a list of packages
  ansible.builtin.apt:
    pkg:
    - foo
    - foo-tools

- name: Install the version '1.00' of package "foo"
  ansible.builtin.apt:
    name: foo=1.00

- name: Update the repository cache and update package "nginx" to latest version using default release squeeze-backport
  ansible.builtin.apt:
    name: nginx
    state: latest
    default_release: squeeze-backports
    update_cache: yes

- name: Install the version '1.18.0' of package "nginx" and allow potential downgrades
  ansible.builtin.apt:
    name: nginx=1.18.0
    state: present
    allow_downgrade: yes

- name: Install zfsutils-linux with ensuring conflicted packages (e.g. zfs-fuse) will not be removed.
  ansible.builtin.apt:
    name: zfsutils-linux
    state: latest
    fail_on_autoremove: yes

- name: Install latest version of "openjdk-6-jdk" ignoring "install-recommends"
  ansible.builtin.apt:
    name: openjdk-6-jdk
    state: latest
    install_recommends: no

- name: Update all packages to their latest version
  ansible.builtin.apt:
    name: "*"
    state: latest

- name: Upgrade the OS (apt-get dist-upgrade)
  ansible.builtin.apt:
    upgrade: dist

- name: Run the equivalent of "apt-get update" as a separate step
  ansible.builtin.apt:
    update_cache: yes

- name: Only run "update_cache=yes" if the last one is more than 3600 seconds ago
  ansible.builtin.apt:
    update_cache: yes
    cache_valid_time: 3600

- name: Pass options to dpkg on run
  ansible.builtin.apt:
    upgrade: dist
    update_cache: yes
    dpkg_options: 'force-confold,force-confdef'

- name: Install a .deb package
  ansible.builtin.apt:
    deb: /tmp/mypackage.deb

- name: Install the build dependencies for package "foo"
  ansible.builtin.apt:
    pkg: foo
    state: build-dep

- name: Install a .deb package from the internet
  ansible.builtin.apt:
    deb: https://example.com/python-ppq_0.1-1_all.deb

- name: Remove useless packages from the cache
  ansible.builtin.apt:
    autoclean: yes

- name: Remove dependencies that are no longer required
  ansible.builtin.apt:
    autoremove: yes

- name: Remove dependencies that are no longer required and purge their configuration files
  ansible.builtin.apt:
    autoremove: yes
    purge: true

- name: Run the equivalent of "apt-get clean" as a separate step
  ansible.builtin.apt:
    clean: yes
```

### Redemarrage du serveur grace au module `reboot`

[Lien vers la doc.](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/reboot_module.html)

On peut ajouter le bloc suivant afin de rebooter apres un upgrade ou autre :

```yml
- name: "Reboot Machine"
  ansible.builtin.reboot:
    msg: "Reboot du serveur dans 5 secondes operee via Ansible"
    connect_timeout: 5
    pre_reboot_delay: 0 # si < 60 sec, est mis a 0..
    post_reboot_delay: 30
    test_command: uptime
```

Resultat :

```bash
cloud-1 | CHANGED => {
    "changed": true,
    "elapsed": 30,
    "rebooted": true
}
```

## Gestion des cles SSH avec les modules `ansible.posix.authorized_key` et `community.crypto.openssh_keypair`

[Lien vers la doc de `authorized_key`](https://docs.ansible.com/ansible/latest/collections/ansible/posix/authorized_key_module.html)

[Lien vers la doc de `openssh_keypair`](https://docs.ansible.com/ansible/latest/collections/community/crypto/openssh_keypair_module.html)

`authorized_key` ajoute ou supprime une cle ssh autorise (dans le fichier du meme nom) pour un utilisateur donne.

`openssh_keypair` genere une cle et permet de la gerer.

> [!WARNING]
> Il faut bien faire attention a qui on est, la gestion des utilisateurs et des cles peut etre complique a plusieurs egards.

### Quelques options utiles du modules `openssh_keypair`

- `attributes` : attributs des fichiers
- `passphrase` : mot de passe pour la cle.
- `comment` : commentaire sur la cle
- `force` : force le renouvellement de la cle meme si elle existe
- `group` : groupe du fichier
- `mode` : permissions (chmod like)
- `owner` : proprietaire
- `path` : chemin des cles
- `regenerate` : `never`, `fail`, `partial_idempotence` (defaut), `full_idempotence`, `always`.
- `state` : `present`, `absent`
- `type` : rsa, dsa, rsa1, ecdsa, ed25519

> [!TIP]
> Si une cle est cassee, il faut passer l'attribut force a yes.

### Exemple d'utilisation du module `openssh_keypair`

On va generer une cle en local (sur la machine node manager, l'host) :

```yml
- name: generation de cle ssh
  community.crypto.openssh_keypair:
    path: '/tmp/testssh'
    state: 'present'
  delegates_to: localhost
  run_once: true
```

Cela cree la cle. Cependant le module ne prend pas en charge les mots de passes hashes ou un vault, ce qui rend son utilisation a mon avis restreinte a des environnements qui ne necessitent pas une forte securite.

### Quelques options utiles du module `authorized_key`

- `comment` : change le commentaire sur la cle
- `exclusive` : si oui ou non on supprime les autre cles non specifiees dans la fichier authorized_keys. De ;ultipl cles peuvent etre en effet specifie dans le `key`.
- `key`: Une ou plusieurs cles publiques. Peuvent etre separees par un retour a la ligne "\n". Peut etre aussu une url comme `https://github.com/username.keys` ou bienvia `file://`.
- `manage_dir` : Si oui ou non le module doit gerer le dossier. Si oui, il va creer le repertoire ainsi que les differents droits sur le dossier et les fichiers. Il faut mettre `false` si on utilise un repertoire different pour le fichier authorized_keys.
- `path` : Le chemin d'acces du fichier `authorized_keys`
- `state` : `present` ou `absent`.
- `user` : le nom d'utilisateur sur leuquel sera installe le `authorized_keys`
- `validate_certs` : valider ou non les certificats si url.

### Exemple d'utilisation du module `authorized_key`

Exemple pris du site Ansible :

```yml
- name: Set authorized key taken from file
  ansible.posix.authorized_key:
    user: charlie
    state: present
    key: "{{ lookup('file', '/home/charlie/.ssh/id_rsa.pub') }}"

- name: Set authorized keys taken from url
  ansible.posix.authorized_key:
    user: charlie
    state: present
    key: https://github.com/charlie.keys

- name: Set authorized keys taken from path on controller node
  ansible.posix.authorized_key:
    user: charlie
    state: present
    key: file:///home/charlie/.ssh/id_rsa.pub

- name: Set authorized keys taken from url using lookup
  ansible.posix.authorized_key:
    user: charlie
    state: present
    key: "{{ lookup('url', 'https://github.com/charlie.keys', split_lines=False) }}"

- name: Set authorized key in alternate location
  ansible.posix.authorized_key:
    user: charlie
    state: present
    key: "{{ lookup('file', '/home/charlie/.ssh/id_rsa.pub') }}"
    path: /etc/ssh/authorized_keys/charlie
    manage_dir: false

- name: Set up multiple authorized keys
  ansible.posix.authorized_key:
    user: deploy
    state: present
    key: '{{ item }}'
  with_file:
    - public_keys/doe-jane
    - public_keys/doe-john

- name: Set authorized key defining key options
  ansible.posix.authorized_key:
    user: charlie
    state: present
    key: "{{ lookup('file', '/home/charlie/.ssh/id_rsa.pub') }}"
    key_options: 'no-port-forwarding,from="10.0.1.1"'

- name: Set authorized key without validating the TLS/SSL certificates
  ansible.posix.authorized_key:
    user: charlie
    state: present
    key: https://github.com/user.keys
    validate_certs: false

- name: Set authorized key, removing all the authorized keys already set
  ansible.posix.authorized_key:
    user: root
    key: "{{ lookup('file', 'public_keys/doe-jane') }}"
    state: present
    exclusive: true

- name: Set authorized key for user ubuntu copying it from current user
  ansible.posix.authorized_key:
    user: ubuntu
    state: present
    key: "{{ lookup('file', lookup('env','HOME') + '/.ssh/id_rsa.pub') }}"
```

## `delegate_to`, `run_once`, `local`, `local_action`

[Lien vers la doc.](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_delegation.html)

Deleguer une tache consiste a executer une tache sur une autre serveur que ceux specifies au sein de l'inventory.

Une `local_action` sert a executer une action en local comme son nom l'indique.

`run_once` specifie que le job ne doit etre fait qu'une seule fois.

> [!WARNING]
> Certaines taches telles que `include`, `add_host`, et `debug` ne peuvent pas etre deleguees. Si l'attribut `connection` indique que le `support` est a False ou None, alors la tache ne peut pas etre deleguee.

### Exemple de delegation

Venant de la documentation Ansible :

```yml
---
- hosts: webservers
  serial: 5

  tasks:
    - name: Take out of load balancer pool
      ansible.builtin.command: /usr/bin/take_out_of_pool {{ inventory_hostname }}
      delegate_to: 127.0.0.1

    - name: Actual steps would go here
      ansible.builtin.yum:
        name: acme-web-stack
        state: latest

    - name: Add back to load balancer pool
      ansible.builtin.command: /usr/bin/add_back_to_pool {{ inventory_hostname }}
      delegate_to: 127.0.0.1
```

### Exemple d'une `local_action`

```yml
---
# ...

  tasks:
    - name: Take out of load balancer pool
      local_action: ansible.builtin.command /usr/bin/take_out_of_pool {{ inventory_hostname }}

# ...

    - name: Add back to load balancer pool
      local_action: ansible.builtin.command /usr/bin/add_back_to_pool {{ inventory_hostname }}
```

### Exemple de `run_once`

```yml
---
# ...

  tasks:
    - name: Send summary mail
      local_action:
        module: community.general.mail
        subject: "Summary Mail"
        to: "{{ mail_recipient }}"
        body: "{{ mail_body }}"
      run_once: True
```

