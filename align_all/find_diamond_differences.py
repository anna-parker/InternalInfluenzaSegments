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
    diamond_results["reference"] = (
        diamond_results[DiamondDataSetIdentifier]
        .str.replace(r"\|CDS\d+$", "", regex=True)
        .replace(r"^seg\d-", "", regex=True)
    )

    diamond_results["cds"] = diamond_results[DiamondDataSetIdentifier].str.extract(
        r"(CDS\d+)$"
    )

    diamond_results["weighted_identity"] = (
        diamond_results["bitscore"] * diamond_results["length"]
    )

    composite = diamond_results.groupby(
        [SequenceIdentifier, "reference"], as_index=False
    ).agg(
        total_length=("length", "sum"),
        weighted_identity_sum=("weighted_identity", "sum"),
        n_hits=("cds", "nunique"),  # how many CDS found
    )

    composite["composite_score"] = (
        composite["weighted_identity_sum"] / composite["total_length"]
    )

    best_composite = (
        composite.sort_values(
            [SequenceIdentifier, "composite_score", "total_length"],
            ascending=[True, False, False],
        )
        .groupby(SequenceIdentifier, as_index=False)
        .first()
    )

    merged = align_results.merge(best_composite, on=SequenceIdentifier, how="inner")
    merged["reference"] = (
        merged["reference"]
        .str.replace(r"-CY163681", "", regex=True)
        .replace(r"-CY163685", "", regex=True)
        .replace(r"-CY163683", "", regex=True)
        .replace(r"-CY163684", "", regex=True)
        .replace(r"-CY163685", "", regex=True)
        .replace(r"-CY163686", "", regex=True)
        .replace(r"-CY163687", "", regex=True)
        .replace(r"-CY163688", "", regex=True)
        .replace(r"-CY163689", "", regex=True)
        .replace(r"-CY163690", "", regex=True)
        .replace(r"-CY163691", "", regex=True)
        .replace(r"-CY163692", "", regex=True)
        .replace(r"-CY163693", "", regex=True)
        .replace(r"-CY163694", "", regex=True)
        .replace(r"-CY163695", "", regex=True)
        .replace(r"-CY163696", "", regex=True)
        .replace(r"-CY163697", "", regex=True)
        .replace(r"-CY163698", "", regex=True)
        .replace(r"-CY163699", "", regex=True)
    )
    mismatches = merged[merged["reference"] != merged["segment"]]
    mismatches = mismatches.rename(
        columns={
            "segment": "alignmentAssignedSegment",
            "reference": "diamondAssignedSegment",
        }
    )
    mismatches.to_csv(output, sep="\t", index=False)


if __name__ == "__main__":
    main()
