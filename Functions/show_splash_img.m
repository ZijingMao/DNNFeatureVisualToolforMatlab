function  show_splash_img(image_name, show_time)
% Loads the specified image and display it centered on the screen with no
% title bar or frame for the specified time in seconds.


img = imread(image_name);               % Read the image
[l1,l2,~] = size(img);                  % Get the size
jimg = im2java(img);                    % convert to a Java image class
frame = javax.swing.JFrame;             % Create a fram from class

% Configure Java frame
frame.setUndecorated(true);
icon = javax.swing.ImageIcon(jimg);
label = javax.swing.JLabel(icon);
frame.getContentPane.add(label);
frame.pack;
frame.setSize(l2, l1);                  % Set size as picture

% Calculate the center position to show the image
screenSize = get(0,'ScreenSize');       % Get the screen size
point1 = (screenSize(3) - l2)/2;
point2 = (screenSize(4) - l1)/2;
frame.setLocation(point1, point2);
frame.show;

% Show the picture for N seconds (input) close frame and delete Java objects
pause(show_time);
frame.hide;
clear java


end