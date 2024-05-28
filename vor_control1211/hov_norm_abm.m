function abw = hov_norm_abm(ab1,ab2,wab)

if ab1>ab2
    abw = (ab1-ab2)^wab;
else
    abw = -(ab2-ab1)^wab;
end