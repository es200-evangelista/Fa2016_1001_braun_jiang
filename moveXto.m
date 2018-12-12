function moveXto(patch,x)
    patch.XData = patch.XData - mean(patch.XData) + x;
end

