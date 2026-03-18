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

FILTER = "dataUseTerms=OPEN&segments={segment}-h1n1pdm%2C{segment}-h1n1%2C{segment}-h3n2%2C{segment}-h2n2&versionStatus=LATEST_VERSION&isRevocation=false&completeness_{segment}From=0.9&hostNameScientific=Homo+sapiens&length_{segment}From=1&length_seg4From=1&length_seg6From=1&subtypeHA=H1&subtypeHA=H2&subtypeHA=H3&subtypeNA=N1&subtypeNA=N2"
TSV_FIELDS_URL_STRING = "%2C".join(TSV_FIELDS)
TRAITS_STRING = " ".join(TRAITS)
FIELDS_STRING = " ".join(TSV_FIELDS)
FASTA_URL_TEMPLATE = f"{LAPIS_URL}unalignedNucleotideSequences?downloadAsFile=true&downloadFileBasename=influenza-a_nuc-seg1_2026-03-16T1639&fastaHeaderTemplate=%7BaccessionVersion%7D&{FILTER}"
METADATA_URL_TEMPLATE = f"{LAPIS_URL}details?downloadAsFile=true&downloadFileBasename=influenza-a_metadata_2026-03-16T1549&{FILTER}&dataFormat=tsv&fields={TSV_FIELDS_URL_STRING}"


def fasta_url(wildcards):
    return FASTA_URL_TEMPLATE.format(segment=wildcards.segment)


def metadata_url(wildcards):
    return METADATA_URL_TEMPLATE.format(segment=wildcards.segment)


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


rule ancestral:
    message:
        "Reconstructing ancestral sequences and mutations"
    input:
        tree="results/segments/refined_tree_{segment}.nwk",
        alignment="results/segments/aligned_segment_{segment}.fasta",
    output:
        node_data="results/nt_muts_{segment}.json",
    params:
        inference="joint",
    shell:
        """
        augur ancestral \
            --tree {input.tree} \
            --alignment {input.alignment} \
            --output-node-data {output.node_data} \
        """


# rule translate:
#     message:
#         "Translating amino acid sequences"
#     input:
#         tree=rules.refine.output.tree,
#         node_data=rules.ancestral.output.node_data,
#         reference=reference_gff3,
#     output:
#         node_data="results/aa_muts.json",
#     shell:
#         """
#         augur translate \
#             --tree {input.tree} \
#             --ancestral-sequences {input.node_data} \
#             --reference-sequence {input.reference} \
#             --output-node-data {output.node_data} \
#         """


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
            --node-data {input.traits} {input.nt_muts} \
            --output {output.auspice_json} \
            --metadata-id-columns "accessionVersion"  \
            --auspice-config {input.auspice_config}
        """
