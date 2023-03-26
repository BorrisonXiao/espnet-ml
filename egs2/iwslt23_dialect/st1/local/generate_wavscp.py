#!/usr/bin/env python3
# -*- encoding: utf8 -*-

import argparse
from pathlib import Path


def generate(src, out, data_dir):
    with open(src, "r") as src, open(out, "w") as out:
        for line in src:
            splitted = line.strip().split()
            orig_path = Path(splitted[7])
            prefix = data_dir / "data" / "audio" / "ta"
            new_path = prefix / orig_path.name
            new_splitted = splitted[:7] + [str(new_path)] + splitted[8:]
            new_line = " ".join(new_splitted)
            print(new_line, file=out)
            # breakpoint()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--src",
        type=Path,
        required=True,
        help="Path to the source wav.scp file.",
    )
    parser.add_argument(
        "--out",
        type=Path,
        required=True,
        help="Path to the output wav.scp file.",
    )
    parser.add_argument(
        "--data-dir",
        type=Path,
        required=True,
        help="The path to the actual audio files.",
    )
    args = parser.parse_args()

    generate(args.src, args.out, args.data_dir)


if __name__ == "__main__":
    main()
