function classification =  classify_grid(B,x)
pihat = mnrval(B,x);
[~,classification] = max(pihat);
end


