data is a structure containing data from RSVP task 18/05/19

Training:
training.effort = effort condition (low or high)

training.tar = 4 matrices (one for each training phase) of target successfully hit (0 or 1), onset of target (secs), participant response time (secs), reaction time (secs)

data.training.FA = timings (secs) of 'false alarms' (spacebar pressed when no target on screen)

main.condition = matrix of condition for each offer 
- (:,1) = reward (1, 2, 3 - low/medium/high)
- (:,2) = effort (1, 2 - low/high)
- (:,3) = sinusoid pattern of effort change offset (1 = 3 4 5 4 3 2 1 2)

main.engage = matrix of offer engagement
- (:,1) = engage (1) or not (0)
- (:,2) = result: 1 = fail; 2 = optout; 3 = success; 4 = not engage

main.optout
- (:,1) = optout time (or point of failure)
- (:,2) = difficulty step (1 - 10) at optout time

main.optout_win
- (:,1) = second optout window onset (secs)
- (:,2) = all zeros due to code bug

main.tar = 48 matrices (one for each offer)
- (:,1) = target successfully hit (0 or 1)
- (:,2) = onset of target (secs)
- (:,3) = participant response time (secs)
- (:,4) = reaction time (secs)

main.FA = timings (secs) of 'false alarms' (spacebar pressed when no target on screen)

main.bonus = bonus participant achieved

NASA - scores on each of 6 subscales of NASA Task Load Idx for participant

GRIT - scores on each of 8 subscales of Grit-S scale
- (9,:) = Grit overall score
- (10,:) = PoE subscore
- (11,:) = CoI subscore

Gender - subject gender

Age - Year of birth

Education - Level of eduction
- 1 = Brevet des collèges
- 2 = Baccalauréat
- 3 = Licence (Bac + 3)
- 4 = Master (Bac + 5)
- 5 = Doctorat (Bac + 8)

tar_hit = number of targets hit on each offer

param_est - parameter estimates for various fits:
.EC = initial engagement completion model 
- 1 = sensitivity of engagement w.r.t. reward
- 2 = sensitivity of engagement w.r.t. effort
- 3 = constant
- 4 = sensitivity of completion w.r.t. reward
- 5 = sensitivity of completion w.r.t. effort
- 6 = constant

.EC_I = engagement completion model with interaction term
- 1 = sensitivity of engagement w.r.t. reward
- 2 = sensitivity of engagement w.r.t. effort
- 3 = constant
- 4 = interaction term
- 5 = sensitivity of completion w.r.t. reward
- 6 = sensitivity of completion w.r.t. effort
- 7 = constant
- 8 = interaction term

.reassess = reassessment model
- 1 = gamma = sensitivity of reassess w.r.t. history of effort
- 2 = lambda 1 = sensitivity of reassess w.r.t. effort magnitude
- 3 = lambda 2 = sensitivity of reassess w.r.t. effort rate of change
- 4 = as = sensitivity of sustaining w.r.t. reward
- 5 = bs = sensitivity of sustaining w.r.t. effort left
- 6 = cs = constant
- 7 = omega 0 = reassessment base rate