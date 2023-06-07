This code describes the distribution network reconfiguration problem in the form of mathematical optimization. However, the strict mathematical model falls under the category of non-linear and non-convex optimization, which is theoretically an NP-hard problem and lacks an effective solving method. In this regard, second-order cone convex relaxation techniques and linearization methods can be introduced as needed to transform the original optimization model into a form that has a convex feasible region for solving. The hybrid integer second-order cone programming model is shown below:    
1 Objective Function     
Assuming the objective function is chosen to reduce system network losses:     
$$\min\sum\limits_{(ij)\in\Phi_i}r_{ij}i_{ij}^2$$
$$i_{i j}^{2}={\frac{P_{i j}^{2}+Q_{i j}^{2}}{V_{i}^{2}}}$$
2 Constraints    
$$\text{s.t.}$$
$$\sum_{(i j)\in\Phi_{l}}z_{i j}=n_{b}-n_{s}$$
$$z_{i j}\in\{0,1\},\forall\left(i j\right)\in\Phi_{l}$$
$$L_{ij}\leqslant z_i\overline{i}_i^2$$
$$\underline{V}_{i}^{2}\mathrm{\leqslant}U_{i}\mathrm{\leqslant}\overline{V}_{i}^{2}$$
$$\left\|\left[2P_j,2Q_j,L_j-U_i\right]^{\text{T}}\right\|_2\leqslant L_{ij}+U_i$$
$$\sum_{k:(j k)\in\Phi_{l}}P_{j k}=P_{i j}-r_{i j}L_{i j}-P_{j}^{L},\quad|P_{j}^{L}|\geqslant\delta$$  
$$\sum_{k:(j k)\in\Phi_{l}}Q_{j k}=Q_{i j}-x_{i j}L_{i j}-Q_{j}^{L},\quad|Q_{j}^{L}|\geqslant\delta$$ 
$$m_{ij}=(1-z_{ij})\cdot M$$  
$$U_{i}-U_{j}\leqslant m_{i j}+2(r_{i j}P_{i j}+x_{i j}Q_{i j})-(r_{i j}^{2}+x_{i j}^{2})L_{i j}$$  
$$U_{i}-U_{j}\geqslant-m_{i j}+2(r_{i j}P_{i j}+x_{i j}Q_{i j})-(r_{i j}^{2}+x_{i j}^{2})L_{i j}$$ 