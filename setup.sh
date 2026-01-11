#!/bin/bash

# =============================
#          SETUP SCRIPT
# =============================

# Lấy thư mục chứa script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Sao chép các file cấu hình (không ghi đè nếu đã tồn tại)
echo "Đang sao chép file cấu hình cá nhân..."
cp -rf "$SCRIPT_DIR/.config" $HOME/
cp -rf "$SCRIPT_DIR/Pictures" $HOME/
echo "Hoàn tất sao chép."

cd $HOME

# Cập nhật hệ thống trước khi cài đặt
echo "Đang cập nhật hệ thống..."
sudo pacman -Syu --noconfirm

echo "Hoàn tất."

# Cài đặt các gói cần thiết
echo "Cài đặt các gói: Hyprland, ..."
sudo pacman -S --needed --noconfirm hyprland playerctl kitty brightnessctl swaybg wl-clipboard noto-fonts-cjk thunar thunar-archive-plugin grim slurp xdg-desktop-portal-hyprland dunst hyprpaper

# Clone và cài đặt `yay` nếu chưa tồn tại
if [ ! -d "yay" ]; then
  echo "Cloning yay..."
  git clone https://aur.archlinux.org/yay.git
fi

cd yay || exit
echo "Đang build và cài đặt yay..."
makepkg -si --noconfirm
cd ..

cp -n "$SCRIPT_DIR/.zshrc" $HOME/

# Cài đặt Quickshell, Icon, Font
echo "Cài đặt quickshell, Icon, Font"
yay -S --noconfirm quickshell-git sysstat papirus-icon-theme otf-comicshanns-nerd cava mpvpaper

echo "con config quickshell"
git clone https://github.com/mailong2401/cartoon-shell.git ~/.config/quickshell/cartoon-shell

# 🛠️ Cleanup sau khi cài đặt
echo "Dọn dẹp sau khi cài đặt..."
rm -rf yay

# ✅ Hoàn thành
echo "Quá trình cài đặt hoàn tất! Khởi động lại máy để hoàn tất cấu hình."
read -p "Bạn có muốn reboot không? (y/n): " answer

case "$answer" in
[Yy]*)
  echo "Đang reboot..."
  sudo reboot
  ;;
[Nn]*)
  echo "Hủy reboot."
  exit 0
  ;;
*)
  echo "Vui lòng nhập y hoặc n."
  exit 1
  ;;
esac
