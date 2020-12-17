function img_3d = MgThorBadPixelCorr(img_3d)
% img_3d = MgThorBadPixelCorr(img_3d)
% correct Thor detector bad pixels

pos=importdata('thor_bad_pixels.txt');

for idx=1:size(pos,1)
    row=pos(idx,1);
    col=pos(idx,2);
    img_3d(row,col,:)=1/4*(img_3d(row+1,col,:)+img_3d(row,col+1,:)+img_3d(row-1,col,:)+img_3d(row,col-1,:));
end

% correction  for two 3x3 dead pixel blocks
for row=86:88
    for col=877:879
        img_3d(row,col,:)=(col-876)*img_3d(row,880,:)+...
            (880-col)*img_3d(row,876,:)+(row-85)*img_3d(89,col,:)+...
            +(89-row)*img_3d(85,col,:);
        img_3d(row,col,:)=img_3d(row,col,:)/8;
    end
end

for row=361:363
    for col=351:353
        img_3d(row,col,:)=(col-350)*img_3d(row,354,:)+...
            (354-col)*img_3d(row,350,:)+(row-360)*img_3d(364,col,:)+...
            +(364-row)*img_3d(360,col,:);
        img_3d(row,col,:)=img_3d(row,col,:)/8;
    end
end

end

