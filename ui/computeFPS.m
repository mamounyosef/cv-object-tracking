function fpsStr = computeFPS(elapsed)
    if elapsed > 0
        fpsStr = sprintf('FPS: %.1f', 1/elapsed);
    else
        fpsStr = 'FPS: --';
    end
end
