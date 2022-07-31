from typer import run
from pdf2image import convert_from_path


def main(input: str, output: str, format: str = "PNG"):
    images = convert_from_path(input, last_page=1)
    thumbnail = images[0]
    thumbnail.save(output, format)


if __name__ == "__main__":
    run(main)
