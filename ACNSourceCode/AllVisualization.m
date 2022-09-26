exp_id_list = {'NOBJ1','Ball2','Block2','Tree2'};
cmap = viridis;
cmap_string = 'viridis';

color_order = [
    [166,206,227],
    [31,120,180],
    [178,223,138],
    [51,160,44],
    [251,154,153],
    [227,26,28],
    [253,191,111],
    [255,127,0],
    [202,178,214],
    [106,61,154],
    [255,255,153],
    [177,89,40]
]/255;

for REP = 1:length(exp_id_list)
    exp_id = exp_id_list{REP};
    load(fullfile('Data',exp_id,'All_in_One.mat'));

    n_large = expanded_array(output.n,vox_all);
    e_large = expanded_array(output.e,vox_all);
    sz = size(vox_all,1);
    [X,Y,Z] = meshgrid(1:sz,1:sz,1:sz);

    filament_smooth = smooth3(vox_all,'gaussian',5);
    if REP > 1
        object_smooth = smooth3(imdilate(vox_obj,strel('sphere',3)),'gaussian',5);
        SURF_OBJ = isosurface(X,Y,Z,object_smooth,0,'noshare');
    elseif REP == 1
        object_smooth = [];
        SURF_OBJ = [];
    end
        
    SURF = isosurface(X,Y,Z,filament_smooth,0.75,'noshare');    
    SURF_LIST = cell(12,1); % separate filaments
    for k = 1:12
        tmp = smooth3(imdilate(vox_list{k},strel('sphere',3)),'gaussian',5);
        SURF_LIST{k} = isosurface(X,Y,Z,tmp,0.75,'noshare');
    end
    
    % PLOT: separated filaments
    close all
    f = SetFigure(30,40);
    view([-2 -1 0.5])
    lighting gouraud
    camlight

    for k = 1:12
        patch('Faces',SURF_LIST{k}.faces,'Vertices',SURF_LIST{k}.vertices,'EdgeColor','none','FaceColor',color_order(k,:),'FaceAlpha',0.7);
        hold on
    end
    %
    if REP > 1
        hold on
        patch('Faces',SURF_OBJ.faces,'Vertices',SURF_OBJ.vertices,'FaceAlpha',0.5,'EdgeColor','none','FaceColor',[1 1 1]*0.8);
    end
    axis equal
    axis off
    print(f,sprintf('Outputs/MeshPlot_Separate_%s',exp_id),'-dpng','-r300');

    DATA_SURF_N = interp3(X,Y,Z,single(n_large),SURF.vertices(:,1),SURF.vertices(:,2),SURF.vertices(:,3));
    DATA_SURF_E = interp3(X,Y,Z,single(e_large),SURF.vertices(:,1),SURF.vertices(:,2),SURF.vertices(:,3));
    DATA_SURF_A = interp3(X,Y,Z,single(e_large)/max(e_large(:)),SURF.vertices(:,1),SURF.vertices(:,2),SURF.vertices(:,3));    
    
    % PLOT: number density
    close all
    f = SetFigure(30,40);
    view([-2 -1 0.5])
    camlight
    h = patch('Faces',SURF.faces,'Vertices',SURF.vertices,'EdgeColor','none','FaceColor','interp','FaceVertexCData',DATA_SURF_N,'FaceVertexAlphaData',DATA_SURF_A);
    h.AlphaDataMapping = 'scaled';
    h.EdgeAlpha = 'interp';
    if REP > 1 % with objects
        hold on
        patch('Faces',SURF_OBJ.faces,'Vertices',SURF_OBJ.vertices,'FaceAlpha',0.5,'EdgeColor','none','FaceColor',[1 1 1]*0.8);
    end

    colormap(cmap);
    colorbar
    caxis([0 12])
    axis equal
    axis off

    print(f,sprintf('Outputs/MeshPlot_%s_n_%s',exp_id,cmap_string),'-dpng','-r300')
    
    % PLOT: entanglement
    close all
    f = SetFigure(30,40);
    view([-2 -1 0.5])
    camlight
    h = patch('Faces',SURF.faces,'Vertices',SURF.vertices,'EdgeColor','none','FaceColor','interp','FaceVertexCData',DATA_SURF_E,'FaceVertexAlphaData',DATA_SURF_A);
    h.AlphaDataMapping = 'direct';
    h.EdgeAlpha = 'interp';

    if REP > 1 % with objects
        hold on
        patch('Faces',SURF_OBJ.faces,'Vertices',SURF_OBJ.vertices,'FaceAlpha',0.5,'EdgeColor','none','FaceColor',[1 1 1]*0.8);
    end

    colormap(cmap);
    caxis([0 4])
    colorbar
    axis equal
    axis off

    print(f,sprintf('Outputs/MeshPlot_%s_e_%s',exp_id,cmap_string),'-dpng','-r300')
    
    % PLOT: contacts

    closed = imclose(vox_all,strel('sphere',2));
    cts = closed&~vox_all;
    cts = bwmorph3(cts,'majority');
    
    SURF_CTS1 = isosurface(X,Y,Z,cts,0);

    close all
    f = SetFigure(30,40);
    view([-2 -1 0.5])
    lighting gouraud
    camlight

    for k = 1:12
        patch('Faces',SURF_LIST{k}.faces,'Vertices',SURF_LIST{k}.vertices,'EdgeColor','none','FaceColor',color_order(k,:),'FaceAlpha',0.1);
        hold on
    end
    
    if REP > 1
        %     dilated_obj = imdilate(vox_obj,strel('sphere',1));
        dilated_fil = imdilate(vox_all,strel('sphere',2));
        SURF_CTS = isosurface(X,Y,Z,vox_obj&dilated_fil,0);

        patch('Faces',SURF_OBJ.faces,'Vertices',SURF_OBJ.vertices,'FaceAlpha',0.1,'EdgeColor','none','FaceColor',[1 1 1]*0.8);
        patch('Faces',SURF_CTS.faces,'Vertices',SURF_CTS.vertices,'FaceAlpha',1,'EdgeColor','none','FaceColor',[1 0 0]);
    end
    patch('Faces',SURF_CTS1.faces,'Vertices',SURF_CTS1.vertices,'FaceAlpha',1,'EdgeColor','none','FaceColor',[0 0 1]);

    axis equal
    axis off
    print(f,sprintf('Outputs/MeshPlot_Separate_Contact_%s',exp_id),'-dpng','-r300')

end

function expanded = expanded_array(fd,tg)
% for cube only now
size_target = size(tg);
size_field = size(fd);
a = size_target(1);
l = size_field(1);


margin = (a - floor(a/l)*40)/2;
expansion_ratio = floor(a/l);

block_unit = ones(expansion_ratio*[1 1 1]);
expanded = zeros(size(tg));

%
for i = 1:40
    for j = 1:40
        for k = 1:40
            x1 = 1+margin+(i-1)*expansion_ratio;
            x2 = x1 + expansion_ratio - 1;
            y1 = 1+margin+(j-1)*expansion_ratio;
            y2 = y1 + expansion_ratio - 1;
            z1 = 1+margin+(k-1)*expansion_ratio;
            z2 = z1 + expansion_ratio - 1;

            expanded(x1:x2,y1:y2,z1:z2) = fd(i,j,k)*block_unit;
        end
    end
end
end

function f = SetFigure(m,n)
f = figure;
myPaperSize = [m n];
lowerLeft = [0 0];

set(f,'PaperUnits','centimeters');
set(f,'PaperPositionMode','manual');
set(f,'PaperSize',myPaperSize);
set(f,'Units','centimeters');
set(f,'Position',[lowerLeft myPaperSize]);
set(f,'PaperPosition',[lowerLeft myPaperSize]);
end