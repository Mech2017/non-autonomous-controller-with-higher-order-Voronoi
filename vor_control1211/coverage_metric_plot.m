time = 0:100;
H_1 = [];
H_2 = [];
H_3 = [];
H_4 = [];
figure2 = figure;
plot(time, H_1, 'LineWidth',1.5);hold on
%plot(time, H_2, 'LineWidth',1.5)
%plot(time, H_3, 'LineWidth',1.5);hold on
%plot(time, H_4, 'LineWidth',1.5)
grid on;
bx = gca;
bx.GridLineStyle = '--';
xlabel('Time [Sec]','FontSize', 11, 'FontWeight', 'bold');
ylabel('Coverage Metrics, H','FontSize', 11, 'FontWeight', 'bold');
legend('without avoidance control','with avoidance control','Location','southeast');
%exportgraphics(figure2,'D:\Research_2nd_Voronoi_2024_4_17\Figure\time_varying_coverage_2.png','Resolution',600)
%exportgraphics(figure2,'D:\Research_2nd_Voronoi_2024_4_17\Figure\time_invarient_coverage_2.png','Resolution',600)
exportgraphics(figure2,'D:\Research_2nd_Voronoi_2024_4_17\Figure\time_varying_coverage_3.png','Resolution',600)