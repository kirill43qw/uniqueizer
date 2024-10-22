from dropbox import files
from instaloader import Instaloader, Post


def download_instagram_video(url):
    L = Instaloader(
        save_metadata=None, download_pictures=None, post_metadata_txt_pattern=""
    )
    L.download_post(Post.from_shortcode(L.context, url.split("/")[4]), target="orig")


def upload_to_dropbox(dbx, output_folder, output_file):
    with open(f"{output_folder}/{output_file}", "rb") as file:
        dbx.files_upload(
            file.read(), f"/{output_file}", mode=files.WriteMode("overwrite")
        )


def download_tiktok_video(url): ...
