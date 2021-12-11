#读取数据
#qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path input_file.csv --output-path paired-end-demux.qza --input-format PairedEndFastqManifestPhred33
#echo "读取数据"
#可视化
#qiime demux summarize --i-data paired-end-demux.qza --o-visualization demux.qzv
#echo "可视化"
#去噪并生成Feature表格和代表性序列（barocode 7 primer 17 --p-trunc-len-f/r根据demux.qzv查看）
#nohup qiime dada2 denoise-paired --i-demultiplexed-seqs paired-end-demux.qza --p-trim-left-f 24 --p-trim-left-r 24 --p-trunc-len-f 260 --p-trunc-len-r 260 --o-table table-dada2.qza --o-representative-sequences rep-seqs.qza --p-n-threads 1 --o-denoising-stats denoising-stats.qza &
#echo "去噪"
#Feature表格统计
#qiime feature-table summarize --i-table table-dada2.qza --o-visualization table.qzv --m-sample-metadata-file mapping.txt
#echo "Feature"
#将.qza转化为.biom
#qiime tools export --input-path table-dada2.qza --output-path exported-feature-table
#将.biom转化为.txt
#biom convert -i exported-feature-table/feature-table.biom -o exported-feature-table/feature-table.txt --to-tsv --header-key taxonomy
#代表性序列可视化统计
#qiime feature-table tabulate-seqs --i-data rep-seqs.qza --o-visualization rep-seqs.qzv
#echo "可视化"
#构建进化树（多序列比对）
#qiime alignment mafft --i-sequences rep-seqs.qza --o-alignment aligned-rep-seqs.qza
#echo "多序列比对"
#构建进化树（移除高变区）
#qiime alignment mask --i-alignment aligned-rep-seqs.qza --o-masked-alignment masked-aligned-rep-seqs.qza
#echo "移除高变区"
#构建无根树
#qiime phylogeny fasttree --i-alignment masked-aligned-rep-seqs.qza --o-tree unrooted-tree.qza
#echo "无根树"
#无根树转化为有根树
#qiime phylogeny midpoint-root --i-tree unrooted-tree.qza --o-rooted-tree rooted-tree.qza
#echo "有根树"
#多样性参数（测序深度根据table.qzv）
#qiime diversity core-metrics-phylogenetic --i-phylogeny rooted-tree.qza --i-table table-dada2.qza --p-sampling-depth 1712 --m-metadata-file mapping.txt --output-dir core-metrics-results
#echo "table.qzv"
#alpha多样性指数可视化
#qiime tools export --input-path core-metrics-results/observed_otus_vector.qza --output-path alpha_diversity/observed_otus
#qiime tools export --input-path core-metrics-results/evenness_vector.qza --output-path alpha_diversity/evenness_vetor
#qiime tools export --input-path core-metrics-results/faith_pd_vector.qza --output-path alpha_diversity/faith_pd_vector
#qiime tools export --input-path core-metrics-results/shannon_vector.qza --output-path alpha_diversity/shannon_vector
#echo "alpha多样性指数可视化"
#beta多样性指数可视化
#qiime tools export --input-path core-metrics-results/bray_curtis_distance_matrix.qza --output-path beta_diversity/bray_curtis_distance_matrix
#qiime tools export --input-path core-metrics-results/jaccard_distance_matrix.qza --output-path beta_diversity/jaccard_distance_matrix
#qiime tools export --input-path core-metrics-results/unweighted_unifrac_distance_matrix.qza --output-path beta_diversity/unweighted_unifrac_distance_matrix
#qiime tools export --input-path core-metrics-results/weighted_unifrac_distance_matrix.qza --output-path beta_diversity/weighted_unifrac_distance_matrix
#echo "beta多样性指数可视化"
#稀释曲线绘制（--p-max-depth取table.qzv的中位数数值整数）
#qiime diversity alpha-rarefaction --i-table table-dada2.qza --m-metadata-file mapping.txt --o-visualization alpha_rarefaction_curves.qzv --p-min-depth 10 --p-max-depth 2983
#echo "稀释曲线"
#计算组间多样性指数差异（alpha多样性）
#qiime diversity alpha-group-significance --i-alpha-diversity core-metrics-results/faith_pd_vector.qza --m-metadata-file mapping.txt --o-visualization alpha_diversity/faith-pd-group-significance.qzv
#统计evenness_vector组间差异是否显著
#qiime diversity alpha-group-significance --i-alpha-diversity core-metrics-results/evenness_vector.qza --m-metadata-file mapping.txt --o-visualization alpha_diversity/evenness_vector-group-significance.qzv
#统计shannon_vector组间差异是否显著
#qiime diversity alpha-group-significance --i-alpha-diversity core-metrics-results/shannon_vector.qza --m-metadata-file mapping.txt --o-visualization alpha_diversity/shannon_vector-group-significance.qzv
#统计shannon_vector组间差异是否显著
#qiime diversity alpha-group-significance --i-alpha-diversity core-metrics-results/observed_otus_vector.qza --m-metadata-file mapping.txt --o-visualization alpha_diversity/observed_otus_vector-group-significance.qzv
#echo "alpha多样性指数差异"
#计算组间多样性指数差异（beta多样性）
#qiime diversity beta-group-significance --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza --m-metadata-file mapping.txt --m-metadata-column Treatment --o-visualization beta_diversity/unweighted-unifrac-significance.qzv --p-pairwise
#qiime diversity beta-group-significance --i-distance-matrix core-metrics-results/weighted_unifrac_distance_matrix.qza --m-metadata-file mapping.txt --m-metadata-column Treatment --o-visualization beta_diversity/weighted-unifrac-significance.qzv --p-pairwise
#qiime diversity beta-group-significance --i-distance-matrix core-metrics-results/bray_curtis_distance_matrix.qza --m-metadata-file mapping.txt --m-metadata-column Treatment --o-visualization beta_diversity/bray-curtis-distance-significance.qzv --p-pairwise
#qiime diversity beta-group-significance --i-distance-matrix core-metrics-results/jaccard_distance_matrix.qza --m-metadata-file mapping.txt --m-metadata-column Treatment --o-visualization beta_diversity/jaccard-distance-significance.qzv --p-pairwise
#echo "beta多样性指数差异"
#mv core-metrics-results/bray_curtis_emperor.qzv beta_diversity/
#mv core-metrics-results/unweighted_unifrac_emperor.qzv beta_diversity/
#mv core-metrics-results/weighted_unifrac_emperor.qzv beta_diversity/
#mv core-metrics-results/jaccard_emperor.qzv beta_diversity/
#物种分类注释（silva）
#qiime feature-classifier classify-sklearn --i-classifier /home/foodbio/database/Qiime2/silva-132-99-nb-341F-806R_classifier.qza --i-reads rep-seqs.qza --o-classification taxa/taxonomy_silva.qza
#qiime metadata tabulate --m-input-file taxa/taxonomy_silva.qza --o-visualization taxa/taxonomy_silva.qzv
#echo "物种注释"
#此处可以添加命令过滤环境污染
qiime taxa filter-table --i-table table-dada2.qza --i-taxonomy taxa/taxonomy_silva.qza --p-exclude Patescibacteria --o-filtered-table table.qza
echo 选择性过滤
qiime taxa barplot --i-table table.qza --i-taxonomy taxa/taxonomy_silva.qza --m-metadata-file mapping.txt --o-visualization taxa-bar-plots-silva.qzv
echo "柱状图"
#利用ANCOM进行差异Features/OTUs分析
#ANCOM基于每个样本的特征频率对FeatureTable[Composition]进行操作，但是不能出现零。为了构建组成对象，必须提供一个添加伪计数（一种遗失值插补方法）的FeatureTable[Frequency]对象，这将产生FeatureTable[Composition]对象。
#OTU添加假count
qiime composition add-pseudocount --i-table table.qza --o-composition-table comp-table.qza
#采用ancom，按Group分组进行差异统计
qiime composition ancom --i-table comp-table.qza --m-metadata-file mapping.txt --m-metadata-column Treatment --o-visualization ancom-group.qzv
#差异分类学级别分析：对在特定的分类学层次上执行差异丰度检验，此处以按门水平合并再统计差异（其他的水平将--p-level 2修改，2代表门、3代表纲、4代表目、5代表科、6代表属。一般可做门和属。）
#按门水平进行合并，统计各门、属的总reads
qiime taxa collapse --i-table table.qza --i-taxonomy taxa/taxonomy_silva.qza --p-level 2 --o-collapsed-table table-2.qza
qiime taxa collapse --i-table table.qza --i-taxonomy taxa/taxonomy_silva.qza --p-level 6 --o-collapsed-table table-6.qza
#同理去除零数据
qiime composition add-pseudocount --i-table table-2.qza --o-composition-table comp-table-2.qza
qiime composition add-pseudocount --i-table table-6.qza --o-composition-table comp-table-6.qza
#在门、属水平按Group分析
qiime composition ancom --i-table comp-table-2.qza --m-metadata-file mapping.txt --m-metadata-column Treatment --o-visualization 2-ancom-Group.qzv
qiime composition ancom --i-table comp-table-6.qza --m-metadata-file mapping.txt --m-metadata-column Treatment --o-visualization 6-ancom-Group.qzv
echo "门、属分析"
