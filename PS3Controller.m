classdef PS3Controller < handle
    %PS3CONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        serial; %COM port
        btnstate;
        jlx=0;
        jly=0;
        jrx=0;
        jry=0;
        fire=0;     %fire set to 0
        laser=0;    %laser set to 0
        loaded=1;
        speed=0;
    end
    
    methods
        function this = PS3Controller(port)
            %clear any existing COM ports
            a=instrfind('PORT',port);
            if ~isempty(a)
                fclose(a);
                delete(a);
            end
            s = serial(port);
            set(s, 'BaudRate', 9600);
            set(s, 'Parity', 'None');
            set(s, 'StopBits', 1);
            set(s, 'FlowControl', 'None');
            set(s, 'TimeOut', 0.1);
            fopen(s);
            this.serial = s;
            flushinput(this.serial);
        end
        
        function update(this)
            this.fire=0;
            this.laser=0;
            try
                str = fscanf(this.serial);
                [~,btnstr,lx,ly,rx,ry] = strread(str,'%s%s%d%d%d%d',1,'delimiter',',');
            catch
                return
            end
            this.btnstate = hex2dec(btnstr);
            this.jlx=(lx-512)/512;
            this.jly=(ly-512)/512;
            this.jrx=(rx-512)/512;
            this.jry=(ry-512)/512;
            thresh=0.1;
            if(abs(this.jlx)<thresh)
                this.jlx=0;
            end
            if(abs(this.jly)<thresh)
                this.jly=0;
            end
            if(abs(this.jrx)<thresh)
                this.jrx=0;
            end
            if(abs(this.jry)<thresh)
                this.jry=0;
            end
            if (this.btnstate==65519) %if button 3 is pressed
                this.fire=1;          %fire laser
               this.laser=1;           % laser noise
             
            elseif (this.btnstate==65471) %% if button 4 is pressed
                this.loaded=1;
            elseif (this.btnstate==65503) % if button 2 is pressed
                this.speed=1;
            end
            
            end
        
        
    
    
end

