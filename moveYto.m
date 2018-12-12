function moveYto(patch,y)
    patch.YData = patch.YData - mean(patch.YData) + y;
end

