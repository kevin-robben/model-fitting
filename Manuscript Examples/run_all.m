cd 'Sim MeSCN H2O'
fit_100_trials
cd '..'

cd 'CLS Propagation of Error'
VIF_comparison
cd '..'

cd 'Sim Under param'
fit_under_param
cd '..'

cd 'Sim Over param'
fit_over_param
cd '..'

cd 'Sim CNC in Calmodulin - Low SNR'
fit_100_trials_low_SNR
cd '..'

cd 'Exp MeSCN DMSO - 2020 Data'
fit_1kubo_MeSCN_DMSO_2020
CLS_analysis_2020
make2020TwSeriesComparisonVideo
fit_2kubo_MeSCN_DMSO_2020
cd '..'

cd 'Exp MeSCN DMSO - 2021 Data'
fit_MeSCN_DMSO_2021
fitting_analysis_2021
make2021TwSeriesComparisonVideo
cd '..'

cd 'Sim Phasing Error without Variable phi'
fit_phase_error
cd '..'

cd 'Sim Phasing Error with Variable phi'
fit_phase_error
cd '..'
