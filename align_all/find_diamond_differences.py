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
    diamond_results = pd.read_csv(
        diamond,
        header=None,
        names=[
            SequenceIdentifier,
            DiamondDataSetIdentifier,
            "pident",
            "length",
            "mismatch",
            "gapopen",
            "qstart",
            "qend",
            "sstart",
            "send",
            "evalue",
            "bitscore",
        ],
        sep="\t",
    )
    diamond_results[DiamondDataSetIdentifier] = (
        diamond_results[DiamondDataSetIdentifier]
        .str.replace(
            r"\|CDS\d+$",
            "",
            regex=True,
        )
        .replace(r"^seg\d-", "", regex=True).replace(r"-CY163681", "", regex=True).replace(r"-CY163685", "", regex=True).replace(r"-CY163683", "", regex=True).replace(r"-CY163684", "", regex=True).replace(r"-CY163685", "", regex=True).replace(r"-CY163686", "", regex=True).replace(r"-CY163687", "", regex=True).replace(r"-CY163688", "", regex=True).replace(r"-CY163689", "", regex=True).replace(r"-CY163690", "", regex=True).replace(r"-CY163691", "", regex=True).replace(r"-CY163692", "", regex=True).replace(r"-CY163693", "", regex=True).replace(r"-CY163694", "", regex=True).replace(r"-CY163695", "", regex=True).replace(r"-CY163696", "", regex=True).replace(r"-CY163697", "", regex=True).replace(r"-CY163698", "", regex=True).replace(r"-CY163699", "", regex=True)
    )

    hits = diamond_results.dropna(subset=["pident"]).sort_values(
        [SequenceIdentifier, "pident"], ascending=[True, False]
    )
    best_hits = hits.groupby(SequenceIdentifier, as_index=False).first()

    merged = align_results.merge(best_hits, on=SequenceIdentifier, how="inner")
    mismatches = merged[merged[DiamondDataSetIdentifier] != merged["segment"]]
    mismatches = mismatches.rename(columns={"segment": "alignmentAssignedSegment", DiamondDataSetIdentifier: "diamondAssignedSegment"})
    mismatches.to_csv(output, sep="\t", index=False)


if __name__ == "__main__":
    main()
