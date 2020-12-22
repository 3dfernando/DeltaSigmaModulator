clear; clc; close all;

VrefPlus=5;
VrefMinus=-5;

VDAC=VrefPlus;
Vintegrator1=0;
Vintegrator2=0;
% expConst1=0.00001;
% expConst2=0.000001;

clockCycles=20; %integrator simulation

Vin=0;
nBits=6;


v=VideoWriter('SigmaDelta_CounterSweep.avi');
v.Quality=95;
v.FrameRate=20;
open(v)

%%
nCycles=200;
Vin_Array=zeros(nCycles*clockCycles,1);
Vintegrator_Array=zeros(nCycles*clockCycles,1);
VDAC_Array=zeros(nCycles*clockCycles,1);
Clock_Array=zeros(nCycles*clockCycles,1);
Sigma_Array=ones(nCycles*clockCycles,1)*(2^(nBits-1));
t=1:length(Vintegrator_Array);

NyquistFrequency=1/(2*(2^nBits)*clockCycles);

i=0;
SigmaBuffer=0;
SigmaValue=2^(nBits-1);

SigmaClockTimes=[];
SigmaCounts=[];

nClockCycles=0;
figure('Position',[882 99 1024 892],'color','k');
frq=1.2;
while 1
    i=i+1;
    
    %Vin=5*sin(2*pi*0.000025*i) + 0.5*sin((2*pi*NyquistFrequency*1.5)*i);
    Vin=5*sin((2*pi*NyquistFrequency*(frq/64))*i);
    %frq=frq+0.0025;
    
    VSum=Vin-VDAC;
    
    %Normal integrator
%     Vintegrator1=Vintegrator1*(1-expConst1)+expConst1*VSum;    
%     Vintegrator2=Vintegrator2*(1-expConst2)+expConst2*VSum;
    Vintegrator2=Vintegrator2+VSum;
    
    if mod(i,clockCycles)==1
        if Vintegrator2>0
            VDAC=VrefPlus;
        else
            VDAC=VrefMinus;
        end  
        %SigmaBuffer=SigmaBuffer+VDAC/(2^nBits);
        SigmaBuffer=SigmaBuffer+(VDAC==5);
        if (mod(nClockCycles,2^nBits)==1 && nClockCycles>(2^(nBits-1)))
            SigmaValue=SigmaBuffer;
        	SigmaBuffer=0;
            SigmaClockTimes=[SigmaClockTimes i];
            SigmaCounts=[SigmaCounts SigmaValue];
        end
        Clock=1;
        nClockCycles=nClockCycles+1;
    elseif mod(i,clockCycles)==floor(clockCycles/2)
        Clock=0;    
    end
    
    Vin_Array=circshift(Vin_Array,-1);
    VDAC_Array=circshift(VDAC_Array,-1);
    Vintegrator_Array=circshift(Vintegrator_Array,-1);
    Clock_Array=circshift(Clock_Array,-1);
    Sigma_Array=circshift(Sigma_Array,-1);
        
    Vin_Array(end)=Vin;
    VDAC_Array(end)=VDAC;
    Vintegrator_Array(end)=Vintegrator2;
    Clock_Array(end)=Clock;
    Sigma_Array(end)=SigmaValue;
    
    
    if mod(i,round(nCycles*clockCycles/100))==1
       
        subplot(4,1,1)
        cla
        plot(t,VDAC_Array,'w-','linewidth',2);
        set(gca,'color','k')
        ylim([-5 5])
        
        subplot(4,1,2)
        cla
        plot(t,Vintegrator_Array,'b-','linewidth',2);
        set(gca,'color','k')
        ylim([-1 1]*200)
        
        subplot(4,1,3)
        cla
        plot(t,Vin_Array,'y-','linewidth',2);
        set(gca,'color','k')
        ylim([-5 5])
        set(gca,'ytick',-5:1:5)
        set(gca,'xtick',[])
        set(gca,'GridColor',[1 1 1]*0.8)
        grid on
        
        subplot(4,1,4)
        cla
        plot(t,5*((Sigma_Array-(2^(nBits-1)))/(2^(nBits-1))),'y-','linewidth',2);
        set(gca,'color','k')
        ylim([-5 5])
        set(gca,'ytick',-5:1:5)
        set(gca,'xtick',[])
        set(gca,'GridColor',[1 1 1]*0.8)
        grid on
        
        %Plots rectangles
        for r=length(SigmaClockTimes):-1:1
            if r==length(SigmaClockTimes)
                %First rectangle
                rectx=[SigmaClockTimes(r) SigmaClockTimes(r) i i SigmaClockTimes(r)];
                recty=[5 -5 -5 5 5];    
                rectx=(rectx-i)+length(t);            
                plotRect=1;
                p(r)=patch(rectx,recty,[1 1 1]*0.8,'edgecolor','none');
                tx(r)=text(rectx(1)-45,0,[num2str(SigmaCounts(r)) ' counts'],'color','w','FontName','Arial Bold','FontSize',18,'HorizontalAlignment','center');
                set(tx(r),'Rotation',90);
            else
                %All other rectangles
                currTime=SigmaClockTimes(r);
                prevTime=SigmaClockTimes(r+1);
                
                plotRect=1;
                if currTime<(i-length(t))
                    %Nothing to do except if prevTime is within bounds
                    if prevTime>(i-length(t))
                        currTime=i-length(t);
                    else
                        plotRect=0;
                    end
                end
                if plotRect
                    rectx=[currTime currTime prevTime prevTime currTime];
                    recty=[5 -5 -5 5 5];    
                    rectx=(rectx-i)+length(t);            
                    p(r)=patch(rectx,recty,[1 1 1]*0.8,'edgecolor','none');                     
                    tx(r)=text(rectx(1)-45,0,[num2str(SigmaCounts(r)) ' counts'],'color','w','FontName','Arial Bold','FontSize',18,'HorizontalAlignment','center');
                    set(tx(r),'Rotation',90);
                end
            end
            
            if plotRect
                if mod(r,2)==0
                    p(r).FaceAlpha=0.2;
                else
                    p(r).FaceAlpha=0.4;
                end
            end
        end
               
        %Plots current count
        txc=text(length(t)+45,0,[num2str(SigmaBuffer) ' counts'],'color','w','FontName','Arial Bold','FontSize',18,'HorizontalAlignment','center');
        set(txc,'Rotation',90);
        
        
        drawnow
        pause(0.01)
        F=getframe(gcf);
        writeVideo(v,F);
    end
    
end


close(v)








