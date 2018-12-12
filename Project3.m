%% Project 3 MATLAB Video Game
%  3/C Braun & 3/C Jiang
%  15 NOV 2016
%% Generate graphics handles

myfig=figure(1); %create figure set it as myfig
clf;
width = 750;
height =375*1.5;
axis([0 width 0 height]); % figure is 500 units wide and 375 tall
grid off;
hold on;
axis('off')
myfig.Color=[.5 .5 .8];        %make outer border black
fill([0 width width 0], [0 0 height height], 'w');
ax=gca;
%  generate background
background=imread('space.png');
imagesc([0 750], [0 562.5], background);
set(gca, 'YDir', 'Normal');

[y,map,alpha] = imread('spaceship1.png');
ship=image(y);      %insert spaceship
ship.AlphaData = alpha;
ship.YData = [64 1]; % this is necessary to flip the graphic so it displays right side up
myfig.UserData.fire=0;
myfig.KeyPressFcn = @keypressed % add key pressed callback to listen for l-r-spc
gun = ship;
bullets = []; % object array of bullets currently in flight

[y, map, alpha]=imread('asteroid2.png');
rocks(1)=image(y);
rocks(1).AlphaData=alpha;
rocks(1).XData=[15 100];
rocks(1).YData=[64 1];

[y, map, alpha]=imread('asteroid2.png');
rocks(4)=image(y);
rocks(4).AlphaData=alpha;
rocks(4).XData=[15 100];
rocks(4).YData=[1 64];

[y, map, alpha]=imread('fuel can2.png');
rocks(2)=image(y);
rocks(2).AlphaData=alpha;
rocks(2).XData=[15 100];
rocks(2).YData=[64 1];

[y, map, alpha]=imread('ammo2.png');
rocks(3)=image(y);
rocks(3).AlphaData=alpha;
rocks(3).XData=[15 100];
rocks(3).YData=[64 1];

[y, map, alpha]=imread('lightning bolt.png');
rocks(5)=image(y);
rocks(5).AlphaData=alpha;
rocks(5).XData=[15 100];
rocks(5).YData=[64 1];

rocks(3).UserData.ammo=1;
rocks(2).UserData.fuel=500;

text(5, 500, 'Score','color','white');
scoretext=text(105, 500, 'Score: ');
scoretext.Color=[1 1 1];
text(5, 450, 'Fuel','color','white');
fueltext=text(105, 450, 'Fuel: ');
fueltext.Color=[1,1,1];

text(5, 400, 'Ammo','color','white');
ammotext=text(105, 400, 'Ammo: ');
ammotext.Color=[1 1 1];
text(5, 350, 'Boost','color','white');
boosttext=text(105, 350, 'Boost: ');
boosttext.Color=[1 1 1];
%% Read Sound Effects

[y, Fs] = audioread('speed.wav');
speed_sound = audioplayer(y, Fs)    %noise when collecting ammo
[y, Fs] = audioread('refuel.wav');
refuel_sound = audioplayer(y, Fs)      % noise when refueling
[y, Fs] = audioread('reload.wav');
reload_sound = audioplayer(y, Fs)    %noise when collecting ammo
[y, Fs] = audioread('hit.wav');
hit_sound = audioplayer(y, Fs)    %noise when collecting ammo

%% Create gamepad object

gamepad = KeyboardEmulator(myfig);
gamepad.mapButton('a',3)
%Create a PS3 gamepad object
%gamepad = PS3Controller('COM9');

moveYto(ship,35)
moveXto(ship,width/2)

%% Move objects to starting points

for rock = rocks
    moveXto(rock, rand()*width); % Random starting x for each of the 3
    moveYto(rock, height);       % Start at top of window, y = 10
end
%  The set command sets the vertex locations to be the basic shape data
%  plus some overall location.  Each base shape is effectively located at
%  (0,0) to start, and then moved absolutely

%% Get a speed for each object
%
%  Each object will move from top to bottom on the screen with a random
%  speed. Falling so speed is negative
speed = -1*(50*rand(5,1) + 170);   % values between 170 and 220 units per second

%% Determine frame rate
%
%  The faster the frame rate, the smoother the graphics
%  If the frame rate is too high (the period too low), the system may slow
%  down dramatically due to processor overload.
T = 0.01;    % 100 hz

%% Move objects on screen
%
% This loop moves the objects from top to bottom on the screen, resetting
% each object's location when it goes off the bottom of the screen
done = 0;  % a flag to determine if the game is over
fuel=1000;
ammo=3;
score=0;
DT=1/20;
m=200;
t=0;
boost=0;

while (done == 0 && fuel>0)  % keep going until the game is over
    fuel=fuel-1;
    score=score+1;
    scoretext.String=score;
    fueltext.String=fuel;
    ammotext.String=ammo;
    boosttext.String=boost;
    pause(T);  % this is the way that we force the framerate
    for i = 1:5             % For each asteroid
        
        moveYby(rocks(i),speed(i)*T);  % position updated by speed*time
        if (max(rocks(i).YData) < -10)             %  if it went off the screen
            speed(i) = -1*(50*rand() + 170);   %    get a new speed
            moveXto(rocks(i),rand()*width)         %    move to new X
            moveYto(rocks(i),height+20);           %    move above the screen
            if (i==2)
                rocks(2).UserData.fuel=500;
            end
            if (i==3)
                rocks(3).UserData.ammo=1;
            end
        end
    end
    
    gamepad.update()
    speed_x = m*(gamepad.jlx);

    moveXby(ship,speed_x*T);
    if(mean(ship.XData)>width)
        moveXto(ship,width)
    elseif(mean(ship.XData)<0)
        moveXto(ship,0)
    end
    speed_y=m*(gamepad.jly);
   
    moveYby(ship,speed_y*T)
    if (mean(ship.YData)>(height/2))
        moveYto(ship, (height/2))
    elseif (mean(ship.YData)<0)
        moveYto(ship,0)
    end
    % speed boost
    if ((gamepad.speed)&&(boost>0))
        m=1000;
        t=t+1;
        speed_sound.play;
        if (t>200)
           gamepad.speed=0;
          t=0;
        m=200;
        end
    end
    %make it shoot
    if ((gamepad.fire) && (ammo>0) && (gamepad.loaded)) % fire button needs to be pressed and gun needs to be loaded
        % create a new bullet object, parented to ax
        newbullet = plot(ax, mean(ship.XData)*[1 1], [max(ship.YData) min(ship.YData)], 'g');
        newbullet.UserData.age = 0; % used to decide if bullet is dead or not
        bullets = [bullets newbullet]; % add the new bullet to the array of live bullets
        gamepad.fire = 0;
        gamepad.loaded=0;
        ammo=ammo-1;
        
        [y, Fs] = audioread('laser.mp3');
        laser_sound = audioplayer(y, Fs);
        if (gamepad.laser)
            disp('Fire');
            laser_sound.play;
            gamepad.laser=0;
        end
        fprintf('Ammo: %d\n', ammo);
    end
     gamepad.fire = 0;
    % Update the bullets: Here's a hack for having variable numbers of bullets
    newbullets = []; % create a new object array
    for bullet=bullets
        if bullet.UserData.age <= 40
            % bullet moves upwards
            bullet.YData = bullet.YData+10;
            bullet.UserData.age = bullet.UserData.age+1;
            newbullets = [newbullets bullet]; % move live bullets over
        elseif bullet.UserData.age <= 41
            % bullet explodes
            bullet.Marker = 'o';
            bullet.MarkerSize = 20;
            bullet.MarkerFaceColor = 'y';
            bullet.UserData.age = bullet.UserData.age+1;
            newbullets = [newbullets bullet]; % move live bullets over
        else
            % but delete the exploded bullets
            % otherwise you end up with an ever expanding array of bullets
            % that starts to bog things down
            delete(bullet);
        end
    end
    bullets = newbullets; % at the end of this bullets only has the live bullets
    newbullets=[];
    for bullet = bullets
        bulletdone=0;
        for rock =rocks
            if (isCollision(bullet,rock))
                disp('Asteroid Destroyed');
                rock.YData=rock.YData-100000;
                score=score+100;            % earn 100 points for destroying asteroid
                bulletdone=1;
                break
            end
        end
        if bulletdone
            delete(bullet);
        else
            newbullets=[newbullets, bullet];
        end
    end
    bullets = newbullets;
    
    for rock = rocks(1)
        if (isCollision(ship,rock))
            
            hit_sound.play;
            text(0, 300, 'Hit by rock!!','color','white');
            disp('Hit!');
            done = 1;  % game over
            break
        end
    end
    
    for rock = rocks(4)
        if (isCollision(ship,rock))
            text(0, 300, 'Hit by rock!!','color','white');
          
            hit_sound.play;
            disp('Hit!');
            done = 1;  % game over
            break;
        end
    end
    
    for rock = rocks(2)
        if (isCollision(ship,rock))
            fuel=fuel +rocks(2).UserData.fuel;
            if (rocks(2).UserData.fuel>0)
                text(0, 200, 'Picked up fuel!','color','white');
                refuel_sound.play;
                rock.YData=rock.YData-100000;
                fprintf('Fuel: %d\n',fuel);
            end
            rocks(2).UserData.fuel=0;
            break;
        end
    end
    
    for rock = rocks(3)
        if (isCollision(ship,rock))
            ammo=ammo+rocks(3).UserData.ammo;
            if (rocks(3).UserData.ammo >0)
                text(0, 100, 'Picked up ammo','color','white');
                reload_sound.play;
                disp('Reload');
                fprintf('Ammo: %d\n', ammo);
                rock.YData=rock.YData-100000;
            end
            rocks(3).UserData.ammo=0;
            break;
        end
        
        for rock = rocks(5)
        if (isCollision(ship,rock))
            boost=boost +1;
            text(0, 250, 'Picked up boost','color','white');
            rock.YData=rock.YData-100000;
            disp('Speed Boost');
            break
        end
    end
    end
    
end
fprintf('Score: %d\n', score);
if (fuel<=0)
    fprintf('Ran out of fuel');
end