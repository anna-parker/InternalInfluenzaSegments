from urllib.parse import urlencode

LAPIS_URL = "https://lapis-virus4.loculus.org/influenza-a/sample/"

SEGMENTS = ["seg4", "seg6"]

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
    "diamond_errors",
]

TRAITS_STRING = " ".join(TRAITS)
TSV_FIELDS_URL_STRING = "%2C".join(TSV_FIELDS)

SEGMENT_SUBTYPES = ["h1n1pdm", "h1n1", "h3n2", "h2n2"]
dataset_name_map = {
    "seg1": {
        "h1n1pdm": "nextstrain/flu/h1n1pdm/pb2",
        "h1n1": "nextstrain/flu/h1n1/pb2",
        "h3n2": "nextstrain/flu/h3n2/pb2",
        "h2n2": "nextstrain/flu/h2n2/pb2",
    },
    "seg2": {
        "h1n1pdm": "nextstrain/flu/h1n1pdm/pb1",
        "h1n1": "nextstrain/flu/h1n1/pb1",
        "h3n2": "nextstrain/flu/h3n2/pb1",
        "h2n2": "nextstrain/flu/h2n2/pb1",
    },
    "seg3": {
        "h1n1pdm": "nextstrain/flu/h1n1pdm/pa",
        "h1n1": "nextstrain/flu/h1n1/pa",
        "h3n2": "nextstrain/flu/h3n2/pa",
        "h2n2": "nextstrain/flu/h2n2/pa",
    },
    "seg4": {
        "h1_h1n1pdm": "nextstrain/flu/h1n1pdm/ha/CY121680",
        "h1_h1n1": "nextstrain/flu/h1n1/ha",
        "h3_h3n2": "nextstrain/flu/h3n2/ha/CY163680",
        "h2_h2n2": "nextstrain/flu/h2n2/ha",
        "h3_h3n8": "flu/HA/ha_h3_h3n8/CY028836",
        "h4_h4n6": "flu/HA/ha_h4_h4n6/CY181241",
        "h5_h5n1": "community/moncla-lab/iav-h5/ha/all-clades",
        "h5_h5n2": "flu/HA/ha_h5_h5n2/KU143256",
        "h6_h6n2": "flu/HA/ha_h6_h6n2/CY130030",
        "h7_h7n9": "flu/HA/ha_h7_h7n9/NC_026425.1",
        "h8_h8n4": "flu/HA/ha_h8_h8n4/CY136131",
        "h9_h9n2": "flu/HA/ha_h9_h9n2/NC_004908.1",
        "h10_h10n7": "flu/HA/ha_h10_h10n7/CY136094",
        "h11_h11n9": "flu/HA/ha_h11_h11n9/CY130070",
        "h12_h12n5": "flu/HA/ha_h12_h12n5/CY130078",
        "h13_h13n6": "flu/HA/ha_h13_h13n6/CY130086",
        "h14_h14n5": "flu/HA/ha_h14_h14n5/JN696314",
        "h15_h15n9": "flu/HA/ha_h15_h15n9/CY006010",
        "h16_h16n3": "flu/HA/ha_h16_h16n3/CY136630",
        "h17_h17n10": "flu/HA/ha_h17_h17n10/CY103876",
        "h18_h18n11": "flu/HA/ha_h18_h18n11/CY125945"
    },
    "seg5": {
        "h1n1pdm": "nextstrain/flu/h1n1pdm/np",
        "h1n1": "nextstrain/flu/h1n1/np",
        "h3n2": "nextstrain/flu/h3n2/np",
        "h2n2": "nextstrain/flu/h2n2/np",
    },
    "seg6": {
        "n1_h1n1pdm": "nextstrain/flu/h1n1pdm/na/MW626056",
        "n1_h1n1": "nextstrain/flu/h1n1/na",
        "n2_h3n2": "nextstrain/flu/h3n2/na/EPI1857215",
        "n2_h2n2": "nextstrain/flu/h2n2/na",
        "n1_h5n1": "flu/NA/na_n1_h5n1/NC_007361.1",
        "n2_h6n2": "flu/NA/na_n2_h6n2/CY130032",
        "n2_h9n2": "flu/NA/na_n2_h9n2/NC_004909.1",
        "n2_h5n2": "flu/NA/na_n2_h5n2/KU143347",
        "n3_h16n3": "flu/NA/na_n3_h16n3/CY136632",
        "n4_h8n4": "flu/NA/na_n4_h8n4/CY136133",
        "n5_h12n5": "flu/NA/na_n5_h12n5/CY130080",
        "n6_h4n6": "flu/NA/na_n6_h4n6/CY181243",
        "n6_h13n6": "flu/NA/na_n6_h13n6/CY130088",
        "n7_h10n7": "flu/NA/na_n7_h10n7/CY136096",
        "n8_h3n8": "flu/NA/na_n8_h3n8/CY028838",
        "n9_h7n9": "flu/NA/na_n9_h7n9/NC_026429.1",
        "n9_h11n9": "flu/NA/na_n9_h11n9/CY130072",
        "n9_h15n9": "flu/NA/na_n9_h15n9/CY005407",
        "n10_h17n10": "flu/NA/na_n10_h17n10/CY103878",
        "n11_h18n11": "flu/NA/na_n11_h18n11/CY125947"
    },
    "seg7": {
        "h1n1pdm": "nextstrain/flu/h1n1pdm/mp",
        "h1n1": "nextstrain/flu/h1n1/mp",
        "h3n2": "nextstrain/flu/h3n2/mp",
        "h2n2": "nextstrain/flu/h2n2/mp",
    },
    "seg8": {
        "h1n1pdm": "nextstrain/flu/h1n1pdm/ns",
        "h1n1": "nextstrain/flu/h1n1/ns",
        "h3n2": "nextstrain/flu/h3n2/ns",
        "h2n2": "nextstrain/flu/h2n2/ns",
    },
}
# HA_SUBTYPES = ["H1", "H2", "H3"]
# NA_SUBTYPES = ["N1", "N2"]

def build_filter(segment):
    params = [
        ("dataUseTerms", "OPEN"),
        ("segments", ",".join(f"{segment}-{subtype}" for subtype in dataset_name_map[segment].keys())),
        ("versionStatus", "LATEST_VERSION"),
        ("isRevocation", "false"),
        # (f"completeness_{segment}From", "0.5"),
        # ("hostNameScientific", "Homo sapiens"),
        (f"length_{segment}From", "1"),
    ]

    # params.extend(("subtypeHA", subtype) for subtype in HA_SUBTYPES)
    # params.extend(("subtypeNA", subtype) for subtype in NA_SUBTYPES)

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

rule add_missing_sequences:
    input:
        differences="align_all/results/diamonddifferences_{segment}.tsv",
        main="results/segment_{segment}.fasta",
        subsampled="results/segments/sample_segment_{segment}.fasta"
    params:
        segment="{segment}",
    output:
        added="results/segments/subsampled_updated_{segment}.fasta"
    shell:
        r"""
        # extract seqNames from TSV (skip header)
        cut -f1 {input.differences} | tail -n +2 > results/wanted_ids_{params.segment}.txt

        # extract existing IDs from subsampled fasta
        seqkit seq -n {input.subsampled} > results/existing_ids_{params.segment}.txt

        # find missing IDs
        grep -Fxv -f results/existing_ids_{params.segment}.txt results/wanted_ids_{params.segment}.txt > results/missing_ids_{params.segment}.txt

        # extract missing sequences from main fasta
        seqkit grep -f results/missing_ids_{params.segment}.txt {input.main} > results/missing_sequences_{params.segment}.fasta

        # combine old + new
        cat {input.subsampled} results/missing_sequences_{params.segment}.fasta > {output.added}
        """

rule add_has_errors_column:
    input:
        metadata="results/metadata_{segment}.tsv",
        flagged="align_all/results/diamonddifferences_{segment}.tsv"
    params:
        segment="{segment}",
    output:
        "results/metadataWithErrors_{segment}.tsv"
    shell:
        r"""
        cut -f1 {input.flagged} | tail -n +2 > results/error_ids_{params.segment}.txt

        awk 'BEGIN{{FS=OFS="\t"}}
             NR==FNR {{error[$1]=1; next}}
             FNR==1 {{
                 print $0, "diamond_errors"
                 next
             }}
             {{
                 flag = ($1 in error) ? "yes" : "no"
                 print $0, flag
             }}' results/error_ids_{params.segment}.txt {input.metadata} > {output}
        """


rule align_segments:
    input:
        reference_genome="results/segments/subsampled_updated_{segment}.fasta",
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
        metadata="results/metadataWithErrors_{segment}.tsv",
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
        metadata="results/metadataWithErrors_{segment}.tsv",
    output:
        auspice_config="config/config_{segment}.json",
    params:
        segment="{segment}",
    shell:
        """
        python auspice_config.py \
            --title "Influenza A Segment {params.segment}" \
            --traits {TRAITS_STRING} \
            --output {output.auspice_config}
        """


rule export:
    input:
        tree="results/segments/refined_tree_{segment}.nwk",
        metadata="results/metadataWithErrors_{segment}.tsv",
        traits="results/segments/traits_{segment}.json",
        auspice_config="config/config_{segment}.json",
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
