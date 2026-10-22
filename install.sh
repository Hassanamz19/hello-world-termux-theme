#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "⏳ Installing dependencies..."
pkg update -y && pkg install -y git zsh curl starship fontconfig figlet ncurses-utils

touch ~/.hushlogin

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"

[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

mkdir -p ~/.termux
cat << 'COLORS' > ~/.termux/colors.properties
background = #1a1b26
foreground = #c0caf5
cursor = #c0caf5
color0 = #15161e
color8 = #414868
color1 = #f7768e
color9 = #f7768e
color2 = #9ece6a
color10 = #9ece6a
color3 = #e0af68
color11 = #e0af68
color4 = #7aa2f7
color12 = #7aa2f7
color5 = #bb9af7
color13 = #bb9af7
color6 = #7dcfff
color14 = #7dcfff
color7 = #a9b1d6
color15 = #c0caf5
COLORS

curl -fsSL -o ~/.termux/font.ttf https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf

mkdir -p ~/.config
cat << 'CONFIG' > ~/.config/starship.toml
format = """
[┌─](bold #7aa2f7)$directory$git_branch$git_status$package$python$nodejs
[└─>](bold #bb9af7) """
right_format = """$battery$cmd_duration$time"""
continuation_prompt = '[∙](bright-black) '

[directory]
style = "bold #7aa2f7"
format = "[$path]($style) "
truncation_length = 3
truncation_symbol = "…/"

[git_branch]
symbol = " "
style = "bold #bb9af7"
format = "on [$symbol$branch]($style) "

[git_status]
style = "bold #f7768e"
format = '([$all_status$ahead_behind]($style) )'

[package]
symbol = " "
style = "bold #e0af68"
format = "[$symbol$version]($style) "

[battery]
full_symbol = "🔋 "
charging_symbol = "⚡ "
discharging_symbol = "🪫 "
format = "[$symbol$percentage]($style) "
[[battery.display]]
threshold = 100
style = "bold green"

[cmd_duration]
min_time = 2_000
style = "bold #e0af68"
format = "took [$duration]($style) "

[time]
disabled = false
time_format = "%R"
style = "bold #565f89"
format = "[$time]($style)"
CONFIG

cat << 'BANNER' > ~/.motd_banner
clear
echo -e "\e[1;36m"
figlet -f slant "Hello World"
echo -e "\e[1;35m────────────────────────────────────────────\e[0m"
BANNER

sed -i 's/^ZSH_THEME=.*/ZSH_THEME=""/' ~/.zshrc 2>/dev/null || true
sed -i 's/plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc 2>/dev/null || true

sed -i '/motd_banner/d' ~/.zshrc 2>/dev/null || true
sed -i '1i source ~/.motd_banner' ~/.zshrc

sed -i '/starship init zsh/d' ~/.zshrc 2>/dev/null || true
echo 'eval "$(starship init zsh)"' >> ~/.zshrc

chsh -s zsh 2>/dev/null || true
termux-reload-settings

echo "✅ Installed successfully!"
