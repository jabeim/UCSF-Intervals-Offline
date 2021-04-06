function [wavOut,envMean, envLo, envHi]= spiral_UCSF(wavIn, condition, carrierDensity,carrierLo,carrierHi, currentSpread, dynamicRange, freqShift, sampleRate)
% function out = spiral(ipwave, n_electrodes, n_carriers, spread, sf)
%
% args in: input wave (:,1); number of electrodes; number of tone carriers;
% current spread [in -dB/Oct (negative!!)]; sampling frequency (Hz).
%
%       EXAMPLE: out = spiral(audioread('_wavefilename_'), 20, 80, -8, 44100);
%
% Typical current spread (Oxenham & Kreft 2014 + Nelson etal 2011) = -8 dB/octave.
%
% Author: Jacques Grange, Cardiff Uni, John Culling group, 2017; grangeja@cardiff.ac.uk.

% Modified by: Jordan Beim, University of Minnesota, Auditory Perception and
% Cognition lab, 2020; beimx004@umn.edu
   currentSteerSim = 1;
                                                                            %
%                                                                           % could change spread to dB per ERB instead
%     analysisLo=12;                                                         % lower bound of analysis filters (Hz) [120 ](Friesen et al.,2001)
%     analysisHi=7325;                                                        % upper bound of analysis filters (Hz)[8658]
%     carrierLo = 333;                                                         % lower bound of carriers (Hz)
%     carrierHi = 16000;                                                      % higher bound of carriers (Hz) change to 16000?
    lp_filter = make_fir_filter(0, 50, sampleRate);                         % generate low-pass filter,  default 50Hz
%     analysisFreqs = generate_cfs(analysisLo, analysisHi, nElectrodes);      % electrodes' centre frequencies
%     analysisFreqs = [333 455 540 642 762 906 1076 1278 1518 1803 2142
%     2544 3022 3590 4264 6665]; % AB standard map 16ch
%     analysisFreqs = [125 234 385 582 840 1182 1631 2227 3064 4085 5656 7352]; % MedEL standard map 12ch
    
    analysisFreqs = {[120 235 384 580 836 1175 1624 2222 3020 4084 5507 7410];
                     [257 618 994 1342 1792 2368 3116 4110 5056 5869 6814 7911];
                     [502 716 986 1341 1790 2365 3111 4104 5452 7366];
                     [502 716 986 1331 1781 2350 3080 4094 5056 5869 6814 7911]};
    
    carrierFreqs = generate_cfs2(carrierLo, carrierHi, carrierDensity);           % tone carrier frequencies
    nCarriers = length(carrierFreqs);
    toneCarriers = zeros(length(wavIn), nCarriers);
%     analysisBands = generate_bands(analysisLo, analysisHi, nElectrodes);    % lower/upper limits of each analysis band
    
% Manually assigned analysis bands re: USCF Mapping Data
    analysisBands = {[70 170 300 469 690 982 1368 1881 2564 3475 4693 6321;
                    170 300 469 690 982 1368 1881 2564 3475 4693 6321 8500]';
                 
                     [120 394 842 1146 1539 2046 2691 3540 4679 5432 6306 7322;
                      394 842 1146 1539 2046 2691 3540 4679 5432 6306 7322 8500]';
    
                     [401 603 828 1145 1537 2043 2687 3535 4672 6232;
                     603 828 1145 1537 2043 2687 3535 4672 6232 8500]';
                 
                     [401 603 829 1148 1514 2048 2653 3508 4679 5432 6306 7322;
                     603 829 1148 1514 2048 2653 3508 4679 5432 6306 7322 8500]'};
    
                 
                 
               

    

    
    
    % override freqShift based on CT maps

    
    if currentSteerSim == 1
        [analysisBands, neuralCFs] = bandInterpolate(condition);
        analysisFreqs = mean(analysisBands,2)';
        nElectrodes = length(analysisFreqs); 
    else
        analysisFreqs = analysisFreqs{condition};
        analysisBands = analysisBands{condition};
        nElectrodes = length(analysisFreqs); 
        switch condition
            case {1, 2}
                neuralCFs = [352 540 784 1109 1533 2099 2866 3877 5255 7284 10209 13732];
            case {3, 4}
                neuralCFs = [502 717 988 1330 1781 2350 3082 4066 5384 7234 9953 13286];           
        end
    end
    
    
    freqShift = neuralCFs(1:length(analysisFreqs))-analysisFreqs;


    envelope = zeros(length(wavIn),nElectrodes);                            % envelopes extracted per electrode
    compressedEnvelope = zeros(length(wavIn),nElectrodes);
    mixedEnvelope = zeros(length(wavIn),nCarriers);                         % mixed envelopes to modulate carriers
                                         
    t = 0:1/sampleRate:(length(wavIn)-1)/sampleRate;
                    
    load('nfMeasurements.mat')
    
    % per Stafford et al 2014, Ear & Hearing                                      
    envMin = sigMax;   % set this to 95% CI for channel envelope magnitudes
    envMax = nfMean;   % set this to approximate noise floor 
    
    if not(all(dynamicRange))
        error('Dynamic Range must be nonzero for all electrodes (range: (0 Inf])')
    end
    
    %% Create per-channel values for current spread, dynamic range, frequency shift
    if isscalar(currentSpread)
        currentSpread = currentSpread*ones(1,nElectrodes); % set current spread per electrode
    end
    
    if isscalar(dynamicRange)
        dynamicRange = dynamicRange*ones(1,nElectrodes); % set dynamic range per electrode
    end
    
    if isscalar(freqShift)
        freqShift = freqShift*ones(1,nElectrodes); % offset each electrode by 500 Hz for the purposes of mixed envelope summation
    end
    
    lowerBound = mean(envMax).*10.^(0.5*dynamicRange/20);   % matching envelope power to DR requires 50% dynamic range scaling here?
    
    
    for j=1:nElectrodes            % extraction of envelopes, per analysis band
        analysisFilterbank(j,:) = make_fir_filter(analysisBands(j,1), analysisBands(j,2), sampleRate);      % analysis filterbank
        speechband = conv(wavIn(:,1),analysisFilterbank(j,:),'same')';                                      % speech band filtering
        speechband = speechband.*(speechband>0);                                                            % envelope extraction by half-wave rectification
        %% Add dynamic range compression to each envelope here
        envelope(:,j) = conv(speechband,lp_filter,'same')';                                                 % low-pass filter envelope
%         figure(1)
%         subplot(121),plot(20*log10(envelope(:,j).^2))
%         if j == 1; hold on; end
%         if j == nElectrodes; hold off; end
%         
%         envMean(j) = mean(envelope(1000:2000,j)-4.656*std(envelope(1000:2000,j)));  %99.999% CI of noise floor amplitude.
%         envLo(j) = min(envelope(:,j));
%         envHi(j) = max(envelope(:,j));
        
        if dynamicRange(j) < inf % rescale only if dynamic range set
            compressedEnvelope(:,j) = rescale(envelope(:,j),lowerBound(j),mean(envMax));  % rescale envelope to [envMax-dynamicRange envMax)
            compressedEnvelope(envelope(:,j) >= 50*envMax(j),j) = 0; % zero points above envMax to reduce signal noise
%             subplot(122),plot(20*log10(compressedEnvelope(:,j).^2))
%             if j == 1; hold on; end
%             if j == nElectrodes; hold off; linkaxes;  end
        else
            compressedEnvelope(:,j) = envelope(:,j);                   
        end
%         pause
    end
    

    envelope = compressedEnvelope;
    
    for i=1:nCarriers              % contribution of each envelope to each mixed envelope
        for j=1:nElectrodes
            mixedEnvelope(:,i) = mixedEnvelope(:,i) + ...
          10^(currentSpread(j)/10*abs(log2((analysisFreqs(j)+freqShift(j))/carrierFreqs(i))))*envelope(:,j).^2;  % weights applied to power envelopes
        end
    end
    mixedEnvelope = mixedEnvelope.^0.5;                                   % sqrt to get back to amplitudes
    wavOut = zeros(length(wavIn),1);
    for i=1:nCarriers
        toneCarriers(:,i) = sin(2*pi*(carrierFreqs(i)*t+rand))';                 % randomise tone phases (particularly important for binaural!)
        wavOut = wavOut + mixedEnvelope(:,i).*toneCarriers(:,i);                    % modulate carriers with mixed envelopes
    end
    wavOut = wavOut*0.05*sqrt(length(wavOut))/norm(wavOut);                             % rms scaled, to avoid saturation
end



