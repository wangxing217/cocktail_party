pkg load nan

function separateUsingICA(sampleNumber)
    sampleNumber = strcat(num2str(sampleNumber), '/');

    mixedSourcesDir = strcat('sound_files/mixed_sources/', sampleNumber);
    originalSourcesDir = strcat('sound_files/original_sources/', sampleNumber);
    outputDir = strcat('sound_files/ica_output/', sampleNumber);

    numSamples = size(readdir(mixedSourcesDir), 1) - 2;

    [mixedSignal1, fs] = audioread(strcat(mixedSourcesDir, '1.wav'));
    [originalSignal1, fs] = audioread(strcat(originalSourcesDir, '1.wav'));
    [mixedSignal2, fs] = audioread(strcat(mixedSourcesDir, '2.wav'));
    [originalSignal2, fs] = audioread(strcat(originalSourcesDir, '2.wav'));

    mixedSignalList = [mixedSignal1, mixedSignal2];
    originalSignalList = [originalSignal1, originalSignal2];

    st = mktime(localtime(time()));
    xx = mixedSignalList';
    [A, W] = fastica(xx, 'verbose', 'off', 'displayMode', 'off');
    et = mktime(localtime(time()));

    'TIME'
    et - st

    a = W*xx;

    output1 = a(1, :)';
    output2 = a(2, :)';
    outputList = [output1, output2];

    numGraph = 1;
    for i = 1:numSamples
        subplot(3, numSamples, numGraph);
        plot(originalSignalList(:, i));
        title(strcat('Original wave', ' ', num2str(i)));

        subplot(3, numSamples, numGraph + numSamples);
        plot(mixedSignalList(:, i));
        title(strcat('Mixed wave', ' ', num2str(i)));

        subplot(3, numSamples, numGraph + numSamples * 2);
        plot(outputList(:, i));
        title(strcat('Output wave', ' ', num2str(i)));

        audiowrite(strcat(outputDir, num2str(i), '.wav'), a(i, :), fs);

        numGraph += 1;
    endfor

    c1 = corrcoef(abs(originalSignal1), abs(output1));
    c2 = corrcoef(abs(originalSignal2), abs(output2));
    cf = mean([c1; c2]);

    c1 = corrcoef(abs(originalSignal1), abs(output2));
    c2 = corrcoef(abs(originalSignal2), abs(output1));
    cs = mean([c1; c2]);

    'CORRELATION:'
    max([cf; cs])
endfunction

function singleSineICA()
    sample = 'singleSine'
    sample = strcat(num2str(sample), '/');

    mixedSourcesDir = strcat('sound_files/mixed_sources/', sample);
    originalSourcesDir = strcat('sound_files/original_sources/', sample);
    outputDir = strcat('sound_files/ica_output/', sample);

    [originalSignal1, fs] = audioread(strcat(originalSourcesDir, '1.wav'));
    [originalSignal2, fs] = audioread(strcat(originalSourcesDir, '2.wav'));

    A = unifrnd(1, 5, 2, 2);
    M = [originalSignal1, originalSignal2];
    S = M * A;
    xx = S';
    st = mktime(localtime(time()));
    [A, W] = fastica(xx, 'displayMode', 'off', 'maxNumIterations', 10000);
    et = mktime(localtime(time()));

    'TIME'
    et - st

    a = W*xx;

    output1 = a(1, :)';
    output2 = a(2, :)';

    mixedSignalList = S;
    outputList = [output1, output2];
    originalSignalList = [originalSignal1, originalSignal2];

    numGraph = 1;
    numSamples = 2;
    for i = 1:numSamples
        subplot(3, numSamples, numGraph);
        plot(originalSignalList(:, i));
        title(strcat('Original wave', ' ', num2str(i)));

        subplot(3, numSamples, numGraph + numSamples);
        plot(mixedSignalList(:, i));
        title(strcat('Mixed wave', ' ', num2str(i)));

        subplot(3, numSamples, numGraph + numSamples * 2);
        plot(outputList(:, i));
        title(strcat('Output wave', ' ', num2str(i)));

        audiowrite(strcat(outputDir, num2str(i), '.wav'), a(i, :), fs);
        'WRITE'

        numGraph += 1;
    endfor

    c1 = corrcoef(abs(originalSignal1), abs(output1));
    c2 = corrcoef(abs(originalSignal2), abs(output2));
    cf = mean([c1; c2]);

    c1 = corrcoef(abs(originalSignal1), abs(output2));
    c2 = corrcoef(abs(originalSignal2), abs(output1));
    cs = mean([c1; c2]);

    'CORRELATION'
    max([cf, cs])
endfunction

sample = argv(){1,1}

if (sample == 'singleSine')
    singleSineICA()
else
    separateUsingICA(sample)
endif
