from datetime import datetime

import instaloader


def download_video(username, start_date, end_date):
    L = instaloader.Instaloader(save_metadata=False, download_pictures=False)
    profile = instaloader.Profile.from_username(L.context, username)
    start_date = datetime.strptime(start_date, "%Y-%m-%d")
    end_date = datetime.strptime(end_date, "%Y-%m-%d")

    if start_date > end_date:
        start_date, end_date = end_date, start_date

    for post in profile.get_posts():
        if start_date <= post.date <= end_date:
            print(f"Downloading post from {post.date} by {username}")
            L.download_post(
                post, target=f"{username}_{end_date.date()}_{start_date.date()}"
            )
        elif post.date < start_date:
            break


def main():
    username = input("username: ")
    start_date = input("start_date: ")
    if not start_date:
        start_date = datetime.now().strftime("%Y-%m-%d")
    end_date = input("end_date: ")

    try:
        datetime.strptime(start_date, "%Y-%m-%d")
        datetime.strptime(end_date, "%Y-%m-%d")
    except ValueError:
        print("Incorrect date format. Example: YYYY-MM-DD")

    download_video(username, start_date, end_date)


if __name__ == "__main__":
    main()
