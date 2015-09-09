function [ hidden_sel ] = rand_threshold( hidden_sel )
%RAND_THRESHOLD 

[row, col] = size(hidden_sel);
for idx1 = 1:row
    for idx2 = 1:col
        hidden_sel = single(hidden_sel >= rand(1));
    end
end

end

