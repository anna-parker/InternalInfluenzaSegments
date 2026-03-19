from urllib.parse import urlencode

LAPIS_URL = "https://lapis-virus4.loculus.org/influenza-a/sample/"

SEGMENTS = ["seg1", "seg2", "seg3", "seg5", "seg7", "seg8"]

TSV_FIELDS = [
    "accessionVersion",
    "geoLocCountry",
    "subtypeHA",
    "subtypeNA",
    "reference_seg1",
    "reference_seg2",
    "reference_seg3",
    "reference_seg4",
    "reference_seg5",
    "reference_seg6",
    "reference_seg7",
    "reference_seg8",
    "submissionId",
    "completeness_seg1",
    "completeness_seg2",
    "completeness_seg3",
    "completeness_seg4",
    "completeness_seg5",
    "completeness_seg6",
    "completeness_seg7",
    "completeness_seg8",
    "insdcAccessionFull_seg1",
    "insdcAccessionFull_seg2",
    "insdcAccessionFull_seg3",
    "insdcAccessionFull_seg4",
    "insdcAccessionFull_seg5",
    "insdcAccessionFull_seg6",
    "insdcAccessionFull_seg7",
    "insdcAccessionFull_seg8",
    "sampleCollectionDate",
]

TRAITS = [
    "geoLocCountry",
    "subtypeHA",
    "subtypeNA",
    "reference_seg1",
    "reference_seg2",
    "reference_seg3",
    "reference_seg4",
    "reference_seg5",
    "reference_seg6",
    "reference_seg7",
    "reference_seg8",
]

TRAITS_STRING = " ".join(TRAITS)
FIELDS_STRING = " ".join(TSV_FIELDS)
TSV_FIELDS_URL_STRING = "%2C".join(TSV_FIELDS)

SEGMENT_SUBTYPES = ["h1n1pdm", "h1n1", "h3n2", "h2n2"]
HA_SUBTYPES = ["H1", "H2", "H3"]
NA_SUBTYPES = ["N1", "N2"]

def build_filter(segment):
    params = [
        ("dataUseTerms", "OPEN"),
        ("segments", ",".join(f"{segment}-{subtype}" for subtype in SEGMENT_SUBTYPES)),
        ("versionStatus", "LATEST_VERSION"),
        ("isRevocation", "false"),
        (f"completeness_{segment}From", "0.5"),
        ("hostNameScientific", "Homo sapiens"),
        (f"length_{segment}From", "1"),
        ("length_seg4From", "1"),
        ("length_seg6From", "1"),
    ]

    params.extend(("subtypeHA", subtype) for subtype in HA_SUBTYPES)
    params.extend(("subtypeNA", subtype) for subtype in NA_SUBTYPES)

    return urlencode(params)


def fasta_url(wildcards):
    filter_string = build_filter(wildcards.segment)
    return (
        f"{LAPIS_URL}unalignedNucleotideSequences"
        f"?downloadAsFile=true"
        f"&downloadFileBasename=influenza-a_nuc-{wildcards.segment}_2026-03-16T1639"
        f"&fastaHeaderTemplate=%7BaccessionVersion%7D"
        f"&{filter_string}"
    )


def metadata_url(wildcards):
    filter_string = build_filter(wildcards.segment)
    return (
        f"{LAPIS_URL}details"
        f"?downloadAsFile=true"
        f"&downloadFileBasename=influenza-a_metadata_{wildcards.segment}_2026-03-16T1549"
        f"&{filter_string}"
        f"&dataFormat=tsv"
        f"&fields={TSV_FIELDS_URL_STRING}"
    )


rule all:
    input:
        expand("auspice/auspice_{segment}.json", segment=SEGMENTS),


rule download_sequences:
    output:
        fasta="results/segment_{segment}.fasta",
    params:
        url=fasta_url,
    shell:
        """
        curl -L "{params.url}" -o {output.fasta}
        """


rule download_metadata:
    output:
        metadata="results/metadata_{segment}.tsv",
    params:
        url=metadata_url,
    shell:
        """
        curl -L "{params.url}" -o {output.metadata}
        """


rule subsample_segments:
    input:
        fasta="results/segment_{segment}.fasta",
    output:
        subsampled_fasta="results/segments/sample_segment_{segment}.fasta",
    shell:
        """
        seqkit sample -n 1000 -2 --out-file {output.subsampled_fasta} {input.fasta}
        """


rule align_segments:
    input:
        reference_genome="results/segments/sample_segment_{segment}.fasta",
    output:
        aligned_fasta="results/segments/aligned_segment_{segment}.fasta",
    shell:
        """
        augur align --sequences {input.reference_genome} --output {output.aligned_fasta}
        """


rule segment_trees:
    input:
        reference_genome="results/segments/aligned_segment_{segment}.fasta",
    output:
        tree="results/segments/tree_{segment}.nwk",
    shell:
        """
        augur tree --alignment {input.reference_genome}  \
             --output {output.tree}
        """


rule refine_trees:
    input:
        tree="results/segments/tree_{segment}.nwk",
    output:
        refined_tree="results/segments/refined_tree_{segment}.nwk",
    shell:
        """
        augur refine --tree {input.tree} --output-tree {output.refined_tree}
        """


rule traits:
    input:
        tree="results/segments/refined_tree_{segment}.nwk",
        metadata="results/metadata_{segment}.tsv",
    output:
        traits="results/segments/traits_{segment}.json",
    shell:
        """
        augur traits --tree {input.tree} --metadata {input.metadata} \
            --output-node-data {output.traits} \
            --columns {TRAITS_STRING} \
            --metadata-id-columns accessionVersion
        """


rule create_auspice_config:
    input:
        tree="results/segments/refined_tree_{segment}.nwk",
        metadata="results/metadata_{segment}.tsv",
    output:
        auspice_config="config/config_{segment}.json",
    params:
        segment="{segment}",
    shell:
        """
        python auspice_config.py \
            --title "Influenza A Segment {params.segment}" \
            --traits {FIELDS_STRING} \
            --output {output.auspice_config}
        """


rule export:
    input:
        tree="results/segments/refined_tree_{segment}.nwk",
        metadata="results/metadata_{segment}.tsv",
        traits="results/segments/traits_{segment}.json",
        auspice_config="config/config_{segment}.json",
        nt_muts="results/nt_muts_{segment}.json",
    output:
        auspice_json="auspice/auspice_{segment}.json",
    shell:
        """
        augur export v2 \
            --tree {input.tree} \
            --metadata {input.metadata} \
            --node-data {input.traits} \
            --output {output.auspice_json} \
            --metadata-id-columns "accessionVersion"  \
            --auspice-config {input.auspice_config}
        """
