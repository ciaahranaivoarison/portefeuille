/// Dictionnaire français vers (anglais, malagasy).
///
/// Les textes malgaches sont à faire relire par un locuteur avant la
/// présentation finale. Pour corriger une traduction, modifiez simplement
/// le texte entre guillemets : le reste de l'application s'adapte.
final Map<String, (String, String)> dictionnaire = {
  // ── Navigation et titres ──
  'Accueil': ('Home', 'Fandraisana'),
  'Comptes': ('Accounts', 'Kaonty'),
  'Historique': ('History', 'Tantara'),
  'Budgets': ('Budgets', 'Tetibola'),
  'Stats': ('Stats', 'Statistika'),
  'Statistiques': ('Statistics', 'Statistika'),
  'Paramètres': ('Settings', 'Fandrindrana'),
  "Gestion d'argent": ('Money Manager', 'Fitantanana vola'),
  'Votre carnet de comptes': ('Your account book', 'Ny bokin’ny kaontinao'),

  // ── Accueil ──
  'Argent total disponible': ('Total money available', 'Vola azo ampiasaina rehetra'),
  'Ajouter une opération': ('Add a transaction', 'Hanampy hetsika'),
  'Revenus du mois': ('Income this month', 'Fidiram-bola amin’ity volana ity'),
  'Dépenses du mois': ('Spending this month', 'Fandaniana amin’ity volana ity'),
  'Argent restant': ('Money left', 'Vola sisa'),
  'Revenus moins dépenses du mois': (
    'Income minus spending this month',
    'Fidiram-bola esorina ny fandaniana amin’ity volana ity',
  ),
  'Mes comptes': ('My accounts', 'Ny kaontiko'),

  // ── Comptes ──
  'Total de tous les comptes': ('Total of all accounts', 'Totalin’ny kaonty rehetra'),
  'Nouveau compte': ('New account', 'Kaonty vaovao'),
  'Aucun compte': ('No accounts', 'Tsy misy kaonty'),
  'Créez votre premier compte ci-dessous.': (
    'Create your first account below.',
    'Mamoròna ny kaonty voalohany eto ambany.',
  ),
  'Ajouter un compte': ('Add an account', 'Hanampy kaonty'),
  'Espèces': ('Cash', 'Vola an-tanana'),
  'Banque': ('Bank', 'Banky'),
  'Modifier le compte': ('Edit account', 'Ovao ny kaonty'),
  'Nom du compte': ('Account name', 'Anaran’ny kaonty'),
  'Ex. : MVola, Banque, Espèces': (
    'E.g.: MVola, Bank, Cash',
    'Oh: MVola, Banky, Vola an-tanana',
  ),
  'Type de compte': ('Account type', 'Karazan’ny kaonty'),
  'Solde de départ (Ar)': ('Starting balance (Ar)', 'Vola fanombohana (Ar)'),
  "C'est l'argent présent sur le compte avant votre première opération.": (
    'This is the money in the account before your first transaction.',
    'Ity no vola ao amin’ny kaonty alohan’ny hetsika voalohany.',
  ),
  "Les revenus, dépenses et transferts s'y ajoutent.": (
    'Income, spending and transfers are added to it.',
    'Ho tafiditra ao ny fidiram-bola, ny fandaniana ary ny famindrana.',
  ),
  'Supprimer ce compte ?': ('Delete this account?', 'Fafana ve ity kaonty ity?'),
  "Un compte ne peut être supprimé que s'il n'a aucune opération.": (
    'An account can only be deleted if it has no transactions.',
    'Tsy azo fafana ny kaonty raha mbola misy hetsika ao aminy.',
  ),
  'Saisissez un nom pour le compte.': (
    'Enter a name for the account.',
    'Ampidiro ny anaran’ny kaonty.',
  ),
  'Un compte porte déjà ce nom.': (
    'An account already has this name.',
    'Efa misy kaonty mitondra io anarana io.',
  ),

  // ── Boutons et mots courants ──
  'Supprimer': ('Delete', 'Fafao'),
  'Annuler': ('Cancel', 'Aoka ihany'),
  'Enregistrer': ('Save', 'Tehirizina'),
  'Enregistrer les modifications': ('Save changes', 'Tehirizina ny fanovana'),

  // ── Opérations ──
  'Nouvelle opération': ('New transaction', 'Hetsika vaovao'),
  "Modifier l'opération": ('Edit transaction', 'Ovao ny hetsika'),
  'Revenu': ('Income', 'Fidiram-bola'),
  'Dépense': ('Expense', 'Fandaniana'),
  'Transfert': ('Transfer', 'Famindrana'),
  'Montant (Ar)': ('Amount (Ar)', 'Vola (Ar)'),
  'Saisissez un montant': ('Enter an amount', 'Ampidiro ny vola'),
  'Compte': ('Account', 'Kaonty'),
  'Compte de départ': ('From account', 'Kaonty avy'),
  "Compte d'arrivée": ('To account', 'Kaonty alehana'),
  'Catégorie': ('Category', 'Sokajy'),
  'Date': ('Date', 'Daty'),
  'Note (facultatif)': ('Note (optional)', 'Fanamarihana (tsy voatery)'),
  'Ex. : Déjeuner': ('E.g.: Lunch', 'Oh: Sakafo atoandro'),
  'Saisissez un montant supérieur à 0.': (
    'Enter an amount greater than 0.',
    'Ampidiro vola mihoatra ny 0.',
  ),
  'Choisissez un compte.': ('Choose an account.', 'Misafidiana kaonty.'),
  'Choisissez une catégorie.': ('Choose a category.', 'Misafidiana sokajy.'),
  'Le montant doit être supérieur à 0.': (
    'The amount must be greater than 0.',
    'Tsy maintsy mihoatra ny 0 ny vola.',
  ),
  'Choisissez deux comptes différents pour le transfert.': (
    'Choose two different accounts for the transfer.',
    'Misafidiana kaonty roa samy hafa ho an’ny famindrana.',
  ),
  'Supprimer cette opération ?': (
    'Delete this transaction?',
    'Fafana ve ity hetsika ity?',
  ),
  'Les soldes seront recalculés automatiquement.': (
    'Balances will be recalculated automatically.',
    'Havaozina ho azy ny vola sisa.',
  ),

  // ── Historique ──
  'Chargement…': ('Loading…', 'Mahandrasa…'),
  'Rechercher une note, une catégorie, un compte': (
    'Search a note, category or account',
    'Karohy fanamarihana, sokajy na kaonty',
  ),
  'Toutes les dates': ('All dates', 'Daty rehetra'),
  "Aujourd'hui": ('Today', 'Androany'),
  'Cette semaine': ('This week', 'Ity herinandro ity'),
  'Ce mois': ('This month', 'Ity volana ity'),
  'Mois précédent': ('Previous month', 'Volana lasa'),
  'Personnalisée': ('Custom', 'Manokana'),
  'Période personnalisée': ('Custom period', 'Elanelana manokana'),
  'Filtres': ('Filters', 'Sivana'),
  'Tous': ('All', 'Rehetra'),
  'Toutes': ('All', 'Rehetra'),
  'Catégories de dépenses': ('Expense categories', 'Sokajin’ny fandaniana'),
  'Catégories de revenus': ('Income categories', 'Sokajin’ny fidiram-bola'),
  'Réinitialiser': ('Reset', 'Averina'),
  'Appliquer': ('Apply', 'Ampiharo'),
  'Tout effacer': ('Clear all', 'Fafao daholo'),
  'Aucun résultat': ('No results', 'Tsy misy valiny'),
  'Aucune opération': ('No transactions', 'Tsy misy hetsika'),
  'Modifiez la recherche ou effacez les filtres.': (
    'Change your search or clear the filters.',
    'Ovay ny fikarohana na fafao ny sivana.',
  ),
  "Appuyez sur « Ajouter une opération » à l'accueil pour saisir la première.": (
    'Tap “Add a transaction” on the home screen to enter the first one.',
    'Tsindrio ny « Hanampy hetsika » eo amin’ny fandraisana mba hampidirana ny voalohany.',
  ),
  'Hier': ('Yesterday', 'Omaly'),
  'Sans catégorie': ('No category', 'Tsy misy sokajy'),

  // ── Budgets ──
  'Une limite mensuelle par catégorie': (
    'A monthly limit per category',
    'Fetra isam-bolana isaky ny sokajy',
  ),
  'Budget mensuel total': ('Total monthly budget', 'Tetibola isam-bolana rehetra'),
  'Nouveau budget': ('New budget', 'Tetibola vaovao'),
  'Mois suivant': ('Next month', 'Volana manaraka'),
  'Ensemble des budgets': ('All budgets', 'Ny tetibola rehetra'),
  'Dépassé': ('Over budget', 'Tafahoatra'),
  'Presque atteint': ('Almost reached', 'Efa ho tonga'),
  'Dans le budget': ('Within budget', 'Ao anatin’ny tetibola'),
  'Prévu': ('Planned', 'Nomanina'),
  'Dépensé': ('Spent', 'Lany'),
  'Restant': ('Left', 'Sisa'),
  'Dépassement': ('Overspent', 'Fahatafahoatana'),
  'Aucun budget défini': ('No budget set', 'Tsy mbola misy tetibola'),
  "Fixez une limite mensuelle par catégorie, par exemple 300 000 Ar pour l'alimentation.": (
    'Set a monthly limit per category, for example 300,000 Ar for food.',
    'Mametraha fetra isam-bolana isaky ny sokajy, ohatra 300 000 Ar ho an’ny sakafo.',
  ),
  'Modifier le budget': ('Edit budget', 'Ovao ny tetibola'),
  'Budget mensuel': ('Monthly budget', 'Tetibola isam-bolana'),
  "Ce budget s'applique chaque mois.": (
    'This budget applies every month.',
    'Ampiharina isam-bolana ity tetibola ity.',
  ),
  'Catégorie de dépenses': ('Expense category', 'Sokajin’ny fandaniana'),
  'Toutes les catégories ont déjà un budget.': (
    'All categories already have a budget.',
    'Samy manana tetibola ny sokajy rehetra.',
  ),
  'Budget par mois (Ar)': ('Budget per month (Ar)', 'Tetibola isam-bolana (Ar)'),
  'par mois': ('per month', 'isam-bolana'),
  'Supprimer ce budget ?': ('Delete this budget?', 'Fafana ve ity tetibola ity?'),
  'Les dépenses ne sont pas supprimées : seul le budget est retiré.': (
    'Spending is not deleted: only the budget is removed.',
    'Tsy fafana ny fandaniana: ny tetibola ihany no esorina.',
  ),
  'Le budget doit être supérieur à 0.': (
    'The budget must be greater than 0.',
    'Tsy maintsy mihoatra ny 0 ny tetibola.',
  ),

  // ── Statistiques ──
  'Solde de la période': ('Balance for the period', 'Sisa amin’ny elanelana'),
  'Revenus': ('Income', 'Fidiram-bola'),
  'Dépenses': ('Spending', 'Fandaniana'),
  'Dépenses par catégorie': ('Spending by category', 'Fandaniana isaky ny sokajy'),
  'Évolution des dépenses': ('Spending over time', 'Fivoaran’ny fandaniana'),
  'Aucune dépense sur cette période.': (
    'No spending in this period.',
    'Tsy misy fandaniana tamin’ity elanelana ity.',
  ),
  'Fév': ('Feb', 'Feb'),
  'Avr': ('Apr', 'Apr'),
  'Mai': ('May', 'Mey'),
  'Juin': ('Jun', 'Jon'),
  'Juil': ('Jul', 'Jol'),
  'Août': ('Aug', 'Aog'),
  'Oct': ('Oct', 'Okt'),
  'Déc': ('Dec', 'Des'),

  // ── Catégories ──
  'Catégories': ('Categories', 'Sokajy'),
  'Nouvelle catégorie': ('New category', 'Sokajy vaovao'),
  'Par défaut': ('Default', 'Mahazatra'),
  'Les catégories par défaut sont verrouillées.': (
    'Default categories are locked.',
    'Voahidy ny sokajy mahazatra.',
  ),
  'Ajoutez les vôtres, puis modifiez-les ou supprimez-les.': (
    'Add your own, then edit or delete them.',
    'Ampio ny anao, avy eo ovay na fafao izy ireo.',
  ),
  'Les catégories par défaut ne peuvent pas être modifiées.': (
    'Default categories cannot be edited.',
    'Tsy azo ovaina ny sokajy mahazatra.',
  ),
  'Modifier la catégorie': ('Edit category', 'Ovao ny sokajy'),
  'Catégorie de revenus': ('Income category', 'Sokajin’ny fidiram-bola'),
  'Nom de la catégorie': ('Category name', 'Anaran’ny sokajy'),
  'Ex. : Scolarité': ('E.g.: Tuition', 'Oh: Sekoly'),
  'Supprimer cette catégorie ?': (
    'Delete this category?',
    'Fafana ve ity sokajy ity?',
  ),
  'Cette catégorie sera supprimée.': (
    'This category will be deleted.',
    'Hofafana ity sokajy ity.',
  ),
  'Les budgets de cette catégorie seront retirés.': (
    'The budgets for this category will be removed.',
    'Hesorina ny tetibolan’ity sokajy ity.',
  ),
  'Saisissez un nom pour la catégorie.': (
    'Enter a name for the category.',
    'Ampidiro ny anaran’ny sokajy.',
  ),
  'Une catégorie porte déjà ce nom.': (
    'A category already has this name.',
    'Efa misy sokajy mitondra io anarana io.',
  ),
  'Alimentation': ('Food', 'Sakafo'),
  'Transport': ('Transport', 'Fitaterana'),
  'Logement': ('Housing', 'Fonenana'),
  'Santé': ('Health', 'Fahasalamana'),
  'Téléphone / Internet': ('Phone / Internet', 'Telefaona / Internet'),
  'Loisirs': ('Leisure', 'Fialam-boly'),
  'Shopping': ('Shopping', 'Fividianana'),
  'Autres': ('Other', 'Hafa'),
  'Salaire': ('Salary', 'Karama'),
  'Commerce': ('Business', 'Varotra'),
  'Cadeau': ('Gift', 'Fanomezana'),

  // ── Paramètres ──
  'Personnalisation': ('Personalization', 'Fanamboarana'),
  'Apparence': ('Appearance', 'Endrika'),
  'Langue': ('Language', 'Fiteny'),
  'Mode clair': ('Light mode', 'Maody mazava'),
  'Mode sombre': ('Dark mode', 'Maody maizina'),
  'Automatique (selon le téléphone)': (
    'Automatic (follows your phone)',
    'Automatika (araka ny findainao)',
  ),
  'Automatique': ('Automatic', 'Automatika'),
  'Sécurité': ('Security', 'Fiarovana'),
  'Paramètres de sécurité': ('Security settings', 'Fandrindrana ny fiarovana'),
  'Code PIN activé': ('PIN code on', 'Mandeha ny kaody PIN'),
  'Mot de passe activé': ('Password on', 'Mandeha ny teny miafina'),
  'Mot de passe, code PIN, biométrie': (
    'Password, PIN code, biometrics',
    'Teny miafina, kaody PIN, biometrika',
  ),
  'Activée': ('On', 'Mandeha'),
  'Données': ('Data', 'Angona'),
  'Ajouter, modifier ou supprimer les vôtres': (
    'Add, edit or delete your own',
    'Hanampy, hanova na hamafa ny anao',
  ),
  'Sauvegarde et restauration': ('Backup and restore', 'Fitehirizana sy famerenana'),
  'Sauvegarder vos données ou les restaurer': (
    'Back up your data or restore it',
    'Hitahiry ny angonao na hamerina azy',
  ),
  'Projet de stage L3': ('L3 internship project', 'Tetikasa stage L3'),
  'fonctionne hors ligne': ('works offline', 'mandeha tsy mila Internet'),

  // ── Apparence et langue ──
  'Choisissez votre ambiance': ('Choose your mood', 'Misafidiana ny endrika tianao'),
  'Fond crème, pour la journée': (
    'Cream background, for daytime',
    'Fototra mavo malefaka, ho an’ny andro',
  ),
  'Bruns chocolat, reposant le soir': (
    'Chocolate browns, easy on the eyes at night',
    'Volon-tsokola, mahafaly ny maso amin’ny hariva',
  ),
  'Suit le réglage de votre téléphone': (
    'Follows your phone setting',
    'Manaraka ny fandrindran’ny findainao',
  ),
  "Votre choix s'applique à tous les écrans et reste mémorisé quand vous fermez l'application.": (
    'Your choice applies to every screen and is remembered when you close the app.',
    'Ampiharina amin’ny efijery rehetra ny safidinao ary tehirizina rehefa mihidy ny application.',
  ),
  "Choisissez la langue de l'application": (
    'Choose the app language',
    'Misafidiana ny fiteny ampiasain’ny application',
  ),
  "Le changement s'applique tout de suite à tous les écrans.": (
    'The change applies immediately to every screen.',
    'Ampiharina avy hatrany amin’ny efijery rehetra ny fanovana.',
  ),

  // ── Sécurité ──
  'Application protégée': ('App protected', 'Voaaro ny application'),
  'Application non protégée': ('App not protected', 'Tsy voaaro ny application'),
  "N'importe qui peut ouvrir l'application.": (
    'Anyone can open the app.',
    'Na iza na iza afaka manokatra ny application.',
  ),
  'Activez un code pour protéger vos données.': (
    'Turn on a code to protect your data.',
    'Alefaso ny kaody mba hiarovana ny angonao.',
  ),
  'Mot de passe et code PIN': ('Password and PIN code', 'Teny miafina sy kaody PIN'),
  'Protection par code': ('Code protection', 'Fiarovana amin’ny kaody'),
  "Désactivée : l'application s'ouvre sans code.": (
    'Off: the app opens without a code.',
    'Tsy mandeha: misokatra tsy misy kaody ny application.',
  ),
  'demandé au lancement': ('asked at launch', 'angatahina rehefa misokatra'),
  'Modifier le code': ('Change code', 'Ovao ny kaody'),
  'Changer de code PIN ou de mot de passe': (
    'Change your PIN code or password',
    'Hanova kaody PIN na teny miafina',
  ),
  'Biométrie': ('Biometrics', 'Biometrika'),
  'biométrie': ('biometrics', 'biometrika'),
  'Empreinte digitale ou visage': ('Fingerprint or face', 'Rantsan-tànana na tarehy'),
  'Mot de passe': ('Password', 'Teny miafina'),
  'Code PIN': ('PIN code', 'Kaody PIN'),
  "Indisponible : aucune empreinte ni aucun visage n'est enregistré sur ce téléphone.": (
    'Unavailable: no fingerprint or face is enrolled on this phone.',
    'Tsy azo: tsy misy rantsan-tànana na tarehy voatahiry ao amin’ity findaina ity.',
  ),
  "Activez d'abord la protection par code.": (
    'Turn on code protection first.',
    'Alefaso aloha ny fiarovana amin’ny kaody.',
  ),
  "l'empreinte digitale": ('your fingerprint', 'rantsan-tànana'),
  'la reconnaissance faciale': ('face recognition', 'famantarana ny tarehy'),
  "l'empreinte digitale ou la reconnaissance faciale": (
    'your fingerprint or face recognition',
    'rantsan-tànana na famantarana ny tarehy',
  ),
  'la biométrie du téléphone': ('the phone’s biometrics', 'biometrikan’ny findaina'),
  'Comment ça marche ?': ('How does it work?', 'Ahoana ny fiasany?'),
  "Votre code n'est jamais enregistré en clair : seule une empreinte chiffrée reste sur le téléphone.": (
    'Your code is never stored in plain text: only an encrypted fingerprint of it stays on the phone.',
    'Tsy voatahiry mazava ny kaodinao: mari-pamantarana voaaro ihany no tehirizina ao amin’ny findaina.',
  ),
  "L'empreinte et le visage sont gérés par Android.": (
    'Fingerprint and face are handled by Android.',
    'Android no mitantana ny rantsan-tànana sy ny tarehy.',
  ),
  "L'application reçoit seulement « réussi » ou « échoué ».": (
    'The app only receives “success” or “failure”.',
    'Ny application dia mahazo fotsiny ny hoe « nahomby » na « tsy nahomby ».',
  ),
  'Après 5 erreurs, le déverrouillage est bloqué pendant 30 secondes.': (
    'After 5 mistakes, unlocking is blocked for 30 seconds.',
    'Aorian’ny diso in-5, voasakana mandritra ny 30 segondra ny fanokafana.',
  ),
  'Protection activée.': ('Protection turned on.', 'Nandeha ny fiarovana.'),
  'Le code sera demandé au lancement.': (
    'The code will be asked at launch.',
    'Angatahina rehefa misokatra ny kaody.',
  ),
  'Protection désactivée.': ('Protection turned off.', 'Najanona ny fiarovana.'),
  'Code modifié.': ('Code changed.', 'Novaina ny kaody.'),
  'Activation annulée.': ('Activation cancelled.', 'Nafoana ny fampandehanana.'),
  "Confirmez l'activation du déverrouillage biométrique": (
    'Confirm turning on biometric unlock',
    'Hamafiso ny fampandehanana ny fanokafana biometrika',
  ),
  "Déverrouillez Gestion d'argent": ('Unlock Money Manager', 'Sokafy ny Fitantanana vola'),
  'Confirmez votre identité': ('Confirm your identity', 'Hamafiso fa ianao ilay tompony'),

  // ── Création du code ──
  "Protéger l'application": ('Protect the app', 'Hiaro ny application'),
  'Choisissez votre méthode': ('Choose your method', 'Misafidiana ny fomba'),
  'Longueur du code': ('Code length', 'Halavan’ny kaody'),
  '6 chiffres (plus sûr)': ('6 digits (safer)', '6 isa (azo antoka kokoa)'),
  'Créez votre nouveau code': ('Create your new code', 'Mamoròna ny kaody vaovao'),
  'Créez votre code': ('Create your code', 'Mamoròna ny kaodinao'),
  'Confirmez votre code': ('Confirm your code', 'Hamafiso ny kaodinao'),
  'Les deux codes sont différents. Recommencez.': (
    'The two codes are different. Start again.',
    'Samy hafa ny kaody roa. Atombohy indray.',
  ),
  'Mot de passe (6 caractères minimum)': (
    'Password (6 characters minimum)',
    'Teny miafina (6 tarehintsoratra farafahakeliny)',
  ),
  'Votre mot de passe': ('Your password', 'Ny teny miafinao'),
  'Saisissez-le à nouveau': ('Enter it again', 'Ampidiro indray'),
  'Confirmation': ('Confirmation', 'Fanamarinana'),
  'Les deux saisies sont différentes.': (
    'The two entries are different.',
    'Samy hafa ny fampidirana roa.',
  ),
  'Enregistrer le mot de passe': ('Save password', 'Tehirizina ny teny miafina'),
  "Le code n'est jamais enregistré en clair : seule une empreinte chiffrée est conservée sur ce téléphone.": (
    'The code is never stored in plain text: only an encrypted fingerprint of it is kept on this phone.',
    'Tsy voatahiry mazava ny kaody: mari-pamantarana voaaro ihany no tehirizina ao amin’ity findaina ity.',
  ),
  "En cas d'oubli, il faut désinstaller l'application, ce qui efface vos données.": (
    'If you forget it, the app must be uninstalled, which erases your data.',
    'Raha adino ny kaody, tsy maintsy esorina ny application ary ho foana ny angonao.',
  ),
  'Pensez à faire une sauvegarde.': ('Remember to make a backup.', 'Tadidio ny manao fitehirizana.'),
  'Trop court': ('Too short', 'Fohy loatra'),
  'Faible': ('Weak', 'Malemy'),
  'Moyen': ('Fair', 'Antonony'),
  'Bon': ('Good', 'Tsara'),
  'Excellent': ('Excellent', 'Tena tsara'),
  'Le mot de passe doit contenir au moins 6 caractères.': (
    'The password must contain at least 6 characters.',
    'Ny teny miafina dia tsy maintsy misy tarehintsoratra 6 farafahakeliny.',
  ),

  // ── Verrouillage ──
  'Saisissez votre code PIN': ('Enter your PIN code', 'Ampidiro ny kaody PIN-nao'),
  'Saisissez votre mot de passe': ('Enter your password', 'Ampidiro ny teny miafinao'),
  'Code incorrect.': ('Wrong code.', 'Diso ny kaody.'),
  'Mot de passe incorrect.': ('Wrong password.', 'Diso ny teny miafina.'),
  'Déverrouiller': ('Unlock', 'Sokafy'),
  "Utiliser l'empreinte ou le visage": (
    'Use fingerprint or face',
    'Hampiasa rantsan-tànana na tarehy',
  ),

  // ── Sauvegarde et restauration ──
  'Vos données restent à vous': ('Your data stays yours', 'Anao ny angonao'),
  'La sauvegarde contient vos comptes, catégories, budgets et opérations, dans un fichier .json.': (
    'The backup contains your accounts, categories, budgets and transactions, in a .json file.',
    'Ao anaty rakitra .json ny kaonty, sokajy, tetibola ary hetsika.',
  ),
  'Elle se fait sans connexion Internet.': (
    'It works without an Internet connection.',
    'Atao tsy mila Internet izany.',
  ),
  "Le code de protection n'en fait pas partie.": (
    'The protection code is not part of it.',
    'Tsy ao ny kaody fiarovana.',
  ),
  'Sauvegarder mes données': ('Back up my data', 'Hitahiry ny angonako'),
  'Dernière sauvegarde': ('Last backup', 'Fitehirizana farany'),
  'Jamais': ('Never', 'Mbola tsy nisy'),
  'Enregistrer sur le téléphone': ('Save on the phone', 'Tehirizina ao amin’ny findaina'),
  'Partager (Drive, WhatsApp, e-mail…)': (
    'Share (Drive, WhatsApp, email…)',
    'Zarao (Drive, WhatsApp, mailaka…)',
  ),
  "Le fichier n'est pas chiffré : conservez-le dans un endroit sûr.": (
    'The file is not encrypted: keep it somewhere safe.',
    'Tsy voaaro ny rakitra: tehirizo amin’ny toerana azo antoka.',
  ),
  'Restaurer mes données': ('Restore my data', 'Hamerina ny angonako'),
  'Attention': ('Warning', 'Tandremo'),
  'La restauration remplace toutes les données actuelles par celles du fichier choisi.': (
    'Restoring replaces all current data with the data in the chosen file.',
    'Ny famerenana dia manolo ny angona rehetra ankehitriny amin’ny an’ilay rakitra voafidy.',
  ),
  'Restaurer depuis un fichier': ('Restore from a file', 'Hamerina avy amin’ny rakitra'),
  'Remplacer les données ?': ('Replace the data?', 'Hosoloina ve ny angona?'),
  'Restaurer': ('Restore', 'Hamerina'),
  'Restauration terminée': ('Restore complete', 'Vita ny famerenana'),
  'Vos données ont été restaurées.': ('Your data has been restored.', 'Voaverina ny angonao.'),
  'Sauvegarde annulée.': ('Backup cancelled.', 'Nafoana ny fitehirizana.'),
  'Sauvegarde enregistrée.': ('Backup saved.', 'Voatahiry ny fitehirizana.'),
  'Ce fichier est trop volumineux pour être une sauvegarde.': (
    'This file is too large to be a backup.',
    'Lehibe loatra ity rakitra ity ka tsy tahiry.',
  ),
  "Ce fichier n'est pas une sauvegarde valide.": (
    'This file is not a valid backup.',
    'Tsy tahiry mety ity rakitra ity.',
  ),
  "Ce fichier n'est pas une sauvegarde de Gestion d'argent.": (
    'This file is not a Money Manager backup.',
    'Tsy tahirin’ny Fitantanana vola ity rakitra ity.',
  ),
  "Cette sauvegarde vient d'une version plus récente de l'application.": (
    'This backup comes from a newer version of the app.',
    'Avy amin’ny dikan’ny application vaovao kokoa ity tahiry ity.',
  ),
  'Sauvegarde corrompue.': ('Corrupted backup.', 'Simba ny tahiry.'),
  'Vos données actuelles sont intactes.': (
    'Your current data is intact.',
    'Tsy niova ny angonao ankehitriny.',
  ),
  'Fichier invalide ou corrompu.': ('Invalid or corrupted file.', 'Tsy mety na simba ny rakitra.'),
  "Vos données actuelles n'ont pas été modifiées.": (
    'Your current data has not been changed.',
    'Tsy novaina ny angonao ankehitriny.',
  ),
  "La restauration remplace toutes les données actuelles de l'application.": (
    'Restoring replaces all the current data in the app.',
    'Ny famerenana dia manolo ny angona rehetra ao amin’ny application.',
  ),
  'Cette action est irréversible.': ('This action cannot be undone.', 'Tsy azo averina ity hetsika ity.'),
  'Enregistrer la sauvegarde': ('Save the backup', 'Tehirizina ny tahiry'),
  'Choisir cette catégorie': ('Choose this category', 'Fidio ity sokajy ity'),
  'Voir les opérations': ('View transactions', 'Hijery ny hetsika'),
  'Modifier le nom': ('Rename', 'Hanova ny anarana'),
  'Total': ('Total', 'Totaliny'),
  'Aucune opération dans cette catégorie.': (
    'No transactions in this category.',
    'Tsy misy hetsika amin’ity sokajy ity.',
  ),
  'Catégorie par défaut : elle ne peut être ni modifiée ni supprimée.': (
    'Default category: it cannot be edited or deleted.',
    'Sokajy mahazatra: tsy azo ovaina na fafana.',
  ),
  'Catégorie supprimée.': ('Category deleted.', 'Voafafa ny sokajy.'),
  'Touchez une catégorie pour voir ses opérations, la modifier ou la supprimer. Les catégories par défaut sont verrouillées.': (
    'Tap a category to see its transactions, edit it or delete it. Default categories are locked.',
    'Tsindrio ny sokajy iray mba hijerena ny hetsika, hanovana na hamafana azy. Voahidy ny sokajy mahazatra.',
  ),
  "Une icône est associée automatiquement au nom de la catégorie. Si le nom n'est pas reconnu, son initiale est utilisée.": (
    "An icon is matched automatically to the category name. If the name isn't recognized, its first letter is used.",
    'Misy sary mifanaraka ho azy amin’ny anaran’ny sokajy. Raha tsy fantatra ny anarana, ny litera voalohany no ampiasaina.',
  ),
  'Accès perdu ?': ('Lost access?', 'Tsy afaka miditra?'),
  "Choisissez comment retrouver l'accès à votre application.": (
    'Choose how to get back into your app.',
    'Misafidiana ny fomba hiverenana ao amin’ny application.',
  ),
  "J'ai mon code de récupération": (
    'I have my recovery code',
    'Manana ny kaody famerenana aho',
  ),
  'Saisissez-le pour choisir un nouveau code. Vos données sont conservées.': (
    'Enter it to choose a new code. Your data is kept.',
    'Ampidiro izy mba hisafidianana kaody vaovao. Tehirizina ny angonao.',
  ),
  'Code de récupération': ('Recovery code', 'Kaody famerenana'),
  'Vérifier et choisir un nouveau code': (
    'Verify and choose a new code',
    'Hamarino ary hisafidy kaody vaovao',
  ),
  'Le code contient 16 caractères.': (
    'The code has 16 characters.',
    'Ny kaody dia misy tarehintsoratra 16.',
  ),
  'Code de récupération incorrect.': (
    'Wrong recovery code.',
    'Diso ny kaody famerenana.',
  ),
  "Je n'ai plus mon code de récupération": (
    'I no longer have my recovery code',
    'Tsy manana ny kaody famerenana intsony aho',
  ),
  'La seule solution est de tout effacer et de repartir de zéro. Si vous avez une sauvegarde, vous pourrez la restaurer ensuite.': (
    'The only solution is to erase everything and start over. If you have a backup, you can restore it afterwards.',
    'Ny hany vahaolana dia ny mamafa ny zava-drehetra ary manomboka indray. Raha manana tahiry ianao, azonao averina aorian’izay.',
  ),
  "Réinitialiser l'application": ('Reset the app', 'Avereno ho vaovao ny application'),
  'Tout effacer ?': ('Erase everything?', 'Fafana daholo ve?'),
  'Tous vos comptes, opérations, budgets et catégories personnalisées seront supprimés définitivement. Cette action est irréversible.': (
    'All your accounts, transactions, budgets and custom categories will be permanently deleted. This cannot be undone.',
    'Ho voafafa tanteraka ny kaonty, hetsika, tetibola ary sokajy manokana rehetra. Tsy azo averina ity hetsika ity.',
  ),
  'Tapez SUPPRIMER pour confirmer :': (
    'Type the word SUPPRIMER to confirm:',
    'Soraty ny teny SUPPRIMER mba hanamafisana:',
  ),
  'Tout effacer:': ('Erase everything', 'Fafao daholo'),
  'Application réinitialisée': ('App reset', 'Voavao ny application'),
  'Vos données ont été effacées. Vous pouvez restaurer une sauvegarde depuis les paramètres.': (
    'Your data has been erased. You can restore a backup from the settings.',
    'Voafafa ny angonao. Azonao averina ny tahiry avy ao amin’ny fandrindrana.',
  ),
  'Pensez à faire une sauvegarde régulière : elle permet de tout restaurer après une réinitialisation.': (
    'Remember to back up regularly: it lets you restore everything after a reset.',
    'Tadidio ny manao fitehirizana tsy tapaka: ahafahana mamerina ny zava-drehetra aorian’ny famafana.',
  ),
  'La réinitialisation a échoué.': ('The reset failed.', 'Tsy nahomby ny famafana.'),
  'Notez ce code maintenant': ('Write this code down now', 'Soraty ankehitriny ity kaody ity'),
  "C'est la seule façon de retrouver l'accès si vous oubliez votre code, sans effacer vos données. Il ne sera plus jamais affiché.": (
    'This is the only way to get back in if you forget your code, without erasing your data. It will never be shown again.',
    'Ity ihany no fomba hiverenana raha adino ny kaodinao, tsy mamafa ny angonao. Tsy hasehoana intsony izy.',
  ),
  'Copier le code': ('Copy the code', 'Adikao ny kaody'),
  'Code copié.': ('Code copied.', 'Voadika ny kaody.'),
  'Écrivez-le sur papier et gardez-le hors du téléphone. Ne le partagez avec personne.': (
    'Write it on paper and keep it away from the phone. Do not share it with anyone.',
    'Soraty amin’ny taratasy ary tehirizo ivelan’ny findaina. Aza zarainao amin’ny olona.',
  ),
  "J'ai noté ce code en lieu sûr": (
    'I wrote this code down somewhere safe',
    'Efa nosoratako tany amin’ny toerana azo antoka ity kaody ity',
  ),
  'Terminer': ('Done', 'Vita'),
  'Cochez la case pour confirmer que vous avez noté le code.': (
    'Tick the box to confirm you have written the code down.',
    'Fafao ny boaty mba hanamafisana fa efa nosoratanao ny kaody.',
  ),
  'Récupération': ('Recovery', 'Famerenana'),
  'Créé': ('Created', 'Voaforona'),
  'Non créé': ('Not created', 'Tsy mbola voaforona'),
  "permet de retrouver l'accès si vous oubliez votre code": (
    'lets you get back in if you forget your code',
    'ahafahana miverina raha adino ny kaodinao',
  ),
  "recommandé en cas d'oubli": ('recommended in case you forget', 'tsara raha adino'),
  'Code PIN oublié ?': ('Forgot your PIN code?', 'Hadino ny kaody PIN?'),
  'Mot de passe oublié ?': ('Forgot your password?', 'Hadino ny teny miafina?'),
  'Posez votre doigt sur le capteur': (
    'Place your finger on the sensor',
    'Apetraho eo amin’ny sensor ny rantsan-tànanao',
  ),
  'Empreinte non reconnue. Réessayez.': (
    'Fingerprint not recognized. Try again.',
    'Tsy fantatra ny rantsan-tànana. Andramo indray.',
  ),
  "Trop d'essais d'empreinte. Utilisez votre code.": (
    'Too many fingerprint attempts. Use your code.',
    'Be loatra ny andrana rantsan-tànana. Ampiasao ny kaodinao.',
  ),
  "Capteur d'empreinte indisponible. Utilisez votre code.": (
    'Fingerprint sensor unavailable. Use your code.',
    'Tsy azo ampiasaina ny sensor rantsan-tànana. Ampiasao ny kaodinao.',
  ),
  "Touchez pour utiliser l'empreinte": (
    'Tap to use your fingerprint',
    'Tsindrio hampiasa ny rantsan-tànana',
  ),
  'Hors ligne': ('Offline', 'Tsy mila Internet'),
  'Données privées': ('Private data', 'Angona manokana'),
  'Sécurisé': ('Secure', 'Voaaro'),
  'Écrivez ici': ('Write here', 'Soraty eto'),
  'Appuyez sur le bouton + en haut à droite pour fixer une limite mensuelle par catégorie.': (
    'Tap the + button at the top right to set a monthly limit per category.',
    'Tsindrio ny bokotra + eo ambony havanana mba hametrahana fetra isam-bolana isaky ny sokajy.',
  ),
  'Un emoji est associé automatiquement au nom de la catégorie.': (
    'An emoji is automatically matched to the category name.',
    'Misy emoji mifanaraka amin’ny anaran’ny sokajy ho azy.',
  ),
  'Appuyez sur le bouton + en haut à droite pour créer votre premier compte.': (
    'Tap the + button at the top right to create your first account.',
    'Tsindrio ny bokotra + eo ambony havanana mba hamoronana ny kaonty voalohany.',
  ),
};