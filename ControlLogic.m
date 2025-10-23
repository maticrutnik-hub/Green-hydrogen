% Changes 26. 04. 2024


function [BattInpPower,BattOutPower,HsysInpPower,HsysOutPower,GridInpPower,GridOutPower,OpCase,BattFull,BattEmpty,HsysFull,HsysEmpty] = ...
ControlLogic(Ts,ExcessPower,...
BattSoC, BattCapacity, BattFullFact, BattEmptyFact, BattInpPowerMax, BattOutPowerMax,...
HsysSoC, HsysCapacity, HsysFullFact, HsysEmptyFact, HsysInpPowerMax, HsysOutPowerMax)

BattInpPower=0;
BattOutPower=0;
HsysInpPower=0;
HsysOutPower=0;
GridInpPower=0;
GridOutPower=0;

%Battery full / empty indicator
%------------------------------
if BattSoC >= BattFullFact * BattCapacity
    BattFull=1;
else
    BattFull=0;
end
if BattSoC <= BattEmptyFact * BattCapacity
    BattEmpty=1;
else
    BattEmpty=0;
end


%Hydrogen system full / empty indicator
%--------------------------------------
if HsysSoC >= HsysFullFact * HsysCapacity
    HsysFull=1;
else
    HsysFull=0;
end
if HsysSoC <= HsysEmptyFact * HsysCapacity
    HsysEmpty=1;
else
    HsysEmpty=0;
end


%Case when generated power exceeds or equals consumed power
%----------------------------------------------------------
if ExcessPower>=0
    BattOutPower=0;
    HsysOutPower=0;
    GridOutPower=0;
    BattInpPwrAcc = min(BattInpPowerMax, (BattFullFact*BattCapacity-BattSoC)/Ts);
    HsysInpPwrAcc = min(HsysInpPowerMax, (HsysFullFact*HsysCapacity-HsysSoC)/Ts);
        
    if (BattFull==0)&&(HsysFull==0)
        if ExcessPower<=BattInpPwrAcc
            BattInpPower=ExcessPower;
            HsysInpPower=0;
            GridInpPower=0;
            OpCase=1010;
        else
        	BattInpPower=BattInpPwrAcc;
                if (ExcessPower-BattInpPwrAcc)<=HsysInpPwrAcc
                	HsysInpPower= ExcessPower-BattInpPwrAcc;
                	GridInpPower=0;
                    OpCase=1011;
                else
                	HsysInpPower=HsysInpPwrAcc;
                	GridInpPower=ExcessPower-BattInpPwrAcc-HsysInpPwrAcc;
                    OpCase=1012;
                end
        end
    end
    
    if (BattFull==1)&&(HsysFull==0)
        BattInpPower=0;
        if ExcessPower<=HsysInpPowerMax
            HsysInpPower=ExcessPower;
            GridInpPower=0;
            OpCase=1021;
        else
        	HsysInpPower=HsysInpPowerMax;
        	GridInpPower=ExcessPower-HsysInpPowerMax;
            OpCase=1022;
        end
    end
    
    if (BattFull==0)&&(HsysFull==1)
        if ExcessPower<=BattInpPowerMax
            BattInpPower=ExcessPower;
            GridInpPower=0;
            OpCase=1031;
        else
            BattInpPower=BattInpPowerMax;
            GridInpPower=ExcessPower-BattInpPowerMax;
            OpCase=1032;
        end
        HsysInpPower=0;
    end
        
    if (BattFull==1)&&(HsysFull==1)
        BattInpPower=0;
        HsysInpPower=0;
        GridInpPower=ExcessPower;
        OpCase=1040;
    end
    
end


%Case when generated power is lower than consumed power
%------------------------------------------------------
if ExcessPower<0
    MissingPower=-ExcessPower;%aux. variable, >0
    BattInpPower=0;
    HsysInpPower=0;
    GridInpPower=0;

    BattOutPwrAcc = min(BattOutPowerMax, (BattSoC-BattEmptyFact*BattCapacity)/Ts);
    HsysOutPwrAcc = min(HsysOutPowerMax, (HsysSoC-HsysEmptyFact*HsysCapacity)/Ts);
        
    if (BattEmpty==0)&&(HsysEmpty==0)
        if MissingPower<=BattOutPwrAcc
            BattOutPower=MissingPower;
            HsysOutPower=0;
            GridOutPower=0;
            OpCase=2010;
        else 
        	BattOutPower=BattOutPwrAcc;
                if (MissingPower-BattOutPwrAcc)<=HsysOutPwrAcc
                	HsysOutPower= MissingPower-BattOutPwrAcc;
                	GridOutPower=0;
                    OpCase=2011;
                else
                	HsysOutPower=HsysOutPwrAcc;
                	GridOutPower=MissingPower-BattOutPwrAcc-HsysOutPwrAcc;
                    OpCase=2012;
                end
        end
    end
    
    if (BattEmpty==1)&&(HsysEmpty==0)
        BattOutPower=0;
        if MissingPower<=HsysOutPwrAcc
            HsysOutPower=MissingPower;
            GridOutPower=0;
            OpCase=2021;
        else
        	HsysOutPower=HsysOutPwrAcc;
        	GridOutPower=MissingPower-HsysOutPwrAcc;
            OpCase=2022;
        end
    end
    
    if (BattEmpty==0)&&(HsysEmpty==1)
        if MissingPower<=BattOutPwrAcc
            BattOutPower=MissingPower;
            GridOutPower=0;
            OpCase=2031;
        else
            BattOutPower=BattOutPwrAcc;
            GridOutPower=MissingPower-BattOutPwrAcc;
            OpCase=2032;
        end
        HsysOutPower=0;
    end
        
    if (BattEmpty==1)&&(HsysEmpty==1)
        BattOutPower=0;
        HsysOutPower=0;
        GridOutPower=MissingPower;
        OpCase=2040;
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


