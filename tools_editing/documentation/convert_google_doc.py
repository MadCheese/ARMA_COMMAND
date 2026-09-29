from __future__ import annotations

import argparse
import re
import shutil
import tempfile
import zipfile
from pathlib import Path
from urllib.parse import parse_qs, urlparse

from bs4 import BeautifulSoup
from markdownify import markdownify as to_markdown
from PIL import Image


PX_RE = re.compile(r"([\w-]+)\s*:\s*(-?[0-9.]+)px")


def style_px(style: str) -> dict[str, float]:
    return {
        key: float(value)
        for key, value in PX_RE.findall(style or "")
    }


def unwrap_google_url(href: str) -> str:
    try:
        parsed = urlparse(href)

        if (
            parsed.netloc in {"google.com", "www.google.com"}
            and parsed.path == "/url"
        ):
            target = parse_qs(parsed.query).get("q")

            if target:
                return target[0]
    except Exception:
        pass

    return href


def crop_if_needed(
    img_tag,
    extracted_root: Path,
    output_assets: Path
) -> str:

    src = img_tag.get("src", "")
    src_path = extracted_root / src

    if not src.startswith("images/") or not src_path.exists():
        return Path(src).name

    parent = img_tag.parent

    parent_style = (
        style_px(parent.get("style", ""))
        if parent
        else {}
    )

    img_style = style_px(img_tag.get("style", ""))

    keys_ok = (
        all(k in parent_style for k in ("width", "height"))
        and
        all(k in img_style for k in ("width", "height"))
    )

    output_name = src_path.name
    needs_crop = False

    if keys_ok:
        container_w = parent_style["width"]
        container_h = parent_style["height"]

        image_w = img_style["width"]
        image_h = img_style["height"]

        margin_left = img_style.get("margin-left", 0.0)
        margin_top = img_style.get("margin-top", 0.0)

        needs_crop = (
            abs(margin_left) > 0.01
            or abs(margin_top) > 0.01
            or container_w + 0.01 < image_w
            or container_h + 0.01 < image_h
        )

        if needs_crop:
            with Image.open(src_path) as image:
                scale_x = image.width / image_w
                scale_y = image.height / image_h

                left = max(
                    0,
                    round(-margin_left * scale_x)
                )

                top = max(
                    0,
                    round(-margin_top * scale_y)
                )

                right = min(
                    image.width,
                    round((container_w - margin_left) * scale_x)
                )

                bottom = min(
                    image.height,
                    round((container_h - margin_top) * scale_y)
                )

                if right > left and bottom > top:
                    output_name = (
                        f"{src_path.stem}-cropped"
                        f"{src_path.suffix.lower()}"
                    )

                    image.crop(
                        (left, top, right, bottom)
                    ).save(
                        output_assets / output_name
                    )

                else:
                    needs_crop = False

    if not needs_crop:
        shutil.copy2(
            src_path,
            output_assets / output_name
        )

    return output_name


def main() -> None:

    parser = argparse.ArgumentParser()

    parser.add_argument(
        "zip_file",
        type=Path
    )

    parser.add_argument(
        "--repo",
        type=Path,
        default=Path.cwd()
    )

    parser.add_argument(
        "--slug",
        required=True
    )

    args = parser.parse_args()

    repo = args.repo.resolve()

    output_md = (
        repo /
        "docs" /
        f"{args.slug}.md"
    )

    output_assets = (
        repo /
        "docs" /
        "assets" /
        args.slug
    )

    if not output_md.parent.exists():
        raise SystemExit(
            f"Missing docs folder: {output_md.parent}"
        )

    if output_assets.exists():
        shutil.rmtree(output_assets)

    output_assets.mkdir(
        parents=True
    )

    with tempfile.TemporaryDirectory(
        prefix="a3c_doc_"
    ) as temp_dir:

        temp_dir = Path(temp_dir)

        with zipfile.ZipFile(args.zip_file) as archive:
            archive.extractall(temp_dir)

        html_files = list(
            temp_dir.glob("*.html")
        )

        if len(html_files) != 1:
            raise SystemExit(
                "Expected one HTML file in ZIP; "
                f"found {len(html_files)}."
            )

        soup = BeautifulSoup(
            html_files[0].read_text(
                encoding="utf-8"
            ),
            "html.parser"
        )

        # Remove Google Docs comment references
        for sup in list(
            soup.find_all("sup")
        ):
            if sup.find(
                "a",
                href=re.compile(
                    r"^#cmnt\d+$"
                )
            ):
                sup.decompose()

        # Remove the exported Google comment discussion
        for anchor in list(
            soup.find_all(
                "a",
                id=re.compile(
                    r"^cmnt\d+$"
                )
            )
        ):
            container = anchor.find_parent(
                ["p", "div", "li"]
            )

            if container:
                container.decompose()
            else:
                anchor.decompose()

        # Replace Google redirect links with their real targets
        for anchor in soup.find_all(
            "a",
            href=True
        ):
            anchor["href"] = unwrap_google_url(
                anchor["href"]
            )

        # Copy images and recreate Google Docs cropping
        for image in soup.find_all(
            "img",
            src=True
        ):
            output_name = crop_if_needed(
                image,
                temp_dir,
                output_assets
            )

            image["src"] = (
                f"assets/{args.slug}/"
                f"{output_name}"
            )

        # Remove Google-specific CSS/script data
        for element in soup.find_all(
            ["style", "script"]
        ):
            element.decompose()

        for element in soup.find_all(True):
            element.attrs.pop(
                "class",
                None
            )

            element.attrs.pop(
                "style",
                None
            )

        markdown = to_markdown(
            str(soup),
            heading_style="ATX",
            bullets="-",
            strip=["span"],
        )

    # Mechanical Markdown cleanup
    markdown = re.sub(
        r"(?m)^#{1,6}\s*$",
        "",
        markdown
    )

    markdown = re.sub(
        r"\n{4,}",
        "\n\n\n",
        markdown
    )

    markdown = (
        markdown.strip()
        + "\n"
    )

    output_md.write_text(
        markdown,
        encoding="utf-8"
    )

    print(
        f"Created {output_md}"
    )

    print(
        f"Created "
        f"{len(list(output_assets.iterdir()))} "
        f"assets in {output_assets}"
    )


if __name__ == "__main__":
    main()