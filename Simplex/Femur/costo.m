function error = costo(params, H)
    x=params(1);
    y=params(2);
    z=params(3);
    rad=params(4);

    di_x = sqrt((x - H(:,1))).^2;
    di_y = sqrt((y - H(:,2))).^2;
    di_z = sqrt((z - H(:,3))).^2;

    vector_di = [(di_x) (di_y) (di_z)];
    vec_norm_di = vecnorm(vector_di, 2, 2);

    error = (1/length(H)) * sum((vec_norm_di(:) - rad).^2);
end

