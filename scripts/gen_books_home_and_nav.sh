#!/usr/bin/env bash

set -e

# 1. 收集所有 book 目录及其 title
declare -A book_titles
for dir in book*/; do
  if [ -f "$dir/book.json" ]; then
    # 用jq读取title
    title=$(jq -r '.title // empty' "$dir/book.json")
    if [ -n "$title" ]; then
      book_titles["$dir"]="$title"
    fi
  fi
done

# 2. 生成美观的首页 index.html
cat > public/index.html <<EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <title>书库导航</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body { font-family: 'Segoe UI', 'Helvetica Neue', Arial, 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif; background: #f7f7f9; margin: 0; padding: 0;}
    .container { max-width: 800px; margin: 40px auto; background: #fff; border-radius: 16px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); padding: 32px; }
    h1 { text-align: center; color: #333; letter-spacing: 2px;}
    ul { list-style: none; padding: 0;}
    li { margin: 20px 0; }
    a.book-link { 
      display: block; 
      padding: 20px 24px; 
      background: linear-gradient(90deg,#f3e7e9 0,#e3eeff 100%);
      border-radius: 10px; 
      font-size: 1.2em; 
      color: #2d3a4b; 
      text-decoration: none; 
      box-shadow: 0 2px 8px rgba(0,0,0,0.04);
      transition: box-shadow 0.2s, transform 0.2s;
    }
    a.book-link:hover {
      box-shadow: 0 6px 16px rgba(0,0,0,0.12);
      transform: translateY(-2px) scale(1.02);
      color: #1e6bb8;
    }
    .footer { text-align: center; margin-top: 32px; color: #999; font-size: 0.95em;}
  </style>
</head>
<body>
  <div class="container">
    <h1>📚 我的书库导航</h1>
    <ul>
EOF

for dir in "${!book_titles[@]}"; do
  name=$(basename "$dir")
  title="${book_titles[$dir]}"
  echo "      <li><a class=\"book-link\" href=\"$name/\">$title</a></li>" >> public/index.html
done

cat >> public/index.html <<EOF
    </ul>
  </div>
</body>
</html>
EOF

# 3. 自动修改各book的book.json，设置 variables.d4t.nav
for dir in "${!book_titles[@]}"; do
  nav='['
  for otherdir in "${!book_titles[@]}"; do
    if [ "$dir" != "$otherdir" ]; then
      othername=$(basename "$otherdir")
      othertitle="${book_titles[$otherdir]}"
      nav="$nav{\"url\": \"../$othername/\", \"target\": \"_self\", \"name\": \"$othertitle\"},"
    fi
  done
  # 增加额外导航
  nav="$nav{\"url\": \"https://github.com/auohh/\", \"target\": \"_blank\", \"name\": \"Github\"}"
  nav="$nav]"
  # 使用jq更新book.json
  jq --argjson nav "$nav" '
    .variables.d4t.nav = $nav
  ' "$dir/book.json" > "$dir/book.json.tmp" && mv "$dir/book.json.tmp" "$dir/book.json"
done

