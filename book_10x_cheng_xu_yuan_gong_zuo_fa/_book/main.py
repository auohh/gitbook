import os
import re
import requests
from urllib.parse import urlparse
from pathlib import Path

# 配置
MARKDOWN_ROOT = '.'  # 搜索的根目录
IMG_DIR = 'assets/images'  # 图片保存目录

# 正则：匹配 ![](...) 语法
IMG_PATTERN = re.compile(r'!\[.*?\]\((https?://[^\)]+)\)')

def download_image(url, save_dir):
    """下载图片到本地, 返回本地相对路径"""
    os.makedirs(save_dir, exist_ok=True)
    parsed_url = urlparse(url)
    filename = os.path.basename(parsed_url.path)
    # 防止重名
    local_path = os.path.join(save_dir, filename)
    i = 1
    while os.path.exists(local_path):
        name, ext = os.path.splitext(filename)
        local_path = os.path.join(save_dir, f"{name}_{i}{ext}")
        i += 1
    try:
        resp = requests.get(url, timeout=15)
        if resp.status_code == 200:
            with open(local_path, 'wb') as f:
                f.write(resp.content)
            print(f"Downloaded: {url} -> {local_path}")
            return local_path.replace("\\", "/")
        else:
            print(f"Failed to download {url} (status {resp.status_code})")
    except Exception as e:
        print(f"Error downloading {url}: {e}")
    return None

def process_markdown(md_path):
    """处理单个 Markdown 文件，下载并替换图片链接"""
    with open(md_path, 'r', encoding='utf-8') as f:
        content = f.read()
    changed = False

    def replace_img(match):
        url = match.group(1)
        if not url.startswith('http'):
            return match.group(0)  # 非外链不处理
        local_path = download_image(url, IMG_DIR)
        if local_path:
            # 生成相对路径
            rel_path = os.path.relpath(local_path, os.path.dirname(md_path))
            rel_path = rel_path.replace("\\", "/")
            nonlocal changed
            changed = True
            return f"![]({rel_path})"
        else:
            return match.group(0)

    new_content = IMG_PATTERN.sub(replace_img, content)
    if changed:
        with open(md_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated: {md_path}")

def main():
    for root, dirs, files in os.walk(MARKDOWN_ROOT):
        for file in files:
            if file.endswith('.md'):
                md_path = os.path.join(root, file)
                process_markdown(md_path)

if __name__ == '__main__':
    main()

