function ArrowLines = arrow(pos, dir, sz)
%% draws an arrow - taken from Singleton Task

startX = pos(1);
startY = pos(2);
endX = pos(1) + dir*sz;
endY = pos(2);


FirstLine = [startX,  endX ; startY, endY];
SecondLine = [startX + (endX-startX)/2 , endX ;startY + (endX-startX)/2 , endY];
ThirdLine = [startX + (endX-startX)/2 , endX ;startY - (endX-startX)/2 , endY];

ArrowLines = [FirstLine, SecondLine, ThirdLine];