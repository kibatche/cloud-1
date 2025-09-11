# cloud-1 - Ansible

- [cloud-1 - Ansible](#cloud-1---ansible)
  - [Documentations](#documentations)
  - [Concepts](#concepts)
    - [Control-node](#control-node)
    - [Managed nodes](#managed-nodes)
    - [Inventory](#inventory)
    - [Playbooks](#playbooks)
    - [Modules](#modules)
    - [Plugins](#plugins)
  - [Bonnes pratiques et tips](#bonnes-pratiques-et-tips)
  - [Le fichier de configuration](#le-fichier-de-configuration)
    - [Le fichier ansible.cfg](#le-fichier-ansiblecfg)
    - [Le cli `ansible-config`](#le-cli-ansible-config)
  - [Le cli `ansible`](#le-cli-ansible)
    - [Introduction](#introduction)
    - [Quelques options a connaitre](#quelques-options-a-connaitre)
    - [Les modules](#les-modules)
  - [L'inventory](#linventory)
    - [Qu'est-ce que c'est ?](#quest-ce-que-cest-)
    - [Le fichier d'inventaire](#le-fichier-dinventaire)
    - [Hierarchisation d'un projet ansible](#hierarchisation-dun-projet-ansible)
  - [Le playbook](#le-playbook)
    - [Quelques options](#quelques-options)
  - [Le module `file`](#le-module-file)

## Documentations

Le site officiel de ansible : [lien](https://docs.ansible.com/)

Les videos tres completes de xavki sur youtube : [lien](https://www.youtube.com/watch?v=8Hb-i9lXdXA&list=PLn6POgpklwWoCpLKOSw3mXCqbRocnhrh-&index=1)

## Concepts

### Control-node

La machine sur laquelle est installee le cli ansible (`ansible-playbook`, `ansible`, `ansible-vault`). Cela peut etre n'importe quel ordinateur avec les specifications necessaires.

### Managed nodes

On parle aussi de `hosts`. Ce sont les machines cibles, comme un serveur par exemple, qui vont etre gerees par ansible.

Ansible n'est normalement pas installe sur ces machines, sauf cas specifiques et deconseilles.

### Inventory

Une liste de `managed nodes` provisionnes par l'intermediaire d'une ou plusieurs `inventory sources`. L'inventaire peut servir a specifier differentes informations sur differents nodes, par exemple l'adresse IP. Il peut etre egalement utilise pour assigne des groupes, aui permet aussi bien de selectionner des nodes dans les `plays` que de gerer l'assignement des variables au sein des blocs (bulk assignement, a checker ce que c'est exactement).

Les fichiers sources des `inventory` peut aussi etre denomme par `hostfile`.

### Playbooks

Ils contiennent les `Plays`, qui sont les unites basiques des executions operees par ansible. C'est aussi bien une notion abstraite d'execution que la description des fichiers sur lesquelles `ansible-playbook` opere.

Les `playbooks` sont ecrits en YAML afin de faciliter leur lecture.

- `Plays` : c'est le contexte principal d'execution d'ansible. C'est objet `playbook` lie les `managed nodes` aux taches definies. Un `Play` contient les variables, les roles et une liste ordonnee de tahce, et peut etre execute repetitivement. Il consiste en une sorte de bloucle implicite sur les hotes lies ainsi que les taches, tout en definissant comment iterer sur ces donnees.
  - `Roles` : Une distribution limitees de contenu Ansible reutilisables (taches, gestionnaires (handler), variables, plugins, templates et fichiers) a utiliser au sein d'un `Play`. Pour utiliser uyne ressource d'un role, ce dernier doit etre importe.
  - `Tasks` : La deifnition d'une action a appliquer sur un hote gere. Il est possible d'executer une seule tache par l'intermediaire d'un commande cree pour en utilisant `ansible` ou `ansible-console`.
  - `Handlers` : Une forme specifique de `task`, qui ne s'execute qu'une fois notifiee par une tache precedente qui a eu pour resultat un changement de statut (`changed status`).

### Modules

Le code ou les binaires que ansible copie ou execute au sein des `managed nodes` - au besoin - afin d'accomplir une action specifique deifnie au sein d'une `Task`.

### Plugins

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

### Le fichier ansible.cfg

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

## L'inventory

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

## Le playbook

Le playbook sert a plusieurs choses, mais principalement :

- a declencher les action a realiser
- a articuler l'inventory - cad les machines gerees (managed nodes) - avec les roles, cad les actions a executer
- a executer des tasks. **C'est une mauvaise pratique a eviter**
- inclure des variables. **C'est une mauvaise pratique a eviter**
- specifier un utilisateur particulier et sa maniere d'interagir avec les tasks

La commande utilisee pour les `playbooks` est `ansible-playbooks`

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

VOici un playbook possible :

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
➜  cloud-1 git:(main) ansible-playbook -i recette/inventory recette/playbook/playbook.yml -e "var1=yoyo"      

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
