
WORKFLOW = 

particleDetect.m # updated pegs for the lighting set up
    input: images folder
    output: output folder
canny.m #load in all the images from top left to bottom right 
    input: piece_%_%_centers.txt in output folder
    output: particle_tracking_results.mat and particle_tracking_summary.csv
preserveparticleID.m
    input: particle_tracking_results.mat
    output: particle_positions.txt
runCD2.m #version of contact detect (need contactDetect from og pegs)
    input: particle_positions.txt
    output: png files that need to be mat files
master.m

