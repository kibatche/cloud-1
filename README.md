# cloud-1
A 42 project using ansible.

# Ansible

## Concepts

### Control-node

La machine sur laquelle est installe le cli ansible (`ansible-playbook`, `ansible`, `ansible-vault`). Cela peut etre n'importe quel ordinateur avec les specifications necessaires.

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

- On peut configurer l'hote sur lequel on se connecte avec SSH pour se faciliter la vie. On peut par exemple faire en sorte de juste ecrire `ssh cloud-1` Exemple

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

- On peut tester le connexion a un serveur distant et la presence d'un interpreteur python accepte via la commande : `ansible -i "root@chbd-cloud1.duckdns.org," all -m ping`. Ici on se connecte au serveur cloud1.duckdns.org et fait un ping dessus ainsi qu'une decouverte de l'interpreteur installe. Le flag `-i` correspond a l'option `--inventory` qui specifie l'hote a tester (voir ci-dessus).
- 


