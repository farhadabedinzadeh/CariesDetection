% Chapter 3: Teeth Segmentation
% 3.1 Introduction
clc
close all;
clear all
format compact
warning off

% 3.2 Pre-Processing
% 3.2.1 Image Cleanup
im1=imread('1.tif');
im1=im1(:,:,1);
im1bw=im1>150;
im1L = bwlabel(im1bw);
sel_L= im1L==im1L(end:end);
im1_out=im1;
im1_out(sel_L)=0;
figure
subplot(1,2,1),imshow(im1),title('Figure 3.1');
subplot(1,2,2),imshow(im1_out)
pause(.1)

% 3.2.2 Image Enhancement
im2=imread('2.tif');
im2=im2(:,:,1);
im2bw=im2>200;
im2L = bwlabel(im2bw);
sel_L=find(im2L==im2L(1:1));
im2_out=im2;
im2_out(sel_L)=0;
im2_out=medfilt2(im2_out);
im2_out=histeq(im2_out);
[counts1,binLocations1]=imhist(im2,64);
[counts2,binLocations2]=imhist(im2_out,64);
figure
subplot(2,2,1),imshow(im2),title('Figure 3.2');
subplot(2,2,2),imshow(im2_out)
subplot(2,2,[3,4]),plot(counts1),hold on,plot(counts2)
pause(.1)

% 3.3 Thresholding
% 3.3.1 Iterative Thresholding
% 3.3.2 Adaptive Thresholding
im3=imread('3.tif');
im3=im3(:,:,1);
im3_T1 = (im3>.4*255);
im3_T2 = (im3>255*graythresh(imadjust(im3))/.6);
im3_T3 = (im3>(.6*.4*255 + .4*255*graythresh(imadjust(im3))/.6 ));
figure
subplot(2,2,1),imshow(im3),title('Figure 3.3');
subplot(2,2,2),imshow(im3_T1)
subplot(2,2,3),imshow(im3_T2)
subplot(2,2,4),imshow(im3_T3)
pause(.1)

% 3.4 Tooth Separation
% 3.4.1 Integral Projection
im4=imread('4.tif');
im4=im4(:,:,1);
im4_out=medfilt2(im4);
im4_out=histeq(im4_out);
im4_out=mean(im4_out);
figure
subplot(1,2,1),imshow(im4),title('Figure 3.4');
subplot(1,2,2),plot(im4_out)
pause(.1)

% 3.4.2 Line Selection
im5=imread('5.tif');
im5=im5(:,:,1);
im5_out=medfilt2(im5);
im5_out=histeq(im5_out);
im5_T = (im5>255*graythresh(imadjust(im5)));
for i=-20:.25:20
    im5_rot=imrotate(im5_T,i);
    im5_integ=mean(im5_rot);
    [pks,locs]=findpeaks(-im5_integ,'MinPeakDistance',100);
    im5_RGB=imread('5.tif');
    im5_RGB=im5_RGB(:,:,1);
    im5_RGB=imrotate(im5_RGB,i);
    im5_RGB(:,locs,1)=255;
    im5_RGB(:,locs,2)=255;
    im5_RGB(:,locs,3)=0;
    
end

im5_rot=imrotate(im5_T,0);
im5_integ=mean(im5_rot);
[pks,locs]=findpeaks(-im5_integ,'MinPeakDistance',150);
im5_RGB=imread('5.tif');
im5_RGB=im5_RGB(:,:,1:3);
for k=1:3
    im5_RGB(:,locs(2:end-1)+k,1)=255;
    im5_RGB(:,locs(2:end-1)+k,2)=255;
    im5_RGB(:,locs(2:end-1)+k,3)=0;
end
figure
imshow(im5_RGB),title('Figure 3.7');
pause(.1)

% Chapter 4: Tooth Boundary Detection
% 4.1 Introduction
% 4.2 Top and Bottom Hat Transformations
im6=imread('6.tif');
im6=im6(:,:,1);
se = strel('disk',10);
tophatFiltered = imtophat(im6,se);
bothatFiltered = imbothat(im6,se);
im6_out=(im6+tophatFiltered)-bothatFiltered;
figure
subplot(2,1,1),imshow(im6),title('Figure 4.1');
subplot(2,1,2),imshow(im6_out)
pause(.1)

% 4.3 Boundary Detection
im7=imread('7.tif');
im7=im7(:,:,1);
im7_out=im7>64;
figure
subplot(2,1,1),imshow(im7),title('Figure 4.2');
subplot(2,1,2),imshow(im7_out)
pause(.1)

for n=8
    im8=imread([num2str(n) '.tif']);
    im8=im8(:,:,1);
    se = strel('disk',10);
    tophatFiltered = imtophat(im8,se);
    bothatFiltered = imbothat(im8,se);
    im8=(im8+tophatFiltered)-bothatFiltered;
    mask1=0*im8;
    mask1(150:end-150,100:end-100)=1;
    im8_out = activecontour(im8,mask1);
    ed_im8=edge(im8_out);
    se = strel('disk',1);
    ed_im8=imdilate(ed_im8,se);
    im8_out=uint8(~ed_im8).*im8;
    im8_out2=imread([num2str(n) '.tif']);
    im8_out2=im8_out2(:,:,1:3);
    im8_out2(:,:,1)=255*uint8(ed_im8)+im8;
    im8_out2(:,:,2)=255*uint8(ed_im8)+im8;
    im8_out2(:,:,3)=0*uint8(ed_im8)+im8;
    figure
    subplot(1,2,1),imshow(im8),title('Figure 4.3');
    subplot(1,2,2),imshow(im8_out2)
end
pause(.1)

% 4.4 Search Space Refinement
% 4.4.1 Centre Elimination
for n=8
    im8=imread([num2str(n) '.tif']);
    im8=im8(:,:,1);
    se = strel('disk',30);
    tophatFiltered = imtophat(im8,se);
    bothatFiltered = imbothat(im8,se);
    im8=(im8+tophatFiltered)-bothatFiltered;
    mask1=0*im8;
    mask1(150:end-150,100:end-100)=1;
    im8_out = activecontour(im8,mask1);
    s  = regionprops(im8_out, 'centroid');
    centroids = cat(1, s.Centroid);
    im8(round(centroids(:,1)),:)=255;
    im8(:,round(centroids(:,2)))=255;
    figure
    imshow(im8),title('Figure 4.4');
end
pause(.1)

% 4.4.2 Boundary Dilation
for n=8
    im8=imread([num2str(n) '.tif']);
    im8=im8(:,:,1);
    se = strel('disk',10);
    tophatFiltered = imtophat(im8,se);
    bothatFiltered = imbothat(im8,se);
    im8=(im8+tophatFiltered)-bothatFiltered;
    mask1=0*im8;
    mask1(150:end-150,100:end-100)=1;
    im8_out = activecontour(im8,mask1);
    ed_im8=edge(im8_out);
    se = strel('disk',8);
    ed_im8=imdilate(ed_im8,se);
    im8_out=uint8(~ed_im8).*im8;
    im8_out2=imread([num2str(n) '.tif']);
    im8_out2=im8_out2(:,:,1:3);
    im8_out2(:,:,1)=255*uint8(ed_im8)+im8;
    im8_out2(:,:,2)=255*uint8(ed_im8)+im8;
    im8_out2(:,:,3)=0*uint8(ed_im8)+im8;
    figure
    subplot(1,2,1),imshow(im8),title('Figure 4.5');
    subplot(1,2,2),imshow(im8_out2)
end
pause(.1)

% Chapter 5: Dental Caries Detection
% 5.1 Introduction
% 5.2 Blob Detection
for n=8
    im8=imread([num2str(n) '.tif']);
    im8=im8(:,:,1);
    LoG=[0 0  1  0 0
        0  1  2  1 0
        1  2 -16 2 1
        0  1  2  1 0
        0  0  1  0 0];
    
    im8_out = imfilter(im8,LoG);
    mask1=0*im8;
    mask1(150:end-150,100:end-100)=1;
    im8_ac = activecontour(im8,mask1);
    [centers, radii, metric] = imfindcircles(im8_out,[3 20]);
    figure
    imshow(im8),title('Figure 5.1');
    centersStrong5=[];
    radiiStrong5=[];
    metricStrong5=[];
    for l=1:size(centers,1)
        if im8_ac(round(centers(l,2)),round(centers(l,1)))==1
            centersStrong5=[centersStrong5;centers(l,:)];
            radiiStrong5=[radiiStrong5 radii(l)];
            metricStrong5=[metricStrong5 metric(l)];
        end
    end
    viscircles(centersStrong5, 2*radiiStrong5,'EdgeColor','r');
    
end
pause(.1)

im9=imread('9.tif');
im9=im9(:,:,1:3);
im9_R=im9(:,:,1);
im9_G=im9(:,:,2);
im9_B=im9(:,:,3);

im9_out=0*im9_R;
for i=1:size(im9,1)
    for j=1:size(im9,2)
        if im9_R(i,j)>150 && im9_G(i,j)<150 && im9_B(i,j)<150
            im9_out(i,j)=255;
        end
    end
end
figure
subplot(2,1,1),imshow(im9),title('Figure 5.3');
subplot(2,1,2),imshow(im9_out)
pause(.1)

% 5.3 Caries Analysis
% 5.3.1 Region of Interest Generation
% 5.3.2 Cluster Analysis
im8=imread('8.tif');
im8=im8(:,:,1);
LoG=[0 0  1  0 0
    0  1  2  1 0
    1  2 -16 2 1
    0  1  2  1 0
    0  0  1  0 0];
im8_out = imfilter(im8,LoG);
[centers, radii, metric] = imfindcircles(im8_out,[3 15]);
centersStrong5=[];
radiiStrong5=[];
metricStrong5=[];
for l=1:size(centers,1)
    if im8_ac(round(centers(l,2)),round(centers(l,1)))==1
        centersStrong5=[centersStrong5;centers(l,:)];
        radiiStrong5=[radiiStrong5 radii(l)];
        metricStrong5=[metricStrong5 metric(l)];
    end
end
Caries_cent=[];
for i=1:size(centersStrong5,1)
    
    Sel_cent=fliplr(round(centersStrong5(i,:)));
    Sel_radi=(round(radiiStrong5(i)));
    
    conn8 = im8_out([Sel_cent(1)-1 Sel_cent(2)-1
        Sel_cent(1)-0 Sel_cent(2)-1
        Sel_cent(1)-1 Sel_cent(2)-0
        Sel_cent(1)-0 Sel_cent(2)+1
        Sel_cent(1)+1 Sel_cent(2)-1
        Sel_cent(1)-1 Sel_cent(2)+1
        Sel_cent(1)+1 Sel_cent(2)+0
        Sel_cent(1)+1 Sel_cent(2)+1]);
    
    Tmax=numel(nonzeros(mean(im8)));
    Pmax=.15;
    Tvar=1.5;
    Pcalc=mean2(conn8)-mean(im8_out(Sel_cent));
    Emax=Tmax-(Tvar*(Pmax-Pcalc))/Tvar;
    Evar=.58;
    H=Emax-(Evar*(Tmax-Tvar))/Tvar;
    
    Gx = mean2([-3*im8_out(Sel_cent(1)-1,Sel_cent(2)-1)
        +3*im8_out(Sel_cent(1)+1,Sel_cent(2)-1)
        -10*im8_out(Sel_cent(1)-1,Sel_cent(2)+0)
        +10*im8_out(Sel_cent(1)+0,Sel_cent(2)+1)
        -3*im8_out(Sel_cent(1)-1,Sel_cent(2)+1)
        +3*im8_out(Sel_cent(1)+1,Sel_cent(2)+1)]);
    Gy = mean2([-3*im8_out(Sel_cent(1)-1,Sel_cent(2)-1)
        +10*im8_out(Sel_cent(1)-1,Sel_cent(2)-0)
        -3*im8_out(Sel_cent(1)-1,Sel_cent(2)+1)
        +3*im8_out(Sel_cent(1)+1,Sel_cent(2)-1)
        +10*im8_out(Sel_cent(1)+1,Sel_cent(2)+0)
        +3*im8_out(Sel_cent(1)+1,Sel_cent(2)+1)]);
    G=abs(Gx)+abs(Gy);
    
    % caries detection
    if (H+G)>0
        Caries_cent=[Caries_cent;Sel_cent H+G Sel_radi];
    end
    
end

% caries diagnosis:
imshow(im8);title('caries diagnosed')
centersStrong_diag=fliplr(Caries_cent(:,1:2));
radiiStrong_diag=2*Caries_cent(:,end);
viscircles(centersStrong_diag, radiiStrong_diag,'EdgeColor','r');

exportgraphics(gca,'final2.png','ContentType','image','Resolution',1080)
