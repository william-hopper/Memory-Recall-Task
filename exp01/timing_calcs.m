trialnum = 1.5;
conf = 5;
effort = 0.75;
rewatchnum = 8:20;
w_rw = 3;
test = 3;
feedback = effort*8 + 3;
numoftrial = 24;

total = (numoftrial*(trialnum + conf*2 + rewatchnum*(effort*8)...
    + w_rw + test*8 + feedback))/60