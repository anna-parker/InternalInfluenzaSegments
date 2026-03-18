#!/usr/bin/env python3
import json
import argparse

MAINTAINERS = ["Anna Parker"]
BUILD_URL = "https://github.com/anna-parker/InfluenzaAReferenceDB"
PANELS = ["tree", "entropy"]


def make_config(title, maintainers, build_url, traits, panels):
    return {
        "title": title,
        "maintainers": [{"name": m} for m in maintainers],
        "build_url": build_url,
        "colorings": [
            {
                "key": trait,
                "title": trait,
                "type": "categorical",
            }
            for trait in traits
        ],
        "panels": panels,
        "filters": traits,
    }


def main():
    parser = argparse.ArgumentParser(description="Generate config JSON")

    parser.add_argument(
        "--title",
        default="Influenza A",
        help="Title of the dataset",
    )

    parser.add_argument(
        "--traits",
        nargs="+",
        required=True,
        help="Traits (space-separated)",
    )

    parser.add_argument(
        "--output",
        help="Output file",
    )

    args = parser.parse_args()

    config = make_config(
        title=args.title,
        maintainers=MAINTAINERS,
        build_url=BUILD_URL,
        traits=args.traits,
        panels=PANELS,
    )

    if args.output:
        with open(args.output, "w") as f:
            json.dump(config, f, indent=2)
    else:
        print(json.dumps(config, indent=2))


if __name__ == "__main__":
    main()