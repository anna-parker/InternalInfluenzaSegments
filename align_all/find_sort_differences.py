"""
This script parses the results of nextclade alignments to multiple references:
 - joins results of all alignments
 - removes rows where there is no alignmentScore (i.e. alignment failed)
 - group by seqName (=accession) and alignmentScore and keep the row with the highest score
"""

import click
import pandas as pd

DataSetIdentifier = "dataset"
SequenceIdentifier = "seqName"


@click.command()
@click.option(
    "--alignment",
    required=True,
    type=click.Path(exists=True),
)
@click.option(
    "--sort",
    required=True,
    type=click.Path(exists=True),
)
@click.option("--output", required=True, type=click.Path(exists=False))
def main(alignment: str, sort: str, output: str) -> None:
    align_results = pd.read_csv(alignment, sep="\t")
    df = pd.read_csv(
        sort,
        sep="\t",
        dtype={
            "index": "Int64",
            "score": "float64",
            SequenceIdentifier: "string",
            DataSetIdentifier: "string",
        },
    )
    df[DataSetIdentifier] = (
        df[DataSetIdentifier]
        .str.replace(r"^seg\d-", "", regex=True)
    )
    hits = df.dropna(subset=["score"]).sort_values(
        [SequenceIdentifier, "score"], ascending=[True, False]
    )
    best_hits = hits.groupby(SequenceIdentifier, as_index=False).first()

    merged = align_results.merge(best_hits, on=SequenceIdentifier, how="inner")
    mismatches = merged[merged[DataSetIdentifier] != merged["segment"]]
    mismatches = mismatches.rename(columns={"segment": "alignmentAssignedSegment", DataSetIdentifier: "sortAssignedSegment"})
    mismatches.to_csv(output, sep="\t", index=False)


if __name__ == "__main__":
    main()
