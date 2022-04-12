# model-fitting
The Model Fitting App is currently available for Windows and Mac users.
Instructions:
Click the green "Code" button and "Download Zip". Unzip the file and run the installer. Please see the Youtube tutorials below for help. If you still have questions, feel free to reach out to me by email (kevin-robben@uiowa.edu) or through the "Discussions" Github page.

Note that installing the Model Fitting GUI App does not require MATLAB. Instead, the installer will download MATLAB Runtime which is free of charge.
On the other hand, running or editing the actual source code will require MATLAB R2020a, or newer, which does require a license.

I strongly recommend the following youtube tutorials for using the model fitting GUI. There are a couple of features and idiosyncrasies that are worth knowing.

Tutorial 1: Download and Installation https://youtu.be/v4-AfWF6CbQ

Tutorial 2: Loading Data, Mask, and Inverse Variance https://youtu.be/B4IyZB8IKS8

Tutorial 3: Loading Parameters, Model Fitting https://youtu.be/N0iaWPMacpY

Tutorial 4: Simulating Data, Examples of Stalling, Multicollinearity https://youtu.be/94Bo3aiUdPc

Please note two typos that appear in Eq. S8 in the supporting information of the manuscript (https://doi.org/10.1021/acs.jpcb.1c08764): (1) Minus signs are missing in the arguments of the expm1() terms as well as the exp(Tw/tau) term, and (2) the third line of Eq. S8 is missing a factor of (2*π*c)^2. The original source code does *not* include these typos. Special thanks to Anneka Jean Miller and Evan Schroeder for recognizing these!
