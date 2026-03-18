# Influenza A Internal Segment Reference Alignment

For human influenza A lineages reassortment is rare, thus HA and NA lineages mappings often correlate with internal segment clades.

We assigned internal segments and their closest reference (~HA/NA lineage) using diamond. This repo takes the full MSA of internal segments, builds trees and annotates them with their assigned closest reference to determine if there has been a mis-classification.


## Local Development
```
micromamba create -f environment.yaml
micromamba activate influenza-testing
snakemake --cores 1
```
## Visualizing Results

https://nextstrain.org/fetch/raw.githubusercontent.com/anna-parker/InternalInfluenzaSegments/main/auspice/auspice_seg1.json
https://nextstrain.org/fetch/raw.githubusercontent.com/anna-parker/InternalInfluenzaSegments/main/auspice/auspice_seg2.json
https://nextstrain.org/fetch/raw.githubusercontent.com/anna-parker/InternalInfluenzaSegments/main/auspice/auspice_seg3.json
https://nextstrain.org/fetch/raw.githubusercontent.com/anna-parker/InternalInfluenzaSegments/main/auspice/auspice_seg5.json
https://nextstrain.org/fetch/raw.githubusercontent.com/anna-parker/InternalInfluenzaSegments/main/auspice/auspice_seg7.json
https://nextstrain.org/fetch/raw.githubusercontent.com/anna-parker/InternalInfluenzaSegments/main/auspice/auspice_seg8.json