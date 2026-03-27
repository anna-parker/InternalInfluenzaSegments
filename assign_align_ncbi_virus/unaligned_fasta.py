"""
This script parses the results of nextclade sort to multiple references:
"""

import click
import pandas as pd
from Bio import SeqIO

DataSetIdentifier = "dataset"
SequenceIdentifier = "seqName"


@click.command()
@click.option(
    "--alignment-results",
    required=True,
    type=click.Path(exists=True),
)
@click.option("--sequences", required=True, type=click.Path(exists=True))
@click.option("--output", required=True, type=click.Path())
def main(alignment_results: str, sequences: str, output: str) -> None:
    df = pd.read_csv(alignment_results, sep="\t")

    unaligned_ids = set(
        df.loc[df["alignmentScore"].isna(), "seqName"]
        .dropna()
        .astype(str)
    )

    records = (
        record
        for record in SeqIO.parse(sequences, "fasta")
        if record.id in unaligned_ids and len(record.seq) >= 100
    )

    n = SeqIO.write(records, output, "fasta")
    print(f"Wrote {n} unaligned sequences")


if __name__ == "__main__":
    main()