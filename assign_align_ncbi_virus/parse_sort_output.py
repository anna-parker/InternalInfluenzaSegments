"""
This script parses the results of nextclade sort to multiple references:
"""

from collections import defaultdict

import click
import pandas as pd
from Bio import SeqIO

DataSetIdentifier = "dataset"
SequenceIdentifier = "seqName"


@click.command()
@click.option(
    "--sort-results",
    required=True,
    type=click.Path(exists=True),
)
@click.option("--sequences", required=True, type=click.Path(exists=True))
@click.option(
    "--results",
    required=True,
    type=click.Path(),
    multiple=True,
)
def main(sort_results: str, sequences: str, results: list[str]) -> None:
    empty_files_to_write = set(results)
    records = SeqIO.parse(sequences, "fasta")
    record_dict = {record.id: record for record in records}
    df = pd.read_csv(
        sort_results,
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
        .str.replace(r"-avian$", "", regex=True)
    )
    hits = df.dropna(subset=["score"]).sort_values(
        [SequenceIdentifier, "score"], ascending=[True, False]
    )
    best_hits = hits.groupby(SequenceIdentifier, as_index=False).first()

    grouped_records = defaultdict(list)

    for _, row in best_hits.iterrows():
        record = record_dict.get(row[SequenceIdentifier])
        assert record is not None
        grouped_records[row[DataSetIdentifier]].append(record)

    for dataset_id, records in grouped_records.items():
        outfile = f"results/assigned_{dataset_id}.fasta"
        empty_files_to_write.discard(outfile)
        with open(outfile, "w") as handle:
            SeqIO.write(records, handle, "fasta")

    for outfile in empty_files_to_write:
        with open(outfile, "w") as handle:
            SeqIO.write([], handle, "fasta")


if __name__ == "__main__":
    main()