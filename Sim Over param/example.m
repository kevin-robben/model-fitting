clear all
close all

fig = figure;
set(fig,'Position',[100 100 600 400]);

fitting_fig = openfig('Output Data\trial1 iter16.fig');
kubo_ax1 = fitting_fig.Children(1).Children(5);
N_iter = 16;
N_stalls = ((length(kubo_ax1.Children)-4)-2*N_iter)/2;
N_reticles = 2;
indx_circ_comp1 = N_reticles+1;
indx_stalls_comp1 = (N_reticles+2):1:(N_reticles+N_stalls+1);
indx_traj_comp1 = (N_reticles+N_stalls+2):1:(N_reticles+N_stalls+N_iter+1);
indx_circ_comp2 = (N_reticles+N_stalls+N_iter+2);
indx_stalls_comp2 = (N_reticles+N_stalls+N_iter+3):1:(N_reticles+2*N_stalls+N_iter+2);
indx_traj_comp2 = (N_reticles+2*N_stalls+N_iter+3):1:(N_reticles+2*N_stalls+2*N_iter+2);

set(kubo_ax1.Children(indx_traj_comp1),'Color','#D95319')
set(kubo_ax1.Children(indx_traj_comp2),'Color','#7E2F8E')



fitting_fig = openfig('Output Data\trial1 iter41.fig');
kubo_ax2 = fitting_fig.Children.Children(5);
N_iter = 41;
N_stalls = ((length(kubo_ax2.Children)-4)-2*N_iter)/2;
N_reticles = 2;
indx_circ_comp1 = N_reticles+1;
indx_stalls_comp1 = (N_reticles+2):1:(N_reticles+N_stalls+1);
indx_traj_comp1 = (N_reticles+N_stalls+2):1:(N_reticles+N_stalls+N_iter+1);
indx_circ_comp2 = (N_reticles+N_stalls+N_iter+2);
indx_stalls_comp2 = (N_reticles+N_stalls+N_iter+3):1:(N_reticles+2*N_stalls+N_iter+2);
indx_traj_comp2 = (N_reticles+2*N_stalls+N_iter+3):1:(N_reticles+2*N_stalls+2*N_iter+2);

set(kubo_ax2.Children(indx_traj_comp1),'Color','#D95319')
set(kubo_ax2.Children(indx_traj_comp2),'Color','#7E2F8E')

delete(kubo_ax2.Children(indx_traj_comp2(10:41)))
delete(kubo_ax2.Children(indx_stalls_comp2(1:2)))
delete(kubo_ax2.Children(indx_traj_comp1(10:41)))
delete(kubo_ax2.Children(indx_stalls_comp1(1:2)))




fitting_fig = openfig('Output Data\trial1 iter120.fig');
kubo_ax2 = fitting_fig.Children.Children(5);
N_iter = 120;
N_stalls = ((length(kubo_ax2.Children)-4)-2*N_iter)/2;
N_reticles = 2;
indx_circ_comp1 = N_reticles+1;
indx_stalls_comp1 = (N_reticles+2):1:(N_reticles+N_stalls+1);
indx_traj_comp1 = (N_reticles+N_stalls+2):1:(N_reticles+N_stalls+N_iter+1);
indx_circ_comp2 = (N_reticles+N_stalls+N_iter+2);
indx_stalls_comp2 = (N_reticles+N_stalls+N_iter+3):1:(N_reticles+2*N_stalls+N_iter+2);
indx_traj_comp2 = (N_reticles+2*N_stalls+N_iter+3):1:(N_reticles+2*N_stalls+2*N_iter+2);

set(kubo_ax2.Children(indx_traj_comp1),'Color','#D95319')
set(kubo_ax2.Children(indx_traj_comp2),'Color','#7E2F8E')

delete(kubo_ax2.Children(indx_traj_comp2(20:120)))
delete(kubo_ax2.Children(indx_stalls_comp2))
delete(kubo_ax2.Children(indx_traj_comp1(20:120)))
delete(kubo_ax2.Children(indx_stalls_comp1))
