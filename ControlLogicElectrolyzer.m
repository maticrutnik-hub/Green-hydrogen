
function [BattInpPower,BattOutPower,HsysInpPwr,HsysOutPwr,GridInpPwr,GridOutPwr,OpCase,BattFull,BattEmpty,HsysFull,HsysEmpty] = ...
ControlLogicElectrolyzer(Ts, ExcessPower,...
BattSoC, BattCapacity, BattFullFact, BattEmptyFact, BattInpPowerMax, BattOutPowerMax,...
HsysSoC, HsysCapacity, HsysFullFact, HsysEmptyFact, HsysInpPowerMax, HsysOutPowerMax, HsysInpPowerMin)


%Debugging
% disp(['LExcessPower: ', num2str(LExcessPower)]);
% disp(['BattSoC:     ', num2str(BattSoC)]);
% disp(['HsysSoC:     ', num2str(HsysSoC)]);
% disp(['BattFullFact: ', num2str(BattFullFact)]);
% disp(['BatCapacity:  ', num2str(BattCapacity)]);
% disp(['BattFull:     ', num2str(BattFull)]);

BattInpPower=0;
BattOutPower=0;
HsysInpPower=0;
HsysOutPower=0;
GridInpPower=0;
GridOutPower=0;

%Battery full / empty indicator
%------------------------------
if BattSoC > BattFullFact * BattCapacity
    BattFull=1;
else
    BattFull=0;
end
if BattSoC < BattEmptyFact * BattCapacity
    BattEmpty=1;
else
    BattEmpty=0;
end


%Hydrogen system full / empty indicator
%--------------------------------------
if HsysSoC > HsysFullFact * HsysCapacity
    HsysFull=1;
else
    HsysFull=0;
end
if HsysSoC < HsysEmptyFact * HsysCapacity
    HsysEmpty=1;
else
    HsysEmpty=0;
end

%Case when generated power exceeds or equals consumed power
%----------------------------------------------------------
if ExcessPower>=0
    BattOutPower=0;
    HsysOutPwr=0;
    GridOutPwr=0;

    BattInpPwrAcc = min(BattInpPowerMax, (BattFullFact*BattCapacity-BattSoC)/Ts);
    HsysInpPwrAcc = min(HsysInpPowerMax, (HsysFullFact*HsysCapacity-HsysSoC)/Ts);
        
    if (BattFull==0)&&(HsysFull==0)   % če baterija in H2 nista polna
        if ExcessPower<=BattInpPwrAcc
            BattInpPower=ExcessPower;
            HsysInpPwr=0;
            GridInpPwr=0;
            OpCase=1010;             %case1
        else
        	BattInpPower=BattInpPwrAcc;
                if (HsysInpPowerMin<(ExcessPower-BattInpPwrAcc))&&(ExcessPower-BattInpPwrAcc)<=HsysInpPwrAcc %min and max electrolyzer power
                	HsysInpPwr= ExcessPower-BattInpPwrAcc;
                	GridInpPwr=0;
                    OpCase=1011;     %case2
                else
                    if  (ExcessPower-BattInpPwrAcc) > HsysInpPwrAcc
                	    HsysInpPwr=HsysInpPwrAcc;
                	    GridInpPwr=ExcessPower-BattInpPwrAcc-HsysInpPwrAcc;
                        OpCase=1012; %case3
                    else
                        HsysInpPwr=0;
        	            GridInpPwr=ExcessPower-BattInpPwrAcc; %premajhna energija za polnjenje ampak odvečna 
                        OpCase=1013; %case4
                    end
                end
        end
    end
     
    if (BattFull==1)&&(HsysFull==0)  %če je baterija polna in H2 tank ni polen
        BattInpPower=0;
        if (HsysInpPowerMin<ExcessPower) && (ExcessPower<=HsysInpPwrAcc) %min and max electrolyzer power
            HsysInpPwr=ExcessPower;
            GridInpPwr=0;
            OpCase=1021;            %case5
        else
            if  (ExcessPower>HsysInpPwrAcc)
        	    HsysInpPwr=HsysInpPwrAcc;
        	    GridInpPwr=ExcessPower-HsysInpPwrAcc;
                OpCase=1022;        %case6
            else
                HsysInpPwr=0;
        	    GridInpPwr=ExcessPower; %premajhna energija za polnjenje ampak odvečna 
                 OpCase=1023;       %case7
            end
        end
    end
    
    if (BattFull==0)&&(HsysFull==1)   % če baterija ni polna, H2 tank polen
        if ExcessPower<=BattInpPwrAcc
            BattInpPower=ExcessPower;
            GridInpPwr=0;
            OpCase=1031;            %case8
        else
            BattInpPower=BattInpPwrAcc;
            GridInpPwr=ExcessPower-BattInpPwrAcc;
            OpCase=1032;            %case9
        end
        HsysInpPwr=0;
    end
        
    if (BattFull==1)&&(HsysFull==1)  % če sta polna baterija in H2 tank
        BattInpPower=0;
        HsysInpPwr=0;
        GridInpPwr=ExcessPower;
        OpCase=1040;                %case10
    end
    
end


%Case when generated power is lower than consumed power
%------------------------------------------------------
if ExcessPower<0
    MissingPower=-ExcessPower;%aux. variable, >0
    BattInpPower=0;
    HsysInpPwr=0;
    GridInpPwr=0;

    BattOutPwrAcc = min(BattOutPowerMax, (BattSoC-BattEmptyFact*BattCapacity)/Ts);
    HsysOutPwrAcc = min(HsysOutPowerMax, (HsysSoC-HsysEmptyFact*HsysCapacity)/Ts);
        
    if (BattEmpty==0)&&(HsysEmpty==0)   % če sta baterija in H2 tank nista prazna
        if MissingPower<=BattOutPwrAcc
            BattOutPower=MissingPower;
            HsysOutPwr=0;
            GridOutPwr=0;
            OpCase=2010;            %case11
        else 
        	BattOutPower=BattOutPwrAcc;
                if (MissingPower-BattOutPwrAcc)<=HsysOutPwrAcc
                	HsysOutPwr= MissingPower-BattOutPwrAcc;
                	GridOutPwr=0;
                    OpCase=2011;    %case12
                else
                	HsysOutPwr=HsysOutPwrAcc;
                	GridOutPwr=MissingPower-BattOutPwrAcc-HsysOutPwrAcc;
                    OpCase=2012;    %case13
                end
        end
    end
    
    if (BattEmpty==1)&&(HsysEmpty==0) %če je baterija prazna in H2 tank ni prazen
        BattOutPower=0;
        if MissingPower<=HsysOutPwrAcc
            HsysOutPwr=MissingPower;
            GridOutPwr=0;
            OpCase=2021;            %case14
        else
        	HsysOutPwr=HsysOutPwrAcc;
        	GridOutPwr=MissingPower-HsysOutPwrAcc;
            OpCase=2022;            %case15
        end
    end
    
    if (BattEmpty==0)&&(HsysEmpty==1)  % baterija ni prazna, H2 tank prazen
        if MissingPower<=BattOutPwrAcc
            BattOutPower=MissingPower;
            GridOutPwr=0;
            OpCase=2031;            %case16
        else
            BattOutPower=BattOutPwrAcc;
            GridOutPwr=MissingPower-BattOutPwrAcc;
            OpCase=2032;            %case17
        end
        HsysOutPwr=0;
    end
        
    if (BattEmpty==1)&&(HsysEmpty==1) % če sta prazna baterija in h2 tank
        BattOutPower=0;
        HsysOutPwr=0;
        GridOutPwr=MissingPower;
        OpCase=2040;                %case18
    end
    
end

%For control purposes
% SumInpPower=BattInpPower+HsysInpPower+GridInpPower;
% SumOutPower=BattOutPower+HsysOutPower+GridOutPower;
% SumPower=SumInpPower+SumOutPower;

% disp(' ');
% disp(' ');
% disp(['CASE:                    ', num2str(OpCase)]);
% disp(['Batt input power  (MWh): ', num2str(BattInpPower)]);
% disp(['Batt output power (MWh): ', num2str(BattOutPower)]);
% disp(['Hsys input power  (MWh): ', num2str(HsysInpPower)]);
% disp(['Hsys output power (MWh): ', num2str(HsysOutPower)]);
% disp(['Grid input power  (MWh): ', num2str(GridInpPower)]);
% disp(['Grid output power (MWh): ', num2str(GridOutPower)]);
% disp(['Excess power      (MWh): ', num2str(ExcessPower)]);
% disp(['Batt+Hsys+Grid    (MWh): ', num2str(SumPower)]);

end


