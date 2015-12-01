Varscan_multiple
==============
Background
--------------
### Varscan
Coverage-based methods for determining insertions and deletions have recently been developed from Illumina reads aligned to a reference genome. One such software package is Varscan, which uses an mpileup file and a non-overlapping window approach to estimate windows having a higher/lower coverage in one population when compared to another. The Varscan software package allows you to provide it with a whole genome coverage ratio to normalize for differences in coverage across the genome using the --data-ratio option. To obtain these coverage estimates, I use the CollectWgsMetrics tool within Picard. The product of the copynumber and copyCaller combined pipeline (with a threshold of 0.2, a minimum window size of 100 and a maximum window size of 1000) is a tab-delimited file that might look like:
```
chrom	chr_start	chr_stop	num_positions	normal_depth	tumor_depth	adjusted_log_ratio	gc_content	region_call	raw_ratio
LG1 45	441	397	19.0	19.0	-0.049	34.0	neutral	-0.024
LG1	519	1086	568	76.8	87.9	0.142	31.5	neutral	0.172
LG1	1087	2047	961	36.5	50.6	0.428	35.1	amp	0.451
LG1	2515	2620	106	11.9	18.7	0.616	38.7	amp	0.63
LG1	2654	3653	1000	34.1	36.3	0.045	35.6	neutral	0.068
LG1	3654	4653	1000	33.5	38.8	0.182	39.1	neutral	0.19
LG1	4654	5653	1000	35.3	31.5	-0.206	36.1	del	-0.186
LG1	5654	5757	104	29.5	24.3	-0.329	35.6	del	-0.306
LG1	5758	6757	1000	27.7	28.0	0.051	50.2	neutral	-0.008
```
As you can see, if population 1 (column 5) has a higher coverage than population 2 (column 6), then a del, or deletion, is called. If population 1 (column 5) has a lower coverage than population 2 (column 6), then an amp, or duplication, is called. Be aware that this software has a cancer background, so that is why it calls population 2 "tumor".

### Limitations of Varscan
I believe that Varscan windows start once the coverage threshold has been meet and stop when the window size is reached or the coverage drops below the coverage threshold and the minimum window size has been reached. Therefore, Varscan doesn't start and stop windows at the same positions across different data sets and makes comparing results across datasets complicated. 

Varscan_multiple.pl
--------------
### Goals
Varscan_multiple.pl was written to compare multiple Varscan outputs to find common (or ancestral) deletions and insertions. 
### Directionality Consideration
When comparing your Varscan outputs, be sure to have a consistant directionality of each comparsion. For example, I have an interest in sex chromosome evolution. I each of my comparisons was males of a species compared to females of that same species.
