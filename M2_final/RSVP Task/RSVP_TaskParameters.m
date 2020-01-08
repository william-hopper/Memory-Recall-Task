%% Task Parameters for RSVP
% Change to suit the task
%% Experimental Phase
clearvars;

% misc
visual_angle = 2.5; % Target stream offset in visual angle 
screen_distance = 80; % distance of participant to screen in cm (will default to 80 if left blank)
n_offers = 3*2*8; % number of seperate offers to be made (conditions*number of repetitions)

effort_idx = [1 2]; % effort level; 1 = low; 2 = high;
effort_eng = {'Low', 'High'};
effort = {'Bas', 'Haut'};
bonus_idx = [1 2 3]; % bonus condition
bonus = [0.5 1 2]; % actual bonus
Difficulty = [3 4 5 4 3 2 1 2;
              4 5 4 3 2 1 2 3;
              5 4 3 2 1 2 3 4;
              4 3 2 1 2 3 4 5;
              3 2 1 2 3 4 5 4;
              2 1 2 3 4 5 4 3;
              1 2 3 4 5 4 3 2;
              2 3 4 5 4 3 2 1]; % difficulty steps
Difficulty_idx = [1 2 3 4 5 6 7 8];

oo_idx(:,:,1) = [3 7;
                 3 7;
                 3 7;
                 3 7;
                 3 7;
                 2 6;
                 3 0;
                 3 7];
      
oo_idx(:,:,2) = [3 7;
                 3 7;
                 3 7;
                 3 7;
                 3 7;
                 2 6;
                 0 7;
                 3 7];
      
n_Tar = 5; % Number of targets to respond to in each 14 second window

% Timings
step_duration = 10.9375; % difficulty step duration
stim_dur = 0.35; % Symbol display time in seconds
max_round_duration = step_duration*8; % total round duration in seconds
tar_response_time = 1; % maximum time allowed to respond to target

step_timing = [0 step_duration step_duration*2 step_duration*3 step_duration*4 step_duration*5 step_duration*6 step_duration*7 step_duration*8];
% optout question window
oo_win = [step_timing(1) step_timing(2); % min and max time in seconds for each window
          step_timing(2) step_timing(3);
          step_timing(3) step_timing(4);
          step_timing(4) step_timing(5);
          step_timing(5) step_timing(6);
          step_timing(6) step_timing(7);
          step_timing(7) step_timing(8);
          step_timing(8) step_timing(9)];
oo_win(:,1) = ceil(oo_win(:,1)); % no less than
oo_win(:,2) = floor(oo_win(:,2)); % no more than

oo_response_time = 2 + stim_dur; % time allowed for optout decision

% Symbol Streams
ns_Std = 6; % Number of non-target streams
ns_Tar = 2; % Number of target streams
ns_Swi = 1; % Number of switch response streams

% Symbols
symbols = [60 60 60 60 60 60 60 'a':'z' 'A':'Z']; % 60s at beginning necessary for string generation
st_colour = [0 0 0]; % RGB text colour values [0 0 0] = black

font_size = 18;
inst_font_size = 30;
inst_line_spacing = 2;

% offer text
TaskOffer.eng.first = 'You will be made the first offer in 3 seconds.';
TaskOffer.eng.count = 'Offer Number: ';
TaskOffer.eng.rwd = 'You will receive: ';
TaskOffer.eng.cst = 'Effort level: ';
TaskOffer.eng.inst = 'Press "Y" to accept, or "N" to decline. Remember, if you decline, you will still receive X but will have to wait X.';
TaskOffer.eng.ready = 'This round will begin in 3 seconds. Remember to maintain your gaze at the point indicated by the eye!';
TaskOffer.eng.wait = 'You have received X. You will be made the next offer in: ';
TaskOffer.eng.optout = 'Press the Enter key at any point to choose to optout.';
TaskMain.eng.optout = 'Optout? Press "Enter"!';
TaskResults.eng.fail{1} = 'You missed too many targets! The next offer will be made in:';
TaskResults.eng.fail{2} = 'You made too many wrong responses! The next offer will be made in:';
TaskResults.eng.optout = 'You chose to optout and have received X. You will be made the next offer in:';
TaskResults.eng.success = 'Round complete. Please wait 3 seconds for the next offer';
TaskResults.eng.finish = 'You have completed all the offers. Thank you for your participation.';

% offer text en francais
TaskOffer.first = 'Nous allons vous proposer la première offre dans 3 secondes.';
TaskOffer.count = 'Offre Numero:';
TaskOffer.rwd = 'Bonus: ';
TaskOffer.cst = 'Niveau d''effort: ';
TaskOffer.inst = 'Appuyez sur "o" pour accepter, ou "n" pour refuser. Rappelez-vous que, si vous refusez l''offre, vous recevrez 0,5 euros et vous devrez attendre le temps qu''il vous aurait fallu pour compléter l''exercice.';
TaskOffer.ready = 'Ce exercice commencera dans 3 secondes. Rappelez-vous de maintenir votre regard au centre de l''écran!';
TaskOffer.wait = 'Vous n''avez reçu que 0,5 euros. Nous allons vous proposer la prochaine offre dans: ';
TaskOffer.optout = 'Appuyez sur la touche "Entrée" à tout moment pour abandonner.';
TaskMain.optout = 'Abandonner? Appuyez sur "Enter"!';
TaskResults.fail{1} = 'Vous avez manqué trop de cibles! Nous allons vous proposer la prochaine offre dans: ';
TaskResults.fail{2} = 'Vous avez mal repondu trop de fois! Nous allons vous proposer la prochaine offre dans: ';
TaskResults.optout = 'Vous avez choisi d''abandonner. Vous n''avez reçu que 0,5 euros.';
TaskResults.success = 'Exercice completé. Nous allons vous proposer la prochaine offre dans 5 secondes.';
TaskResults.finish = 'Vous avez completé toutes les offres. Merci pour votre participation.';

save('realRSVPparams');
%% Training Phase
clearvars;

% misc
visual_angle = 2.5; % Target stream offset in visual angle 
screen_distance = 80; % distance of participant to screen in cm (will default to 80 if left blank)
n_offers = 3*2*8; % number of seperate offers to be made (conditions*number of repetitions)
eye = 0; % if 1, show eye symbol during instructions
training = 1; % 0 if no training

training_effort = [1 2 1 2];
n_train_phase = length(training_effort);
train_Difficulty = [3 4 5 4 3 2 1 2;
                    3 4 5 4 3 2 1 2;
                    3 2 1 2 3 4 5 4;
                    3 2 1 2 3 4 5 4]; % difficulty steps
n_Tar = 5; % Number of targets to respond to in each 14 second window

% Timings
step_duration = 10.9375; % Trial duration
stim_dur = 0.35; % Symbol display time in seconds
tar_response_time = 1; % maximum time allowed to respond to target

% Symbol Streams
ns_Std = 6; % Number of non-target streams
ns_Tar = 2; % Number of target streams
ns_Swi = 1; % Number of switch response streams

% Symbols
symbols = [60 60 60 60 60 60 60 'a':'z' 'A':'Z']; % 60s at beginning necessary for string generation
st_colour = [0 0 0]; % RGB text colour values [0 0 0] = black

font_size = 18;
inst_font_size = 30;
inst_line_spacing = 2;

% instruction text
TaskInst.eng.arrows = 'Use the arrow keys to navigate left and right through the instructions.';
TaskInst.eng.inst1 = 'During this experiment, you will be offered the choice of engaging in a single round of an Attention Task. Each offer will involve a different combination of effort and reward. Both the effort and reward can be either high or low.';
TaskInst.eng.inst2 = 'You can choose to either accept (by pressing ‘y'') or decline (by pressing ‘n'') the presented offer. If you decline, you will receive X€ and be required to wait the same amount of time as it would take to complete the task if you choose to engage.';
TaskInst.eng.inst3 = 'You will only be made 24 separate offers so make sure you consider each one fully before making a decision. There is no right or wrong answer, so answer according to what you prefer at that time.';
TaskInst.eng.inst4 = 'If you choose to engage, you will have to complete one round of the Attention Task. During this task, you will be presented with several streams of changing letters and numbers. It is important that maintain your gaze at the point indicated by the eye symbol in the picture above. Note that this symbol will not appear during actual rounds.';
TaskInst.eng.inst5 = 'During the task, you should respond by pressing the space bar when you see the target number 7 in the current target stream. These are the streams located directly adjacent to the central stream, as indicated above. You need to respond within 1 second.';
TaskInst.eng.inst6 = 'The target number will only appear in one or the other stream at any one time! Before each round that you choose to engage in, an arrow will appear to indicate which stream the targets will first appear in.';
TaskInst.eng.inst7 = 'During each round, you should also pay attention to the central stream (in addition to one of the two target streams) as the “<” or “>” symbol will appear here to indicate that you should swap your attention from one target stream to the other. The direction of the arrow indicates to which side you should swap your attention. You do not need to respond by pressing the space bar when this happens – simply switch your attention to the other side.';
TaskInst.eng.inst8 = 'At any point during a trial, you can choose to opt out by simply pressing the [...] key. Doing so will end the current trial but you will still receive X€. You will then be required to wait the remaining amount of time that was left in the trial before a new engagement offer is given.';
TaskInst.eng.inst9 = 'At the end of a round, you will be informed if you were successful in achieving the reward. There is a performance minimum in terms of the number of targets you need to respond to in order to receive the reward.';
TaskInst.eng.inst10 = 'Before the main task, you will perform a brief training session. This will involve completing four rounds of the Attention Task, two at each level of effort. You will not be able to opt out during these rounds, unlike during the main task. At the end of each training round, you will be informed of your performance.';
TaskInst.eng.inst11 = 'Are you ready to start the first training session? If so please the spacebar.';

TaskTrain.eng.cst = 'Effort level: ';
TaskTrain.eng.lvl{1} = 'Low';
TaskTrain.eng.lvl{2} = 'High';
TaskTrain.eng.ready = 'This round will begin in 3 seconds. Remember to maintain your gaze at the point indicated by the eye!';
TaskTrain.eng.fail{1} = 'You missed too many targets! The next offer will be made in:';
TaskTrain.eng.fail{2} = 'You had too many wrong responses! The next offer will be made in:';
TaskTrain.eng.results{1} = 'Training round finished.';
TaskTrain.eng.results{2} = 'Correct responses:';
TaskTrain.eng.results{3} = 'False alarms:';
TaskTrain.eng.finish = 'You have completed the training phase! Press the spacebar when you are ready to proceed to the main experiment.';

% instructions en francais
TaskInst.arrows = 'Utilisez les touches fléchées gauche et droite pour parcourir les instructions';
TaskInst.inst1 = 'Nous allons vous proposer d''effectuer une suite d''exercices nécessitant votre concentration. Certains de ces exercices seront faciles, d''autres seront difficiles. Chaque exercice est associé à un bonus financier. Ce bonus pourra etre faible (0.1 euros), moyen (1 euros) ou haut (2 euros). À la fin de l''expérience, un quart des exercices sera choisi pour déterminer votre récompense réelle.';
TaskInst.inst2 = 'Avant chaque exercice, nous vous indiquerons sa difficulté et le bonus associé. Vous devrez soit accepter (en appuyant sur "o") ou refuser ("n") d''effectuer l''exercice. Si vous refusez, vous ne recevrez pas le bonus, et vous devrez attendre le temps qu''il vous aurait fallu pour compléter l''exercice (environs une minute et demie).';
TaskInst.inst3 = 'Nous ne vous proposerons que 48 exercices, donc soyez sûr(e) de considérer pleinement chaque décision avant de prendre une décision. Il n''y a pas de bonne ou de mauvaise réponse, donc répondez seulement selon ce que vous préférez à ce moment.';
TaskInst.inst4 = 'Durant un exercice, vous devrez observer plusieurs séquences de lettres et chiffres qui changeront. Nous vous conseillons de fixer votre regard à l''endroit indiqué par le symbole ''oeil'' dans l''image ci-dessus. Notez que ce symbole n''apparaîtra pas durant les exercices réels.';
TaskInst.inst5 = 'L''exercice consiste à appuyer sur la barre d''espace lorsque vous voyez le chiffre « cible » 7 apparaître dans l''une des deux positions adjacentes à la position centrale (voir ci-dessous). Vous n''avez qu''une seconde pour réagir.';
TaskInst.inst6 = 'Il ne peut y avoir qu’un seul chiffre cible à l’écran! Avant chaque exercice, une flèche apparaîtra pour indiquer où vous devriez d’abord fixer votre regard.';
TaskInst.inst7 = 'Attention, la position (gauche ou droite) du chiffre cible changera au cours de l''exercice. Ce changement sera indiqué par l''apparition du symbole "<" ou ">" au centre de l''écran. La direction de la flèche vous indique de quel côté vous devez porter votre attention. Vous n''avez pas à répondre lorsque cela arrive, mais vous devez alors porter rapidement votre attention sur l''autre position de l''écran.';
TaskInst.inst8 = 'Vous pouvez abandonner l''exercice en cours à tout moment, en appuyant sur la touche "Entrée". Si vous décidez d''abandonner, vous ne recevrez pas le bonus et vous devrez attendre le temps qu''il vous aurait fallu pour compléter l''exercice avant qu''une nouvelle proposition d''exercice vous soit faite.';
TaskInst.inst9 = 'A certains moments de l''exercice, nous vous demanderons directement si vous souhaitez abandonner. Lorsque cela se produit, appuyez sur la touche Entrée pour abandonner. Si vous ne répondez pas dans les 2 secondes, l''exercice reprendra immédiatement, alors soyez prêt!';
TaskInst.inst10 = 'Il y a un minimum de performance requis en termes de nombres de cibles atteintes pour recevoir le bonus. Il y a également un nombre maximum de fois où vous pouvez répondre quand il n''y a pas de cible visible à l''écran. Nous vous informerons à la fin de la suite d''exercices combien de bonus vous avez gagné.';
TaskInst.inst11 = 'Avant la suite d''exercice principale, vous participerez à une brève session d''entraînement. Cela implique la complétion de quatre exercices, deux à chaque niveau d''effort. Contrairement à la suite principale vous ne pourrez pas vous désengager durant ces exercices d''entraînements. Nous vous informerons de votre performance à la fin de chaque exercice d''entraînement.';
TaskInst.inst12 = 'Etes-vous prêt à démarrer la première session d''entraînement ? Si oui, appuyez sur la barre d''espace.';

TaskTrain.cst = 'Niveau d''effort: ';
TaskTrain.lvl{1} = 'Bas';
TaskTrain.lvl{2} = 'Haut';
TaskTrain.ready = 'Ce exercice commencera dans 3 secondes. Rappelez-vous de maintenir votre regard au centre de l''écran!';
TaskTrain.fail{1} = 'Vous avez manqué trop de cibles! Nous allons vous proposer la prochaine offre dans: ';
TaskTrain.fail{2} = 'Vous avez mal repondu trop de fois! Nous allons vous proposer la prochaine offre dans: ';
TaskTrain.results{1} = 'Phase d''entraînement terminé.';
TaskTrain.results{2} = 'Réponse correct:';
TaskTrain.results{3} = 'Réponse incorrect:';
TaskTrain.results{4} = 'Veuillez attendre 20 secondes.';
TaskTrain.finish = 'Vous avez completé la phase d''entraînement. La suite principale va désormais commencer. Êtes-vous prêt(e) ? Si oui, appuyez sur la barre d''espace pour voir votre première proposition d''engagement.';

save('testRSVPparams');