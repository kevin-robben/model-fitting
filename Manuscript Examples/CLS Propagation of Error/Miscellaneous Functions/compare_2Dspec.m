function fig = compare_2Dspec(x,w1_plot_lim,w3_plot_lim,T,Data_spec,Model_spec,fig_title)
	n_Tw = nearest_index(x.Tw,T);
	[n1_min,n1_max] = nearest_index(x.w3,w1_plot_lim);
	[n3_min,n3_max] = nearest_index(x.w3,w3_plot_lim);
	fig = openfig('comparison template.fig');
	data_ax = fig.Children(2); data_pos = [data_ax.Position;data_ax.InnerPosition;data_ax.OuterPosition];
	model_ax = fig.Children(4); model_pos =[model_ax.Position;model_ax.InnerPosition;model_ax.OuterPosition];
	res_ax = fig.Children(6); res_pos = [res_ax.Position;res_ax.InnerPosition;res_ax.OuterPosition];
		contourf(data_ax, x.w1, x.w3, real(Data_spec(:,:,n_Tw))', 20);
		hold(data_ax,'on');
		line(data_ax,[0,1e4],[0,1e4],'Color','k')
		title(data_ax,'Experimental Data');
		xlim(data_ax,w1_plot_lim);ylim(data_ax,w3_plot_lim);ylabel(data_ax,'Probe (cm^{-1})');xlabel(data_ax,'Pump (cm^{-1})')
		data_ax.Position = data_pos(1,:);data_ax.InnerPosition = data_pos(2,:);data_ax.OuterPosition = data_pos(3,:);
		temp = colorbar(data_ax,'location','northoutside');temp.Position = [0.08,0.78,0.252,0.034];
		data_ax.TickLength = [0.03,0];
		data_clim = caxis(data_ax);
		
		
		contourf(model_ax, x.w1, x.w3, real(Model_spec(:,:,n_Tw))', 20);
		hold(model_ax,'on');
		line(model_ax,[0,1e4],[0,1e4],'Color','k')
		title(model_ax,'Model Fit');
		xlim(model_ax,w1_plot_lim);ylim(model_ax,w3_plot_lim);xlabel(model_ax,'Pump (cm^{-1})')
		model_ax.Position = model_pos(1,:);model_ax.InnerPosition = model_pos(2,:);model_ax.OuterPosition = model_pos(3,:);
		temp = colorbar(model_ax,'location','northoutside');temp.Position = [0.393,0.78,0.252,0.034];
		model_ax.TickLength = [0.03,0];
		model_clim = caxis(model_ax);
		
		Diff = Data_spec-Model_spec;
		contourf(res_ax,x.w1,x.w3,real(Diff(:,:,n_Tw))',20);
		hold(res_ax,'on');
		line(res_ax,[0,1e4],[0,1e4],'Color','k')
		title(res_ax,'Residual (D - M)');
		xlim(res_ax,w1_plot_lim);ylim(res_ax,w3_plot_lim);xlabel(res_ax,'Pump (cm^{-1})')
		res_ax.Position = res_pos(1,:);res_ax.InnerPosition = res_pos(2,:);res_ax.OuterPosition = res_pos(3,:);
		temp = colorbar(res_ax,'location','northoutside');temp.Position = [0.71,0.78,0.252,0.034];
		res_ax.TickLength = [0.03,0];
		
		
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
    %% add title
        annotation(fig,'textbox',[0.32 0.9 0.4 0.08],'String',sprintf('%s at %.4g ps',fig_title,T),'HorizontalAlignment','center','FitBoxToText','off','EdgeColor','none');
end