import os
import subprocess
import sys
from random import randint

from dotenv import load_dotenv
import dropbox
from rich.console import Console
from rich.panel import Panel
from rich.progress import (
    Progress,
    SpinnerColumn,
    TextColumn,
    TimeRemainingColumn,
    BarColumn,
    TimeElapsedColumn,
)

from services import download_instagram_video, download_tiktok_video, upload_to_dropbox


input_folder = "orig"
output_folder = "ready"

console = Console()
console.print(
    Panel("[bold cyan]UNIQUEIZES[/bold cyan]"),
    justify="center",
)

load_dotenv()

token_dbx = os.getenv("DBX_TOKEN")
if not token_dbx:
    token_dbx = input("Enter your dbx_token or skip: ").strip()
time_in_metadata = str(os.getenv("TIME_IN_METADATA "))


if token_dbx:
    dbx = dropbox.Dropbox(token_dbx)
    try:
        dbx.users_get_current_account()
    except dropbox.exceptions.AuthError:
        console.print("[bold red]Incorrect token![/bold red]")
        sys.exit()


with open("urls.txt") as f:
    urls_list = f.read().splitlines()
    urls_not_empty = [i for i in urls_list if i]
if urls_not_empty:
    with Progress(
        SpinnerColumn(spinner_name="line"),
        TextColumn("[cyan]{task.description}"),
        TimeRemainingColumn(),
    ) as progress:
        download_task = progress.add_task(
            "[cyan]Загрузка видео...", total=len(urls_not_empty)
        )

        for url in urls_not_empty:
            if "instagram" in url:
                download_instagram_video(url)
            else:
                download_tiktok_video(url)
            progress.update(download_task, advance=1)

with Progress(
    TextColumn("[bold yellow]{task.description}"),
    BarColumn(bar_width=None, complete_style="green", finished_style="bright_green"),
    "[progress.percentage]{task.percentage:>3.0f}%",
    TimeElapsedColumn(),
) as progress:
    video_files = os.listdir(input_folder)
    processing_task = progress.add_task(
        "[cyan]processing...", total=len(video_files), message=""
    )

    for filename in video_files:
        if filename.lower().endswith((".mp4", ".mov")):
            input_file = os.path.join(input_folder, filename)
            output_file = (
                "IMG_" + "".join(map(str, [randint(0, 9) for _ in range(4)])) + ".mp4"
            )

            subprocess.run(
                [
                    "core/unique.sh",
                    input_file,
                    output_folder,
                    output_file,
                    time_in_metadata,
                ],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            os.remove(f"{input_file}")

            if token_dbx:
                upload_to_dropbox(dbx, output_folder, output_file)
                os.remove(f"{output_folder}/{output_file}")

        progress.update(processing_task, advance=1)


console.print("[bold cyan]It's done![/bold cyan]")
