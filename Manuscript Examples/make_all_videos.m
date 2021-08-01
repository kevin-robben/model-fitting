cd([pwd,'\Sim MeSCN H2O'])
makeVideos
cd('..\')

cd([pwd,'\Sim Over param'])
makeVideos
cd('..\')

cd([pwd,'\Sim Under param'])
makeVideos
cd('..\')

cd([pwd,'\Sim CNC in Calmodulin - Low SNR'])
makeVideos
cd('..\')

cd([pwd,'\Sim Phasing Error with Variable phi'])
makeVideos
cd('..\')

cd([pwd,'\Sim Phasing Error without Variable phi'])
makeVideos
cd('..\')

cd([pwd,'\Exp MeSCN DMSO - 2020 Data'])
make2020TwSeriesComparisonVideo
cd('..\')

cd([pwd,'\Exp MeSCN DMSO - 2021 Data'])
make2021TwSeriesComparisonVideo
cd('..\')
