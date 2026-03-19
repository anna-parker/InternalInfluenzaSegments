"""
This script parses the results of nextclade alignments to multiple references:
 - joins results of all alignments
 - removes rows where there is no alignmentScore (i.e. alignment failed)
 - group by seqName (=accession) and alignmentScore and keep the row with the highest score
"""

import click
import pandas as pd

DiamondDataSetIdentifier = "dataset"
SequenceIdentifier = "seqName"


@click.command()
@click.option(
    "--alignment",
    required=True,
    type=click.Path(exists=True),
)
@click.option(
    "--diamond",
    required=True,
    type=click.Path(exists=True),
)
@click.option("--output", required=True, type=click.Path(exists=False))
def main(alignment: str, diamond: str, output: str) -> None:
    align_results = pd.read_csv(alignment, sep="\t")
    diamond_results = pd.read_csv(diamond, sep="\t")
    diamond_results[DiamondDataSetIdentifier] = diamond_results[DiamondDataSetIdentifier].str.replace(
        r"\|CDS\d+$",
        "",
        regex=True,
    ).replace(r"^seg\d_", "", regex=True)

    hits = diamond_results.dropna(subset=["pident"]).sort_values(
        [SequenceIdentifier, "pident"], ascending=[True, False]
    )
    best_hits = hits.groupby(SequenceIdentifier, as_index=False).first()

    merged = align_results.merge(best_hits, on=SequenceIdentifier, how="inner")
    mismatches = merged[merged[DiamondDataSetIdentifier] != merged["segment"]]
    mismatches.to_csv(output, sep="\t", index=False)


if __name__ == "__main__":
    main()
