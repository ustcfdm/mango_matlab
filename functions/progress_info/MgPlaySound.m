function MgPlaySound(soundNumber)
% Play a sound.

if nargin < 1
    soundNumber = 1;
end

switch soundNumber
    case 1
        S = load('chirp.mat');
        soundsc(S.y);
    otherwise
        error("Unsupported sound nubmer '%d'\n", soundNumber);
end


end

