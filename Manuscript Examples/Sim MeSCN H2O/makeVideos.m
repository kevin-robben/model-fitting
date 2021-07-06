clear all
close all
%% make fitting update video
	%% load figures and convert to frames
		d = dir('Output Data\Fitting Update Figures\*.fig');
		for i=1:length(d)
			trial_iter = regexp(d(i).name,'\d*','match');
			trial(i) = str2num(string(trial_iter(1)));
			iter(i) = str2num(string(trial_iter(2)));
		end
		[B,I] = sort(iter);
		d = d(I);
		trial = trial(I);
		[B,I] = sort(trial);
        d = d(I);
        clear trial iter;
	%% write frames to video
		writerObj = VideoWriter(sprintf('Output Data\\Fitting Video.mp4'),'MPEG-4');
		writerObj.FrameRate = 2;
		writerObj.Quality = 100;
		open(writerObj);
		for i=1:length(d)
            fig = openfig([d(i).folder,'\',d(i).name]);
			frame = getframe(fig);
            if i == 1
                default_size = size(frame.cdata);
            elseif ~all(size(frame.cdata) == default_size)
                frame.cdata = imresize(frame.cdata,default_size(1:2));
            end
			writeVideo(writerObj,frame);
            close(fig);
		end
		close(writerObj);
%% make C and SIGN video
	%% load figures and convert to frames
        d = dir('Output Data\C and SIGN Figures\*.fig');
		for i=1:length(d)
			trial_iter = regexp(d(i).name,'\d*','match');
			trial(i) = str2num(string(trial_iter(1)));
		end
		[B,I] = sort(trial);
        d = d(I);
        clear trial;
	%% write frames to video
		writerObj = VideoWriter(sprintf('Output Data\\C and SIGN Video.mp4'),'MPEG-4');
		writerObj.FrameRate = 2;
		writerObj.Quality = 50;
		open(writerObj);
		for i=1:length(d)
            fig = openfig([d(i).folder,'\',d(i).name]);
			frame = getframe(fig);
            if i == 1
                default_size = size(frame.cdata);
            elseif ~all(size(frame.cdata) == default_size)
                frame.cdata = imresize(frame.cdata,default_size(1:2));
            end
			writeVideo(writerObj,frame);
            close(fig);
		end
		close(writerObj);
%% make CLS video
	%% load figures and convert to frames
        d = dir('Output Data\CLS Figures\*.fig');
		for i=1:length(d)
			trial_iter = regexp(d(i).name,'\d*','match');
			trial(i) = str2num(string(trial_iter(1)));
		end
		[B,I] = sort(trial);
        d = d(I);
        clear trial;
	%% write frames to video
		writerObj = VideoWriter(sprintf('Output Data\\CLS Video.mp4'),'MPEG-4');
		writerObj.FrameRate = 2;
		writerObj.Quality = 50;
		open(writerObj);
		for i=1:length(d)
            fig = openfig([d(i).folder,'\',d(i).name]);
			frame = getframe(fig);
            if i == 1
                default_size = size(frame.cdata);
            elseif ~all(size(frame.cdata) == default_size)
                frame.cdata = imresize(frame.cdata,default_size(1:2));
            end
			writeVideo(writerObj,frame);
            close(fig);
		end
		close(writerObj);
%% make params video
	%% load figures and convert to frames
        d = dir('Output Data\Params Figures\*.fig');
		for i=1:length(d)
			trial_iter = regexp(d(i).name,'\d*','match');
			trial(i) = str2num(string(trial_iter(1)));
		end
		[B,I] = sort(trial);
        d = d(I);
        clear trial;
	%% write frames to video
		writerObj = VideoWriter(sprintf('Output Data\\Params Video.mp4'),'MPEG-4');
		writerObj.FrameRate = 2;
		writerObj.Quality = 100;
		open(writerObj);
		check = zeros(1,5);
		for i=1:length(d)
            fig = openfig([d(i).folder,'\',d(i).name]);
			ax = findobj(fig,'Tag','B'); 
			check = check + (ax.Children(1).YData-ax.Children(1).YNegativeDelta > 1) + (ax.Children(1).YData+ax.Children(1).YPositiveDelta < 1)
			frame = getframe(fig);
            if i == 1
                default_size = size(frame.cdata);
            elseif ~all(size(frame.cdata) == default_size)
                frame.cdata = imresize(frame.cdata,default_size(1:2));
            end
			writeVideo(writerObj,frame);
            close(fig);
		end
		close(writerObj);