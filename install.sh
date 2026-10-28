#!/bin/bash
mkdir -p ~/bin

cat << 'EOF' > ~/bin/pd
#!/bin/bash
C="$HOME/.pd_config"
if [ "$1" = "-c" ] || [ ! -s "$C" ]; then
    read -rp "Pixeldrain API Key: " K
    [ -z "$K" ] && exit 1
    echo "$K" > "$C" && chmod 600 "$C"
    [ "$1" = "-c" ] && echo "API Key Updated" && exit 0
fi
[ -f "$1" ] || { echo "Usage: pd <file> | pd -c (update token api)"; exit 1; }
res=$(curl -# --connect-timeout 15 --keepalive-time 30 --http1.1 -H "Expect:" -u ":$(cat "$C")" -T "$1" https://pixeldrain.com/api/file/)
id=$(echo "$res" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')
[ -n "$id" ] && echo -e "\nDone: https://pixeldrain.com/u/$id" || echo -e "\nFailed: $res"
EOF

cat << 'EOF' > ~/bin/goup
#!/bin/bash
[ -f "$1" ] || { echo "Usage: goup <file>"; exit 1; }
srv=$(curl -s -m 10 https://api.gofile.io/servers | grep -oP '(?<="name":")[^"]+' | head -n 1)
res=$(curl -# --connect-timeout 15 --keepalive-time 30 --http1.1 -H "Expect:" -F "file=@$1" "https://${srv:-store1}.gofile.io/contents/uploadfile")
url=$(echo "$res" | grep -oP '(?<="downloadPage":")[^"]+')
[ -n "$url" ] && echo -e "\nDone: $url" || echo -e "\nFailed: $res"
EOF

cat << 'EOF' > ~/bin/bh
#!/bin/bash
[ -f "$1" ] || { echo "Usage: bh <file>"; exit 1; }
res=$(curl -# --connect-timeout 15 --keepalive-time 30 --http1.1 -H "Expect:" -T "$1" "https://w.buzzheavier.com/$(basename "$1")")
id=$(echo "$res" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')
[ -n "$id" ] && echo -e "\nDone: https://buzzheavier.com/$id" || echo -e "\nFailed: $res"
EOF

chmod +x ~/bin/pd ~/bin/goup ~/bin/bh

if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
    export PATH="$HOME/bin:$PATH"
fi

echo "Done, cmd: pd, goup, bh | Update api token: pd -c"

