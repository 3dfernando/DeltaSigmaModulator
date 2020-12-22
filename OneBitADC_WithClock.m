clear; clc; close all;

VrefPlus=5;
VrefMinus=-5;



v1=VideoWriter('1Bit_ADC_Input_WITHCLOCK2.avi');
v1.Quality=95;
v1.FrameRate=20;
open(v1)

v2=VideoWriter('1Bit_ADC_Output_WITHCLOCK2.avi');
v2.Quality=95;
v2.FrameRate=20;
open(v2)

v3=VideoWriter('1Bit_ADC_CLOCK2.avi');
v3.Quality=95;
v3.FrameRate=20;
open(v3)

%%
nCycles=200;
nClockCycles = 50;
Vin_Array=zeros(nCycles,1);
Vout_Array=ones(nCycles,1)*5;
Vclock_Array=ones(nCycles,1)*(-5);
t=1:length(Vin_Array);

i=0;
clk=-5;
f1=figure('Position',[1042 718 669 268],'color','k');
f2=figure('Position',[1040 396 669 268],'color','k');
f3=figure('Position',[1042 64 669 268],'color','k');
while 1
    i=i+1;
    
    Vin=randn()*25;
    expConst=0.01;
    VinLowpass=Vin*expConst+(1-expConst)*Vin_Array(end);
    if VinLowpass>5
        VinLowpass=5;
    elseif VinLowpass<-5
        VinLowpass=-5;
    end
    
%     Vin=5*sin((2*pi*NyquistFrequency*(frq/64))*i);
    %Clock
    if mod(i,nClockCycles)==1
        clk=-clk;
        if clk>0 %Only rising edge
            if VinLowpass>0
                Vout=5;
            else
                Vout=-5;        
            end
        end
    end
    
    Vin_Array=circshift(Vin_Array,-1);
    Vout_Array=circshift(Vout_Array,-1);
    Vclock_Array=circshift(Vclock_Array,-1);
    
    Vin_Array(end)=VinLowpass;
    Vout_Array(end)=Vout;
    Vclock_Array(end)=clk;
    
    
    if mod(i,5)==1
       figure(f1)
       cla
        plot(t,Vin_Array,'y-','linewidth',2);hold on
        plot(t,Vclock_Array,'w:','linewidth',1);
        set(gca,'color','k')
        ylim([-5 5])
        set(gca,'ytick',-5:5:5)
        set(gca,'xtick',[])
        set(gca,'GridColor',[1 1 1]*0.8)
        grid on
        
        figure(f2)
        plot(t,Vout_Array,'b-','linewidth',2);
        set(gca,'color','k')
        ylim([-1 1]*5)
        set(gca,'ytick',-5:1:5)
        set(gca,'xtick',[])
        set(gca,'GridColor',[1 1 1]*0.8)
        grid on
        
        figure(f3)
        plot(t,Vclock_Array,'w-','linewidth',2);
        set(gca,'color','k')
        ylim([-1 1]*5)
        set(gca,'ytick',-5:5:5)
        set(gca,'xtick',[])
        set(gca,'GridColor',[1 1 1]*0.8)
        grid on
        
        drawnow
        pause(0.01)
        F1=getframe(f1);
        writeVideo(v1,F1);
        
        F2=getframe(f2);
        writeVideo(v2,F2);
        
        F3=getframe(f3);
        writeVideo(v3,F3);
    end
    
end


close(v1)
close(v2)
close(v3)








