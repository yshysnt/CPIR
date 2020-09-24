function [mappedX, mapping] = laplacian_eigen(G, no_dims, eig_impl,largest_conn_comp)

    if ~exist('no_dims', 'var')
        no_dims = 2;
    end

    if ~exist('eig_impl', 'var')
        eig_impl = 'Matlab';
    end
    
    % Only embed largest connected component of the neighborhood graph
    if largest_conn_comp
        blocks = components(G)';
        count = zeros(1, max(blocks));
        for i=1:max(blocks)
            count(i) = length(find(blocks == i));
        end
        [count, block_no] = max(count);
        conn_comp = find(blocks == block_no);    
        G = G(conn_comp, conn_comp);
    end
    
    % Compute weights (W = G)
    disp('Computing weight matrices...');
    
    % Construct diagonal weight matrix
    D = diag(sum(G, 2));
    
    % Compute Laplacian
    L = D - G;
    L(isnan(L)) = 0; D(isnan(D)) = 0;
	L(isinf(L)) = 0; D(isinf(D)) = 0;
    
    % Construct eigenmaps (solve Ly = lambda*Dy)
    disp('Constructing Eigenmaps...');
    tol = 0;
    % prevent ill-condition
    L2=L+D;
    
    if strcmp(eig_impl, 'JDQR')
        options.Disp = 0;
        options.LSolver = 'bicgstab';
        [mappedX, lambda] = jdqz(L2, D, no_dims + 1, tol, options);			% only need bottom (no_dims + 1) eigenvectors
    else
        options.disp = 0;
        options.isreal = 1;
        options.issym = 1;
        [mappedX, lambda] = eigs(L2, D, no_dims + 1, tol, options);			% only need bottom (no_dims + 1) eigenvectors
    end
    lambda=lambda-1;
    % Sort eigenvectors in ascending order
    lambda = diag(lambda);
    [lambda, ind] = sort(lambda, 'ascend');
    lambda = lambda(2:no_dims + 1);
    
    % Final embedding
	mappedX = mappedX(:,ind(2:no_dims + 1));

    % Store data for out-of-sample extension
    mapping.K = G;
    mapping.vec = mappedX;
    mapping.val = lambda;
    if largest_conn_comp
        mapping.conn_comp = conn_comp;
    end
end
    
    