function [mse] = fn_151029_MSE(sample,ref)
    edge = 0;
    diff = sample - ref; 
    sq = diff.^2;
    sumVal = sum(sq(edge+1:end-edge));
    mse = sumVal/(size(sample,1)-2*edge);
end