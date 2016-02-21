function classification =  classify_grid(B,x)
num_features = size(x);
num_features = num_features(2);
pihat = mnrval(B,x(:,1:num_features - 1));
[~,classification] = max(pihat);
end


