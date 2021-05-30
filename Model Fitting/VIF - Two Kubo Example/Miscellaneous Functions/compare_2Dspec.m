function compare_2Dspec(fig,x,w1_plot_lim,w3_plot_lim,T,Data_spec,Model_spec)
	n_Tw = nearest_index(x.Tw,T);
	layout = tiledlayout(fig,1,3,'TileSpacing','compact');set(gcf,'Position',[20 200 1500 500]);
	data_ax = nexttile(layout,1);
		plot_2Dspec(data_ax,x,w1_plot_lim,w3_plot_lim,Data_spec(:,:,n_Tw),sprintf('Experimental Data at T_w = %.3gps',x.Tw(n_Tw)))
		data_clim = caxis(data_ax);
	model_ax = nexttile(layout,2);
		plot_2Dspec(model_ax,x,w1_plot_lim,w3_plot_lim,Model_spec(:,:,n_Tw),sprintf('Model Fit at T_w = %.3gps',x.Tw(n_Tw)))
		model_clim = caxis(model_ax);
	res_ax = nexttile(layout,3);
		Diff = Data_spec-Model_spec;
		plot_2Dspec(res_ax,x,w1_plot_lim,w3_plot_lim,Diff(:,:,n_Tw),sprintf('Residual (Data - Model) at T_w = %.3gps',x.Tw(n_Tw)))
	%% make color axis the same between data and model
		if data_clim(1) < model_clim(1)
			min_clim = data_clim(1);
		else
			min_clim = model_clim(1);
		end
		if data_clim(2) > model_clim(2)
			max_clim = data_clim(2);
		else
			max_clim = model_clim(2);
		end
		caxis(model_ax,[min_clim,max_clim]);
		caxis(data_ax,[min_clim,max_clim]);
end