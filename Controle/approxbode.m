function [] = approxbode(lti)

%   Funcao que plota o diagrama de bode com assintotas
%
%		This function plots an approximate or asymptotic Bode plot over the
%			output from MATLAB's bode command.  
%       An explanation of the Bode plot is provided at
%			http://wikis.controltheorypro.com/index.php?title=Bode_Plot
%
%
%	---	Arguments
%	Inputs
%		lti:	SISO LTI object (not an FRD) to be plotted.


% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Copyright, Gabe Spradlin, 2008 --- http://wikis.ControlTheoryPro.com
%		All rights reserved
%		You may use this function freely for any use except redistribution.
%			In other words this function is open to everyone for personal,
%			educational, and commercial uses.  However, if you wish to provide
%			end users with this function please do so by providing the following
%			link to it:
%
%			http://wikis.controltheorypro.com/index.php?title=Image:approxBode.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Revision History:
%
% Original
% 07/08/08
% G Spradlin
%
% Modificado    09/2014 - LGJ
%               03/2016 - LGJ
%               10/2017 - LGJ
%               09/2019 - LGJ
%               09/2022 - LGJ
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%	Use the MATLAB bode command to get the necessary data for plotting
%		the MATLAB bode command output.  The wBode (frequency in rad/sec)
%		is also used to bound the approximation.
[magBode, phsBode, wBode] = bode(lti);

%	Use zpkdata and tfdata to get details necessary for generating the
%		Bode plotting data.
%
%		zpkdata returns the zeros, poles, and system gain.  The zeros and
%			poles are required for approzimate Bode plotting.
[z, p, k] = zpkdata(lti, 'v');
%		tddata returns the numerator and denominator of the system
%			transfer function.
[num, den] = tfdata(lti, 'v');

%	Create a list of unique zeros and poles
uniqZ = -1*unique(abs(z));
uniqP = -1*unique(abs(p));

%	Sort that list of poles and zeros so that 0 is the first and inf is
%		the last.
[junk, sortInd] = sort(abs([uniqZ ; uniqP]), 'ascend');
allRoots = [uniqZ ; uniqP];
allRoots = allRoots(sortInd);

%	The last entry of the numerator and denominator is the DC system gain.
%		In other words, the system transfer function when s = 0.
magDC = num(end) / den(end);

%	---	Note that the magDC variable is dependent on the final value in the numerator
%				denominator.  If the last value of either is 0 then the function will not 
%				work properly.	---	%

%	Determine the phase at DC based on the value of magDC
if magDC > 0
	phsDC = 0;
else
	phsDC = -180;
end

%	--- Note that the above code always produced a DC phase equivalent to MATLAB's bode
%				command but sometimes it would produce a phase of 0 while the bode command
%				produced -360 degrees.  While these are equal this made comparisons difficult.
%				As a result I fixed the DC phase to be equal to DC phase provided by the
%				bode command.

% Encontrar a fase inicial
[~, phsDC] = bode(lti,wBode(1)/1e4);
phsDC = round(phsDC);
% phsDC = phsBode(1); % Antigo

%	Spin through each unique root (pole or zero) and determine the
%		resulting magnitude and phase change for each root.
for i = 1:length(allRoots)

	%	Get the current root
	currRoot = allRoots(i);

	%	If this is the first root then initialize the various
	%		plotting vectors.
	if i == 1
		magFreq = 0;
		phsFreq = 0;
		mag = 20*log10(magDC);
		phs = phsDC;
		currMagSlope = 0;
		currPhaseChange = 0;
	end
	
	%	The real part of the root is the frequency (rad/sec).
	currFreq = abs((currRoot));

	%	Update the magnitude and phase vectors.
	magFreq = [magFreq, currFreq];
	phsFreq = [phsFreq, currFreq*0.1, 10*currFreq];
	
	%	Determine the #s of poles and zeros at this frequency.
	indZ = find(abs(z) == abs(currRoot));
	indP = find(abs(p) == abs(currRoot));
	
	numZ = length(indZ);
	numP = length(indP);
	
	%	The phase changed is dependent on the #s of poles and zeros.
	currPhaseChange = (+90 * numZ) + (-90 * numP);
	
	%	If the current frequency does not equal 0, then update the magnitude
	%		and phase based on the correct changes at these frequencies.
	if currFreq ~= 0
		%	The magnitude is calculated based on the present slope and magnitude.
		%		The present slope is based on the last frequency.
		mag = [mag, calcMag(mag(end), magFreq(end-1), currMagSlope, currFreq)];
		
		%	Adjust the phase based on the number of poles and zeros.  The phase change
		%		is determined by the #s of poles and zeros at the current frequency and
		%		the sign of the DC magnitude.
		phs = [phs, phs(end), (phs(end) + -sign(currRoot) * currPhaseChange)];
	else
		%	This section is for when the current frequency is 0.  This is so that transfer
		%		functions of s and 1/s can be plotted correctly.
		num = numP - numZ;
		
		magFreq = wBode(1);		
		phsFreq = wBode(1);
		mag = db(magBode(1));
		phs = -90*num;
	end
	
	%	Update the slope based on the current root.  It will be used
	%		by the next root of the final point -- wBode(end).
	currMagSlope = currMagSlope + (+20 * numZ) + (-20 * numP);
end

%	Add the final points for the phase and magnitude vectors.
magFreq = [magFreq, max(wBode)];
magFreq(1) = min(wBode);
phsFreq = [phsFreq, phsFreq(end), phsFreq(end), max(wBode)];
phsFreq(1) = min(wBode);
phs = [phs, phs(end), phs(end), phs(end)];
mag = [mag, calcMag(mag(end), magFreq(end-1), currMagSlope, max(wBode))];

%	Convert the frequency vectors from rad/sec to Hz.
wBode = wBode;
magFreq = magFreq;
phsFreq = phsFreq;

%	Plot the approximate Bode vs. the MATLAB bode command
h = gcf;
subplot(2, 1, 1)
semilogx(wBode, 20*log10(magBode(:)), 'b', magFreq, mag, 'r-.', 'LineWidth', 2)
hold on
semilogx(magFreq, mag, 'ro', 'MarkerSize', 6.5)
axis([min(wBode) max(wBode) floor(min(mag)/20)*20 ceil(max(mag)/20)*20])
vettick = (floor(min(mag)/20)*20):20:(ceil(max(mag)/20)*20);
set(gca,'ytick',vettick);
hold off
grid on
ylabel('Magnitude (dB)')

if length(z) == 1 && length(p) == 1
	title({'Approximate Bode', ['Zeros: [' num2str(z') '], Poles: [' num2str(p') '], Gain: ' num2str(k)]})
else
	title({'Approximate Bode'})
end

% Realizar ass�ntotas mais detalhadas na fase.
[phsFreq, phs] = corrigefases(phsFreq, phs);

subplot(2, 1, 2)
semilogx(wBode, phsBode(:), 'b', phsFreq, phs, 'r-.', 'LineWidth', 2)
hold on
semilogx(phsFreq, phs, 'ro', 'MarkerSize', 6.5)
axis([min(wBode) max(wBode) floor(min(phs)/90)*90 ceil(max(phs)/90)*90])
set(gca,'ytick',min(phs):90:max(phs));
hold off
grid on
ylabel('Phase (deg)')
xlabel('Frequency (rad/s)')


function [phsFreq_novo, phs_novo] = corrigefases(phsFreq, phs)

% armazena [inclinacao, freqini, freqfim]
assintota = [0 0 max(phsFreq)];
numpontos = length(phs);
[phsFreq_novo,sequencia] = sort(phsFreq);
phs_novo = phs(sequencia);

% Recalcula o novo valor de fase, considerando as assintotas validas em
% cada faixa
for k = 1:(numpontos-1)
    if sequencia(k) < numpontos
        % armazena [inclinacao, freqini, freqfim]
        assintota = [assintota;...
            [(phs(sequencia(k)+1)-phs(sequencia(k)))/2, phsFreq(sequencia(k)), phsFreq(sequencia(k)+1)]];
    end
    validas = assintota(:,2)<=phsFreq_novo(k) & assintota(:,3)>=phsFreq_novo(k+1);
    m = sum(assintota(validas,1));
    %  Y = Y0 + m x log(X/X0)
    phs_novo(k+1) = phs_novo(k) + m*log10(phsFreq_novo(k+1)/phsFreq_novo(k));
end



%	---	Subfunctions

%	Calculate the magnitude using the current magnitude, current frequency,
%		current slope, and final frequency in conjunction with the polyfit and
%		polyval functions.
function [endMag] = calcMag(startMag, startFreq, slope, endFreq)

%	If the slope is 0 then the final magnitude will be equal to the starting
%		magnitude.
if slope == 0
	endMag = startMag;
	return
end

%	Determine the number of frequency decades and round up.
numDecades = ceil(log10(endFreq / startFreq));

%	Calculate the magnitude based on the starting magnitude and add the
%		dB magnitude + the current slope * number of frequency decades.
tempMag = startMag + (slope * numDecades);

%	Calculate the end frequency by taking the current frequency and multiplying
%		it by the number of frequency decades.
tempFreq = startFreq * 10^numDecades;

%	Use polyfit and polyval to determine the magnitude at the desired end frequency.
P = polyfit(log10([startFreq ; tempFreq]), [startMag ; tempMag], 1);
endMag = polyval(P, log10(endFreq));