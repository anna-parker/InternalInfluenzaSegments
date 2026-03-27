from pathlib import Path
from Bio import SeqIO


def count_fasta(path):
    if not path.exists():
        return 0
    return sum(1 for _ in SeqIO.parse(path, "fasta"))


def main(results_dir="results"):
    results_dir = Path(results_dir)

    assigned_files = list(results_dir.glob("assigned_*.fasta"))
    assigned_files.sort()

    print("refname\tassigned\tunaligned\tpct_unaligned")

    for assigned_file in assigned_files:
        refname = assigned_file.stem.replace("assigned_", "")
        unaligned_file = results_dir / f"unaligned_{refname}_filtered.tsv"

        assigned_count = count_fasta(assigned_file)
        unaligned_count = count_fasta(unaligned_file)

        pct_unaligned = (unaligned_count / assigned_count * 100) if assigned_count > 0 else 0

        print(
            f"{refname}\t{assigned_count}\t{unaligned_count}\t{pct_unaligned:.2f}"
        )


if __name__ == "__main__":
    main()