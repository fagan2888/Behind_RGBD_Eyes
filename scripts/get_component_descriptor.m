function [ descriptor ] = get_component_descriptor( dimg, rgbimg, indices, cam_params )
%GET_COMPONENTS_DESCRIPTOR Summary of this function goes here
%   Detailed explanation goes here

    % descriptor -> component location and colour histogram
    descriptor = cell(1,2);
    
    size_dimg = size(dimg);
    area_dimg = numel(dimg);
    
    pc = get_point_cloud(dimg(indices),size_dimg,indices',cam_params);
    
    % descriptor{1} = [mean(X) mean(Y) mean(Z)]
    descriptor{1} = mean(pc.Location,1);
    P = [pc.Location(:,1)';pc.Location(:,2)';pc.Location(:,3)'];
    
    niu = cam_params.Krgb * [cam_params.R cam_params.T] * [P;ones(1,size(P,2))];

    % x = miu1 / miu3    y = miu2 / miu3
    x2=round(niu(1,:)./niu(3,:)); 

    y2=round(niu(2,:)./niu(3,:));
    
    component_rgb=zeros(size(P,2),3);
    indsclean=find((x2>=1)&(x2<=size_dimg(2)+1)&(y2>=1)&(y2<=size_dimg(1)+1));
    indscolor=sub2ind(size_dimg,y2(indsclean),x2(indsclean));
    rgb_img_aux=reshape(rgbimg,[area_dimg 3]);
    
    component_rgb(indsclean,:)=rgb_img_aux(indscolor,:)/255;
    component_hsv = rgb2hsv(component_rgb);
    h_histogram = histcounts(component_hsv(:,1),10);
    
    %only h histogram needed
    %s_histogram = histcounts(component_hsv(:,2),10);

    descriptor{2} = h_histogram;
    
%     pc=pointCloud(P', 'color',uint8(component_rgb*255));
%     figure(7); showPointCloud(pc);
%     title('Component rgb');

    
end