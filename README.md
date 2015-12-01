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
...
```
As you can see, if population 1 (column 5) has a higher coverage than population 2 (column 6), then a del, or deletion, is called. If population 1 (column 5) has a lower coverage than population 2 (column 6), then an amp, or duplication, is called. Be aware that this software has a cancer background, so that is why it calls population 2 "tumor".

### Limitations of Varscan
I believe that Varscan windows start once the coverage threshold has been meet and stop when the window size is reached or the coverage drops below the coverage threshold and the minimum window size has been reached. Therefore, Varscan doesn't start and stop windows at the same positions across different data sets and makes comparing results across datasets complicated. 

Varscan_multiple.pl
--------------
### Goals
Varscan_multiple.pl was written to compare multiple Varscan outputs to find common (or ancestral) deletions and insertions. 
### Directionality Consideration
When comparing your Varscan outputs, be sure to have a consistant directionality of each comparsion. For example, I have an interest in sex chromosome evolution. In each of my comparisons, males of a species compared to females of that same species. So, males were first in the mpileup file and females were second, therefore males were always considered "normal" and females were always considered the "tumor". This is important because "del" and "amp" are called based upon the "normal" coverage. If you flipped it and had females first and males second in one comparison and males first and females second in the another comparision, then the ancestral duplications or deletions shared on the sex chromosomes would be "amp" in one comparision and "del" in the other. As a result, the Varscan_multiple.pl would not consider this site an ancestral duplication or deletion. However, it would call it if the directionality was correct.
### Using Varscan_multiple.pl
Varscan_multiple.pl was set up to run on the output of the copynumber/Copycaller pipeline in Varscan_v2.3.7. Below are two sample files:

Input_1.txt
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
...
```
Input_2.txt
```
chrom	chr_start	chr_stop	num_positions	normal_depth	tumor_depth	adjusted_log_ratio	gc_content	region_call	raw_ratio
LG1	289	1288	1000	38.8	38.6	0.016	34.4	neutral	0.018
LG1	1289	1443	155	19.0	18.6	-0.009	32.3	neutral	-0.002
LG1	1649	2056	408	16.0	24.3	0.623	32.6	amp	0.63
LG1	2412	2648	237	17.7	24.5	0.501	43.0	amp	0.499
LG1	2742	3741	1000	57.3	60.6	0.109	37.2	neutral	0.106
LG1	3742	4741	1000	61.3	51.1	-0.233	37.6	del	-0.236
LG1	4742	5741	1000	37.0	39.7	0.130	36.4	neutral	0.129
LG1	5742	6741	1000	30.3	26.4	-0.188	50.2	neutral	-0.172
LG1	6742	7300	559	27.2	26.4	-0.020	47.6	neutral	-0.019
...
```
Below is a sample command line:
```
perl Varscan_multiple.pl --input_file=Input_1.txt --input_file=Input_2.txt --output_file=Output.bed --track_name=Name_of_track_in_IGV --chrom_size_file=Chrom_size_file.txt --raw_data_file=Raw_data_output.txt --minimum_consensus=2
```
The chrom_size_file is a tab-delimited file:
```
LG1 31194787
LG2 25048291
LG3 19325363
LG4 28679955
LG5 37389089
LG6 36725243
LG7 51042256
LG8_24 29447820
LG9 20956653
LG10 17092887
...
```
* Column 1 -> Scaffold/Contig/Linkage Group/Chromosome
* Column 2 -> Size of the Scaffold/Contig/Linkage Group/Chromosome in Column 1

The output_file will be a BED file that looks like:

```
track name=Name_of_track_in_IGV itemRgb="On"
LG1	0	1087	neutral	0	+	0	1087	0,0,255
LG1	1649	2048	amp	0	+	1649	2048	0,255,0
LG1	2057	2412	neutral	0	+	2057	2412	0,0,255
LG1	2515	2621	amp	0	+	2515	2621	0,255,0
LG1	2649	3742	neutral	0	+	2649	3742	0,0,255
LG1	4654	4742	del	0	+	4654	4742	255,0,0
LG1	5758	6758	neutral	0	+	5758	6758	0,0,255
LG1	7569	7599	neutral	0	+	7569	7599	0,0,255
LG1	7647	8599	amp	0	+	7647	8599	0,255,0
...
```

The raw_data_file is an output file which contains each position in the genome and whether is was called within an "amp", "del" or "neutral" window.
```
LG1	1	neutral	neutral
LG1	2	neutral	neutral
LG1	3	neutral	neutral
LG1	4	neutral	neutral
LG1	5	neutral	neutral
LG1	6	neutral	neutral
LG1	7	neutral	neutral
LG1	8	neutral	neutral
LG1	9	neutral	neutral
LG1	10	neutral	neutral
...
```
This file in future add-ons will be used to allow the user to run a script with various thresholds and make BED files from it. It is also an way of ground-truthing the data in the BED file.

The threshold is how many "amp"s, "del"s or "neutral"s the user requires for it to be called. If the threshold is equal to the number of Varscan comparisons, then the "amp", "del", or "neutral" must be shared by all Varscan comparisons. However, if the threshold is less than the number of Varscan comparisions it only needs to be in some proportion of the comparisons.

The track_name will be the name of the track in IGV.

The file might look like this in your IGV browser:

![alt tag](https://github.com/Gammerdinger/Varscan_multiple/blob/master/Varscan_multiple_example_IGV.png)
