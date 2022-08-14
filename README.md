# HybridizationScripts

1. Run newhybrids pipeline (uses hybriddetective) to get top loci for determining hybrids.

2. Simulate 1st, 2nd, and 3rd generation hybrids with adegenetHybridize.R.

3. In folder with the simulated files, run the genepopConvert.sh script. This will turn the "genepop" format file output from the radiator R package to the proper genepop format, then use genepop2newhybrids.pl to convert to newhybrids.

4. Run the runAll.sh script. This will execute 4 replicates of newhybrids on simulated data.

5. After newhybrids finishes, go to the subfolder folder containing runfolder subdirectories (e.g., run_1, run_2, etc.). 

6. Run the relabelAll.sh script to relabel newhybrids output (aa-PofZ.txt) with sample names and populations. This script calls the relabelPofZ.pl script. It also relabels the header line in the aa-PofZ.txt file. 

7. run compareNewhybrids.pl to get output.

8. Run compareMaps.pl to find simulated individuals that were misclassified.
