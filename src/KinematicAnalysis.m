classdef KinematicAnalysis
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        time
        timeLabel
        bodyAngle
        bodyAngleLabel
        linearVelocity
        linearVelocityUnit
        x
        xLabel
        y
        yLabel
        
        filteredBodyAngle
        
        % bend vars
        bodyAngleAtBend=[]
        normalizedBend=[]
        bendCoordinates=[]
    end
    
    methods
        function obj=KinematicAnalysis(table,flip,trim)
            % Constant Strings
            CURL_VAR='Curl';
            TIME_VAR='Time';
            LINEAR_VELOCITY_VAR='LinearVelocity';
            CURL_VELOCITY_VAR='CurlVelocity';
            HEAD_POSITION_X='HeadPositionX';
            HEAD_POSITION_Y='HeadPositionY';
            obj.timeLabel='Time (ms)';
            obj.bodyAngleLabel='Body angle (degrees)';
            obj.xLabel='X Coordinate (mm)';
            obj.yLabel='Y Coordinate (mm)';
            
            
            % Get the indices for the variables
            curlIndex=find(strcmpi(table.Properties.VariableNames,CURL_VAR));
            timeIndex= find(strcmpi(table.Properties.VariableNames,TIME_VAR));
            linearVelIndex=find(strcmpi(table.Properties.VariableNames,LINEAR_VELOCITY_VAR));
            curlVelIndex=find(strcmpi(table.Properties.VariableNames,CURL_VELOCITY_VAR));
            headPositionXIndex=find(strcmpi(table.Properties.VariableNames,HEAD_POSITION_X));
            headPositionYIndex=find(strcmpi(table.Properties.VariableNames,HEAD_POSITION_Y));
            
           

            if isempty(trim)
               trim=[2 2*height(table)] ;
            end
            
            % trim the table
            table=table(trim(1)/2+1:trim(2)/2,:);
            
            % Reset time
            data=table2array(table);
            data(:,timeIndex)=data(:,timeIndex)-data(1,timeIndex);
            
            % set initial velocities
            data(1,curlVelIndex)=0.0;
            data(1,linearVelIndex)=0.0;
            
            % set the table values in object
            obj.time=data(:,timeIndex);
            if flip
                obj.bodyAngle=-1*data(:,curlIndex);
            else
                obj.bodyAngle=data(:,curlIndex);
            end
            obj.x=data(:,headPositionXIndex);
            obj.y=data(:,headPositionYIndex);
            
            win=generalGaussian(5,0.5,100);
            obj.filteredBodyAngle=conv(win,obj.bodyAngle);
            obj.filteredBodyAngle=obj.filteredBodyAngle.*mean(obj.bodyAngle)/mean(obj.filteredBodyAngle);
            obj.filteredBodyAngle=circshift(obj.filteredBodyAngle,-2);
            obj.filteredBodyAngle=obj.filteredBodyAngle(1:length(obj.filteredBodyAngle)-4);
            
            bends=[];
            direction='None';
            changed=false;
            DIRECTION_DECREASE='direction';
            DIRECTION_INCREASE='increasing';
            for i=2:length(obj.filteredBodyAngle)-3
                if isempty(bends) || i-bends(length(bends))>4
                    current=obj.filteredBodyAngle(i);
                    previous=obj.filteredBodyAngle(i-1);
                    if current > previous+1
                        if strcmp(direction, DIRECTION_DECREASE)
                            changed=true;
                        end
                        direction=DIRECTION_INCREASE;
                    elseif current < previous -1
                        if strcmp(direction, DIRECTION_INCREASE)
                            changed=true;
                        end
                        direction=DIRECTION_DECREASE;
                    end
                    
                    if changed
                        localArray=obj.bodyAngle(i-2:i);
                        value=[];
                        if strcmp(direction,DIRECTION_INCREASE)
                           [~,value]=min(localArray);
                        elseif strcmp(direction,DIRECTION_DECREASE)
                            [~,value]=max(localArray);
                        end
                        bends(length(bends)+1)=i-3+value;
                        changed=false;
                    end
                end
            end
            
            bends=bends*2;
            bends=bends+trim(1);
            obj.normalizedBend=zeros(1,length(bends));
            obj.bodyAngleAtBend=zeros(1,length(bends));
            
            for i=1:length(bends)
                normBend=bends(i)-trim(1);
                obj.normalizedBend(i)=normBend;
                obj.bodyAngleAtBend(i)=obj.bodyAngle(floor(normBend/2));
            end
            obj.bendCoordinates=vertcat(obj.normalizedBend,obj.bodyAngleAtBend)';
        end
        
        function duration=getDuration(obj)
           duration=obj.time(length(obj.time)); 
        end
        
        function coord=getXCoordinatesFromOrigin(obj)
            coord=obj.x-obj.x(1);
        end
        
        function coord=getYCoordinatesFromOrigin(obj)
            coord=obj.y-obj.y(1);
        end
        
        function [maxDist, distTravelled] = distanceTravelled(obj)
            c1=horzcat(obj.x,obj.y);
            c2=c1(1:length(c1)-1,:);
            c1=c1(2:length(c1),:);
            dt=sqrt(sum((c2-c1).^2,2));
            distTravelled=zeros(size(dt));
            distTravelled(1)=dt(1);
            for i = 2:length(dt)
                distTravelled(i)=distTravelled(i-1)+dt(i);
            end
            maxDist=max(distTravelled);
        end
        
        function [meanV, medianV, maxV] = getVelocityStatistics(obj)
            meanV=mean(obj.linearVelocity);
            medianV=median(obj.linearVelocity);
            maxV=max(obj.linearVelocity);
        end
        
        function [meanBA, medianBA, maxBA] = getBodyAngleStatistics(obj)
            meanBA=mean(obj.bodyAngle);
            medianBA=median(obj.bodyAngle);
            maxBA=max(obj.bodyAngle);
        end
        
        function [numBends, freqBends, numHighAmpBends] = getBodyBendStatistics(obj)
            numBends=length(obj.bodyAngleAtBend);
            freqBends=numBends/obj.getDuration();
            numHighAmpBends=0;
            for i = 1:numBends
               if abs(obj.bodyAngleAtBend(i))>=110
                   numHighAmpBends=numHighAmpBends+1;
               end
            end
        end
    end
    
end

