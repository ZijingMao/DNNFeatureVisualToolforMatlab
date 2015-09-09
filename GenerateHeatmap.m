function GenerateHeatmap(target, nontarget, channel, time)

min_val = min(min(target), min(nontarget));
max_val = max(max(target), max(nontarget));
caxis(gca, [min_val, max_val])

tmp = reshape(target', [channel, time]);
imagesc(tmp);
colorbar;
set(gca, 'XTick', [1, 16, 32, 48, 64, 80, 96, 112, 128], ...
'XTickLabel',{'0','0.125','0.25','0.375','0.5','0.625','0.75','0.875','1 (s)'}, 'FontSize', 16);
xlabel('Time (Second)', 'FontSize', 16);
ylabel('Channels', 'FontSize', 16);
grid on;
caxis(gca, [min_val, max_val]);
set(gcf, 'PaperPosition', [0 0 16 8]);
set(gcf, 'PaperSize', [ 16 8]);
saveas(gcf, [pwd, '\Temp images\', 'heatmap_target.png']);

tmp = reshape(nontarget', [channel, time]);
imagesc(tmp);
colorbar;
set(gca, 'XTick', [1, 16, 32, 48, 64, 80, 96, 112, 128], ...
'XTickLabel',{'0','0.125','0.25','0.375','0.5','0.625','0.75','0.875','1 (s)'}, 'FontSize', 16);
xlabel('Time (Second)', 'FontSize', 16);
ylabel('Channels', 'FontSize', 16);
grid on;
caxis(gca, [min_val, max_val]);
set(gcf, 'PaperPosition', [0 0 16 8]);
set(gcf, 'PaperSize', [ 16 8]);
saveas(gcf, [pwd, '\Temp images\', 'heatmap_nontarget.png']);

end