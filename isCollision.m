function [ collision ] = isCollision(patch1,patch2)
  if(isempty(polyxpoly(patch1.XData,patch1.YData,...
                       patch2.XData,patch2.YData)))
      collision=0;
  else
      collision=1;
  end
end

