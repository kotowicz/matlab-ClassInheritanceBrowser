% Example for Class Inheritance Browser

% Copyright Clayton Ernst, Andrew Hagen, Eric Lee and Andreas Kotowicz, 2010
% UC Berkeley E177 Final Project, Spring 2010

% This example will open the class inheritance browser using the included
% directory '+inex' (inheritance example package). We assume that both 
% '+classInheritance' and '+inex' are in the current directory containing 
% this m-file.

% For further instructions on how to use the class inheritance browser, see
% the included documentation.

%clear classes;
% add current directory to path.
addpath(pwd);
h = classInheritance.browse('+inex');
