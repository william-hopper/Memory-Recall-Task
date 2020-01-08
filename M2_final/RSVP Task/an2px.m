function pix = an2px(visual_angle, distance, screenNumber)
% Converts monitor pixels into degrees of visual angle

% default to screen distance of 80 cm
if ~exist('distance', 'var') || isempty(distance)
    distance = 80;
end

distance = distance*10; % convert to mm

dimensions = Screen('Rect', screenNumber); % get dimensions of main screen

aspect_ratio = dimensions(3) / dimensions(4); % calculate aspect ratio

dpi = get(groot, 'ScreenPixelsPerInch'); % calculate density per inch

[~, name] = system('HostName');
name = deblank(name);

if strcmp(name, 'WH-MateBook')
    dpi = 259.39;
end

pixel_width = 25.4/dpi;

visualangle_mm = tand(0.5 * visual_angle) * 2 * distance;

pix = round(visualangle_mm / pixel_width);
end